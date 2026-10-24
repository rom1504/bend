# Phase137 reproducibility

All compiler transformations are checked Bend. Host tools only compose exact
source declarations, execute existing compiler APIs, build machine objects and
record evidence. One coordinator owns CPU3 target execution; independent checker
acquisition uses the existing CPU6 guard serially with that lane.

Start with the [design](../../../../design/phase137/README.md) and
[experiment](../../../../experiments/phase137/P137-001-borrowed-query-boundaries.md).

- `wide/prepare-v01.py` rebases exactly four width bounds on qualified Phase134.
- `queries/prepare-v01.py` extracts actual current queries and independent controls.
  `prepare-v02.py` preserves a negative source-only refinement separately.
- `queries/prepare-retain-v02.py` adds the conservative early-inline policy and20
  controls. `prepare-integration-v01.py` composes actual compiler source03.
- `loop/emit-v01.mjs` uses the selected ordinary checked compiler path. It is not
  the older alternate Phase118 emitter.
- `loop/build-v01.py` reuses the aligned QBE builder and independent stdout.
- `loop/timing-manifest-v01.py` and `extend-manifest-v01.py` feed the existing
  general profiler; they do not add a new benchmark engine.
- `audit/` independently reviews exact source changes, call reachability and
  machine code. `native/` binds existing qualification and timing gates.

The frozen final small comparison is
`selfhost/build/phase137/query-timing03/report.json`; its manifest and all raw
rounds are archived in
[`evidence01`](../../../../implementation/phase137/evidence01/receipt.json).
That capsule preserves source/API/QBE/report bytes; large native ELF/objects stay
at their recorded local paths, with construction recipes and exact hashes. Older
qualified toolchain/runtime artifacts retain their previous phase provenance.

Use fresh output paths. Ordinary jobs use2–3GiB RSS and16GiB available-memory
limits, full image acquisition4GiB. Preserve every rejected variant and verify
that the actual timed caller reaches a borrowed reader before claiming benefit.

The qualified compiler is unchanged until independent native reproduction and
semantic gates pass. See [native commands](../../../../implementation/phase137/native-plan.md).
