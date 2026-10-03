# Checkpoint 04: native data and sequential traversal

This is a candidate checkpoint, not release admission. Phase41 remains installed.
Exact samples, ranges, control counts and input identities are in
[prototype-summary05.json](prototype-summary05.json). The complete 45-point
runtime comparison and final semantic campaign are still pending.

The checked13 compiler extends the existing closed scalar region to precisely
validated native List/Sigma types and sequential child continuations. Nat.add
keeps its original checked runtime implementation; a private descriptor snapshot
makes that exact native callable eligible for the existing guard. No native
arithmetic implementation or public data layout changes. Fusion also reuses five
already computed call spines instead of recomputing them.

Three balanced short-screen rounds, milliseconds per invocation:

| BST size, seed | Phase42 checked07 | checked13 | Pinned TypeScript | Speedup over checked07 | Candidate / TS |
|---|---:|---:|---:|---:|---:|
| 32, 17 | 3.119337 | 0.209356 | 0.013608 | 14.90× | 15.38× |
| 128, 17 | 42.747350 | 1.488418 | 0.182444 | 28.72× | 8.16× |

The baseline here is checked07, not Phase41. These are actual compiler outputs,
not saved-JavaScript rewrites. All 216 independent BST value oracles and 24 alias
checks pass, together with descriptor/host-boundary and deep traversal controls.
The independent sequential fixture passes its complete controls as well.

An important scope correction: pre-import wrappers around BigInt and Math.imul
expose actual observable differences in both old and new optimized regions.
Those diagnostics are retained as failures of universal host equivalence. They
are outside the **previously published** supported environment: standard
intrinsics at module initialization. This assumption predates Phase42 (commits
44a36083 and 88619d9c; see the review report and performance guide). We have not
broadened that contract to excuse a supported failure. Post-import mutation,
public foreign values and allowed Error reentry still require their controls.
The earlier blanket hold based only on pre-import wrappers is superseded by
this scope assessment. The selective rollback remains available, unapplied.

Two useful failures shortened the loop. checked12 had the Nat.add source change
but the old generated runtime bundle; the activation assertion caught it despite
216 equal values. Regenerating the runtime and producing a fresh checked13
attempt fixed activation. A separate hybrid-recursion prototype failed its
worker selector before timing; that diagnostic is preserved for correction.

Validation planning also found that one full45 preset600 run cannot finish:
669 mandatory one-second process warmups already exceed its global deadline.
The final protocol uses three serial 15-point batches with the same preset and
all 669 samples, followed by exact aggregate closure. No partial run is promoted.
