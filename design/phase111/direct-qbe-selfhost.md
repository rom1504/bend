# Phase111: complete direct QBE compilation

Status: implementation authorized on 2026-10-18. Starting commit
`569914d223731ff1a9dc5e083fb8613d9778cecc`, branch `selfhost/bootstrap`.

## Objective and boundary

Compile the complete compiler written in Bend through a structured native
representation directly to QBE, assemble and link it, and use the resulting
native executable to repeat that compilation. Ordinary requests must not emit C
or invoke cproc. The retained C runtime may be compiled once and cached. This is
not a claim that acquiring QBE, the runtime or host providers never needs a C
toolchain. Keep the installed compiler and the full Phase108 route available
until the replacement satisfies its own qualification gates.

The source of semantic truth is the selected mature compiler at
`selfhost/build/phase102/projection-cost-source01/compiler.bend`, SHA-256
`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`.
The base source modules alone lack later selected lowering improvements. Source
composition must authenticate the selected source, preserve it except for named
entry replacements, and record every added module. Compiler algorithms remain
in Bend. Python/JavaScript may prepare sources, supervise tools and record
evidence; they must not implement the new semantic lowering.

## Why this architecture

Phase108 demonstrates full native QBE self-hosting through C/cproc. Phase110
demonstrates direct owning IR for a restricted String/List library. Neither is
the desired full direct route. Extending that narrow library frontend duplicates
general language semantics; parsing C merely relocates the existing boundary.

Reuse the mature checked frontend, erasure, constructor identity, liveness,
closure capture and continuation decisions. Introduce structured operations
before native expressions become C strings. Emit QBE for the established
`Reply segment(WlState*)` portable ABI. Keep the explicit trampoline, allocator,
reference counts, arrays, tasks and host effects. QBE's ordinary calls, loads,
stores, branches, function addresses and data relocations are sufficient; a new
SSA optimizer or assembly backend is not a prerequisite.

The first implementation may deliberately bypass optional NF/NQ/observer
workers. This can substantially slow the resulting compiler. The approximately
149-second selected-source emission is not a valid deadline prediction for a
generic boxed successor. Preserve correctness first, then measure the full cost;
do not promote an unusably slow fallback as a performance success.

## Interfaces

1. **Checked request → structured segments.** Opaque owning Terms remain
   distinct in the representation from raw addresses and U32 values. Include
   Keep with its returned handle, Sink, construction, destructive take,
   continuations, direct/dynamic application, primitives and explicit failure.
   Unexpected erased forms produce a named error, never a silent C fallback.
2. **Segments → QBE module.** Preserve evaluation order, argument bank transfer,
   exact 64-bit constants, function identities and program data. Resolve symbols
   without a whole-program quadratic scan. Avoid mandatory full JSON copies.
3. **Module → runtime.** Use a versioned program descriptor and explicit
   capacities/layout. `STAT_OFF` depends on result-bank capacity in the current
   runtime; changing one macro into a variable is not sufficient. Preserve the
   separate next-function ID and scheduler Reply sentinel. Reset outgoing banks
   only after incoming values have been captured.
4. **Native CLI.** The executable checks source using the retained frontend and
   emits QBE/data. Link to the authenticated runtime object. Keep source checking,
   lowering failures, assembly/link failures and execution failures separately
   visible. The CLI must not trust caller-supplied semantic certificates.

## Sequential integration gates

### A. Freeze the contract and establish a fast loop

Inventory selected erased forms, runtime calls and metadata. Agree the segment
model and runtime ABI before parallel edits diverge. Compile/check small new
modules through the existing checked API. Run actual checked-source fixtures for
capturing closures, non-tail calls and IO, plus primitive/array boundaries. Each
successful case must emit QBE and execute against independent expected output.
Record unsupported cases rather than counting refusal as conformance.

### B. Complete generic language and module coverage

Add every source form needed by the compiler, constructor and closure layouts,
full primitive semantics, continuations, readback and required host effects.
Use fast focused cases per new boundary. Audit emitted code and build commands
to establish that ordinary requests contain no C generation/cproc invocation.
Keep CPU single-thread operation explicit until separate parallel gates pass.

### C. Build the complete compiler

Acquire the new compiler entry once using the trusted existing route after the
fast gate passes. Use it to emit the full compiler directly to QBE, assemble/link
the image, and run real source/check/compile requests. Freeze exact sources,
runtime, tool versions and emitted modules. If performance or memory blocks the
full input, reduce/profile the actual boundary before repeating the expensive
build; a timeout is an observation, not a completed milestone.

### D. Qualify self-hosting and measure

Use the directly produced native compiler to produce its successor. Check
deterministic QBE products where applicable and independent semantic outputs.
Run the retained focused negative and full-language controls, then the broader
program set once. Report compiler latency, generated-program runtime, memory,
conformance and added complexity separately. Compare like-for-like inputs,
runtime, resource limits and preparation. No upstream parity claim from a
matched kernel or a single bootstrap.

### E. Package and document

Provide reproducible acquisition, direct compilation and replay commands, ABI
limits, retained runtime dependencies and measured status. Record unsuccessful
attempts and remaining gaps. Update the frontier, write the implementation
report, and commit/push coherent checkpoints. Default promotion requires the
separate installed compiler gates; completing an experimental route alone is
not permission to weaken them.

## Efficient execution

Parallel source work: semantic lowerer, runtime/descriptor extraction, QBE
module emission, and independent coverage review. Root owns source assembly,
integration and the sole CPU3 target lane. Agents do not launch overlapping
compiler builds or timing jobs. Agree contracts early; use small checked modules
and fixtures before full acquisitions. Preserve failures; avoid rerunning
unchanged broad validations.

Use the existing process-tree guard. Full acquisition starts with a 4GiB RSS cap
and 16GiB available-memory floor; raise neither without evidence. Current disk
space is below the guard's floor. Reclaim only hash-verified archived generated
outputs, recording restoration paths and actual freed space. Preserve sources,
selected executables, runtime dependencies and failed receipts. No PR comments.

## Falsifiable claims

- A full-language direct backend can reuse the existing runtime ABI without
  cproc: demonstrated only by actual checked-source QBE execution and full self
  emission, not by the existence of an emitter.
- Generic semantics suffice for self-hosting: rejected or qualified if real
  compiler workloads hit unsupported forms, ownership faults or impractical
  resource costs.
- Removing C translation improves the research loop: requires complete build
  timings including runtime acquisition/amortization and verification; fewer
  stages alone do not establish a speedup.

See [Phase108 lowering audit](../../implementation/phase108/lowering-audit.md),
[runtime audit](../../implementation/phase108/runtime-audit.md), and
[Phase110 report](../../implementation/phase110/README.md).
