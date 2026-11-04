# Phase161 backend architecture audit

At `d3588cfc5d6f0499208357b455b3043f436cd83f`, read-only source/evidence
inspection; no compiler, build or benchmark jobs. Comparison source is bendc
`56edcc65b3527a75838011682c231072d5b46097`, authenticated under
`selfhost/build/phase158/current`. This compares responsibilities and active
source paths, not time inferred from source or generated-text size.

The largest concrete architectural difference is **our generic segment lowering
plus separately admitted direct/borrowed/product implementations**. bendc's C
route does not build our generic scheduled program as a fallback and verification
reference. However, bendc is not a single-pass compiler: it lowers and raises an
optimizer IR, repeatedly walks the entire loaded program, rebuilds metadata and
also emits multiple wrappers/workers. Removing checking or disabling all useful
optimization is not the conclusion.

## Responsibility-bounded source census

Counts below are literal source bytes, physical lines, and lines excluding blanks
and full-line `#` comments. They are reproducible from the named manifest module
prefixes or inclusive source line intervals. They include declarations' type
annotations and laws; these are not token counts, executed-function counts or
minimum implementation sizes. In particular, the maintained directories include
finite controls, alternate C emission, incremental/reuse paths and diagnostics
that are not all reached by an ordinary QBE request.

| Source responsibility | Bytes | Lines | Nonblank/noncomment lines | `def` / `type` |
|---|---:|---:|---:|---:|
|Our manifest-owned `src/back/native/`, 40 modules: shared erasure/layout/ownership/observers plus native C emission|405,174|7,910|5,593|977 / 43|
|Our `src/back/qbe/`, 46 modules: structured IR, lowering, optimization/admission, verifiers, regions, emission, reuse and controls|967,794|20,447|15,445|2,334 / 207|
|Our `src/back/common/`, 9 modules: shared preparation/facts/helpers|97,634|2,086|1,546|225 / 0|
|bendc host tables/generation/representations/printers, `bendc.bend:3653–14812`|426,529|11,160|9,205|1,036 / 46|
|bendc core optimizer and later representation/program preparation, `:21771–26471`|176,704|4,701|3,828|390 / 13|
|bendc shared `core.bend`: source expression and optimizer IR, lowering/raising/transforms|69,163|2,352|2,031|135 / 16|
|bendc direct AArch64 implementation plus trailing native/CLI policy, `bendc.bend:26472–31028`|183,808|4,557|3,660|438 / 17|
|bendc `asm.bend`, instruction/object support|44,202|1,191|816|183 / 9|

The C responsibility rows also need the small `LM.*` lambda-match pass
(`:15490–15695`) and shared utility/driver/type definitions outside these ranges.
They deliberately exclude the separate checker, lexer/parser, most GPU/JS code,
runtime C and external Clang. Our three directory rows likewise exclude the
frontend/checker, runtime C, external QBE and linker. Thus the table is a bounded
architectural inventory, **not an exact ratio of equivalent active closures**.
The distinct 759,725-byte maintained `src/back/js/` tree is not counted as QBE
backend work merely because the full compiler source contains it. Root's
fixed-QBE full/reduced-source experiment is the appropriate way to measure the
acquisition cost of including unrelated declarations.

Pins: maintained `selfhost/src/compiler.json` SHA256
`ce8a967e20cecfca47b588db2fe679405b5f2c3aba4897390ecc5dbef8bbc37d`;
bendc main `72be729fb5a27c528acc4d232314ac44c4595a86dc67d9dde47197956edabb99`;
core `776ec5d81269d74ab3e8da0ad0f748e0f0e48695aae667a5d57ed033c433a1b7`;
asm `91794842d83c54362a756d0a759ea8fc4979b889184567cc543b640fb6f7a2f9`.

## Active representations and traversals

