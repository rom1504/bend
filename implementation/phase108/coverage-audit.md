# Phase108 source coverage and the shortest useful loop

This is a source inspection and gate design, dated 2026-10-18. No compiler image,
generated target, ownership control or benchmark was run for this audit. The
current Phase107 result remains a scalar subset. The next meaningful increment
is the production ownership boundary for unchanged `nt_reverse<String>`, followed
by the independently held-out `String.reverse.go`, then the lexer and compiler.

The Phase108 campaign subsequently selected a second route for the immediate
full-image attempt: retain the existing Bend semantic/C backend, supply a
portable CPU runtime through its supported runtime-template input, and compile
the resulting C through **cproc's C11 frontend → QBE**. This reuses the existing
erasure, ownership and closure decisions rather than implementing them in the
scalar Nx lowerer. The source coverage and frozen controls below apply to both
routes. The structured-capture section describes the direct KTerm→Nx route's
remaining architectural boundary; it is not a prerequisite for testing cproc.
Do not call the cproc route direct KTerm→Nx lowering or QBE self-hosting. Its
critical new contracts are C11/runtime compatibility and the portable trampoline.
Generated compiler algorithm bodies must remain the existing Bend backend's
output; runtime substitution happens before emission, not by rewriting those
bodies afterward.

## Exact compiler denominator

The active native selection is
`selfhost/tools/native/selection.json`, whose admission is Phase102
`native-chain04/admission.json` (`a8a7abd1…`, 1,809,272 bytes). Its prepared compiler
source is `selfhost/build/phase102/projection-cost-source01/compiler.bend`,
**SHA256 `63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`**,
1,788,947 bytes. This exact source identity is also recorded by
`selfhost/build/phase103/cli06/inputs.json` and
`selfhost/build/phase107/native-source04/manifest.json`.

The latter adds the scalar Nx lowerer, passes and QBE emitter to that compiler;
its resulting source is 1,895,210 bytes (`00446757…`). The public Phase103 CLI
source is a different artifact, 1,798,399 bytes (`bb65ec3c…`), with the native host
entry and authenticated OS effects. Choose and freeze the intended full-image
entry; these are not interchangeable qualification denominators.

A lexical scan of the selected 1,788,947-byte source, masking comments and
String/Char literals, counts **4,087 `def`, 159 `type`, and 658 `law`
declarations**. These are source inventory counts, not reachable runtime function
counts, monomorphization counts, or checked feature coverage. Runtime C text
embedded in String literals is not evidence that a Bend function uses that C
feature. The much smaller `selfhost/src/compiler.json` identifies maintained
modules but omits added host/cache code in the selected prepared source.

| Required capability | Actual compiler source witness | What must be established |
| --- | --- | --- |
| Recursive general ADTs; lists, Strings, products, unions and nested matches | `src/core/term.bend:25` (`KTerm`, `KLambda`, `KLiteral`, `KDef`, index nodes); `src/front/lexer.bend:2` (`FToken`, `FScanned`) | Checked identity and live fields, tagged values, generic constructor build/take, exact branch demand. |
| Erased polymorphism and quantities | `src/core/term.bend:4` (`kc(-A: Type, …)`), `src/back/native/text.bend:40` (`nt_reverse(-A: Data, …)`) | Preserve checked erasure, quantity-zero arguments and binder IDs; no inference from surface argument position. |
| Closures and indirect application | `src/core/term.bend:4` passes and invokes `Unit -> A`; `name_key` captures `c` and `rest`; lexer choice continuations capture source/accumulator state | Generic closure environments, retain/drop of captures, indirect call ABI, lazy choice. Recognizing selected literal choices alone is insufficient. |
| Self-tail, mutual-tail and non-tail recursion | `nt_reverse`; `src/back/native/text.bend:82` / `:93` (`nt_replace_step` / `nt_replace_go`); `src/core/term.bend:123` recursive traversal | Bounded native stack for tail cycles; explicit continuation/stack protocol for general calls; ownership across transitions. |
| U32, Nat, Char and selected F32 operations | `src/core/index.bend:26`; `src/core/reach.bend:223`; `src/front/literals_arrays.bend:65` (`F32.read`, then `F32.bits`); `src/core/pretty.bend:336` (`F32.show`) | Extend primitive admission beyond Phase107. Float parse/show and conversions are real compiler work; strings naming other primitives are not. |
| Compiler-owned arrays | `tools/performance/phase88/base/decoder.bend:176,193,259,340,375`: read/write/allocate `Array<P88Node>` and `Array<String>` | The cached Base path actually requires array runtime behavior. Selected source has two `Array.get`, two `Array.set`, two `Array.new` call sites, not merely emitted target text. |
| Dependent type/checker structures | `src/check/kernel.bend:634` application telescope substitution; `:718` lambda/constructor/match/equality/rewrite dispatch | Lower the compiler's executing ADT algorithms. Its ability to check a source feature is distinct from runtime support for that feature. |
| File, time, arguments and error effects | Selected prepared `p86_read_file` family; `tools/performance/phase88/entry.bend:304` onward; public `src/host/native-cli.bend:3` adds three native host effects | IO continuation and result representation, versioned foreign symbol/table bindings, exact bytes and errors. Host glue only implements OS/byte transport. |
| Production ownership and static values | `src/back/native/bridge.bend:156,194,460`; `src/back/native/static.bend:1`; existing runtime helpers | Shared/unique/static roots, shell reclamation, child ownership, redirect semantics, static-image identity. |
| Full-image execution protocol | `src/back/native/emit.bend:58` closure creation; `:68` frames, `:81` jump/return; `src/runtime/native/runtime.c:110` CPU/device dispatch split | An ordinary C-ABI call does not replace guaranteed scheduler tail transitions. A CPU trampoline can be qualified separately from devices. |

