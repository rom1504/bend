# Phase109: explicit runtime imports over shared Nx

This is an implementation and source audit. Execution evidence is recorded by
the root integration run; no target runs or image builds were performed by this
subtask. The baseline is `caee748`, with Phase106/107 Nx files left unchanged.

## What changes

The existing Nx representation already has the scalar widths, typed arguments,
branches, loops and direct calls required to express an ownership-heavy worker.
The missing boundary is a library with external function signatures and an
opaque context ABI. Adding a second general IR or another QBE emitter is not
necessary for this slice.

`selfhost/tools/performance/phase109/nx/library.bend` adds:

```text
NxImport  { name, params: List<NxParam>, result: NxType }
NxLibrary { imports: List<NxImport>, functions: List<NxFunction>,
            exports: List<String> }

nxlib_verify(library)   -> Bool
nxlib_qbe(library)      -> String
nxlib_c(library)        -> String  // matched C control, same graph/runtime ABI
nxlib_optimize(library) -> NxLibrary  // optional local constant folding only
```

The exported library ABI is `(context: NxPtr, terms: NxU64...) -> NxU64`.
Imported runtime functions have individually exact signatures. `NxU64` here is
the machine carrier for a tagged production Term, not an ordinary pointer or a
U32 scalar. Ownership meaning remains in the structured layer above Nx.

All calls retain the existing `nx_pure = false` classification. They may occur
only in statement roots; the unchanged Nx type verifier rejects calls nested in
arguments, arithmetic operands or conditions. This prohibits moving ownership
effects into unspecified operand evaluation order. Even `rt_id`, which borrows
its argument, initially has the conservative effect barrier.

Import declarations enter existing signature lookup through a private projection
to `NxFunction` records with empty bodies. Those records are **only lookup
entries**: the verifier checks actual definitions separately, QBE emission emits
only actual definitions, and no closed-program optimizer receives the projected
context. Thus imports cannot be inlined as empty definitions, dropped as dead
definitions or supplied as implementations by accident. A separate declaration
ADT makes that boundary explicit without invasive edits to existing walkers.

The existing scalar `NxProgram` API, `nx_verify`, public U32 result restriction
and scalar argument admission are unchanged. Library exports must name real
definitions, must be unique, and cannot export an import. Imported names must be
valid, unique, disjoint from definitions, and have valid unique parameters and
result types. Calls have exact arity and parameter/result width checks through
the shared verifier.

## What is deliberately refused

The initial opaque-runtime library rejects `NxAlloc`, `NxFree`, `NxLoad`,
`NxStore`, `NxOffset`, `NxFunc`, `NxICall` and pointer constants. Therefore it
cannot accidentally instantiate Phase107's synthetic calloc/free model or peer
inside the runtime context. It emits neither the scalar ABI wrapper nor the
`nxq_alloc` helper. The QBE function body, statement and expression emission is
shared unchanged with Phase107 (`nxq_function`).

Direct calls, loops and local values remain available. Closed-program
reachability, demand/leaf inlining, allocation promotion and memory forwarding
are not exposed for `NxLibrary` in this phase. They need an import-aware effect
and graph contract first. Optional optimization reuses only the existing local
constant folder and re-verifies the result; U64 Term operations and effectful
calls are retained.

These checks establish structural/type validity, **not ownership, runtime
lifetime, scratch-field linearity, stack bounds or whole-compiler correctness**.
For example, Nx represents Term with U64 and does not itself prevent arbitrary
U64 arithmetic on it. The structured ownership layer must enforce that stronger
boundary. The context must be a live object supplied by the matching runtime;
pointer typing alone cannot prove this.

## Versioned runtime signatures

`runtime.bend` declares the agreed `bend-runtime-109-v1` ABI. Logical names have
the existing QBE emitter's `nx_` symbol prefix, e.g. `rt_keep` emits
`$nx_rt_keep`.

