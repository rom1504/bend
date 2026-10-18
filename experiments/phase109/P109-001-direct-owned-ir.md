# P109-001: structured ownership before machine lowering

Status: implemented and qualified for the selected ownership slice and native frontend.
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

Result: actual checked erased bodies lower through Bend-owned operations to QBE,
using the production heap/refcount runtime. A native Bend image produces all nine
source-contract/policy products exactly as the hosted path, agrees for cached/live
Base and passes four admission refusals. A fresh worker built from native output
passes thirteen independent graph/lifetime observations. Ordinary selected-library
requests need no JavaScript, Clang or cproc; image acquisition retains C/cproc/QBE.

The [report](../../implementation/phase109/README.md) and
[runtime-interface experiment](P109-002-runtime-interface.md) separate compiler
acquisition, native requests, generated-kernel speed and remaining coverage.
No production/default change or full-language direct-IR self-hosting claim.
