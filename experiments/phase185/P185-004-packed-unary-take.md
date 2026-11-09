# P185-004: Guarded ordinary packed unary take

Status: source candidate, separately attributable from cold allocation.
No execution or performance result is claimed here.

The admitted baseline profiles attribute 15.98% of QBE tree-bitonic samples
and 11.43% of map128 samples to take helpers. This includes heap/shared work
that this candidate retains. Tree leaf comparisons call the unary helper
even for packed scalar leaves, so a tag-and-identity fast branch may remove
some call overhead. There is no claim that the whole sampled share vanishes.

`back/qbe/packed-take.bend` changes the existing `p111_take` factory in shared
native lowering. Checked ordinary match lowering supplies the constructor
identity and exact field count. Only count one and the existing ordinary
`$ctor.` identity policy are admitted. Native special constructors retain
their established separate representation. The original IR verifier remains
unchanged and resolves the new symbolic constructor ID before target emission.

The fast condition is `((word >> 40) & 0x7fffff) == (0x10000 | expectedCID)`.
It simultaneously requires TAG_PAK and the exact expected constructor ID,
ignoring RFC exactly as the selected runtime's `term_tag` does. Success copies
all 40 location/payload bits to the original scratch slot, preserves the
helper's result value one, and uses the original field load. Heap, shared
heap, wrong tag, and wrong CID values reach the unchanged runtime take call
with the original full-width input word. No heap or reference-count operation
occurs in the packed branch.

An input snapshot precedes guard temporaries and writes. Temporaries use the
fresh lowering counter; source-generated locals use the separate `v_<id>`
namespace. Explicit inputs beginning `p185pt_` decline expansion, and the
control set covers temporary, result, status, and nearby-prefix aliases.
This is structured IR before verification, shared by QBE and x86, rather
than textual backend rewriting. It changes no runtime implementation.

`tests/phase185/packed-take-controls.bend` has 26 admission/verification rows
and seven direct functions. `packed-take-oracle.c` crosses those functions
with 20 independently labelled full-width words, checking exact outputs,
helper calls and arguments, and unchanged state: 420 checks per target.
Its slow helpers are isolated stubs, not replacements in program products.
`packed-take-inputs.bend` separately exercises the real runtime with values
around the 40-bit boundary and retained packed/heap aliases, fed through a
bounded loop to avoid relying solely on constant constructor expressions.

The candidate is falsified by source rejection, machine oracle mismatch,
missing lowering in the intended leaf path, or a measured regression.
Runtime comparison must preserve the constructor-only variant so this take
change is separately attributable. Broad exact-output qualification remains
necessary before promotion.
