# Final31 receipts and compiler-request screen

Do not execute collection until root confirms the selected profile and all final
reports have stopped changing. Interim capsules preserve earlier evidence; this
last capsule adds exact current JSON bytes and external product hashes. It is
not a source/API/ELF archive.

The final checklist is:

- Actual Phase113 guard `process.json`, `inputs.json`, and `method.json` files,
  including failed attempts; these establish charged wall time and limits.
- Checked API30/API31 reports, both source manifests/recipes and composition
  admissions30/31, preserving the selection alternatives.
- `width-wide30-31-check` and `width-wide30-31-native` run/plan receipts, original
  control and six-case acquisition/build/observation receipts, final six-case
  timing and producer-audit/binding reports.
- Selected `native-final31-plan.json`, native hosted/N1/self/N2/focused/full45
  reports and exact-QBE receipt (automatically collected by the existing tool).
- `native-final31-batch45-plan.json`, its actual acquisition/build, binding,
  three-round timing, guard and serial-job receipts. Keep45 output qualification
  separate from44 runtime ratios and from conformance45.
- The final transport manifest/report/guard, selected profile/selection receipt,
  and prior interim03 index/archive pins when root has finalized those paths.

The following **root-only, post-selection** snippet selects concrete existing
guard/API/admission/current-run receipts plus the final plan's output trees.
Add the finalized selection/interim03 paths to `extra` before executing it. No
target is launched, but it must wait until final reports are immutable.

```python
import json, pathlib, subprocess, sys
root = pathlib.Path('/home/ai/bend2/build/publish/bend')
p113 = root/'selfhost/build/phase113'
p111 = root/'selfhost/build/phase111'
p112 = root/'selfhost/build/phase112'
out = p113/'final31-evidence'
extra = []
for pattern in ['*-guard/process.json', '*-guard/inputs.json', '*-guard/method.json']:
    extra.extend(p113.glob(pattern))
for rel in ['native-final31-batch45-plan.json',
            'array-composition-admission30/manifest.json',
            'array-composition-admission31/manifest.json',
            'width-source30/manifest.json', 'width-source30/recipe.json',
            'wide-source31/manifest.json', 'wide-source31/recipe.json']:
    extra.append(p113/rel)
extra += [p111/'p113-width-api30/report.json', p111/'p113-wide-api31/report.json']
trees = [p113/'width-wide30-31-check', p113/'width-wide30-31-native']
for pattern in ['p113-width30-*/report.json', 'p113-wide31-*/report.json',
                'p113-final31-original-*/report.json',
                'p113-final31-native-batch45-*/report.json',
                'p113-final31-native-batch45-*/build/report.json']:
    extra.extend(p111.glob(pattern))
batch = json.loads((p113/'native-final31-batch45-plan.json').read_text())
for name in ['acquisition', 'timing', 'jobs', 'guard']:
    trees.append(pathlib.Path(batch['artifacts'][name]))
extra.append(pathlib.Path(batch['artifacts']['binding']))
# Add exact final six-case timing/audit/binding, transport and selection files.
# Append an interim03 index/manifest here; do not copy its older receipt trees.
cmd = [sys.executable, '-B', str(root/'selfhost/tools/performance/phase113/bench/collect-native-evidence.py'),
       '--plan', str(p113/'native-final31-plan.json'), '--out', str(out),
       '--max-json-mib', '2', '--max-total-mib', '16']
for path in sorted(set(extra)):
    assert path.is_file(), path
    cmd += ['--extra-json', str(path)]
for path in sorted(set(trees)):
    assert path.is_dir(), path
    cmd += ['--extra-tree', str(path)]
subprocess.run(cmd, check=True)
manifest = json.loads((out/'manifest.json').read_text())
assert manifest['complete'], 'Missing/oversize receipts: preserve attempt and review'
assert manifest['qualificationPassed'], 'Native qualification has not passed'
size = (out/'manifest.json').stat().st_size + (out/'receipts.tar.gz').stat().st_size
assert size < 3*1024**2, 'Do not publish oversized capsule; narrow explicit extras'
print('Receipt capsule bytes:', size)
```

Do not count a missing or changed external dependency as copied evidence. The
collector records it separately. The final manifest plus compressed exact JSON
archive must total less than3MiB before copying to the report directory. The
16MiB ceiling limits raw JSON input; repeated pins compress in the archive and
the manifest deduplicates external hash references. No arbitrary generated
products or verbose tool stdout are copied.

## Three-source N1/N2 compiler requests

After N1/N2 acquisition and the exact-QBE gate complete, prepare an ordinary
transport manifest without running a target:

```sh
python3 -B selfhost/tools/performance/phase113/bench/prepare-native-transport.py \
  --qualification-plan selfhost/build/phase113/native-final31-plan.json \
  --out selfhost/build/phase113/native-final31-transport-manifest.json \
  --tag p113-final31-transport01
```

Execute its printed `rootGuardCommand` only on root's serial lane. It invokes the
unchanged Phase112 transport runner for cache mode, three rotated rounds, three
existing one-shot sources (lexer, closures256, map-churn128), and three roles.
Legacy `phase111` means selected Phase113 N1; `phase112` means selected Phase113
N2. Source/runtime/build lineage is explicit. The 90-second guard is a hard
ceiling; historical transport04 completed27 observations in54.7seconds.

Five clocks are recorded: compiler request, machine build, their child-time sum,
harness time until executable readiness, and one-shot execution for correctness.
The last is not a program-speed benchmark. Native output is QBE, upstream output
is C; ready-executable costs use the normal cached runtime for QBE and full
Clang-O2 compilation upstream. Cache mode discloses native prepared Base versus
upstream source Base. No timing method, old manifest, oracle or source changes.
