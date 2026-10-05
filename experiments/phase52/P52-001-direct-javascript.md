# P52-001: upstream-compatible direct JavaScript backend

Status: authorized, implementation in progress; no measurement or promotion yet.

Hypothesis: making direct calls/native closures the ordinary lowering strategy
removes descriptor/guard overhead for a broad range of checked Bend programs.

See the [design](../../design/phase52/direct-javascript.md). The new mode has the
upstream callable interface; the existing mutable descriptor interface remains
available. The TypeScript implementation is a reference/bootstrap only.

Falsifiers: incorrect erasure, staging, effects or representation; hidden legacy
runtime dependency; no executed code-shape change; wins limited to renamed
special cases; or clean multi-shape execution failing to show substantial gains.

Outcome and evidence will be recorded in
[implementation/phase52](../../implementation/phase52/README.md).
