# Phase108: fastest general route to a QBE-built compiler

Source inspection only, 2026-10-18. No target execution, compilation, production
edit, or performance measurement was performed for this audit. The selected
compiler source is
`selfhost/build/phase102/projection-cost-source01/compiler.bend`, authenticated by
`selfhost/tools/native/selection.json` and its admission record. This proposal
keeps compiler algorithms in Bend and treats runtime C as a separately acquired
library. It is a route to a complete CPU compiler, not a promise of production
runtime parity or GPU support.

## Immediate full-compiler route: cproc plus portable dispatch

After the initial structured-boundary audit, root proposed consuming the existing
Bend-emitted C with cproc/QBE and replacing only the nonportable host tail-call
protocol with an explicit trampoline. **This is the fastest route to a working
full compiler in the present tree.** It preserves current generic and optimized
ownership, closure, scheduler, layout, primitive and foreign-request lowering,
instead of recreating them in a new structured bridge. Keep the structured plan
below as the route to direct Nx coverage, not as a prerequisite for this attempt.

The honest pipeline is Bend source → existing Bend frontend/backend → C → cproc
→ QBE → assembler/linker. The compiler algorithms remain Bend-written; cproc is
a new external C frontend dependency. This removes Clang from repeated program
construction once the reusable support pieces exist, but does not turn Phase107
Nx into a full-language IR or eliminate C emission. Separate the following
achievements: an existing full emitted C compiler built through QBE; a QBE-built
compiler that emits/rebuilds itself; and eventual direct Bend→Nx→QBE self-hosting.

Local cproc source was inspected under `selfhost/build/phase108/toolchain/cproc-src`.
Its README says it implements most C11, lacks atomic and volatile types, inline
assembly, statement expressions, long double and position-independent generation,
and currently requires an external preprocessor. `decl.c:122` and `:416`
explicitly reject `_Atomic`. The documented builtin list does not include
`__builtin_clz`. These are concrete compatibility gates, not merely a musttail
problem:

- The runtime has `_Atomic` thread-pool globals and `__atomic_*` ownership,
  allocator and scheduler accesses. Move these accesses to an ordinary-ABI shim
  compiled with GCC, preserving memory orders and return values. Do not erase
  atomics while claiming threaded support. A one-thread compiler still needs a
  coherent explicit runtime mode rather than ad hoc token replacement.
- Provide a defined CLZ helper, including the established nonzero precondition
  of each caller; remove unsupported optimization attributes deliberately.
- Keep glibc/system headers behind an authenticated preprocessing boundary and
  inspect unsupported extensions before a full 10,000-function acquisition.
- Preserve float bitcasts, integer truncation/overflow behavior, array aliasing,
  struct ABI and OS/effect APIs. QBE/cproc compatibility cannot be inferred from
  compilation alone; run focused controls and exact generated-program outputs.
- Preserve distinct scheduler Reply and next-FID channels in the trampoline.
  Raw `return term_tsk(...)`, `return task_deliver(...)` and error returns must
  exit to the scheduler; jump macros must continue its inner dispatch loop.
- Expect lower initial optimization quality. cproc/QBE need not reproduce Clang
  inlining or register conventions. A working but slower compiler is a useful
  coverage milestone; measure acquisition time and actual compiler request
  runtime separately before claiming acceleration.

This route can validate the portable runtime once for both future backends. It
also permits a paired C/Clang versus C/cproc comparison that holds all Bend
semantic lowering decisions constant. A full-compilation failure can be reduced
to the C frontend/runtime boundary instead of simultaneously debugging erasure,
closure conversion, ownership, Nx lowering and machine-code generation.

## Longer-term direct Nx recommendation

Build a **generic boxed segment backend**, retaining the existing native
backend's checked erasure, constructor identity, ownership placement, closure
captures and continuation segmentation. Emit each segment as an ordinary C-ABI
QBE function operating on an explicit runtime state. Drive those functions from
an explicit loop/trampoline, so arbitrary tail and mutual calls do not use the
machine call stack. Start with conservative layouts and the sequential execution
path; add parallel scheduling through the same state protocol after the compiler
works.

Do not extend `phase107/frontend/lower.bend` one source datatype at a time. That
lowerer has intentionally omitted the compiler's central semantic machinery.
Do not translate the final `N_Segment.body`: it is C source, not a portable IR.
Do not port all private worker/product/observer optimizations before trying the
whole compiler. They have a complete generic fallback already.