Paths beginning `src/` or `tools/` in this table are beneath `selfhost/`.
The current public CLI specifies one CPU worker (`native-cli.bend:19`). Merely
including array-atomic, parallel or device emitters in the compiler does not
prove that its own run requires those operations. Conversely, the actual Base
decoder arrays above cannot be excluded on that argument. Any narrower full-image
claim must come from the checked reachable graph for the frozen entry and mode.
Many compiler definitions are `@unsafe`; successful checking is not a termination
proof (`kernel.bend:1370` exempts unsafe self-calls from the decrease check).

## Existing capture is before erasure

`selfhost/tools/performance/phase107/frontend/capture.mjs` invokes the driver-owned
API with `inspect(source, {mode:'native', captureCheckedGraph:true})`.
`typed-driver.mjs:800` rejects an injected API, wrong mode, or wrong option type.
After checking, selected annotation and `jl_checked_error`, `:929` returns only
`layoutDefs` as `checkedGraph`. It intentionally returns neither the context book
nor C output and marks `foreignValidated:false`.

That is a useful authenticated *annotation* boundary. It is not a capture of
production-erased bodies, ownership operations, constructor tables, foreign
admission or scheduler decisions. In particular, `nc_erase_mat` needs the original
ADT/telescope context to derive live field counts and masks. The current native
frontend makes the same omission deliberately: `frontend/native/prepare.py`
clones thirteen `p86_plan*` definitions and changes
`P107PlanReady{nr_prepare_annotated(context, annotated), verdict}` to
`P107PlanReady{annotated, verdict}`.

The smallest useful additional capture is a **Bend-owned bounded product at this
existing checked boundary**, with the full context kept private while it is
computed:

1. Call `nr_prepare_annotated(context, annotated)` after layout admission. It
   merges annotations with original type-level definitions and `nr_walk` records
   `NativeErasedBody` facts and live arities using `nc_definition_plain` and
   `nd_arity_plain` (`back/native/request.bend:20,63`). Emit selected facts through
   a Bend serializer; do not serialize the whole shared cached book.
2. Retain each selected function's exact source name, type/quantities, annotated
   body, erased body, live arity, referenced names and primitive/foreign
   provenance. Tag histograms and source-position summaries are useful coverage
   metadata, never substitutes for the bodies. For each full-image refusal,
   report the function and unsupported tag/call rather than stopping at an
   unlabelled first List signature.
3. Bind an ordered constructor manifest to this exact source/request: checked
   ADT owner, source/encoded identity, live arity, field mask and Base provenance.
   Reuse `nc_ctor_identity`, `nc_ctor_specs`, `nc_constructors`, and the actual
   linked ordering used by `nc_add_ctors`/`nb_ctr_ids`. Do not assign IDs from
   source spelling or assume arbitrary `Con`/`SCon` numbers.
4. Capture ownership decisions as structured operations before String emission:
   the current `nc_partition_step`/`nc_keep_uses` decide sink/keep but return C
   Strings; `nc_destructure` combines take and shell release; `ne_constructor`
   combines allocation, field sealing and packing. Erased bodies alone do not
   contain these later decisions. The new emitter must reuse their semantic
   analyses or expose a shared structured layer. `N_Segment.body` and
   `N_Emitted.code` are already C text and are too late for this boundary.
5. Include a versioned runtime import/effect table and fixed layout policy.
   Start with conservative sealing and generic boxed constructors, with static
   or immediate cases explicitly admitted. Term, U32, host pointer and context
   roles remain distinct even where they use equal machine widths. Unknown
   runtime calls are barriers to memory forwarding and allocation promotion.

The host may copy/hash files, transport named ADTs, invoke the checked Bend API,
link objects, serialize observations and compare independent expected values.
It must not rebuild erasure, ownership, closure conversion or lowering in Python,
JS or C. Preserve the current capture refusal controls and add changed-source,
layout-ID, arity, missing-import, duplicate-symbol, effect-role and stale-cache
controls. Cache keys bind source/Base, capture schema, lowerer, runtime/object,
constructor table, import signatures, QBE/toolchain and optimization policy.

## Progressive unchanged-source gates

