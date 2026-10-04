# Remaining general worker coverage after worker23

Read-only structural inspection of the checked modules in
`selfhost/build/phase45/full-preparation-worker23/modules` and their recorded
source files. No compiler change, target execution, new timing or full-corpus
qualification is claimed. This note distinguishes a missing private graph from
an admitted graph that still has optimization opportunities.

## What the actual modules show

Complete JavaScript AST assignments were inspected, not only export lines.
“Contextual root” below means an emitted guarded entry, not a fresh activation
measurement.

| Source | Current emitted contextual roots | Concrete remaining boundary |
| --- | --- | --- |
| Morning | None | `Str.split` and `Str.join.go` return functions after matching; their finish helpers accept and invoke those functions. Function types and local applications are outside complete first-order worker admission. |
| Evening | None | `fpart` constructs `Array<F32>` and calls `Array.swap`. Native Array types and operations are outside the complete private type/native-call proof. Nullary and Unit support alone cannot close this graph. |
| Map/Set operations | `chk_get`, `chk_union` | `chk_order` and `chk_set.s4` call intrinsic `String.eq`, which is absent from the private native whitelist. Canonical Unit is now accepted; it is no longer a sufficient explanation for the remaining generic Set path. |
| RLE roundtrip | `main.out` | The complete root already has worker lowering. Its remaining gap is not evidence of missing first-order coverage. The worker retains private list/tuple construction and recursive components. |
| Generic row | None | `row.probe` returns a `Dp` object containing Array handles; public results admit only scalars/String. Its body also requires Array allocation/read/write. Both boundaries must be addressed for this exact observed entry. |
| Closures | None in the contextual backend | The timed `bench` already uses the inherited total-U32 callback construction/application fusion plan. Absence of a contextual marker is not absence of optimization. General function transport remains outside JW. |

The morning factory types are explicit in the recorded source: `Char ->
List<&2,String>` and `String -> String`; the corresponding function values pass
through helper parameters. The local row has `Array<U32>` in `gen`, `init`, every
cell stage and `Dp`. These are concrete type/operation incompatibilities with
`j_pure_type_head`, `j_pure_native` and `jw_expr`, rather than guessed profiling
causes. The row's former acyclic `umin` wrapper remains excluded by the worker18
profitability rule; reopening that entry is not an Array solution.

For Map/Set, `j_intrinsic` makes `String.eq` a native call rather than a source
instance. `j_pure_call` requires a proved primitive or `j_pure_eligible` callee;
`j_pure_native` currently admits String append, not equality. Therefore a graph
reaching that equality cannot pass this native gate. Other refused helpers, such
as `chk_del`, may have additional independent blockers. This bounded inspection
does not claim to identify the first failed predicate for every helper or promise
that one whitelist change will admit the complete root.

## Shared extensions worth separating

**1. Typed native-operation descriptions.** The cheapest new coverage probe is an
exact String-equality signature/provenance rule, initially retaining its existing
`JWNative` runtime call. The current runtime equality is not merely JavaScript
`===`: it checks well-formed strings and otherwise compares checked code points.
Preserve that behavior, native descriptor dependency and full host/String guards.
Do not silently inline host method calls or label the operation total. A compact
shared operation description could eventually supply admission, result layout,
representation compatibility and emitter behavior, replacing independently
maintained name lists. First qualify one operation, without building an unused
framework or widening unrelated intrinsics.

**2. Known local functions become first-order values before worker proof.** Follow
the [bounded known-function design](known-local-functions.md): represent a finite
lambda site plus evaluated captures, lift its body, and specialize known helper
function parameters. Morning requires helper-parameter transport, not just
immediate lambda application. Keep factory-prefix demand before later call
arguments; retain exact original dependency facts and public fallback. Feed all
new calls into the existing SCC machinery. Unknown callbacks, public returned
closures and ordinary data escape initially refuse the transformation. Existing
callback fusion remains selected until this general path actually replaces it.

**3. Typed private Array operations need ownership and effects.** Add explicit
allocation, read, update and swap operations only for arrays created within a
proved root with supported element types. Track identity/aliasing and evaluation
order across their returned array/value pairs. Reads and writes must not be
classified as movable pure arithmetic. Keep dimensions, index behavior, F32
rounding, errors and public native dependencies exact. The first useful proof can
refuse imported arrays, unknown calls and escapes; it should be reusable by both
U32 and F32 workloads, not tied to a row algorithm. Array effects belong in typed
worker operations and a shared legality analysis, not new string tags in KTerm.

The generic-row observed result still escapes four handles in `Dp`. Supporting
its inner loop does not authorize changing that returned object. A separate
boundary adapter must preserve public Array/record layout, sharing, identity and
getter behavior, or the root must continue to refuse. A scalar-result fixture is
a cheaper initial falsifier for the internal Array pass, not permission to report
the existing object-result benchmark as covered.

**4. Optimize graphs already admitted.** RLE is an appropriate witness for general
scalar replacement of fresh nonescaping tuples and producer/consumer fusion.
Its encoded list is used both for length and expansion, so a single-consumer
rewrite cannot simply erase it. Use explicit use/escape facts, preserve shared
values and errors, and begin with a provably single-use constructor/projection
case. Reuse worker calls, cases and layout facts; keep direct-call/SCC and generic
entry protocols separate. A new public wrapper around each helper would repeat
the row regression rather than optimize this graph.

## Fast falsifiers before broader work

Record a structured refusal reason from the existing bounded proof stages before
raising any limit: unsupported type, native boundary, local callee, public result,
resource exhaustion or selected stronger plan. Such diagnostics are proposed,
not currently present in these receipts. They would prevent confusing existing
fusion with failed compilation or attributing all Set refusals to Unit.

For each extension, use small renamed compositions and require clean results,
actual private entry and exact refusal under dependency/host mutation. String
controls need malformed-surrogate/error behavior; functions need capture and
prefix-order witnesses; Arrays need alias/write/error order; result adapters need
identity and layout witnesses. Run the maintained fast-five canaries, including
the generic row, before a feature-focused screen and the complete corpus.

There are no speed estimates here. Emitted structure identifies legal work to
investigate; qualification and fresh measurement determine coverage and benefit.
