# Phase119: refreshed profiles after ownership and transport improvements

**There is enough evidence to optimize again.** The remaining costs divide into
numeric representation/identity losses and construction/lifetime/runtime-boundary
work. Repeating the broad multi-backend survey is not the next step. The new
profiles also show that register clearing has largely ceased to be the target:
all sampled libc PCs in the current programs and compiler request are copying,
with no samples in the authenticated fill implementation.

This phase changes no compiler, runtime, benchmark definition, qualified image
or installed selection. It starts at `6315f14`, reuses Phase118 products and
preserves the original whole45 generated-program score of3.00893× upstream.
The focused six-program aggregate below is a different diagnostic population.

[Design](../../design/phase119/profile-refresh.md) · [Exact results](results.json) ·
[Numeric source/machine audit](numeric-audit.md) ·
[Reproduction](../../selfhost/tools/performance/phase119/README.md) ·
[Evidence capsule](evidence/summary.json).

## Controlled comparison

Six unchanged source fixtures run on current QBE118, mature selfhost C102 and
pinned upstream C. Retained C products use their original Clang-O3 build policy;
current QBE uses its selected runtime-extend01. The exact safe03/float01 QBE
bridge authenticates reuse of the hosted-produced program binaries. This is
not a new N2-produced batch-runtime qualification, nor an isolated experiment
changing only QBE versus Clang.

Three rotated clean rounds use four times the original repetitions and32
warmups, matching the earlier Phase116 diagnostic method. Timed intervals exclude
process startup. Sampling runs do not contribute to these medians.

| Program | Upstream C ms | Mature selfhost C ms | Current QBE ms | QBE/upstream | C/upstream |
| --- | ---: | ---: | ---: | ---: | ---: |
| Scalar loop8192 | 201 | 207 | 429 | 2.134× | 1.030× |
| Active ray256 | 201 | 688 | 1703 | 8.473× | 3.423× |
| Lexer | 186 | 199 | 832 | 4.473× | 1.070× |
| Tree | 201 | 271 | 963 | 4.791× | 1.348× |
| List pipeline128 | 198 | 137 | 677 | 3.419× | 0.692× |
| Map churn128 | 200 | 126 | 720 | 3.600× | 0.630× |

Six-case geometric ratios are QBE4.10290× and mature C1.14186× upstream.
These are selected difficult workloads, not a regression from the broad3.01×.
Mature C supports substantial recoverable headroom on five cases, but its own
ray deficit shows that copying its existing strategies cannot establish parity.
JavaScript profiles remain historical Phase116 evidence; no new JS claim is made.

## What the current program profiles establish

Thirty-six unchanged-program captures use8ms and13ms periods, scaled to about7s.
Every capture has zero drops/overruns and more than99.97% recorded process CPU
coverage. Unsized QBE symbols end at the next text symbol, explicitly inferred.
Shares below pool both periods and describe physical instruction leaves, not
inclusive source functions or allocation counts.

| Workload | Current sampled bottleneck | Consequence |
| --- | --- | --- |
| Scalar | 100% in `mit`; no calls in the hot loop | Ownership and runtime-helper work cannot explain the2.13× gap. |
| Ray | isect41.8%; nearest21.9%; nearest.t8.4%; trace10.6%; generic op10.9% | About72% lies in the intersection/nearest family; inspect numeric regions and their boundaries. |
| List | destination fill21.7%; take2 20.8%; extend1 17.1%; ctor2 7.4% | About59.5% in the first three helpers; remove intermediate construction, rather than indefinitely optimizing individual helpers. |
| Tree | ctor2 14.6%; take2 13.6%; take1 4.4%; libc copy8.2% | Constructor/field/lifetime work remains material after the transport win. |
| Lexer | take2 9.0%; copy9.7%; work loop5.8%; jump5.3%; register transfer5.0% | Both representation and fragmented runtime transitions remain; no single library function explains the gap. |
| Map | copy17.1%; borrowed fields8.4%; generic op6.6%; register transfer5.6%; jump4.9% | Borrowing removed some ownership work, but still crosses generic field-copy/control boundaries. |

The exact libc hash and disassembled implementation ranges are retained in
[results](results.json) and [copy/fill assembly](libc-copy-fill.asm). Lexer138,
tree117, list12 and map242 library samples all fall in the copy implementation.
There are no current fill samples in these captures. That does not establish
zero executed clears, identify all copy callers, or justify calling copying
allocation. It does invalidate treating the old large fill share as current.

The runtime's destination-fill helper still validates the private destination,
finds its field, checks the hole and stores/seals its result. Its sampled share
is not all removable checking. Phase118's cursor experiment already showed that
an apparently simpler destination representation can yield only a tiny gain.
Fusion is a different hypothesis: avoid constructing the temporary in the first
place, with strictness, sharing, effects, lifetime and stack-safety gates intact.

