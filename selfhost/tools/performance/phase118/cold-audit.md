# Phase118: remove unnecessary count-one wrappers using the existing certificate

Status: source audit and isolated Bend prototype. This agent ran no compiler,
target, benchmark, or new profile. Root owns certificate queries and experiments.

## Corrected interpretation of the prior profile

The Phase116 Take hotspot at the RFC field-copy block proves RFC indirection,
**not a reference count greater than one**. `ctr_take` copies fields before it
tests `RFC_CNT == 1`. `rfc_seal` creates precisely such count-one wrappers.
Consequently describing all those samples as genuine sharing was too strong.
`span_fade`, or a PC beyond the count>1 branch, is the evidence for shared-parent
child increments. The distinction changes the priority: unnecessary sealing can
explain hot wrapper allocation, indirection and release even for linear trees.

## Existing implementation gap

`src/back/native/book.bend:nc_ctor_specs` and `nc_default_ctors` set every
`N_Constructor.hot` flag true. `phase111/segment/lower-book.bend:p111_finish`
copies those rows into the QBE program. `p111q_ctor_table` serializes them into
`p111_cid_hot`; the descriptor points to this byte array at offset136.
`phase111/runtime/core.inc.c:p111_rt_ctor` nevertheless seals every child
unconditionally, independent of that table. The table currently affects
`io_seal`, not ordinary constructor allocation.

The mature C backend has a separate, checked whole-program certificate in
`src/back/native/sharing.bend:nh_definitions`. For every duplicated runtime
variable it heats its checked annotated datatype, all its constructors, and
transitive live-field types. Unannotated duplicates, unknown/open/dependent
layouts and exhausted budgets heat `*`, declining the optimization. It needs the
checked annotated book, before ownership/type information is erased; erased
runtime Terms are insufficient evidence.

`ne_ctor_node` uses that certificate to omit `rfc_seal` for a cold **parent**.
The parent identity controls sealing, not the child's constructor identity.
The measured mature C artifacts for tree, map, list-pipeline and lexer all contain
`#define NATIVE_COLD_CTORS 1` and only SCon/SNil hot definitions. None contains a
later observer-dependent hot undefinition. Thus those C products already avoid
sealing ordinary user-tree/list/map nodes. This is a static comparison of retained
products, not a fresh measurement or proof that every current QBE request gets
the same certificate; the root must query the exact requests.

## Why cold stores preserve the ownership representation

An unwrapped child inside a unique parent is safe: `ctr_take` transfers it once;
`term_drop` walks and frees it once. An RFC-wrapped unique parent also transfers
fields once after releasing its count-one wrapper. Immutable `term_peek` reads
do not require child wrappers.

The dangerous operation is **taking a parent shared more than once**. Its
`span_fade` increments already sealed child RFCs and rejects nontrivial raw
children. The certificate must therefore exclude every path that can duplicate
a cold parent, including duplication of a containing value. `nh_type`'s
transitive field heating is essential; a local constructor-use count alone is
insufficient. This initial prototype does not implement the stronger mature
`nh_observer_types` relaxation for shared-but-readonly roots. That requires proving
all destructive consumers, partial applications, direct/flat worker bypasses and
effects follow the observer policy.

Runtime consumers/producers reviewed:

- `term_keep`: wraps/increments the parent; does not repair raw child fields.
- `ctr_take`/`span_fade`: the critical shared-consumption boundary above.
- `term_drop`, `term_sink`: already handle raw or wrapped unique children.
- Readback/show and borrowed workers: peek without transferring child ownership.
- `p111_rt_frame`, register transfers, closures: move existing ownership; keep
  their original representation and contracts.
- `io_node`, `io_str`, `io_cbuf`: IO creation can use parent hot metadata, and
  destructive String consumption uses ordinary Take. Audited effect permission
  and transitive source closure must remain intact.
- `p111_tuple` and `p111_native_word`: currently seal unconditionally. Leaving
  them unchanged is conservative and can retain extra cost; it is not incorrect.
- Arrays, Word, primitive wrappers, foreign/effect constructors: excluded from
  this first cold-store application. Their specialized representations remain
  unchanged.

## Minimal implementation and integration

`cold-model.bend` exports:

- `p118c_plan(request)`: exact hot keys, eligible cold constructor identities,
  validity and source-bound error; permission is the unchanged `ns_definitions`.
- `p118c_hot`, `p118c_cold`, `p118c_valid`: small query results for the fast loop.
- `p118c_apply(original, plan)`: verifies the original using unchanged
  `p113a_verify`, re-derives the certificate from the retained request, and changes
  only constructor hot flags. All segments, direct functions, effects, static
  words and readback remain identical. `*`/missing permission/invalid source
  preserves the original program.

Eligible rows must originate from checked source ADTs through the existing
`nc_ctor_specs`/`nc_ctor_identity` machinery, have positive arity, and be absent
from the hot set. Ordinary Base Tuple/Con can qualify; foreign definitions and
special numeric/Word/Array/effect constructors are retained hot. Constructor IDs,
order and arities never change.

`cold-tables.bend:p118c_tables` detects zero bytes in the exact hot table and ORs
capability8 into descriptor datum11 (offset88). Apply it **after** `p117p_tables`,
which otherwise rewrites that slot to3. Root's proposed wrapper around the
full-table `p111q_data_chunks` call covers array-enabled, ordinary-direct,
no-direct-function and static fallback render routes. It must not parse emitted
QBE text or attach the capability independently of the altered table.

Root supplies runtime support for capabilities1/3/9/11, retaining old sealing
unless capability8 is present and the exact **parent CID** is cold. The same
predicate must govern sized-constructor helpers and TRMC initialization/link
stores; otherwise one path can retain extra overhead or disagree with ownership
expectations. The ABI structure remains192 bytes and old descriptor behavior
remains available.

The plan and original program must come from the same checked NR_Request in the
root harness. They are compiler-internal records, not an authenticated serialized
certificate format. Manifests pin source/runtime identity. No raw hot-name list
is accepted as authority by `p118c_apply`.

## Cheap decisive checks

Query the unchanged certificate on the exact tree/map/list/lexer requests first.
If it yields `*`, retain that refusal rather than weakening admission. Compare
all constructor rows before/after: only admitted hot bits may differ, descriptor
capability must change coherently, and all source-independent metadata must be
identical.

Test cold stores alone before combining borrowing/TRMC. Ordinary controls should
cover unique nested user nodes, a duplicated node (must be hot), a duplicated
container containing that node (transitive heating), multiple instantiations of
a generic container, a static subtree in a generated parent, a generated child
in a static/returned owner where supported, partial applications, and full
readback after construction/take/drop. Unsupported annotations/effects must
fall back. Use normal checked Bend inputs; no malformed raw runtime faults.

If timing improves, inspect allocator/Take profiles and emitted hot tables to
separate fewer count-one wrappers from true shared-RFC work. Compare code size,
plan cost and runtime; a table-level representation win should transfer across
unrelated workloads without growing many body-specific optimization rules.
