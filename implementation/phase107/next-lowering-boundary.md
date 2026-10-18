# Next real allocation-heavy lowering boundary

Start with **`nt_reverse`, instantiated for `List<&2, String>`**, from
`selfhost/src/back/native/text.bend:40`. Use the existing checked definition,
not a host reconstruction. Its recursive arm consumes one `Con`, transfers its
head and tail, constructs `Con{head, acc}`, and recurs. `nt_append` at line 46
uses it twice; this is actual compiler list machinery. String heads are opaque
owned values, making this a stronger test than a list of scalar integers.

The close held-out case is pinned Base `String.reverse.go` at
`selfhost/.bootstrap/upstream-phase66/bend2/base.bend:1942`, used by the real lexer
in `selfhost/src/front/lexer.bend` (`f_scan_word`, line 151; `f_scan_quote`, line
161). It exercises the same constructor mechanism with `SCon` and `Char` instead
of `Con` and an opaque string head. These are allocation-using source slices;
this inspection does **not** establish that either dominates current compiler
time. Capture actual allocation and runtime counts before predicting speedup.

Do not begin by porting all of `f_scan_word`. It additionally needs the
`FScanned{word,rest,size}` result, shared input observations in `f_head`/`f_tail`,
Char primitives and lazy `f_choose` continuations. The complete lexer adds token
products, multiple recursion cycles and source-position semantics. The smaller
reverse pair isolates the ownership boundary first while exercising reusable
general ADT construction and matching.

## Why the current source lowerer refuses

`phase107/frontend/lower.bend` admits only checked Base U32 and Bool in
`nxk_type` (line 33), with only scalar live signatures in `nxk_signature` (177).
`nxk_expr` handles the two Bool constructors, and `nxk_function_body` only admits
Bool matching. `nt_reverse` fails its List signature before body lowering;
String, general constructors and matches are unsupported. Calling an existing
runtime symbol is not an escape hatch: foreign intrinsic replacement is refused
in `nxk_call`, and Nx `verify.bend` currently resolves calls only to declared
functions with bodies. The array-of-U64 entry wrapper also expects scalar
arguments and a U32 result, not owned Bend values.

The production backend already has the required semantic decisions:

| Existing source | Boundary to preserve |
| --- | --- |
| `back/native/erase.bend`, `nc_erase_annotated`, `nc_erase_mat` | Checked erasure and live constructor fields; no guessing erased arguments from source syntax. |
| `back/native/bridge.bend:156`, `nc_partition_step`; line 194, `nc_keep_uses` | Dead owned values use `term_sink`; duplicated live values use `term_keep`. |
| `back/native/bridge.bend:460`, `nc_destructure` | Boxed matching obtains children through `ctr_take` and releases the consumed shell with `spare_free`; it is not a raw memory load followed by `free`. |
| `back/native/emit.bend:2`, `ne_stores`; line 42, `ne_constructor` | Constructor allocation, child sealing, immediate versus boxed representation, and checked cold-constructor exceptions. |
| `back/native/sharing.bend`, `nh_macros` and observer facts | Whether child sealing can be skipped is a checked whole-program fact. Start with the conservative path. |
| `back/native/identity.bend` and `tables.bend:294`, `nb_emit` | Constructor identity/arity, function metadata and static-image layout belong to the linked program. |

Paths in this table are under `selfhost/src/`. These facts should feed structured
native operations **before C formatting**. `N_Segment.body` and `N_Emitted.code`
in `back/native/ir.bend` are currently Strings containing C. They cannot be
consumed by QBE without either changing that boundary or reparsing C; reparsing
would duplicate semantics and defeat the architectural purpose.

## Production values are not the synthetic allocation model

`selfhost/src/runtime/native/runtime.c:185` defines `Term` as U64. Tags occupy
high bits, constructor/function IDs occupy an auxiliary field, and the low
40 bits are a heap **word location**, not an ordinary process pointer. The top
bit marks a reference-count redirect. `Env` (line 214) contains heap and allocator
pointers. `term_peek` (773) follows redirects. Static nodes below `HEAP_OFF`
follow a different reclamation path.

`term_keep` (762), `term_sink` (887), `rfc_seal` (739), `ctr_take` (905),
`heap_alloc` (661) and `spare_free` (686) jointly define ownership transfer.
`ctr_take` has distinct unique and shared cases; in the shared case it preserves
child ownership while consuming one parent reference. Constructor creation also
depends on the program's constructor tables. Replacing these operations with
Nx `calloc`, raw pointer loads and `free` would implement another runtime, not
the production Bend runtime.

The Phase107 memory forwarding/scalar-promotion passes must initially treat all
production ownership/runtime operations as barriers. A Term represented in a
machine U64 is not thereby an ordinary arithmetic scalar, and its heap location
is not an Nx pointer. Preserve that distinction in IR types or semantic metadata
so generic scalar arithmetic, inlining and allocation promotion cannot silently
discard ownership effects.

## Smallest useful capability increment

1. Add a versioned runtime-import table with exact signatures and effects, plus
   opaque `Term` and runtime-context roles. Host pointers, Term words and U32
   values need distinct admission checks even if some share a machine width.
   Keep unknown calls conservative and cache keys bound to the runtime ABI,
   constructor tables, runtime object and imported symbol signatures.