## The numeric audit makes the next tests concrete

The central ray workers and scalar `mit` emitted assembly are unchanged from
the old Phase114/117 products after local-label renumbering only. The fresh
profiles establish that these same regions are still hot.

1. **Signed-word identity recovery is missing, not arithmetic-shift support.**
   Both our IR and QBE already accept `sar`. Independent lowering of logical
   shifts, comparisons and sign-fill selection loses a useful word identity.
   The inspected loop retains97 instructions versus upstream38, with no calls
   or stack accesses inside the iteration. Test a general reaching-definition
   recognizer preserving low32 bits, exact sign-fill constants, Boolean polarity
   and U32 zero-extension. Keep the full-Nat shift guard where required. This is
   the smallest decisive next experiment; static counts do not predict its gain.
2. **Ray needs a preserved numeric region, beyond a typed calling convention.**
   Intersection still has49 integer/float register moves and a2072-byte frame;
   nearest functions have still larger frames and repeated boundary conversions.
   Prior ABI-only prototypes improved active ray12.77%, so they do not promise
   parity. Compare ABI-only with a bounded intersection/nearest region preserving
   typed locals and exposing exact simplification across calls.
3. **Upstream exposes an additional capability: packed arithmetic.**
   Its larger `spin_22` body contains SIMD arithmetic absent from the inspected
   mature-C and QBE hot functions. Those static sites do not measure vectorization's
   benefit. Merely merging scalar QBE regions cannot be assumed to recover SIMD;
   that is a separate capability question, after demonstrating scalar region gains.

The [audit](numeric-audit.md) records exact lowering points, identities, controls
and cheap falsification criteria. Do not revive generic dead-scalar cleanup:
Phase118 made the loop longer and8.05% slower despite shorter QBE text.

## The native compiler now has a different cost distribution

An identical ordinary lexer-scan source/cache request runs on qualified N1
Phase114 and Phase118. Each run must reproduce its image's independently frozen
complete QBE output, not just a checksum emitted by the candidate. Four profiles
per image alternate8/13ms; two unprofiled observations bracket them.

| Metric | Phase114 N1 | Phase118 N1 |
| --- | ---: | ---: |
| Clean request observations | 2.680s,2.689s | 1.892s,1.890s |
| Pooled physical samples | 1085 | 758 |
| `term_drop` | 14.6% | 17.7% |
| `span_fade` | 9.2% | 10.4% |
| libc fill | 15.0% | 0 sampled |
| libc copy | 4.7% | 8.0% |

The median request uses29.6% less time in this small check. Two observations and
one request are not a replacement for Phase118's three-source N1/N2/upstream
screen. Destruction/reclamation now accounts for28.1% of leaves, but its increased
percentage does not mean its absolute cost regressed: the total request is faster.
There are additional extraction, constructor, borrowed-view and control leaves.

For compiler throughput, prioritize reducing temporary structures and associated
lifetime work. Duplicate analysis and discarded C residual construction remain
source-level opportunities, but these leaf profiles do not attribute their
inclusive cost. Before selecting a large compiler refactor, connect one such
producer to the measured lifetime work with a bounded stage/caller experiment.
Do not claim the profiles prove an analysis cache would pay off.

## Recommended order and research cost

1. Try the exact signed-word identity in the allocation-free scalar kernel;
   require better machine code and transfer to an unrelated numeric program.
2. Test a bounded typed numeric region against the prior ABI-only strategy.
3. Test elimination of one ordinary intermediate list, then a separate text/tree
   pipeline. Keep the general fallback and independent outputs.
4. For compiler throughput, attribute one temporary-structure producer before
   changing analysis reuse or representation globally.

No further broad survey is needed before these experiments. No parity prediction
is established. General capability and transfer matter more than improving one
ray benchmark or deleting checks without proof.

All102 observations independently replay, including54 clean program runs,
36 sampled program runs and12 compiler requests. All44 profile analyses are
recomputed;27,493 samples remain after zero-loss checks. Individual compiler
captures are short, so their samples are pooled across four runs per image.
Program pairs each have ample samples. No failure or rejected run is omitted.

Three serial guarded jobs cost313.254s total (5.22min), peak82.64MiB process-tree
RSS, minimum available memory24.86GiB. There was no rebuild, image acquisition,
full45 rerun or installed promotion. One reused agent performed a bounded offline
numeric audit; only root ran targets. Total research wall time also includes
reading, analysis and reporting; these execution clocks do not measure model
cost or quota. The small evidence capsule preserves raw samples, outputs and
receipts while leaving large frozen artifacts in place.
