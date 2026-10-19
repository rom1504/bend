# Phase112: direct QBE speed campaign

Status: in progress, 2026-10-19. Work window 00:41–03:41 UTC or later.
The [design](../../design/phase112/qbe-parity.md) defines the frozen comparison,
three ambition levels, resource limits and promotion gates. Production is unchanged.

## First findings

The initial generic lowerer repeatedly scans let suffixes for variable uses. A
backwards persistent use-set pass preserves the complete emitted QBE for six
source inputs and passes 47 independent/differential helper controls. In paired
warm hosted lowering diagnostics, the 64/128/256-statement chains take 0.612/0.184/
0.123 times baseline; lexer/list/U32 fixtures take 0.807/0.942/0.941 times baseline.
These are lowering-only observations, not native compiler or upstream ratios.

The frozen Unicode batch source timed out after 120 seconds under the baseline
native compiler and 60 seconds under its checked hosted API. The liveness
candidate completes staged emission in 13.26 seconds (frontend 2.06; lowering
8.34; verification 1.22). A longer staged baseline is being collected to locate
the bottleneck and establish identical generated output.

Direct scalar U32 lowering passes 57 source boundary observations. A first
self-tail-loop planner passes 13 controls but initially admits no loop in the
real arithmetic fixture: an error branch contains a continuation frame. The
revised planner preserves exact terminal failure branches while refusing frames
that can reach a loop. Independent review also found that secondary runtime
buffers must be constrained to scratch, not arbitrary state pointers. Neither
change is promoted solely on source review.

## Evidence locations

Local raw receipts live under `selfhost/build/phase112/` and the explicitly named
`selfhost/build/phase111/p112-*` products required by existing tooling. Full
source/API/input hashes accompany acquisitions. A compact committed evidence
capsule will be sealed at phase completion. Failed timeouts and rejected compiler
checks are retained.

- `liveness-controls01/report.json`: 47 controls.
- `liveness-scaling02/report.json`: paired diagnostics and exact QBE hashes.
- `phase111/p112-liveness-unicode01/report.json`: staged Unicode emission.
- `baseline-acquisition-guard01`: native Unicode timeout.
- `baseline-api-guard01`: hosted Unicode timeout.
- `loops-controls01`: initial loop controls.
- `phase111/p112-scalar-boundary-build01`: native scalar observations.

Disk pressure was reduced by hardlinking 950 authenticated identical generated
files, recovering 1,265,594,368 bytes while retaining every pathname and byte.
All subsequent generated products use fresh paths.
