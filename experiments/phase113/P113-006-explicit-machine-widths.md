# P113-006: explicit machine widths at Boolean and arithmetic boundaries

Updated 2026-10-20: sources30/31 check, all 80 ordinary jobs pass, and the
three-round development comparison passes all 90 complete-output observations.
This includes the original workload that rejected branch24. Full source31 native
acquisition later hits the 600 s lowering limit, so no native generation is
qualified. See the [phase report](../../implementation/phase113/README.md).

## Observed sequence

Source19's operation-derived ranges removed impossible high-tag tests, but
Boolean-exhaustiveness branches remained. Branch24 added mandatory-one and
versioned branch facts, reducing that control code. Its
[ordinary screen](../../selfhost/build/phase112/p113-branch-screen24/report.json)
then failed the local-pair complete-output check. Eight successful samples before
the failure do not qualify the candidate or its timings.

The pinned [QBE `phicopyref`](../../selfhost/build/phase108/toolchain/qbe-1.3/copy.c)
dominating-condition case can replace a 1/0 phi with the branch predicate
without checking the phi's result class against that predicate's width.
[The GVN consumer](../../selfhost/build/phase108/toolchain/qbe-1.3/gvn.c)
substitutes the returned reference. Source and
[ordinary failing-worker assembly](../../selfhost/build/phase111/p113-branch24-local-pair-build/program.s)
inspection found inconsistent Boolean production/consumption
widths. This supports making the boundary explicit; it is not a claim that a
custom minimal demonstration succeeded. Those attempts were aborted or
inconclusive and are not acceptance evidence.

## Narrow correction in Bend

The [Bool renderer](../../selfhost/tools/performance/phase113/bool-width/model.bend)
recognizes only two single-assignment arms targeting the same U64 local with
1/0 or 0/1. It emits a normalized U32 comparison with zero, then `extuw` into
the original U64 destination. Arbitrary nonzero branch conditions therefore
remain true. Both scalar and direct branches use this rule; other branches,
effects, error paths and labels retain the old rendering. Fresh temporaries and
counter exhaustion have explicit guards.

The separate [arithmetic-width renderer](../../selfhost/tools/performance/phase113/width/README.md)
handles adjacent same-destination ring operations followed by a low32 mask, or
a standalone low32 mask. It emits a word operation plus explicit zero extension.
It does not narrow shifts, division, signed operations or comparisons. The
verified IR, full-Term ABI and original QBE compiler remain unchanged. These
are Bend emitter modules, not a QBE/toolchain patch.

Source30 uses the normal 192-node/512-growth inlining policy. Source31 is the
parallel 384-node/1,024-growth variant; both have the Boolean-width correction.
Do not attribute a difference between them to the correction alone.

## Gates and falsification

Both [API30](../../selfhost/build/phase111/p113-width-api30/report.json) and
[API31](../../selfhost/build/phase111/p113-wide-api31/report.json) are checked.
[Bool controls](../../selfhost/build/phase113/bool-width-controls01/report.json)
record 112 passes; [arithmetic controls](../../selfhost/build/phase113/width-native30/report.json)
record 22 structural checks and 128 independent native observations. These do
not replace the [80-job ordinary campaign](../../selfhost/build/phase113/width-wide30-31-native/report.json),
which subsequently completed successfully.

The authoritative first correction gate is the unchanged complete local-pair
source, workload and expected output that rejected branch24. Require all other
frozen native controls and workload outputs as well. Reject on any changed
full-U64 result, high-bit loss, alias error, non-Boolean truth normalization,
reordered effect or failed fallback. A small arithmetic witness can miss a
workload-specific machine-code problem, so no minimal test substitutes for that
ordinary gate. Only then compare runtime, and subsequently qualify the broad
corpus and native compiler generations. No target was executed by this record's
author.
