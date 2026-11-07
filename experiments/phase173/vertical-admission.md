# Why the first general SCC change does not yet transform the complete store

Static inspection of the root-produced
`scc-store-emission01/program.ssa` against
`store-native-candidate02/program.ssa` finds two newly direct **store** cycles:

| Machine worker | Source product entrypoints |
| --- | --- |
| `$p173scc.3` | `p173s_push_edges`, `p173branch_13`, `p173take_12` |
| `$p173scc.5` | `p173s_valid_edges`, `p173branch_17`, `p173branch_18`, `p173take_15`, `p173branch_19` |

There is also a direct `U32.show.fin`/`U32.show.go` cycle, `$p173scc.1`.
The complete import, export, reference and compaction loops remain generic:
`p173s_import_go`, `p173s_export_go`, `p173s_refs_go` and `p173c_go` have no
`p113d_$direct` or `p113d_$product` worker in either product. Their actual
`p111_$direct` bodies still invoke runtime scheduling. This conclusion examines
the actual function bodies separately from `p112w` closure factory wrappers;
counting functions or factories alone would not establish it.

The [machine-level inspection receipt](vertical-admission-qbe.json) pins both
complete QBE files and records exact body identities, source lines, calls and
new SCC forwarding entrypoints. This is static evidence, not a new dynamic
profile or proof of which calls dominate the native runtime.

QBE text decreases only 13,046,832 → 13,042,801 bytes. The root's hosted request
reports 108.674 seconds: frontend 45.827, lower/verify 51.362, render 7.049. Those
hosted intervals do not measure native store performance. Refer to the root's
paired native receipt for the runtime effect; this audit ran no targets.

## Do not misdiagnose the missing capability

A source-dependency audit of the exact native candidate source finds core cycle
sizes of **9 import, 11 export, 6 reference, and 36 compaction functions**. These
fit the new 64-member cap. Their recursive source calls appear in tail position.
The store/node/emit calls whose results feed continuations are outside those
recursive components. That does not prove their lowered product ABI preserves
tail position, but it does mean that a new non-tail continuation architecture
has not yet been justified by these source cycles.

The nine-field `P173Store` itself exceeds the existing eight-field product
layout threshold. However, `P173Store & Result` has a two-field outer product;
it is incorrect to infer a ten-word result merely by recursively adding fields.
The current product layout is shallow. Both representation width and actual
ABI adaptation must be inspected in the lowered candidates.

The remaining competing explanations are:

1. A member already has a raw lowering error, so SCC discovery cannot include it.
2. The actual lowered cycle mixes boxed one-result and flat two-result entrypoints
   and introduces reconstruction after an otherwise tail source call.
3. The cycle is legal and constructed, but one external dependency remains
   unready, so the complete worker cannot pass dependency closure.
4. Other explicit component obligations (size, scratch, shape, effect/ownership
   conditions) reject the actual lowered body.

These are hypotheses until the raw diagnostic is executed; none follows from
the small QBE reduction alone.

## Cheapest decisive diagnostic

[`vertical-admission.bend`](../../selfhost/tests/phase173/vertical-admission.bend)
exports `p173vd_request(NR_Request)`. It reuses unchanged static preparation and
full callable signatures, then lowers only the actual `p173` helpers, excluding
literal-transport helpers. It returns complete source signatures, ordinary and
product raw candidates, their exact errors and call lists, and discovered SCC
component names, widths, results, body size, scratch and legality.

This is a pre-early-ready diagnostic superset: its candidate counts must not be
reported as the exact production workload. The complete structured bodies and
errors are the evidence. They can reveal whether a proposed transformation is
blocked before SCC discovery, by ABI adaptation, or by a separate dependency.
The diagnostic deliberately omits full generic lowering, final rendering, QBE
construction and new native image acquisition.

The root-owned host command is:

```text
bun selfhost/tests/phase173/vertical-admission.mjs \
  --receipt CHECKED_API/report.json \
  --assembly CHECKED_SOURCE/manifest.json \
  --source selfhost/build/phase173/store-native-candidate-source02/compiler.bend \
  --out FRESH_DIRECTORY
```

The observer authenticates source, acquisition, prepared Base, carrier and engine
before and after execution. It saves complete candidates plus a compact error,
call and component summary. All lowering and SCC decisions remain checked Bend.

