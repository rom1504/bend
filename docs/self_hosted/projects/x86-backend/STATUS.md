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
- [ ] Complete second-generation reproduction and final report.
- [ ] Report, commit/push and provide precise next action.

Reference producer: `selfhost/build/phase175/full-native-n2/program` with its
`report.json`; current production source is unchanged Phase178. Experimental
modules live under `selfhost/src/back/x86/`; they are not installed or silently
selected by the production manifest. Exact sources and receipts live under
`selfhost/build/phase181`; every target job must use the maintained outer guard.

Key risks: late QBE emission performs additional transformations; retaining
N111 alone loses private workers. Use the complete structured program, preserve
the runtime ABI and distinguish initially omitted optimization from semantics.
Ownership, stack safety, widths, multiresult conventions and static IDs are gates.