| Import | Arguments after opaque context | Result | Contract |
| --- | --- | --- | --- |
| `rt_id` | Term | U32 | Borrowed constructor identity observation |
| `rt_keep` | Term | Term | Return the potentially changed retained owning word |
| `rt_sink` | Term | U32 zero | Consume one ownership token |
| `rt_take2` | Term | U32 zero | Consume parent and populate two context scratch fields |
| `rt_field` | U32 index | Term | Transfer one scratch field exactly once |
| `rt_build2` | U32 cid, Term head, Term tail | Term | Consume both children into constructor |
| `rt_zero` | U32 cid | Term | Construct admitted nullary constructor |
| `rt_fail` | U32 reason | Term, unreachable | Abort on an erased impossible/default arm |

The current constructor catalogue is `Nil=0`, `Con=1`, `SNil=2`, `SCon=3`.
Both scratch fields must be transferred before another take. The structured
lowerer and runtime tests must cover this; it is not inferred from Nx types.

The matched C emitter in `c.bend` shares the existing Nx expression and statement
renderer. It supplies explicit external prototypes and exports only named
library workers. Unlike the scalar C boundary's `uintptr_t`, its pointer
declarations use `struct NxRt *`, matching the actual runtime ABI at the C type
level as well as the machine level. It emits no allocation helpers. This permits
QBE versus Clang/GCC comparisons holding the lowered graph and runtime object
constant; the existence of the control does not itself establish a speed ratio.

## Prepared controls

`controls.bend` exposes `nxlib_control_report()`. It prepares 30 library
admission/refusal cases plus five barrier/nonregression checks: identity,
explicit import, sequencing, missing/duplicate/colliding import,
bad signatures, wrong Term/context width or arity, nested effects,
raw allocation/context access/free, indirect imports, invalid exports and
wrong exported ABI. Separate checks assert calls remain effectful, the scalar
entry rule remains unchanged, and local folding preserves imported calls.

The expanded catalogue also checks distinct `raw`, `trusted` and `fused`
imports, rejects mixed checked/trusted call names, validates the fused index
width, and rejects an unknown policy. Trusted calls remain effect barriers.

These are structural controls, not semantic output or performance measurements.
Root should execute them alongside actual ownership kernels and frozen runtime
witnesses before using the library path in a compiler image.

## Independent ownership-lowering review

The subsequent source review inspected `lower/{model,lower,nx}.bend` and the
actual runtime adapter. Four important connections are present in the source:

- Use counts are computed at a terminal expression after matcher descent, so
  mutually exclusive branches do not share a summed retain budget.
- `NxoKeep` assigns the result of `rt_keep` back to the same word. This matters
  because production `term_keep` can allocate an RFC wrapper and return a
  different bit pattern. Later uses therefore see the returned handle.
- `NxoTake` lowers to one parent take followed immediately by both scratch
  transfers; no constructor or second take intervenes.
- A tail transfer first saves every argument into `nextN` locals, then overwrites
  `pN` locals. This preserves swaps and dependencies among outgoing arguments.

The review found that Nx checking alone could not reject duplicate ownership
consumption, a missing retain/drop, an overwritten live owner, or tail-transfer
fallthrough. It also found an implicit logical consume in nullary matching.
The lowerer owner made that consume explicit as `NxoTake{word,[]}`, which emits
no runtime work only for a proven immediate nullary constructor.

`lower/verify.bend` now provides `nxo_verify(ops,arity)`, an independent path-local
credit checker. Every parameter begins with one owning credit. Keep adds one;
sink/build/take/return/tail consume their specified credits. Fresh results cannot
overwrite live credits. Each returning or tail-transferring path must exhaust
all credits; branch paths are checked independently. The only exception is
explicit fail-stop, which aborts the process. Tail argument count and terminal
position are checked separately from ownership counts.

The checker tracks constructor identities refined by branch tests or builds.
An empty-field take requires a known `Nil`/`SNil`; a binary take requires a known
`Con`/`SCon` and two distinct fresh destinations. Thus replacing a binary take
with a silent nullary discard fails admission. The atomic semantic take still
depends on correct Nx expansion and runtime scratch transfer behavior, tested
separately; this validator does not prove the expander or runtime implementation.

`lower/verify-controls.bend` prepares `nxo_ownership_report()`: 28 owned-IR cases
(seven positive and 21 negative mutations), independent of source occurrence
counting and Nx typing. These include missing keep/sink, double consume,
keep/return after consume, unrefined or wrong-arity take, scratch collision,
overwriting a live owner, duplicate tail arguments, fallthrough and one leaking
branch. Execution status belongs to the integration report. The checker does
not establish constructor child types, runtime reference-count correctness or
whole-source compiler correctness.

