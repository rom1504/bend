# Current frontier: Phase117 scalar-array facts and loop versioning

[Report](../implementation/phase117/README.md) ·
[Design](../design/phase117/array-facts-and-scalar-code.md) ·
[Exact measurements](../implementation/phase117/results.json) ·
[Selection](../implementation/phase117/selection.json) ·
[Reproduction](../selfhost/tools/performance/phase117/README.md).

Selected checked Bend source03 reuses packed32 scalar allocation/access/drop,
tracks exact invariant entry handles, versions complete loops with an original
fallback worker, and raises the general inline body cap384→512. All other budgets
and independent admission/verifier boundaries remain. The selected runtime is
capability-adapted GCC10-O2; global/allocator-only O3 experiments are NOT selected.
No workload names guide compiler decisions.

Original45 passes405 complete output/count observations. Its44 timed points move
5.308→4.240×pinned upstream C,1.25185×faster/20.12% less time. Array cases gain up
to5×; tree/lexer/scalar families are mostly unchanged. Longer closure64 recheck
regresses3.1%; closure256's small initial regression does not persist. These are
hosted-API-produced native programs, not a new native-compiler qualification.

Hosted prepared-Base requests cost+3.7%fold,+23.7%editdist,−0.6%lexer; geometric
cost+8.46%. Source50,590→51,056lines (+0.92%); broad QBE grows2.35%. Do not equate
generated-code speed with compiler/request/research-loop speed. No native B1/B2
throughput update, installed selection change or recursive acceleration claim.

Selected source SHA8010f9b5691a32f9b8d3a45da444e05b4bf4275fd1380e2acb122bfd2e53fec6;
API `phase111/p117-version-api03`, runtime `phase117/runtime01`.22 finite analysis
controls,11 ordinary owner/array controls and forced-slow scalar/product ABI
controls pass. Independent replay checks1,198 selected/rejected observations.
Source/API checks plus finite controls are not a formal backend proof.

New profiles: fold59%kernel,28%allocation/fill,2%generic destruction (previously22%);
editdist353/354 leaves in row. Boolean normalization has zero useful gain; optional
unroll2 adds6–11% only on folds and remains excluded. Global runtime-O3 regresses
ownership cases; allocator-only O3 improves small fold but broad marginal gain
~0.5% and new2–4%slowdowns do not justify promotion. Preserve all negative results.

Prioritize broad ownership information/borrowed observers and destination-passing
in hot tree/map/text computations, using Phase116 and mature-C plans. Shared RFC
paths require proof, not uniqueness assumptions. Also isolate/reduce extra inlining,
lowering and verification cost before claiming a faster compiler research loop.
For runtime-only experiments reuse authenticated QBE/object artifacts; the new
relink harness avoids282s broad emission while retaining original execution gates.

# Qualified native development checkpoint: Phase114 source02

[Report](../implementation/phase114/README.md) ·
[Native results](../implementation/phase114/native-results.md) ·
[Selection](../implementation/phase114/selection.json).

Source02 N1/N2 self-reproduce74,220,801QBE bytes. Both pass focused19 and N2 passes
original45 one-shot outputs. The prior hosted source01 runtime aggregate is5.386×
upstream; do not relabel it as native-produced full45 timing. Source02 changes six
namespace traversals to loops after the first full acquisition hit a host stack
exception. Final qualification took22.07min/3.820GiB; enough disk is required.

Three-source native request ratios: N1 2.82490× /N2 2.82713× upstream;
request+machine-build sums1.35522×/1.35687×. The prepared-Base direct-QBE/cached-runtime
policy differs from upstream source-Base→C/Clang. Do not compare these clocks with
compiled-program runtime. Installed production selection remains unchanged.
Float/table/scalar-operand extensions are still separate experiments; read the
Phase114 report before repeating them. Phase112/113 remain historical checkpoints.

# Supporting evidence and production identities

[Phase116](../implementation/phase116/README.md): eight matched diagnostic programs,
QBE6.649×upstream C versus mature selfhost C1.089×;120 clean observations,48 native
captures and16 V8 profiles. This subset does not replace broad45. C already has
useful coherent scalar-array, observer and constructor plans. Tree scan is cold;
warp ownership/constructor paths are hot. Compiler profiles show related ownership
costs, but transfer to the compiler still needs measurement.

[Phase115](../implementation/phase115/README.md): four-policy reuse cuts emission
30.3%, but current policy remains best for runtime. Existing alternatives have
little diversity. Small negative-decision retention saves4.15% full warm emission;
it remains separate from the qualified native source. Do not launch large policy
search without new opportunities or demonstrated complete-loop amortization.

[Phase105](../implementation/phase105/README.md) remains authoritative for production
B1/B2 versus upstream: prepared45 0.499×/0.517×, live-Base2.384×/2.231×, full-source
prepared2.602×/2.965×. The installed native CLI/package is the Phase102 selection;
the Phase90 JS release remains separate. Read [comparison definitions](../docs/self_hosted/NATIVE_COMPILER_COMPARISON.md)
and [direct-QBE guide](../docs/self_hosted/direct-qbe.md) before quoting metrics.

# Resource, evidence and communication rules

One root-owned serial CPU3 target lane; use existing process-tree guards,2GiB for
ordinary experiments and a16GiB available floor. Larger qualified image campaigns
have separate4GiB gates. No unsafe/failure-runtime probes; do not resume Phase113
custom failure reproductions. Ordinary valid source controls and frozen benchmarks
are the iteration loop. Agents can perform disjoint offline audits; account for
cost rather than using them reflexively. Keep rejected attempts and independent
oracles. Never overwrite a frozen artifact, including hardlinked paths.

Disk is tight. Phase117 retained every exact artifact while deduplicating bytes;
its evidence capsule is10.9MB compressed. No full image build until disk and
measured benefit justify it.54 guards used19.82min total; non-target research time
and billing/quota are distinct. No PR comments unless explicitly requested.

The longer-term recursive-research question remains open. Use
[Phase104 design](../design/phase104/recursive-improvement.md) and
[research](../research/compilers_architecture_and_techniques/recursive-self-improvement.md).
Repeated self-reproduction is not recursive improvement;1×/10×/100× labels are
research scope, never measured speedup factors. See the ledger for older frontiers.
