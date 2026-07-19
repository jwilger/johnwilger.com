+++
title = "The Software I Wouldn't Have Bothered to Build"
description = "A small SSH-agent annoyance became a designed, tested, documented open-source tool in one morning. Agentic development changed which problems were worth solving."
slug = "the-software-i-wouldnt-have-bothered-to-build"
date = 2026-07-19
draft = true

[extra]
cover = "/images/blog/the-software-i-wouldnt-have-bothered-to-build-cover.png"

[taxonomies]
tags = ["ai", "llm", "software-engineering", "open-source", "rust"]
+++

This morning I had an annoyance. By lunchtime it had a name, an architecture,
a public repository, a Rust implementation, ADRs, strict tests, release
automation, and [a website that looks better than most developer-tool sites
have any right to](https://jwilger.github.io/lanyard-ssh-agent/).

The tool is [Lanyard](https://github.com/jwilger/lanyard-ssh-agent), an SSH-agent
switching proxy. I built it because I use 1Password's SSH agent when I'm sitting
at my desktop, but I also SSH into that desktop from my laptop and forward the
laptop's agent. Both routes work fine until they meet a long-lived Zellij
session.

`SSH_AUTH_SOCK` inside the session points at whichever socket existed when the
session started. Attach locally and the session knows about 1Password. Attach
remotely and it may know about the forwarded agent. Move between the two and
the environment doesn't follow you. Authentication and Git commit signing then
depend on which machine happened to create the session hours or days earlier.

I'd put up with this for a while. The usual next step would have been a shell
function that rewrote an environment variable, a symlink shuffled between
sockets, or some startup hook whose behavior I'd forget six months later. It
would mostly work. It would also fail in exactly the cases that made the problem
interesting.

Instead, I described the problem to a coding agent and spent the morning turning
the annoyance into a product.

## The gap between a workaround and a tool

The first idea sounds almost trivial: expose one stable Unix socket and forward
requests to whichever SSH agent works.

That sentence hides most of the engineering.

An SSH agent isn't just a bag of keys behind a socket. Clients list identities,
request signatures, query extensions, and establish OpenSSH session bindings.
Some operations are safe to retry after a disconnect. Some aren't. A failed
signature request may mean "I don't have that key," "the user denied access,"
or "I signed it and the response was lost." Forwarded sockets appear and
disappear as SSH connections come and go. A local desktop agent can be present
but locked. Multiple agents may advertise the same public key with different
comments.

A shell script can choose a socket before launching Git. It can't make one
long-lived client connection see a deduplicated union of identities, route a
signature request to the agent that can satisfy it, replay an acknowledged
session binding on a newly selected backend, and distinguish safe failover from
an ambiguous mutation.

Once I wrote the problem down that way, the shape of Lanyard became clear:

- A stable `SSH_AUTH_SOCK` under the user's runtime directory.
- Automatic discovery of same-user OpenSSH forwarding sockets.
- Explicit registration and removal for login hooks and unusual socket paths.
- A configured local agent, normally 1Password, kept as the final fallback.
- Identity aggregation with deterministic ordering and key-blob deduplication.
- Per-operation timeouts, bounded messages, and a hard candidate limit.
- Read-only routing and narrowly supported OpenSSH extensions, with agent
  mutation requests rejected.
- A local control socket with machine-readable status rather than state hidden
  in shell variables.

That's a small systems program, not a clever alias.

## What the agent changed

I've been writing software long enough that I could have built this without an
agent. Realistically, I wouldn't have.

The expected value was wrong. A few hours of occasional SSH-agent irritation
didn't justify several evenings of reading protocol documents, building a Unix
socket server, writing integration tests with fake agents, packaging it, and
documenting the result. I'd have spent twenty minutes on a brittle script,
declared it good enough, and paid the annoyance tax indefinitely.

Agentic development changed that calculation. I supplied the problem, the
constraints, and the decisions that mattered. The agent handled enough of the
mechanical middle that the full solution fit inside a morning.

We started by turning the idea into a Tiber backlog rather than immediately
generating code. The work was split into semantic increments: repository and
engineering harness, static proxy, discovery and identity aggregation, adaptive
signing, end-to-end verification, Home Manager packaging, release automation,
and the documentation site. Architectural decisions went into ADRs before the
implementation made them expensive to reconsider.

The implementation proceeded test-first. Fake SSH agents exercised framed
protocol messages over real Unix sockets. Black-box CLI tests launched the
daemon, registered agents through its control socket, inspected JSON status,
sent termination signals, and checked socket ownership and cleanup. Strict
Clippy settings turned suspicious shortcuts into build failures. `cargo-deny`
checked dependency policy. Mutation testing repeatedly rewrote the program and
proved that the tests noticed.

The reviews weren't ceremonial. They found bugs that would have survived a
happy-path demo:

- A session binding could pin a client to the first agent and prevent signing
  with a key advertised by another.
- A signing disconnect was initially treated as fail-closed across the whole
  candidate set, contradicting the availability policy recorded in the ADR. It
  needed to advance to a different agent without retrying the same one.
- An ambiguous `session-bind` disconnect had the opposite requirement because
  replaying that mutation onto another backend could apply it twice.
- If every agent returned malformed identity data, the proxy reported a valid
  empty key list instead of a protocol failure.
- Aggregated identity responses could exceed the same message bound enforced on
  individual upstream responses.
- A failed control-socket bind could leave behind an orphaned agent socket.
- The first GitHub Pages run started before Pages had been enabled on the
  repository and failed with a 404.

Those aren't aesthetic disagreements. They're protocol, availability, and
lifecycle defects. The value of the workflow wasn't that an LLM emitted Rust
quickly. It was that the agent could stay in the loop through failing tests,
surviving mutants, independent reviews, CI, deployment, and the fixes those
gates demanded.

## Secure means choosing the boundary

"Secure" is easy to sprinkle over a README and harder to make concrete.

Lanyard handles signing credentials, so its trust boundary needed to be
explicit. It accepts only same-user discovered sockets, creates a private
runtime directory and owner-only sockets, rejects SSH-agent mutation requests,
bounds input and output messages, caps candidate fan-out, and applies operation-
specific timeouts. An acknowledged OpenSSH session binding is retained and
replayed when a later request reaches a new backend.

The failure policy is operation-specific rather than uniformly "retry" or
uniformly "stop." Identity listing and queries can move through candidates.
An explicit signing failure can fall through because another agent may own the
same key. A signing disconnect may advance to a different backend under the
availability policy, but it won't resend the same request to the same backend.
An ambiguous session-binding disconnect stops because duplicating that mutation
crosses a different safety boundary.

Release automation got the same treatment. The reusable release workflow I
normally use turned out to pin its top-level revision while invoking nested
actions by mutable tags in jobs that handle publishing credentials. Rather than
wave that through because the morning was nearly over, Lanyard's caller stays
fail-closed until the shared workflow is fixed and repinned. GitHub Pages can
deploy; credential-bearing publication can't quietly opt into a weaker supply-
chain policy.

None of these choices came from asking a model to "make it secure." They came
from defining the actual deployment model, writing down the plausible failures,
and making the tests and workflows enforce the decisions.

## The agent was still an agent

This wasn't a flawless autonomous run, and pretending otherwise would make the
story useless.

The agent initially missed my worktree plugin and made application changes in
the primary checkout while two independent tickets ran in worktrees. That made
branch integration needlessly awkward. When I asked it to publish the website,
it pushed the site commit and reported success before noticing that the Pages
workflow lived in another branch and Pages wasn't enabled on the repository.
Later, the task-closing workflow exited successfully without actually moving a
completed ticket to `done`.

I caught some of those mistakes. Repository guards, tests, and independent
review passes caught others. The workflow improved as failures appeared: move
all ticket work into isolated worktrees, make primary-checkout commits and
pushes fail, verify deployed URLs rather than equating a push with publication,
and inspect task state instead of trusting a green automation run.

This is the same standard I'd apply to any engineering system. A useful agent
doesn't remove the need for observability and controls. It makes investing in
them pay off across every subsequent task.

## The economics of caring

The phrase "AI makes developers faster" still feels too shallow for what
happened this morning.

I didn't type Rust faster. I moved a problem across a threshold.

Yesterday, this annoyance belonged below the line: too small to deserve a real
program, too fiddly to solve properly, not painful enough to consume a weekend.
The available options were to tolerate it or build something I wouldn't be
proud to share.

Today, the line moved. I could afford to care about the protocol details. I
could afford ADRs for a personal utility, mutation tests for a proxy with a
tiny codebase, cross-architecture release artifacts, Home Manager integration,
and documentation written for somebody who isn't me. I could afford to turn a
local irritation into software another person can install and understand.

The output is a tool, but the change I care about is the expanded set of
problems worth solving well.

There are thousands of annoyances like this in the gaps between general-purpose
tools. Most never become software because the engineering cost is larger than
the irritation. They become shell-history archaeology, half-remembered dotfile
snippets, and habits built around bugs nobody had time to remove.

Agentic development doesn't make those problems disappear. It makes a different
response economically possible: define the problem precisely, choose an
architecture, encode the safety boundaries, and let a disciplined system carry
the work through implementation and verification.

Sometimes the result is a company. Sometimes it's infrastructure. And sometimes
it's just that Git can sign a commit whether I attached to Zellij from the chair
in front of my desktop or from a laptop somewhere else.

That was worth a morning.
