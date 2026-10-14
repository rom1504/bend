# Phase87 Map: unsafe continuation sharing, before a full rebuild

Source investigation and small discriminators, 2026-10-14. Root executed all
targets serially; this lane inspected their retained receipts/output and authored
the source controls. Production/upstream sources and installed artifacts remain
unchanged. The full observer repair below is a design, not an implementation.

## More precise localization

The Phase86 diagnostic locates the fail-stop at `rfc_wrap`, called by generated
`WL_FID_NOA_EVAL_K8169`. The symbol name does not mean the standalone forwarding
definition `noa_eval` lacks its declared type. It has a full `law`; pinned upstream
checks it and uses its elaborated body. The native segment includes inlined
`noa_eval_step` work.

In retained `selfhost/build/phase86/acquire08/compiler.c:200760`, the segment
restores `_k_2` from its stack and calls `term_keep(e, _k_2, 1)`. It then writes the
same value into two separately allocated environments, used by
`FID_NOA_EVAL_C8170` and `FID_NOA_EVAL_C8176`, and calls `FID_NT_CHOOSE`.
This matches the first conditional in `observer-analysis.bend:182`: both
alternative thunk expressions capture the continuation. Thus the current evidence
points to simultaneous closure capture in unsafe source, not simply an untyped
forwarder losing metadata. Native execution of the tiny controls confirms this
mechanism; it does not establish that this is the only full-compiler defect.

Pinned upstream explains the mechanism:

- `bend.ts:233` explicitly excludes unsafe books from its safety claims. Unsafe
  binder domains may use `+` at any kind; `lhs_kind` at647 converts this formation
  demand to `Lone`. This does not grant the runtime generic copying of closures.
- `comp.ts:780` counts `Mat` uses with `Math.max`; other children add their uses.
  Mutually exclusive direct match arms can consume one affine continuation.
  Two eagerly constructed lambda arguments each need their captured value now.
- `comp.ts:1794`–1810, `bind_pop`, emits `term_keep` for an earlier use of an owned
  boxed value. `lay_of` at923 maps function types to `BOX`; merely adding an inline
  function signature does not choose a shareable native function representation.
- `comp.ts:3881`–3913 rejects `TAG_CLO`/`TAG_TSK` in `rfc_wrap`. Do not weaken this
  guard or treat it as a missing reference-count increment.

All paths refer to `selfhost/.bootstrap/upstream-phase66/bend2/` for the immutable
upstream files. The relevant source is our
`selfhost/src/back/native/observer-analysis.bend`, not generated user Map code.

## Small checked acquisition controls

[Lane README](../../selfhost/tools/performance/phase87/map/README.md) specifies
eight fixtures, outcomes and serial guarded commands. The first controls vary
separate-law versus inline signatures and eager branch thunks versus direct
matches. An affine helper that threads the continuation once is an additional
composable remedy. The safe negative removes `@unsafe` and should be rejected.
The last pair separately tests genuinely repeated continuation invocation and a
safe Data encoding of the same operation. All intended positive outputs are83.

Root's `selfhost/build/phase87/map/summary.json` records29 guarded jobs. Seven
sources fully check and emit both targets; all seven raw JS images print83.
`law-eager`, `typed-eager` and `typed-double` exit1 in native execution with
`bend: runtime fail-stop` and no output. `law-match`, `typed-match`,
`typed-thread` and `data-double` print83 natively. The safe eager negative is
rejected at checking with `k (consumed more than once)`; no C/JS is emitted.
This lane independently read all role stdout/stderr and acquisition receipts.

The law-eager/typed-eager generated C files are byte-identical, as are their JS
files. The law-match/typed-match C/JS pairs are also byte-identical. An inline
signature alone does not fix this boundary. Direct exclusive matching avoids
double capture; an explicit Data environment permits real reuse.

Summed target wall time is15.842s, campaign span22.651s, maximum process-tree
RSS240.92MiB. Each positive C image is76–80KB and each O2 build takes0.42–0.54s.
This is a much cheaper correctness discriminator than a259s full image rebuild.
It is not a speed benchmark or proof of full Map correctness.

These pure small entries avoid full compiler acquisition, Base preparation in a
compiler request, filesystem effects and raw-JS compatibility derivatives. Their
checked-emission/build/run timings are preserved separately. The acquisition
script pins current upstream identities, copies input source/script, records all
phases, refuses an existing output directory and never executes generated code.

## Why a syntactic branch fix is not complete

`noa_match_fields` at315–320 intentionally evaluates a symbolic yes branch and,
if it succeeds, a symbolic no branch. Both evaluations capture and invoke the
same `k`. This is actual reuse across two computations, not just an implementation
accident of `nt_choose`. Direct matching throughout the dispatch chain would
remove the first visible fail-stop but cannot by itself make this code affine.

The most promising complete remedy is narrowly defunctionalizing the observer's
continuations: replace `NO_Input -> NO_Analysis` with an explicit Data type of
frames containing existing Data values and a tail frame, and interpret one frame
when a value arrives. The observer already represents source-program closures as
KTerm data (`OL`/`OM`); this proposal concerns the compiler implementation's own
continuations. It is not a new whole-compiler IR or a JS/C backend fork.

