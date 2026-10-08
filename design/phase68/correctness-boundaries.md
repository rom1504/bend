# Phase68: correctness boundaries for faster native lowering

Status: correctness design, with initial observations recorded separately in the
[controls README](../../selfhost/tools/performance/phase68/controls/README.md).
Root executes all compiler, C, and runtime targets under the
existing CPU3/resource guard. Source/data work uses CPU0. Phase67 and earlier
raw results remain immutable.

## Baseline and scope

The installed Phase67 release is the baseline: checked B1 `c76f1113…`, genuine
B2 `cbffd1f8…`, source `e4a4105e…`, pinned upstream `0592662`. It retains the
uniform word representation, continuation runtime, ownership protocol, and
scheduler ABI. Its local atom/scalar lowering saves transport without changing
those contracts. Read the [release report](../../implementation/phase67/README.md),
[conformance scope](../../selfhost/CONFORMANCE.md), and
[native lowering guide](../../docs/self_hosted/native-value-lowering.md).

Six diagnostic native families remain 10.41× upstream in aggregate. They motivate
optimization but do not replace semantic coverage. In particular, the array
benchmark alone cannot establish callback ownership, foreign ABI, failure order,
or scheduler behavior. The 13 unsupported native APIs remain separately named
limitations; a new emitter must neither claim them nor turn them into success.

The next implementation should share language-level arity, type, and ownership
facts between JS and C when their meaning is identical. Target-specific runtime
slots, scalar bit patterns, scheduler entry, and error boundaries remain explicit.
Sharing a helper is justified by its contract, not by similar source spelling.

## Admission and fallback matrix

| Transformation | Initial admissible example | Boundary that needs fallback or a separate proof |
| --- | --- | --- |
| Matcher arity raising | Every match arm exposes the same extra lambda prefix; exact known saturation | Unequal arm prefixes, partial/over-application, foreign entry, bang, erased parameters, unreachable `Efq` tails |
| Direct C return | A sequential known call whose dependency closure stays in the direct convention | Fork or bang anywhere in reachable callees; opaque callbacks; scheduler/IO re-entry; non-tail recursion without a bounded-stack strategy |
| Flat aggregate arguments/results | Closed finite record with known live scalar fields and explicit pack/unpack boundaries | Open type families, recursive type cycles, arrays, IO requests, wide-layout limits, hidden field layouts |
| Scalar replacement | Non-escaping constructor immediately projected or matched, preserving each field's evaluation and ownership | Shared values, partial consumption, captured fields, escaping/foreign values, variant-local reuse, dropped heap fields |
| Callback specialization | Exact known closure code plus a statically known environment, with generic entry preserved | Unknown callback, partial/over-application, erased slots, callback returned or stored, native/foreign callback ABI |
| Borrowing or ownership elision | All uses and last-use boundaries proven for the actual value and representation | Shared arrays, copy-on-write, recursive aggregates, captures outliving frames, error/branch exits and parallel handoff |

Fallback is part of the implementation. A decline must preserve the original
entry path, diagnostic, owned value handoff, and supported program behavior. An
optimization cannot merely generate an unsupported marker for a previously
supported shape. A finite work budget must decline cleanly, never return an
incomplete call/dependency/layout proof as an accepted one.

### Matcher arity is a source fact; live arity is a representation fact

The JS `jd_arity(book,d)` computes source arity from the original typed definition
and caps raising by its type telescope. `jd_live_arity(book,dt(d),arity)` removes
erased slots. Reusing that pair in native lowering can eliminate duplicate
analysis. It must run against the typed original `KDef`, not its erased body.

`nc_erase_mat` stores **live constructor fields + 1** in the emitted match index;
source constructor arity still includes erased fields. Residual arguments enter
the chosen arm after its live constructor fields. Mixing these two counts
misbinds a later callback argument while still producing plausible C.

