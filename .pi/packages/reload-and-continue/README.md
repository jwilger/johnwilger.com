# Reload and continue

After a resource is saved, an interactive Pi session still has its old tools and instructions until reload. This project-local tool removes the extra user turn that used to be needed to resume the task. It reuses the lifecycle pattern from the user-provided Compass extension (revision `fdd4072`) and Pi 1.6.0's bundled `reload-runtime.ts` example. The extension itself has no install or runtime subprocesses, credential reads, or network calls; Pi reloads the session's configured resources as usual.

## Try it

Open interactive Pi in this trusted checkout. If this session predates the package, run `/reload` once to bootstrap it. For a quick check, ask Pi to call `reload_and_continue` alone with:

```json
{
  "continuation": "Verify that the johnwilger.com reload-and-continue package registered reload_and_continue after reload. Report what you observed."
}
```

For a real change, name the new skill, extension, package, or MCP config and tell Pi how to check it before using it, then say what to do next. The tool stops the current run when called alone; after Pi settles, its normal reload runs and the replacement extension starts a new turn. No second user message is needed. If two calls are made in one run, the first accepted continuation wins.

The **pending** handoff lives in process memory only. Abort before the run settles or send another message that starts before dispatch, and the request is dropped. Reopening a saved session doesn't replay it. As with an ordinary prompt, a continuation that already ran appears in session history. Print, JSON, and RPC sessions can't use this tool. If the package itself doesn't load after reload, Pi reports the problem rather than guessing whether it can continue.

## Verification

On Pi 1.6.0, an isolated terminal session with a loopback-only model fixture picked up a tool saved after startup and made exactly one new request containing the verification instruction and the first of two continuations. Aborting after the tool ran, entering a blank continuation, queuing a new user message, reopening the saved session, and calling from JSON mode did not trigger a handoff. Removing the package before reload displayed an error in the terminal and sent no continuation. Strict TypeScript checking used the installed Pi and TypeBox declarations.

## Revisit

This mechanism covers Pi 1.6.0's interactive lifecycle, not every failure of a resource it reloads. The resumed turn must verify the specific resource. Recheck after Pi upgrades or if any tool fails to stop, repeats a turn, or continues in the wrong context. Remove the package if Pi adds a native reload-and-resume operation with equivalent behavior.
