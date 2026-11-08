# AMD64 backend — authoritative handoff

Status: working experimental Phase181 native emitter. Baseline2e9ac9d,
`selfhost/bootstrap`. No installed change. Scope and gates:
[design](../../../../design/phase181/README.md).

- [x] Identify structured native operations and existing full verification boundary.
- [x] Implement Bend machine placement, instruction selection and ABI/data emission.
- [x] Independently source-check; 17 ABI functions, 10 hygiene observations and nine source/output controls pass.
- [x] Compile/run a real parser/checker on a 656KB compiler source with matching observations.
- [x] Measure generated execution: selected emitter 17.14s versus QBE8.31s, 2.06×. Build observations are not an isolated target-speed comparison.
- [x] Build the complete experimental x86 compiler entry closure (1.415MB); the assembly-built image passes three source/output smoke cases.
- [x] Complete second-generation reproduction: identical assembly/object and loaded ELF sections; only an object-path string differs in the non-loaded symbol table. Both generations pass the three source/output smoke cases.
- [x] Report and reproducible evidence: [Phase181](../../../../implementation/phase181/README.md). Implementation commit17e207a; final evidence is committed separately.

Reference producer: `selfhost/build/phase175/full-native-n2/program` with its
`report.json`; current production source is unchanged Phase178. Experimental
modules live under `selfhost/src/back/x86/`; they are not installed or silently
selected by the production manifest. Exact sources and receipts live under
`selfhost/build/phase181`; every target job must use the maintained outer guard.

Key risks: late QBE emission performs additional transformations; retaining
N111 alone loses private workers. Use the complete structured program, preserve
the runtime ABI and distinguish initially omitted optimization from semantics.
Ownership, stack safety, widths, multiresult conventions and static IDs are gates.

The exact native entry closure is1,415,281 bytes, SHA256
`6d9408c2467f4d19731271569a501b94927556037605e11af1d48dce5e775366`.
X0=`selfhost/build/phase181/native-build02`, X1=`x86-n1`, X2=`x86-n2`;
each has its own authenticated build receipt. X0 emits this source in108.510s,
X1 in217.811s (2.007×); total builds117.811s and226.417s. These are the
experimental x86-entry closure, not the historical multi-target production build.

**Next bounded task:** apply existing `p112a_expand` runtime tag lowering before
x86 frame placement, then test guarded `p128bf` borrowed-field expansion. The
machine audit identifies actual missing operations in string equality, hash and
lookup. Preserve signature/fallback/fresh-name conditions; run focused ABI and
source controls, then the real checker. Only a meaningful transfer gain justifies
another full bootstrap. Copy/DCE and proper live-range placement follow;
direct ELF emission and installed promotion wait. No universal IR rewrite needed.
