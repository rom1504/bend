#!/usr/bin/env python3
"""Freeze two disjoint native acquisitions against the retained45 reference."""
import argparse
import copy
import sys
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'))
import bench
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out',type=Path,required=True)
a = p.parse_args()
base_path = ROOT/'selfhost/build/phase152/programs45-acquire01/programs.manifest.json'
base = bench.read(base_path)
catalog = ROOT/'selfhost/tools/bench/catalogs/native45/catalog.json'
inputs = [bench.pin(__file__),bench.pin(base_path),bench.pin(catalog)]
selected = {}
role = None
for name in ['quality-six-native01','quality-remaining-native01']:
    report_path = ROOT/'selfhost/build/phase169'/name/'report.json'
    report = bench.read(report_path)
    assert report['complete'] and not report['changedInputs']
    manifest_pin = report['programManifest']
    bench.verify(manifest_pin)
    manifest = bench.read(manifest_pin['file'])
    assert set(manifest['roles']) == {'candidate'}
    for item in report['inputs']+manifest['inputs']: bench.verify(item)
    if role is None: role = copy.deepcopy(manifest['roles']['candidate'])
    assert manifest['roles']['candidate']['stage'] == 'N2-P169-quality'
    role['inputs'] = bench.unique_inputs(role['inputs']+manifest['roles']['candidate']['inputs'])
    inputs += [bench.pin(report_path),manifest_pin]
    for row in manifest['cases']:
        assert row['id'] not in selected
        selected[row['id']] = row
assert set(selected) == {row['id'] for row in base['cases']} and len(selected) == 45
rows = []
for row in base['cases']:
    candidate = selected[row['id']]
    for key in ['source','point','expectedFile']: assert row[key] == candidate[key]
    rows.append(dict(id=row['id'],products=dict(phase152=row['products']['phase152'],
                                               candidate=candidate['products']['candidate'])))
roles = dict(phase152=copy.deepcopy(base['roles']['phase152']),candidate=role)
for role in roles.values(): role['inputs'] = bench.unique_inputs(role['inputs']+inputs)
out = a.out.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase169')
out.mkdir(parents=True,exist_ok=False)
recipe = dict(kind='programs',cwd=str(ROOT),catalog=str(catalog),reference='phase152',
    roles=roles,cases=rows,scope='Frozen45 corpus, actual native N2 acquisition versus retained Phase152; no fresh upstream comparison.')
bench.save(out/'programs.recipe.json',recipe,fresh=True)
bench.freeze(out/'programs.recipe.json',out/'programs.manifest.json')
bench.save(out/'report.json',dict(complete=True,targetsRun=False,inputs=inputs,
    programManifest=bench.pin(out/'programs.manifest.json'),cases=45),fresh=True)