Our source entry has already checked and annotated the source before this
backend sequence. `back/common/constructor-facts.bend:185–220` merges the
annotation context, builds constructor facts, walks reachable names from `main`,
attaches erased facts and prepares authenticated static constants. These remain
`KDef`/`KTerm` records; several native forms are tags inside `KTerm`, not separate
algebraic data types. The active `p144o_lower_bangs` then performs both:

1. `p111_compile_defs` (`qbe/lower.bend:646`): for each reachable name, obtain its
   prepared definition and lower to `P111Program`/`N111Segment`, including runtime state,
   parameter/frame transport and continuations.
2. `p113pl_candidates` (`qbe/flat-products.bend:431`): inspect reachable
   definitions/signatures and construct eligible product/direct candidates.
   Flat entries also call `nc_compact_definition` (:415), which retrieves the
   same prepared body on the ordinary active path.
   It does not blindly lower every definition: native/foreign/bang/arity and
   signature checks precede candidate construction.

**Compaction/body preparation is already shared.** Before either lowerer,
`p112s_defs` (`qbe/static-data.bend:162`) visits every reachable ordinary
non-native/non-foreign `Def`, applies `nc_compact(nc_definition(...))` and the
static transformation, and `p112s_def_step` stores the result as
`NativeStaticBody`. `p112s_attach_book` installs the indexed facts in the
prepared book. `nc_compact_definition` (`native/book.bend:104`) checks that fact
and directly returns `dv(fact)`; it does not compact the body again. The two
source call sites therefore do not establish two compaction walks. Reject
"share compaction/body preparation" as a new optimization unless concrete
evidence identifies a material fallback through the nonprepared branch (for
example a separately admitted route bypassing static preparation). No such
fallback exposure has been established here. The real duplication under audit
starts with subsequent generic/private lowering, their analyses and retained
products.

`N111Stmt` has nine machine-operation/control variants. `P113DStmt` adds five
direct-worker forms, including a wrapper around `N111Stmt`, multi-result calls,
results and tail recurrence. `P113DProgram` retains the original static/generic
program alongside direct functions. Region analysis has additional tail,
worker and fusion body/plan types (`qbe/model.bend:131–221`). The 207 QBE `type`
declarations include result/error, cache, fact, cursor and control records;
calling all of them separate IRs would exaggerate the representation count.

The direct candidates pass `p126sc_candidates` and `p113d_passes` with fuel 32
(`prepared-context.bend:63`, `direct-lower.bend:292`). Each successful round
admits candidates whose dependencies are already ready, preserving a waiting
list and ordered ready index; it stops at no progress. That is a bounded
dependency fixed point, not 32 guaranteed body rewrites. Optional worker merging
can repeat admission against the extended signatures (`prepared-context:84`).

`p114s_open` verifies the original static/generic program and the direct
functions, retaining IDs and validity. Inlining transforms the direct list and
commits through an admission boundary. **`p114s_ranges` is currently identity**;
its wrapper name is not another analysis pass. Phase146's `p146c_finish/verify`
reuses the accepted original context/IDs but independently checks every actual
final transformed function and retains array/transport checks. See
`checked-boundary.bend:18–98`, `retained-context.bend:5–44`; the optimized initial
direct verifier is `p147d_functions` in `verify-compact.bend:523`.

Optional scalar/borrowed/product discovery and integration follow this checked
boundary. If workers replace functions or enable further direct dependencies,
the resulting closure is checked again (`product-composition.bend:352`,
`prepared-context.bend:93–156`). These checks concern a changed program; they
cannot simply be labelled duplicate checking of identical bodies.

Emission constructs signatures, ready/region indexes and the lookup catalogue
in `p134e_registered` (`stream-emission.bend:41`). Its cursor visits private
workers, legacy regions, public segments, tables and the entry. The original
segments, derived functions and shared context coexist until their cursor
consumers finish. It already streams bounded pieces; `p144e_body_tail` already
flattens instruction chunks directly onto their suffix. A new whole-program
streaming rewrite would duplicate existing work.