There is no ready-made neutral instruction stream to intercept today. The clean
semantic boundary is inside the generic bridge, **before each C string is
constructed**. `ir.bend` is only 25 lines; `N_Segment.body`, `NC_Code.body`,
`N_Emitted.code`, `NC_EnvPartition.drop` and `NC_Binding.word` are all C strings.
Changing `ne_segment` alone cannot work. Even replacing every `ne_*` helper is
insufficient: bridge/direct/pattern/parallel contain C expressions and control
flow directly.

For the fastest isolated implementation, add a namespaced structured version of
the generic bridge, sharing its type-independent analyses and exact erasure,
rather than changing the types of all existing optimized C paths. Preserve the
existing bridge's decisions function by function, with an explicit correspondence
map. Later, factor shared semantic decisions behind a structured operation
builder and render the old C backend from that builder. Reworking all existing
NF/NQ code now would enlarge the critical path considerably.

## Existing decisions that can be reused

Paths below are under `selfhost/src/back/native/` unless stated otherwise.

| Existing boundary | Reuse and constraint |
| --- | --- |
| `request.bend:63`, `nr_prepare_annotated` | Keep the complete merged checked type context, source binder bound, reachable names, erased bodies and reachable foreign paths in `NR_Request`. |
| `erase.bend:55–101`, `nc_erase_mat` / `nc_erase_annotated` / `nc_erase` | Preserve erased binders/arguments/fields; constructor matching already records live field count as `ix = count + 1`, field word mask in `qt`, and qualified constructor identity. |
| `book.bend`, `nc_definition_plain` / `nc_compact_definition` / `nc_refs` | Reuse native primitive replacement, foreign effect constructors, live dependency traversal and literal compaction. Avoid creating `NStatic` initially. |
| `identity.bend`, `nc_ctor_identity` | Keep user constructors separate from Base special representations and foreign request IDs. |
| `bridge.bend:124–209`, `nc_uses*` / partition / keep | The existing liveness sets determine exactly which owned words are dropped, retained and captured. Reuse set computation; substitute structured `Keep`/`Sink` emission. |
| `bridge.bend:284`, `nc_let_cut` | Keeps the shared subset, captures only body-live values, constructs a continuation with frame slots, and lowers the producer separately. Preserve this order. |
| `bridge.bend:305`, `nc_lambda` | Already identifies closure captures and adds the argument as the last segment parameter. |
| `direct.bend`, `nd_head` / `nd_args` / `nd_arity` / `nd_beta` / `nd_match_sequence` | Existing saturated-call and demand-preserving sequencing decisions can be reused. Retain generic partial applications and closure factories. The bounded combinator optimization is optional. |
| `bridge.bend:487`, `nc_match_apply_slow_to` | A hit consumes the scrutinized word, creates live fields and lowers the arm; a miss retains the original word for the next matcher. Preserve the Emit/Halt validity guard. |
| `bridge.bend:460`, `nc_destructure` | Generic fields are acquired by one `ctr_take` then `spare_free`, not independent loads and free. Single-field packing, Base words and arrays are distinct cases. |
| `emit.bend:42–64`, constructor/closure creation | Constructors seal owned children; closures transfer capture ownership without constructor sealing. Keep these separate. |
| `parallel.bend`, `nc_parallel` | Contains both sequential fallback and parallel child/join segmentation. Sequential fallback permits early full-compiler coverage without inventing fork semantics. |
| `tables.bend`, `N_Segment` | Retains arity/result width, frame layout, refs, bang and fork facts. Use these to build a versioned program descriptor rather than regenerate semantic facts from QBE. |

`pattern.bend` and `word-pattern.bend` optimize scalar decision chains. They are
not necessary for semantic coverage if ordinary matching remains available.
`layout.bend` carries proven scalar kinds through bindings and continuations;
initially keeping all scheduler values as full Terms is conservative. Do not
assume `N_W64` means an arithmetic integer or an ordinary pointer.

A subtle fallback trap: `ns_compile_fallback` still invokes `nf_plan`, and
`nc_finish` eventually installs workers. Merely choosing that entry does not
produce a guaranteed boxed-only backend. The new entry must explicitly bypass
worker planning and static/layout admission while retaining checked validation.

## General operation inventory

The initial structured layer needs the following semantic operations. This is
an inventory of the existing generic backend, not an assertion that every one
is reachable in the selected compiler. A checked reachability census should
establish the latter before the first expensive compiler-image acquisition.

