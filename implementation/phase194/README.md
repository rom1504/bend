# Phase194 — value identity, composable selection and diagnostic discovery

Completed, native-qualified and selected in maintained source. **Direct-object
native45 runtime improves from 2.102761× to 1.971034× mature Bend C**, or **6.26%
less time** than freshly measured Phase193. Held-out cases improve 6.52%. This is
a measured improvement, not parity: 32 of 44 timed programs still exceed 2× C.
Installed Phase189 remains unchanged; this report qualifies the research image.

## Full native45 result

Four roles rotate through four balanced rounds on CPU3. All 45 outputs pass;
44 enter timing ratios and the zero-work case remains correctness-only. Exact
products, 610 calibration observations and 720 timed observations were
reauthenticated. The 12 new diagnostics are excluded from this historical score.

| Metric | Phase193, freshly timed | Phase194 |
|---|---:|---:|
| Geometric runtime / mature Bend C | 2.102761× | 1.971034× |
| Equal-family runtime / C (22 families) | 2.173862× | 2.044576× |
| Mean positive log-slowdown / C | 0.860694 | 0.808492 |
| Cases >1.1× C | 39/44 | 36/44 |
| Cases >2× C | 32/44 | 32/44 |
| Fixed-catalog equivalent runtime sum | 25.889s | 24.463s |
| Positive fixed-catalog excess over C | 15.892s | 14.476s |

The paired overall ratio is 0.937355; equal-family ratio is 0.940527; the
34 eligible held-out cases take 0.934823× baseline time. The independently timed
QBE reference is 1.348552× C. These C products are our mature self-hosted C target,
not handwritten C or a new upstream compiler comparison. Historical Phase193's
2.117890× score was a different timing campaign; it is not the denominator here.

Ordinary improvements include numeric256 −15.14%, numeric1024 −11.78%,
local-pair −7.95%, editdist −6.10%, and ray64/256 about −5.5%. Held-out scalar-region
falls25.09%, Mandelbrot variants19.83–24.87%, and closure25623.90%. Those latter
results measure the combined compiler change; they do not isolate each pass's
causal contribution. Local-fold improves16.76% with a dispersion flag.

Every regression stays included: expression128 +2.90%, lexer +1.01%, generic-row
+0.96%, unicode16 +0.83%, expression32 +0.79%, unicode64 +0.76%, morning +0.52%,
record64 +0.14%. Twelve cases carry a max/min >1.10 dispersion flag in at least
one role. Flags are not confidence intervals. See the complete
[runtime table and raw-result identity](runtime-summary.md).

## What changed

Three small, general Bend-written mechanisms extend the existing typed x86 path:

1. Closed F32 definition identity distinguishes overwritten values before XMM
   placement. A bounded suffix check admits a rename only when the original destination
   is redefined before an observation/call/control boundary. The last write keeps
   its original name; existing canonical-full-word and placement checks remain.
2. Predicate selection preserves a comparison through exact copies, xor1 and
   empty predicate branches into an existing pure conditional-selection plan.
   Whole-original read counts certify that removed Boolean temporaries do not
   escape. Comparison and selected-value widths are independent. The CMP stays
   at its original point, and intervening loads preserve flags.
3. Commutative register selection uses the left register directly when the
   destination already contains the right operand for U32/U64 add/mul/and/or/xor.
   It removes snapshots and copies without changing allocation, memory operations
   or evaluation order. A cheap applicability check avoids an extra frame lookup
   on ordinary refusals. Subtraction, comparisons, shifts and pointer types retain
   the original path.

No benchmark names, new runtime ABI, general SSA framework or new backend were
introduced. There is one bounded F32 transformation with supporting scans; predicate facts
extend an existing walk; commutation is local instruction selection. The source grows
332 lines / 16,466 bytes (0.905%) to 42,159 lines / 1,835,600 bytes. This is additional code,
not a line-count reduction. Five non-x86 canonical profiles remain byte-identical.

The selected source is `selfhost/build/phase194/selected-source02/compiler.bend`,
SHA256 `4b29752fec8fbdb593a86b80f99ea18b7705dfc9fe56a364280bebb1f46c5e63`.
Independent acceptance has zero holes. Source acceptance, finite testing and
mathematical proof remain distinct; no new BendTT theorem is claimed.

## Fast experiments and actual removed work

The first two mechanisms were tested independently before composition, against
freshly interleaved frozen Phase193/C/QBE products. On six development cases,
predicate selection reduces local-pair by9.23% and editdist by4.98%. Float identity
reduces numeric256 by13.93% and ray64 by2.52%. Dispersion flags stay included;
these are not whole-suite estimates. See [causal screen](ablation-runtime-summary.md).

The final three-feature development screen gives roughly8% less local-pair time,
6% editdist,15% numeric and5% ray, with tree/lexer near baseline. The additional
commutation effect on ordinary programs is small; ray's approximately3.5% extra
improvement is dispersion-flagged. See [composition screen](composition-dev-summary.md).

