# Phase128 Stage2 concrete borrowed-layout graph audit

Source-only review of
`selfhost/tools/performance/phase128/borrow/next/layouts.bend`:
7905 bytes, SHA256
`481e5f3acf5269a474ca3d0e12a4a35e9ff251339ba8f2cdb92d9f5c79fcc42e`.
No target execution, build or timing measurement was performed in this audit.
Stage1's [call-contract audit](borrow-calls-audit.md) and the original
[scalar/runtime audit](borrow-audit.md) remain prerequisites.

No blocking source-level issue was found in this version. The important invariant
is stronger than nominal type equality: **every nonscalar nominal owner has one
exact concrete instantiation throughout this observer's reachable layout graph**.
Only after proving that property does the analysis reuse its older nominal type
names. This is a bounded extension for scalar observers, not generic ownership
inference or a proof of the complete compiler.

## Why nominal names retain enough information here

The graph starts from the original, checked parameter types before they are
replaced by `NO_Schema` variables carrying type names. `nq_layout_type` resolves
bounded transparent aliases. For every nonscalar type, `p128bl_seen` either adds
the normalized concrete `KTerm` or compares it with the already recorded type
using `norm_exact`. That comparison checks complete children, quantities, names,
binder identities and removed-name metadata, ignoring source-location metadata.

Consequently, simultaneous `List<String>` and `List<U32>` roots or fields are
refused. `List<List<String>>` is also refused when graph expansion reaches the
different inner List instantiation. This conservative limitation is intentional;
it prevents the name-only `NO_Spec.fields` and `noa_loop_valid` checks from
conflating those layouts. Equivalent aliases that are not normalized identically
may be declined; that is lost coverage rather than unsound admission.

Each admitted node has exactly two constructors: a nullary constructor and a
constructor with at least two declared live fields. The nonempty constructor
must have exactly one field of its own nominal owner, and that field must be
exactly the same instantiated type. All other fields are recursively checked as
scalar or graph nodes. Mutual graph references are possible, but each individual
node retains the required self spine; repeated graph visits terminate through
the recorded-type table. The budget is **64 graph visits**, including scalar and
repeat visits, not 64 newly discovered types.

The field proof is inductive. Entry root atoms come from the checked concrete
parameter types. A borrowed match creates atoms only from the specialized field
descriptors of that root's unique graph entry. Thus every descendant atom with
nominal name T has the concrete T instantiation already recorded by the graph.
The NO origin chain preserves the retaining ancestor. This is sufficient for
name-based matching and recursive cursor comparison within this bounded graph.

## Constructor specialization and scalar boundaries

The implementation reuses `nol_ctor_fields`, rather than inferring layout from
constructor spelling or observed runtime shapes. Its `nq_layout_specialize`
substitutes the supplied type arguments with existing 64-step and 4096-node
growth bounds. The resulting constructor telescope must have the expected
number of non-erased live fields, and its result must match the original owner
and exact type arguments. Dependencies on previous runtime fields and indexed
constructor results are rejected. Original observer parameters/results also
reject dependencies on prior parameters, including erased type parameters.

`nol_owner` still checks ADT identity, parameter arity, absence of removed arms
and unsupported indexed/template metadata. Native owners are limited to the
existing String representation and canonical List; other native layouts are
not assumed to be ordinary boxed spines. User constructors use the existing
provenance-based `nc_ctor_identity` encoding, so a user name does not acquire a
Base constructor ABI merely by resembling one.

Scalar recognition is unchanged: supported native scalar types and bounded
all-nullary enums must be plain ADTs. A parameterized type does not become
scalar because its name resembles a scalar. The extra graph cannot silently
reinterpret Array, function, foreign or arbitrary boxed fields as machine
scalars. Scalar result extraction and the one/two-root limit also remain intact.

The successful graph does not persist full type arguments into every residual
node. Its single-instantiation invariant is therefore essential: future changes
must either preserve it or carry full specialized type identities through
matching, helper calls and loop checks.

## Helper and fallback obligations remain intact

Stage2 changes only schema derivation after an ordinary schema fails. Stage1
helper summaries still come from the original plain-root/scalar schema and
cannot introduce a differently instantiated parameterized helper root. Borrowed
helper actuals must remain `OA` values with held-root provenance. Virtual `OC`
constructors may be symbolically eliminated by NO evaluation, but cannot be
passed as supposedly retained physical roots or recursive cursors.

Retaining the outer List protects a borrowed String head even when the head's
own reference count is one. It must be passed to the private borrowed reader,
never to an ordinary owning adapter/fallback without a real ownership transfer.
No borrowed child may escape as the observer's scalar result.

The existing public adapter continues to guard the actual original roots,
retain them throughout the read, and sink each once afterward. Unique, mixed
and conservatively refused aliases keep the exact owning fallback. Overlap
between two distinct roots does not invalidate readonly access while both roots
are retained. Under the shared-root guard, final drops are non-destructive in
the sequential runtime and therefore do not invalidate another root's children.

Original-position fallback insertion, private-reader dependency ordering,
source-bound summary derivation, the restored residual validation gate and full
projected final verification remain mandatory. A successful layout graph alone
does not authorize arbitrary generated machine calls.

## Highest-value qualification controls

- Checked `List<String>` membership with shared and static roots, early match,
  early mismatch, Unicode and missing entries; retained list/query observed
  afterward. Inspect actual reader calls and borrowed list-field reads.
- A renamed generic user spine with a borrowed String payload, demonstrating
  selection by constructor/type structure rather than List/function spelling.
- Unique and mixed-root inputs retain correct fallback and bounded native stack;
  shared tails, aliased heads and a query equal to a retained list head remain
  readable after the call.
- Different instantiations of one owner, changed recursive type arguments,
  multiple or absent self fields, indexed/dependent/erased fields and graph
  budget exhaustion refuse the optimization. In particular, test two checked
  parameters with different List element types, not only synthetic graph nodes.
- Native Array/other unsupported owner, escaped borrowed child, invented origin
  and wrong helper type reject at their original semantic boundaries.

The source includes finite graph-predicate controls, but source inspection is
not evidence that these or the ordinary compiler-generated controls have run.
The parent campaign owns checking, output comparison and measurements. Require
those results before qualification or any production-selection change.