| Group | Required operations and details |
| --- | --- |
| Values | Bound Term, small word literal, qualified constructor ID, segment ID; explicit U32/Term conversions where an intrinsic needs them. |
| Ownership | `Keep` returning the potentially changed Term, `Sink`; constructor child sealing; constructor take with multiple owned outputs and consumed parent shell. |
| Data | Nullary immediate constructor; generic boxed constructor; native Zero/Succ/Bool/Char/U32/F32 representations; Tuple and IO constructors; String as ordinary SNil/SCon. |
| Testing | Constructor identity test; Base scalar tests; array leaf/node class test; invalid IO tag failure. |
| Control | Bind evaluated atom, sequence, branch, fail-stop, direct segment transfer, return to saved continuation. |
| Continuations | Push held values plus return ID; pop exact held count; load return values from register state. Storage is runtime-managed, not recursive native calls. |
| Functions | Closure allocation from live captures, named function factory, saturated call, partial application, dynamic application and closure capture transfer. Bang application has a task-producing path. |
| Scalar primitives | 69 names in `intrinsic.bend`: U32 arithmetic/comparisons/bit operations/shifts/conversions; Nat checked arithmetic/comparison; Bool; F32 arithmetic/comparisons/math/read/show. Preserve totalized division/modulo, large-shift behavior, Nat overflow and exact F32 bit transport. |
| Composite primitive | `nat_divmod` returns an owned Tuple with division-by-zero behavior matching production. U32/Nat `cmp` returns the LT/EQ/GT constructor representation. |
| Arrays | Six operations (`new/get/set/swap/size/clone`) plus nine atomics; `ALeaf`/`ANode` construction and destructive matching; boxed element layout initially. Pair-returning primitives preserve the original array token and return the second value inside Tuple. |
| Tasks | Task creation, continuation/index linkage, child result slots, remaining-count join, task return/delivery. May initially be unreachable with sequential execution, but keep metadata. |
| Host boundary | Program registration, runtime initialization and destruction, root evaluation, IO request loop/effects, argv/files/output, error propagation and readback descriptors where needed. |

The erased dispatch covers `NWord`, `Var`, `Ref`, transparent core wrappers,
`Lam`, `App`, `Let`/`NSeqLet`, `Ctr`, `NCtr`, `NApply`, `NCall`, proof/type zeros,
`Mat`/`NMatch`, `NOp`, `Efq` and `Rwt`. Literal compaction can produce
`NNatAdd`/`NNatSum`. `NQBundle`, `NQBox` and `NFCall` belong to optional worker
lowering and need not occur in the generic entry. `NStatic` and `NWPattern` need
not be introduced by its preparation. Any unexpected internal form should fail
with a named definition and node, not silently select another compiler.

## Proposed module boundary

Use a small structured native layer above Nx rather than giving every ownership
operation a new general optimizer rule on day one:

- `segment-model.bend`: typed Term atoms, bindings, operations, continuation
  descriptors, segment IDs and program tables. Terms and runtime pointers are
  distinct even if both eventually occupy 64 bits.
- `segment-lower.bend`: generic erased KTerm cases, parameterized by the existing
  checked book. Reuse `nc_uses*`, erasure, constructor lookup and direct-call
  helpers; preserve ownership/capture decisions from the bridge.
- `segment-calls.bend`: saturated/partial/dynamic application and closure factory
  construction; no machine-stack recursion for Bend calls.
- `segment-runtime.bend`: one explicit versioned import catalogue, primitive IDs
  and effect/ownership contracts; data and signature validation in Bend.
- `segment-nx.bend`: turn one structured segment into one Nx function, lower
  runtime operations to conservative imported calls, read/write state slots,
  return the next segment ID or terminal status.
- `segment-program.bend`: deterministic IDs, metadata and import manifests;
  QBE data tables and a host entry with the correct runtime ABI.

These are suggested boundaries, not six mandatory files. Keep small operations
and common walkers together where that produces simpler code.

The C shim implements the existing heap/scheduler/OS protocol. It must not parse
source, classify KTerm, select primitive replacement or perform reachability.
Primitive arithmetic/math can remain runtime helpers initially: this avoids
adding floating-point IR and every numerical edge case before the compiler
runs. It costs calls; measure that cost after correctness.

## Runtime and trampoline contract