Concrete frame families visible in current source are argument-list evaluation,
argument-list application, application function/argument stages, constructor
completion, let-body evaluation, reference-argument application, virtual match
application, symbolic match yes/no application, and final observation. Stored
environments are NO_Context, KTerm, lists, fresh/fuel scalars and other frames—all
already Data except the current host closure. Sharing frames then follows the
runtime's supported data ownership path. Preserve the exact current evaluation
order, fresh/fuel propagation, branch fact environments, first-error behavior and
the point at which `noa_match_join` evaluates its second branch.

The cheap `typed-double` versus `data-double` gate passes its predicted contract.
Next use a standalone observer harness that compares complete NO_Analysis products
against unchanged JS on representative sources. Only after those pass should one revised
full compiler image be built and Map tried. A successful tiny control proves the
ownership mechanism, not complete Map correctness, exact generated C, or speed.
There is no supported speed-gain estimate yet; avoiding unsupported closure
sharing is first a correctness prerequisite. A narrowly scoped implementation
looks feasible in hours rather than a backend redesign, but its output identity
and allocation cost must be measured.

## Full source audit: eight frames, not a whole new evaluator

The exact continuation set can be smaller than the broad family list above.
`NO_Context` never changes during one analysis and can stay a separate argument to
`noa_continue(ctx, continuation, input)`, rather than occupying every frame.
One recursive Data type with the following eight constructors replaces all
`NO_Input -> NO_Analysis` values. Every nonterminal constructor stores a `next`
continuation in addition to the fields below. No host closures occur in a frame.

| Proposed frame | Stored fields besides `next` | Existing closure sites and action on input |
|---|---|---|
|`Finish`|none; no `next`|452 inner lambda: `noa_finish(ctx, input)`|
|`EvalArgs`|remaining terms, lexical env, source-reference stack, reversed argument accumulator|167: prepend input.value to the accumulator, then evaluate the remaining arguments with input facts/fresh/fuel|
|`ApplyArgs`|remaining argument values|173,276,302,318,452 outer lambda: apply input.value to those values, using input facts/fresh/fuel|
|`AppFunction`|argument source term, lexical env, reference stack|186 first lambda: evaluate the argument, pushing `AppArgument(input.value, next)`|
|`AppArgument`|evaluated function value|186 second lambda: apply the saved function to input.value|
|`Constructor`|constructor name|187: pass the complete input through `noa_constructor`|
|`LetBody`|body source term, binder ID, lexical env, reference stack|190: bind input.value in the saved env and evaluate the body|
|`ApplyOne`|one saved argument value|303,320: apply input.value to the saved argument|

All stored fields are existing KTerm/list/String/U32 data. Each action threads
the *current* input's facts/fresh/fuel, never a stale captured version. There are
13 continuation lambda expressions in these sites, reduced to eight reusable
shapes through `ApplyArgs` and `ApplyOne`. Initial analysis becomes evaluation
with `ApplyArgs(params, Finish)`.

Keep `noa_prepend`, `noa_match_join` and `noa_recur_done` on the ordinary call
stack for this bounded repair. They do not need extra frame constructors:
`noa_primitive` still wraps the result of `noa_continue`, `noa_match_fields` still
evaluates yes then no, and `noa_recur` still validates the full continuation
result before emitting `NO_Loop`. No dispatcher fuel is charged: only the same
existing `noa_eval`/`noa_apply` entry points decrement it. Existing `nt_choose`
closures may now capture a Data continuation safely, so converting every choice
to a direct match is not required for correctness of this repair.

The smallest change surface is this one module: add the Data type and dispatcher,
change continuation parameter types in the three laws and14 definitions, replace
the13 lambdas by constructors and the10 direct `k(...)` applications by dispatch.
The public `noa_analyze` result, permission boundary, schema/emitter/plan modules
and JS/C compilation paths stay identical. These counts describe the inspected
source; they are not a completed patch or a qualified simplification gain.

## Why plain direct returns are not the smaller equivalent change

A function returning only `NO_Input` cannot express all current outcomes:

1. A primitive must emit an enclosing `NO_Let` around the *remaining computation*.
   A returned value plus a statement list could represent this case alone.
2. A symbolic match must run the remaining computation under each branch's facts.
   The no branch starts with fresh/fuel **after the entire yes continuation**,
   and does not run when that continuation returns an error. Evaluating both
   branches first and then continuing changes variable numbering, budget behavior,
   refusal precedence and output; returning a single merged value also loses
   path-specific origin/fact information.
3. `noa_recur` runs the continuation with a distinguished result marker and
   requires its complete result to be exactly `NO_Return(marker)` before emitting
   `NO_Loop`. Returning only the recursive call's apparent value cannot retain this
   tailness proof. `Efq` and failed paths also terminate without calling k.

A direct-style result tree with value leaves, statement nodes, match nodes,
delayed branch work and recursive-tail obligations could encode these effects,
but binding a remaining computation across it recreates the continuation problem.
It adds an intermediate representation and a traversal, rather than being the
plain NO_Input/NO_Analysis return simplification hoped for here. Evaluating ahead
and renumbering later risks changing the bounded observer's accepted cases.

Two smaller alternatives are valid only under explicit narrower contracts:
direct matching or the tested `choose_k` helper solves exclusively chosen
branches; a branch-free direct evaluator could handle a restricted subset and
fall back to another *native-safe* evaluator on symbolic matches. The latter
adds a second path and does not solve the current full Map request by itself.
For equivalent full functionality, eight typed Data frames are the smallest
concrete repair identified in this audit. Test complete analysis values and exact
C before making any performance or broad-correctness claim.
