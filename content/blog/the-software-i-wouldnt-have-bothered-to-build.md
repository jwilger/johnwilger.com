+++
title = "The Software I Wouldn't Have Bothered to Build"
description = "A small SSH-agent annoyance became a designed, tested, documented open-source tool in one morning. Agentic development changed which problems were worth solving."
slug = "the-software-i-wouldnt-have-bothered-to-build"
date = 2026-07-19

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

Instead, I spent some time defining the problem with a coding agent. We worked
through the architecture, wrote down the decisions that would be expensive to
change later, and split the work into increments I could review independently.
Then I left the computer and did other things with my life while the agent built
it.

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

## The part I delegated

I've been writing software long enough that I could have built this without an
agent. Realistically, I wouldn't have.

The expected value was wrong. A few hours of occasional SSH-agent irritation
didn't justify several evenings of reading protocol documents, building a Unix
socket server, writing integration tests with fake agents, packaging it, and
documenting the result. I'd have spent twenty minutes on a brittle script,
declared it good enough, and paid the annoyance tax indefinitely.

Agentic development changed that calculation, but not because an LLM can type
Rust faster than I can. The useful part was being able to stop typing at all.

Before I stepped away, the agent and I turned the idea into a
[Tiber](https://github.com/jwilger/ai-plugins/tree/main/plugins/tiber) backlog.
We worked out the trust boundary and the failure policy. I approved the general
architecture: a stable proxy socket, multiple dynamically discovered backends,
identity aggregation, operation-specific failover, and a separate control
socket. The work was divided into semantic increments covering the repository
harness, proxy behavior, discovery, adaptive signing, packaging, releases, and
documentation. Decisions with expensive consequences went into ADRs.

At that point, the work no longer needed me continuously. The agent could take
the next ticket, write a failing test, implement the behavior, run the rest of
the gates, review the diff, commit it, push it, watch CI, and move on. I didn't
sit there approving every command or reading every intermediate patch. I went
away.

That was possible because this wasn't a bare agent dropped into an empty
repository with a prompt to "build an SSH proxy." I've spent a lot of time on
the harness around it: test-first development, strict compiler and linter
settings, mutation testing, architectural decision records, isolated
worktrees, independent review passes, commit and push gates, and instructions
for watching CI and deployed behavior. I'm currently consolidating that work in
my [ai-plugins repository](https://github.com/jwilger/ai-plugins).

Those guardrails are what let me trust the agent with long stretches of
autonomous work. Trust here doesn't mean assuming it won't make mistakes. It
means I know what evidence it has to produce before it can move on, and I know
which decisions will make it stop and wait for me.

For Lanyard, fake SSH agents exercised framed protocol messages over real Unix
sockets. Black-box tests launched the daemon, registered agents through its
control socket, inspected JSON status, sent termination signals, and checked
socket ownership and cleanup. Strict Clippy settings turned suspicious
shortcuts into build failures. `cargo-deny` checked dependency policy. Mutation
testing changed the program and checked whether the tests noticed.

The review passes found bugs that would have survived a demo:

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

I wasn't present when most of these were introduced or found. The agent worked
through failing tests, surviving mutants, review findings, CI failures, and
deployment checks on its own. It came back when a decision crossed a boundary
we'd established or when the available evidence couldn't settle the question.
That distinction took time to build into my workflow. Without it, "autonomous"
usually means either reckless or exhausting: the agent barrels through choices
it shouldn't make, or it interrupts so often that I may as well write the code.

## Where I still had to be involved

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

Release automation produced one of the decisions that did need me. The reusable
release workflow I normally use pins its top-level revision but invokes nested
actions by mutable tags in jobs that handle publishing credentials. The agent
stopped rather than weakening the repository's supply-chain policy to get a
green release. We left credential-bearing publication fail-closed until the
shared workflow can be fixed and repinned. GitHub Pages could still deploy.

The run still exposed holes in that setup. The agent initially missed my
worktree plugin and made application changes in the primary checkout while two
other tickets ran in worktrees. Publishing the documentation site revealed that
the Pages workflow was stranded on another branch and Pages hadn't been enabled
for the repository. A task-closing command exited successfully once without
actually moving the task to `done`.

Each failure became a change to the harness: require ticket work to happen in
isolated worktrees, block primary-checkout commits and pushes, verify a deployed
URL instead of treating a successful push as a deployment, and inspect the
resulting task state instead of trusting an exit code. That's the investment
that compounds. The next project starts with the failures from this one already
encoded.

## The economics of caring

The phrase "AI makes developers faster" doesn't describe what happened here. I
didn't type Rust faster. For much of the implementation, I wasn't typing Rust
at all.

Yesterday, this annoyance belonged below the line: too small to deserve a real
program, too fiddly to solve properly, not painful enough to consume a weekend.
The available options were to tolerate it or build something I wouldn't be
proud to share.

This time I paid the part of the cost that needed my judgment: defining the
problem, choosing the architecture, deciding how signing failures should behave,
and setting the boundaries for credentials and release automation. The harness
carried much of the remaining work while I spent my attention elsewhere. That
made ADRs, mutation tests, cross-architecture artifacts, Home Manager
integration, and documentation reasonable for a personal utility.

There are thousands of annoyances like this in the gaps between general-purpose
tools. Most never become software because the engineering cost is larger than
the irritation. They become shell-history archaeology, half-remembered dotfile
snippets, and habits built around bugs nobody had time to remove.

Now Git can sign a commit whether I attached to Zellij from the chair in front
of my desktop or from a laptop somewhere else. I got the tool without donating
the rest of my day to its implementation. I wouldn't have made that trade before
I could trust the surrounding system to keep working, catch mistakes, and know
when to call me back.
