# P54-001: separate shared facts from compatibility emission

Hypothesis: direct JS can stop depending on legacy-emitter modules by relocating
unchanged typed queries and shared JS formatting without altering emitted code.
Falsifiers: changed helper bodies, a hidden legacy dependency, changed demand or
numeric rules, changed generated modules, or a bootstrap/native routing failure.

[Design](../../design/phase54/backend-cleanup-and-direct-bootstrap.md).
Owners: helper/routing agents, challenged by architecture and independent review.
Freeze source and record exact moved bodies. Use checked source and small
semantic/native gates, then complete emitted-output comparison. Code movement
is a dependency improvement; it is not reported as a line-count reduction.

## Completed integration

Thirty-four definitions and their laws moved unchanged into three backend-common
query modules and one shared JavaScript text utility. All 62 direct helper-owner
rows now resolve outside legacy emitter/planner modules. Independent static
review confirmed exact names/bodies with no additions or removals. The integrated
manifest retains both direct and compatibility backends; code movement is not
a claimed code-size reduction.

The isolated helper-only checked build passed in 61.607 seconds. Its API hash exactly
matches installed Phase53, and all eight core point modules are byte-identical.
Five redundant EOF blank lines were then removed; the final helper-only physical
line delta is +14 rather than the initial +19. The subsequent whitespace-clean
combined graph02 checked build passes 36 strict frontend witnesses. Its API
changes because of the independent graph transformation, not the helper move.

[Implementation and identities](../../implementation/phase54/shared-helpers.md)
retain the initial inventory and whitespace followup.
[Qualification](../../implementation/phase54/qualification.md) reports the
separate final semantic, native and output-retention scopes, all passing. The helper result does not claim faster runtime,
faster compilation, broader native conformance or a direct self-emitted fixed
point.
