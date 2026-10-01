# Phase39 countdown experiment

Status: accepted in installed and verified Phase39 checked05. Final five-round
comparisons improve numeric 256/1,024 by 1.068×/1.221× and scalar 8,192 by 1.203×
against Phase37; actual controls and selected-image owner closure pass. Root ran
every execution; the owner inspected evidence and authored the reserved helpers.

The [design](../../design/phase39/countdown.md) freezes the mechanism and controls;
[P39-001](../../experiments/phase39/P39-001-countdown.md) tracks its decision.
Initial source inspection found two BigInt private loops in the Phase37 numeric
module. The accepted implementation reuses vector countdown admission and
coordinates scalar emission in two existing `worker.bend` helpers.

## Development ablation and screen

`selfhost/build/phase39/countdown-derived01/derive.json` binds the installed
numeric parent `a 2ffdcd6…` to unchanged, nested-only and both-loop prototypes.
Generic fallback, guards, floating operations and native casts remain unchanged.
`countdown-controls01/report.json` passes **50 independent numeric oracles,
18 nonzero/zero admission checks, 32 capped boundary cases and 56 public/host
boundaries**. Root reports 0.202 seconds and 59 MiB peak RSS for these controls.
The high Nat tests cap diagnostic execution at three bodies; no `2^48` countdown
was run. These are saved-output witnesses, not compiler-admission evidence.

The first maintained-harness screen used the 20-second preset, two points and
three paired rounds; actual wall time was 7.42 seconds. All six candidate round
medians improved and the ranges were disjoint:

| Numeric point | Installed median [range], ms | Both-loop median [range], ms | Installed / candidate | Candidate / TS |
|---|---:|---:|---:|---:|
| 256 | 0.0173404 [0.0173268–0.0181824] | 0.0158780 [0.0158316–0.0158833] | 1.092× | 7.875× |
| 1,024 | 0.0286937 [0.0284149–0.0294915] | 0.0249844 [0.0249701–0.0250568] | 1.148× | 3.238× |

Evidence: `selfhost/build/phase39/countdown-screen01/report.{json,md}`. This is
an early screen, not a steady-state claim: half-sample drift reaches −12.58% in
one baseline 256 sample and −10.22% in a candidate 1,024 sample. The final measurements below supersede this development screen; it alone
did not establish acceptance. The denominator is the
installed Phase37 compiler's programs; these ratios do not include previous wins.

## Minimal source implementation

Only the existing `j_region_number_counter`, `j_nat_loop_body` and
`j_nat_loop_emit` helpers changed. The proof no longer requires an array-vector
parameter. It still requires exactly one predecessor use, solely in the first
argument of a saturated self-tail call; its use scan includes annotations and
captures. The shape and tail tests use staged `kc`, avoiding Bend's eager `&&`
evaluation. The emitted scalar private loop converts once at entry, tests
Number zero and subtracts Number one. Public Nat input/result values and all
entry/dependency/host guards stay unchanged; no new runtime helper is introduced.

The existing nested-helper initializer already converts an admitted counter.
The common scalar loop body therefore repeats an idempotent captured-Number
conversion at that private entry. It cannot invoke a replaced global Number;
its constant entry cost must be included in production timing. The saved-output
nested prototype has one conversion, so it is not byte-identical to this emitter.

Root's `checked01` build passed in 40.57 seconds at approximately 1.13 GiB RSS.
The derived API SHA is
`963caaea0005026a88f2aeadd0aec0b875bd457d968a69b9b1b6150370c2e298`;
the runtime is unchanged (`51bb6046…`). This establishes checked compiler
construction, not final optimization acceptance. The new source fixture has
eligible U32 and Nat-result loops and declined escaping/observed predecessors.
`countdown-acquire.py` binds baseline/candidate/TS checked receipts to identical
fixture bytes; `countdown-compiled-controls.mjs` instruments actual emitted loops
without introducing private scopes or bypassing public entry.