Machine inspection connects these observations to specific work:

- Pair/edit row loops shrink93→77 instructions, removing three SETcc→TEST chains
  while retaining three CMOVs and the same frame.
- Numeric removes three adjacent register-bank round trips. Ray removes94 static
  instructions overall, but frames grow and isect5 gains four stack references.
- Held-out scalar-region loses seven predicate chains:159→121 loop instructions,
  with five fewer stack accesses. The closure callback loses two accumulation
  MOVs:13→11 loop instructions. Frames stay unchanged; code layout also changes.
  These are real transfer mechanisms, not isolated attribution of the full gain.
- The new few-live diagnostic loses exactly22 MOVs:89→67 loop instructions,
  with identical multiplies/XORs/frame and no spills. The many-live loop retains
  its12 stack accesses. Unique-product loses two hot MOVs; mask loses four.

Static counts are not dynamic invocation counts or performance ceilings. The
value-rebinding diagnostic improves with byte-identical hot code and changed
code addresses/layout; its gain is not attributed to arithmetic removal. Negative evidence
and unexplained differences are retained in the machine reports.

## The diagnostic suite changed the research question

Twelve ordinary programs form six paired families, with independent outputs at
two parameter points. Only the larger point is timed. They remain outside native45 and its geometric score.
All12 build through C, QBE, baseline x86 and selected x86. Each timing campaign
first checks96 exact observations, then rotates four roles through four balanced
rounds with200–300ms calibration targets. The original12-program authority and
failed versions are preserved; the active catalog is version3.

The two-feature diagnostic comparison shows23.5% improvement on closed F32 and
21.7% on the predicate mask. Adding commutation reduces few-live time22.6% and
unique-product11.1%; the many-live case is effectively unchanged. All other
results, including regressions and variable shared-product timings, remain in
[diagnostic tables](diagnostic-runtime-summary.md) and
[commutation tables](diagnostic-commutative-summary.md).

These probes falsify several tempting broad explanations:

- The value-identity pair already has spill-free loops. A wholesale SSA rewrite
  is not justified by those examples.
- QBE has no spills in the many-live case and uses additional registers currently
  reserved as x86 scratch; their causal contribution was not isolated. C vectorizes both pressure variants; fewer scalar moves alone cannot
  reproduce that capability.
- Unique products scalarize, while shared products reconstruct owned heap state
  and invoke observers. QBE retains related reconstruction; C inlines helpers
  but keeps heap/ownership paths. This is a representation problem as well as a
  machine-selection problem.
- The memory pair includes two takes/two constructions and helper calls around
  reads. It is not an isolated DRAM-latency experiment.
- F32 state still crosses register banks at loop backedges, and redundant counter
  predicates survive. Pure arithmetic, placement and branch selection do not yet
  compose fully on the float path.

The commutation idea was discovered by inspecting the new diagnostics and then
checked on unrelated programs. This is useful evidence that diagnostic discovery
can generate compiler improvements. It is not evidence of recursive acceleration
or a measured increase in validated discoveries per research hour.

## Correctness and trust boundary

Finite controls cover integer widths, signed comparisons, old-value snapshots,
protected locals, copies/inversions, repeated definitions, admission fuel,
canonical/noncanonical floating words, NaN payloads and ordinary effects/cuts.
Float controls provide28,880 machine observations per route; predicate7,260;
additional stress1,210; commutation6,050. Object and rendered assembly consume
the same typed instructions, so they are not two independent selectors.

The independent audit found that some full-pipeline stress cases did not
exercise the new selector. A versioned raw-selector fixture closes that admission gap with
actual machine-pattern assertions; passing output alone was insufficient.
Float pressure saturation and complete universal semantic equivalence remain
outside the finite evidence. No validators or benchmark definitions were weakened.

The final source passes independent acceptance with zero holes, native64 and ten
runtime controls, all 45 independently expected N1/N2 outputs, and exact equality
of all 45 objects and 135 linked sections between generations. Six ordinary
checked-hosted products match N1 objects exactly. N1 builds N2; N2 reproduces the
same compiler object as N3. Linked compiler binaries differ in metadata, so
binary-byte equality is not claimed.

Qualified research N2 is `selfhost/build/phase194/native-self01/program`, SHA256
`5148debe7f21391ed784ba487840fd501693aafd161f231d004f29846151c982`.
Its object is `474a4ee5dcb43fa32d329684b1ec1380dfbb276f7ea912414ce9408bf65a7f2c`.
Installed Phase189 and the qualified Phase193 reference remain intact.

## Compiler cost

The four paired compiler requests take **1.007781×** Phase193 time for the
QBE-built N1 and **0.985722×** for the x86-built N2. This two-round screen detects
no material compiler-cost regression; it is not a confidence interval or proof
of a 1.4% compiler improvement. Each request's output is checked against its own
qualified product. It measures source-to-object with cached Base, excluding
linking and generated-program execution.

