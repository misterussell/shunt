---
name: todo-staging
description: Use in this project after superpowers:brainstorming reaches an agreed design, instead of writing a design doc or invoking superpowers:writing-plans. Also use when picking up existing `TODO:` stubs in lib/ or test/ to implement the next one.
---

# Todo Staging

## Overview

Stage an agreed design as explicit, scoped `# TODO:` comments directly in the files they
belong to, instead of a separate spec or plan document. The codebase becomes the source of
truth for what's left to do — grep for it instead of cross-referencing docs.

## Staging a Design

1. Insert one `# TODO: <description>` comment per discrete, independently-testable piece of
   work, at the exact file/location it belongs.
   - Self-contained: a reader should know exactly what to do from the comment + surrounding
     code alone — no chat history required.
     - Bad: `TODO: handle errors`
     - Good: `TODO: return {:error, :expired} when offer.expires_at is in the past, mirroring
       Catalog.validate_offer/1`
   - Too big for one comment to describe concretely → split into multiple TODOs.
   - New file needed: create it with its skeleton, TODO inside. Wiring into existing code
     (router, supervision tree, etc.) gets its own TODO at the call site.
2. Self-review every inserted TODO for vagueness or placeholder language ("handle it", "etc",
   "as needed") — fix in place.
3. Show the user the staged set: `grep -rn "TODO:" lib/ test/`
4. Commit the stub insertion on its own (e.g. `git commit -m "Stage TODOs for <feature>"`) so
   the agreed scope is visible in the codebase before implementation starts.

## Implementing Staged TODOs

1. Pick one TODO, or a small logically-grouped few (e.g. all TODOs in one function).
2. **REQUIRED SUB-SKILL:** Use superpowers:test-driven-development to implement it.
3. Remove the TODO comment once resolved.
4. Commit.
5. Repeat until `grep -rn "TODO:" lib/ test/` finds none left for this feature.

## Quick Reference

| Step | Old workflow | This skill |
|---|---|---|
| Capture design | `docs/superpowers/specs/*.md` | `# TODO:` comments in the affected files |
| Break into tasks | `docs/superpowers/plans/*.md` | The TODOs themselves |
| Track progress | checkboxes in plan doc | grep for remaining TODOs |
| Review | user reads doc | user reads `grep` output / diff |

## Common Mistakes

- Vague TODOs ("TODO: fix this") — defeats the purpose; must be as scoped as a plan doc's task.
- Staging and implementing in the same commit — stage first, commit, then implement, so the
  agreed scope is visible on its own.
- Falling back to a plan doc "just this once" — if a TODO can't be made concrete enough to
  stand alone, split it further; don't reach for a doc.
