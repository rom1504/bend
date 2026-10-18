# P109-001: structured ownership before machine lowering

Status: designed; implementation in progress.
[Design](../../design/phase109/direct-owned-ir.md).

Hypothesis: preserve checked erasure/ownership decisions as structured operations,
then lower to an Nx library with explicit runtime imports. This removes cproc from
owned-worker acquisition without reimplementing Bend's heap or source semantics.

Real source witnesses: unchanged compiler nt_reverse<List<String>> and heldout
Base String.reverse.go. Controls cover shared/static/deep roots and retained aliases.
Production nt_reverse already has a direct worker loop: no per-cell trampoline
removal gain may be credited to this experiment. A separate matched transport
comparison will distinguish ABI and machine-backend costs.

Reject unsupported shapes explicitly. Imported effects are barriers. Compare actual
products and independent outputs before timings, and retain negative results.
Full compiler Nx self-hosting and installed-default promotion are later gates.
