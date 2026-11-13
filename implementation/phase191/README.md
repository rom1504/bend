# Phase191: direct-x86 selection and register placement

Parent `e4cdffa`; campaign began 2026-11-13 18:01:53 UTC. The selected
implementation combines indexed addressing and memory ALU selection, loop-aware
register priority, pure conditional selection, and adjacent frame forwarding.
Across all 44 ratio-eligible native45 cases, final geometric runtime is
0.889567× freshly timed, frozen Phase190 products: an 11.04% reduction. The
36 eligible held-out cases achieve 0.921616× (7.84% less runtime); the eight
development cases achieve 0.758592×. The full-suite ratio to the mature C
backend improves from 3.076292× to 2.736569×, so parity remains unmet. Numeric
recurrence-256 regresses 8.51%, and all 11 dispersion flags remain included.

The frozen candidate emitted all 45 native45 programs and passed their exact
independent outputs in [native45-01](../../selfhost/build/phase191/native45-01/report.json).
The [final runtime summary](runtime-summary.md) covers all 45 cases, including
the correctness-only zero-work case. Compiler qualification and final compiler
timing are separate gates below. Installed selection is not changed by these
observations.

## Candidate and scope

The [selected source](../../selfhost/build/phase191/selected-source01/compiler.bend)
is 1,746,137 bytes, SHA-256
`d9cc1516c1b7d51f2e7f220228ee07477a98f253dbe1cff78652a38782740ce2`.
The QBE-built native compiler used to emit native45 is
[native-image01](../../selfhost/build/phase191/native-image01/report.json),
SHA-256 `dd7f160e13a7c06d305c40d8cac27dd98ff1be207bc27fab976089a585ac3231`.
This producer image is distinct from a qualified self-reproducing direct-x86
compiler. The target runtime remains the pinned Phase190 runtime object,
SHA-256 `67141c4505a0355901d857c4ba81dfc17559329e536818a843ce68615384d13e`.

All compiler algorithms remain Bend. Host scripts authenticate, transport,
execute independent observers, and summarize evidence. The selected source
enables all five switches: address, memory ALU, loop profitability, conditional
selection, and frame forwarding. Call-move and body-alignment experiments are
excluded. No target-name specialization, source-oracle weakening, or increase
in allocator bounds is selected.

| Change | Mechanism and boundary |
|---|---|
| Typed indexed operands | Base + index × scale + displacement, with explicit SIB/REX encoding and existing width rules; invalid shapes refuse. |
| Address/memory selection | Single-use adjacent address/load patterns remove transport before allocation; full-width arithmetic, original memory order, protected parameters/setup, and allocation dependencies remain explicit. |
| Loop priority | Backedge-reaching uses receive additional profitability weight; exit-only values lose their accidental advantage. Actual liveness, interference, call restrictions, and post-color validation remain unchanged. |
| Conditional selection | Matched one-to-four pure copy arms become register CMOV; empty arms disappear. Inputs are snapshotted before writes; no user memory operation or effect is speculated. |
| Frame forwarding | An immediately adjacent equal-width 64-bit load of the same aligned negative RBP slot reuses its stored register. The store remains; every intervening item clears the fact. |

See [correctness boundaries](correctness-boundaries.md), the
[design](../../design/phase191/README.md), and
[experiment record](../../experiments/phase191/selection-and-registers.md).

## Development decisions

The frozen [case partition](../../selfhost/tests/phase191/cases.json) has eight
development and 37 held-out cases. Local-pair/editdist are development cases
here even though previously held out in Phase190. Held-out means withheld from
this campaign's tuning; it does not mean novel algorithms. The reused native45
acquisition helper carries historical Phase190 6/39 partition metadata; its
45 exact-output results are valid, but those labels do not define this campaign.

