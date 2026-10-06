# Phase59: counted work in two first requests

Both diagnostics passed complete prepared-module byte equality. They count one
ordinary first library request each for lexer and Evening, after importing the
private counter image and using its separately primed Base disk cache. No later
requests or generated benchmark executions are included. The three serial jobs
took 17.377 s including preparation and supervision; this is not clean timing.

The parent is selected last01 B2 `a73daccf…`; the insertion-only diagnostic image
is `9f57bc4191…`. The [source audit](source-analysis.md) and
[counter protocol](../../selfhost/tools/performance/phase59/counters/README.md)
describe the exact semantic entry sites. Shared SCC cases and self-loop entries
count internal tail transfers. Counts are executed source operations, not
physical allocations. Instrumentation adds overhead and is never a speed sample.

## Measured operation counts

| Operation | Lexer | Evening |
| --- | ---: | ---: |
| Complete primitive-table constructions | 711 | 2,595 |
| Primitive record literal sites executed, 90 per table | 63,990 | 233,550 |
| Primitive lookup-row comparisons | 33,799 | 201,261 |
| Row comparisons per table construction | 47.54 | 77.56 |
| Use-marker search starts | 232 | 888 |
| Use-marker input lengths summed, UTF-16 units | 41,168 | 724,028 |
| Use-marker suffix entries, including terminals | 21,118 | 192,228 |
| Other search starts | 2,517 | 7,646 |
| Other search input lengths summed, UTF-16 units | 38,977 | 231,470 |
| All nonempty `contains` suffix steps | 50,732 | 365,568 |
| All `starts_with` entries, including other callers | 82,555 | 548,926 |
| Rendered dependency-scanner input, UTF-16 units | 12,324 | 81,374 |
| Nonempty ordinary dependency-scanner steps | 11,470 | 74,227 |
| Marker-parser steps | 440 | 4,843 |
| Validated dependency markers | 46 | 256 |
| Unique outgoing dependency edges | 33 | 124 |
| Duplicate validated markers | 13 | 132 |
| `jd_definition` entries | 69 | 174 |
| Reachability definition entries | 29 | 80 |
| Component-case render entries | 0 | 16 |
| Generic substitution entries | 155,141 | 511,645 |
| Matching Var visits | 17,217 | 54,557 |
| Other Var visits | 25,003 | 76,310 |
| Nonliteral substitution rebuild entries | 109,461 | 365,305 |
| Substitution child-list entries | 135,052 | 456,318 |
| Existing stable-proof true branches, both consumers | 944 | 1,590 |
| Existing stable-proof false branches, both consumers | 709 | 994 |
| `book_put` entries | 1,743 | 1,828 |
| `index_set` entries | 4,986 | 6,159 |
| Trie `index_node` constructions | 37,487 | 44,144 |
| `index_remove` list visits | 330,722 | 376,468 |
| Retained-list construction branches in `index_remove` | 329,274 | 374,623 |
| Quantity merge left-list entries | 9,278 | 9,118 |
| Quantity get plus delete list visits | 26,270 | 25,848 |
| Quantity visits per merged left entry | 2.831 | 2.835 |

The primitive table has 90 records, 90 linked-list constructors and one terminal
Nil literal. The row count is derived from the actual selected B2 AST. This does
not imply 181 surviving heap allocations per call: V8 optimization and physical
allocation were not counted. The table and its repeated linear lookup remain a
small, concrete candidate, with especially late or unsuccessful Evening searches.

Quantity merging is not the strongest measured lead on these two inputs. Its
search/delete visits are modest compared with substitution and index copying.
This does not establish good scaling for wide independent-binder scopes.

## Strongest new lead: avoid reconstructing an unchanged String

The separate first-request allocation capture attributes Evening exclusive
weights of **251,773,488 bytes (28.03%)** to `String.contains.if$scc` and
**234,765,208 bytes (26.13%)** to `jd_reach_refs_unique$scc`, out of
898,284,512 estimated bytes. The first component contains `String.contains` and
its Boolean continuation; the second contains the ordinary scanner, marker
parser and marker completion. These are component attributions, not identified
object kinds or proofs that one member caused every allocation.

The allocation window includes import/API load plus first request, whereas the
counter window begins immediately before the request. They are separate
processes with different instrumentation. Their agreement on hot mechanisms is
useful; dividing sampled bytes by a counter to claim an exact per-operation
allocation cost would be unjustified.

