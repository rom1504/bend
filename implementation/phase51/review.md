# Phase51 independent boundary review

This is a static review and a proposed control list, not executed qualification.
The starting implementation is [core.mjs](../../selfhost/src/runtime/js/core.mjs).
Root owns all target execution. No production file was changed by this review.

## Integrated candidate checkpoint

Static review of `source-candidate01` against frozen Phase48 RNFA04 passes.
The inventories contain the same 250 source, tool and test files. Exactly three
files differ: `core.mjs` (`d1799585…`), its assembled runtime (`3158f543…`), and
`jpure.bend` (`f625c524…`). The differences are the IO-only helper extraction and
the same-entry String token described below; the other dispatcher experiments
are not part of this candidate.

The IO helper preserves the two original `io` reads, argument demand, delayed
closure reads, and recursive `apply` call with its original default ownership.
The token suppresses only the repeated String-family scan. Every argument slot
is read before fresh full host and String checks. Between those checks and
`localGuard`, the compiler emits only primitive type tests and host-validated
numeric predicates on cached slots; an unknown input type emits `false`.
Explicit `regionProof===null` prevents inheriting an older host proof. All source,
prototype and call checks remain, as does the original generic fallback.
The IO helper cannot run inside this synchronous proof interval, so composing
the two changes introduces no new callback gap.

This checkpoint is source review, not final qualification. Root's fresh checked
build, maintained runtime suites and semantic controllers must bind the combined
API and runtime. The view/tree controls must retain their historical Phase47
predecessors for their explicit old-hook trace assertions; RNFA04 is not a
substitute for those particular baseline arguments. Consumed prototype producers
and controllers remain unchanged.

The subsequent [qualification](qualification.md) and [release report](README.md)
record completion of these requirements; this document retains the static review.

The proposed dispatcher extraction is a good narrow first experiment: keep the
existing prefix, argument formation, exact entry and partial application in
`apply`, and move whole IO, type, nonfunction and overflow bodies into helpers.
Passing the already evaluated `f`, `args` or `all` variables introduces no new
property reads. Preserve the expressions inside those bodies exactly; caching
their repeated reads is a separate, substantially less trivial change.

## Dispatch controls that distinguish plausible wrong implementations

Compare original and derivative runtime observations, including event sequence,
returned values and descriptor fields, thrown object identity, and mutations to
input arrays. Use a fresh module per prototype/global mutation and restore hooks
in `finally`. Logging must use captured operations or scalar strings when array
prototype hooks are installed.

| Named control | Setup and distinguishing observation |
| --- | --- |
| `changing-io` | An `io` getter returns false on the first read and true on the second. Both reads must remain; the second branch creates the IO adapter. Also exercise first-read true with an `args.length` getter returning zero. |
| `changing-type-name` | A `typeName` getter changes between admission and object construction. The returned object's name uses the second read. `typeArgs` and both iterators remain demanded in their original order. |
| `type-iterator-close` | Make the type-argument iterator throw on a later element, and give the argument iterator a logging getter. The argument iterator must not be requested first. Use a closing/throwing iterator where the original spread actually closes it; do not invent a universal close requirement. |
| `changing-bound` | `f.bound` returns one object for `.length` and another for `.concat(args)`. The latter is the concat receiver. A custom concat can return an exotic `all` object; do not assume its result is an ordinary Array. |
| `copy-before-arity` | An `args.slice` getter or method changes `f.code` and `f.arity`. The unchanged argument-copy operation precedes the saturation test. Public input mutation must still be isolated. |
| `code-call-env-order` | Use getters for `f.code`, the returned function's `.call`, and `f.env`; let each mutate the next. The initial code truthiness test and invocation read are distinct. Invocation resolves `.call` before `.env`. |
| `partial-fresh-descriptor` | A partial application rereads arity/code/env and returns a fresh descriptor whose bound vector follows the original copy/concat path. Mutating the original prefix after creation must not mutate the partial's stored prefix. |
| `overflow-changing-arity` | The first code invocation changes `f.arity`; a returned bounce changes it again when forced. Preserve the post-call comparison and the still-later slice-bound read after `force(r)`. Do not cache the original arity. |
| `overflow-slice-order` | An exotic `all.slice` getter records its receiver and index. The first slice is resolved after code/call/env and before invoking the code; the second slice is resolved after forcing the first result. |
| `holes-and-species` | Sparse input, inherited numeric getter, Array subclass `Symbol.species`, custom slice and bound `Symbol.isConcatSpreadable` must retain original copying, holes, prototype and demand behavior. Do not replace slice/concat with spread or an index loop in this experiment. |
| `null-and-nonfunction` | `apply(null,args)` must not touch args. A nonfunction with zero arguments returns unchanged; with arguments it performs the original `String(f)` then `bad` path. Throwing coercion and global Error reentry distinguish reordering. |
| `io-continuation` | Exercise `pureValue` getter versus request construction and continuation descriptor reuse. Moving the IO body must keep its later closure reads of the original f, rather than snapshotting fields at adapter creation. |

