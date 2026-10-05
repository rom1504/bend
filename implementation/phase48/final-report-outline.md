# Phase48 final report assembly

This is a reporting checklist, **not a release or performance qualification**.
RNFA04 is the intended final candidate. Use its final receipts to replace pending
statuses in the release summary; do not infer completion from a successful build
or from RNFA03's byte-identical corpus output.

## Lead with the final measured result

The primary comparison remains 45 points, 23 sources and 669 fresh samples, with
the pinned TypeScript compiler and a fresh array06 baseline. Report all three
geometric weightings, before/after ratios, wins/regressions/ties and the largest
remaining gaps. **Those aggregate values are pending.** Run the reviewed renderer
only after the complete summary exists; preserve every point in `results.md`.
Keep finite, corpus-informed coverage distinct from universal language coverage.

Report one installed compiler identity only after installation and portable
verification actually pass. The intended API is
`6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100`; runtime remains
`880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.

## Explain the changes using their evidence

| Combined slice | General mechanism | Evidence to carry into the report |
| --- | --- | --- |
| R: composite results | Preserve public array handles while adapting a proved private aggregate result | [Composite result report](composite-results.md); the provisional generic-row point improves 13.431× with its complete four-array oracle |
| N: native values | Emit proved native String operations directly inside the private worker | [Native-value report](native-values.md); keep isolated Unicode results separate from final aggregate |
| F: finite F32 literals | Replace private finite literal decoding with an exact dyadic value while preserving the shared DataView write | [F32 report](private-f32-literals.md); 408 source-value observations, 17 boundaries, lower-level bit checks and actual corpus counters |
| A: typed arrays | Shared typed operation facts, guarded literal handles and bounded profitability checks | [Typed-array report](typed-array-effects.md), [literal handles](literal-array-handles.md) and [RNFA04 scaling checkpoint](rnfa04-checkpoint.md) |

The integrated R slice means the handle-preserving composite-result adapter, not
the unselected private tuple-transport experiment. The V transport and H function
flow prototypes remain separate, with their failed, neutral or narrow results
preserved. Do not present investigated concepts as selected implementation.

The normalization-cost failure also belongs in the findings: RNFA02's expensive
eager normalization was corrected before RNFA03 acquisition. It motivates bounded
planning and shared facts; one corrected acquisition is not evidence of improved
general compiler throughput.

## Keep costs and regressions visible

The [RNFA04 accounting](accounting.md) records +406 physical lines, +314 code
lines, +51 definitions and six new modules. The runtime is unchanged. Summed
bytes across the 24 distinct source/output pairs increase 0.72%; 16 of 45 point
outputs change against array06. All 45 primary outputs are identical to RNFA03.

The independent literal screen retains zero/one-trip overhead of **30.63% and
18.64%** despite large-input gains. Do not say the tiny-input problem is fixed.
The [compiler-request screen](compiler-cost-final.md) records **3.27% / 4.41%**
median regressions on Evening/lexer. It covers two sources, not the compiler's
own build or all corpus compilation. Separate import, request, process and
preparation costs instead of presenting one as another.

## Qualification and publication joins

Attach exact final semantic/controller receipts without adding heterogeneous
counts into a fabricated conformance total. Source-value tests, IR laws,
host-mutation observations and activation counters establish different things.
Keep preserved fixture-checker failures and reporting corrections visible.

Final runtime, backend/frontend qualification, installation, CLI smoke and
portable replay statuses must come from their own final receipts. Publication
follows the [existing plan](publication-plan.md): verify exact current/reference
bundles, close writers explicitly, then archive the raw evidence and publish a
verified index. Historical Phase45–47 evidence remains read-only.

Campaign time and resource accounting should name its cutoff, sum measured jobs
without nesting duplicates, and leave unattributed elapsed time unclassified.
Source/output accounting and the cost screen are already complete; final timing,
release status and archive references are pending at this outline's cutoff.
