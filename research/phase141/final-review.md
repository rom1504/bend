# Phase141 final independent review

Source and receipt review only: no compiler execution, builds, benchmarks or
production edits. Candidate:
`selfhost/build/phase141/integrated-source02/compiler.bend`, SHA256
`f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`.
Reviewed against Phase140 source18, parser `deletion-v01.json`, static-family
`contract-v02.json`, the earlier independent reviews, and the first-hour report.

**No new source-semantic blocker found.** The proposed remaining gates can
qualify this exact image's ordinary native route on the frozen regression
corpora. They do not establish full language conformance, prove the refactors,
or promote the Phase140 incremental interface. Keep installed Phase137 intact
and identify incremental results separately as experimental.

## Source and public-interface boundary

The earlier parser and comparator reviews remain applicable. Source02 corrects
template declaration order; it does not introduce another parser algorithm or
comparator policy. Independent declaration comparison of the actual source02
still finds all108 published driver roots and all227 contract-protected
declarations byte-identical to the parent. The retained proof inventory is
unchanged. These are exact source checks, not a proof of compilation correctness.

The compatibility boundary is deliberate: `f_tops` and `f_top` remain, while32
internal parser definitions and17 associated forward declarations disappear.
`p134v_list` becomes a closed-template helper rather than a runtime-callable
private function. Neither change promises compatibility for arbitrary historical
tools exporting undocumented internals. The current published roots remain the
supported interface. Retained forward type laws and existing `@unsafe` parser
definitions must not be presented as new semantic equivalence theorems.

Static specialization preserves the audited fields, variants and comparison
order. Its finite controls use independent fixture truth tables, rather than
comparing a canonical function to itself after renaming. The remaining native
concerns are specialization/code growth and stack behavior, not an identified
source mismatch. See [parser review](parser-review.md) and
[static-family review](static-family-review.md) for the exact contracts.

## What the existing receipts establish

| Evidence | Supported statement and limit |
|---|---|
| `phase141/parser-corpus02/report.json` |1,739 exact parser-result comparisons:865 successful parses and874 identical rejections. Five further inputs hit the hosted stack limit in both versions and are untested. Matching a contextual or unsupported-source rejection is compatibility evidence, not successful upstream conformance. |
| `phase141/parser-checkpoint01/report.json` |48 independent checkpoint/edit/error/recovery comparisons. This establishes the tested hosted behavior; it is not arbitrary-edit soundness or native recovery qualification. |
| `phase141/family-finite01/report.json` |19 control rows, including501 ordered record-pair comparisons and list checks. Finite evidence plus the source bridge, not a universal comparator theorem. |
| `phase111/p141-integrated-api02/report.json` |Checks the controls-added API source `e0d346c…`, not the exact native source `f5bfca6…`. The separately planned exact-source API certificate is needed for native qualification. |
| `phase111/p141-integrated-full45-02/report.json` |Completed45/45 compilation, build and exact-output passes through integrated **N1**, SHA`61b59e6a…`. Its own scope correctly says it does not alone establish a self-host chain. Final N2 coverage remains a separate gate. |
| `phase141/integrated-pairs01/report.json` |Four alternating rounds on three compiler requests,24 observations, with exact QBE checks. This measures compiler-request latency, not generated-program runtime across45 workloads. |

The first-hour report already distinguishes its earlier six-case screen from a
full45 invocation, preserves the stack/checker negatives, and identifies its
full-request timing as one ordered pair. Those qualifications should survive the
final summary. Its parser-only image results do not by themselves qualify the
combined parser/static image.

## Assessment of the proposed native qualification

The revised plan is proportionate if every receipt binds the exact candidate,
Base/carrier, runtime, producer and machine-build policy:

1. Check the exact native source independently, retaining the separate
   controls-added API and its source bridge. A frozen source-only manifest may
   correctly retain `checked:false`; the qualification receipt should link the
   later actual certificate rather than rewrite that historical manifest.
2. Run the focused19 gates through N1 and N2, and the frozen45 through final N2.
   State the actual sets and any overlap; they are not automatically64 distinct
   programs. These are frozen regression gates, not a new full-conformance census.
3. Have N1 compile the same source to Q2, compare Q1=Q2 exactly, and build N2
   using the authenticated runtime/toolchain. This establishes same-source output
   reproduction by N1. Running N2's gates establishes N2 behavior on those gates;
   it does not establish N2→Q3 self-reproduction unless that emission is also run.
4. Keep the actual incremental edit experiment separately scoped: bind both
   source revisions, compare each warm product to its independent fresh product,
   and retain cold acquisition/reuse cost. A successful edit and output match do
   not qualify all parser/checker/cache invalidation classes or native error
   recovery. Existing Phase140 unsupported-edit and trusted-cache premises remain.

Reusing `V.emission`, `V.coverage` and `Q.build` authentication is preferable to
inventing weaker gates. The initial `mandelbrot` selector failure was orchestration
failure before targets, not a compiler failure or a passing coverage result;
the completed corrected invocation is the one to cite.

## Claim limits to retain

Exact QBE with the same runtime and machine-build policy supports unchanged
generated code for those particular products. It is not a fresh broad runtime
speed measurement. The compiler executable itself changes, so its execution
cost still requires measurement even when its outputs match.

Native QBE gates and unchanged published roots do not establish newly measured
JS/C backend conformance. If those routes are not rerun, describe their source
interfaces as preserved and report that backend-specific qualification was not
part of this cycle. The frontend comparisons provide useful shared evidence.

The comparator subsystem's220→83 code-line reduction is2.65× for that family.
The integrated source removes828 physical/606 code lines from the experimental
Phase140 source, including76 test-helper code lines. It is about1.3% of that
compiler, not a2–3× whole-compiler simplification or a reduction relative to the
smaller installed Phase137 image.

With these boundaries, ordinary native qualification is an appropriate claim
once its remaining receipts complete. “Fully conformant,” “proved equivalent,”
“all backends qualified,” or “incremental mode production-ready” would exceed
the reviewed evidence.
