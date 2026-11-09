# Phase185 — QBE and assembly generated-program performance

[Design](../../design/phase185/README.md) · [Profiles](profile-findings.md) ·
[Remaining work](remaining-runtime-opportunities.md) · [Experiment progress](progress.md)

Work began at06:07:54UTC on2026-11-09 from1d8b56e. The primary reference is our
C backend executing identical Bend programs. Handwritten C and upstream C are
separate comparisons; ratios below must not be relabelled as those references.

## Current integration checkpoint

The maintained compiler now contains shared Boolean result facts, canonical
Boolean operations, packed single-field projection, cold-constructor allocation
and verified continuation-frame expansion. A checked descriptor fact can remove
the repeated cold-allocation descriptor guard; raw/unpaired IDs retain it.

Assembly now reuses admitted array and late native expansions, preserves
entry-only setup across loop backedges, removes stable copies and dead pure
assignments, forwards known local stack cells, places confined temporary values
in caller-saved registers, emits direct register destinations/immediates, and
uses native scalar F32 instructions for admitted binary arithmetic/comparisons.
Calls, aliasing and unknown boundaries retain conservative behavior. No backend
switch, runtime replacement, benchmark-name recognizer or final-verifier change
was introduced.

## Measurements so far

The first integrated full45 campaign completes all45 correctness points and44
timed points with four rotated rounds. QBE/C geometric runtime decreases from
1.55570 to1.49599 (3.84% less runtime); assembly/C is5.98203. These are the
first integrated candidate, before the final descriptor and assembly refinements.
The ray family is0.98989×C; tree3.05786×C and BST2.89845×C still have large gaps.

The final bounded assembly screen compares actual retained products in four
rotated rounds: local-pair13225→2598.96µs (5.09×), local-fold249.75→39.34µs
(6.35×), scalar-region1533.54→345µs (4.45×), generic-row586.90→437.06µs
(1.34×). These four timed cases are diagnostic, not a full45 speedup claim.

The final QBE four-case screen observes tree559.28→483.56µs, map892.86→804.95µs,
ray36000→32250µs and BST25.30→19.95µs. Three rotated rounds and exact complete
output/count checks pass. The differing absolute clocks across campaigns are
why within-campaign paired ratios, rather than cross-campaign absolute values,
are the performance evidence.

## Correctness and selection

Independent upstream source checks accept both current maintained QBE and x86
profiles. The checked hosted API passes finite machine oracles for full-word
Boolean semantics, scalar facts, immediate selection, copies, setup/backedges,
public returns, packed payloads, cold constructors, transient register lifetimes,
dead assignments, continuation frames, F32 edge cases, stack-cell aliases,
register arithmetic and descriptor facts. The new register oracle alone covers
3267 invocations/26136 exact result words. These are finite observations and
structural admission checks, not BendTT proofs.

Eight ordinary source/runtime checks and the first integrated90 benchmark
products pass. Final refinements also pass all12 pilot product outputs. Full
native acquisition/reproduction/qualification is in progress at this commit;
no installed image or release selector has changed. Later report revisions will
record the actual qualification outcome rather than infer it from B1 success.

Final candidate source identities: QBE076aa368ae888d02abb1e83f7e89a6c39a11c9baf2f00a970f19f5c336a77214
(3202029bytes); x86374255ac57f28dd93e4714e75093956aa8c938c905e3e771d9c85aae455bae5d
(1525646bytes). Complete sources are retained under
`selfhost/build/phase185/release-source03/`.

## Evidence and reproducibility

Root-owned serial CPU3 lane; sequential runtime, GPUoff; pinned current runtime,
assembler, linker and QBE; 5GiB disk reserve. Adaptive batches target250ms and
require100ms minimum, with full output and success-count verification. Profiling
samples are diagnostics, separate from clean timing; no unsupported hardware
counter or quota measurement is claimed.

Primary roots: `baseline-profile01`, `array-profile02`, `full45-runtime01`,
`register-controls01`, `register-x86-runtime01`, `register-qbe-runtime01`,
`source-qbe-check01`, `source-x86-check01`. All are under
`selfhost/build/phase185/`. Portable evidence and the final qualification
receipts will accompany the closing report. Early negative screens remain in
[evidence/early-screens.json.gz](evidence/early-screens.json.gz).

Preserved negatives include slower array-only assembly, mixed cold-constructor
profitability, rejected unconditional scalar-fact reuse across public Returns,
fixture grammar/oracle mistakes, and a180s full45 emission deadline. The latter
completed44 verified products; an authenticated supplemental final case and
metadata-only merge recovered those products without redoing successful work.
