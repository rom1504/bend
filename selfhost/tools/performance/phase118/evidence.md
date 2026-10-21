# Phase118 offline evidence replay and capsule

`evidence.py` launches no compiler, benchmark, target program, shell, or build.
It authenticates existing local files and recomputes the selected hosted result.
Defaults deliberately select `broad-screen01`, `broad-emit01`,
`all-controls-run01`, `all-controls-emit01`, and `all-controls03.json`; alternate
receipts must be supplied explicitly. Every output directory must be fresh.

```sh
python3 -B selfhost/tools/performance/phase118/evidence.py \
  --out selfhost/build/phase118/evidence-final01 \
  --native-plan selfhost/build/phase118/native-float01-plan.json
```

The verifier requires all 45 original cases, exactly three rounds for candidate,
same-run Phase117 baseline, and original upstream: 405 observations. It compares
raw stdout to the retained Phase112 independent full-output oracle plus exact
warmup/repetition counts, validates the elapsed suffix against the original
`observation` routine and wall clock, checks the frozen 50ms workload profile,
and recomputes every median and ratio. It excludes only the original zero-work
sentinel, leaving 44 geometric-mean ratios, and compares the recomputation with
`broad-summary01.json`. Binary/source/QBE/runtime/toolchain/build-command pins
are checked. The selected full-source composition is replayed from the frozen
parent and module snapshots; the actual checked API and request-bound entry are
authenticated using the Phase118 contract, not the old staged renderer contract.

For the 19 ordinary controls it checks complete raw stdout/stderr and recorded
exit status against 17 source `#|` literal oracles and two retained Phase102 flat
description oracles. The historical `arrays-io` oracle's `exitCode` schema is
normalized to `status` only after its exact original bytes are authenticated.
The first offline replay rejected that schema distinction; its failure receipt
is retained. This was a replay-tool correction, not a target/control failure.

The timing runner does not record individual exit codes in its rows. Its pinned
method checks return code zero before storing each row; the replay independently
checks raw output/count/time bytes but cannot recover a missing exit-status
observation. Ordinary-control receipts do record their status. Neither source
checking nor these finite observations is a proof of arbitrary ownership behavior.

The initial successful replay (`evidence-replay02`) reproduced 405/19, 44 timed
cases, **3.00892612027716× upstream**, and **1.4345687959277815× faster than the
same-run Phase117 baseline**. These are hosted-emitted program timings. Native
qualification was still pending, and no capsule was sealed by this replay.

After root confirms that target jobs and final documentation are stable, rerun
with a fresh directory and `--capsule`. The script refuses capsule creation while
the supplied native plan has pending/incomplete receipts. Native status remains
a separately labeled receipt inventory; this tool does not relabel hosted
observations as native-produced or independently replay the native semantic suites.

The capsule is a gzip tar with a path-to-SHA256 manifest and one blob per unique
content hash. It includes Phase118 source/methods, source-module snapshots,
reports, raw small observations, guards, and rejected/incomplete attempts;
matching `p118-*` Phase111/113 acquisition/build receipts are included. The
selected compiler, checked API, and exact parent source are included. Large
generated QBE/assembly, objects, executables, and other compiler/API snapshots
stay local; their recorded pins and explicit omission reasons remain. No
unrelated phase directory is swept. Original fixture/oracle/method dependencies
needed by the replay are included when small. Previous capsules/inventories are
not recursively archived.

Unique raw payload is bounded at 64 MiB and compressed output defaults to a
16 MiB ceiling. Every archived blob is read back and hashed. To restore an
included path, copy its manifest `blob` to its repository-relative `file`,
verifying size/SHA256 first; archive membership conveys no qualification. Full
local replay still requires omitted machine/toolchain dependencies. Raw result
oracles and observations are retained in the capsule for independent inspection.
No binaries are executed during collection. Root owns final sealing, staging,
and commits; pinned native tools/modules remain unchanged.
