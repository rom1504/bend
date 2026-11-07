# Erasure product prototype

Outcome: independently checked, 1,474 controls pass, complete native frontend
timing is neutral. **Rejected for production integration.** See
[neutral-result.md](neutral-result.md) and the
[phase report](../../../../implementation/phase178/README.md). The following
sections preserve the experiment design and its original gate expectations.

Source-only experiment against maintained parent `296f288`. No compiler,
benchmark or generated program was run by its author. Root owns checking,
measurement and selection. All changes are confined to this directory.

The initially considered annotation/layout fusion needs to carry facts through
application-spine products, dependent constructor fields, match-rest rebuilding
and let substitution. Layout also ignores erased fields/arguments and one arm
of single-constructor matches, and treats bare versus applied Array references
differently. A small overlay would clone most annotation or change its helper
contracts extensively. This prototype therefore takes the authorized smaller
boundary: erased body plus the references of its surviving output.

## Producer and consumers

`erased-product.bend` factors the six existing erasure operations into one shared
implementation. `NativeErasedTerm` and `NativeErasedTerms` carry the original
body/list and a reverse-preorder reference accumulator. They are ordinary typed
products, not markers embedded in KTerm. For collection mode, the invariant is:

```
result.body = original_erasure(book, input)
result.reversedRefs = reverse(nc_refs(result.body)) ++ incoming_reversed_refs
```

Thus reversing the result onto a pending queue yields earlier seed references,
then the body's references, then the old queue. References retain duplicates and
stored Ref children; Var children disappear as before. Dropped App arguments,
extra children of erased lambdas, annotations and equality proofs contribute no
references. Live children are erased left to right. Constructor telescopes use
the original argument for dependent substitution, including an erased argument.
Primitive/foreign body construction retains the original implementation and a
body/reference scan fallback.

Compatibility APIs use `collect=False`: the same core computes the original
body while preserving the incoming accumulator unchanged. It allocates no Ref
list cells and does not run the native/foreign reference scanner. It still
returns intermediate products; this boxing/continuation cost is a significant
unmeasured risk, not assumed free.

Three immediate consumers use `collect=True`. `p143nr_visit` and public
`nr_visit` reverse the supplied refs directly onto their old todo queue, deleting
the completed-body `nc_refs` scan and append. `p140oe_fresh` publishes forward
refs to the unchanged incremental recorder, retaining reuse entries, hits,
misses and exact queue semantics. `nc_compile_def` continues to scan its compact
body: its input has undergone another transformation, so erasure refs are not
silently substituted there.

`spec.json` lists the ten exact replacements, helper prelude, ordered control
modules and exports. Root's Phase178 extraction adapter should consume these
lists; the older Phase177 adapter intentionally rejects this changed parent.
Candidate module order is `erased-product.bend`, `controls.bend`, then
`control-candidate.bend`; baseline uses only the two baseline control modules.
Public function signatures and complete `NR_Request` values remain unchanged.

## Controls and decision

`values.mjs --baseline REPORT --candidate REPORT --out FRESH_DIRECTORY` accepts
independently checked hosted API reports. It compares every field rather than
digests and preserves aliases. Twenty literal expectations cover all KTerm
representations, metadata, empty/overfull shapes, duplicate refs, proof erasure,
dependent/live/erased constructor fields, both match arms, and a partial Array
intrinsic. Parameterized controls cover four plain/cached ownership books,
nonempty accumulator seeds and pending queues, collection-disabled mode, raw
public helper calls, dependent argument telescopes, native/foreign definitions,
ordered/cyclic/duplicate-name closures, and incremental fresh/reuse results.

The observer's initial seeded-reference formula placed the seed after the body;
independent source review caught and corrected it before any target execution.
The literal expected values and baseline algorithms remain independent of the
new erasure implementation. No passing result is claimed yet.

After those controls, compare existing complete frontend/request outputs and
the isolated medium frontend cost, charging setup, all consumers and teardown.
Reject a neutral or slower product before a full compiler acquisition. Removing
one traversal does not establish a speedup: pair returns and the new consumer
boundary may cost more. The old medium diagnostic's entire erasure/request
interval was 12.46% of frontend time; this scanner is an unknown fraction, and
that interval is not a full-build or removable-work ceiling. Annotation, layout,
their diagnostic order, and the semantic verifier remain unchanged.
