# Phase41: faster tree programs and shorter validation

**Phase41 checked01 is installed and verified.** The upstream target remains
`018751270e800bc222a93dad7f257083ee53a5f7`. Final integration passes 15/15 audit
groups, all 227 canonical sources match, and all 42 ordinary/relocated CLI checks
pass. This is a checked B1 derivative, not a new self-emitted fixed point.

| Metric | Result |
|---|---|
| Generated tree execution | **1.51–1.59× faster** than fresh Phase40, three changed points, five rounds |
| Remaining tree gap vs TypeScript | **9.33–12.18× slower** on those points |
| Other benchmark outputs | **42/45 byte-identical**; three retimed unchanged controls |
| Compiler request cost | Tree **+9.46%** median; other three sources show no clear regression |
| Frontend validation elapsed | **13m42s → 7m17s**, historical comparison; same 3222 observations |
| Compiler source | **+35 physical lines / +4 definitions**; runtime, types and modules unchanged |

The tree improvement removes generic dispatch through a small nonrecursive
wrapper around an already admitted recursive worker. It reuses the typed graph
proof, dependency guards, tagged values, fallback and structural frame engine.
It introduces neither a new intermediate representation nor a runtime feature.
Every changed tree point wins all five paired rotations with disjoint ranges;
within-process drift remains visible in the [canonical results](results.md).
This is a scoped improvement, not a catalog-wide or typical-program speed claim.

The tree compilation increase is an explicit accepted tradeoff of roughly 213ms
per measured checked request for33.6–37.2% less generated execution time.
[Admission](performance-admission.md) records the exception to the prospective
blanket regression rule. The compiler itself is not faster as a result.
Four normal checked source requests remain 4.63–7.73× the TypeScript request time.

The private transfer-tuple prototype was **rejected**: corrected controls passed,
but 0.23–0.40% timing shifts were smaller than baseline noise. The lexer proposal
was **deferred** after a String host-hook counterexample showed missing proof
obligations. These negative results and every failed fixture/tool attempt are
preserved; only the tree patch reached production.

Conformance observations remain unchanged:3026 main +196 broader exact frontend
agreements, including four shared main failures; backend pilot69pass/8not
applicable/4shared failures. New wrapper, inherited owner, expanded application,
mutation, reentry, order, alias and deep-stack checks pass. Counts overlap.
Full backend/GPU and independent proof validity remain unestablished.

The mixed-agent investigation used Sol6.1 for implementation/planning and Luna
for evidence/profile work and fallback review. Root serialized heavy jobs under
memory/deadline bounds. [Accounting](accounting.md) separates observed process
intervals from unclassified wall time; it does not infer model latency or causal
agent speedup. The actual checked-build-to-screen interval was3m23s. The reusable
portable fast-five preset completes in17s. Broad validation ran once after the
candidate was frozen.

Start with the [20/60/300/600-second run guide](../../selfhost/tools/performance/phase41/README.md).
The [design](../../design/phase41/README.md), [experiments](../../experiments/phase41/),
[tree implementation](tree.md), [integration](integration.md),
[validation](validation.md), [profiles](profile-findings.md),
[independent review](final-independent-review.md), and [closed evidence](evidence/README.md)
provide the detailed evidence. Next, profile the compiler's repeated graph
analysis and the remaining tree runtime hotspots before extending admission or
starting another broad backend rewrite. No PR comment was posted.
