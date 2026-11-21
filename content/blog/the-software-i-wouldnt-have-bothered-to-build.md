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

Most engineering organizations carry a list of problems that nobody plans to fix: a release step that someone performs by hand, a script that only its author understands, a monthly report assembled by copying figures from one system into another. Few of them are hard. They stay on the list because fixing one properly would cost more than the irritation it causes, and while software was written by hand that was usually the right call.

One morning in July I had a problem of that kind. By lunchtime it had been replaced by [Lanyard](https://github.com/jwilger/lanyard-ssh-agent), an open-source tool with a written design, strict tests, release automation, and [a documentation site](https://jwilger.github.io/lanyard-ssh-agent/), and for much of that morning I wasn't at the computer. What made the tool worth building was how little of my attention it needed. That's a different change from writing code faster, and it bears on every item on that list.

To prove who I am to other machines and to sign my Git commits, I rely on an SSH agent, a small program that holds my private keys and signs requests with them. At my desk that's 1Password's agent. When I connect to the same desktop from my laptop, it's the laptop's agent, forwarded over the connection. I also keep terminal sessions running for days in Zellij, and a session knows only about the agent that existed when it started. The agent's address is held in an environment variable, `SSH_AUTH_SOCK`, which is set once and doesn't follow me from one machine to the other. Authentication and commit signing therefore worked or failed according to which machine had created the session hours or days earlier.

I'd put up with this for a while. The usual fix would have been a shell function that rewrote the variable, a symlink switched between the two agents, or a startup hook whose behavior I'd have forgotten in six months. It would have worked most of the time and failed in the cases that made the problem difficult. This time I spent a while defining the problem with a coding agent. We worked through the architecture, wrote down the decisions that would be expensive to change later, and split the work into increments I could review independently. Then I left, and the agent built it.

## Why a script wouldn't do

The proper fix sounds nearly as small as the workaround: give every session one permanent address, and put a program behind it that passes each request to whichever agent is available. The distance between that sentence and a tool I'd trust with my signing keys is where the cost lies, and it's the reason problems like this one stay on the list.

An SSH agent does more than hand over keys. Programs ask it to list the identities it holds, to sign things, to answer queries about extensions, and to bind itself to a particular SSH session. Some of those requests can safely be repeated after a dropped connection and some can't. A failed signature might mean the agent doesn't have that key, or that the user declined, or that the signature was made and the reply was lost. Forwarded agents appear and disappear as connections come and go. The desktop agent can be present but locked. Two agents can offer the same key under different names.

A script can choose an agent before Git starts. It can't give one long-running session a single combined list of keys, send each signing request to the agent able to satisfy it, repeat an acknowledged session binding on a newly chosen agent, or tell a failure that's safe to retry from one that isn't.

Written down that way, the problem calls for a small systems program. Lanyard provides one stable address under the user's runtime directory. It discovers forwarded agents belonging to the same user automatically, lets login hooks register and remove others explicitly, and keeps a configured local agent, normally 1Password, as the final fallback. It merges the agents' keys into one list in a fixed order with duplicates removed. Each operation has a timeout, messages are bounded in size, and there's a hard limit on how many agents a request will try. Lanyard passes through read-only requests and a narrow set of OpenSSH extensions, and it rejects any request that would change the keys an agent holds. Its state is reported in machine-readable form through a separate control socket, where a script would have left it in shell variables.

## What I handed over

I've been writing software long enough that I could have built this without an agent. I wouldn't have, because the expected value was wrong. A few hours of occasional irritation didn't justify several evenings of reading protocol documents, building a socket server, writing integration tests against fake agents, packaging the result, and documenting it. I'd have spent twenty minutes on a brittle script, called it good enough, and gone on paying for the annoyance indefinitely.

Agentic development changed that calculation, though not because a model types Rust faster than I do. It changed because I could stop typing.

Before I stepped away, the agent and I turned the idea into a [Tiber](https://github.com/jwilger/ai-plugins/tree/main/plugins/tiber) backlog. We worked out the trust boundary, meaning which agents the tool would accept and what it would refuse to do, and the policy for failures. I approved the general architecture: a stable proxy socket, several dynamically discovered agents behind it, a merged list of identities, failover rules specific to each operation, and a separate control socket. The work was divided into increments covering the repository's checks, proxy behavior, discovery, adaptive signing, packaging, releases, and documentation. Decisions with expensive consequences went into architecture decision records, short documents that state a decision and the reasons for it.

From that point the work didn't need me continuously. The agent took a ticket, wrote a failing test, implemented the behavior, ran the remaining checks, reviewed the diff, committed and pushed it, watched the automated build, and moved to the next ticket. I didn't approve each command or read each intermediate patch.

That was possible because the agent wasn't working in an empty repository with an instruction to build an SSH proxy. It was working inside a set of checks I've spent a long time on: test-first development, strict compiler and linter settings, mutation testing, decision records, isolated working copies, independent review passes, gates on commits and pushes, and instructions for watching the build and the deployed result. I'm consolidating that work in my [ai-plugins repository](https://github.com/jwilger/ai-plugins). Those checks are what let me trust an agent with long stretches of unattended work. Trust in this sense doesn't mean assuming the agent won't make mistakes. It means I know what evidence it has to produce before it can move on, and which decisions will make it stop and wait for me.

For Lanyard, fake SSH agents exchanged real protocol messages with the program over real Unix sockets. Black-box tests started it, registered agents through its control socket, read its status, sent it termination signals, and checked that its sockets had the right owner and were cleaned up afterwards. Strict Clippy settings turned suspicious shortcuts into build failures, `cargo-deny` checked the dependencies against policy, and mutation testing altered the program deliberately to see whether the tests noticed.

The review passes found bugs that a demonstration wouldn't have shown. A session binding could tie a client to the first agent and prevent it from signing with a key held by another. A dropped connection during signing was at first treated as a reason to stop trying any agent, which contradicted the availability policy in the decision record; the request needed to move on to a different agent without being retried on the same one. A dropped connection during session binding needed the opposite treatment, because repeating that request on another agent could apply it twice. When every agent returned malformed data, the proxy reported an empty list of keys where it should have reported a failure. A merged list of keys could exceed the size limit enforced on each agent's own reply. A failed start of the control socket could leave an orphaned agent socket behind. The first deployment of the documentation site ran before GitHub Pages had been enabled for the repository and failed with a 404.

I wasn't present when most of these were introduced or found. The agent worked through failing tests, mutations the tests hadn't caught, review findings, build failures, and deployment checks without me, and came back when a decision crossed a boundary we'd set or when the evidence couldn't settle a question. Building that distinction into my workflow took time. Without it, an autonomous agent is either reckless, making choices it shouldn't, or exhausting, interrupting so often that I might as well write the code.

## What still needed me

Lanyard handles signing credentials, so the limits on what it will do had to be explicit. It accepts only discovered sockets owned by the same user, creates a private runtime directory and sockets that only their owner can use, rejects requests that would change an agent's keys, bounds the messages it reads and writes, caps the number of agents it will try, and applies a timeout suited to each operation. An acknowledged session binding is kept and replayed when a later request reaches a different agent.

The failure policy needed the same attention, because no single rule fits every operation. Listing keys and answering queries can move from one agent to the next. An explicit refusal to sign can fall through to the next agent, since another one may hold the same key. A dropped connection during signing may move on to a different agent but never resends the request to the same one. A dropped connection during session binding stops there, because repeating that change crosses a different safety boundary.

Release automation produced a decision that the agent couldn't make for me. The shared release workflow I normally use pins its own revision but calls nested actions by tags that can be moved, in jobs that handle publishing credentials. The agent stopped rather than weaken the repository's supply-chain policy to get a passing release. We left publication with credentials switched off until the shared workflow is fixed and repinned. The documentation site could still deploy.

The run exposed holes in my setup as well. The agent at first missed my worktree plugin and changed application code in the main checkout while two other tickets were running in separate working copies. Publishing the documentation site showed that its workflow was stranded on another branch and that Pages hadn't been enabled. A command that closes a task exited successfully once without moving the task to done.

Each failure became a change to the checks. Ticket work has to happen in an isolated working copy, commits and pushes from the main checkout are blocked, a deployment counts only when the deployed address has been checked, and a task counts as closed only when its recorded state says so. This is where the investment compounds, because the next project starts with this one's failures already accounted for.

None of this made me type Rust faster, and for much of the implementation I wasn't typing at all. The annoyance had sat below the line: too small to deserve a real program, too fiddly to solve properly, and not painful enough to take a weekend. My choices had been to tolerate it or to build something I wouldn't have been proud to share.

This time I paid only the part of the cost that needed my judgment: defining the problem, choosing the architecture, deciding how signing failures should behave, and setting the limits for credentials and release automation. The checks carried much of the rest while my attention was elsewhere, and that made decision records, mutation tests, builds for more than one processor architecture, Home Manager integration, and documentation reasonable for a personal utility.

There are many problems like this one in the gaps between general-purpose tools. Most never become software because the engineering costs more than the irritation, and they survive as dotfile snippets, half-remembered commands, and habits built around bugs nobody had time to remove.

Git now signs my commits whether I've attached to a session from the chair at my desk or from a laptop somewhere else, and getting there didn't cost me the rest of the day. I wouldn't have made that trade before I could trust the surrounding system to keep working, catch mistakes, and know when to call me back. An organization's list gets shorter on the same condition. A model that writes code doesn't change what's worth fixing until the people who would have done the work can hand it over and trust what comes back.