Pick the next change only after identifying the first causal barrier in an
actual core loop. In particular, do not build general non-tail frames to repair
an avoidable boxed/flat result conversion or an unavailable array helper.

## Executed diagnostic: the missing composition is argument ABI adaptation

The root executed `scc-store-admission01`: 44.502 seconds frontend and 16.873
seconds diagnostic. The complete checked output contains **309 raw candidates:
296 error-free and 13 with `product result shape mismatch`**. The
[corrected metadata summary](vertical-admission-summary.json) preserves exact
names, calls, component obligations and paths to the first error.

The root's frozen v1 host observer misread each String call name as a record in
its compact summary, producing null entries. Its complete-candidates artifact
was unaffected. The original observer and receipt remain untouched;
[`vertical-admission-summary.py`](../../selfhost/tests/phase173/vertical-admission-summary.py)
authenticates that complete artifact and produces the corrected summary without
executing a target or rerunning the compiler.

Several important components already pass the new SCC legality check:

| Component | Members | Result words | Maximum arguments | Statements | Scratch bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| Import | 9 | 2 | 8 | 664 | 200 |
| Partial compaction | 15 | 2 | 11 | 967 | 312 |
| Partial export | 6 | 2 | 11 | 443 | 128 |

They are far below the size and scratch limits. They cannot close because of
failed helper dependencies:

- Import → emit → take1 → take2 → add_node → `$product.p173branch_3`.
- Export → export_visit → `$product.p173take_4`.
- References → branch14 → `$product.p173take_14`.
- Compaction → visit → `$product.p173take_19`, and the same emit dependency.

The deeper finding is that **the callee product signatures exist**. For example,
`p173take_14` consumes a flat outer pair `(Store, Node)`. Its `Node` field is still
boxed. `p173branch_15` has a known three-field product argument and a known
two-field result. However, `nq_args_fit` accepts only an existing `NQBundle` for
that product argument; it refuses the boxed variable. `p113pl_call` therefore
calls the boxed `$direct.p173branch_15`, then `p113p_transfer` refuses to return
its opaque result as the caller's flat pair. The analogous boundary occurs in
the other three core computations.

Thus existing optimizations fail to compose even though the type, constructor,
callee ABI and recursive tail behavior are already known. This is neither a
missing source-level tail-recursion capability nor an inherently non-tail
algorithm. A return-only unboxing bridge would add post-call work and mix one-
and two-result conventions inside the cycle; it may leave that cycle blocked.
Adapting the **boxed argument** to the already verified flat callee preserves
the flat result and tail-call shape instead.

The smallest general follow-up is a guarded argument adapter at `p113pl_call`:
use the existing finite product signature, test the ordinary constructor, consume
the owned boxed token through the existing `p111_take`, and call the existing
flat helper with its fields. Preserve the current path for existing bundles,
unknown/special shapes, unavailable bindings and unsafe duplication. Reuse all
final verification and SCC obligations. This is a hypothesis being implemented
separately, not a demonstrated speed result in this document.

Ownership obligations include retained aliases, correct field reference counts,
one consuming take per actual owned argument, deterministic argument evaluation,
fresh generated locals and no borrowed field escaping its owner. The guard must
not be replaced by an unchecked load. Existing checked-signature provenance is
essential; a fabricated `NQShape` is not independent semantic authority.

[`vertical-abi-workload.bend`](../../selfhost/tests/phase173/vertical-abi-workload.bend)
adds ordinary source controls for unique nested products, a shared alias read
after its first call, the same product passed twice, sum fallback and a 65,536-
step tail cycle. Its complete expected output is
`[9,13,9,13,9,101,18,14,0,17,5,5,9,1]`. Root execution and actual admission evidence
are still required. These controls complement the real 101-body compiler corpus;
they do not replace it.

## Independent adapter source review

The separate `product-arguments.bend` candidate uses ordinary constructor guards,
the existing consuming `p111_take`, and the existing flat call/result path.
Generated field names agree with `p111_load_fields` and `nq_bundle_params`.
Removing the original owned binding is appropriate; fresh field values can go
directly into the final call-word list because admission excludes references to
those fresh IDs in the remaining arguments. No borrowed projection is introduced.

The review found two admission edge cases, corrected before the root snapshot:

- A unique semantic ID alone does not exclude two bindings sharing the same
  emitted owned local. The candidate now refuses that ambiguous duplicate token.
