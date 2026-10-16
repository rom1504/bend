#!/usr/bin/env python3
"""Guarded saved-C diagnosis of cold TRMC destination publication."""
import importlib.util, json, statistics, sys
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
spec = importlib.util.spec_from_file_location('native_runtime93', ROOT / 'selfhost/tools/performance/phase93/run.py')
R = importlib.util.module_from_spec(spec); spec.loader.exec_module(R)
out = Path(sys.argv[1]).resolve(); out.mkdir(parents=True, exist_ok=False)
source = ROOT / 'selfhost/build/phase102/list-cold-link01/report.json'
diagnostic = R.read(source)
products_path = ROOT / 'selfhost/build/phase99/phase102-runtime-products02/phase98-products.json'
products = R.read(products_path)
plan_path = ROOT / 'selfhost/build/phase99/phase102-runtime-products02/calibration.json'
plans = R.read(plan_path)['plan']
report = dict(complete=False, method=R.pin(__file__), diagnostic=R.pin(source),
              products=R.pin(products_path), plans=R.pin(plan_path), rows=[],
              scope='C-only homogeneous cold-list diagnosis, not compiler qualification')
R.save(out / 'report.json', report)
for name in ['coverage-list-pipeline-512', 'coverage-list-pipeline-128']:
    row = next(x for x in diagnostic['rows'] if x['id'] == name and x['variant'] == 'both')
    case = next(x for x in products['cases'] if x['id'] == name)
    for p in [row['candidate'], row['source'], row['candidateProduct']['binary'], row['baseline']['binary']]: R.verify(p)
    directory = out / name; directory.mkdir()
    command = row['candidateProduct']['build']['command']
    argv = command[command.index('--') + 1:]
    argv[argv.index(row['source']['file'])] = row['candidate']['file']
    binary = directory / 'diagnostic.program'; argv[argv.index('-o') + 1] = str(binary)
    build = R.guard(directory / 'build', argv)
    candidate = dict(c=row['candidate'], binary=R.pin(binary), build=build)
    record = dict(id=name, product=candidate, samples=[]); report['rows'].append(record)
    p = plans[name]
    for round_number in range(6):
        roles = ['phase98', 'candidate02', 'cold-link']
        if round_number % 2: roles.reverse()
        for role in roles:
            product = {'phase98':row['baseline'], 'candidate02':row['candidateProduct'], 'cold-link':candidate}[role]
            current = dict(case, products={role:product})
            sample = R.sample(directory / f'{round_number}-{role}', current, role, p['repetitions'], p['warmups'])
            assert sample['qualified']
            sample['round'] = round_number + 1; record['samples'].append(sample)
            R.save(out / 'report.json', report)
    record['mediansMs'] = {role:statistics.median(x['elapsedMs'] for x in record['samples'] if x['role'] == role) for role in roles}
    record['ratiosToPhase98'] = {role:value / record['mediansMs']['phase98'] for role,value in record['mediansMs'].items()}
    print(json.dumps({k:v for k,v in record.items() if k in ['id','mediansMs','ratiosToPhase98']}), flush=True)
for p in [report['method'], report['diagnostic'], report['products'], report['plans']]: R.verify(p)
report['complete'] = True; R.save(out / 'report.json', report)
