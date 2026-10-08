# Product transport and occurrence reuse: checked checkpoints

**Products10 passes focused correctness checks, but its intended product workers
do not activate in the three diagnostic programs. Reuse11 reduces repeated
occurrence analysis while reproducing all three complete C outputs.** These
are development checkpoints; the installed Phase67 release remains separate.

The [compact evidence join](evidence/product-and-reuse-controls.json) records
the observed results and repository-relative input hashes. Its collection read
source and existing reports on CPU0; it ran no compiler, Clang or generated
program. The [dedicated reuse audit](evidence/occurrence-reuse11.json) retains
the complete helper and C-equality provenance.

## Products10: correctness and activation are separate gates

Actual checked B1 `c0f4eace…` passes strict checking. Six selected native fixtures
agree exactly with the pinned upstream compiler:

| Fixture | Independent output | Main boundary exercised |
| --- | --- | --- |
| Aggregate tail swap | `1007006` | Ordered aggregate arguments across a tail call. |
| Captured array callback | `29` | Callback capture and array ownership. |
| Array product return | `2917` | Returned array/value pair consumed by another function. |
| Record product return | `1131` | Named record producer and consumer. |
| Shared matcher residual | `"keepkeepkeepkeep"` | Sharing across a matcher. |
| Prefix scratch scopes | `7071122` | Multiple allocating values with private C scratch names. |

A seventh fixture returns `1831`: one branch discards a fresh owned product;
the other reads both array fields. Its retained C contains the original
`drop_product_branch68` entry and no private
`$product.drop_product_branch68` worker token. Eighteen actual-image demand
decisions also pass. These finite controls exercise the ownership guard; they
do not prove general ownership correctness or establish that positive cases
use an unboxed path.

The saved-C activation audit finds:

| Program | Ordinary workers | Defined product workers | Reachable product workers |
| --- | ---: | ---: | ---: |
| Numeric | 14 | 0 | 0 |
| Array | 17 | 0 | 0 |
| Lexer | 26 | 0 | 0 |

The strong array mechanism check therefore fails with “no entry-reachable
product hot worker.” This is useful negative evidence: passing outputs alone
would have hidden that the optimization was inactive. The audit follows
selected host edges and excludes preserved device fallbacks, though structural
reachability is still not proof of runtime branch execution.

Actual compiler introspection shows the array loop's applied `Pair` type
receiving an `Absent` layout/signature from the bounded syntactic query. That
identifies an activation barrier to investigate. The diagnostic intentionally
stops after capture; its `PRODUCT_DIAGNOSTIC_CAPTURE_COMPLETE` result is not a
successful program compilation. The short array screen is 125/124 ms for
Products10 versus 116/117 ms for working09 on the same work. It establishes no
runtime gain and is not a balanced performance estimate.

## Raw controls: two instrumenter failures, then twelve passing rows

The frozen raw suite compares working09 (`8894d861…`) with Products10. It covers
first-error precedence, an unused deliberately mistyped product argument,
immediate let chains, overridden and partial primitives, and shared-error
checkpoint placement. Native rows run with one and four CPU threads; the
checkpoint derivative mocks error observation on CPU and does not test a GPU.

| Retained attempt | Outcome | Cause and correction |
| --- | --- | --- |
| `products-raw10`, controller v5 | Incomplete after five rows | Substring matching counted `INLINE` inside `NF_INLINE` as a second worker. |
| `products-raw10-v2`, controller v6 | JavaScript parse failure; no execution report | An extra closing bracket prevented the controller from starting. |
| `products-raw10-v3`, controller v7 | All 12 report rows pass | Whole-line worker matching, separate ordinary/product body scopes and descending-offset marker insertion; the extra bracket was removed. |

Both failed attempts remain preserved. No production compiler correction was
made for these instrumentation failures. The final controller passed Node's
syntax check before retrying. Future JavaScript controllers need that cheap
parser gate before source-review approval; text inspection missed this error.
The final twelve rows retain the original outputs, diagnostics and checkpoint
oracle rather than weakening them to accommodate either failure.

## Reuse11: less analysis, identical emitted code

Actual checked B1 `3612aaae…` passes strict checking. The source change adds six
lines and no functions or types. Four existing boxed-binding paths reuse one
body-occurrence summary for liveness, sharing and ordered drops. A value's
second partition is skipped only after filtering its environment to live
bindings. Product substitution and dependency-call metadata remain unchanged.

The actual Products10/Reuse11 comparison passes **3,520 complete lowering-result
pairs**, plus **four product metadata/bundle cases**, in 2.53 seconds. Equality
includes emitted statements, segment order, fresh identifiers, diagnostics and
dependency calls. Cases include repeated environment entries, full-width IDs,
malformed raw terms and nested lets in both values and bodies. Instrumentation
records:

| Collector calls in the finite helper matrix | Products10 | Reuse11 |
| --- | ---: | ---: |
| Original body | 7,360 | 3,880 |
| Original value | 4,640 | 2,640 |
| Total, including nested lowering | 15,544 | 9,350 |

The total is about 40% lower **for this matrix**, not a prediction of whole
compiler speed. The observer appends exports and counters to the exact compiled
image; it leaves the generated algorithm prefix intact. The source inventory
differs only at the two declared proposal files. Comparisons use ordered
environment partitions, not structural equality between internal occurrence
indexes.

Fresh numeric, array and lexer C emissions are each byte-identical to the
runtime-qualified Products10 outputs. The audit binds the actual selected API,
recipe, guarded command and full C bytes independently of the root's compact
success report. This supports reusing those three native output observations.
It does not qualify genuine B2, broad conformance, other programs, or a release.
Single-request clocks suggest a smaller compilation cost, but balanced B1/B2
timings remain a separate gate.

The next product experiment needs an active-path witness before a long runtime
comparison. The next reuse experiment can keep complete-C equality as its cheap
first discriminator, then measure actual compilation latency separately.
