# Phase122: profile the remaining gap to upstream

The strongest opportunity is to preserve **typed, owned values across complete
private computations**, rather than optimize another isolated runtime helper.
Fresh comparisons show that our mature C output already approaches or beats
upstream on several families where current QBE remains3–4.5× slower. Three
distinct mechanisms prevent QBE from obtaining that result: private operations
fail to compose, temporary products remain materialized, and compact scalar
computations expand into inefficient machine code.

This phase profiles and diagnoses only. No optimizer, runtime, compiler image,
benchmark definition or installed selection changed. Source is Phase121 source04
on qualified Phase118; Phase120 numeric experiments remain separate.

[Design](../../design/phase122/remaining-gap-profiles.md) ·
[Reproduce](../../selfhost/tools/performance/phase122/README.md) ·
[Results](results.json) · [Evidence](evidence/summary.json).

## What was measured

Ten selected cases, three existing products each, three rotated clean rounds:
90 complete-output/count observations. Two physical-PC captures per product at
8/13ms give60 usable, zero-loss captures and33,274 samples. Reanalysis and all150
outputs pass. Sampling uses independently scaled counts; profile clocks do not
enter the following speed ratios. Three rounds are a screening measurement,
not a confidence interval for small differences.

Times are fixed-batch medians in milliseconds. Source, inputs and output oracle
match across products. Compiler vintages and toolchains differ; this is not an
isolated QBE-versus-Clang experiment.

| Program | Current QBE | Mature selfhost C | Upstream C | QBE / upstream | Mature C / upstream |
|---|---:|---:|---:|---:|---:|
| RLE roundtrip |1531|414|199|7.69×|2.08×|
| Evening program |1428|271|199|7.18×|1.36×|
| Tree bitonic |965|271|204|4.73×|1.33×|
| Lexer |851|204|190|4.48×|1.07×|
| Map churn128 |725|125|201|3.61×|0.62×|
| BST64 |618|197|185|3.34×|1.06×|
| Record aggregation256 |702|156|203|3.46×|0.77×|
| Active ray256 |1702|686|201|8.47×|3.41×|
| Scalar region8192 |428|207|200|2.14×|1.03×|
| Edit distance |429|202|202|2.12×|1.00×|

This deliberately difficult diagnostic subset is4.240× upstream geometrically;
it does **not** replace Phase121's full44-timed-point score2.144×. The full frozen
corpus still has40 points above1.1×, and its summed fixed-batch times are3.219×
upstream. Four unusually fast points improve the geometric score substantially.
No native compiler-throughput or fresh JavaScript performance measurement follows
from these results. JS is used below as a source of reusable semantic plans.

## Three mechanisms, with counterexamples

**1. Existing private optimizations do not compose across ordinary calls.**
RLE has direct `lrepeat`, `lconcat` and `rle` workers, but `expand` remains in the
global scheduler. Its first helper call needs a local continuation before its
own recursive descent. The private recursive-table plan supports terminal ready
calls or descent to the same recursive owner, but not that composition. A checked
`CallReady → Resume` node could keep the computation in an explicit local stack,
with exact ownership and no new machine-recursive cycle. The exact structured
refusal trace still needs to confirm all admission blockers.

This is dynamically relevant: control/transport leaves are17.1% of RLE,23.0% of
evening,21.4% of map and15.4% of lexer; generic segments add separate useful and
administrative work. All current-QBE libc samples in these profiles fall in the
authenticated copy region. They do not identify the callers of those copies.
Eliminating only a20% helper share could yield at most1.25×. A larger win requires
also eliminating register-bank traffic, intermediate values and repeated work
inside the resulting private region. **BST is a counterexample:** only0.5% is
control/transport, so this mechanism cannot explain its3.34× deficit.

**2. Ownership and finite layout information disappear too early.** RLE's
already-inlined step reconstructs two nested state tuples on each backedge.
Upstream carries their three fields directly. Our layout admission rejects a
nested finite Sigma because its ADT name equals its parent's; the one-level
layout cannot express the complete field bundle. Shared fresh products also
rebox before field use, whereas upstream shares their fields directly.

