# Source32 semantic integration review

Bounded, read-only review of the selected composition and
[representation document](../../docs/self_hosted/representation-composition.md).
No compiler, API, generated program or performance test was run for this review.
No concrete semantic integration blocker was found. This is source review plus
inspection of existing receipts, not a proof of unrestricted compiler correctness.

The reviewed compiler is
[`observer-divmod-source32/compiler.bend`](../../selfhost/build/phase126/observer-divmod-source32/compiler.bend),
SHA256 `40c469114c4d1c75dceab456e1979bb5c0278744a02e6dbe4a37e63667740abb`.
Its [checked API receipt](../../selfhost/build/phase111/p126-observer32-api/report.json)
is complete. The [finite receipt](../../selfhost/build/phase126/observer32-finite/report.json)
passes all 98 rows across eight groups. The
[ordinary native receipt](../../selfhost/build/phase118/p126-final32-controls-run/report.json)
passes all nine programs, including float boundaries/state, selectors/routing,
owning reconstruction, full-width Nat/shift/divmod and mutual tail recursion.
These controls establish their stated observations; they are not broad45 or
native self-hosting qualification.

## Integration boundaries checked

- Local float rendering retains the full-Term function ABI and original word
  values at observation boundaries. Float facts are invalidated by word results;
  guarded conversion precedes `stoui`. Table projection reads the full input word
  before writing an aliased destination and clamps to the verified default row.
  Unknown calls and unsupported buffer/control shapes retain fallback.
- Source32's Nat.divmod shape hook authenticates the native application through
  `nd_native_call`, including arity, rather than accepting a source spelling.
  The new import requires the exact state argument, two full-width words and a
  distinct, sufficiently sized local output buffer. The helper writes quotient
  and remainder, with `(0, a)` for divisor zero, and performs no ownership action.
  This is a narrowly extended import gate: the two previous direct-verifier
  declarations survive as exact fallback aliases, rather than being silently
  replaced by an unconditional permission.
- SCC promotion runs in the actual product planner before dependency closure.
  The later observer closure preserves already accepted wrappers and joined
  workers. Eligibility requires an exact two-member, single-result tail cycle;
  terminal call/result identity, arity, generated-name hygiene and parallel
  full-word backedges remain explicit. Ordinary dependency closure and final
  verification still apply. Non-tail or unresolved cycles retain the original
  route. Existing machine evidence shows local backedges for the admitted
  U32/Nat formatting workers, not native recursive calls between their members.
- The [native ABI admission](../../selfhost/build/phase126/native32-abi01.json)
  completes byte-exact layered source replay and binds the old runtime prefix
  plus the reviewed divmod suffix. Its scope explicitly excludes target execution
  and installation. The nine-program run binds
  [`runtime-divmod01`](../../selfhost/build/phase126/runtime-divmod01/report.json),
  not the unextended Phase125 runtime object.

## Reporting boundaries

The representation document correctly separates hosted evidence, native
qualification, installed selection and upstream parity. Retain that separation
until the root-owned native chain and original45 campaign have their own complete
receipts; the completed ABI admission and staged plan are not substitutes.

Three qualifications should remain visible in the final report:

1. “Exact F32 values” describes local representation/rounding and observation
   preservation. It should not be generalized into exact arithmetic NaN-payload
   or floating-environment equivalence. Raw NaN bit transport and guarded
   conversion observations are narrower, concrete claims.
2. The mutual-recursion ordinary fixture is explicitly `@unsafe` at the three
   forward-calling helpers. That is the language's supported permission for these
   user forward laws; it does not relax the IR verifier or establish a general
   termination proof. Record the fixture contract when citing its deep-loop and
   owning-alias evidence.
3. Earlier README checkpoints describe inactive Nat projection and an unqualified
   SCC prototype. Those are historical failures, not source32's status. Likewise,
   a blanket “selected Phase125 runtime” description no longer covers the final
   composition. Preserve the old receipts while distinguishing the now activated,
   checked source32 and its additive runtime helper.

No claim of unrestricted recursion elimination, universal ownership/layout
inference, allocation freedom, broad speedup or successful self-hosting follows
from this review. The excluded typed-private-ABI and tree-shell experiments must
remain excluded from descriptions of the selected implementation.
