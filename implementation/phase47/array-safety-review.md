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

## Follow-up: a nested private tree bypasses the optimized public root

Read-only inspection of checked array04's emitted `editdist.mjs` falsifies the
proposed explanation that an inherited `regionProof` alone prevents the
positive-depth workload from improving. `G.bench` calls `G.batch`. The latter's
private scalar-tree body calls its own handle-based private `pair` helper; its
complete assignment contains neither `regionProofOpen` nor an array-view guard
or raw-root marker. The separate public `G.pair` assignment does contain one raw
root. Changing only the nested-proof guard cannot affect that private tree leaf.
This is structural evidence, not an executed activation or timing result.

Fresh nested admission is a separate possible extension. It would require both
the full host capability and source dependencies to be checked afresh, in the
order host capability, original scalar input validation, source guard, body.
An explicit fresh mode in the host/local/scalar guard functions can bypass only
their inherited-proof shortcuts. Temporarily clearing proof solely around the
local guard is also defensible after a complete fresh host check, provided a
`finally` restores it before both body and fallback. The remaining checks then
use verified native reflection on fixed original objects; accessor or Proxy
replacements fail identity checks before traversal. Checking fresh host state
while still accepting `regionProofCovers` for source dependencies is insufficient.
Neither extension was implemented or executed by this review.

## Composition at the existing private tree entry

The proposed adapter and its subsequent two-file implementation pass independent
static review. The shared audit now accepts an explicit list of already-checked
terms: the tree's zero arm and successor/combiner. Its original complete helper
list is audited as before. The root is added only to the allowed-call lookup,
so the existing tree proof authorizes its two saturated self children without
adding an unchecked source body to the helper set.

The additional lexical closure shares the existing tree frame emitter. It
normalizes every private helper and both checked arms consistently, retaining
the root self Apps that the frame emitter consumes. The wrapper passes the same
Succ predecessor; only the original `j_tree_body` adds one to restore the current
depth. Parallel children, saved parent arguments and left/right unwind order
therefore retain their existing implementation. The combiner remains restricted
to the two child results, with no parent capture.

Entry uses fresh array host permission, original scalar/predecessor validation,
the original predecessor bound `<32n`, and the original full dependency guard.
The zero matcher and complete old tree/generic path are retained. No inherited
proof shortcut is relaxed, no proof is opened by the new branch, and the runtime
is unchanged. As with the ordinary raw-array root, unsupported nodes or audit
fuel exhaustion refuse the representation change. Extra lexical declarations
increase generated size and compiler work; this review establishes no speed gain.

| Reviewed file | SHA256 |
| --- | --- |
| `src/back/js/array-view.bend` | `7509f9d5f27c888064b5927bc958d74a5b1c0492619ab576ee878a7bef56ea95` |
| `src/back/js/tree.bend` | `4936fad0f0ea6e49200e21c9751d5c3fa52c139732cacf19dd79aee88a325b2c` |

The separately prepared counter producer also passes static review: exact
whole-module hashes justify its fixed assignment anchors, and its observations
are explicitly ineligible for timing or host-introspection claims. The renamed
v4 fixture was corrected before consumption to combine only child results. Its
159 finite oracles, separate raw-tree/leaf counters, zero-depth control and ten
host/source mutation scenarios supplement the existing public-storage and
reflection controls. This review executed no target program.

## Integer-only host guard subtype

The subsequent five-file guard refinement passes static review against frozen
array05. It retains full host checking whenever the canonical root signature,
original root type/body, either checked tree arm, or any helper's canonical
signature/type/body contains floating use. `j_region_float_signature` normalizes
parameter types before testing them, so an unused aliased F32 argument still
requires the full guard before its Math.fround/Number.isNaN input predicate.

For an admitted integer-only graph, the existing reduced host set still checks
global identities, reflection, WeakSet operations, array protocols and prototype
keys, Number.isInteger and Math.imul. The new separate captured Math.floor data
descriptor check covers U32.div. Number/BigInt conversions and existing exact
Array.fill/Number.isSafeInteger checks cover the remaining native operations.
The closed-array audit refuses F32 literals, F32 operations, U32.to_f32 and
unknown native operations; none of the omitted DataView/floating methods is
reachable from this subtype. No assumption is made that an unused floating
parameter is absent merely because its body ignores it.

Global Math identity is checked before reading its floor descriptor through
captured reflection, so a replacement/accessor cannot run during admission.
Non-null inherited proof still refuses. Both entry routes keep the original
host-before-input-before-dependency ordering and complete fallback. Full mode
retains its previous emitted guard spelling; the two runtime copies contain the
same change. This is a static safety result, not an executed performance result.

| Reviewed file | SHA256 |
| --- | --- |
| `src/back/js/array-view.bend` | `f1774c1b289c3707a010a89757b166180e54d77bc06304615b5004af1fccbb18` |
| `src/back/js/region.bend` | `6ee245756d76d5dfc285b5da5af9f974ef93bcd13e62b308491c16d2a675526d` |
| `src/back/js/tree.bend` | `d5862f37796aee0908bc623492e54a9ece7a7ab4f34072e080e483402955798b` |
| `src/runtime/js/core.mjs` | `d427d2433cee7585d002ea178a694e552deb7cbf8e21ce4caaf9804a1463e971` |
| `src/runtime.mjs` | `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` |