The final N1 acquisition takes 170.329s; N1→N2 takes 280.493s; N2→N3 takes
342.028s. Those are single build observations, including machine construction.
The same-source last two builds compare differently hosted compiler executables,
not successive improvements. Cross-phase historical self-builds use different
compiler sources and do not establish a controlled cold-build gain. The N2
binary grows 0.641% to 24,963,272 bytes. See [compiler-cost receipts](compiler-cost.md).

## Methodology: what worked and what did not

Astra High agents handled bounded float/predicate implementation, independent
semantic review, diagnostic fixtures, machine comparisons, compiler-cost audit
and retention planning. One coordinating agent owned integration and the single
CPU3 execution lane. Agents did not run competing timed campaigns.

The productive sequence was checked component → exact machine witness → six
ordinary programs → separate diagnostics → selected native qualification. The
new probes led to commutative selection, a mechanism absent from the initial
plan. Existing counters and disassembly were more decisive than adding another
generic optimization framework. This campaign did not collect new physical CPU
samples; it used prior profiles, actual machine code, controlled runtime
ablations and independent output oracles.

Costs and failures matter. Forward declarations, affine annotations and memory
fixture admission required versioned corrections. A stale-parent API was refused
by provenance checking. Some full-pipeline stress controls did not reach the
selector; raw-selector controls made that boundary explicit. A long CSV hit the
retained guard's path check before dispatch. A compiler-cost plan rejected invalid
CLI flags before requests ran. The first final runtime launch preceded manifest
completion and failed without executing programs; the fresh `runtime02` is the
complete result. None of these attempts is counted as a semantic or performance
success; raw failures remain in the evidence archive.

Not every smaller machine loop became proportionally faster. Many-live pressure
is unchanged, memory-dependent timing regresses 3.77% in the commutation screen
with dispersion flags, and value-rebinding improves without a changed hot kernel.
These are reasons to preserve negative evidence and separate code layout,
representation and dynamic work from static instruction counts.

## Remaining opportunities

The next small compositional test is integer comparison→FloatBranch reuse with
original float-node emission. Blindly routing float plain rows through the entire
ordinary selector would be unsafe: XMM-only values can have stale GPR homes, and
address selection can extend input lifetimes that current placement did not plan.
The [independent design audit](../../research/phase194/next-composition.md) gives
precise boundaries and falsifiers.

The larger opportunities are preserving F32 loop-carried state, reducing scratch
register reservation with explicit instruction/clobber lifetimes, and eliminating
shared-product reconstruction across known observers. The diagnostics distinguish
these mechanisms; they do not establish promised whole-suite gains. General
vectorization is another gap exposed by C, with a materially larger engineering
and verification cost than commutation.

## Cost and retention

The 65 terminal guarded jobs used **50.08 minutes** of serial guard wall time;
nine failed jobs remain included. The overall session also includes agent work,
source edits, analysis, orchestration and report preparation. Those overlap with
execution; they must not be added as independent wall-clock durations.

| Guard category | Minutes |
|---|---:|
| Three compiler-image acquisitions/reproduction | 13.24 |
| Development/reference product construction | 12.74 |
| Runtime experiments, including final full suite | 12.81 |
| Native oracles and generation comparisons | 5.54 |
| Checked API acquisition | 2.55 |
| Adversarial component controls | 1.05 |
| Compiler request timing | 1.13 |
| Source checking, planning and other guarded work | 1.02 |

These are descriptive categories from [the complete cost ledger](campaign-cost01.json),
not a claim that all build or validation cost was unavoidable. Agent billing and
compute are unavailable. Peak guarded process-tree RSS was 2.08GiB; minimum
observed free disk was 5.09GiB. Two reviewed archive/verify/restore/prune tranches
recovered 644,296,704 bytes net from historical generated text; current artifacts,
images, objects, sources and profiles were retained. No phase-directory deletion.

## Reproduction

[Design](../../design/phase194/README.md) ·
[Methods](../../selfhost/tests/phase194/README.md) ·
[Predicate audit](../../research/phase194/predicate-machine.md) ·
[Float audit](../../research/phase194/float-machine.md) ·
[Integer/memory diagnostics](../../research/phase194/diagnostic-machine.md) ·
[Held-out machine transfer](../../research/phase194/heldout-machine.md) ·
[Float/product diagnostics](../../research/phase194/diagnostic-float-products.md) ·
[Independent combined audit](../../research/phase194/combined-audit.md) ·
[Qualification identities](evidence.json) · [Verbatim receipt archive](evidence01/receipts.tar.gz).

Use one guarded CPU3 lane and fresh paths. Original failed source/control/fixture
attempts remain preserved. Retention archives verify exact members and restore a
full witness before pruning only reviewed historical generated text. Agent billing
is unavailable and will not be inferred from wall time or guard totals.
