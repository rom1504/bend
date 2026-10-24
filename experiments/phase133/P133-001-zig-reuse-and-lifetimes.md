# P133-001 — Zig-informed reuse and bounded IR lifetimes

Status: source-grounded research and derived bounds; no implementation promoted.

Question: does Zig justify a stronger route to compilation speed and compact IR
than Phase132's compact-name and post-emission object-cache experiments?

Method: inspect SHA256-authenticated official Zig0.17.0 source; separate stable
source from dated primary demonstrations; inspect current qualified Bend source
and module provenance; reuse the immutable Phase132 census/profile evidence.
No Zig binary, new compiler build or target execution was required.

[Main report](../../research/phase133/README.md) ·
[Incremental source audit](../../research/phase133/zig-incremental.md) ·
[Representation audit](../../research/phase133/zig-ir.md) ·
[Bend boundaries](../../research/phase133/bend-opportunities.md).

Findings: compact canonical facts, dependencies on specific results, persistent
compiler state and disposable per-function AIR compose into Zig's fast loop.
MIR expansion is explicitly budgeted; a tiny whole-program IR is not the claim.
The current Bend census's largest QBE function is171,719bytes versus107MB total;
this supports a bounded rendered-function buffer, not1MB total compiler state.
QBE's own pinned driver already processes and frees one function at a time.

Hypothesis for implementation: reuse a verified named owner/SCC unit before
numeric/static binding and bound its physical representation/emission lifetime.
First preserve exact output through a lifetime-only change, then intern one
identity domain and add dependency-correct reuse. Keep independent final gates.

Falsifiers: unchanged output cannot be streamed with bounded retained state;
packing adds more work than it removes; checked fact construction exceeds reuse;
local edits invalidate most units; global checking/linking dominates the edit;
or source/runtime/policy changes produce stale hits. No speed forecast can hide
these costs. Warm local-edit and cold full-compiler targets remain distinct.
