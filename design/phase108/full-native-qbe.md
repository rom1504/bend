# Phase108: run the full Bend compiler without Clang

Start: 2026-10-18 15:55 UTC. User requests the full compiler working through the
new setup. This phase prioritizes an actual full image and reproducible behavioral
evidence over additional scalar microbenchmarks. Compiler algorithms stay in Bend.

## Baseline and question

Phase107 has native parsing/checking plus Bend-owned scalar lowering, typed Nx IR,
optimization and QBE emission. It does not support the compiler's owned data,
closures, arrays, IO or general continuation graph. Its image is still acquired
through Clang. Production Phase103/102 has these capabilities and a qualified
native B1/B2 chain, but renders native segment bodies as C strings.

Can we reuse those qualified semantic decisions and build a full native compiler
through QBE, removing Clang's tail-call calling convention as a dependency?

## Two paths, with explicit boundaries

1. **Full compatibility path:** Bend checked core → existing Bend C lowering →
   cproc (C11 frontend) → QBE → assembler/linker. Replace the Clang-only host
   `musttail` transport with a bounded-stack ordinary-ABI segment trampoline.
   Keep the existing allocator, ownership transfers, constructors, continuations,
   static image, primitive implementation and IO. Native atomics may live in a
   small GCC-compiled support object if cproc cannot express them. This is a
   full-language compatibility experiment, not direct Nx lowering or elimination
   of all C/toolchain dependencies.
2. **Direct structural path:** preserve Phase107's Bend → Nx → QBE implementation.
   Later migrate generic segment operations to typed structure before C strings,
   using the compatibility path as an executable oracle. Do not independently
   rebuild the existing erasure/liveness/closure machinery merely to reach a full
   image. The initial audits document this boundary and its required imports.

The first path has much lower semantic implementation cost. cproc support for
system headers, atomics, floating point and generated worker functions is an
empirical admission gate, not an assumption. If it fails, retain the exact blocker
and evaluate the portable GCC route separately; do not label GCC output QBE.

## Sequential implementation gates

1. Pin tools and source identities. Freeze independent source controls: real list
   reversal with aliases, unrelated Unicode string reversal, captured functions,
   non-tail calls, arrays and IO, plus compiler rejection controls.
2. Add portable CPU trampoline behind an explicit opt-in. Each segment returns a
   next segment identifier through shared state, or an ordinary scheduler reply.
   Preserve stack, register bank, result count and sequential mode. Dead register
   values must be initialized before serialization. Device execution is unchanged
   and is not qualified by a CPU test. Add register-state metadata in Bend's table
   emitter rather than interpreting generated program bodies in a host script.
3. Compile tiny real programs through cproc/QBE. Independently test deep calls,
   ownership/aliases, arrays, host effects and (if admitted) threaded scheduler
   behavior. Compare complete outputs to frozen expectations and the selected
   compiler. Fix underlying ABI/semantic faults, not individual program shapes.
4. Build the actual selected compiler source through the portable runtime and QBE.
   First run one scalar source, then compiler-heavy sources, repeated requests and
   invalid input. Compare entire generated products/diagnostics under an identical
   output-runtime policy. Build a successor image using the QBE compiler and check
   bootstrap output consistency where resource/time budgets permit.
5. Measure separately: machine-code build time, full source-to-image time, compiler
   request time, generated-program execution time, peak RSS and code size. Use
   alternating matched pairs only after correctness. Retain useful small fast
   loops and document exact ordinary commands. Promotion requires evidence; do not
   silently replace the installed native release.

## Efficient execution and resources

Root serializes target work on CPU3 using process-tree guards. Agents inspect and
edit disjoint modules; no concurrent large target runs. Current disk headroom is
roughly0.5GiB. Stream intermediate compilation stages where practical, retain
failed receipts and hashes, and delete only explicitly rebuildable scoped scratch
artifacts after recording identities. Keep installed assets and prior evidence.

Use a small program to discriminate each ABI change before any ~30MiB full image.
Only reacquire a compiler image when compiler-source integration requires it.
Measure target occupancy separately from wall-clock research and never infer
billing/quota from elapsed time. No PR comments are authorized.

## Success and falsification

Success is a native QBE-built compiler that executes the real parser/checker/
eraser/backends, accepts and rejects the same tested inputs, and emits the same
complete products as its trusted parent under matched policy. A self-produced
successor strengthens this result. A tiny generated program alone is insufficient.
Speedup is a separate result; portable segment dispatch may cost runtime, and QBE
may optimize generated C differently from Clang. Report regressions plainly.

The installed production ratios from Phase105 and direct-Nx scalar ratios from
Phase107 retain their original denominators until measured anew. No whole-compiler
proof, GPU qualification or autonomous research acceleration is implied.
