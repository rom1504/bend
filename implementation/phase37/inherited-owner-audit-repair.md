# Phase37 inherited-owner provenance audit successor

The reviewed successor now **passes all seven inherited Phase36 owner groups**
on the selected checked03 compiler. Root's bounded audit completes in
**3.015 seconds**, verifying **678 file identities and 15 pinned Git provenance
blobs**. The original failed closer and its evidence remain unchanged.

Root completed all seven Phase36 owner-control groups against fresh checked03
emissions. The unchanged Phase36 closer then failed during provenance traversal,
before closing a group. The preserved `phase36-owners01/report.json` has
`complete: false`, `pass: false` and an empty `cases` list; the supervisor records
exit one after 0.202 seconds. The individual successful control reports remain
separate from this failed final audit.

The failing identity is the historical Mandelbrot source:

`018751270e800bc222a93dad7f257083ee53a5f7:bench/runtime/mandelbrot/main.bend`.

The old walker treated its Git provenance path as an ordinary file relative to
the catalog directory, producing the nonexistent path
`selfhost/tools/performance/programs/bench/runtime/mandelbrot/main.bend`.
The benchmark source is outside the sparse working tree. Its original bytes
remain available as a pinned local Git blob. This is a path-namespace error in
the provenance audit, not a failed compiler observation or a reason to omit
source verification.

## Narrow successor

[`phase36-owner-close-v2.py`](../../selfhost/tools/performance/phase37/phase36-owner-close-v2.py)
is a new Phase37 derivative of the consumed Phase36 closer. Its
[derivation record](../../selfhost/tools/performance/phase37/phase36-owner-close-v2.derivation.json)
pins both source tools and its own final bytes. The old closer, plans, failed
report and supervisor receipt remain unchanged.

All original semantic and checked-emission assertions are retained: the selected
API/runtime/Base/driver equality, frozen source and purity conditions, actual
checked input/output receipts, seven exact owner groups and counts, emitted
candidate identity, diagnostic parents and scoped-guard acquisition links. The
report kind remains `phase36-final-owner-controls`; `auditVersion: 2` and the
derivation identity distinguish this successor.

The changed traversal uses the already reviewed Phase37 new-owner closer's
explicit identity namespaces:

- Absolute files remain absolute. Repository `selfhost/...` paths resolve from
  the repository root.
- Catalogs, bundles, preparations and the explicit historical-subset preparation
  resolve relative identities from their own directory. Application proposal
  paths resolve from the documented Phase37 catalog directory.
- An identity carrying a commit/path pair is read through bounded local
  `git cat-file blob` at the unchanged pin. SHA256, byte size and Git blob ID
  are checked where present. Replace-object interpretation is disabled.
- Unknown relative namespaces fail. No required provenance identity is skipped.
  Every file and Git blob is rechecked before success; repeat reads cannot replace
  an earlier identity silently.

The derivative also walks its own derivation graph, including the preserved
failed audit and supervisor evidence. Independent read-only review identified
the need to traverse those newly recorded failure links, and that tightening
was applied before any execution. The independent applications reviewer confirmed
that the original 43 assertion expressions remain in the final successor and
that the original `verify`, `identity`, `refs` and `attempt_check` function ASTs
are unchanged. Parent/helper/self/failure hashes and sizes matched the derivation
record. This review was communicated before root's execution; there is no
separate review-file artifact. The reviewed successor hash is recorded below.

Root executed this command under the serial CPU/memory supervisor, using the
same successful control acquisitions and a fresh output:

```sh
python3 selfhost/tools/performance/phase37/phase36-owner-close-v2.py \
  selfhost/build/phase37/checked03 \
  selfhost/build/phase37/historical-subset01/manifest.json \
  selfhost/build/phase37/phase36-owners01/cohorts \
  selfhost/build/phase37/phase36-owners01/mapping.json \
  selfhost/build/phase37/phase36-owner-close02/report.json
```

The [successful audit](../../selfhost/build/phase37/phase36-owner-close02/report.json)
records `complete: true`, `pass: true`, seven named cases and all original exact
counts. The [supervisor receipt](../../selfhost/build/phase37/phase36-owner-close-outer02/run.json)
records exit zero and the exact command. No control or compiler rerun is claimed
by this audit: it closes the existing successful observations after verifying
their semantic and identity bindings. Full inherited conformance, the three new
Phase37 owner groups and installed-release validation retain separate gates.

| Identity | SHA256 |
| --- | --- |
| Unchanged Phase36 parent closer | `450016f3e719792e0668b26526f1f186c8d3d5c271a8edaffd9c1b606223bc4d` |
| Contextual resolver parent, Phase37 new-owner closer v2 | `6595799297f1ad4382594f4439b37f6267fa58b19d7b72d329458e453313c0b4` |
| New inherited-owner closer v2 | `eae14e859aeb94aaf0e719950fd7c94d4971b154ff508b8b2d2ebced7d7e04a8` |
| Derivation record | `2fdaba4c5e0c279aff3f8400f36d95c833c33262a39050d06528122f95044ec8` |
| Preserved failed audit, `phase36-owners01/report.json` | `49ed83c8a1ed1d19e2227806339bdf721e99fcb81a23353fb830b7bc27a0e54a` |
| Preserved failed supervisor, `phase36-owners01/run-close/run.json` | `a377f7cb132c9decffe73a798258c679b287dfa1649aa7bb618d4f45e45e07d6` |
| Successful successor, `phase36-owner-close02/report.json` | `8d271eca8402d8737ea02f6960101205aed5b03494d6cce0123a474fef365dcf` |
| Successful supervisor, `phase36-owner-close-outer02/run.json` | `9dc7a6f20c0d12a1cf15a9d4bd9ca98797cceee8b2116cec88b06eaea735f296` |

Raw paths are under `selfhost/build/phase37` and are restored from the phase
evidence capsule. The coverage agent authored the successor and this report;
it did not execute an auditor, compiler, test, profile or generated program.