| Stage | Frozen source and entry | Added semantic boundary | Independent acceptance |
| --- | --- | --- | --- |
| 1 | `back/native/text.bend:40`, `nt_reverse(String, xs, acc)` | General List construction/match, opaque owned String heads, erased type argument, owned self-tail loop | Exact sequence including accumulator; all aliases remain valid; all returned/discarded roots clean up; deep input does not grow native stack. |
| 2, held out | pinned Base `base.bend:1942`, `String.reverse.go(s, acc)` | Different ADT identity/field roles and Char values through the same mechanism | Exact Unicode scalar order and accumulator; shared and static roots; no name-based special case or post-freeze adaptation. |
| 3 | `front/lexer.bend:151`, `f_scan_word`, then `f_scan_quote` | `FScanned` products, shared input observations, ASCII primitives, lazy captured continuations | Exact `{word, rest, size}`, exponent/sign boundaries, empty and non-ASCII input, quote escapes and failure; unused branch does no work. |
| 4 | `f_lex_cursor` and real frontend token accessors | `FToken` with seven fields, mutual recursion, comments/nesting, position conventions | Complete token tuples including line/column/kind/begin/end/previousEnd, not just token text. UTF16 offsets and physical columns are separate. |
| 5 | frozen selected compiler entry plus Base/cache/host manifests | All reachable compiler ADTs/calls/primitives/arrays/effects and runtime transitions | Exact frontend verdict/diagnostics and emitted artifacts on the focused independent corpus; native image checks its own source; qualified reproduction with explicit B1/B2 identities. |

Witness sources should import or mechanically extract the *exact unchanged*
declaration with a source hash, then use a tiny Bend `main` that keeps it reachable.
The existing driver captures `main`'s closure; choosing a replay entry does not
make an unreachable helper appear. Record the actual canonical name in the
captured graph. A host implementation of reverse/lexer is an oracle, never the
compiled algorithm. Keep an entry that accepts owned Terms separate from the
existing scalar array-of-U64 wrapper.

Freeze these hand-auditable values before executing the new path:

| Entry/input | Exact expected result |
| --- | --- |
| `nt_reverse([], ["z"])` | `["z"]` |
| `nt_reverse(["a","bc",""], ["tail"])` | `["","bc","a","tail"]` |
| List with head `"head"` and aliased tail `["b","c"]`, empty accumulator | Reverse is `["c","b","head"]`; retained tail still equals `["b","c"]` after reverse/result disposal. |
| Reverse with a retained nonempty String head alias | Output head bytes/scalars and retained alias both match the original String after independent disposal orders. |
| `String.reverse.go("a🙂é", "!")` | `"é🙂a!"` |
| `String.reverse.go("e\u0301", "")` | `"\u0301e"` (scalar reversal, not grapheme reversal) |
| `f_scan_word("abc_9.rest+", "", 0)` | `{word:"abc_9.rest", rest:"+", size:10}` |
| `f_scan_word("1e-3+", "", 0)` | `{word:"1e-3", rest:"+", size:4}` |
| `f_scan_word("1e+x", "", 0)` | `{word:"1e", rest:"+x", size:2}` |
| `f_scan_word("x-y", "", 0)` | `{word:"x", rest:"-y", size:1}` |
| `f_scan_word("λa", "", 0)` | `{word:"", rest:"λa", size:0}` |
| `f_scan_word("c!", "ba", 2)` | `{word:"abc", rest:"!", size:3}` |

For ownership, instantiate empty/singleton/deep, unique/shared/static roots,
shared tails, repeated head objects, nonempty accumulators, and both alias-drop
orders. A result hash alone cannot establish lifetime correctness: traverse aliases
after consuming/dropping the result and record allocator/live-root accounting.
The lowest-cost discriminatory case is the three-element List with both retained
tail and head aliases; a missing child keep or premature shell free should fail
there before a lexer or image build is attempted. Also require expected failure
from deliberate missing-keep, early-sink and eager-unused-branch mutants. QBE/C
differential equality supplements the fixed oracle; the paths share the runtime
and therefore are not independent evidence of ownership correctness.

## Bounded replay and promotion

Capture/freeze a small checked witness once. Replay only the checked Bend lowerer,
IR verifier and emitter after each change, using one authenticated cached runtime
object and fresh worker objects. Run raw and optimized QBE plus the existing C
path on identical input roots. First collect exact outputs/refusals, then ownership
counts, maximum stack/live heap and assembly shape; time only qualified pairs.
Report capture/frontend, lowering/optimization, QBE, assemble, link, run and
one-time image/runtime acquisition separately. A cached runtime object cannot
be credited as a fresh runtime build saving.

Root owns all compiler/target work on CPU3 under the existing process-tree guard.
Offline preparation may hash/read source and write bounded manifests/specs.
With roughly 547 MiB free at task start, avoid duplicate full-source/C/image
copies and unbounded per-definition JSON; preserve failed attempts and unrelated
dirty files. Record capsule size before capture. Broader backend and full-image
gates follow demonstrated coverage; repeated full frontend acquisition is not the
inner loop for a lowerer-only edit.

Passing stages 1–2 proves reusable production ADT/ownership lowering for these
witnesses. It does not prove lexer coverage, compiler image coverage, general
scheduler/GPU support, or a whole-compiler speedup. The full-image endpoint requires
the measured checked reachable inventory and the stage-5 evidence above.
