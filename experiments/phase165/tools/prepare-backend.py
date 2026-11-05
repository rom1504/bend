#!/usr/bin/env python3
"""Source/data preparation only; print a guarded replay job, run no compiler."""
import argparse, json, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, require, write_json, fresh_output

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--case', choices=['coverage-map-churn-128', 'compiler-verifier-slice'], default='coverage-map-churn-128')
a = p.parse_args()
api_path = ROOT / 'selfhost/build/phase152/composite-api01/report.json'
capture_path = ROOT / 'selfhost/build/phase154/capture-plan05/capture/report.json'
assets_path = ROOT / 'selfhost/manifests/assets-native.json'
api, capture, assets = [json.loads(x.read_text()) for x in [api_path, capture_path, assets_path]]
require(api['complete'] and api['checked'] and capture['complete'], 'Retained checked evidence required')
roots = ['p86_prepare', 'p86_plan', 'p134e_plan', 'p134e_begin', 'p134e_next',
         'nr_compile_prepared', 'ne_runtime_prepare', 'kf_source', 'nc_foreign_source']
require(set(roots) <= set(api['exports']), 'Retained API misses required roots; use documented extraction fallback')
require(api['source']['sha256'] == '027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8', 'Wrong canonical API')
row = next(r for r in capture['rows'] if r['name'] == a.case)
providers = {k: assets['assets'][k] for k in ['base', 'bun', 'c-runtime', 'c-effect-args', 'c-effect-print', 'c-effect-now']}
inputs = [pin(__file__), pin(ROOT/'experiments/phase165/tools/backend-replay.mjs'),
          pin(ROOT/'experiments/phase147/tools/support.mjs'), pin(ROOT/'experiments/phase154/tools/graph.mjs'),
          pin(api_path), pin(capture_path), pin(assets_path), api['api'], api['source'], row['source'], *providers.values()]
oracle = None
expected = None
if a.case == 'coverage-map-churn-128':
    prior_path = ROOT/'selfhost/build/phase156/pilot01/oracle-map/report.json'
    prior = json.loads(prior_path.read_text())
    require(prior['complete'] and prior['request']['source'] == row['source'], 'Oracle source mismatch')
    require(prior['request']['base'] == providers['base'], 'Oracle Base mismatch')
    oracle = pin(ROOT/'selfhost/build/phase156/pilot01/oracle-map/program.ssa')
    require(oracle['sha256'] == 'eba759e043db9d1dcb5883e51c2120d99e103cac70e334fa327da1458d7f7fda', 'Wrong retained Map oracle')
    expected = pin(ROOT/'selfhost/tests/consolidation/native-broad/coverage-map-churn-128.stdout')
    require(Path(expected['file']).read_text() == '3714872484\n', 'Unexpected Map value')
    inputs += [pin(prior_path), oracle, expected]
for value in inputs: verify(value)
out = fresh_output(a.out, ROOT)
plan = dict(kind='phase165-backend-replay', version=1, complete=True, targetsRun=False,
            apiReceipt=pin(api_path), api=api['api'], requiredExports=roots, source=row['source'],
            name=a.case, expectedStdout='3714872484\n' if a.case.startswith('coverage') else '0\n',
            expectedReason='Frozen original Map point' if a.case.startswith('coverage') else
              'p111_empty has no main; p111v_program_indexed returns a nonempty error, so Bool.to_u32(String.is_empty(...)) is zero.',
            providers=providers, inputs=inputs, qbeOracle=oracle, expectedFile=expected,
            executionArgs=['--threads', '1', '--gpu', 'off'],
            bounds=dict(graphBytes=32*1024**2, productBytes=16*1024**2, pieces=1000000),
            acquisition=dict(required=False, reason='Exact retained checked API exports all nine roots'))
write_json(out/'plan.json', plan)
replay = out/'replay'
command = [sys.executable, '-B', str(ROOT/'selfhost/tools/build-retention/guard.py'), '--out', str(out/'replay-guard'),
           '--run-root', str(replay), '--seconds', '90', '--disk-mib', '96', '--rss-mib', '3072',
           '--available-mib', '16384', '--file-mib', '32', '--cpu', '3', '--',
           str(ROOT/providers['bun']['file']), str(ROOT/'experiments/phase165/tools/backend-replay.mjs'),
           str(out/'plan.json'), str(replay)]
write_json(out/'jobs.json', [dict(name='complete-backend-replay', command=command)])
print(json.dumps(dict(plan=str(out/'plan.json'), jobs=str(out/'jobs.json'), acquisitionRequired=False, targetsRun=False)))
