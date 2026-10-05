# P52-003: ordered intrinsic expansion for computed arguments

Status: design before candidate07 execution. The parent authorized this bounded
follow-up after [P52-002](P52-002-atomic-intrinsics.md) measured a 1.074256×
eight-point geometric speedup, below its 1.10× target. No result is claimed for
this experiment yet.

## Hypothesis and scope

Atomic expansion leaves six native wrapper calls inside candidate06 `mit`, one
inside `asr8`, six inside `isect5`, and 63 inside the active-ray `trace` body.
The pinned TypeScript output emits the operations directly after ordered local
bindings. These are static sites, not executed-call counts. The wrapper/inlining
explanation is a hypothesis; V8 may already remove them.

The next candidate keeps the exact atom fast path and expands other admitted
native calls with a local parameter IIFE:

```js
(($a0, $a1) => TEMPLATE($a0, $a1))(actual0, actual1)
```

The real expression is parenthesized. Existing `jd_intrinsic` supplies the
template only after the same native provenance, telescope and live-arity checks.
Ordinary definitions and unsupported operations keep the old named call. There
is no source/workload selector, constant folding, numeric table, new runtime
operation, or general statement-emitter refactor.

Each original live actual is evaluated once, left-to-right, before evaluating
the template. A repeated template parameter only rereads its private binding;
a conditional template cannot discard evaluation of a supplied actual. In
particular, Math method lookup occurs after actual evaluation. Array updates
keep their original argument evaluation, aliases, read/write order and internal
callback. Erased values remain omitted by the existing argument lowering.

The IIFE appears where the saturated call previously appeared, including inside
eta-expanded closures. It does not move supplied expressions to partial-call
creation. Its parameters are lexical locals; actual expressions are outside
that parameter scope. The original operand `JD_USE`/`JD_REF` comments remain
in the call arguments, while the eliminated native callee has no reference.
Candidate06 already handles terminal native edges in call analysis.

## Falsifiers and measurement

First require the checked build, unchanged-runtime identity, structural evidence
of expansion, and the existing semantic/native controls. Explicitly challenge
eager Bool operands, once-only Nat arguments, a throwing earlier operand,
post-import Math getters, partial application and Array alias/update behavior.
Keep the pre-existing NaN/table failure separate; it cannot excuse a new failure.

Reuse the same eight-point profile and 60-second, three-rotation protocol from
P52-002, with fresh **direct06 / direct07 / pinned TS** roles. Do not chain ratios
from separate runs or replace the known05 result. The intended benefit is at
least 1.05× equal-point speedup over06, with no unexplained point more than10%
slower. The smaller incremental target is set before any07 execution, based on
the already observed06 result. These are engineering selection thresholds, not
significance claims.
Also inspect all four previously slow sources individually.

An IIFE can cost more than a named wrapper or displace useful V8 inlining. If
the clean screen is flat, regresses, or misses the target, retain that outcome
and reconsider before any broader emitter change. A full statement-prefix/value
API and constant numeric tables are separate proposals, not automatic follow-ups.
Only a surviving candidate warrants full-corpus qualification. Parent owns all
builds, acquisitions, execution and timing; source/review work stays separate.

## Source checkpoint

Only `selfhost/src/back/js/direct/core.bend` changes: its non-atomic `jd_call`
branch and one helper using the existing positional parameter generator.
Before/after source hashes and the exact patch will be retained in
`implementation/phase52/proposals/ordered-intrinsics.*`. Independent review is
required before the parent freezes candidate07.
