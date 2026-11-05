#!/usr/bin/env python3
"""Prepare only: reverse the complete replay, pin both machine-qualified products."""
import argparse, json, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
from common import pin, verify, require, write_json, fresh_output
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--case', choices=['map', 'verifier'], required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
prior_name, machine_name = ('backend-plan02','backend-machine01') if a.case == 'map' else ('backend-plan04','backend-machine03')
prior_path = ROOT/'selfhost/build/phase165'/prior_name/'plan.json'
emission_path = prior_path.parent/'replay/report.json'
machine_path = ROOT/'selfhost/build/phase165'/machine_name/'report.json'
plan, emission, machine = [json.loads(x.read_text()) for x in [prior_path, emission_path, machine_path]]
require(emission['complete'] and emission['qbeOracleExact'] and machine['complete'], 'Completed prior semantic gates required')
require(plan['source'] == emission['source'], 'Prior request source differs')
for role in ['c', 'qbe']:
    require(machine['products'][role]['exact'], 'Prior machine value failed')
    value = emission['products'][role]['file']; verify(value)
    require(any(x['sha256'] == value['sha256'] and x['bytes'] == value['bytes'] for x in machine['inputs']), 'Prior machine gate did not consume product')
plan['cOracle'] = emission['products']['c']['file']
plan['qbeOracle'] = emission['products']['qbe']['file']
plan['order'] = ['c', 'qbe']
plan['previousRequest'] = emission['request']
plan['priorMachineGate'] = pin(machine_path)
plan['captureScope'] = 'No new request graph capture; full live request feeds both backends. Exact C and QBE output gates transfer the prior finite machine result.'
runner = ROOT/'experiments/phase165/tools/backend-replay-v2.mjs'
plan['inputs'] += [pin(__file__), pin(runner), pin(prior_path), pin(emission_path), pin(machine_path),
                   plan['cOracle'], plan['qbeOracle'], plan['previousRequest']]
for row in plan['inputs']: verify(row)
out = fresh_output(a.out, ROOT)
write_json(out/'plan.json', plan)
jobs = json.loads((prior_path.parent/'jobs.json').read_text())
for job in jobs:
    command = job['command']
    command[command.index('--out')+1] = str(out/'replay-guard')
    command[command.index('--run-root')+1] = str(out/'replay')
    command[command.index('--file-mib')+1] = '64'
    command[command.index('--disk-mib')+1] = '40'
    command[-3:] = [str(runner), str(out/'plan.json'), str(out/'replay')]
write_json(out/'jobs.json', jobs)
print(json.dumps(dict(plan=str(out/'plan.json'), jobs=str(out/'jobs.json'), acquisitionRequired=False,
                     order=plan['order'], capture=False, targetsRun=False)))