| Screen | Cases; timed observations | Geometric runtime / Phase190 | Decision |
|---|---:|---:|---|
| Loop priority alone | 8; 200 across all five roles | 0.983592 | Retain in combination. |
| Address/memory alone | Same first screen | 0.877046 | Retain. |
| Address + priority (Both) | Same first screen | 0.856193 | Basis for follow-up. |
| Both + conditional + frame (Extra) | 8; 128 across four roles | 0.757261 | Selected policy. |
| Selected policy repeat in call screen | 8; 128 across four roles | 0.756605 | Consistent development aggregate. |
| Additional call-move prototype | Same call screen | 0.752333 | Reject: about 0.56% improvement over selected policy does not justify added machinery. |

Receipts: [first ablation](../../selfhost/build/phase191/ablation-summary01.md),
[Extra](../../selfhost/build/phase191/extra-summary01.md), and
[call experiment](../../selfhost/build/phase191/call-summary01.md). Ratios use
role medians from the same run; adaptive repetition counts are normalized.
The first screen flags dispersion for local-fold/expression; the call screen
flags ray/Map. All cases remain in the aggregates. Extra has no dispersion flag,
including its 1.08248× numeric-recurrence regression. Its development C ratio is
3.15912× versus baseline 4.17177×; neither replaces Phase190's 44-case 3.083793×.

The three-case [mini ablation](../../selfhost/build/phase191/mini-summary01.md)
separates frame, conditional, their combination, and 16-byte body alignment.
Relative to Both, local-pair is respectively 1.0543×, 0.7016×, 0.6376×,
and 0.6344×; numeric recurrence is 1.0255×, 1.0228×, 1.0787×, and 1.1075×.
Alignment did not repair the regression and was removed. Numeric's inspected
hot recurrence and wrapper have identical normalized instructions in Both and
Extra; only locations/call targets move. This motivates a layout hypothesis,
not a proven cache/front-end explanation or permission to tune one offset.

The call prototype passed six checked controls, both machine routes, and eight
program oracles. Its bounded cycle handling, refusal fallback, fixtures, and
integration patch remain under [tests](../../selfhost/tests/phase191/README.md)
for later work, outside production. Early failed source/API snapshots and an
invalidated mutable-manifest acquisition remain retained. Subsequent API jobs
bind the explicit frozen bootstrap manifest; failed receipts were not relabeled.

## Work removed and remaining

Exact ELF spans and authenticated manifests underpin
[machine-work](../../research/phase191/machine-work.md) and
[extra-machine-work](../../research/phase191/extra-machine-work.md).
For local-pair's positive row iteration, Phase190 → Both → Extra gives
142–147 → 97–102 → 93 instructions, 54–55 → 21–22 → 21 RBP references,
and 15 → 3 → 2 conservative frame store/load transitions. Conditional branches
fall from seven to one in Extra, with three CMOVs and three empty diamonds
removed. Both introduces five indexed accesses. One specific address chain
falls from 20 instructions/116 bytes/12 RBP references to four instructions/
15 bytes/zero RBP references. Exit-only handles move out of the hot register set.

Local-fold falls from 27 to 23 instructions per positive iteration; its frame
reference count was already zero. Extra removes 199 explicit frame loads from
Map insertion (8,149 → 8,078 whole-function instructions), often replacing
loads with register moves. That recursive function is not a single loop;
its borrowed traversal loop remains 60–75 instructions and has no new CMOV.
The C local-pair hot inline loop has 26 instructions, five indexed accesses,
two CMOVs, one conditional branch, and no calls. Remaining Bend transport,
boolean materialization before CMOV, and frame traffic are concrete follow-up
targets. C's RBP-based array accesses are not counted as spills.

The new [frame transition diagnostic](../../selfhost/tests/phase191/frame-transitions.py)
extends the frozen Phase190 audit with exact witnesses, width/alias checks,
join/branch barriers, and conservative invalidation. Five metadata test methods
cover its analysis. These static counts establish machine work and opportunities,
not dynamic frequency, cache misses, instruction latency, or additive speedups.

The [primary-source research](../../research/phase191/backend-research.md)
distinguishes LLVM's rich address selection and frequency-aware allocation,
Rust's usual LLVM backend, and Zig 0.15.1's compile-speed-oriented x86 backend.
It supports this bounded composition of selection and placement. No LLVM/Zig
performance number is transferred to Bend. llvm-mca remains a proposed optional
dependency/resource model; it would not establish cache or store-forward costs.

