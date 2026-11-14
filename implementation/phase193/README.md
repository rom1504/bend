# Phase193 — shared x86 composition, with a growth budget

Status: final source, native reproduction, correctness gates and full-suite timing
pass. Installed Phase189 and the qualified Phase192 reference remain unchanged.

## Result and scope

The selected change connects x86 public fallback bodies to the **existing** QBE
closed-continuation and ready-tail plans. It removes intermediate frame capture
and scheduler detours when the original semantic planner already knows a direct
helper is safe. Actual compiler owners `index_leaf`, `index_remove`, `p111v_put`
and `p131i_insert` demonstrate the missing composition. There is no benchmark-name
recognizer, new runtime ABI or new register-allocation algorithm.

The final native compiler completes four paired compiler requests in
**0.906848× Phase192 time (9.32% less)**. The same-producer N1 screen costs
1.029446× (2.94% more), so the new analysis is not free; the x86-generated N2
still wins after paying that cost. These are cached-Base source-to-object
requests, not cold full compiler builds. See [compiler costs](budget-compiler-cost.md).

Across native45, selected generated programs take **4.16% less time**, moving from
**2.209895× to 2.117890× mature Bend C**. Held-out programs improve **4.24%**.
This phase does not establish parity, a full compiler correctness theorem, or
recursive research acceleration.

## Why this experiment

On identical Phase192 compiler source, input, Base and output, the x86-built N2
costs **5.684283s**, versus **4.120591s** for the QBE-built N1: **1.379483×** wall
and 1.382919× CPU. Two clean observations and four sampled executions per role
use two sampling periods. All twelve outputs equal the independently checked
hosted 587,720-byte object. No sample was lost or rejected; unresolved samples
remain visible. Sampling overhead is measured separately from clean timing.

Physical profiles identify String readers, ownership helpers and dispatch as
real costs. They do not establish that all helper time is removable or that
static call counts predict dynamic work. The useful architectural difference
was more specific: x86 consumed the recursive H plans but skipped two compatible
public fallback plans that QBE already used.

See [profile](../../research/phase193/compiler-profile.md),
[machine witnesses](../../research/phase193/composition-machine.md), and
[String/ownership frontier](../../research/phase193/string-machine-frontier.md).
The compiler transformation is entirely Bend; host scripts only transport,
measure, validate and retain artifacts.

The [final before/after profile](../../research/phase193/budget-compiler-profile.md)
corroborates a net request reduction, with material two-run spread. Approximate
scheduler CPU falls0.2093→0.1195s and sink0.2180→0.1559s; String readers and
reclamation remain prominent. No dynamic invocation counts were collected.
Pooled comparison quality passes at2,243/2,073 samples, but the original report
retains `profilesUsable=false` because individual13ms captures are below500
samples. No threshold was changed. These are diagnostic estimates, not a causal
allocation of the speedup or a replacement for the separate request timing gate.

## Experiment ladder and causal checks

1. Extract unchanged compiler index/KDef routines into a 1,000-round workload.
   Its independent full-field digest checks collisions, persistent aliases,
   overwrites, Unicode/prefix keys, missing reads and final contents. Expected
   output is `2885372021\n`.
2. Compare off, fusion-only, tail-only and both variants in twenty rotated
   rounds. Full composition takes 0.925369× baseline time; fusion alone 0.932377×,
   tail alone 0.948864×. This distinguishes the mechanisms on this kernel only.
3. Check four development families before the full corpus. Final budgeted
   composition takes 0.796803× baseline on Map32, 0.962515× expression32,
   0.981723× tree and 0.968246× lexer. Small differences are not confidence claims.
4. Gate real compiler requests and complete compiler size before reproduction.
   This reveals code growth that small-program tests miss; then test one bounded
   profitability adjustment before qualifying the final source.
5. Freeze final source, independently check it, qualify native generations,
   compare exact generated products, then run the entire immutable native45.

The final budget kernel takes **0.930394×** baseline (6.96% less), against
0.924664× for uncapped composition in the same 18-round/54-process experiment.
Its object is 200,552 bytes versus 195,648 baseline and 218,048 uncapped.
These 45–50ms fresh processes include startup. They are neither compiler-request
throughput nor a held-out benchmark. Native45 uses ten development and 35 held-out
programs; its historical 44 eligible timing cases remain unchanged.

## The failed economic assumption and selected correction

Uncapped fusion improves the complete suite by 4.67% and native compiler requests
by 10.33%, but produces a 26.805MB compiler versus Phase192's 23.759MB. Its N1→N2
acquisition takes 302.204s. A symbol census attributes **99.45%** of the text growth
to public bodies; several matched bodies grow 6–16× through continuation copying.
A semantically valid optimization is not automatically profitable.

