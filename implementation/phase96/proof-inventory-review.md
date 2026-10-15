# Phase96 proof inventory and adequacy review

Offline audit of `algebra-all03` and `representation-check03`, 2026-10-15.
No target, compiler or kernel was run by this reviewer. The source rationale
and upstream trust boundary are in
[upstream-proof-method.md](../../research/phase96/upstream-proof-method.md).

## Accepted evidence

| Book | Public laws / supporting lemmas | Emitted definitions | Opaque definitions | Elaborated text SHA256 |
| --- | --- | --- | --- | --- |
| [algebra-all03](../../selfhost/build/phase96/algebra-all03/report.json) | 14 / 7 | 61 | 9 generic parameters | `5f9761c147a8593bd5e6e9078b2eb8fb6428840f6a953eb6e1286b992d987cdb` |
| [representation-check03](../../selfhost/build/phase96/representation-check03/report.json) | 17 / 0 | 79 | 0 | `ab2a066da841130f0cc55160048f53a285706f0a78b2093c7ec60860fa31ecef` |

All 21 algebra theorem names and all 17 representation theorem names bind to
actual equality declarations with nonempty ordinary bodies in the emitted
text. None is omitted, opaque or bodyless. Every emitted declaration has a
nonempty body. All 42 recorded input entries and all 10 source snapshots
rehash correctly, as do their recorded source origins and elaborated outputs.
This counts recorded entries across the two reports, not 42 distinct inputs.

For each accepted book the retained frontend receipt is exit0 with
`ALL PROOFS CHECK` and the mathematical-validity reminder; elaboration is exit0
with empty stdout/stderr; the independent kernel is exit0 with exactly
`ALL PROOFS CHECK`. Both independently false equality controls exit1 with
`SOME PROOFS FAIL`, naming `phase67_false`, expected `.left`, observed `.right`.
The guard records `complete=false` for these expected nonzero controls; the
parent report correctly treats that as expected rejection, not a successful
positive check. No stopped-for condition or unexpected stderr is reported.

Both runs retain the same method snapshot, SHA256
`d21c9887213b499bbe985bb5982a2b5b5f7d4906a68e6b12eb1bcb9d042c90b1`.
Toolchain validation deliberately reauthenticates the key Phase94 executable,
shared library, kernel source/module and runner; it does not rehash the entire
previously audited toolchain installation. This limitation is explicit in the
reports. The independent check does not prove the TypeScript elaborator or
generated C/JS implementations correct.

## Specialization binding is valid for these books