First actual fixture acquisition, `countdown-cohort01`, preserved successful
checked baseline and candidate emissions. TypeScript acquisition then failed
with sandbox `spawnSync git EPERM` while verifying its upstream checkout. This
was an environmental acquisition failure, not a rejected Bend fixture or a
compiler correctness failure. The successful new-directory retry is recorded
below. Static inspection already showed actual candidate `p39.count`/`p39.keep`
Number loops and `p39.escape`/`p39.observe` BigInt loops; subsequent controls,
rather than that inspection alone, established the observed behavior.

## Actual source controls and development confirmation

The clean `countdown-cohort02` retry acquired all three compilers successfully.
Actual controls v1 then preserved a **test expectation error** after 36 U32
oracles: pinned TypeScript's public Nat wrappers return BigInt, but the test
expected an internal Number. Inspection of its emitted `nat_host` input and
`BigInt(run_loop(...))` result wrappers established the mistake. V2 preserves
all baseline/candidate assertions and expects the same public BigInt from all
three compilers. Both failed and successful attempts remain available.

`countdown-actual-controls02/report.json` passes **66 independent value oracles,
12 actual emitted-loop admission/refusal checks and 25 public boundaries** in
0.705 seconds. The diagnostic only adds counters at existing private loops;
admitted source successors visibly use Number, escaping/observed predecessors
retain BigInt, and high Nat accumulator/results remain BigInt. No new proof
scope, private-entry bypass or huge trip count is added by these controls.

`checked01-screen01/report.json` completed five points, five paired rounds each,
under the 300-second preset in 91.33 seconds. The countdown-related points are:

| Point | Installed median [range], ms | Checked01 median [range], ms | Installed / candidate | Candidate / TS |
|---|---:|---:|---:|---:|
| Numeric 256 | 0.0168623 [0.0164521–0.0171809] | 0.0156906 [0.0150155–0.0158798] | 1.075× | 7.518× |
| Numeric 1,024 | 0.0272170 [0.0270262–0.0275095] | 0.0222685 [0.0219871–0.0224970] | 1.222× | 2.866× |
| Scalar region 8,192 | 0.142613 [0.142184–0.142968] | 0.113024 [0.112187–0.113749] | 1.262× | 1.137× |

All three ranges are disjoint. Numeric 1,024 and scalar 8,192 have absolute
within-sample half drift below 2% in both selfhost roles; numeric 256 remains
more variable (candidate reaches +7.12%, baseline +6.34%). This is actual checked
compiler output, including the duplicate constant entry conversion. Checked01
also includes the separately documented guard-scope patch, so these are aggregate
candidate measurements; the earlier isolated countdown ablation supplies causal
evidence. Static inspection of scalar 8,192 finds five new Number conversions
and no `regionProofOpen($guards)` scope in either version.

Separate `checked01-diagnostics01` completed all 12 CPU/allocation profiles in
16.724 seconds. For numeric 1,024, sampled allocation fell from approximately
51,967 to 10,696 bytes per invocation (79.4% lower). The largest baseline sampled
allocator was `p37.numeric` (79.0%); the candidate's largest was
`getOwnPropertyDescriptor` (62.6%). This supports removing repeated BigInt work
and identifies guard allocation as a remaining cost. Candidate `p37.numeric`
still accounts for 38.5% sampled self CPU. These are separate instrumented
observations, not throughput ratios or a prediction that removing a percentage
of samples will yield the same percentage speedup. Sampled allocation measures
allocation during the window, not retained heap or exact object counts.

Final-candidate semantic rerun: `countdown-cohort03` acquires all three checked
fixture emissions with the selected checked05 API
`04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`.
`countdown-final-controls01` again passes all 66 value oracles, 12 live
admission/refusal rows and 25 public boundaries using unchanged controls v2.
This carries the countdown result through the later tree/unary integration;
its final timing is recorded in the aggregate release comparison below.

## Final selected-image outcome

The completed [45-point execution comparison](execution/report.md) uses the
frozen checked05 output, Phase37 and TypeScript in the same runs. Final medians
[ranges] are milliseconds per export; each row has five paired rounds:

| Point | Phase37 | Final Phase39 | Phase37 / Phase39 | Phase39 / TS |
|---|---:|---:|---:|---:|
| Numeric 256 | 0.016784 [0.016421–0.017096] | 0.015716 [0.015091–0.016151] | 1.068× | 7.517× |
| Numeric 1,024 | 0.027083 [0.027054–0.030594] | 0.022181 [0.022065–0.024737] | 1.221× | 2.794× |
| Scalar 8,192 | 0.141353 [0.140659–0.156815] | 0.117468 [0.116119–0.128806] | 1.203× | 1.174× |

All three observed ranges are disjoint. Numeric 1,024 selfhost half drift stays
within 2%; numeric 256 reaches +6.75% and scalar 8,192 about ±7.54% in candidate samples.
These are final aggregate source-candidate results; the isolated development
ablation supplies the specific countdown mechanism evidence.

The final [profile comparison](profile-findings.md) confirms numeric 1,024 sampled
allocation falls 51,632→10,749 bytes/call (−79.18%). Its remaining allocation is
mostly descriptor/name/scalar-guard work; the profile does not justify removing
checks across public calls. [Compiler cost](compiler-cost.md) passes 27 fresh
checked emissions with exact frozen-byte agreement. Numeric source request
medians are 1,344.882→1,322.234 ms (−1.68%, overlapping ranges). Aggregate tree
compilation costs 3.50% more; neither result attributes compiler cost to countdown alone.

The [new-owner closure](new-owner-gates.md) passes all four checked05 groups,
including the final 66/12/25 countdown observations. The inherited Phase35 counter
fixture initially failed its old assertion that the scalar loop must stay BigInt,
after all 35 independent input oracles passed. The explicit Phase39 successor now
requires that eligible scalar Number loop while preserving observable/stored/
aliased predecessor refusals and all five live mutation boundaries. Its successful
bounded execution and exact consumed tool bytes are bound by
`counter-owner-rebind-v2.py`; `counter-owner-rebind01/owner-report.json` closes
all 15 inherited owner groups without editing the original plan or failure.

Checked05 is installed and its release verification passes. The unchanged CLI
smoke retry passes 42/42 after the first attempt's environment-only `clang EPERM`
failure, which is retained. See the [integration report](integration.md) and
[campaign report](README.md) for the complete release ledger and final audit.
Public Nat representation remains BigInt; these gains apply to the proven
private countdowns and do not claim a universal program speedup.

## Development experiment command recipes

The module arguments may be restored Phase39 portable-baseline files with the
same bytes. The deriver requires the exact Phase37 SHA, and records both parent
identities. Every output directory below must be new. These are command recipes,
not a record that they ran.

```sh
PHASE39_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 30 \
  --rss-mib 2048 --available-mib 2048 selfhost/build/phase39/countdown-derive-outer01 \
  -- taskset -c 3 "$PHASE39_NODE" --max-old-space-size=1024 \
  selfhost/tools/performance/phase39/countdown-derive.mjs \
  selfhost/build/phase37/candidate02/modules/numeric-recurrence.mjs \
  selfhost/build/phase37/typescript01/modules/numeric-recurrence.mjs \
  selfhost/tools/performance/phase37/catalog.json \
  selfhost/build/phase39/countdown-derived01
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 30 \
  --rss-mib 2048 --available-mib 2048 selfhost/build/phase39/countdown-controls-outer01 \
  -- taskset -c 3 "$PHASE39_NODE" --max-old-space-size=1024 \
  selfhost/tools/performance/phase39/countdown-controls.mjs \
  selfhost/build/phase39/countdown-derived01 selfhost/build/phase39/countdown-controls01
python3 selfhost/tools/performance/phase35/compare.py \
  selfhost/build/phase39/countdown-derived01/compare.json \
  selfhost/build/phase39/countdown-screen01 --node "$PHASE39_NODE" --cpu 3 --budget 60
```

The comparator owns its execution guard; do not nest it in the outer supervisor.
It uses a stricter 1.5GiB process-tree ceiling, 2GiB available-memory floor and
1GiB Node heap. Clean timing has original/nested/both/TypeScript roles at the two
frozen numeric points. Diagnostic modules are excluded from that configuration.
