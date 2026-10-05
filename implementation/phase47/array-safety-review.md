# Private array storage: independent safety review

Status: static contract review, before production acquisition or qualification.
The saved-output experiment establishes an opportunity, not permission to change
the public array ABI. Its preserved `array-timing01/report.json` has 20 samples:
median 680 ms original, 683 ms expanded helper, 186 ms reused view, and 186 ms
reused view plus length. Thus the measured 3.656× gain is associated with backing
view reuse; there is no measured additional benefit from caching length.

The recommended first implementation is a **private raw backing representation
inside a completely proved scalar-input/scalar-output region**. This is simpler
than a persistent cache, allocation registry or public ownership marker. It uses
the existing region plan and adds an explicit representation capability. Public
array values and ordinary native helpers retain their existing representation.

## Existing permissions are insufficient

The current [array helpers](../../selfhost/src/runtime/js/base.mjs) are observable:
`arraydata(a)` can read `a.array` twice, invoke getters, flatten tree storage, or
throw. Each read/write converts its index through live `Number`. The subsequent
length read occurs **after** that conversion. `Array.new` uses live `Number`,
`Number.isSafeInteger`, global `Array`, and `Array.prototype.fill`; a fill hook can
leak the allocation, return a Proxy, reenter, or replace a later conversion hook.

In [runtime core](../../selfhost/src/runtime/js/core.mjs), `localGuard` checks
source/native descriptors and runtime protocol markers. It does not guard those
allocation/conversion hooks. `regionHostGuard` checks the Number/Array globals
and prototype key sets, but its descriptor lists omit `fill` and
`Number.isSafeInteger`. Replacing an existing prototype method does not change
the prototype key list. Moreover, `regionHostGuard` returns immediately when
`regionProof` is non-null. That proof is not an array-storage capability.

The [existing supported contract](../../selfhost/docs/ARCHITECTURE.md) assumes
standard host intrinsics at module initialization and supports post-import
mutation through refusal/fallback. This proposal uses that same premise. It
does not assume that post-import callbacks are absent merely because the Bend
source is first-order.

## Smallest useful static proof

Consume the successful [region plan](../../selfhost/src/back/js/region.bend),
including all of its helper bodies and branches, rather than recognize emitted
JavaScript text or a benchmark family. Fail closed on an unknown operation or
analysis-budget exhaustion. Require all of the following:

- The public root accepts and returns canonical scalars. No caller-provided
  array, record, function or returned composite crosses this first boundary.
- Every private array originates in a canonical, already type-checked
  `Array.new<U32>` operation within this invocation. Reject `ALeaf`/`ANode`
  construction and matching, imported array values and unknown origins.
- Only canonical `Array.new/get/set`, proved private calls, local tuple transport
  and an explicit safe scalar-operation set use these arrays. Reject
  `JGeneric`/`JResidual`, foreign calls, arbitrary callbacks and unproved natives.
  Existing region admission alone is broader than this operation set.
- No permitted operation exposes storage, replaces a backing property or resizes
  it. Internal aliases are allowed: they must keep referring to the same backing
  object. Distinct allocations must remain distinct.
- Each retained scalar operation is either host-free on proved primitive inputs
  or uses an intrinsic covered by the fresh host capability. Do not infer this
  from a scalar result type or a broad purity flag.

This proof can allow array-valued private helper results and state tuples: they
stay inside the complete region. The restriction is on the public boundary and
unknown consumers, not on every internal function signature.

## Dynamic guard and ordering

Use captured native reflection to check current identities without invoking
getters. The capability must check the standard host/protocol conditions afresh,
plus the original own data descriptors for `Array.prototype.fill` and
`Number.isSafeInteger`. It must cover global Number/Array identities, relevant
prototype links, and the absence of added inherited numeric setters. Native fill
uses ordinary element assignment, so an inherited numeric setter can otherwise
expose a supposedly fresh allocation.

