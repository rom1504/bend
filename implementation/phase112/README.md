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
8.34; verification 1.22). A longer staged baseline failed naturally with a hosted stack overflow after
56.48 seconds inside lowering (60.39 seconds outer wall); no product equality
claim is possible for this source. The transformed product passes native execution.

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

## First generated-program screen

The six frozen Phase93 batch sources now have independently authenticated QBE
products. Three alternating rounds with the separately frozen fast profile yield
these combined-candidate/upstream runtime ratios: lexer35.53, ray211.81, closures
13.86, Unicode6.50, map11.08, numeric15.13; geometric mean22.01. This candidate
has backward liveness, U32 operations, self-tail loops and safe accessors. It
does not include the later private workers or static data. All measured outputs
are exact. These six points are a development screen, not the45-program claim.

The scalar recurrence kernel improves from87.86ms baseline to49.40ms with scalar
operations and5.51ms with the combined loop/accessor changes (0.0627 time ratio).
The representative results demonstrate why that narrow16x win cannot establish
whole-language parity. Continuation/call structure and primitive exposure need
further work.

Private-worker controls now pass native ordered calls, eight-argument transport,
pending continuations and four unique/shared owning loops. The CPU-only fail-stop
adapter preserves actual exit status/stdout/stderr for framed and unframed
failures, bound to exact runtime04 where err_post exits the process. Static-image
controls pass19 checks initially,20 after effect-name exclusion, plus8 native
semantic observations. Images stay capped at65536 words with dynamic fallback.
The original structural verifier remains mandatory.

The first full candidate image acquisition is running. Production remains
unchanged; native full-source and corpus gates are still outstanding.
