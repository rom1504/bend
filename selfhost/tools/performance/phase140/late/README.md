# Initial observer reuse experiment

`core-v03.bend` is an optional, unintegrated fixed-producer in-process cache.
It replaces only the computation of `p128br_scan`, returning the same
`P128BROpen` interface plus cache state and work counts. No original declaration
is overridden. Candidate 15 passed checked API acquisition and all 32 late
controls in `selfhost/build/phase140/native-finite04/report.json`; real-request
and native cost qualification remain separate. `core-v01` is
retained as a rejected dependency-key attempt: it omitted the global scalar
specification catalogue appended to every successful observer schema.

The cache must receive the **original `NR_Request.book`**, not the rewritten
post-static book retained by `P140ORCache`. Its dependency state uses the exact
ordered source headers and fresh bound, a reverse dependency graph, and exact
`ns_body` changes for all original declarations. It additionally requires the
same ordered candidate-name list and exact global `nol_scalar_specs(book,book)`
catalogue, constructed once per request and retained in the cache. This extra
gate matters when an unrelated ADT references a changed type-alias body: the
source owner need not depend on that ADT, but its complete schema still contains
the scalar catalogue. Each clean owner may retain its initial
observer plan, eligibility result and generated workers, including refusals.

Scalar adapters retain owning fallbacks. Their key also compares the exact
first current optimized function matching `p113d_public(book,owner)`, including
absence and ineligible first matches. It deliberately does not key only on the
signature or unoptimized source. Initial helper seeds and retry list order are
reconstructed using the original operations. Retry planning, closure checks,
`p113d_passes`, and `p126bp_complete` remain unchanged.

The cache is not an authenticated artifact or proof object. Only internal state
returned by the same compiler is admissible, and the session may publish it
only after its complete request succeeds. Final structural verification alone
cannot establish semantic validity of a forged worker cache.

Version 3 explicitly combines each source declaration's references with the
references in its current `ns_body` fact, including nested fact declarations.
A source or fact change refreshes that owner's edge list; closure uses the old
reverse graph, then updates the retained graph for the next revision. This
removes the former assumption that erasure cannot introduce additional names.
Controls exercise a dependency present only in erased metadata and its later
removal. Private cache provenance and the real request's constructor/namespace
invariants still apply; arbitrary forged cache entries are not authenticated.

Dependencies: the selected compiler, Phase140 owner `core-v04`, `reverse-v03`,
`raw-v01`/fact-change helper, and existing `p134v_function` exact comparison.
`p140l_scan(book,names,original,previous)` returns
`P140LResult{scan,cache,[hits,misses,dirtyCount,analysisReady]}`;
`p140l_empty()` creates the cold state. `controls-v04` contains 32 finite
controls for cold and edited requests, candidate order and fresh-bound refusal,
transitive invalidation, fallback changes/absence, duplicate-name order, and
every global scalar-specification field. The catalogue controls directly
exercise the unrelated-ADT/type-alias dependency that invalidated version 1; additional controls cover hidden erased references.
`emit-v01` preserves the original
verified-emission branches and retains the previous cache on any error.

The decisive next measurement is an independently fresh initial scan versus a
cached scan on the real edited Lexer and Map requests: deeply compare the entire
returned `P128BROpen`, charge dependency checking and cache reclamation, then
compare complete final QBE bytes. Only after those pass should an integrated
native full-compiler replay measure how much of the remaining 35-second backend
time this actually removes. High hit counts alone are not a speed claim.

Retry caching is deferred: it additionally depends on the complete helper
context and current owning fallbacks. This first implementation does not assert
that initial scans dominate either retries or the independent final verifier.

`screen-v02.mjs` also compares the optional emission wrapper with fresh complete
outputs and tests its error/cache-publication path. The host script orchestrates
and compares values; semantic preparation, transformations, cache decisions and
verification all execute through the independently checked Bend API.

`session/backend-v02.bend` is the optional integration: it retains a separate
late cache in `P140BCache`, appends four late counts to backend stats, and uses
`p140le_verified` only after the original array-validation boundary. It is not
a production selection or a qualified image by itself.
