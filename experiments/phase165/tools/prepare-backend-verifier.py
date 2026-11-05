#!/usr/bin/env python3
"""Add retained historical oracle to the unchanged replay preparation. No targets."""
import argparse, json, subprocess, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
from common import pin, verify, require, write_json
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
subprocess.run([sys.executable, '-B', str(ROOT/'experiments/phase165/tools/prepare-backend.py'),
                '--case', 'compiler-verifier-slice', '--out', str(a.out)], cwd=ROOT, check=True)
out = a.out.resolve()
plan = json.loads((out/'plan.json').read_text())
prior_path = ROOT/'selfhost/build/phase147/integrated-plan05/fast-pairs/00-02-new/report.json'
prior = json.loads(prior_path.read_text())
require(prior['complete'] and prior['byteExact'], 'Historical native oracle incomplete')
for field in ['bytes', 'sha256']:
    require(prior['source'][field] == plan['source'][field], 'Historical source content differs')
    require(prior['base'][field] == plan['providers']['base'][field], 'Historical Base differs')
oracle = prior['product']; verify(oracle)
require(oracle['sha256'] == '3065248dd7e11c486f17ae170f0cbe4ce0ade226dbc6500414ab50c2dd9fd343', 'Unexpected historical product')
capture_path = ROOT/'selfhost/build/phase154/capture-plan05/capture/report.json'
capture = json.loads(capture_path.read_text())
row = next(r for r in capture['rows'] if r['name'] == plan['name'])
verify(row['graph'])
require(row['graphBytes'] < plan['bounds']['graphBytes'], 'Prior superset capture exceeds request limit')
plan['qbeOracle'] = oracle
plan['oracleScope'] = 'Same exact source/Base, older Phase147 native generation. Strict byte equality gate; mismatch is inconclusive and stops this screen without fresh acquisition.'
plan['requestSizeEvidence'] = dict(supersetGraph=row['graph'], includes='planned request, request, selected owners, complete original emission plan',
                                 scope='Prior identity-preserving superset transport is below32MiB; actual request capture still has enforced32MiB limit.')
plan['inputs'] += [pin(__file__), pin(prior_path), oracle, row['graph']]
write_json(out/'plan.json', plan)
jobs = json.loads((out/'jobs.json').read_text())
for job in jobs:
    command = job['command']; command[command.index('--file-mib')+1] = '64'
write_json(out/'jobs.json', jobs)
print(json.dumps(dict(plan=str(out/'plan.json'), jobs=str(out/'jobs.json'), acquisitionRequired=False,
                     historicalOracle=True, targetsRun=False)))
