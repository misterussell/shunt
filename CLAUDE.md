# CLAUDE.md

@AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Singleton is an anti-pattern in Elixir. Functional always.

All content generation must follow:

## Code Rules

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity first

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Spec/Plan Workflow

In this project, after superpowers:brainstorming reaches an agreed design, do NOT write a
design doc to docs/superpowers/specs, and do NOT invoke superpowers:writing-plans. Instead
use the project skill `todo-staging` to stage the design as inline TODOs and implement them.

## Branching

Before committing, check the current branch with `git branch --show-current`. If it is
`main` or `master`, create and switch to a new feature branch first - never commit feature
work directly to `main`/`master`.

## Content

All content generation must follow:

- docs/SHUNT_CONTENT_CONSTITUTION.md
- docs/SHUNT_TERMINOLOGY.md
- docs/SHUNT_STYLE_GUIDE.md
- docs/SHUNT_NAMING_PATTERNS.md
- docs/SHUNT_LEXICON.md
- docs/SHUNT_STORY_CANON.md

When building a new district or location, start from docs/SHUNT_DISTRICT_AUTHORING.md — the
playbook for content structure, the requirements/effects DSL, District Evolution facts, Web-v1
conditional reveals, integrity constraints, and the build/verify workflow. Before building a new
*area*, read docs/SHUNT_STORY_CANON.md — the cross-district story bible and the forward hooks
(e.g. the Spire's continuity contract) that new content must not contradict; update it when your
area reveals something the next one must know.