There is a specific repeated shape in the exact parent B2:

```
head = original.codePointAt(0) > 0xFFFF ? original.slice(0, 2) : original[0]
tail = original.codePointAt(0) > 0xFFFF ? original.slice(2) : original.slice(1)
starts_with(head + tail, needle)
```

The actual bodies are at `compiler.mjs:594` (`String.contains.if$scc`) and
`:58685` (`jd_reach_refs_unique$scc`) in the pinned last01 emission. The scanner
also reconstructs the same head-plus-tail before dropping a known marker prefix.
Its Boolean `and` is emitted as an ordinary strict call, so the prefix test is
not implicitly skipped whenever the line flag is false.

The **hypothesis** is that repeatedly slicing, rebuilding and inspecting long
suffixes incurs substantial string construction or flattening work. Source and
generated code establish the reconstruction; these profiles do not establish
V8's exact string representation, backing-store retention, copying complexity,
or a speed gain from removing it. Input lengths are cumulative across repeated
searches, not distinct strings. Evening's 724,028 use-marker UTF-16 input units
and 192,228 suffix entries are therefore compatible with much larger cumulative
sampled allocation, without proving which mechanism accounts for those bytes.

The smallest next counterfactual is a **general String-origin rule**: when an
exact nonempty String match exposes its unchanged head and tail and immediately
reconstructs both, use the original immutable String value. This precedes a
wholesale structured-emitter rewrite as a test. It needs source-origin evidence,
not recognition of these compiler function names, and must retain demand,
Unicode behavior and the existing standard-builtins scope. Independent increasing
string-length tests, ASCII/astral and boundary cases, changed-head/tail refusals,
and actual allocation/optimized-code observations would distinguish the theory.
No such patch or test was executed in Phase59.

## Persistent book updates precede a broad quantity rewrite

The roughly 329k/375k retained `index_remove` links exceed the 37k/44k trie
`index_node` constructions. This makes generic list filtering worth investigating
before replacing the quantity representation. `index_remove` has several actual
callers: leaf collision-bucket replacement, `index_put_rest`, uncached `book_put`,
`book_final_legacy`, and the unrelated legacy worker graph path. These totals do
not independently assign every retained link to one caller.

The direct backend's `jd_selected_context` repeatedly calls `book_put`; checked
specialization and declaration processing also update books. A future caller
census or exact batch-overlay counterfactual should preserve list order, duplicate
precedence, collision behavior and cached-context metadata. Claiming that a map
alone replaces those semantics would be premature. The current counts support
investigating full-list replacement costs; they do not prove an optimal new data
structure or a removable fraction of runtime.

Substitution remains substantial. Its existing static telescope paths succeeded
944/1,590 times, so those avoided traversals must not be sold as a missing feature.
Many other visits reconstruct nonliteral nodes, but lack of a matching Var does
not alone permit returning the input: `core_rebuild` can canonicalize or perform
beta work. Audit the hot callers and reuse existing proof machinery before a
larger delayed-substitution design.

## Evidence and checks

The data-only readback checked the successful 0/1/1 request counts, exact outputs
and internal count identities: Var plus node entries equal total substitution;
literal plus nonliteral entries equal node entries; removed plus retained entries
equal index-list visits; unique plus duplicate markers equal completed markers.
No new raw report or target was written during this analysis.

| Evidence | SHA-256 |
| --- | --- |
| `counter-requests01/report.json` | `2bb01f69de98fb5dcccedf6ecd2b8b819c7339838e0927eb1d02dd8797cb9d11` |
| `counter-requests01/lexer/report.json` | `95bdc14675c2ccdea051cd188a11633927dcadfbe0957c9b43fe0e9aa5ef25d1` |
| `counter-requests01/evening/report.json` | `addd5d0e0bdd3d5dca0da9be0bb5d48477f745c2cde9238c5cad5f1a85f645d5` |
| `first-allocation01/report.json` | `9906e7510dbf4cc8d80f9c41fd0129041411585f743e02c8a58b3fa3b032078e` |
| Evening allocation `summary.json` | `afb4fe3a00d27263d507471c0f50bf117620887277551b6a6e646dd3899c05c4` |

All paths in this table are under `selfhost/build/phase59`. Exact generated
outputs remain lexer `dcb0125d…` and Evening `5fd27e63…`, matching the genuine
preparation. These two observations rank further tests; they neither establish
universal counts nor predict reaching handwritten-compiler parity.
