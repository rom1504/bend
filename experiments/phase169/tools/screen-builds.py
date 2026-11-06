#!/usr/bin/env python3
"""Freeze existing checked hosted pilot products against retained native45 products.

No compiler or generated program runs here. The maintained runner supplies all
complete value/count checks and balanced timing; failed rows cannot form a ratio.
"""
import argparse
import copy
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/bench'))
import bench

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--build', action='append', required=True, help='CASE:one-build/report.json')
p.add_argument('--variant', required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert a.variant != 'phase152'
baseline_path = ROOT / 'selfhost/build/phase152/programs45-acquire01/programs.manifest.json'
baseline = bench.read(baseline_path)
catalog = ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json'
by_name = {row['id']:row for row in baseline['cases']}
rows, identities = [], [bench.pin(Path(__file__)), bench.pin(baseline_path), bench.pin(catalog)]
for spec in a.build:
    name, value = spec.split(':', 1)
    assert name in by_name and name not in [row['id'] for row in rows]
    path = Path(value).resolve(strict=True)
    built = bench.read(path)
    assert built['complete'] and built['role'] == 'stream'
    assert built['preparationPolicy'] == 'cache'
    original = by_name[name]
    assert original['source'] in built['inputs'], 'Different source workload'
    emitted_path, machine_path = path.parent/'emit/report.json', path.parent/'machine/report.json'
    emitted, machine = bench.read(emitted_path), bench.read(machine_path)
    assert emitted['complete'] and machine['complete']
    assert built['binary'] == machine['binary']
    assert built['ir'] == emitted['ir'] == machine['sourceIR']
    assert machine['runtime']['sha256'] == '2d07832382a11d7e993124ecc70452e4e1a3b7f753cf429343e1183cd8e493a3'
    inputs = bench.unique_inputs([*built['inputs'], *emitted['inputs'], *machine['inputs'],
        bench.pin(path), bench.pin(emitted_path), bench.pin(machine_path)])
    for item in inputs:
        bench.verify(item)
    product = dict(artifact=built['binary'], generatedSource=built['ir'], inputs=inputs)
    rows.append(dict(id=name, products={'phase152':original['products']['phase152'], a.variant:product}))
    identities.append(bench.pin(path))
roles = {'phase152':copy.deepcopy(baseline['roles']['phase152']), a.variant:dict(
    host='js', stage='B1', target='qbe', policy='ordinary-serial', emitter='selfhost',
    preparation='cache', status='phase169-checked-pilot-no-native-promotion', inputs=identities)}
roles['phase152']['inputs'] = bench.unique_inputs([*roles['phase152']['inputs'], *identities])
recipe = dict(kind='programs', cwd=str(ROOT), catalog=str(catalog), reference='phase152',
    roles=roles, cases=rows, scope='Frozen native45 points; hosted candidate acquisition, native runtime timing. Selected pilot, not full45 or upstream parity.')
out = a.out.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase169')
out.mkdir(parents=True, exist_ok=False)
bench.save(out/'programs.recipe.json', recipe, fresh=True)
manifest = bench.freeze(out/'programs.recipe.json', out/'programs.manifest.json')
bench.save(out/'report.json', dict(complete=True, targetsRun=False, inputs=identities,
    cases=[row['id'] for row in rows], programManifest=bench.pin(out/'programs.manifest.json')), fresh=True)
print({'cases':len(rows), 'manifest':str(out/'programs.manifest.json')})