A positive case in `match-arity-packet.bend` exposes lambdas in both arms. A second
function returns a named function in one arm: its smaller common syntactic prefix
must not be inflated from the other arm. The same source exercises exact calls
and a partially applied function crossing an opaque callback parameter.

`compile/erasure_match_arm` and `compile/erased_partial_closure` separately test
constructor-field erasure and a remaining erased callback argument.
`compile/match_absurd_tail` requires an unreachable matcher closure to be emitted
without executing its failing tail. `compile/over_application` requires remaining
arguments to apply to the actual returned function.

### Evaluation and failure order

Bind nontrivial arguments once and in the chosen language/backend order before
using C expressions. C argument evaluation order cannot supply Bend's ordering.
Do not duplicate an expression while flattening fields, testing tags, or producing
both an ABI box and a scalar representation.

There is a precise open discriminator for arity raising. A function can match an
`IO.OP` request before returning a lambda, while a later supplied argument would
raise Nat overflow. The old curried native path can reach the tag refusal first;
upstream's `def_raise` has no IO.OP exclusion and `emit_args` evaluates supplied
arguments before the raised matcher body. This is a possible inherited native
versus reference difference, not automatically a new regression. Qualify the
actual source against the pinned reference before choosing its expected result;
retain both observations and their compile/runtime phases. Partial application
and explicitly staged lets need separate controls. Do not silently rewrite an
existing golden to make a candidate pass.

The separately versioned [error-order controls](../../selfhost/tools/performance/phase68/controls/error-order-v1/manifest.json)
make this discriminator concrete. Their independent reference goldens are Nat
overflow for saturated and partial named calls, and tag fail-stop for an explicitly
staged full helper call. All three must exit 1 without printing `SECRET`.
The first actual run confirmed the saturated agreement and exposed the partial
native mismatch. Its local-binder staged fixture was invalid in both parsers;
[the corrected source](../../selfhost/tools/performance/phase68/controls/error-order-v2/staged.bend)
uses parameter matching and needs fresh execution. The prospective expectation
is not relabelled as an observed pass.

For malformed raw-core APIs retain the Phase67 exact compile-diagnostic controls:
unbound value plus earlier body error reports `native unbound variable 91`;
unbound value without the earlier error reports `native unbound variable 90`.
These public raw inputs do not establish checked-source semantics, and vice versa.

### Ownership and scalar replacement

A flat result returned by a closure must be unpacked once before sharing it.
The fields then carry the appropriate ownership, rather than two owners of the
same reclaimed box. `compile/closure_record_shared` already caught that failure.

A constructor's unused field may still own an array, closure, or recursive tree.
Removing its allocation does not remove the required sink. At a branch merge,
a spare node consumed in one arm cannot be treated as consumed in another.
`run/list_rebox_generic_sum` is a shape and output witness for this distinction;
its golden alone does not prove the absence of a leak. If a candidate changes
reclamation, add a bounded allocation/reference-count diagnostic or sanitizer
run on that case. Do not treat an unchanged stdout digest as a memory-safety proof.

Tail transfer stages old argument components before writing any destination.
`compile/array_swap_header` checks array permutation; the new
`aggregate-tail-swap.bend` checks a record through a partial callback and three
tail permutations, followed by two surviving uses of the returned record.

Captured affine arrays must outlive the constructing frame and be consumed or
dropped exactly once. `callback-array-owner.bend` stores such a closure inside
a constructor. `run/fn_capture_owns` and `compile/closure_slab_drop` cover retained
captures and disposal. Callback specialization must also retain the public
foreign callback entry (`io/foreign_runtime_apply_tail`).

### Scheduler and error exits

A direct CPU path must not be selected merely because the current invocation has
one thread: a forked task can be drained sequentially, and a dependency can itself
fork or invoke bang. Keep the existing task/continuation entry where required.
Run ownership/fork fixtures with both `--threads 1` and `--threads 4`, GPU off.

