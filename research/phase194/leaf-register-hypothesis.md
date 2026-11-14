# A smaller register-pressure falsifier before late machine allocation

Source observation: `loop-liveness.bend` allocates nine joint colors: four saved
homes1–4 and five caller homes. `frame.bend` initially binds hidden `state` to
saved home0/R12. RAX/R10/R11/RCX remain selection scratch. QBE's spill-free pressure
loop uses a wider register set; the exact witnesses are in diagnostic-machine.md.

A smaller hypothesis than a new machine allocator is to allow saved home0 as a
tenth color for a verified state-independent leaf region. This is **unimplemented
and unmeasured**, not a recommended immediate edit or an established gain.

The first slice should be a single-result integer leaf with self-tail recursion,
no explicit state reads and no explicit or implicit calls. Preserve the existing
interference graph, argument snapshots and callee-save ABI. Use the new pressure
pair as a fast spill/runtime falsifier; require ordinary-program transfer before
considering it general. An extra color may merely move spills or have no runtime
benefit. Do not infer a whole-suite gain from a register count.

Important source-level traps:

- `X181Frame.calls` is outgoing stack-argument space, **not a call count**. Zero
  does not certify a leaf: register-only calls can need no outgoing bytes.
- Hidden state is implicitly supplied to helpers. A lexical absence of the local
  name `state` is insufficient; audit emitted helper paths and fallbacks.
- Color9 is currently the spill sentinel, and callee/caller mapping is positional.
  Changing a single bound from9 to10 is incorrect. Any prototype needs an explicit
  available-pool contract and unchanged spill fallback, not scattered constants.
- Incoming argument placement, return buffers, implicit runtime calls and save/
  restore masks must agree with the admitted pool. The original state home must
  remain intact outside the qualified leaf slice.

First establish an actual spill reduction in the unchanged diagnostic computation,
then time it. If one extra color is insufficient, that negative is useful evidence
for a more substantial instruction/clobber lifetime representation. No compiler,
artifact, benchmark or qualification selection changed for this note.
