# Impeccable adoption review — 2026-11-20

**Decision: don't publish or activate the current bundle.** The proposed use was design guidance for the site's future redesign. The review did not establish a safe execution path for the bundled engine. No launcher, engine, or agent hook was run during this review.

## What was checked

- The [skill v4.10.0 release](https://github.com/pbakaus/impeccable/releases/tag/v4.10.0) resolves to `b49177d32788f2dc585c42831d845dacf1ebed2c`. Its `universal.zip` SHA-256 is `76c056a775bef9f5ce1a80889b6f961e7d0f9a3e8ef6343789392130d0383148`. The 139 local files matched the release except for the Codex hook paths, which point to the local `.agents` copy. These checks identify the source and bytes, not the safety of the runtime.
- The launchers pin fresh downloads to the [engine v0.1.27 release](https://github.com/pbakaus/impeccable/releases/tag/engine-v0.1.27) and check their hashes. They also run binaries selected from the environment, home directories, or `PATH` without checking those bytes against the release. Some of the engine code is not available for source review. The launchers inherit the agent's environment and default to a cache outside the repository.
- The proposed Copilot hook runs after edits. The Codex hook also runs on stop. Both invoke the launcher automatically after the host approves the hooks. Removing the hooks alone wouldn't make the skill inert: its instructions direct the agent to start the launcher for context.
- Separately, sign-in, critique storage, asset generation, and live editing have their own data and access boundaries. None was authorized by this review.

## When to revisit

For design guidance alone, first consider reviewed documentation that doesn't register a skill or run code. Before adding a runtime, establish the provenance and scope of the exact executable, limit its environment and writable paths, and verify the intended check with a pass and a fail. Automatic execution and any account or service access need separate consideration.