bendc current follows `LM.decls` → `Pick.decls` → `Arrw.decls` → `Lo.program`
(`bendc.bend:26462`). `Lo.program:25746` builds `G` and masks, lowers *every*
runtime definition `Core.Expr` → `Core.Tm`, erases, builds rank/contexts, performs
monadic and general inlining, simplification, specialization, unrolling, fusion,
tail pushing, match reuse, resubstitution and reference repair, then raises
`Core.Tm` → `Core.Expr`. Both principal term types have 16 constructors
(`core.bend:Tm`, `Expr`). `Opt.simps:23598` uses three walk/substitution rounds
when enabled; optional transforms and fuel are not all unconditional body work.

Next are `Par.auto`, sum unboxing, nesting, **two** parameter-unboxing rounds,
optional RC-oriented `RO.program`, another `G.new`, word-leaf/headerless layout,
DPS graph analysis, result unboxing and flow facts. `G.new:4000` builds law,
constructor, definition and body maps; it is rebuilt after transformation.
`Dps.build:14201` constructs edges/reverse edges/groups even with `free=false`;
RC borrowing adds a bounded 64-round flags fixed point when RC is enabled.
Only then does `Gen.all.go:10220` walk reachable names from `main` and generate
code. Reachable emission is **not lazy whole-program optimization**.

The C emitter builds Docs and flattens the complete result
(`Gen.program.fin:25944`). This is a real cost bendc retains and our streaming
path avoids. A GPU-book rebuild is behind a thunk and GPU target test; its
presence in `Gen.program` is not evidence that CPU-only requests execute it.

## One comparable source function through both routes

Use the actual safe consuming helper `p88_string_eq_go` in
`selfhost/src/core/consuming-strings.bend:5`: three inputs, simultaneous
String/String/Bool matching, recursive comparison of tails, and discarded
tails on mismatch. Phase160's common compiler implementation contains this
same function, so this is a comparison of one algorithm, not analogous names.

Our route preserves checked ownership and annotated constructor information,
prepares/compacts its body once, builds the generic segment path from that
prepared body, then considers its
scalar/direct/borrowed schema. Admitted workers still receive structural checks
and retain a public/fallback call boundary. The retained Phase156 QBE has both
owned and borrowed implementations; the owned worker at `program.ssa:2498`
uses `p125_rt_take2` and sinks discarded tails. Do not infer all calls use that
worker or infer its dynamic cost from this static trace.

bendc's corresponding `DDef` travels through `Opt.lower` (`:22362`), core
erasure/transforms and `Opt.raise`, then `Gen.def` (`:9922`) →
`Gen.def.decl/native/body` → the boxed ordinary worker in the Phase160
`BEND_UNBOX=0` policy. `Gen.stmt` (`:9381`) renders the match and tail return as
C control flow. C02 `program.c:25661` contains `F_p88__string__eq__go` as a tail
loop over field loads, without local keep/take/sink operations under NO_FREE.
Clang handles its ordinary native calls/registers/control-flow optimization;
the tracing runtime handles subsequent reclamation. This is a backend/runtime
contract difference, not evidence that the source checker licensed dropping
ownership checks in our runtime.

bendc does **not** avoid wrappers universally: `Gen.def.boxed:9758` can generate
closure wrappers, leaf fast/slow workers and sequential clones; `Gen.def.unb:9784`
generates a flat-result worker plus a boxed adapter. Our C02 comparison disables
the defective unboxing path. Default current bendc must be described separately
from that successful compatibility policy.

## Categories bendc's C path avoids, and what can actually disappear