The selected policy uses the original planner and accepts a fused body only when
its statement count is at most `2 * original + 16`. An explicit arithmetic bound
prevents overflow. It counts only when a site fused, using the existing linear
counter. Rejection still permits ready-tail conversion of the **original** body.
There is no partially accepted fusion or weaker semantic admission.

The final compiler is **24.804MB**, 7.46% smaller than the uncapped candidate and
4.40% larger than Phase192. N1→N2 costs **278.214s**, 7.94% less than uncapped but
9.16% above the historical Phase192 observation. These are single acquisitions
of different compiler sources, not controlled cold-build speedup estimates.
The four development cases differ from uncapped by less than 0.8% each.

Final N2→N3 self-reproduction takes **341.379s**, versus the historical Phase192
354.521s. Source and emitted products differ, and these are single observations;
this does not establish a controlled 3.71% cold-build gain. It does show why the
9.32% small-request improvement must not be assigned to full self-compilation.

This budget still constructs the fusion plan before refusing it. Avoiding that
work earlier is a plausible next compiler-cost experiment, not a measured gain.
The threshold is an initial policy, not a proven optimum. Original analysis,
selection, ownership and fallback contracts remain intact.

## Final generated-program runtime

The final complete [budget summary](runtime-budget-summary.md) authenticates
591 calibration observations and 720 timed observations: four balanced rounds
of four roles across 45 programs, of which 44 are historically ratio-eligible.
The zero-work case remains correctness-only. The larger bounded campaign
completes without a deadline continuation.

| Metric | Fresh Phase192 | Selected Phase193 |
| --- | ---: | ---: |
| Geometric runtime / mature Bend C | 2.209895× | 2.117890× |
| Candidate / Phase192 | 1× | 0.958367× (4.16% less) |
| Equal-family runtime / C, 22 families | 2.312129× | 2.189091× |
| Mean positive log-slowdown / C | 0.908674 | 0.866163 |
| Cases above 1.1× /2× C | 36 /32 | 37 /32 |
| Fixed catalog work | 27.5391s | 26.1976s |
| Positive excess fixed work above C | 17.4736s | 16.1323s |

Held-out 34 timed cases improve 4.24%; the ten development cases improve 3.90%.
Equal-family time improves 5.32%, fixed work 4.87%. Fresh QBE is 1.349626× C.
Record aggregation improves 20–22%, evening 20%, Map churn 20–21%, and Map-set
13%. These results transfer beyond the extracted compiler workload.

All regressions remain included. The largest are numeric1024 **+3.55%**,
expression32 **+2.35%**, and Mandelbrot variation **+1.09%**, all dispersion-flagged.
The summary retains eleven flagged cases; a flag is neither a correction nor
proof that a regression is noise. Symreg variation rises from 1.09973× to
1.10845× C, accounting for the additional case above 1.1×. No case-count parity
improvement is claimed. Four rounds do not establish confidence intervals.

The earlier **uncapped** complete results remain in
[runtime-summary.md](runtime-summary.md). They are a separate experiment, not
the final selection. Its 400-second deadline ended during an untimed calibration;
a strict authenticated continuation completed exactly four missing cases and
retained all earlier results and the failed pilot. The uncapped 4.67% and final
budget 4.16% improvements come from separate freshly balanced campaigns, not a
direct paired estimate of their difference.

The comparison is against the mature selfhosted **Bend C target**, not handwritten
C, and not the runtime of the upstream TypeScript compiler. C, QBE, Phase192 x86
and the selected x86 products are freshly interleaved under identical input and
runtime policies. All individual regressions and dispersion flags stay included.

## Correctness, ownership and qualification boundaries

- Independent source checking of the exact final source passes with zero holes.
- Thirteen distinct admission/structural adversaries pass under four isolated
  policies; 1,024 independent runtime observations pass across direct ELF and
  GNU-as routes. Separate seven-case numeric budget boundaries pass. The budget's
  composition/fallback behavior has a source audit; those seven checks are not a
  universal theorem about it.
- Both final N1 and N2 pass every native45 output oracle.
- All 45 N1/N2 objects and their 135 linked sections are compared separately.
  Four checked-hosted development products also equal N1 exactly. The hosted
  budget API and native source use different preparation paths: an exact closure
  audit proves their 5,267 compiler declarations plus five bridge wrappers agree.
- Native64 and runtime10 pass; final N2→N3 objects reproduce exactly.
- Five other canonical source profiles and maps remain byte-identical. All 112
  protected declarations and the 225-module inventory remain unchanged.

Helper arguments are snapshotted before calls; public `rt_return` preserves the
pending caller continuation. Reserved names, metadata, target availability,
original H/direct precedence and whole-original fallback remain enforced. Runtime
code and the independent final verifier are unchanged. The maintained adapter is
190 lines; canonical selected source grows **359 lines /16,042 bytes (0.89%)**.