The tree witness is different: QBE consumes two Node cells and constructs three;
upstream reuses the two consumed cells and allocates only the enclosing Node.
BST spends51.3% of sampled time in constructor/take helpers despite already using
private workers. Known packed leaves also retain avoidable helper boundaries.
This makes ownership-preserving reconstruction a real candidate. But generic
cell-credit reuse was neutral/slower in Phase118; the same protocol should not be
retried. Removing every sampled BST constructor/take cost alone would bound the
speedup near2.05×, not3.34×. Additional worker simplification would still be needed.

**3. Fully private scalar loops can still emit poor machine code.** Editdist's
active row has hoisted array checks, direct element access and no hot helper
calls. Yet its selected inner loop has65 instructions and9 stack-memory operands;
both C products have26 instructions and none. Comparison results pass through
Boolean conversion and a second comparison before selection. C reduces this to
a direct compare/conditional move. QBE also forms addresses less efficiently and
keeps more live temporaries. The recorded intervals and instruction counts are
reproducible, but do not assign causal cycle fractions.

Ray is another private-code problem:88.5% of samples are in private workers,
11.5% in generic primitive dispatch, with no sampled global scheduler. Its F32
arguments and loop values still cross integer-word interfaces; the intersection
body has repeated integer/float transfers. Phase120's local float facts and
inlining did not establish a typed loop/call ABI. Upstream additionally exposes
packed arithmetic to Clang. Mature C remains3.41× upstream here, so merely
matching our C lowering is insufficient for ray parity.

Detailed evidence: [structural](structural-audit.md),
[editdist](editdist-audit.md), [numeric](numeric-audit.md),
[primitive arms](primitive-audit.md). The latter resolves actual Nat operations
inside `p111_rt_op`: map's divmod arm is3.05% of all samples and returns an owned
tuple. A scalar two-result projection could remove its tuple boundary as well
as dispatch; the allocation share attributable to that caller is unmeasured.
Lexer primitive dispatch is just0.55%, so primitive tuning is not its priority.

## Ranked next experiments

Ranked by expected information and useful gain per implementation hour. All gain
ranges are **planning hypotheses for affected programs**, not measurements,
guarantees or multiplicative independent gains. Times assume this workspace and
include focused controls/measurement; a full native acquisition/qualification
adds roughly20–30min based on prior campaigns and should happen only once after
integration. No compiler-throughput gain is assumed.

| Order | Capability / first falsifying experiment | Estimated local speedup | Prototype / general implementation | Complexity and main risk |
|---|---|---|---|---|
|1|**Canonicalize typed predicates after inlining.** Remove proven comparison→Bool→comparison round trips in frozen editdist IR; require compact compare/select and fewer spills. Confirm on unrelated unsigned minima and scalar loops.|1.2–1.8× on editdist-like scalar loops; full2.1× gap is an empirical ceiling to investigate, not promised by this pass.|20–40min /1–2h|Low–medium. Preserve word widths, unknown-value branches and unsigned boundaries. Earlier Phase120 Boolean rewriting caused verifier fallback or neutrality; this is a narrower, machine-evidenced experiment.|
|2|**Compose ready helper calls inside stack-safe private recursion.** Query `expand`'s exact refusal, then isolate outlined-versus-inlined helper before descent with heap results and deep inputs.|1.2–1.8× on scheduler-heavy families; combining with representation elimination could plausibly give2–4×, still unmeasured.|30–60min /2–4h|Medium–high. Exact continuation captures, callee ownership/effects and call-graph cycles; never replace explicit-stack safety with unchecked C recursion.|
|3|**Keep finite nested/shared products virtual.** Compare explicit RLE state lanes with outer-shell-only flattening, then shared product fields in an unrelated control. Also test Nat.divmod two-result projection separately from arithmetic specialization.|1.1–1.5× for the first state-shell change;1.3–2× where whole private product lifetimes disappear. This is only a subset of RLE/evening work.|20–40min /1–3h|Medium. Finite versus recursive dependent layouts, field-level retain/drop and escaping results. Reuse JS typed-shape admission, not JS memory semantics.|
|4|**Preserve owned cells through reconstruction and known packed access.** Start with the two-input/three-output tree rewrite using a private exact-layout token, without the rejected generic credit ABI. Require BST transfer.|1.3–2× on constructor-heavy tree/BST cases if helper/allocation categories shrink.|30–60min /2–4h|High. Uniqueness, shared/static/packed refusals, children ownership and evaluation order. A matched tag alone does not prove reuse safe.|
|5|**Persistent F32 private regions.** Compare integer ABI, typed ABI only, then typed calls/backedges on intersection/nearest and an unrelated recurrence. Only then measure scalar-versus-packed headroom.|1.5–3× on ray-like numeric code is an ambitious hypothesis;8.5× parity needs further evidence, possibly specialization and vector lowering.|45–90min /3–6h before a separate SIMD effort|High. F32 rounding, signed zero/NaN behavior, typed phis and boundary adapters, spill pressure. Blindly increasing inlining previously increased body/frame size.|

