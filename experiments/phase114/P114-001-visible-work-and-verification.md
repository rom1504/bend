# P114-001: expose repeated compilation and runtime work

Starting point: `6259718`, Phase113 source31. See the
[ambition plan](../../design/phase114/qbe-parity-and-staged-runtime.md).

Hypotheses: repeated full verification contributes materially to large lowering;
opaque common runtime operations contribute materially to the broad generated
program gap. These are separate hypotheses and require separate evidence.

First isolate existing Bend lowering stages without semantic changes. Then test
internal immutable verification reuse with unchanged final QBE and independent
final verification. In parallel, compare exact generated helper/call shapes
against mature/upstream C and select one general runtime fast path.

Refuse attribution from static counts alone. Reject changed outputs, ownership
ordering changes, admitted external verification certificates or narrowing of
full Terms. Small controls and real complete programs precede full acquisition
and broad45. Native qualification remains Phase112 facts until an actual successor
passes. No targets have run for this experiment at design time.