Use a per-evaluation/per-worker state containing the real `Env`, stack pointer,
register bank, current segment ID, sequential flag, result width and terminal
reply. Generated `step(state)` functions read their parameters from state/frame
slots, execute a segment, write outgoing words, and return a next ID/status.
A runtime loop dispatches the next step with an ordinary C function pointer.
Continuation returns pop the saved ID and exact frame layout. Dynamic apply
performs the existing capture load/free and appends the argument. The host call
stack stays bounded across tail recursion, mutual recursion and non-tail calls
whose continuations live in the runtime stack.

The production CPU ABI (`runtime.c:109–135`, `1258–1385`) uses `preserve_none`
and `musttail`, which QBE's ordinary ABI does not implement. The device path
already demonstrates switch dispatch, but setting `DEVICE=1` on the host would
also change memory addressing, locks, stack stride and allocator behavior.
Adapt dispatch explicitly while retaining CPU behavior. Do not rely on GCC/QBE
incidental sibling-call optimization.

For the first CPU compiler, run the existing sequential path (`seq=true`) and
lower parallel lets to `nc_lets` semantics. This is a CPU one-thread compiler
capability, not preserved thread/device performance. Preserve task metadata so
the subsequent path can use the same trampoline as `work_loop` within the
existing `monk_step`/task delivery protocol, with one state per worker.

Use the actual `term_keep`, `term_sink`, `rfc_seal`, `ctr_take`, `spare_free`,
`heap_alloc`, array helpers and term drop implementation. In particular,
`term_keep` returns a possibly different redirect-bearing word. Its returned
value must replace the old binding before either owner is captured. Closures
are affine: the runtime explicitly refuses reference-count wrapping of closures
and tasks. An adapter that silently treats them as shareable changes semantics.

A stable runtime object needs a descriptor for constructor arities, function
arities/result widths/flags, step pointers and reserved IDs. Current macros and
static tables are per-program. Generate descriptor data in Bend/QBE, or emit a
small mechanically rendered C data unit as an initial separate acquisition
boundary; do not quietly include the whole generated program in C again.
Program descriptors must remain alive until every owned Term/task from that
program is gone. Bind caching to runtime ABI, imported signatures and tables.

A cached C runtime compiled once with Clang is compatible with a QBE-built
compiler image goal; it does not establish an entirely Clang-free bootstrap.
Removing Clang from the reusable runtime build is a separate portable-dispatch
qualification. Native custom foreign C effects likewise require their own
provider build, while the compiler's known OS/effect set can be cached.

## Nx/QBE integration blockers

1. Nx has no import declarations: calls currently resolve only to functions with
   bodies. Add explicit imports (or a separate immutable import context) and exact
   signatures. The verifier, QBE emission, JSON transport, call graph and all
   optimizers must agree. Imported runtime calls are effect barriers by default.
2. The public Nx entry is restricted to scalar arguments and a U32 result.
   Separate library verification from the Phase106 integer runner ABI; add an
   authenticated runtime-state entry rather than encode pointers as integers.
3. Nx constants carry only U32 payloads. Do not encode tagged Terms by truncating
   64-bit constants. Build tags through validated runtime constructors or add
   exact 64-bit literals. Descriptor/function pointer data also needs an emitter.
4. Ownership effects must remain ordered. Initial segment execution can use Nx
   only as a typed machine-level transport and disable memory promotion,
   forwarding and aggressive inline/tail policies. `NxAlloc` means calloc-like
   host allocation, not the Bend heap. Runtime scratch cannot escape a call.
5. Verification and function resolution are linear list scans; uniqueness makes
   whole-module work quadratic. QBE emission repeatedly calls type resolution.
   At thousands of compiler functions/segments, use indexed immutable symbols
   and one checked import/signature table, or emit validated segment units.
   This is a structural scaling risk, not a measured Phase108 bottleneck.
6. Existing source units include a JSON copy of the entire Nx graph. Do not
   require that duplicate product for every full compiler build. Stream/bound
   the QBE unit output and keep only useful manifests/diagnostics on this disk.

The Phase107 native frontend assembly intentionally replaces
`P107PlanReady{nr_prepare_annotated(context, annotated), verdict}` with
`P107PlanReady{annotated, verdict}`. Undo that narrowing for the new path:
`annotated` alone is not the full type/layout context needed by generic erasure.
The selected `p86_plan` chain already parses, checks, reports, validates owned
emission, constructs the full context, annotates the reachable closure and calls
`jl_checked_error`. Reuse that chain and consume its `NR_Request` directly.

