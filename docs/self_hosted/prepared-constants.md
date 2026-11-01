# Prepared constants across bounded selector expansion

The Phase152 optimization retains a fact already established by static
preparation: an ordinary nullary constructor is a full-width packed immediate
with no owned heap fields. Its construction and discard do not need runtime
helper calls. See the [design](../../design/phase152/README.md) and
[semantic audit](../../research/phase152/prepared-values-contract.md).

`nc_source_body` intentionally exposes erased source to several analyses. A
bounded selector expanded from that view could recreate `Unit{}` after static
preparation, losing both the constant and its nonowning classification. QBE
then received constructor and sink calls even though the runtime immediately
returned a packed word and discarded it without allocation.

The fix retains the original admission decision, then compares the original
compact body with its freshly prepared body. Only corresponding nullary
constructor leaves may change to authenticated `NStatic` leaves. The comparison
retains binder identities, quantities, variant metadata, children and ordering.
The prepared body has its own size bound and matching definition/prior-fact
identity. Unknown, stale, boxed, special-constructor, payload-bearing or
structurally different facts fall back to the original body. The original
freshness, saturation, callback-use and ordered-actual checks remain required.

Authenticated nullary `NStatic` bindings receive `N_Imm64`, retaining the entire
constructor tag and allowing existing local alias/ownership logic to omit
redundant keep/sink operations. `N_W32` would be wrong: it truncates the tag.
Other values keep the previous classification. The final native verifier and
the static-word emitter remain independent gates.

This is a general selector capability, with no Unit CID assumption or compiler
function-name recognizer. It does not change `nc_source_body` globally, permit
arbitrary raw markers, qualify parallel heaps, or prove compiler correctness.
Finite controls and independently checked/executed programs test its obligations;
they are distinct from a BendTT-checked equivalence theorem.

When investigating a related optimization, first measure the complete consumed
worker. Fewer allocations is an incorrect explanation here: nullary packed
construction already allocated nothing. The removed work is helper calls,
checks, argument/register transport and ownership bookkeeping. Whole-compiler
benefits require separate native measurements; local dispatch ratios cannot be
extrapolated to all compilation time.
