# P4-020 — full-source validation of the final private compiler

Status: complete; exact emission passes, small profile gain with visible drift. This record was created after the corrected control finished
and after the candidate launched; it is not a preregistration of those runs.

Question: do the private call transformation and combined Boolean/stability
profile preserve a complete checked compiler emission, and does the profile
reduce full-request wall time under the same limits?

The source and public H are the completed [Phase 4 fixed point](../../implementation/phase4/final-source.md).
The earlier `F is not defined` failure and correction are retained in
[P4-016](P4-016-private-lexical-scope.md). A completed error observation is not a
successful compile or a usable performance sample.

Control image: `61e7d94c19bbda2de2a55037d5e2b992868a145ab6f29d557f4bc0885e759cb1`.
Candidate image: `4318bbcdb2040ad794387b1466b0bafbe12233e67983224c5a564d13fa5753a3`.
Both consume source `34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122`
and must emit actual bytes equal to H `b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`.

The permanent `private-full-source.py` wrapper invokes the canonical private CLI
in one fresh process, pinned to CPU2. Node v24.18.0 uses a 4 MiB stack and 12 GiB
worker heap, with a one-hour request deadline. Python records outer wall and
waited-descendant CPU/peak RSS; the CLI separately records request and launch
wall. Input identities are checked before and after. Source/Base/image identities
remain frozen; OS caches are not flushed. Other physical cores are active.

The corrected control completed at 17:46:41 UTC: 780.022 seconds outer wall,
778.536 seconds request, 4,333,668 KiB peak RSS, exact H bytes. The candidate
started at 17:52:01 UTC. A successful pair warrants an opposite-order pair if
the remaining window permits, to expose run-order/control drift. Require every
attempt, exact output and resource observation in the final evidence; no
successful-only filtering. Keep these full-image measurements separate from the
public-H fixed point and pinned TypeScript runs with different launch histories.

The final-image full frontend sweep and small TypeScript comparison are separate
gates. The ordinary B1 development loop remains the recommendation. No result
here changes the public runtime or proves complete language conformance.

## Completed decision — 18:39 UTC

All four actual outputs equal the proven H. Outer wall in planned order is
780.022 / 749.523 / 824.998 / 831.247 seconds (control/profile/profile/control).
The profile improves the pairs by 3.91% and 0.75%; two-sample mean/median wall
improves 805.634→787.260 seconds (2.28%), while mean maximum-child RSS rises
3.16%. Preserve the approximately 10% candidate drift and 6.6% control drift;
these observations do not support a tightly bounded speed estimate.

The [complete report](../../implementation/phase4/private-full-source.md) links
all four audited observations, actual cache payloads, exact output and tool
identities. CPU2 affinity held, but other cores were active and a short unpinned
C inspection overlapped candidate B. No valid observation was dropped. The
full-source correctness gate passes; profile promotion additionally requires the
separate frontend audit and reproduction through the canonical package.