## Ambitious implementation order and gates

1. **Freeze the whole-compiler target immediately.** Record selected source,
   runtime/effect ABI and checked reachable operation census; make the generic
   lowerer report unsupported forms across that whole closure. This prevents
   spending the campaign only on a growing set of scalar demonstrations.
2. **Build runtime import/state and the smallest segment round trip.** Test an
   unchanged real List<String> reverse body and unrelated String reverse using
   constructor build/take/keep/sink. Add deep mutual recursion and a non-tail
   continuation now, because a self-tail-only ABI cannot support the compiler.
3. **Complete the generic bridge in one coverage push.** Closures, partial
   applications, ordinary matches, all reachable intrinsics, arrays if reachable,
   and host IO. Use conservative boxed layouts. The test gate includes sharing
   a parent, preserving a retained alias after destructive matching, affine
   closure captures, nested matches, dropped branches and repeated requests.
4. **Build the full selected compiler through QBE.** This is the central gate:
   the exact full Bend source lowers without fallback to C body emission, the
   resulting image parses/checks/emits a known program, and invalid programs
   retain diagnostics. Test both cached-Base and live-Base paths where available.
5. **Prove useful self-host coverage separately.** Have the QBE-built image
   compile the same full source again; compare semantic products/canonical IR
   and independent outputs, with source/ABI manifests. Byte identity is useful
   only after deterministic emission is established. Acquire a new frontend
   image only when its source/runtime integration actually changed.
6. **Optimize real cost after the generic compiler works.** First recover direct
   saturated segment jumps and local self loops, then promote selected ordinary
   workers. Measure runtime-adapter calls/dispatch versus ownership, parse/check
   and text construction. Only then port scalar/product/observer policies with
   matched workload evidence.

Finite compiler smoke tests are not whole-language parity. A QBE-built compiler
that still emits C is already a meaningful compiler-image milestone; a compiler
that emits QBE for its own complete source is the next distinct milestone.
Neither requires all current C optimization policies to be ported first. CPU
parallel behavior, device execution, arbitrary foreign effects and production
release qualification stay explicit additional gates.

The initial reverse estimate in Phase107 described a careful incremental heap
experiment. A generic segment strategy changes the objective: implement the
small full semantic substrate once and use the whole compiler as a coverage
consumer. This is more ambitious and has higher early integration risk, but it
is the shortest clean route visible in the present source. No credible wall-time
or speedup estimate follows from this read-only audit.

## Q0 bridge → Q1 clean review

The root's revised bootstrap avoids acquiring a new Clang compiler image:
selected native B2 emits the scoped modified compiler source with the portable
runtime; the temporary bridge inserts only the four transport macros; cproc/QBE
builds Q0. Q0 then emits that same modified source with the same runtime and its
new Bend `nb_bank`; cproc/QBE builds Q1 without the bridge. This is a sound
bootstrap plan. Compare complete Q0-bridged C against Q0's clean self-emission:
the new Bend metadata and temporary bridge deliberately use the same insertion
point and exact register order, so byte equality is a useful strong gate.
Separate this source/output agreement from Q1 runtime and diagnostic checks.

`prepare.py` authenticates the selected source and proves its inverse after only
`nb_zero` plus the four `nb_bank` macro additions. Its original Clang acquisition
commands are an unused optional route, not the provenance of this Q0/Q1 attempt.
The temporary bridge is admitted only to old canonical `WL_SIG/WL_BANK/WL_ALL`
headers and rejects preexisting metadata. It does not change segment bodies.

Read-only driver review found provenance improvements needed for qualification:
pin the actual patched Phase108 QBE referenced by cproc `config.h` (the initial
`run.py` instead pinned Phase107 QBE); record/reverify cpp, assembler, linker,
GCC driver, process helper, support headers and atomic shim provenance. Emission
should record/reverify Base, cache, effects and selection/admission, and require
that the five runtime parts concatenate exactly to the named runtime. Custom
Q0/Q1 compiler pins need a linked build receipt to establish source lineage.
Freeze independent expected output before execution, not after it.

The fresh `portable-source02` runtime snapshot includes the scoped `_Alignas`
change and its parts reconstruct exactly; the in-flight `full-emit01` record
uses that snapshot. The earlier `portable-source01` remains separate evidence.
No target execution was performed by this review.
