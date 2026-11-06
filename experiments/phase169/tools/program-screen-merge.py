#!/usr/bin/env python3
"""Metadata only: authenticate the fixed six-family screen, merge, then freeze."""
import argparse
import copy
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/bench'))
import bench


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--acquisition', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    selection_path = ROOT / 'experiments/phase169/program-screen-selection.json'
    selection = bench.read(selection_path)
    names = selection['cases']
    for key in ('baselineManifest', 'baselineAcquisition', 'candidateImage',
                'candidateImageReceipt', 'catalog', 'acquisitionRecipe'):
        bench.verify(selection[key])
    for pin in selection['baselineSelectedInputs']:
        bench.verify(pin)
    baseline = bench.read(selection['baselineManifest']['file'])
    baseline_report = bench.read(selection['baselineAcquisition']['file'])
    bench.require(baseline_report['complete'] and not baseline_report['changedInputs'],
                  'Original baseline acquisition was incomplete')
    candidate_path = args.acquisition.resolve(strict=True)
    report = bench.read(candidate_path)
    bench.require(report['complete'] and not report['changedInputs'] and report['selected'] == names,
                  'Candidate acquisition incomplete or selection changed')
    expected_recipe = bench.read(selection['acquisitionRecipe']['file'])
    bench.require(report['roles'] == expected_recipe['roles'], 'Candidate role/image treatment changed')
    for pin in report['inputs']:
        bench.verify(pin)
    bench.require(selection['acquisitionRecipe'] in report['inputs'], 'Acquisition recipe was not consumed')
    bench.verify(report['programManifest'])
    candidate = bench.read(report['programManifest']['file'])
    for pin in candidate['inputs']:
        bench.verify(pin)
    bench.require(set(candidate['roles']) == {'candidate'}, 'Acquisition must build only candidate')
    baseline_rows = {row['id']: row for row in baseline['cases']}
    candidate_rows = {row['id']: row for row in candidate['cases']}
    bench.require(list(candidate_rows) == names, 'Candidate manifest selection changed')
    provenance = [bench.pin(selection_path), bench.pin(__file__),
                  selection['baselineManifest'], selection['baselineAcquisition'],
                  bench.pin(candidate_path), report['programManifest']]
    roles = {'phase152': copy.deepcopy(baseline['roles']['phase152']),
             'candidate': copy.deepcopy(candidate['roles']['candidate'])}
    for role in roles.values():
        role['inputs'] = bench.unique_inputs([*role['inputs'], *provenance])
    rows = []
    for name in names:
        old, new = baseline_rows[name], candidate_rows[name]
        for key in ('source', 'point', 'expectedFile'):
            bench.require(old[key] == new[key], 'Wrapper/oracle/work amount changed: ' + name)
        rows.append(dict(id=name, products={'phase152': old['products']['phase152'],
                                           'candidate': new['products']['candidate']}))
    recipe = dict(kind='programs', cwd=str(ROOT), catalog=selection['catalog']['file'],
                  reference='phase152', roles=roles, cases=rows, scope=selection['scope'])
    out = args.out.resolve()
    bench.require(out.is_relative_to(ROOT / 'selfhost/build/phase169'), 'Use a Phase169 build root')
    out.mkdir(parents=True, exist_ok=False)
    bench.save(out / 'programs.recipe.json', recipe, fresh=True)
    manifest = bench.freeze(out / 'programs.recipe.json', out / 'programs.manifest.json')
    bench.save(out / 'report.json', dict(kind='phase169-six-family-merge', complete=True,
        targetsRun=False, cases=names, inputs=provenance,
        programManifest=bench.pin(out / 'programs.manifest.json'),
        scope=selection['scope']), fresh=True)
    print(json.dumps(dict(complete=True, targetsRun=False, cases=len(manifest['cases']),
                         manifest=str(out / 'programs.manifest.json'))))


if __name__ == '__main__':
    main()