Retain [test-apply.mjs](../../selfhost/src/runtime/js/test-apply.mjs), which already
covers owned versus public vectors, partial ownership, oversaturation,
constructor forcing order and IO. Add the cases above to an isolated runtime
controller rather than changing historical consumed controls. Exact/private
entry controls should additionally cover raw `.code`, `.code.call`, `new code`,
argument-getter reentry and mutation of Function.prototype.call; the one-use
entry token and its `finally` restoration must remain unchanged.

## Guard review obligations and cheap falsifiers

The existing premise is standard host initialization with supported post-import
mutation. Do not introduce a new stable-host premise or cached cross-call
permission. A smaller guard needs an original-source **and original-runtime**
effect argument; absence from optimized output or a dependency-name list alone
does not establish that an omitted hook is unobservable.

- `self-restoring-reflection`: a replacement reflection function restores itself
  while changing a later source descriptor. Trusted host validation must precede
  mutable dependency inspection. A partly collected proof must not be reused.
- `source-proxy`: replace a G slot with a getter or Proxy; mutate the original
  descriptor's code/env/bound/prototype separately. Compare fallback event order
  and verify refusal without unexpectedly traversing the replacement Proxy.
- `marker-on-primitive`: add bounce/build/request/code hooks on Boolean, Number,
  BigInt, Object or Array prototypes, chosen for values the original path forces.
  A scalar result does not by itself remove original forcing observations.
- `late-allocation-hook`: Array.fill or Number.isSafeInteger mutates a helper's
  code during allocation. The Phase48 fresh array fence must not be weakened.
- `error-reentry`: replace Error with a hook that calls the same public root.
  `bad` suspends regionProof during the hook, and all outer state restores on
  throw. Normal replay after the error must still qualify independently.
- `retained-float-view`: an earlier generic DataView hook retains the shared view,
  then restores methods. Later finite-literal writes remain observable; a host
  identity check is not an ownership proof for that view.
- `guard-vector-hooks`: removing temporary arrays or `.every` from scalarGuard
  is only locally justified after a fresh trusted host fence and inert argument
  validation. scalarGuard/localGuard have other call sites; do not globally
  replace their observable hook behavior based on one guarded caller.

The historical [host-entry controls](../../selfhost/tools/performance/phase45/exact-entry-host-hooks-controls-v1.mjs),
[array fill controls](../../selfhost/tools/performance/phase48/controls/array-fill-boundary-controls-v1.mjs)
and [self-restoring reflection controls](../../selfhost/tools/performance/phase48/controls/array-view-controls-v4.mjs)
provide reusable examples. Historical baseline quirks are not automatically the
semantic oracle: retain an independently justified ordinary-source lane when a
known internal guard hook is the behavior being corrected, as those controls do.

The first dispatcher slice needs no admission widening or guard narrowing.
Review source equivalence first, then exact boundary controls, actual optimized
inlining, allocation estimates and separate clean timing. A bytecode-size refusal
is evidence for the experiment, not proof that a split will be faster.