The capability must **not** inherit success from `regionProof`. In particular,
checking only at the end of an entry condition is insufficient if earlier input
or dependency checks invoke live reflection. A replaced reflection method can
alter an already-checked helper and restore itself before that final host check.
The source proof would then be stale despite clean final intrinsic identities.
Run a fresh, non-bypassing host check before such checks; an additional allocation
check may run last. Alternatively, make all preceding checks use captured,
non-observing primitives. Do not publish a capability based on a stale guard.

Under the complete no-callback graph proof, successful entry checks remain valid
through the synchronous private execution: no permitted operation can install
new hooks or leak storage. A root-entry check is sufficient only with that
complete proof. A more permissive path that executes a custom conversion first
would need a new proof at the actual allocation boundary and precise treatment
of every later callback; that is unnecessary complexity for this first pass.

Reject before evaluating the optimized source body and use the existing generic
fallback, emitted with the original, unflagged compiler environment. Do not
restart source evaluation after a failed mid-body check: allocation and callback
effects may already have happened.

## Representation and evaluation laws

At the original allocation expression, `arrayfill(value, depth, '^').array`
obtains the raw backing array from a fresh inert handle. The allocation, depth
conversion, validation and fill remain in their original order. Inside the
proved region, the raw backing array stands for that handle. A write returns
the same backing array; a read returns/forwards that same identity alongside the
element. Keep the original Number conversion and subsequent length lookup for
each read and write. No length cache is needed for the observed gain.

All three existing consumers must agree on the private layout:
`j_region_native_array`, `j_region_read_definition` and
`j_region_inline_output`. Audit the tuple/vector and nested-loop paths that carry
these values as well. The representation flag must not reach ordinary emission,
public constructors/projections, unrelated roots or the fallback.

Preserve left-to-right argument evaluation: array, index and value expressions
are evaluated before the write body. Read demand remains at its original point,
including an unused scalar result consumed by a tuple match. A zero-trip loop
must not acquire storage speculatively; an allocation already present before
that loop still executes. Do not move allocation into or out of the loop.

There is no mutable module-level view cache or permission flag. Per-invocation
storage therefore stays isolated under Error-hook reentry. Existing `bad`
suspends `regionProof` before calling Error and always throws; a failing outer
operation cannot resume with assumptions invalidated by that hook. Preserve
this error behavior rather than treating errors as total scalar operations.

## Required evidence and extension boundary

The independent [control plan](control-plan.md) covers values, zero-trip demand,
public aliases/getters/proxies, fill/Number mutation, storage replacement,
callbacks, native/source descriptor changes and errors. Require a separate
mechanism witness that the renamed closed root actually uses the new private
layout; ordinary agreement alone does not test its correctness. Add guard-order
self-restoration and inherited numeric-setter controls, and retain the existing
Phase30/36 array and callback gates.

Qualification must show that public, escaped and opaque-call roots retain their
observations, while the admitted root has no repeated `arraydata` call. Then
measure a freshly checked compiler output with the same paired protocol, plus
the maintained canaries and representative corpus. The saved-output 3.656× is
neither a production speed claim nor an estimate for all Bend programs.

Later extensions should add explicit allocation/read/write/escape effects to a
shared typed operation plan. Public-array view caching, invalidation across
callbacks, mutable length optimization and arbitrary array-native admission
each need additional facts. They are separate work, not implicit consequences
of this first private representation.

## Frozen `source-array01` static verdict

**Static PASS**, comparing the actual frozen Phase47 `source-array01` files
against Phase45 `source-worker23`; no target execution or acquisition was
performed by this reviewer. Checked compilation, activation and runtime controls
remain root-owned qualification steps.

The implementation preserves the entire old root path and adds a separately
scoped raw-helper closure, allocated once. Only an exact entry with a fresh
`arrayViewHostGuard`, canonical scalar inputs and the existing source dependency
guard can call it. The fresh guard refuses non-null `regionProof`, invokes the
captured full host checks before live validation, checks the Object prototype
parent, and adds the missing fill/safe-integer identities. Refusal proceeds
through the unchanged old checks and body, retaining their observations.

