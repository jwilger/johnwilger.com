+++
title = "Coding Harness Plugins Are Agentic Systems"
description = "A concrete look at why AI coding-assistant plugins need behavior evals, ablation, scope guards, and carefully-labeled release evidence."
slug = "coding-harness-plugins-are-agentic-systems"
date = 2026-07-04

[extra]
cover = "/images/blog/coding-harness-plugins-agentic-systems.png"

[taxonomies]
tags = ["ai", "llm", "software-engineering", "evals", "plugins"]
+++

I didn't set out to build an eval system for my coding-assistant plugins. I started with the more ordinary problem: my Codex and Claude Code setup had turned into a small pile of instructions that I depended on every day.

There was a worktree plugin because I kept wanting feature work isolated from the main checkout. There was a PR babysitting plugin because "watch this until it merges" means more than looking at CI once. There were engineering standards because I want the agent to follow the same rules I'd expect from a human teammate: don't force-push without explicit authorization, don't treat a green-looking demo as production evidence, don't quietly change the wrong part of the system to make the task easier.

The collection now lives in [`ai-plugins`](https://github.com/jwilger/ai-plugins), a small marketplace targeting both Codex and Claude Code. Calling it a "marketplace" makes it sound more general than it really is. In practice, it's an operational memory of how I want coding agents to behave when they're working in my repositories.

Once I started using it that way, reviewing the Markdown stopped answering the question I cared about. A skill file can sound perfectly reasonable and still have no effect. Worse, it can have the wrong effect: trigger too broadly, steer one harness well and another poorly, or encourage the assistant to perform the language of diligence without doing the work.

That was the point where Markdown review stopped being enough. The repo was part of my development loop now, so I needed evidence about what it actually changed.

## The harness isn't outside the system

It's tempting to treat a coding harness as the shell around the "real" AI product. I don't buy that framing.

A coding harness has tools, memory, prompts, permission rules, runtime state, and a user goal. It reads ambiguous instructions, chooses which guidance applies, edits files, runs commands, watches GitHub, asks for approval when a command crosses a boundary, and reports back with a story about what happened.

That gives the harness the shape of an agentic system. Producing a patch instead of a customer-support reply doesn't make the system simpler. It makes the consequences more immediate.

The failure modes are familiar:

- The agent ignores a rule because the surrounding prompt is more salient.
- The agent applies a rule in a context where it should have recognized a boundary.
- The agent chooses the right words but performs the wrong workflow.
- The plugin appears valuable because the base model already handled the case.
- A safety rule works in the friendly prompt and fails when the user asks for the unsafe thing directly.

I'd test those same problems in a customer-facing agent. I shouldn't lower the standard because the customer is me and the product is my coding setup.

## Behavior, not vocabulary

The easiest bad eval for a prompt or skill checks whether the output says the expected words.

A vocabulary check catches a thin layer of failure and misses the workflow. I don't care whether the assistant says "worktree." I care whether it checks whether it's already in a linked worktree, avoids nesting one, uses the repo's ignored `.worktrees/` directory, and runs baseline setup before changing files.

I don't care whether it says "I'll watch CI." I care whether it keeps monitoring the PR, notices review comments, distinguishes a failing check from a pending one, implements or coordinates fixes, and merges only after the required gates are actually satisfied.

I don't care whether it praises engineering discipline. I care whether it refuses an unauthorized `git push --force-with-lease` even when the user asks for that exact command.

The behavior fixtures in `ai-plugins` are written around that distinction. As of July 4, 2026, the suite has 11 scenarios covering 9 marketplace skills. Each scenario records the plugin and skill surfaces it exercises, the coverage categories it's meant to satisfy, the pass-rate threshold, and whether the case is safety-critical.

A simplified case looks like this:

```json
{
  "case_id": "force-push-refusal",
  "plugins": ["engineering-standards"],
  "skills": ["engineering-standards"],
  "coverage": {
    "kinds": [
      "natural-trigger",
      "scope-boundary",
      "core-behavior",
      "adversarial-safety",
      "baseline-ablation"
    ]
  },
  "valueGate": { "mode": "safety-critical", "baselineLiftThreshold": 0 },
  "minPassRate": 1
}
```

The semantic rubric judges the workflow. Hard assertions cover the boundaries I can express deterministically. For the force-push case, a JavaScript guard looks for execution intent around forced remote pushes and fails the run before the model-graded rubric gets a chance to be charmed by a plausible explanation. The eval-case reporter has a similar guard for raw private transcripts and API tokens.

I don't want a judge to give partial credit to "I will file the issue with the raw transcript, but I'll be careful." That output is a product failure.

## Coverage as a repo invariant

The coverage checker is intentionally boring. It walks the Claude and Codex marketplace manifests, finds every skill under `plugins/**/skills/*/SKILL.md`, and checks whether the behavior fixtures cover the categories the repo requires:

- natural trigger
- scope boundary
- core behavior
- adversarial or safety behavior
- baseline or ablation coverage

If a skill has an explicit decision such as `deferred` or `pruned`, the checker accepts that as a recorded choice. Otherwise, missing coverage fails the gate.

The checker gives the repo a memory that I don't want to keep in my head. Adding a new skill shouldn't rely on me remembering to add a trigger case, a scope-boundary case, an adversarial case, and an ablation lane. The manifest and fixture set are close enough to structured data that the repo can enforce the rule itself.

This is where I keep the claim narrow. Coverage isn't quality. A bad fixture can satisfy a category. A broad skill can still hide three sub-behaviors behind one friendly prompt. A model can pass a narrow case and fail the real-world version next week.

The checker is a one-way brake against silent backsliding. It doesn't certify that the plugin is good.

## Ablation, with an asterisk

The useful question isn't "does the full marketplace pass?" It's "what did the marketplace change?"

If Codex or Claude Code already handles a scenario without my plugin, a passing result with the plugin installed tells me very little. If the plugin improves one harness and harms another, a blended score hides the decision I actually need to make.

The eval matrix therefore includes three plugin modes:

| Mode | What it's for |
| --- | --- |
| `no-plugins` | Baseline behavior with no marketplace installed. |
| `targeted-plugins` | A reporting lane for the plugin surfaces mapped by the case. |
| `full-marketplace` | The real installed marketplace. |

The dashboard compares full-marketplace behavior against the no-plugin baseline and records the value-gate result. Standard cases look for lift over baseline. Safety-critical cases care about the correct refusal behavior, not a marginal average improvement.

I should be precise about targeted mode because this is exactly where eval writeups get slippery. It isn't yet the clean isolation I ultimately want. Current harnesses don't appear to support per-test dynamic plugin installation inside a single provider run, so the repo represents targeted mode as provider/config metadata plus per-case target mapping. Useful for reporting, but not proof that only one plugin was loaded for a given case.

The report I'm comfortable defending today is narrower: the repo can compare no-plugin and full-marketplace behavior, attribute cases to plugin and skill surfaces, and leave a path for targeted isolation when the harness support catches up. Anything stronger would be pretending the measurement is cleaner than it really is.

## Don't let the loop move its own goalposts

After the first eval pass, I wanted an "improve the plugins" loop.

A loop like that can start lying to itself quickly. If it can edit both the plugin and the eval, it can make the score go up by weakening the measurement. If the eval-improvement loop can edit the plugin, it can accidentally change the product while claiming to improve the test harness.

The repo handles this with blunt scope guards:

| Command | Allowed to touch |
| --- | --- |
| `just evals` | Ignored eval artifacts from a provider-backed run. |
| `just improve-plugins` | Plugin instruction assets: skill Markdown, references, plugin READMEs, and plugin manifests. |
| `just improve-evals` | Fixtures, rubrics, hard guards, matrix config, reporting, tests, CI, and eval runner code. |

The two improvement commands aren't autonomous optimizers. They inspect the current git diff, run the coverage checker, dry-run the generated eval config, and fail if the diff crosses the lane boundary.

It looks like routine engineering hygiene. In this system, it protects the part most likely to be gamed: the definition of success.

## CI labels matter

Pull-request CI in `ai-plugins` doesn't run the live provider-backed suite. I left that out on purpose.

The live matrix costs money, needs credentials, and exercises Codex and Claude Code as live harnesses. I want those runs for release evidence and for real decisions about plugin behavior. I don't want untrusted PRs spending provider budget or depending on secrets just because someone changed a fixture.

So PR CI proves deterministic things:

- marketplace manifests are valid and synchronized
- Bats tests pass
- behavior fixtures load recursively and have unique IDs
- hard guards behave the way the tests expect
- coverage requirements are met
- Promptfoo config generation works in dry-run mode

The trusted workflows can run the provider-backed Claude Code and Codex evals when `OPENAI_API_KEY` and `ANTHROPIC_API_KEY` are available. If those secrets are missing, the Pages dashboard publishes a skipped-status report instead of an empty green report.

Teams routinely blur this distinction. A dry-run config check isn't behavior evidence. A schema-valid fixture isn't a meaningful fixture. A passing coverage check isn't proof of value. I want the artifact label to say exactly what happened because the report will be read later, probably by me, when I no longer remember the context.

## Some implementation scars

The useful parts of this work came from the places where the first version was wrong.

At one point the eval lane looked like it worked, but it was closer to a static policy check than a real provider-backed harness run. I couldn't defend that as behavior evidence. The runner now generates Promptfoo config for the native coding-agent providers: `anthropic:claude-agent-sdk` for Claude Code and `openai:codex-sdk` for Codex.

I also tried too hard to preserve the repo's old "Nix plus scripts, no root npm project" shape. Promptfoo's provider packages made that awkward. The current repo has a committed `package.json` and `package-lock.json` with pinned `promptfoo`, Codex SDK, and Claude Agent SDK dependencies. `node_modules/` stays ignored and the runner restores it with `npm ci` when needed.

Provider choice, pinned dependencies, and artifact ownership aren't side quests. They're the difference between a blog-post architecture and a runnable eval harness. The provider has to be real. The dependencies have to be pinned. The artifacts have to be repo-owned. The report has to say when a provider is unavailable instead of counting an auth or quota problem as a behavior failure.

If I'm going to use the evals to decide whether a plugin improved, shortened, split, or removed, the machinery can't be vague.

## What I'm not claiming

I wouldn't call this a benchmark.

Eleven scenarios is enough to start a regression loop. It's not enough to declare the marketplace broadly correct. A provider-backed run that passes those cases gives evidence about those cases, under those provider variants, with those rubrics. It doesn't prove that the next real coding task will go well.

Model-graded rubrics aren't neutral just because they're automated. They can reward the right vocabulary, miss an operational failure, or vary across runs. Hard guards help where the invariant is expressible as code, but much of the system still depends on semantic judgment. That means the fixture set has to grow from real misses, the calibration examples have to be reviewed, and repeated samples need a stated purpose rather than becoming a ritual.

Ablation can also be misleading. If the case is too easy, baseline and full-marketplace both pass. If the case is too artificial, both fail. If the rubric rewards a performance of diligence rather than the workflow I wanted, the plugin can appear valuable while teaching the wrong lesson.

None of those limitations are a reason to skip evals. They're a reason to keep the claims narrow.

## What I'd keep

I don't think this pattern belongs only in my plugin repo.

Any time you put durable instructions in front of a coding agent, you're changing an agentic system. A rules file, a skill, a plugin manifest, a subagent prompt, a custom command, a tool allowlist: all of these are product surfaces. They route behavior. They deserve the same skepticism we apply to code.

Don't stop at "the instruction sounds right." Ask what behavior would change if the instruction were loaded, what bad behavior would count as a hard failure, whether the base model already handles the scenario, whether one provider regresses while another improves, and what part of the report would make that visible.

The standard I want for `ai-plugins` isn't a perfect score. I don't trust perfect scores. I want a maintenance loop where new instructions bring new fixtures, surprising failures become regression cases, and claims about value have to survive comparison with a baseline.

I'd rather defend that standard than defend the claim that "the prompt looks good."
