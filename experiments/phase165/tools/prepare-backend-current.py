#!/usr/bin/env python3
"""Bind the verifier replay to an exact, same-generation native oracle. No jobs."""
import argparse, json, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
from common import pin, verify, require, write_json, fresh_output
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
prior_path = ROOT/'selfhost/build/phase165/backend-plan03/plan.json'
failed_path = ROOT/'selfhost/build/phase165/backend-plan03/replay/report.json'
oracle_path = ROOT/'selfhost/build/phase165/verifier-oracle02/report.json'
old_oracle_path = ROOT/'selfhost/build/phase165/verifier-oracle01/report.json'
plan, failed, oracle = [json.loads(x.read_text()) for x in [prior_path, failed_path, oracle_path]]
api = json.loads(Path(plan['apiReceipt']['file']).read_text())
require(oracle['complete'] and oracle['byteExact'], 'Current native oracle must pass exact comparison')
require(oracle['request']['imageMetadata']['sourceIdentity']['sha256'] == api['source']['sha256'], 'Compiler source generation differs')
require(oracle['source'] == plan['source'] and oracle['base'] == plan['providers']['base'], 'Input source/Base differs')
require(not failed['complete'] and failed['qbeOracleExact'] is False, 'Expected preserved historical mismatch')
for field in ['bytes', 'sha256']:
    require(oracle['product'][field] == failed['products']['qbe']['file'][field], 'New native oracle differs from hosted product')
plan['qbeOracle'] = oracle['product']
plan['oracleScope'] = 'Exact same source/Base and qualified Phase152 compiler source027e1504; explicit native-n2 matches the complete hosted QBE.'
plan['supersedes'] = dict(plan=pin(prior_path), historicalGate=pin(failed_path), olderImageGate=pin(old_oracle_path))
plan['inputs'] += [pin(__file__), pin(prior_path), pin(failed_path), pin(old_oracle_path),
                   pin(oracle_path), oracle['product'], oracle['image']]
for row in plan['inputs']: verify(row)
out = fresh_output(a.out, ROOT)
write_json(out/'plan.json', plan)
jobs = json.loads((prior_path.parent/'jobs.json').read_text())
for job in jobs:
    command = job['command']
    command[command.index('--out')+1] = str(out/'replay-guard')
    command[command.index('--run-root')+1] = str(out/'replay')
    command[-2:] = [str(out/'plan.json'), str(out/'replay')]
write_json(out/'jobs.json', jobs)
print(json.dumps(dict(plan=str(out/'plan.json'), jobs=str(out/'jobs.json'), acquisitionRequired=False, targetsRun=False)))
