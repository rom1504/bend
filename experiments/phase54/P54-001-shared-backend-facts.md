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