## Trusted runtime and reconstruction policy review

`nxlib_runtime_imports_policy` admits exactly `raw`, `trusted` and `fused`, with
an explicit policy predicate. Raw retains the eight checked imports. Trusted
has seven identically typed `rt_fast_*` imports plus checked fail-stop. Fused
adds `rt_rebuild2(context,parent,cid,keep_index,other) -> Term`. An unknown
policy has no import declarations and is refused before lowering by
`nxo_finish_policy`. The original default remains raw.

Trusted entry preconditions come from the authenticated checked source,
fixed constructor descriptor, verified ownership IR and live runtime context.
Ownership credits alone do not prove child types or context validity. The
checked public runtime entry points and negative tests remain a separate gate.

Independent source review of the reconstruction policy found these required
conditions implemented: an exact adjacent `Take2; Build2; Tail2` sequence;
the new first field is exactly one taken field; the other argument is an
external owner distinct from both children and parent; the destination cannot
overwrite parent, children or the external owner; the tail transfers the new
constructor and remaining child exactly once. No intervening keep, observer or
effect is crossed. The original semantic graph passes ownership verification
before trusted or fused machine operations are constructed.

The runtime uses the unchanged production `ctr_take`, which returns an actual
reusable location only for unique ownership. Shared references return zero
after correctly retaining children, so they allocate a new node. A static
constructor may return a nonzero immortal location; the explicit
`spare >= HEAP_OFF` condition prevents overwriting it. Both zero and static
spares allocate. The retained child and external owner still pass through the
same `rfc_seal` constructor logic. The remaining child enters scratch slot zero
and is transferred immediately by `fast_field(context,0)` before the tail move.

This review supports the stated ownership/alias mechanism. Runtime tests with
unique, shared and static inputs are still necessary, and the compiler's
pattern-matching policy is not a proof of a general reconstruction theorem.
Measurement and promotion decisions remain in the root integration report.

## Admission-boundary finding

A later read-only end-to-end review found that checked-fact transport had been
trusted too broadly inside the experimental lowerer. `kid(t,0/1)` consumed the
expected children but silently ignored extra children on several node forms.
The caller supplied the correct fixed constructor catalogue, but the lowerer
did not itself reject a reordered, incomplete or identity-mutated catalogue.

This is an observed admission gap, not evidence that authenticated source
fixtures were miscompiled. The root-run pre-fix harness
`selfhost/build/phase109/admission-before01/report.json` records 26/38 passing
expectations and 12 unexpected admissions, with no exceptions: extra children
on Mat/Lam/App/Var/Ref/Efq, an invalid lambda quantity, and five catalogue
mutations. The positive controls are actual authenticated facts; the corrupt
inputs are explicitly fabricated transport mutations, not typechecked sources.

`lower/admission.bend` adds a small gate for exactly the shapes consumed by this
lowerer: Mat2, Lam1 with quantity1/2, App2, Var0, Ref0, Efq0 and declared
constructor field counts. It binds exact fixed descriptor order, names, IDs and
arities. Unsupported forms refuse. `nxo_lower_policy` checks this before lowering.
This deliberately does not reimplement the Bend checker, prove globally unique
binder IDs or authenticate an arbitrary caller-supplied `NativeErasedBody`
label; those remain responsibilities of the checked frontend and transport.

`lower-admission.mjs` preserves 38 bounded cases: six authenticated positives
across raw/trusted/fused and 32 malformed/unsupported mutations. It also covers
external, indirect, non-tail, partial and oversaturated calls and parameter
count boundaries. Every mutated input and diagnostic is written, and an
exception never counts as a valid refusal. Post-fix execution is recorded by
the root integration report.

## Consequence for the larger architecture

One useful simplification is already clear from source inspection: direct Nx
need not reimplement runtime heap representations merely to gain full-width
ownership-aware computation. Explicit imports preserve that boundary while
letting a structured Bend lowerer retain ordinary local control flow. Whether
this lowers runtime traffic or improves build time is a measurement question;
the new boundary itself is not evidence of a speedup or full-language coverage.
