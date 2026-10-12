# Phase71 bounded diagnosis methods

One agent, no production changes. See the [report](../../../../implementation/phase71/README.md).
All raw paths are under `selfhost/build/phase71`; older phases stay immutable.
Run targets serially. `run.py` and the acquisition/measurement scripts reuse the
existing2GiBRSS/4GiBavailable guard; Node emission needs the known sandbox
exception. CPU affinity for scaling is explicit and recorded.

`prepare.py` creates the Array.map virtual-product C and patch by exact source
and replacement checks. `prepare-v1.py` retains the rejected extractor. The
initial source/recipe and all corrected successors are retained in raw.
`acquire.py` is the original failed fixture acquisition; `acquire-parallel-v*.py`
retain diagnostic predecessors. Final `acquire-parallel.py` binds recipe-v3,
source `balanced.bend` and output `acquire05`. Both roles use the same Clang flags.
`emit.mjs` derives from frozen Phase70 emission; only error rendering changes.

Final measurement commands (choose fresh output names on replay):

```sh
python3 -B selfhost/tools/performance/phase71/measure.py product --out product-replay
python3 -B selfhost/tools/performance/phase71/measure.py parallel --out parallel-replay
```

Restore saved raw inputs or prepare fresh acquisition paths before replay.
`measure.py` refuses existing output directories, rotates roles, checks independent
outputs and records whole-child CPU/process time alongside the proper clock.
`product01` and `parallel02` are qualified; `parallel01` is short calibration only.
`measure-v1.py` preserves that predecessor's oracle/artifact bindings.

`evidence01/evidence.zip` stores raw/method files, except private `usage-*` files and the
archive's own output directory. `evidence01/manifest.json` pins every archived file;
`evidence01/verification.json` records successful member-by-member rehash verification.
Restore in a scratch directory; executable modes are also recorded in ZIP metadata.
Recipes pin external installed/compiler/runtime/Clang inputs. Absolute paths
need adaptation in fresh replay plans. The archive is evidence, not a hermetic
build environment. No new compiler speed or full conformance claim follows.