- A `MAX_U32 - 32` start plus 32 unpacked fields reaches `MAX_U32`, after which
  the existing final call increments the fresh counter. Admission now reserves
  the additional call slot (`MAX_U32 - 33`), preventing wraparound.

The implementation agent added finite controls for both cases, alongside normal
call/fallback equality and independent final verification. This paragraph records
source review and corrections, not execution of those controls by this reviewer.
Constructor-miss handling uses the existing impossible-match failure. Its claim
is equivalence for checked values with trusted finite product signatures, not
arbitrary malformed foreign payloads or a new full compiler correctness theorem.

## ABI03: the exact barrier is removed in checked raw lowering

The root's `abi-store-admission03` repeats the same actual store source through
the revised argument adapter. All **309 candidates now lower without error**;
all 13 original product-result refusals disappear. The
[new corrected summary](vertical-admission-abi03-summary.json) leaves the old
receipt and summary unchanged.

| Core cycle | Before argument adapter | After adapter | After: result / argument words | After: statements / scratch |
| --- | ---: | ---: | --- | --- |
| Import | 9 members, legal but blocked externally | 9, legal | 2 / 8 | 664 / 200 B |
| Compaction | 15-member partial component | Full 36, legal | 2 / 16 | 2,051 / 616 B |
| Export | 6-member partial component | Full 11, legal | 2 / 11 | 643 / 208 B |
| References | No complete component | Full 6, legal | 2 / 7 | 259 / 56 B |

The Word decoder (11 members), Nat decoder (9), Succ scanner (6), and complete
store validator (8) also form legal components. Existing edge pushing and edge
validation remain legal. All are within unchanged parameter, statement, scratch
and component-size bounds.

This establishes a causal source/IR result: adapting known boxed arguments
restores the missing flat calls and joins the fragmented recursive computations.
It does **not yet** establish that the final compiler admits every worker or
that native execution becomes faster. The new summary references the prior SCC
QBE only to identify already-emitted external dependencies; it must not be read
as a measurement or machine-code census of the ABI03 candidate. Final native
emission, independent verification, complete-output equality and runtime are
the root's next gates.

## ABI03: final emission and native execution

Those gates subsequently completed. The actual final QBE contains complete
direct workers for import (9 members), compaction (36), export (11) and reference
collection (6). The [actual QBE census](vertical-admission-abi03-qbe.json) and
[exact selected bodies](vertical-admission-abi03-bodies.ssa) preserve the evidence.
Walking generated-function calls from these four entrypoints finds no named
scheduler jump/apply/closure/return/resume hook. Runtime helper internals remain
outside that static claim. Construction, take, keep and destruction work remain.

The actual 101-body native consumer produces the complete independent output:
962,601 bytes, SHA-256
`6f2f5400603f0f7209abd2da2317ef3bd8097fff19d4f36b2b39797d18001ac7`.
The root's `abi-store-pair03/report.json` preserves four balanced process pairs,
all exact. Its baseline is the **original KTerm implementation**, not the previous
indexed implementation:

| Whole process / complete output | Median |
| --- | ---: |
| Original KTerm, contemporaneous baseline | 78.649 ms |
| Indexed store with ABI bridge and complete SCCs | 93.690 ms |
| Previous indexed store, earlier `store-native-pair01` campaign | 157.692 ms |

The new indexed path remains **19.1% slower than KTerm**, while its time is about
40.6% lower than the earlier same-algorithm indexed path. The latter comparison
is across campaigns; the original KTerm reference was stable at 78.725 ms in
the earlier campaign. A narrow SCC-only campaign had recovered only 5.74%.
This supports the composability explanation but does not establish a full
compiler speedup or make the indexed representation the selected implementation.

Final QBE falls from 13,046,832 to 12,717,939 bytes. This is not the mechanism
used to infer the runtime gain: the important evidence is actual direct worker
admission and exact native execution. The hosted emission request took 102.322 s
(44.922 s frontend, 48.224 s lowering/verification, 4.747 s rendering); those
intervals are not an end-to-end native self-build measurement.

The remaining concrete boundary is documented in
[the dispatcher experiment sketch](vertical-dispatch.md). The generated
compaction worker still sends 50 statically constant transitions through its
36-way state dispatcher. That observation justifies a cheap experiment, not an
assumed performance gain.
