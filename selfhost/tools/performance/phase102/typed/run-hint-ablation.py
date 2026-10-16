#!/usr/bin/env python3
"""Serial four-product runtime diagnosis; production sources remain unchanged."""
import importlib.util
import json
import statistics
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
spec = importlib.util.spec_from_file_location('native_runtime93', ROOT / 'selfhost/tools/performance/phase93/run.py')
R = importlib.util.module_from_spec(spec); spec.loader.exec_module(R)
out = Path(sys.argv[1]).resolve(); out.mkdir(parents=True, exist_ok=False)
base = ROOT / 'selfhost/build/phase99'
paths = [base / f'phase102-runtime-products{x}/phase98-products.json' for x in ['02', '03']]
datasets = [R.read(p) for p in paths]
assert all(d['complete'] for d in datasets)
plan_path = base / 'phase102-runtime-products03/calibration.json'
plans = R.read(plan_path)['plan']
report = dict(complete=False, method=R.pin(__file__), methodInputs=R.methods(),
              products=[R.pin(p) for p in paths], plans=R.pin(plan_path), rows=[],
              scope='Eight balanced rounds of retained Phase98/02/03 and saved-C hint-only ablation. Complete outputs checked by unchanged Phase93 sample method. No compiler qualification from the ablation.')
def save(): R.save(out / 'report.json', report)
save()
try:
    names = ['raytrace', 'local-fold', 'variation-local-fold-128-0', 'variation-local-fold-8192-123']
    for name in names:
        old, new = [next(c for c in d['cases'] if c['id'] == name) for d in datasets]
        assert old['source'] == new['source'] and old['point'] == new['point']
        index = datasets[1]['cases'].index(new)
        diagnostic_path = ROOT / f'selfhost/build/phase102/restore-hints01/{index:02d}-{name}/report.json'
        diagnostic = R.read(diagnostic_path)
        assert diagnostic['complete'] and diagnostic['inverseExact'] and diagnostic['after'] == new['products']['own']['c']
        for p in [diagnostic['before'], diagnostic['after'], diagnostic['candidate']]: R.verify(p)
        directory = out / name; directory.mkdir()
        command = new['products']['own']['build']['command']
        argv = command[command.index('--') + 1:]
        argv[argv.index(diagnostic['after']['file'])] = diagnostic['candidate']['file']
        binary = directory / 'hint-ablation.program'; argv[argv.index('-o') + 1] = str(binary)
        build = R.guard(directory / 'build', argv)
        products = {'phase98':new['phase98Product'], 'candidate02':old['products']['own'],
                    'candidate03':new['products']['own'],
                    'prior-hints':dict(c=diagnostic['candidate'], binary=R.pin(binary), build=build)}
        row = dict(id=name, diagnostic=R.pin(diagnostic_path), products=products, samples=[])
        report['rows'].append(row); save()
        roles = list(products); p = plans[name]
        for rnd in range(8):
            ordered = roles[rnd % 4:] + roles[:rnd % 4]
            if rnd >= 4: ordered.reverse()
            for role in ordered:
                sample = R.sample(directory / f'{rnd}-{role}', dict(new, products=products), role,
                                  p['repetitions'], p['warmups'])
                sample['round'] = rnd + 1; row['samples'].append(sample); save()
                assert sample['qualified'], 'Preserve short sample and recalibrate separately'
        row['mediansMs'] = {role:statistics.median(s['elapsedMs'] for s in row['samples'] if s['role'] == role) for role in roles}
        row['rangesMs'] = {role:[min(s['elapsedMs'] for s in row['samples'] if s['role']==role), max(s['elapsedMs'] for s in row['samples'] if s['role']==role)] for role in roles}
        row['ratiosToPhase98'] = {role:ms / row['mediansMs']['phase98'] for role,ms in row['mediansMs'].items()}
        print(json.dumps({k:row[k] for k in ['id','mediansMs','ratiosToPhase98','rangesMs']}), flush=True)
    for p in report['products'] + report['methodInputs'] + [report['method'], report['plans']]: R.verify(p)
    report['complete'] = True
except BaseException as error:
    report['error'] = repr(error); raise
finally: save()