| Category | Evidence and requirement boundary |
|---|---|
|Generic scheduled lowering alongside direct-worker lowering|Present together in active `p144o_lower_bangs`; absent from bendc's ordinary C pipeline. This is our implementation/ABI architecture, not a Bend language requirement. The generic program currently supplies fallbacks, IDs, verifier/reference metadata and remaining public functions, so deletion needs a replacement contract, not a skipped call.|
|Our explicit register-state/continuation transport synthesis|N111 segments use a borrowed state pointer and carry frame/register transport. bendc C delegates ordinary call/return/register allocation to Clang. Direct calls could avoid some synthesis, but effects, closures, parallelism and fallback ABI remain real obligations. Our pipeline also delegates final machine allocation to QBE; it is not itself a full machine optimizer.|
|Our independent post-transform verifier/admission architecture|There is no equivalent full N111/P113 final structural verifier in bendc's inspected C route. It has source checking, pass-specific checks/proofs and Clang validation; these are different guarantees. Keep our independent final verifier. Narrow reuse of authenticated unchanged facts is already implemented and is the appropriate comparison boundary.|
|Per-binding sharing/drop analysis in tracing-only mode|`Gen.own:5916` → `Gen.shares.if:5299` returns an empty Doc with NO_FREE and RC off; RC borrowing analysis is also bypassed. Our ownership runtime requires live/use partitions and correct keeps/sinks. Omitting them is a memory-policy change, not a free optimizer simplification. bendc default free/RC modes do this analysis too.|
|Multiple checked producer/observer/owned/borrowed composition layers|Our scalar/product helpers need schema discovery, admission, adapters, closure recomposition and checks. Some overhead is structural rather than language-mandated. Their generated-program benefit is real: Phase149 already falsified 'disable them all for free'.|

Source checking, dependent erasure, effects/foreign ABI, constructor layout and
correct final outputs remain required on both sides. bendc's specialized
transform proofs do not establish a general end-to-end code-generation proof;
our final verifier likewise is not a proof of runtime/foreign implementation
safety. Keep those distinctions when discussing total compiler complexity.

## Recomputed facts: current evidence and smallest useful direction

The clearest remaining local example is `p113pl_bind_flat:277`: `nc_uses(body)`
feeds keep, while `nc_live_env(env,body)` computes it again when the environment
is nonempty (`native/bridge.bend:198`). The boxed path immediately below already
shares its set. Phase156 tried sharing on the real pipeline: the balanced Map
follow-up was neutral, and retaining/transporting the set added work. This is
evidence of repeated analysis, **not an unclaimed easy gain**. See
`experiments/phase156/uses/analysis.md`.

Likewise do not re-propose shared compaction, global constructor facts or
repeated raw verification removal: prepared `NativeStaticBody` facts,
Phase144's constructor facts and Phase146's accepted context are active. Inlining
has its own indexed table, candidate admission has signatures, and emission has
registry/catalogue facts. These describe different bodies/stages and sometimes
different namespaces; a universal cache must prove identity, invalidation,
diagnostic precedence and ownership lifetime before they can safely be shared.
bendc also rebuilds maps and repeats per-variable `Use.n`/RC usage walks outside
its tracing-only policy.

The next architectural question is **how much subsequent generic/private
lowering and analysis is duplicated after their already-shared prepared body**.
First use the finer dispatcher-stage partition to separate generic production,
generic metadata, signatures, private candidate production and admission;
then identify the actual fallback consumers and any specific analysis both
lowerers repeat. Do not spend an experiment adding another preparation cache.
If a material repeated analysis is identified, an affordable later fixture is
one complete real function's generic-plus-direct production/admission, observing
every body/error/signature and preserving the original final verifier. It must
charge summary conversion, lifetime and cleanup costs; a scalar-only query loop
is insufficient. Avoiding a generic product also requires proving it is unused
by fallback, public emission and verification. No wholesale new IR, removal of
the generic reference program, or promotion is justified by this source audit.

Finally, current bendc **does have direct native AArch64 output** (`N.program`,
`:30542`, `asm.bend`), not just C. That route performs its own frame/register and
object work and uses a different preparation sequence from its C route. It is
not a Linux x86-64 replacement measured in Phase160. Compare source-to-C with
source-to-QBE explicitly, and include external Clang/QBE construction only in
the corresponding complete-machine acquisition metric. Neither the historic
8.8-second self-C observation nor output-text size measures the architectural
cost of compiling the same source to the same target.
