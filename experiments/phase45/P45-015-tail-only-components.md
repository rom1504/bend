# P45-015: native loops for proved tail-only components

Status: checked worker15 and the existing default-stack composition controls
passed. The incremental two-point timing is effectively flat. Retain provisionally
for simpler generated tail code, pending the combined broad screen and the new
focused exhausted-budget control; no measured speed gain is claimed. No larger native-stack budget and no source-family selector are added.

Worker11 uses the same budget32 for every recursive component, including components
whose recursive calls have already become scalar program-counter loops. Its
records allocation profile contains the U32.show.fin/go explicit machine even
though the native form only tail-transfers between its entries. Entering such a
component while an outer non-tail computation exhausts the budget unnecessarily
selects allocating machine vectors. This is evidence of an opportunity, not an
isolated performance attribution.

## Proof and implementation

The existing exact SCC plan remains mandatory. For every function in a recursive
component, walk every instruction, both case branches, and following instructions.
A direct call to the same component must satisfy **the existing printer predicate**
`jw_tail_result(rest, slot)`: its remaining instruction list is exactly a return of
that call's result slot. Other direct calls are edges in the proved condensation
DAG. Invalid graphs already fail the unchanged graph/lowering admission gates.

When every intra-component edge passes, all recursive transfers use the existing
`jw_native_tail` scalar capture/store/PC update. They do not invoke a JavaScript
function recursively. The component emits its native loop and direct private
wrappers, with no budget decrement, budget check, finally restoration or machine.
An entry still creates its own scalar frame; arguments retain left-to-right
capture before overwritten slots. Mixed/non-tail components retain the exact
budget32 wrapper and continuation-machine spelling. Acyclic components are
unchanged. Root signatures, source/host guards and public fallback are unchanged.

The stack argument is structural: within a qualified SCC, input-proportional
recursion becomes iteration. Moving between SCCs follows a DAG with at most96
functions, so a downstream component cannot return to this SCC through a private
call. Descendant non-tail SCCs still consume the shared non-tail budget and still
enter their iterative fallback at zero. A machine in an ancestor may call the
qualified native loop even when that budget is zero. No private cyclic call path
has escaped the budget unless every edge in that cycle is implemented as a loop.
Public/Error-hook reentry retains the existing separate host-boundary semantics;
this pass does not assert a bound for arbitrary externally recursive callbacks.

The isolated emitter patch adds28 net lines and reuses existing IR/call facts.
No extra source/type analysis or cache is introduced. The source-generation walk
visits selected component code once; the surrounding function-list scans remain
bounded by the existing96-function cap.

## Qualification

- An independent mutually recursive tail-only component with argument permutation
  and long input; require a native marker and no machine for that component.
- The same tail-only component called under a non-tail recursive ancestor deeper
  than32, proving correct execution with the shared budget exhausted.
- One same-component non-tail edge in either case branch must retain the machine
  and original budget, including a recursive result used in later arithmetic.
- A tail-only component calling a downstream non-tail component must retain the
  latter's fallback and bounded deep execution; no source-name recognition.
- Genuine source errors and Error-hook reentry, followed by successful replay;
  descriptor/host mutations and raw/partial/overapplication keep public fallback.
- Existing deep composition controls under the default stack, then clean rotated
  Map/records timing and separate fallback/allocation diagnostics. Counters are
  untimed derivatives. Positive timing is required before promotion.

The frozen patch and emitter derivative were prepared in
`/tmp/phase45-tail-only-scc/`; root copies their identities into the immutable
experiment evidence before execution. The base worker11 emitter SHA-256 is
`9de14070290c956732d8d2fe4d1950a92b8cb9b7efcdb06fc6f2fa5fd600a2fb`.
The patch SHA-256 is
`994eeec55f452993a23740dae3624120c821fe3b2bce36b437ba761b4ba0cfbd`.

## Isolated execution and timing

The checked worker15 API is
`d91341a62bc7b478a3b2de93aaa8155c044b1b06d433ce324b5f39e29badab22`.
The v5 composition controller passed all six default-stack runs in
`selfhost/build/phase45/worker-controls15-*-defaultstack/`:

- Small mode: 135 scalar oracles, five tree observations, 15 activation
  observations, five live helper-mutation boundaries and two diagnostic-fault
  unwinding/reentry observations. Small language results compare Phase44 checked04,
  worker15 and pinned TypeScript; the injected unwinding faults are diagnostics,
  not genuine source-error tests.
- Five deep roots (bench, tail_check, tree_check, scope_check, sibling_check):
  each passes four independent candidate oracles at depths 4096 and 50000 with two
  seeds, plus its separate activation observations. Prior generic/TypeScript deep
  behavior is not included in those candidate-only claims.

The focused fixture that enters a tail-only component beneath an exhausted
non-tail budget is still being qualified separately. The existing deep passes
must not be described as that exact new regression test.

`selfhost/build/phase45/runtime-worker15-vs11/report.json` contains the clean
incremental comparison: two points, three fresh rotated rounds per role,
18 successful samples in 15.188545 seconds under the 60-second preset. Each process
uses 350ms warmup, 40ms calibration and 150ms target sampling. The baseline is
worker11, candidate worker15, with pinned TypeScript measured afresh.

| Point | Worker11 median ms | Worker15 median ms | Fresh TS median ms | 11 / 15 | 15 / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Map128 | 2.299826 | 2.290965 | 0.784139 | 1.003868× | 2.921631× |
| Records256 | 3.164914 | 3.185256 | 1.334116 | 0.993614× | 2.387541× |

This is effectively flat: approximately 0.39% lower Map time and 0.64% higher records
time, neither an established gain/regression. Map process half-drift reaches 20.29%
for baseline and 21.66% for candidate; records reaches 13.21% and 10.71%. The changed
fresh TypeScript denominator does not turn the records result into an incremental
speed improvement. Timing report SHA-256:
`41b8b399f58992c20a27ef7a56702306144520896f33efc66c1b2a7762d1b97f`.

## Generated-code simplification and retention

These are complete emitted module UTF-8 byte counts from actual
`preparation-worker11/modules/` and `preparation-worker15/modules/` artifacts:

| Module | Worker11 bytes | Worker15 bytes | Reduction | Machine declarations | Native component declarations |
| --- | ---: | ---: | ---: | --- | --- |
| map-churn.mjs | 250,013 | 244,849 | 5,164 (2.07%) | 15→9 | 15→15 |
| record-aggregation.mjs | 244,507 | 241,065 | 3,442 (1.41%) | 14→11 | 14→14 |

Worker15 emits seven marked tail-only entry wrappers in Map and five in records;
multiple wrappers can share one component. This removes six and three unneeded
continuation machines respectively, plus budget/finally paths for the proved
loops. Module hashes are `096ceb74ab54fe7fd64d2abef764374e60d751e6806833a2fad913988a59e701`
(Map15) and `db1ba03e50c28d8ea19d9d7d3e4ae5527241697f1b1eef4a6d326aa47f5a3c5f`
(records15).

The retention argument is a small general proof with less generated machinery
and no needless budget charge for iterative recursion. It is **not** that this
screen demonstrated faster execution. Combined worker16 incorporates this pass
with the independently developed alias-frontier and constructor changes; its
broad results must be reported separately and cannot be attributed to P45-015
alone.
