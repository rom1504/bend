# Editdist regression: missing array authority and local composition

This bounded offline audit compares the exact Phase152 and Phase169 checked
editdist products named by the root. `editdist-quality-audit.json` pins both
complete IRs, machine reports and assembly, and confirms identical source and
linked runtime hashes. No target was run and no candidate was edited here.
The approximately19× execution regression is the root's current screen result;
the static audit does not independently reproduce that timing.

Two lost capabilities are concrete. The old descriptor has capabilities15,
the candidate5: scalar-array bit2 and constructor-cold bit8 disappeared.
There are151 constructors in both products:18 cold before, zero now. Both
products still have71 direct functions. The candidate's smaller code is therefore
not evidence that its hot computation became better optimized.

| Actual function | Phase152 | Phase169 candidate |
| --- | --- | --- |
| `$product.row` |64,067B QBE; inlined cell computation and versioned array fast path, retained `p117v` fallback |6,048B; calls `$product.cell` |
| `$product.cell` |49,818B; complete four-read/one-write computation present |2,777B; one array-pair operation, then calls `cell.f1` |
| `$direct.init` |3,781B; versioned array fast path and retained fallback |2,359B; runtime operation every iteration |
| `$direct.gen` |8,153B; inlined PRNG and versioned array fast path |3,361B; calls PRNG and runtime array operation |

Old `$product.row` assembly has182 lines and25 `movl` sites; the new body has63
lines and4. Those are static shape facts, not instruction-frequency estimates.
The fixture computes four independent256×256 DP grids; its cell chain runs
262,144 times at the small setting. Losing the composed inner-loop array path
is therefore a credible large cost mechanism, unlike unrelated static code size.

## Exact pipeline boundaries

`selfhost/tests/phase169/streaming.bend:p169s_seeded` chooses renderer mode0 or1
solely from whether direct functions exist. It never computes the actual
`p113a_certificate(request)`, never selects mode2 and never calls `p117p_tables`.
Maintained `stream-emission.bend:p134e_admitted/p134e_prepare` instead derives
the enabled state from `P113ACertificate{scalar,unshared}`. Mode2 selects
`p126i_catalogue` and `p126i_emit_one`, exposing array templates and loop versions;
`p117p_tables` establishes the corresponding scalar storage ABI. Mode and table
bit must be restored together from the same actual authority, never by forcing
the observed old descriptor value.

The certificate is `ns_definitions(book,names)` plus guarded
`nr_unshared(book,names)`. Its successful source predicate alone does not replace
the maintained final-program namespace/template obligations:
`p113a_verify_after` checks reserved array locals, and the existing transport
checks remain relevant. The certificate-threading owner has been notified.

Separately, `early-scalars-selective.bend:p168t_walk` preserves ordinary
non-target function bodies and adds only already leaf-clean ones to its table.
Mature `checked-boundary.bend:p114s_inline` applies bounded `p113i_functions`;
its `p113i_function_done` also applies scalar cleanup. Consequently candidate
row→cell→cell.f1→cell.f2→cell.f3→cell.f4 calls survive. Renderer mode2 can optimize
the array operations it sees but cannot by itself inline this function chain.
This is a distinct limitation to measure after the certificate-only treatment.

Finally, the Phase168 request entry bypasses `p167l_start`'s source-derived
`p118c_plan`/constructor classification. That explains the missing18 cold flags.
It is real for this workload, although the full compiler's original cold count
was zero. Keep cold authority separate from array authority and from current
certificate-only measurements.

## Cheapest falsifiers

First use the existing hosted checked API to restore only actual array-certificate
threading, original namespace/transport obligations, matching table flag and
renderer mode2. Preserve the import-seeded region registry, final verification
and original mode1 fallback. Emit editdist, build with the identical runtime and
run its existing independent oracle before any new compiler image acquisition.
Expect array templates and init/gen loop versions to reappear; record whether
row is still staged and whether execution recovers materially.

If the cell chain remains costly, a second separate treatment can apply the
existing bounded `p113i_function` to ordinary nonblocked bodies and publish the
cleaned functions into the existing inlining table. Keep observer seeds and
retry-owner protection exactly as in the selective policy; broad early inlining
previously embedded stale owned helpers. This restores local composition where
the policy currently returns `head` unchanged, without restoring the entire old
global pipeline. Its actual transformed functions still need the original
verification and output gates.

Only afterward consider restoring the source-derived cold plan. Neither the
array fix nor the inliner should use editdist names or workload-specific gates.
The mature whole-program array certificate is a general semantic category and
legitimately false for the full compiler. Correct generated output alone does
not qualify the currently much slower editdist product for promotion.
