# Final checked self-reproduction

The final source reaches a **checked B1→H→H fixed point**. The unchanged
maintained runner completed both stages, and an independent retained-file audit
read the actual outputs and found them byte-identical:

- 1,170,415 bytes each;
- SHA-256 `5043267732f5178b12d14708e7dc07e3aa1a71b9d1d5949ef279af23c4297edd`.

Both proof outputs also match **each of the four actual P523 Bend outputs** byte
for byte. Those measured outputs remain separate evidence; none was imported as
an assumed proof stage. The proof used a fresh directory, genuine checked B1,
no resume history and no fabricated bootstrap sidecar.

The [independent audit](final-selfhost-audit.json) passes on its first attempt,
verifying 225 file identities and all 59 production module identities. Its
[auditor](final-selfhost-audit.py) executes no compiler or generated module.
The original [attempt01 result](final-selfhost-audit-attempt01.json), exact
pre-execution auditor source and file-backed stdout/stderr are retained in the
proof directory's `audit-history/`; the final JSON is a byte-identical copy of
that successful result. The [final evidence archive](final-selfhost-evidence/manifest.json)
preserves 232 historical file identities in 96 content-addressed objects,
including the proof directory and audit artifacts (946,004 compressed bytes).

## Source and execution identity

The genuinely checked initial API is
`5969c53d34a088bc9630eb2c065c2eea7fd260294cf3fefb14dffb305b7e4667`,
from integration 05 and assembled source
`e3b927d13dc2645e19171b72de60c49dd5bc5e5059863937153b957e2ce0ec1d`.
For every one of the 59 `compiler.json` Bend modules, current production bytes,
the integration snapshot and the assembly snapshot match the genuine bootstrap's
module SHA. The actual assembled source, canonical pinned Base, output runtime,
initial API and frozen host match the proof records and P523 input identities.

The runtime is SHA
`26f5eee2f54b194b64f768df6ff505c67bf7a5df2159aa06caf53ecba54e910b`;
Base is SHA
`b8c2734d45ec6b4ce70fee70ff06ef35e08fce885af8852d8eb77dbff020e946`
at the canonical pinned checkout. The maintained selfhost runner, actual driver,
ABI, native-build, assembler and resource-helper bytes remain unchanged from
those recorded inputs. This uses the normal source loading, checking, ownership,
specialization and emission path; the compiler producing stage3 is the actual
stage2 output.

The launch/proof reports both complete successfully, with verified inputs, no
signal, spawn error, timeout, overflow, interrupted/resumed attempt or skipped
stage. They record CPU 0, Node 24.18.0, 4 MiB Node stack, at least 8 MiB OS stack,
12 GiB heap, 40-minute per-stage timeout and 55-minute external launcher timeout.
Other intentional compiler/archive work was held; lightweight documentation,
source reads and separately disclosed Git/network metadata activity were not
claimed to be absent.

| Actual proof child | Recorded duration |
| --- | ---: |
| Genuine checked B1 compiles source to H (stage2) | 661.410s |
| That H compiles the same source to H (stage3) | 1,595.546s |

The launcher started at 01:32:44.957 UTC on 2026-09-23; the maintained proof finished
at 02:10:22.188 UTC. These durations are **descriptive proof observations**, not
an opposite-order H/TypeScript benchmark or a measurement of the B1 equality
derivative. No compiler or oracle was rerun for the independent audit.

## Provenance boundary and scope

The launcher directly records preparation/runner/compiler/driver/Base/runtime/
Node identities. Its maintained workflow/process imports were not directly
listed in the launch-entry inputs. Their actual current bytes additionally match
P523's earlier recorded identities; the audit labels that evidence a companion
association and does not rewrite the launch input list. The selfhost runner
separately verifies its actual source, Base, driver/helpers, runtime and stage
compiler before/after each stage.

This is the exact frozen source's checked JavaScript-library fixed point. It is
not native compiler self-reproduction, full-language conformance or evidence of
faster generated user programs. The final checked-B1 frontend/backend results,
and any subsequent conformance gates on this proven H artifact, retain their
own scopes and artifact identities. See the separate
[compilation comparison](full-source-comparison.md) and
[final frontend comparison](final-conformance.md).
