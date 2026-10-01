# Phase39 countdown experiment

Status: saved-output and actual-source controls passed; minimal compiler change
included in the checked Phase39 `checked01` build. Five-round target measurements
confirm gains; full campaign acceptance remains pending. Root ran every execution;
the owner inspected code and authored the design, tools and reserved helpers.

The [design](../../design/phase39/countdown.md) freezes the mechanism and controls;
[P39-001](../../experiments/phase39/P39-001-countdown.md) tracks its decision.
Source inspection finds two BigInt private loops in the installed numeric module.
Existing vector countdown admission can be reused, but scalar emission also
needs coordinated changes in two `worker.bend` helpers if the ablation wins.

## Evidence acquired so far

`selfhost/build/phase39/countdown-derived01/derive.json` binds the installed
numeric parent `a2ffdcd6…` to unchanged, nested-only and both-loop prototypes.
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
one baseline 256 sample and −10.22% in a candidate 1,024 sample. Deeper confirmation
and actual emitted-code measurements remain necessary. The denominator is the
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
compiler correctness failure. Root will use a new cohort directory for the
authorized retry. Read-only inspection already confirms that actual candidate
`p39.count`/`p39.keep` loops use Number and `p39.escape`/`p39.observe` retain
BigInt; that static evidence does not replace the awaited control execution.

## Actual source controls and paired confirmation

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

Awaited gates: broad regression coverage and aggregate compiler-cost checks.
No universal speedup,
Nat representation change or installed-release promotion is claimed here.

## Proposed root commands

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
