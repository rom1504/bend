# Generic dispatch in the Phase50 CPU samples

Morning and Evening have substantial sampled cost in generic application and
matching, rather than the named private-entry guards that dominated the earlier
RLE probe. MapSet combines both mechanisms. This is an observational diagnosis;
no proposed optimization has been implemented or shown to remove these costs.

## Exact sampled inputs

Reports are retained at `selfhost/build/phase50/cpu01/<case>/profile-report.json`.
Each report passes its configured result checks. Module paths are
`selfhost/build/phase50/modules/<module-SHA>.mjs`. Hashes below were checked by
data-only reads on CPU 0; no targets were executed for this analysis.

| Case | Module SHA-256 | CPU report SHA-256 |
| --- | --- | --- |
| `test-morning-program` | `f6e11b080d14cb9ba2dd32a5e758909be521eac13adf21c71028cb7b5bffc41e` | `db292917ad10e04572fd93ace215f34801e4b319df1b8bc53e0b66747450469e` |
| `test-evening-program` | `b21b0bbd4e40873907038838d89c559ef73d6c7e599f87e63e94b9f5be77f8b7` | `c05c6efaea52fc31defdb4c5291d808483c3fb6545bbef53ae3ff43e20ad3c57` |
| `test-map-set-ops` | `fe5c1aef40bfeb890960b3e14a1ae9b35ecf11a4881270141c94d61c80e1b345` | `2ea381cfd2288d2629d5cf13bca88f7c072462fc57756f2a63fd1c629aa22a73` |

The reports contain 651 / 627 / 661 samples respectively. Percentages below
are self weights using preceding sample time deltas, including the whole profile
window. They are not invocation counts or instrumented function durations.
Inclusive shares overlap and are deliberately not summed.

| Frame, generated line:column (one-based) | Morning self % | Evening self % | MapSet self % |
| --- | ---: | ---: | ---: |
| `apply`, 75:15 | 22.979 | 18.426 | 17.350 |
| `force`, 61:15 | 9.724 | 9.532 | 9.818 |
| `invokeExact`, 47:21 | 9.701 | 11.734 | 12.145 |
| Three dispatchers combined | 42.404 | 39.693 | 39.313 |
| Anonymous `matcher1` callback, 315:41 | 6.499 | 6.311 | 4.952 |
| Anonymous `matcher` callback, 458:46 | 4.855 | 11.301 | 4.407 |
| `callOwned`, 91:17 | 4.587 | 3.704 | 2.297 |

## What the matching source actually does

Morning and Evening each contain only the `exactCode` declaration, with no
registration call. Consequently `hasExactCodes` remains false: `invokeExact`
lines 48–50 reads `f.code`, then immediately invokes `code.call(f.env,all)`.
Its sampled cost here is ordinary indirect dispatch, not reflection/token
guarding. MapSet registers two roots, `chk_get` and `chk_union`; generic exact
applications in that module additionally test captured WeakSet membership.
Zero sampled named guard frames in Morning/Evening does not mean every generic
type/shape check is free.

`apply` lines 76–85 checks several representations, forms an argument vector
using `bound.concat(args)` or `args.slice()` where required, constructs a new
descriptor for partial application, and slices vectors for overapplication.
`callOwned` avoids copying a fresh vector at its immediate application; that
does not remove vectors at later matcher or bounce boundaries.

`matcher1` line 315 projects fields and returns a fresh `jump` object before
invoking the arm. `matcher` line 458 similarly routes matched or unmatched
branches. `force` lines 64–72 consumes these bounce objects, applies their
vectors without the owned flag, and maintains additional frame/value arrays
when forcing delayed constructor fields. `project` line 311 copies a Tuple
into `[x[0],x[1]]`; line 308 builds a String field vector with two `codePointAt`
calls and a suffix `slice`. These are syntactic allocation/dispatch paths;
V8 may remove some physical allocations.

The hottest identified source callbacks support this mechanism: Morning
`Str.split` at 888:185 contributes 5.151% self weight and recursively transports
a partial function into `Str.split.fin`. Evening `String.cmp` at 854:547
contributes 2.169%, and `String.cmp.fin` at 853:348 contributes 1.360%. MapSet's
corresponding `String.cmp.fin` at 841:348 contributes 1.533%. They use the same
generic matcher/application machinery, with reconstructed strings and tuples.

## Sampled allocation

Fresh `followup01/<case>-<role>-allocation/profile-report.json` observations:

| Case | Candidate estimated bytes/call | TypeScript | Ratio |
| --- | ---: | ---: | ---: |
| Morning | 256,549 | 8,517 | 30.12× |
| Evening | 178,662 | 6,436 | 27.76× |
| MapSet | 1,361,386 | 46,935 | 29.01× |
| Expression128 | 102,142 | 23,350 | 4.37× |

These divide `summary.estimatedBytes` by completed repetitions and include collected objects and harness work. They are not retained heap or exact event counts; sample/tree accounting disagreements remain in the reports. Morning/Evening allocation self weights identify `apply`, `project`, `callOwned`, matcher callbacks and `force`; MapSet additionally samples reflection descriptors. Expression differs: its producer, producer selector, `ctor` and evaluator account for about 89% of sampled allocation self weight.

## V8 traces: an identified inlining limit

All six `trace01` runs (Evening, MapSet and Expression128, candidate/TypeScript) contain **zero deoptimizations between the measure markers**. MapSet has earlier warmup `apply` wrong-map deoptimizations; those are not steady-window deopts.

Evening and MapSet repeatedly refuse to inline `apply` with **reason 5** (70 and 30 notices). The pinned [Node v24.18.0 enum](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/objects/shared-function-info.h) identifies this as `kExceedsBytecodeLimit`; the [inlining heuristic](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/compiler/js-inlining-heuristic.cc) prints that enum directly. This is a demonstrated bytecode-size refusal, not evidence of polymorphic-call refusal or a reason to force optimization.

Both `apply` and `force` complete TurboFan optimization before measurement. `invokeExact` completes Maglev compilation and is explicitly inlined into TurboFan `apply`; no separate TurboFan completion for it appears in these two traces. V8 also inlines `force` into `callOwned`, `ctor` into `force`, and `fn` into matcher factories. Thus the runtime is being optimized, but the large `apply` function still blocks a useful caller boundary.

Exact stdout files are `trace01/00-test-evening-program-candidate/process/stdout.log` (SHA `98a3b11bc00d8e7362def3965061866d6f5c76c7aa56e150cd911230630263c3`) and `trace01/02-test-map-set-ops-candidate/process/stdout.log` (SHA `45dbaae5261f0e1b3926fdc71fc4f3f297aef4c72821c0076c431594bbe023fe`), beneath `selfhost/build/phase50/`. Evening lines 88–89 show refusal, 119 shows `invokeExact` inlining, and 121 completes optimized `apply`; MapSet equivalents are 101–102, 132 and 140.

## Next bounded hypothesis

Test whether separating genuinely cold `apply` branches allows its common path to inline and removes surviving descriptor/vector transport. Preserve all public property-read order, malformed-input behavior, bound/environment hooks and demand semantics. The current evidence identifies a concrete inlining barrier; it does not establish the speedup, safety or ideal shape of that refactor. First compare exact boundary controls and optimized traces, then allocations and clean repeated timing.

A separate producer/consumer experiment is more relevant to Expression's allocation than generic dispatch. Lexer and raytrace profiles are instead dominated by private workers/bodies. No single generic-dispatch change is assumed to solve those workloads, and these instrumented observations are not new clean performance ratios.