## Physical profiles

[Profile assessment](../../research/phase191/profile-assessment.md) authenticates
Phase190/Both/C captures for local-pair and Map. These are pre-Extra products,
not selected-candidate profiles. All six pools have 570–616 samples across
8/13 ms periods, no dropped/overrun samples, and over 99.90% window CPU coverage.
Local-pair's inspected loop owns over 98% of baseline/Both sampled PCs. Map is
distributed: insertion owns only 3.5–4.6%; its 199 removed loads cannot explain
a large whole-program gain alone. C's hot pair owner is the inline `NF_FID_pair`
loop, rather than the separately emitted `dp.row` example inspected initially.

The maintained [runtime profile planner](../../selfhost/tools/profiler/plan-runtime.py)
pins manifests, timing receipts, sampler identity, periods, and independently
calibrated per-role repetition counts. Each case-role is a separate workload:
the comparator intentionally emits zero cross-role comparisons. Per-repetition
CPU estimates are descriptive, include startup/warmup, and are not paired
runtime qualification. The generic comparator retains unknown PCs in its
denominator; Map has about 1.8–2.1% unknown weight, so it would fail Phase190's
additional zero-unknown rule. The generic C `WL_FID_*` scheduler grouping is
misleading for generated workers; this assessment uses physical function names.
Three planner metadata tests and the existing manifest-freeze tests passed.

The later [final-product profile](../../research/phase191/final-profile-assessment.md)
uses numeric1024 and Map32 from the exact final benchmark products. All twelve
raw sample analyses and aggregate results recompute exactly; all six pools pass
with 578–614 samples and at least 99.908% whole-child CPU coverage. Numeric's
runtime-op helper owns **35.37%** of candidate samples, with both periods
agreeing broadly. Exact code supplies opcode58 (`f32_to_u32`) on each iteration.
This is a strong next target, not proof that 35% of time is removable. Selected
Map attribution remains distributed and retains 1.843% unknown sample weight.
[Retained assessment](profile-evidence/assessment.json) includes the denominators;
`derive.py.txt` is a verbatim transcript of the frozen offline derivation, not a
new compiler or an independently runnable build entry point.

The planner initially refused numeric256 because the requested sample duration
would exceed its two-million-repetition bound. We used the existing larger
numeric1024 fixture without changing that bound or any benchmark definition.
There was no additional optimization after the held-out measurement.

## Validation and proof boundary

[Source checking](../../selfhost/build/phase191/source-check01/report.json)
accepted the frozen source through unmodified upstream loading/checking with
zero unresolved holes. It is explicitly not a kernel theorem/proof-safety audit.
[Core controls](../../selfhost/build/phase191/controls02/report.json) pass
37 encoding, 13 loop-priority, and 19 selection checks;
[extra controls](../../selfhost/build/phase191/extra-controls01/report.json)
pass 38 CMOV, 21 frame, and 15 conditional checks. Direct ELF and rendered
assembly execute independent C observers; indexed encoding and CMOV additionally
use separately written assembly and literal-byte expectations. These routes
provide finite independent observations, not a whole-compiler equivalence proof.
All 45 exact native45 outputs pass from the frozen native producer. Source
acceptance, structural guards, finite behavior, self-reproduction, and installed
promotion remain distinct claims; two generations can share a compiler bug.

## Broad result and release gates

The final [runtime receipt](../../selfhost/build/phase191/runtime01/report.json)
uses the frozen native45 candidate products, Phase190 native45-02 products, and
mature C references. It contains six position-balanced rounds: 810 timed and
445 pilot observations with revalidated oracles. The authenticated
[JSON summary](runtime-summary.json) verifies 568 input pins and uses the
Phase191 8/37 partition. The copied summaries are byte-for-byte originals;
their historical `phase190-*` schema names identify reused analysis tools.
`scalar-region-0` passes correctness and is excluded from ratio statistics.

