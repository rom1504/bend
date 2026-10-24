# Existing-stage timing changes the incremental-compilation priority

**The narrow generic-owner boundary cannot remove most compilation time on the
three real requests.** Even perfect free reuse of all generic owner lowering and
raw private-candidate preparation would remove only 13.5% of the lexer's backend
time in this hosted diagnostic. Its largest cost lies later, in optimized private
IR processing and verification. Map has more preparation headroom, but the same
two stages still cover only 33.9% of its backend.

This is a stage-ceiling investigation, not an implemented speedup or a measurement
of native N1/N2 runtime shares. It replaces an unjustified inference from owner
hit counts with measured complete-request costs.

## Method and exact-output gate

The [driver](../../../selfhost/tools/performance/phase134/reuse/stages-v02.mjs)
orchestrates **existing checked Bend exports** from unchanged
`stream-source02/compiler.bend`, SHA-256
`a7c3522a563bb4eb58d215b0f614ba4df06ef57bcd98a096c5d56e9e8cafd9d4`.
No compiler source, verifier, optimization policy or runtime ABI changed.

The acquired API exports the real source/constructor/static preparation, generic
owner lowering, candidate construction/closure, optimization wrappers, independent
final verification, borrowed-helper closure, cursor preparation and rendering.
Both original `nc_bangs_names` computations remain. Error values and all final
products are checked. The driver retains original stages rather than substituting
an inferred fast path.

There are two passes: lexer → closures → Map, then Map → closures → lexer. A single
process shares immutable Base preparation. Every one of the six full products
equals the independently qualified Phase131 native QBE byte-for-byte, including
native chunk-separator newlines:

| Request | Output bytes | SHA-256 |
|---|---:|---|
| lexer | 577,297 | `d7f319ddfe98e211951e305d692fa0190f4c2ade7cf0beb998a5e88ae7f13559` |
| coverage-closures-256 | 99,537 | `c5b9d940e875610ccb93b9ebbc8105964f16c98169ed8ead1edbcc08b0becbd7` |
| coverage-map-churn-128 | 1,028,294 | `37fd22e781e93290c2ab661c06f1991d57542f58e90d983890cebff6f7ef24e5` |

The diagnostic acquired its checked API in 13.45 s with a 2.09 GB process-tree
peak. Six requests took 35.58 s under the CPU4 guard, peaking at 515 MB. Root
authorized this diagnostic lane; this was not a clean native timing campaign.
Host retention, JIT, garbage collection, export boundaries and evaluation order
can change costs relative to the generated native compiler. Stage proportions
must therefore be confirmed natively before a speedup forecast or promotion.

## Results

The table uses the second observation of each request. Percentages divide by
backend stage time, excluding source checking, shared Base acquisition and the
host's final output join. First observations and all raw timings remain in the
receipt. For example, lexer backend time changes from 6.331 s to 4.393 s, making
JIT/order effects visible rather than treating them as optimization gains.

| Existing stage | Lexer | Closures | Map |
|---|---:|---:|---:|
| Backend seconds | 4.393 | 0.546 | 8.250 |
| Complete staged request seconds, including frontend | 5.117 | 0.879 | 9.150 |
| Static preparation | 1.2% | 2.3% | 0.8% |
| Generic owner lowering | 4.5% | 10.7% | 8.0% |
| Raw private-candidate preparation | 9.0% | 13.3% | 25.9% |
| Private open/verification | 6.1% | 12.9% | 14.4% |
| Private inline wrapper | 25.3% | 6.9% | 3.0% |
| Private range wrapper | 22.5% | 4.0% | 2.8% |
| Array final verifier | 11.8% | 8.5% | 9.7% |
| Borrowed-helper/final closure | 1.8% | 3.5% | 5.0% |
| Render context | 6.0% | 8.1% | 8.3% |
| Render pieces | 9.0% | 19.0% | 17.6% |

The listed stages do not exhaust the backend: constructor and signature
preparation, admission, certificates and assembly account for the remainder.
The whole-stage sum and request elapsed time are both recorded so orchestration
cost is visible.

`p114s_inline` and `p114s_ranges` each include `p114s_commit`, which independently
verifies the candidate private functions against retained original IDs. Therefore
their large lexer times **do not yet establish expensive transformation work**.
The open stage also checks the original static program and private functions;
the later public final verifier remains independent. These are distinct costs
that the next diagnostic should separate before proposing reuse.

## What this implies

1. Stop broadening the book-independent generic-owner memo just to increase its
   hit count. The actual edit only hits cheap primitives; even an impossible
   perfect generic cache has a small ceiling on these requests.
2. Do not build a static-body cache here: its whole existing stage costs 0.8–2.3%
   of backend time, before key checking, retention and invalidation overhead.
3. The highest-information next experiment splits private transformation time
   from the verification inside `p114s_commit`. Reuse of immutable original
   verification context may be more valuable and simpler than another body cache.
   Preserve the independent final verifier in either case.
4. An ambitious useful reuse unit should eventually include a contextually
   admitted private owner or strongly connected region **after** expensive local
   optimization. Its key must retain consumed callee bodies, types, layout,
   ownership, helper-admission and absence facts. Do not assume a Ref-only call
   graph is sufficient. Exact rebinding/global final verification still costs
   time; this is a proposed boundary, not a qualified implementation.
5. Map offers a separate sizeable candidate-preparation opportunity. First measure
   an actual edited request and prove expensive candidates can be reused legally;
   source-level namespace labels or retained candidate counts are insufficient.

These results support the Zig/Go principle of retaining useful semantic and
optimized-unit state across edits, but do not justify adopting their precise
data structures or promising millisecond Bend edits. The cheapest safe memo in
this phase selected the wrong dynamic work. The correction is to choose the next
unit using these measured costs and precise dependency obligations.

## Evidence and retained refusal

- [Raw six-request stage receipt](phase134/stages02/report.json).
- [Guard receipt](phase134/stage-guard02/process.json).
- [Checked API receipt](phase111/p134-stage-api01/report.json).
- [Reference reconciliation](phase134/stage-reference-reconciliation01.json).

The first diagnostic attempt refused before compiler execution because
`reference02.json` recorded an earlier hash of the reference-generation script.
The successful driver authenticates the immutable receipt and every consumed
source/product; historical generator identities are explicitly marked provenance.
A separate metadata-only reconciliation validates **all current creator inputs**
from `reference03.json`, and proves its source, three cases, 45 wrappers and their
products are identical to reference02. The six output identities are independently
rechecked against reference03. No benchmark source or output was redefined.
The initial refusal and both driver versions are preserved.
