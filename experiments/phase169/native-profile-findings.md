# N2 canonical compiler profile: remaining work

Offline inspection only. The accepted `native-n2-profile01` capture has 5,484
samples at 32ms, 99.35% main-thread/process-CPU coverage, zero loss/overruns and
exact complete QBE output. It records 176.644s process CPU / 176.863s sampler
wall time. Symbol resolution covers 95.42%; unknown samples remain in every
denominator. Data and exact inputs are in `native-profile-findings.json`.

## Physical observations

The retained Phase161 full-source capture used the same canonical input and
32ms period, but a different compiler/runtime image with extra active-context
and stage instrumentation. Its 7,452 samples / 239.862s diagnostic process CPU
are useful historical context, not a matched clean timing comparison. Differences
in inlining also move instructions between helper symbols.

| Disjoint physical leaf family | Phase161 | Current N2 |
| --- | ---: | ---: |
| `term_drop` + `span_fade` |17.50%|18.34%|
| `p111_rt_sink` |3.64%|4.01%|
| Constructor takes, including old `ctr_take` |11.97%|10.98%|
| Constructor-building helpers |3.96%|4.80%|
| `p111_rt_keep` + `rfc_wrap` |2.43%|2.28%|
| Work loop + register/jump/return/frame helpers |11.27%|8.59%|
| All `p88_string_eq` named worker variants |6.54%|9.50%|
| `String.cmp` named worker variants |2.24%|1.86%|
| `index_hash` named worker variants |2.67%|1.66%|

The first five families total **40.41%** now. This is physical time in lifetime
and product operations; constructor helper names do not prove fresh allocation.
The single hottest named compiler worker is the existing borrowed
`p88_string_eq_go` reader: 467 samples / 8.52%. `term_drop` is 10.61%,
`span_fade` 7.73%, and the work loop 2.66%. These are not dynamic call counts or
inclusive caller costs. In particular, the higher equality fraction does not
establish a regression: the entire denominator changed, and there is only one
capture per treatment.

Named leaves in `p128bs_*`, `p128br_*`, `no_emit*`, `p168*`, `p169*` have **zero**
samples; `p167*` has three, `p113pl_*` five, `p112c_*` ten, `p112r_*` fifteen,
and `p111v_*` twenty-seven. This does not establish negligible algorithm cost.
Shared helpers and 289 anonymous-continuation samples hide their originating
caller. No current active-owner/stage bridge was collected. Therefore this
profile cannot defensibly name a hottest semantic compiler stage. The strongest
visible cross-stage mechanism remains name/value processing and term lifetime.
Phase161's authenticated stage evidence located substantial time in rendering,
checking, candidate construction and verification; those old stage intervals
must not be assigned to the new architecture.

## Two worthwhile work-elimination hypotheses

**1. Verify unchanged direct bodies once; check only the renderer ABI delta.**
The duplication is concrete: `streaming.bend:62` runs `p167ob_final`, whose direct
gate calls `p118b_verify_functions`. `streaming.bend:49` then calls that full gate
again after `p168v_functions` changes only public flags, preserving names,
parameters, results, body objects and order. `ownership.bend:256` reconstructs
original IDs/constructor maps, projects all borrowed bodies and runs the full
direct flow verifier on each call. `verify-direct.bend:182` shows the additional
public-header ABI obligation separately from the unchanged body flow.

A private successful-check continuation can retain the immutable original body
list and actual IDs, construct the same public view, and independently check the
exact public-wrapper/header condition. No external Boolean/hash certificate,
fake headers, body mutation or reduced original admission is permitted. Audit
that dependency validation never observes the changed public flag; keep malformed
header/adapter/private-worker controls and exact QBE equality. This removes one
whole projection/flow-verification/destruction cycle rather than accelerating
one lookup. **Hypothesis: 5–10% compiler-only gain**, contingent on this duplicate
cycle costing that much; the current leaf profile does not measure it. First
add a bounded clock around the two exact calls on the real verifier/checker
requests, then test one full request only if the removable interval justifies it.

**2. Eliminate unused-field ownership round trips, starting with owned projections.**
The actual N2 assembly still has these static, branch-inclusive call sites:

| Ordinary boxed worker | Take sites | Sink sites | Scratch subtraction |
| --- | ---: | ---: | ---: |
| `ks` |3|7|2048 B|
| `nm` |3|6|2048 B|
| `tg` |3|8|2048 B|
| `dn` / `dk`, each |3|11|2088 B|

`core/term.bend:126,139,178` returns one field, while
`back/qbe/lower.bend:451` takes and loads every field. A general, independently
admitted selected-field projection could retain only the escaping child when
the parent is shared, consume the parent's owned reference, and preserve the
original unique-parent fallback/destruction behavior. This is a different
operation from the already tested shared-take fusion, which still retains all
fields and measured only about 2.15% on the small compiler request.

**Hypothesis: 5–12% compiler-only gain** if these avoidable shared projections
account for enough of the 14.99% take+sink leaves and associated reclamation.
The profile does not yet attribute those leaves to getters, so that condition
must be tested. Begin with source-authorized projection shapes, shared and unique
parents, complete outputs, repeated aliases, retained roots, all physical variants,
counter/overflow and failure-order obligations; keep unproved cases on the old
path. Include the new import's exact ownership verifier contract. A real checker
and verifier request is a better first transfer gate than another field-get loop.

Neither hypothesis rewrites equality or repeats the neutral index-zipper trial.
Global numeric identities could eventually reduce the visible name work, but
conversion/lifetime costs already erased smaller storage wins. That is a larger
architectural project, less immediate than these two explicit repeated-work
boundaries. No implementation or performance guarantee is supplied by this audit.
