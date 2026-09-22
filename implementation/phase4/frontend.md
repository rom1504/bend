# Exact frontend observations

The original-source private compiler completed all **2,756** parse/check probes
from the **1,378** pinned fixtures. Every compiler observation and exact diagnostic
matches the previous Phase 3 compiler. A fresh live TypeScript run also matches
its previous observations. There are **zero new differences**, zero resolved
differences and the same **560 existing differences** between Bend and TypeScript.

This validates preservation of the recorded frontend behavior. It does not mean
full language conformance: the fixture judge still reports 377 Bend check-lane
failures versus three for the reference. Acceptance, rejection phase and exact
diagnostic/report differences remain separately recorded.

The private image is SHA-256
`1905c283551d4ad93c129549f8c540d8d21b47eb0486d88036f0afa9a0d4f9ab`,
specialized from the completed Phase 3 H proof. It runs behind a data-only worker
adapter with no incoming function objects or raw compiler graphs. This sweep
validates the private specialization independently of the later combined-source
compiler. A separate combined-source sweep is in progress.

Both sweeps use serial persistent workers on CPU 1, recycling after 64 probes,
with a 4 MiB Node stack, 4 GiB heap/RSS bound and a five-minute request deadline.
Each request constructs a fresh source graph. All fixture/adapter/compiler
identities remained unchanged, and every observation completed without a worker
crash, timeout or unsupported result. The private workflow took 2,562.167 seconds
and the reference 252.963 seconds inside their runners. These are unpaired full
workflow observations, including worker recycling; they are not controlled
request-latency medians or the focused edit loop.

## Retained reference setup failure

After the private sweep completed, the initial reference launch failed before
any probe because its frozen harness omitted two imported host helper files.
The original launcher remains incomplete, with the module-import error retained.
The corrected snapshot includes those dependencies; a fresh independent reference
sweep completed all probes. The comparison uses that actual new report and never
relabels the failed launch as a pass.

See the [setup-failure record](evidence/frontend-reference-setup-failure.json),
[compressed exact comparison](frontend-evidence/private-live-comparison.json.gz)
and [archive manifest](frontend-evidence/manifest.json). They preserve the original
candidate report, incomplete launch, new reference report and their hashes.
The [comparison tool](../../selfhost/tools/performance/phase4/frontend-compare.mjs)
requires equal fixture bytes and complete unique probe inventories, checks input
and worker integrity, and retains every historical change and live mismatch.
