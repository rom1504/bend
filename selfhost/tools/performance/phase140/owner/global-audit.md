# Owner cache global-read audit

This is a bounded source audit, not a proof of the compiler or a demonstrated
checked-source miscompilation. It motivated a conservative refusal rule and
additional exact-output controls before broader qualification.

## What is already protected

The cache receives the actual current checked context through the original
P86 driver/ownership/entry gates. `dg_event_output` stores the checked term in
definition values; `book_context_world` is explicitly private to that admitted
world/load/seed combination. Arbitrary forged KDef/BookCache objects are not
public cache inputs. The static image and NQ signature contexts are recomputed
before raw reuse, and exact ordered names, bangs, signatures, static node offsets
and values remain raw admission conditions. Incoming generic fresh counters
must match too. Constructor/ready context has an additional root-owned gate.

The header comparison preserves complete declaration types, flags, children
and Foreign bodies. Therefore a changed constructor declaration or layout flag
already refuses reuse. Normalization can still read an alias **body** through
an unchanged constructor telescope; exact source headers alone do not establish
that its normalized fields stayed unchanged.

## Actual read paths

In selected Phase137 source:

- `ka_def` (line10828) annotates against the complete context. `ka_mat` (10911)
  looks up constructor children through the normalized datatype goal. `wnf` and
  `norm_ref` can unfold referenced definition bodies.
- `nc_definition_plain` (35602) calls `nc_erase`; annotated constructors and
  matches read child telescopes through `nc_erase_annotated` (31950) and
  `nc_erase_mat` (31943). `nc_live_count` (31918) and `nh_field_mask` (35376)
  normalize these types.
- Generic/private lowering can reach `j_layout_ctor`/`j_find_ctor` and
  `nc_find_ctor_plain`, which search the complete constructor catalogue by
  name. `nc_ctor_owned` (31098) also scans owner declarations, although its
  own kind/child/native observations are protected by exact headers.
- `p113pl_candidates` (45992) has hard-coded datatype-layout checks through
  its fusion/flat-product helpers, including Cmp, Maybe, Map and Sigma. Their
  constructor telescopes may reference aliases.

A conservative token-reference call-graph inspection found no route from
`ka_def`, `nc_definition_plain`, `p111_entry` or `p113pl_candidates` to
`nol_scalar_specs`. The late observer's globally appended scalar catalogue is
therefore a separate issue; it has its own exact catalogue gate. This call-graph
inspection is source evidence, not a universal dynamic-read theorem.

## Why add a refusal rule

The owner graph records all names in an owner's type/body and child declarations.
An alias change therefore marks any datatype whose child telescope refers to
that alias. However, a constructor occurrence can name the child rather than
its top-level datatype owner. Checked type flow often supplies the parent via
an enclosing type or callee signature, but relying on that informally would
leave the global constructor fallback paths insufficiently justified.

The new `core-v05.bend`/`reverse-v04.bend` rule is deliberately conservative:
if any dirty owner contains an ADT declaration, set `analysis.ready=False`.
It preserves the dirty map/count and refreshed current edges. All front/raw
product lookups then miss through their existing admission conditions; reverse
refresh builds the current graph for the next successful request. The same rule
runs after derived-fact closure. Numeric function-body edits without affected
ADTs retain ordinary reuse. No constructor-name-to-parent inference is assumed.

The seven data-only `global-controls-v01.bend` checks construct unchanged
headers with an alias-body edit affecting a constructor telescope. They test
refusal, independent-owner misses, retained diagnostics, current-graph refresh,
and continued admission for an ordinary numeric edit. They are **not** presented
as a source program that both revisions passed through the checker.

Reviewer independently checked the refusal placement and caught a diagnostic
reset in the false arm of fact analysis; reverse-v04 now retains dirty/count in
that arm. Source/API/complete-output validation is still required for the new
versions. Root owns bridge-v03 constructor context and combined qualification.

## Erasure traversal cost

The selected Phase137 `nr_walk` (36279) itself still uses linear
`nb_contains(done,name)`. The owner prototype preserved it, so a warm erasure hit
still paid repeated scans of the entire visited-name list, plus `nc_refs` walks
of already cached bodies. This is a new optimization opportunity, not a prior
optimization accidentally removed.

`products-v02.bend` adds a private Patricia visited set while preserving the
original ordered todo/done/fact/entry lists. Only the membership predicate
changes. `products-v03.bend`, authored by the checker lane, additionally retains
the exact ordered `nc_refs` result with its erased body. Five
`erasure-controls-v01.bend` checks compare complete `NR_Closure` names and facts
against the untouched `nr_walk` for cold and warm chains, cycles, duplicate refs,
missing names and a real hash collision. They remain finite evidence; complete
real-request/frontend/QBE identity is the integration gate.