The new bounded audit consumes the root and every helper plan. Unknown native,
generic/residual, fold/producer and callback plans fail closed. Arrays can only
arise from the canonical new operation; array constructors and destructuring are
refused. The private BookCache marker preserves the original source index and
planner payload and reaches all three array consumers. It does not reach the
old fallback. Raw aliases, argument evaluation, Number-before-length reads and
zero-trip demand match the laws above. No new mutable global permission exists.

| Frozen path under `source-array01` | SHA256 |
| --- | --- |
| `src/back/js/array-view.bend` | `512bb90af47b5840aaa0aa9fa8223293d7299629bd01c87b3ba24b0de8e66eb4` |
| `src/back/js/region.bend` | `390ed091745f8fd11c0f8ab6760eda182e07373d60dd621fa66ec3541cbeb3e4` |
| `src/back/js/emit.bend` | `26ba63314b7d537bf41a232b7fd7f72461136152bc49688b8b7d346e424fe515` |
| `src/runtime/js/core.mjs` | `e7637bff2965863c5c0279694cc560dac6f56a8f4f6672fffaa5a72e07f15e2a` |
| `src/runtime.mjs` | `82781f5c8cecb14df370112a210974f55d52e32fa34cd71bfb03caec5e4c1fc5` |

The frozen `source-array02` ordered-write successor also passes static review.
It changes only the private statement consumer: exactly four canonical native
arguments are captured left-to-right; the erased argument becomes null without
evaluating its source. Conversion, length lookup and mutation then occur in the
same order as the former IIFE, followed by return/assignment of the captured
array. Consumers are existing return or mutable vector-slot destinations.
Each store has a lexical block for reserved temporaries; unsupported expressions
and unflagged emission retain the previous text. The runtime is unchanged.
This is a source review, not a measured gain or runtime qualification.

| Frozen path under `source-array02` | SHA256 |
| --- | --- |
| `src/back/js/array-view.bend` | `5dc15787ee2d28631300a0f336f86a6660dff631ac7f0e2a3c529c54c9416f67` |
| `src/back/js/region.bend` | `b66e2aa8f894784e1c7cf8860e71746cf389ea236d4dfddf927d09c9bc583595` |

The next canonical-native-App checkpoint also passes static review:
`array-view.bend` SHA256
`a76d93ef549a3ab0d9146de24ce3ae108cfab064a25036ae24a21aede6bba9db`.
An Array source App is admitted only with the existing exact native
signature/owner/arity/erased-U32 proof and its original native dependency in the
guarded helper set. Only that proof permits skipping the erased operand during
the executable audit. After complete admission, the root and every nonnative
helper normalize these saturated Apps to `JNative` consistently inside the raw
closure. Existing native nodes recurse too; Ann/Unpack type metadata and native
definition bodies remain unchanged. The original closure and fallback are not
normalized. No mixed handle/backing route was found in this bounded review;
checked acquisition and actual activation remain separate requirements.

The frozen `source-array04` helper-App successor passes static review as well:
`array-view.bend` SHA256
`378b326089cdb3a662e9fa981d91a03c4700e86d4ecdd006f3416d7dcdf1be19`.
Only collected, nonnative, template-free helpers with positive arity at most 32
and exactly that many arguments acquire `JCall`. The complete original region
proof supplies the typed live telescope, body and dependency guards; this rule
does not admit unknown or partially applied helpers.

The normalizer threads the current Mat helper's name. Its self Apps retain the
source shape consumed by the existing Nat countdown-tail emitter; the original
Nat shape and active-chain proof still govern those sites. Root calls and every
other helper call use the private ABI, including calls to a different Mat helper.
Preserving all Mat Apps would be unsafe here: an ordinary root expression could
dispatch through a public descriptor with a raw backing argument. Arguments of
the retained self-tail call still normalize recursively, so nested private work
uses the same layout. No new recursion admission, public ABI or fallback change
was found. This verdict is static and precedes root-owned array04 execution.
