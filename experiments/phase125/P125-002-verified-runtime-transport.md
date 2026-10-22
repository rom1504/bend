# P125-002: carry existing verifier facts into the runtime ABI

Status: prototype; broad performance unmeasured.

P125-001 removes six allocations/takes in the frozen RLE invocation but its
conservative runtime/transport variants are neutral or slower. This motivates
testing redundant call/check work separately, on operations with wider coverage.

The original constructor verifier already proves literal field count, real
constructor identity, matching metadata arity and allocated buffer capacity.
A distinct sized constructor ABI can omit those repeated checks and the count
argument. Take verification proves count/buffer capacity but **not** the actual
input Term's tag/CID/arity. Preserve those dynamic checks and every ownership,
publication and reclamation operation. Do not infer a stronger take proof.

Implementation and contract audit: selfhost/tools/performance/phase125/verified-runtime/.
Original structured calls and original verification remain unchanged; only the
existing post-verification projection selects the new explicit ABI.

First test a small multi-family screen and complete alias/depth controls. Reject
if gains are absent, regressions material, or compiler overhead excessive. Static
site counts are applicability evidence only. No malformed native memory probes.

If worthwhile, qualify the integrated source/runtime through the planned broad
and native gates. A future matched-constructor witness is a separate hypothesis,
not a reason to delete unproved checks now.
