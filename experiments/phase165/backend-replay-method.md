# Phase165 complete backend replay — source-only method

No compiler acquisition is needed for the first screen. The checked
`selfhost/build/phase152/composite-api01/report.json` exports all nine roots in
`tools/prepare-backend.py`; its API is `b5bda080852437823a6d7391c09bef8b467694f388daa5a18627ad480f9e50df`.
The source is the qualified `027e1504…` compiler, not a new override.

From the repository root, prepare one small job:

```sh
python3 -B experiments/phase165/tools/prepare-backend.py --out selfhost/build/phase165/backend-plan-fresh
```

This only authenticates retained files and writes `plan.json`/`jobs.json`.
Root executes the single command in `jobs.json` under its existing serial lane:
90 seconds, 3 GiB RSS, 96 MiB output budget, CPU3. **Override the generated
`--file-mib 32` to `--file-mib 64`: the guard's minimum is 64 MiB.** The original
admission rejection started no target; the successful Map guard records this
CLI override. Method/plan pins remain frozen. Do not
nest it under another guard. The first case is the unchanged 1,817-byte ordinary
IO Map source previously captured in Phase154, **not** the native45 timing wrapper.
Its complete expected stdout is the maintained `.stdout` file, `3714872484\n`.
The runner compares all QBE bytes against the retained same-source/same-Base
native oracle `selfhost/build/phase156/pilot01/oracle-map/program.ssa`
(`eba759e0…`, 1,028,598 bytes). It reports acquisition time as zero.

After that gate, prepare the only second case with:

```sh
python3 -B experiments/phase165/tools/prepare-backend-verifier.py --out selfhost/build/phase165/backend-verifier-fresh
```

This uses the unchanged 37,696-byte
`selfhost/build/phase154/capture-plan05/compiler-workload.bend`; expected output
is `0\n`. Its main checks the empty structured program, which lacks a main
segment and therefore has a nonempty verifier error. This is a complete compiler
slice request, not broad execution coverage of every verifier branch. The
prepared `backend-plan03/jobs.json` uses the corrected 64 MiB guard limit and a
strict retained **historical Phase147** native QBE oracle (2,187,663 bytes,
`3065248d…`) for the same exact source/Base. A mismatch stops this screen and is
inconclusive across compiler generations; no fresh acquisition is planned to
resolve it. The prior Phase154 27,427,112-byte graph contains the request plus
the complete original emission plan; the new request-only capture retains its
enforced 32 MiB limit. The second case has been prepared, not executed by this agent.

The runner prepares/checks source once, captures the **entire six-field**
`NR_Request` with the existing identity-preserving graph transport, then gives
the same live request to original QBE and mature C. It retains `request.graph.json`,
`program.ssa`, `program.c`, full verdict and receipt. Each product is bounded to
16 MiB and the request capture to 32 MiB. Base, runtime and effect bytes are
pinned before/after; only the existing audited Base args/print/now handlers are
accepted. `kf_source` and `nc_foreign_source` perform foreign decisions in Bend.
The C clock includes runtime preparation, foreign processing, emission and file
write; QBE includes planning, complete cursor draining and file write. Source
reading/capture are separate. Fixed QBE-then-C order is a feasibility observation,
not a paired/native speed claim; teardown is absent from regional clocks.

Root's next gates are machine construction and **both** generated programs' exact stdout/stderr
and exit status. `selfhost/tools/build/native.py --target qbe --ir …` accepts the
QBE file. For C, use the pinned `assets-native.json` `clang` asset and C
toolchain (`-std=c11 -O3`, declared include flags, `-lpthread -lm`); `native.py`
accepts QBE only. Execute both with the recorded `--threads 1 --gpu off` and no
source arguments: this original IO fixture has a fixed point, not a timing/count
protocol. No execution or output
equivalence is claimed by the runner's `complete` emission receipt.

If the retained API is unavailable, the exact incremental acquisition is
`experiments/phase163/tools/prepare.py` with nine repeated `--export` arguments
from `plan.requiredExports`, no additive module/override, then the maintained
`selfhost/tools/build/hosted.mjs acquire` over its compiler/exports files and
`selfhost/.bootstrap/upstream-phase66`. That extractor authenticates the same
qualified parent. Do not silently substitute a different image. This fallback
is unnecessary for the retained artifact inspected here.

## Root-executed Map result

[`backend-plan02/replay/report.json`](../../selfhost/build/phase165/backend-plan02/replay/report.json)
records acquisition **0**, Base preparation 7.463s, checked frontend 1.375s,
complete QBE backend/output 8.266s and complete C backend/output 6.548s. The
11,146,917-byte request capture is shared unchanged. All 1,028,598 QBE bytes
match the independent native oracle; C emits 809,678 bytes. This is one hosted,
fixed-order feasibility observation with different output contracts. It does
not establish a native compiler speedup, repeated timing result, or bendc
backend comparison, and it does not attribute the 2.132B residual allocations.

[`backend-machine01/report.json`](../../selfhost/build/phase165/backend-machine01/report.json)
then independently builds both full products and observes exact maintained Map
stdout, empty stderr and exit 0 for both. This qualifies this one original source
point only. Python syntax checks and all data preparation were done here;
compiler/backend/machine executions were root-owned guarded jobs.

The verifier `backend-plan03` screen stopped at its historical QBE gate before
C emission: the Phase152 API produced 2,146,264 bytes (`5e402f91…`), whereas the
Phase147 oracle has 2,187,663 (`3065248d…`). The first native follow-up,
`verifier-oracle01`, selected the asset named `qbe-n2`, whose recorded compiler
source is `96c40c9d…`; it reproduced the older output. This is another compiler
version boundary, not a same-version hosted/native discrepancy. The matching
Phase152 research N2 is explicitly `selfhost/build/phase152/native-n2/program`
(`d6271295…`, source `027e1504…`). Only a complete, exact receipt from that source
generation can authorize a current-oracle second replay. Both failed gates are
retained; neither counts as backend correctness or performance evidence.

Root's `verifier-oracle02` then uses the explicit Phase152 N2 and matches all
2,146,264 hosted QBE bytes (`5e402f91…`). `backend-plan04/jobs.json` binds this
current oracle, the exact source-generation identity, and both prior failures.
It reuses the frozen runner and requests the complete C leg only after the
strict current QBE gate. Preparation used `tools/prepare-backend-current.py`;
it acquired no API or image and ran no backend target. The Map-only machine
adapter remains unchanged; a successful verifier replay still needs its own
exact `0\n` generated-program execution gate.

The later verifier replay and `backend-machine03` pass both complete products
and the independent `0\n` gate. For a bounded counterbalance to C always running
second, `backend-plan05` (Map) and `backend-plan06` (verifier) use the separate
`backend-replay-v2.mjs` with explicit order `['c','qbe']`. Both full C and QBE
must equal the previously machine-checked products; those completed machine
receipts are bound in each plan, so no new machine build is needed if identity
passes. Each fresh job retains the 16 MiB per-product limit, uses a 40 MiB disk
budget, and acquires no API. They skip new graph encoding/writing and retain the
first complete capture. Because this also changes work outside the clocks and
heap/JIT warmup, these are reversed-order diagnostics, not an isolated estimate
of order alone or a native timing claim. Preparation ran no target jobs.
