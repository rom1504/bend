# AMD64 backend — authoritative handoff

Status: implementing Phase181 first vertical slice. Baseline2e9ac9d,
`selfhost/bootstrap`. No installed change. Scope and gates:
[design](../../../../design/phase181/README.md).

- [x] Identify structured native operations and existing full verification boundary.
- [ ] Implement Bend machine placement, instruction selection and ABI/data emission.
- [ ] Independently source-check and run cheap arithmetic/ABI controls.
- [ ] Compile/run a real compiler workload against independent outputs.
- [ ] Compare complete build time and generated execution with QBE.
- [ ] Extend to full compiler after demonstrated feasibility; record blockers honestly.
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
