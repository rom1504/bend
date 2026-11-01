# Maintained profiler dependencies

Repository consolidation changes locations and explicit input binding. It does
not rewrite historical reports or qualify new sampling/runtime behavior.

| Previous dependency | Maintained implementation | Continuity |
| --- | --- | --- |
| Phase68 `sample-analysis-v2.py` | `elf.py` | Four exact functions: command, load segments, virtual-address mapping, coverage summary. Generic analyzer no longer imports the campaign script. |
| Implicit Phase111/113 emitter source list | `owners.py --emitter-source` | Explicit repeated pins; unknown/unbound producer remains unverified. Group/FID attribution rules unchanged. |
| Phase112 control source and freeze paths | `controls/` and `controls/migration.json` | Existing C and expected JSON bytes untouched. Historical path strings are provenance; current source is authenticated by the frozen expected hash. |
| Phase144 concat preparer | `concat_v1.py`, `runtime.py --concat-v1` | Same seven hook/counter definitions; reversible runtime/support extension and zero-column ABI expectation. |

`stages_v1.py`, `stages-build-v1.py`, support C, ABI fixtures, sample formats,
timing units and clean-versus-diagnostic classifications remain unchanged.
Current commands have no phase implementation imports. Historical IDs embedded
in runtime symbols and protocol records remain valid ABI data.

Execution still needs explicit workload/source/runtime/ELF/toolchain assets,
Linux sampling support, and a single outer disk/resource guard. Offline ELF
analysis uses system `readelf`/`nm`/`objdump` as before. Main-thread sampling is the
qualified generic scope; retained all-thread parsing does not promote an
experimental all-thread collector. No new compiler, sampler, runtime ABI or
Lean target was executed by this migration lane.

Run offline controls with:

```sh
taskset -c 0 timeout 60s python3 -B -m unittest discover \
  -s selfhost/tools/profiler -p 'test_*.py'
```

The fixture/helper migration and offline checks are recorded alongside the
[law migration](../laws/migration.json). Restore old phase evidence through the
history index when reproducing an old report; maintained requests do not read it.
