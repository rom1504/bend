# Phase113 interim03 evidence snapshot

Collected at 2026-10-20 19:37:38 UTC by [collect.py](collect.py): 51 byte-exact
copies totaling 1,462,953 bytes. [index.json](index.json) maps every copy to its
original path, size, SHA256 and observed mtime. Copies were checked against the
read bytes; source metadata stayed stable while reading. No compiler or native
target ran, and no original artifact was modified.

The explicit collector limits each file to 512 KiB and the capsule to 6 MiB.
Every selected file fits, so this snapshot has no hash-only selected entries.
The collector refuses to overwrite an existing capsule. It preserves completed
source16–19 diagnostics plus source-check-only API20/21 snapshots. Native or
runtime qualification of sources 20/21 is not asserted; source21 excludes heap hoisting.

Useful entry points:

- [Range controls](files/039-report.json): 78 groups, 483 observations.
- [Source19 runtime screen](files/050-phase113-report.json): one-round
  `diagnostic1`, no qualified aggregate. Raw logs are summarized by the separately
  copied inherited report; individual run output files stay in the build tree.
- [Exact ray delta](files/003-ray16-static-delta.json): 111 Succ replacements
  across 12 functions; whole-program equality after those replacements.
- [Wide18 audit](files/042-report.json), [before](files/043-before.txt) and
  [after](files/044-after.txt): actual node, stack and surviving-call evidence.
- Failed field/array fixture [attempt01](files/037-report.json) and
  [attempt02](files/038-report.json), followed by the completed
  [attempt03 batch](files/036-report.json). Failures remain failures.
- [API20](files/021-report.json), [API21](files/022-report.json) and
  [source21 composition](files/009-composition21.json): source checks and the
  explicit `heap:false` boundary, not execution qualification.

This is a bounded evidence copy, not a transitive rebuild archive. Full compiler
sources, APIs, SSA, runtime objects, executables and referenced subordinate logs
remain at their original pinned paths. The exact ray inputs are hash-bound in
its copied witness, but their complete SSA payloads are not copied here. Do not
delete originals on the strength of this capsule. Earlier outcomes remain in
the [interim02 index](../evidence/interim02/index.json); later runs need a fresh
snapshot. The main Phase113 report was not rewritten by this audit.