The accepted method matches an exact law-name suffix followed optionally by
`.q[012v]+` and a numeric fresh-name suffix. This follows the actual elaborator:
[`safe.ts:316`](../../bend2/safe.ts#L316) uses `0/1/2` for quantity constants
and `v` for other specialized parameters, then `fresh` adds `_1`, `_2`, etc.
([543](../../bend2/safe.ts#L543)). For example,
`membership.contains_singleton.qvv` is the ordinary specialized theorem;
`membership.contains_singleton_7e_eq` is a different opaque comparator and
does **not** match the law-binding expression.

The prior [algebra-all02](../../selfhost/build/phase96/algebra-all02/report.json)
stopped after successful source checking/elaboration because its inventory
predicate could not recognize `contains_append.qvv`. It did not perform the
independent kernel step and remains an incomplete, preserved attempt. The
all03 name fix agrees with actual emitted syntax; it does not relax the
nonopaque-body requirement. All03 also contains the new semantic anchors, so
it is not merely a relabelled all02 result.

For a future book with several finite template specializations, matching at
least one suffixed name would not itself prove that every expected
specialization was emitted. These current theorem bindings were inspected
individually. Likewise, the generic runner checks theorem inventory, while
the helper-body inventory below is a separate offline audit.

## Representation source connection and exact scope

The [extraction manifest](../../selfhost/build/phase96/representation-source03/manifest.json)
binds `selfhost/src/core/term.bend`: 19,671 bytes, SHA256
`d75234683496e33fcb59cd3598979245700733236d9326025d298f9c33ef33d3`.
Independently locating every declaration in that file reproduces the manifest
and `production.bend` exactly: the `KTerm` type is unchanged, and the only
transformation to each of 15 helper declarations is removing its leading
`@unsafe` line. No body, field, branch or parameter changes. The generated
helper source is 5,507 bytes, SHA256
`c444560110b575409fe916e784e3c9502ccb29943736208d43418f59fb893c42`.

All selected declarations appear nonopaque in the accepted book:
`KTerm`, `tg`, `nm`, `ix`, `qt`, `ks`, `rm`, `kb`, `ke`,
`k_with_children`, `k_with_span`, `core_literal`, `kl_number`, `kl_text`,
`k_quantity_present`, `k_rebuild`. The full `KTerm`, `KLambda` and `KLiteral`
constructor fields are present. Thus this is stronger than proving laws about
a separately rewritten model: the selected source bodies themselves are
accepted in the safe fragment after annotation removal. Production retains
its annotations, and neither its callers nor compilation/runtime preservation
are established by this extraction.

The 17 laws quantify over arbitrary fields/terms; they do not assume valid
parser output, particular ranges, unique removed names or well-formed binder
IDs. Their scope is representation operations:

* Put-back, overwrite and commutation constrain child/span updates together.
  The new-child and new-span read laws reject no-op setters, which the basic
  lens laws alone would permit. Literal child replacement is explicitly a
  full-value no-op, not an exception hidden from the statement.
* Metadata preservation includes names, IDs, quantities, removed-name order,
  source ranges, quantity presence and literal payload. Constructor-specific
  observation laws independently anchor the projection tuple for all three
  variants. The complete-term put-back equations also constrain reconstruction.
* `children_update_is_rebuild` connects two actual production helpers.
  `rebuild_put_back` and that connection constrain `k_rebuild` when its other
  fields are original projections. They do **not** specify every arbitrary
  replacement of name, ID, quantity, removed names or spans.
* `core_literal` is present and safely admitted but not referenced by any of
  these 17 laws. Do not describe all 15 helpers as having fully specified
  behavior. Replacing this particular predicate with a constant is outside
  the current formal obligations.

The term `Semantics` in the proof is a metadata/children observation record,
not an operational semantics of Bend evaluation. Its preservation theorem
must not be reported as whole-program semantic preservation.

## Algebra adequacy and negative-control scope

The final inventory's 14 public laws and 7 supporting lemmas are consistent
with the frozen source and emitted book. `contains_singleton` now anchors
membership to the arbitrary supplied comparator; `filter_cons_decision`
anchors filtering to the arbitrary supplied predicate and full filtered tail.
These directly address the always-False membership and always-empty filter
weaknesses of append/idempotence laws alone. No comparator reflexivity,
uniqueness or predicate axiom is assumed.

The 9 opaque algebra declarations are typed generic parameters: the abstract
element/state/drop types and comparator/predicate/drop callbacks. None is an
actual theorem, list implementation, Phase94 helper or reference body. Ordinary
theorem checking cannot unfold their checked models. The resulting generic
claims remain conditional on typed pure total parameters; this does not prove
the unsafe compiler's adapters implement those callbacks.

The Phase94 prefix law compares complete ordered rows and an arbitrary tail
and drop value with the independent reference filter. It preserves the existing
drop value during prefix filtering; it is not a new full theorem about every
drop transition of `npe_extend`. The original complete Phase94 equivalence
evidence remains separate.

The completed negative campaigns pass with the following exact scope:

| Campaign | Rejected law-bearing controls | Standalone helper admissions |
| --- | --- | --- |
| [algebra-negative-check01](../../selfhost/build/phase96/algebra-negative-check01/report.json) | 8: 4 false claim mutations, 2 Phase94 helper-body mutations, 2 constant-helper anchor substitutions | 3: both Phase94 mutants and the shared constant-helper module |
| [representation-negative-check01](../../selfhost/build/phase96/representation-negative-check01/report.json) | 8 actual helper-body mutants with frozen laws | 8: each mutant helper module |

All 27 child reports, source snapshots and raw check logs were inspected and
their recorded report/source hashes verified. Every helper admission exits0
with the normal frontend success output. Every law-bearing control exits1 with
an expected/observed equality mismatch at an identified law body; none is
credited for a parser error, missing law, affinity failure or resource stop.
All use `--source-only`: these are **frontend** semantic rejections and helper
admissions, not independent kernel checks of the mutants. The positive books
and separate false-equality kernel controls remain the independent evidence.

The representation detections are concrete: ignored child replacement fails
`node_reads_new_children`; erased removed names fail `children_put_back`;
ignored span start fails `span_reads_new_begin`; swapped literal spans fail
`span_put_back`; lost lambda quantity presence and wrong name projection fail
`rebuild_put_back`; wrong literal tag and numeric payload fail
`literal_observation`. The two Phase94 mutants fail `prefix_step_order` on
retained dead rows or changed row order. The constant observers fail their
singleton/cons anchors, after their shared helper module independently passes
the frontend. These results establish useful detection of the selected
semantic faults; they do not imply completeness of the law set.

## Finite production oracle review

Audited the frozen
[production-full02 manifest](../../selfhost/build/phase96/production-full02/manifest.json),
SHA256 `24efcad61cd19bcca494fc055dc873bb6b62502a9e65ab65f2541a290471d2c6`,
and its copied methods. It contains 226 cases in 16 families, with 32 explicit
native witnesses. All 19 frozen input identities, 8 maintained source identities
and 5 B2/host identities rehash correctly. Every one of the 141 selected
declaration spans matches its original source bytes/hash/line; concatenating
them with the recorded Base import reproduces `extracted.bend` exactly.
The current genuine JS B2 is explicitly pinned at `284f6e9b…`; this is not a
claim to exercise the separate native-hosted B2 compiler.

The full01-to-full02 repair adds explicit local binding types. All 226 case IDs,
inputs, expected values and expected wire values are unchanged. The native
main calls the 32 recorded witnesses, and `native.expected.txt` equals those
cases' complete expected wire values in the recorded order.
The retained [full02 native receipt](../../selfhost/build/phase96/production-full02-native/report.json)
also passes offline verification: all 32 output lines match exact expected
bytes, stderr is empty, worker inputs are unchanged and its compilation status
is `ok`; recorded compiler, image and output hashes match.

The Python oracle imports no production code. Its first-match selection,
last-position event selection, set partition, ordered environment filtering and
Unicode encoding are independent value specifications. Constructor observers
retain full payloads, metadata, variants and list order. The substitution
reference correctly rebuilds canonical Apps and beta-reduces even when the
requested substitution ID is absent; its test domain is the stated finite,
well-shaped fragment with globally unique binder IDs. No expected-value error
was found in the reviewed corpus.

Particularly useful boundaries are duplicate definitions with unequal complete
payloads, the `costarring`/`liquid` 32-bit FNV collision, cached event-list
preservation, 255/256/257-event selection, high-bit/U32-max occurrence keys,
first-only duplicate environment removal, exact ordered sink text, distinct
lambda quantity-presence values and canonical/noncanonical Unicode encoding.
Structural rebuild cases change every replaceable field, adding finite
coverage beyond the narrower formal `k_rebuild` equations. Explicit retained
aliases are observed in projection/rebuild, cached-book, set and environment
cases; repeated literal expressions elsewhere should not be described as
additional alias-preservation tests.

All ten mutation recipes name a present helper span and an actually
distinguishing frozen witness: lambda presence, literal end, variable ID,
collision bucket selection, membership hit, dead-row order, first-only removal,
join separator, first-shadow lookup and constructor prefix. Preparation alone
does not count as a detection: require successful target compilation/execution
and a full actual/expected mismatch at the named case. A compiler refusal or
serializer exception is a different result.

The frozen full02 worker has one result-state weakness: a final input-verification
exception can occur after it set `passed=true`, and its catch records the error
without clearing that flag. It must therefore be consumed with the stronger
parent acceptance conditions, including `inputsUnchanged=true` and complete
successful compilation. Root's integrated runner enforces these conditions,
which reject the identified failure path, and requires `actual !== expected`
for semantic mutants. Future worker snapshots reset failure state. Preserve full02 rather than
editing its measured method.

These are finite executable constraints, separate from the 31 public universal
laws above. The 32 native representatives remain a smaller behavior screen
than the 226-case JS corpus. Neither coverage count establishes general
substitution correctness, whole-compiler correctness, ownership safety or a
performance improvement. The corpus and ten deliberate faults are useful at
their stated scope; no additional corpus expansion is needed for this review.

## Final integrated result

The final offline audit of [audit01](../../selfhost/build/phase96/audit01/report.json)
and [fast01](../../selfhost/build/phase96/fast01/report.json) passes. Both retain
38 ordinary, nonopaque theorem declarations (31 public laws and 7 supporting
lemmas), accepted positive kernel receipts and the exact independent
false-equality rejection. Both execute all 226 JS cases with complete actual
values equal to expected values. Inputs remain unchanged. Their recorded
end-to-end wall times are respectively 90.7215s and 15.4794s; these are workflow
costs, not compiler or generated-program speed improvements.

All 10 integrated production mutants compile successfully, complete execution
with unchanged inputs, and produce `actual != expected` at the specified
witness. None is counted merely for a compiler error or exception. Verified
witnesses are `children-update-007`, `span-update-017`,
`substitution-beta-000`, `cached-lookup-022`, `membership-019`,
`environment-partition-005`, `environment-selection-004`, `text-assembly-002`,
`lookup-shadowing-012` and `constructor-encoding-008`. The integrated native
compile/build/run also succeeds with exact complete output for all 32 selected
cases and empty stderr. Product, image and raw-output hashes match receipts.

Independent archive readback agrees with the
[evidence01 summary](../../selfhost/tools/laws/phase96/evidence01/summary.json):
all 1,752 members match their recorded hashes and retained raw bytes, with no
missing current raw file. Uncompressed size is 18,293,811 bytes; the archive is
3,126,787 bytes, SHA256
`352efcd8bd42d4a7729b4039a0729ed7347f832896ed94d353a2feef37d4d242`.
The execution ledger independently reconciles to 108 serial guarded jobs,
103.2717s target occupancy, peak tree RSS 651,522,048 bytes, no overlap and no
resource stop. It includes earlier failed attempts and expected rejections.
External pinned compiler/toolchain artifacts are represented by authenticated
identities rather than duplicated into this raw archive.

No substantive discrepancy remains in the reviewed evidence. The proof,
finite-execution, mutation-detection and trust scopes described above continue
to apply; this phase makes no production optimization or promotion claim.