| Final subset | Cases / ratio eligible | Candidate / Phase190 | Phase190 / C | Candidate / C |
|---|---:|---:|---:|---:|
| All | 45 / 44 | 0.889567 | 3.076292 | 2.736569 |
| Development | 8 / 8 | 0.758592 | 4.17728 | 3.16885 |
| Held-out | 37 / 36 | 0.921616 | 2.87410 | 2.64882 |

Mean positive log slowdown, `mean(max(0, ln(runtime/reference)))`, against C
falls from 1.246744 to 1.131531. Counts above 1.1× and 2× C remain 40 and 37
of 44: the large gains do not eliminate the broad deficit. Against Phase190,
candidate positive log slowdown is 0.00767941, with no case above 1.1×.
The 22-family diagnostic gives equal-family candidate/Phase190 0.890850;
equal-family baseline/C 3.122250 improves to candidate/C 2.781455. Family
weighting averages geometrically within each family first; it does not replace
the equal-case headline or make these related variants independent algorithms.

At original catalog repetition counts, fixed-equivalent total time is
38,940.15 ms for Phase190, 34,100.17 ms for candidate, and 10,243.93 ms for C:
candidate removes 4,839.98 ms (12.43%) of Phase190 work. Positive fixed-work
excess over C falls from 28,872.79 to 24,032.23 ms; candidate's positive excess
over Phase190 is 225.31 ms. These sums use original catalog repetitions,
never role-specific adaptive calibration counts. See
[family/fixed-work diagnostics](family-summary.json).

All individual candidate regressions against Phase190 are retained:

| Case | Runtime / Phase190 | Dispersion flag |
|---|---:|---|
| coverage-numeric-recurrence-256 | 1.08506 | No |
| symreg | 1.08191 | Yes |
| coverage-list-pipeline-512 | 1.04299 | No |
| coverage-bst-32 | 1.03650 | Yes |
| coverage-numeric-recurrence-1024 | 1.02823 | No |
| coverage-bst-64 | 1.02064 | Yes |
| variation-symreg-4-17 | 1.01851 | No |
| test-rle-roundtrip | 1.01769 | No |
| variation-symreg-7-123 | 1.01000 | No |
| coverage-expression-32 | 1.00374 | No |
| test-evening-program | 1.00176 | No |

The 11 flagged cases are ray-active-64, tree-bitonic, symreg, morning-program,
lexer-10-123, tree-bitonic-9-123, closures-256, bst-32, bst-64,
unicode-text-64, and record-aggregation-256; the exact IDs and every role's
spread appear in the summary. Flags mean some role exceeds the 1.1 max/min
threshold; they are not confidence intervals or a reason to omit a case.
Local-pair/editdist retain 0.333120×/0.369946× baseline runtime, and the two
held-out editdist variants achieve 0.370542×/0.370732×. These support transfer
across the frozen suite without establishing statistical significance or C parity.

Native qualification is complete for the frozen candidate:

- Independent upstream source checking passes.
- Actual native N1 builds N2; N2 reproduces the complete exact object through N3.
- N2 passes all 64 backend cases and all ten runtime controls.
- N2 passes all 45 benchmark outputs; all 45 emitted objects and 135 linked
  `.text`/`.data`/`.rodata` sections match N1 exactly. This transfers the runtime
  result without another timing campaign.
- Eight checked-hosted development objects and 24 linked sections match N1.
- JS/C/QBE source profiles and source maps remain byte-identical to `e4cdffa`.

The explicitly qualified candidate is
`selfhost/build/phase191/native-self01/program`, with its adjacent `report.json`,
SHA-256 `2800bc15aa9147ad9c5e2c9952b1d175addd478687677bd04b5f9e3d64e25c84`.
[Evidence](evidence.json) pins the completed gates. Installed Phase189 and the
qualified Phase190 baseline remain intact. This campaign changes maintained
source and exposes a qualified candidate; it does not perform installed public
selector promotion. Whole-corpus runtime above is for direct objects; focused
independent controls also exercise the typed assembly renderer, without a new
whole-corpus assembly runtime claim.
| Compiler operation on the frozen selected source | Seconds |
|---|---:|
| Qualified QBE producer builds native N1 | 160.167 |
| N1 builds direct-object N2 | 242.093 |
| Direct-x86 N2 rebuilds the exact object as N3 | 342.329 |