Selected source SHA256:
`fd95adc1bdc210bc3827c9dd3536b8e7289fb60c4e983f0e008714665239428a`.
Selected N2: `selfhost/build/phase193/budget-native-self01/program`, SHA256
`d518efb62f7500681288dedb19979a5aa3bbd1b71a71e509546f64059af8d177`.
Its 30,390,000-byte object has SHA256
`5a67994548796e866b2413b6aa5bcae22fb1244638e72ae4bc30c7dc0b6ef91b`.
Finite controls, source acceptance, reproduction and mathematical proof are
distinct. No new BendTT theorem or installed release promotion is claimed.

## Rejected ideas, remaining risks and next step

Blanket ownership-take inlining repeats an earlier negative experiment. The
reflexive-comparison fold touches too little measured work to lead this campaign.
Constant-backedge threading remains an unselected offline prototype. Machine
inspection does not justify broad scratch promotion: traced temporary buffers
escape to constructors or fallback transfers. These negatives are retained.

Uncapped local-fold has identical hot-loop bytes at the same address despite a
runtime regression; surrounding public bodies changed. Unicode has unchanged
private worker instructions but different public control code. Neither inspection
proves that layout or noise caused the regression. Final timings, not static
instruction counts, decide the selected result.

The next strongest shared direction is **borrowed String traversal and value
lifetimes across helper boundaries**, guided by actual compiler samples and
held-out text/tree workloads. Test a small, ownership-aware reader before another
broad allocator rewrite. Separately, test rejecting excessive continuation copying
before materialization. That could improve research iteration cost without
changing the accepted generated program, but must preserve exact selected plans.

Keep the compiler as one real workload alongside unrelated programs. The measured
9.32% request gain is useful; it is not evidence that a complete research cycle is
9.32% faster. Build, independent qualification, failed experiments and agent work
must be charged separately. No discovery-rate or recursive-acceleration claim is
made.

## Research cost

[The complete guard ledger](campaign-cost.json) records **57 jobs /3,320.50s
(55.34 minutes)** of serial guarded work, including five nonzero-exit jobs.
This is not total elapsed research time, agent compute, token quota or billing.
Offline analysis, writing, orchestration and retention outside guards are excluded.

| Guarded category | Seconds |
| --- | ---: |
| Compiler image acquisition / reproduction | 1,268.50 |
| Program-runtime campaigns | 925.62 |
| Native oracles and qualification | 447.89 |
| Compiler-request timing | 138.86 |
| Compiler profiling | 135.51 |
| Remaining APIs, controls, kernels and source checks | 404.12 |

The uncapped campaign's deadline job is counted in full; its 41 accepted cases
remain useful evidence, so failed-job time is not all discarded work. Other
failures exposed affine fixture reuse, export/verifier metadata or runtime
fixture mistakes and remain retained. Peak process-tree RSS is **2.08GiB** and
minimum observed free disk is **5.115GiB**, above the required reserve. All five
full-image builds were gated by earlier kernel/development evidence; the uncapped
candidate was stopped before N3 when its code-growth cost became clear.

The practical methodology win is reusing an already checked semantic plan and
finding its economic failure before final promotion. There is still no measured
increase in validated discoveries per research hour. Further experiments should
use the preserved compiler-helper closure and existing profile instead of
rebuilding a complete compiler merely to try another local transformation.

## Reproduction and retained evidence

[Design](../../design/phase193/README.md),
[experiment 1](../../experiments/phase193/P193-001-public-ready-composition.md),
[growth-budget experiment](../../experiments/phase193/P193-002-fusion-growth-budget.md),
[methods](../../selfhost/tests/phase193/README.md),
[hosted/native closure audit](../../research/phase193/budget-hosted-native-products.md).

[Final evidence](evidence.json) pins20 completed receipts and the qualified
source/object identities. The [verified metadata bundle](evidence-bundle01/inventory.json)
preserves bounded receipts and diagnostics, including failed attempts; it is not
a backup of all compiler executables or raw profiling samples.

Use the maintained source assembler, explicit frozen assets and fresh output
paths. `selfhost/tests/phase193/job.py` applies the repository guard and retention
close; one CPU3 target lane, 5GiB disk reserve, bounded memory. Frozen argv and
source identities are preserved in the final qualification plans and receipts.
Do not reapply experimental patches to already selected maintained source.

Three exact reviewed archive/verify/prune tranches recover approximately 515MiB
of old assembly artifacts. Images, objects, sources, consumed development assembly
and all budget roots remain protected. Historical assembly replay may require
restoring its verified archive. No directory-by-age deletion or shared lock removal
was used. See the three retention reports beside this document.
