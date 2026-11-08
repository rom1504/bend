# Phase181 — Bend-written AMD64 backend

Start from2e9ac9d. Build a real assembly target using the existing checked native
operations, runtime and semantic verification. No production selector change.
The continuing project handoff is
[`docs/self_hosted/projects/x86-backend/STATUS.md`](../../docs/self_hosted/projects/x86-backend/STATUS.md).

The destination is complete native self-hosting. First establish source-to-executable
operation on a real compiler workload, preserving independent semantic oracles.
The existing QBE target remains the reference. A replacement for QBE's measured
8.1s alone does not explain or remove the151s spent inside our compiler. Compare
complete requests and produced executables; do not claim speed from deleted tools.

## Architecture and milestones

1. Reuse the full verified native program: segments, direct workers, static data,
   IDs and capability permissions. Emit AMD64 SysV assembly in Bend, using a
   per-function frame/placement model and structured N111/P113 operations.
   Preserve call/ownership order and self-loop snapshots. Keep existing assembler,
   linker and pinned runtime object. No QBE text parsing or host-language compiler.
2. Establish arithmetic/ABI controls and an extracted compiler workload. Include
   calls with stack arguments, multiple results, branches, memory, data relocations,
   non-tail calls and stack-safe loops. Use literal expected outputs and existing
   independent QBE/hosted controls; unsupported operations fail explicitly.
3. Recover generated-code quality with measured register placement and preserve
   useful late semantic rewrites. Distinguish omitted optimization from unsupported
   semantics. A conservative correct path does not inherit QBE's quality claims.
4. Attempt the complete compiler only once smaller workloads establish feasibility.
   Native generations and independent gates must precede promotion. Direct ELF
   object emission is a follow-up once assembly is correct and its costs measured.

Use one controlled target lane, default2GiB RSS/5GiB disk reserve. Native image
acquisition uses the explicit qualified Phase175 N2. Cheap source/control checks
precede native builds. Agents work on disjoint compiler modules or independent
audits; root owns integration and measurements. Preserve failed attempts.

The first placement policy may reserve stack homes and a small set of callee-saved
registers. This deliberately simple baseline exposes actual register-pressure and
instruction-selection costs before a broader allocator is justified. It must
respect16-byte call alignment, hidden state/result arguments, caller clobbers,
exact32/64-bit behavior, simultaneous tail reassignment and runtime buffer lifetimes.

Report source acceptance, finite semantics, backend eligibility, native execution,
generated program speed, compiler/request cost and self-host qualification
separately. No proof claim follows from a successful native reproduction.