These use the existing prepared Base in cache mode and measure the complete
emission/machine pipeline after preflight, not independent source checking,
fully cold Base preparation, or isolated compiler kernels. N2 and N3 objects are byte-identical. The previous
phase recorded 159.472 / 241.793 / 348.274 seconds respectively on its own
1.84% smaller source. This historical comparison shows no large acquisition
regression; it is not a controlled same-source proof of compiler-speed gain.
The same-source N2/N1 execution-host ratio here is 1.414×: generated compiler
runtime remains an optimization opportunity independent of the 44-program score.

## Cost and retained complexity

The [final guarded-cost snapshot](campaign-cost.json), generated offline by
[campaign-cost.py](../../selfhost/tests/phase191/campaign-cost.py), records
63 closed jobs: 51 succeeded, 12 failed, none incomplete. Guard durations total
**48.214 minutes**, including **119.622 seconds of failures**. Maximum observed
process-tree RSS is **2,127,405,056 bytes** (1.98 GiB). No OOM occurred.

| Guarded category | Minutes |
|---|---:|
| Checked API acquisition and hosted emission | 15.780 |
| Native image acquisition and two self-builds | 12.437 |
| Native45/backend qualification and runtime controls | 5.788 |
| Balanced generated-program runtime campaigns | 9.995 |
| Physical profiles | 1.820 |
| Focused controls, source check, diagnostics and machine linking | 2.394 |

These summed guard durations are not elapsed research time, CPU time, kernel
runtime or total agent cost. Static analysis, editing, metadata checks, archival
and agent research run outside this accounting. Agent billing/quota is not
observable. Bounded Astra high agents handled independent research, encoder and
allocation work, semantic review and harness/retention tasks; root controlled the
single target-execution lane and integration. The earlier partial snapshot is
retained as [cost-snapshot01.json](cost-snapshot01.json).

Two reviewed archival tranches reclaimed **580.07 MiB net** while preserving
qualified/current artifacts and the shared execution lock. Both archives were
verified before pruning, with byte-exact restoration witnesses. See
[retention-result.json](retention-result.json) and
[retention-result02.json](retention-result02.json). All campaign outputs needed
for reproduction remain retained; the installed selector was not changed.

Frozen assembled source grows from 1,714,595 to 1,746,137 bytes (+31,542, 1.84%)
and 39,642 to 40,271 physical lines (+629). Its mapped x86 declarations grow
810 → 892 across 32 → 35 modules; their disjoint source spans account for the
same 31,542 added bytes. Counts include comments and selected declarations,
not logical complexity or whole-module churn. They exclude the rejected call
prototype and do not attribute unrelated mutable worktree changes to Phase191.

## Next experiment and research feedback

The [next-opportunity audit](../../research/phase191/next-opportunities.md)
compares the selected ELF with mature C. First complete the existing F32 value
path: numeric still dispatches its guarded F32-to-U32 conversion every iteration
and constructs argument buffers around inline arithmetic. Test exact conversion
edges before combining it with persistent XMM values. A 20–40% numeric runtime
reduction is a screening hypothesis, not a measured ceiling or a whole-suite
prediction. Shared address scaling and accumulator placement in fold are the
next bounded integer experiment. Map requires more than call-transfer cleanup.

The method that paid off was an exact hot-code witness, a small independently
checked transformation, balanced ablation, and a frozen held-out test. Static
counts helped explain the address win but failed to predict the call-move win.
The profiler corrected which C function actually executed and prevented us
from treating a cold Map helper as the whole workload. These are useful
improvements to experimentation; this campaign does not causally demonstrate
recursive acceleration or a higher future discovery rate. That would need a
controlled research-throughput experiment including acquisition and failures.
