# P52-003: ordered intrinsic expansion for computed arguments

Status: rejected after the precommitted candidate07 screen. All eight emissions,
smoke cases and72 timing samples passed their exact oracles, but07 was about26%
slower than06 geometrically, with four regressions above10%. The parent selected
06 for the final full-corpus run; no07 semantic or full-corpus run is credited.

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


## Frozen screen method

The versioned [reference remapper](../../selfhost/tools/performance/phase52/direct-reference-v2.py)
keeps exact direct06 and TypeScript module bytes and labels the former baseline.
The [comparison controller](../../selfhost/tools/performance/phase52/compare-ordered.py)
pins that06 API, the unchanged direct runtime and original eight-point catalog;
it invokes the unchanged benchmark runner. Its receipt records the precommitted
1.05× geometric gain and1.10× maximum slowdown thresholds. `passed` in that
receipt means all measurement/oracle checks passed, not that the performance
selection threshold was achieved.

The fresh outputs are `ordered-reference06`, `prepared-direct07-ordered`,
`smoke-direct07-ordered` and `screen-direct07-ordered`, all under
`selfhost/build/phase52/`. The original P52-002 tools/reports are preserved.
Executable parent controllers remain unpinned and acquire the shared CPU3 lock;
Node heap1GiB, tree RSS2GiB and available-memory floor4GiB remain unchanged.


## Measured outcome: reject07

The unchanged60-profile screen completed72/72 fresh samples in58.523452s.
Equal-point geometric means are06/TS **1.225034×**,07/TS **1.540438×**,
and06/07 **0.795250×**:07 is about25.75% slower overall. Both precommitted
conditions fail: there is no1.05× gain and four points regress more than10%.

| Point | TS µs | Direct06 µs | Direct07 µs | 06/07 speedup | 07/06 slowdown |
| --- | ---: | ---: | ---: | ---: | ---: |
| Mandelbrot | 47.583202 | 80.907050 | 288.680742 | 0.280265× | 3.568054× |
| Local pair | 1242.778139 | 1626.034301 | 2039.680055 | 0.797201× | 1.254389× |
| Edit distance | 5053.273710 | 6534.295826 | 8168.843947 | 0.799905× | 1.250149× |
| Active ray64 | 303.669796 | 468.490131 | 523.858745 | 0.894306× | 1.118185× |
| Local fold8192 | 124.133750 | 136.855631 | 132.387413 | 1.033751× | 0.967351× |
| Morning | 3.145801 | 2.906107 | 2.972915 | 0.977528× | 1.022989× |
| Expression128 | 9.282464 | 9.719153 | 9.420733 | 1.031677× | 0.969296× |
| Closures64 | 5.693870 | 6.102120 | 6.356223 | 0.960023× | 1.041642× |

All roles retain identical inputs and exact output checks. No point was dropped
or replaced. No sample exceeds20% absolute half drift or1.2 fresh-round spread;
this does not prove complete JIT convergence. The largest regressions are much
larger than the observed round variation. Parameter IIFEs are a poor lowering
choice for these measurements. Inlining thresholds, closure handling or other
V8 behavior could explain why, but this experiment does not establish which
engine mechanism caused the slowdown.

The checked07 build used58.8924s and peaked at1,474,510,848 tree-RSS bytes.
Eight acquisitions used45.394078 summed child-wall seconds and peaked at
581,152,768 bytes. The limits stayed unchanged. The actual acquisition API is
`5defe4152b4f5d37cd830e502c74c4a6d9fed15aa685b79b40478139505b36e6`,
source SHA256
`36ec3fb6d80bd4e5fa0203017d51c834885fe1636f7cdb1d65a88f32ae2f317d`.
The direct runtime is byte-identical to06. The separate checked-bootstrap API
inside the attempt is not substituted for the acquisition API identity.

All failed-performance evidence is retained under `selfhost/build/phase52/`:

- `ordered-reference06/manifest.json`:
  `ce26b2a45a74ee843443db59f4a0af798f9e60fe5744d3f0ccae4c930d94358f`.
- `prepared-direct07-ordered/manifest.json`:
  `fe5a941e108295475808ccd7a641562bc79ad844453260410aef4146bab60e4c`.
- `smoke-direct07-ordered/report.json`:
  `8bb08c7ba277cccd1cb143d6199495031ef8ac3fc4257f803cd82134d0fccb17`.
- `screen-direct07-ordered/report.json`:
  `88acd5d687389b8cd62400eb3e4dcf75a8cf124f691b1e00b02a0544a6f4665e`.
- `screen-direct07-ordered/phase52-comparison.json`:
  `bae3579c91a03d557c88beb6dd8bb8d604e04e4ce35584f61897b8b3f7bc995a`.

The comparison receipt's method `passed:true` is correct: measurement and output
checks completed. It is deliberately distinct from the **failed performance
acceptance decision** above. Root rejected07 before spending another full-corpus
or semantic campaign on it. The source patch and frozen checked07 remain
available for review; they are not the selected compiler.