Start with row1 because it can falsify a cheap, general cause quickly. Run the
RLE explicit-state ceiling alongside the source audit for row2, without a broad
compiler build. Stop or narrow any experiment whose predicted code removal
occurs without a useful timing change. If a kernel improves, require a renamed
semantic control and an unrelated family before extending admission.

The ambitious coherent design combines rows2–5 in a **small typed private-plan
interface**: ordered operations, finite field layouts, ownership modes, effects,
local continuations and explicit boundary adapters. Existing JS `JVirtual`,
`JUnpack` and typed-shape plans already preserve part of this information; the
native verifier and scalar lowering should remain shared. Prove one missing
operation at a time. Do not replace the entire IR or add another backend first.

## What reaching1× actually requires

On the frozen full corpus, ray contributes22.9% of positive excess fixed-batch
time, tree11.5%, lexer9.8%, RLE6.6%, evening6.1%, Mandelbrot5.2%, map5.2%, BST5.0%
and record aggregation5.0%. These weights depend on the existing fixed counts;
they are not estimates of application prevalence.

Uniformly making the40 still-slow points2× faster would move the geometric score
from2.144× to1.142×. Approximately2.314× across those points reaches geometric
parity. That still would not mean each program is at parity. These counterfactuals
are computed in [results](results.json), without multiplying overlapping plans.

There is stronger evidence than a speculative gain forecast: several existing
mature C products already execute near1× on exactly these sources. The work is
to recover their useful representations and control structure in QBE, then fix
the scalar code-quality differences that Clang currently repairs. Ray needs a
separate further advance. A single runtime-helper patch, larger policy search,
or another win on the already-fast list/closure families cannot establish this.

## Cost, limitations and next decision

Two serial guarded jobs took380.42s total:47.00s clean measurement and333.42s
profiles, peak32.06MiB process-tree RSS, minimum24.79GiB available. There were no
failed target runs, image acquisitions or broad rebuilds. Two agents performed
bounded offline structural/numeric audits; the root owned all target execution.
Agent token/billing cost is not available and is not inferred from wall time.
[Accounting](accounting.json) records the session snapshot separately.

Reused frozen products and independent oracles make this a cheap investigation.
Profiling establishes hot leaves, not inclusive callers or allocation counts.
No new optimization gain, self-research acceleration, N1/N2 qualification,
parallel/GPU behavior or current-upstream-head migration is claimed. Production
and the qualified Phase118 compiler remain intact.

Next decision: perform the compact editdist predicate experiment and the RLE
state-lane ceiling first. If both succeed and transfer, use the smallest common
typed private-plan extension to connect scalar values, products and continuations.