The nonsequential error checkpoint removed by an initial Phase67 proposal must
remain at the corresponding boundary. Its mocked shared-error test is a CPU
source diagnostic only; it does not validate device execution. A new direct-return
convention may need a successor to that diagnostic because emitted C markers
change. Preserve the original controller and require a checked exact derivative;
do not relax a failed textual preflight into a passing semantic result.

## Fast gates and independent oracles

The [control catalog](../../selfhost/tools/performance/phase68/controls/catalog-v1.json)
pins 29 sources and their unchanged `#|` goldens. Four are new, unexecuted source
proposals. Their expected values are derived without the compiler:

- `match-arity-packet`: `12*1000000 + 29*10000 + 7*100 + 11 = 12290711`.
- `aggregate-tail-swap`: `(4,9) → (9,5) → (5,10) → (10,6)`; two scores give `1007006`.
- `callback-array-owner`: index 1 of `[17,29]` is `29`; remaining array is consumed.
- `matcher-shared-residual`: two pairwise appends of `"keep"` give `keepkeepkeepkeep`.

Use the smallest selection affected by a candidate:

1. **Arity fast, 6 sources:** common/unequal match prefixes, erased fields, erased
   partial closure, over-application, uncalled absurd tail, and a shared scrutinee/residual alias.
2. **Flat fast, 6 sources:** the new record and captured-array cases, array argument
   swap, partial closure, bang fallback, and shared family data under a fork.
3. **Ownership, 8 sources:** returned record sharing, boxed array clone/swap/drop,
   recursive shared trees/patterns, captured owners, slab drop, dependent family,
   and variant-local reboxing.
4. **Boundary, 9 sources:** IO request refusals/defaults, intrinsic-looking foreign
   effect, foreign callback, erased field call, F32 transport, division by zero,
   and Nat fail-stop.
5. **Integration:** the 29-source union once a candidate survives its fast set,
   plus the maintained raw controls and selected one/four-thread executions.

The independent fixture judge is unchanged. Compare the exact diagnostic/output,
exit code, and checked/refusal phase; `unsupported`, timeout, or compiler crash is
not an acceptable substitute. An expected exit 1 is valid only with its exact
fixture oracle. New sources first need the reference to typecheck and agree with
these independent goldens. Any faulty fixture is corrected as a fresh version,
preserving its attempted bytes and failure receipt.

The source selections feed the existing checked workflow; commands are in the
[controls README](../../selfhost/tools/performance/phase68/controls/README.md).
No new driver or test framework is required. Keep initial runtime measurements
on the Phase67 seven-second executable loop after acquisition. Do not repeat the
slow upstream timing campaign on every source edit.

## Promotion and compiler-in-C checks

Output success alone cannot prove the new path was used. Pair each candidate
screen with an emitted-code/admission census: actual raised calls or direct
returns, removed continuations/boxes, and fallback sites. A positive performance
claim needs at least one actual admitted site in its measured source. Counts
explain the mechanism; only separate runtime clocks measure speed.

Before promotion, require the selected checked image, native source controls,
independent six-family output oracles, broader native boundaries, and exact
source/toolchain/runtime provenance. Preserve JS/frontend qualification only
through an explicit unchanged reachable closure; shared helper edits can require
fresh affected JS controls. Genuine B2 own-source checking and reproduction remain
separate from compiled-program speed.

Compiling the compiler program to C is another boundary, not a relabelled JS B2.
Keep an explicit lineage: source → checked emitter image → emitted C → pinned C
compiler/flags → native compiler executable. Start by compiling small known
programs with that native executable and compare complete emitted modules and
observations, then the 23-source/45-point corpus. Only then attempt native
self-compilation/reproduction. Record C emission, Clang acquisition, executable
startup, compilation request, and generated-program execution separately. The
compiler source's unsafe declaration count continues to imply proof-trust refusal;
self-reproduction is not an independent correctness theorem.