2. Add structured constructor-tag tests, owned constructor take, constructor
   build, keep and sink operations. The first implementation may lower these
   to ordinary C-ABI calls. Model transferred children explicitly; a take is
   effectful and produces several owned values. Do not fake it as independent
   pure field reads. Use a bounded caller scratch buffer or an explicit result
   structure with a documented lifetime, not one heap allocation per field.
3. Lower the admitted List/String worker from checked KTerm with exact erasure
   and ownership decisions. Preserve branch demand. Initially use generic boxed
   constructors and conservative sealing rather than transferring product/cold
   layout optimizations at the same time.
4. Form an explicit loop for the worker's self-tail recurrence, after evaluating
   its next arguments and completing required ownership operations. Introduce
   an authenticated owned-Term test entry; retain the current scalar ABI for
   existing fixtures rather than smuggling pointers through its integers.

This is a generic constructor/match increment with two real source witnesses,
not a name-specialized lexer intrinsic. Decline unsupported types, effects,
partial applications and recursion shapes explicitly.

## Reuse the runtime through an ordinary C ABI

Prefer a small exported adapter around the **existing** runtime. A prospective
interface passes an opaque context pointer and U64 Term values, avoiding direct
cross-language passing of the current `Env` struct. Wrappers can reconstruct
`Env` internally and preserve its helpers exactly. Constructor take/build must
bind program identities and ownership policy, not accept unchecked arbitrary
IDs. This interface is proposed; it does not already exist as a reusable library.

The current runtime is a template: helpers are largely static/inline, tables and
dispatch are emitted into the same translation unit, and `term_drop` needs
constructor/function arities. Therefore "compile runtime once" requires an
explicit split between stable runtime code and per-program tables/entry points.
Start with a fixed authenticated test table and one cached runtime object; then
replace generated compile-time tables with a versioned descriptor interface.
Measure the extra C-ABI call cost before deciding which tiny operations merit
direct Nx lowering. No new collector, allocator or ownership model is needed.

The first adapter may itself be acquired once using the current Clang toolchain.
That removes Clang from repeated worker experiments, but does not remove it from
bootstrap acquisition. A later portable CPU runtime build must address existing
Clang-specific scheduling conventions; merely switching its driver to GCC is
not equivalent.

## Tail calls, scheduling and devices

`runtime.c:110–135` distinguishes device switch dispatch from CPU functions using
`preserve_none` and `musttail`. `ne_jump`/`ne_ret` in `emit.bend` target that
protocol. An ordinary QBE C-ABI call is not a guaranteed constant-stack scheduler
transition. The current Nx self-tail transform is restricted to scalar frames
and does not establish owned-Term transfer. Extend it with ownership invariants,
or emit the admitted worker loop directly after a checked tail analysis.

For later mutual recursion use an explicit dispatcher/trampoline or a backend
with a qualified guaranteed-tail ABI. Do not depend on incidental optimizer tail
calls. Keep the CPU worker adapter separate from scheduler tasks, IO, bang/fork
metadata and device segments. The production runtime contains Metal/CUDA paths;
their existence does not validate the proposed QBE CPU path for GPU execution.

## Gates and estimated work

These are implementation estimates from this source inspection, not measured
delivery rates or performance promises. Use separate stop/go checkpoints.

| Increment | Estimated focused work | Required evidence |
| --- | --- | --- |
| Freeze exact checked reverse definitions, layout manifest and test inputs | 0.5–1 hour | Dependency graph, checked annotations, IDs and source/runtime hashes; document refusal of wider inputs. |
| Fixed-table production-runtime C-ABI adapter | 2–4 hours | Unique/shared/static roots; keep/take/build/sink ownership; allocator accounting and fresh process tests; no compiler algorithm in host glue. |
| Structured ADT lowering and owned self-tail loop for both witnesses | 4–8 hours | Real unchanged Bend bodies lower; branch/erasure correctness; deep lists do not grow native stack; C/QBE differential outputs. |
| Broader lifetime and compilation-cost qualification | 2–4 hours | Shared tails and string heads, alias survives reverse, empty/singleton/deep inputs, all return/drop paths, exact input preservation where owned aliases remain, bounded memory, raw/optimized agreement. |
| Expand to `f_scan_word`/`FScanned` and token construction | Further 8–20 hours | Char semantics, closure/demand or certified direct-choice lowering, product/opaque fields, Unicode and exponent/sign cases, lexer positions and residual input. |

Use the same production allocator and inputs on both generated paths. Measure
frontend/lowering, QBE/object/link time, execution, allocations, peak live heap
and code size separately. Reuse cached runtime objects; run small ownership
controls on each change and reserve full compiler-image acquisition for a
qualified boundary. Derive projected whole-compiler gains only after profiling
coverage and runtime cost of the newly lowered slice.

A fully Clang-free **compiler image acquisition** additionally needs coverage for
the compiler's general ADTs, closures, calls, arrays and host IO, plus a portable
runtime/scheduler build. The reverse experiment would establish the missing
production heap/ownership bridge; it would not establish that full self-hosting
coverage or provide a reliable schedule for it.

This task inspected source only. No new lowering, adapter, runtime variant,
compiler build or generated-target execution was performed.
