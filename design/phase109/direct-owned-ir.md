# Phase109 — direct structured lowering with production ownership

Baseline: `caee748`, branch `selfhost/bootstrap`, inspected 2026-10-18.
User authorizes design, implementation, report and commits/pushes. No PR comments.

## Decision and objective

Make direct structured IR the development direction. Keep Phase108 cproc/QBE as
an executable bootstrap/reference, and keep the qualified production compiler
selected. Pause discretionary cproc optimization. This phase must demonstrate a
real compiler computation lowered in Bend from checked semantics to QBE without
C body emission/parsing, using the actual heap and ownership runtime.

The central question is whether preserved semantic operations and explicit runtime
imports provide a cleaner and cheaper acquisition boundary while retaining useful
machine-code quality. Removing cproc alone does not establish a runtime speedup.
Full-language migration follows evidence; no unchecked fallback or declaration of
full Nx self-hosting is permitted for a successful small slice.

## Observations and confounders

Phase108 self-hosts the full compiler through its mature C lowering and portable
continuations. Full self-emission is 338.89 s; native successor construction is
56.08 s. Six-source compiler execution screens at 3.22–3.34× selected Clang-native
B2. This changes both backend and continuation transport, and the early sampled
profile had overruns. Missing C helper inlining is supported, not an explanation
of the entire gap. Phase107's direct checked-source Nx route admits scalar types;
its synthetic calloc/free memory model is not Bend's tagged heap.

The current native `NR_Request` already contains checked erased bodies. Reuse
those facts; never reconstruct erasure from source spelling or generated C.
Current `N_Emitted.code`/`N_Segment.body` are C Strings. Introduce structure before
that loss of information. The production `nt_reverse` already has an ordinary
native worker loop, so this kernel cannot demonstrate elimination of per-cell
scheduler dispatch; that must be investigated with a separate non-tail witness.

## Architecture

```
Existing checked Bend frontend + annotation + native erasure
  → NativeErasedBody facts and admitted constructor descriptors
  → structured owned operations in Bend
  → Nx library with explicit runtime imports and typed library exports
  → existing Bend-written QBE emitter
  → QBE / GNU assembler + cached production-runtime object
```

Ownership operations retain constructor identity, field transfer, keep/sink,
ordinary returns and self-tail transfer. Terms occupy U64, context is an opaque
pointer, and Terms are never treated as process pointers. Runtime imports are
effect barriers. The scalar Nx entry/verifier remains unchanged; library entry
validation is explicit. Do not expose fake import bodies to optimization passes.

Start with a versioned fixed descriptor ABI for Nil/Con and SNil/SCon, arities
zero/two, and actual production heap/refcount helpers. `keep`'s returned word
replaces the old binding before either copy is transferred. `take` consumes the
parent and transfers each field exactly once; constructor building consumes its
children. Nullary owned values and static roots require their actual runtime
semantics. A cached runtime object may be built once with GCC/Clang; record that
acquisition separately. Repeated direct worker builds must not invoke cproc.

The eventual descriptor interface carries program identities/layouts and runtime
entry signatures; do not prematurely implement a general new allocator, collector,
scheduler or backend. Future extensions add ordinary calls, closures, continuation
suspension, arrays, foreign effects and parallel/device semantics with independent
gates. Context-local scratch is acceptable for a bounded initial take2 ABI only
if the verifier forbids overlapping transfer and escaped scratch values.

## Sequential implementation and falsification gates

1. Freeze exact real compiler `nt_reverse<List<String>>`, unrelated Base
   `String.reverse.go`, independent outputs/aliases and a continuation-heavy
   witness. Inspect source and native worker shapes. Preserve baseline images.
2. Implement explicit Nx library imports/export signatures and a small checked
   owned-operation lowering in Bend. Capture genuine existing erased facts through
   the checked Bend API; a JS host may transport them during fast development.
   Host code must not implement language semantics or mutate the tested bodies.
3. Build the actual production-runtime adapter once. Check unique/shared/static
   roots, empty/single/deep inputs, opaque string heads, retained aliases, field
   ownership, sink/drop and scratch lifecycle. Add refusal and mutation controls
   that exercise verifier boundaries. No compiler-image acquisition yet.
4. Compile unchanged source facts to direct QBE, then execute the runtime controls.
   Compare with C compilation of the same structured graph and, where practical,
   actual mature native worker bodies under the same runtime and inputs. Separately
   compare identical complete generated C under Clang original transport, Clang
   portable transport, and cproc/QBE portable transport; isolate accessor policy.
5. Measure cold object construction, warmed cached-runtime worker builds, execution,
   memory and code size separately. Use alternating rounds and checksums/oracles,
   not one startup-dominated timing. Inspect the generated instructions. If generic
   ownership import traffic dominates, test one semantics-preserving structured
   fusion or specialization; do not hide it in a name-specific runtime intrinsic.
6. Qualify the useful path, document unsupported constructs and rejected designs,
   and set the next migration gate from observed evidence. A native-hosted frontend
   rebuild is justified only after the checked fast loop works. Full self-hosting
   and broad45 remain separate expensive gates for eventual complete coverage.

## Competing hypotheses

- Structured ownership plus runtime reuse removes repeated C parsing/optimization
  cost and preserves sufficient facts for good direct code. Falsify with matched
  small kernels if acquisition costs merely move into runtime rebuilding or code
  becomes much slower despite simple available specialization.
- The portable continuation ABI is the primary QBE regression. Separate it using
  original/portable Clang and portable QBE on the same generated program; direct
  reverse workers alone cannot establish this cause.
- Runtime helper inlining is primary. Compare identical imports/body structure
  and inspect actual calls/assembly; avoid attributing all differences to inlining.
- The mature direct worker already captures most benefits. If true, the useful
  architecture is a structured encoding of those decisions, not a second optimizer
  or reimplementation of semantics. Keep the existing lowering as the source of
  facts and remove representation duplication incrementally.

## Resource, methodology and promotion policy

Root serializes target runs on CPU3 under process-tree guards; agents prepare
independent source/runtime/IR/control work. Default 2 GiB RSS, 4 GiB available
floor, short deadlines. No full compiler rebuild before a successful real slice.
Disk is constrained: delete only verified archived/rebuildable generated outputs,
record cleanup, retain failures and never delete user/source work. Preserve input,
method, runtime, object and tool identities. New evidence stays in phase109 paths.

No new goal object or arbitrary time commitment. Record actual work and qualified
capabilities rather than interpreting a plan as accomplished. The installed
compiler, upstream pinned sources, benchmark definitions and correctness gates
remain unchanged. Capture-only host interfaces may be extended explicitly without
changing ordinary behavior. Commit scoped changes and a report with observations,
hypotheses, demonstrated gains, limits, and an actionable next gate.
