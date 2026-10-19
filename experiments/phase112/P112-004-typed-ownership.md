# P112-004: retain checked scalar facts before ownership lowering

Status: focused controls and matched six-program screen pass; full acquisition, exact self-emission,19 focused cases in each generation and45
one-shot successor programs pass. Broad timing is recorded in the final report.

The mature compiler already classifies canonical scalar parameters and aliases.
Generic Phase111 bindings discard those kinds. Reuse `nf_worker_kinds`,
`nk_typed_bindings` and `nk_binding`; skip retain/drop only for known `N_W32`.
Keep machine arguments U64, preserve capture kinds, and leave Nat/unknown/call
results/fields on the original owning path. Five declarations change. The
existing Word-pattern producer supplies another kind only after explicit masks.

Twenty-seven checked helper controls and eleven paired native outputs pass.
Source admission binds the original verifier/runtime, five exact deltas, mature
helpers and U64 transport consumers; ten mutations are rejected. Gap-if has
its independent22 structural controls and two native pairs, including a32-node
budget shared by both branches. These are semantic tests, not a global proof.

Three matched six-program rounds: gap11.9845×upstream, gap-if12.0455×,
facts10.9234×. Facts/gap-if is0.9068; lexer710→460ms. Outputs/counts all match.
Source SHA256:`1df2df372cb3614f7cb4d70f5d81741112b7b15943a4eba204407ef7c3232c71`.

The separate immediate-helper emitter is rejected by Unicode equality/counts
and is explicitly absent. Preserve its independent failure as evidence that
local controls alone do not establish compositional correctness.

[Implementation](../../selfhost/tools/performance/phase112/typed-ownership/README.md) ·
[Report](../../implementation/phase112/README.md) ·
[Rejected helper experiment](../../implementation/phase112/immediate-rejection.md).
