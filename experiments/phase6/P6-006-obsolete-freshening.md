# P6-006 — Remove superseded freshening helpers

Registered 2026-09-23T05:16:38.874216+00:00, before source edits. Owner root; independent review before
integration. Baseline a6459af, current selected API e2b5463678a2….

Hypothesis: old recursive freshening families have no callers outside their own
obsolete groups. Delete their definitions, laws and exclusive FFreshTerms type.
Retain f_fresh_term, f_rename_var, f_fresh_defs, f_fresh_result and its result
helper. Active entry points already dispatch to explicit-stack workers.

Scan production modules plus tracked maintained tools/tests for references,
including strings and dynamic-root declarations. Preserve deleted blocks and
audit scope. Historical experiment scripts remain historical. Stop on a required
root/caller. The documented f_load_origins and f_load_origins_for APIs remain;
a later delegation to actual load traces needs its own compatibility gate.

Use an isolated project, genuine checked/equality workflow, CPU0, 4 GiB heap,
4 MiB stack and 300-second outer cap. Require unchanged selected API bytes and
public export roots plus all 21 maintained paired acceptance/phase controls.
The all-definition compiler-library roots intentionally shrink with source;
that is separate from selected bootstrap API equivalence. Unexpected byte
changes require investigation. A later combined source receives full frontend
and checked fixed-point gates. No speed gain follows from line deletion alone.
Two setup failures before source mutation/compiler launch are retained in the
attempt directory: wrong cwd and an invalid orchestration expression.
