#!/usr/bin/env python3
"""Resolve the three-path lookup job plan; execute no compiler or target."""
import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, require, fresh_output, write_json

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--preparation', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--run-root', type=Path, required=True)
p.add_argument('--rounds', type=int, choices=(1000,10000), required=True)
p.add_argument('--role', choices=('lookup','expected-records'), required=True)
a = p.parse_args()
prepared = json.loads(a.preparation.read_text())
require(prepared['complete'] and prepared['targetsRun'] is False, 'Source-only prepared input required')
source = prepared['source']; verify(source)
spec_path = ROOT / 'experiments/phase166/lookup-spec.json'
spec = json.loads(spec_path.read_text())
if a.role == 'lookup':
    main_name = '/lookup-main.bend' if a.rounds == 1000 else '/lookup-10000-main.bend'
    main_pin = next(x for x in spec['inputs'] if x['file'].endswith(main_name))
    main_pin = {**main_pin, 'file': str(ROOT / main_pin['file'])}
else:
    require(a.rounds == 10000, 'Only the fixed10000 expected-record control exists')
    main_pin = pin(ROOT/'selfhost/tests/phase166/lookup-consumer-main.bend')
    require(Path(main_pin['file']).read_text() == 'def main() -> U32:\n  p166c_run(10000)\n', 'Control main differs')
verify(main_pin)
require(any(x['sha256'] == main_pin['sha256'] for x in prepared['inputs']), 'Plan must use the pinned requested main point')
api_path = ROOT / 'selfhost/build/phase152/composite-api01/report.json'
api_receipt = json.loads(api_path.read_text())
require(api_receipt['complete'] and api_receipt['checked'], 'Checked selected compiler API required')
exports = ['p86_prepare','p86_plan','p134e_plan','p134e_begin','p134e_next','nr_compile_prepared','ne_runtime_prepare']
require(set(exports) <= set(api_receipt['exports']), 'Missing actual backend API')
parent_path = ROOT / 'selfhost/build/phase165/backend-plan04/plan.json'
parent = json.loads(parent_path.read_text())
providers = {k: parent['providers'][k] for k in ('base','bun','c-runtime')}
assets_path = ROOT / 'selfhost/manifests/assets-native.json'
assets = json.loads(assets_path.read_text())
seed_path = ROOT / 'selfhost/build/phase160/capped-seed01/report.json'
seed = json.loads(seed_path.read_text()); require(seed['complete'], 'Incomplete bounded-search seed')
recipe_path = ROOT / 'selfhost/build/phase157/seed01/report.json'
recipe = json.loads(recipe_path.read_text())['command']
header_path = ROOT / 'selfhost/build/phase159/refill-prepare01/report.json'
header = json.loads(header_path.read_text()); verify(header['candidate']); verify(header['original'])
require(Path(header['candidate']['file']).read_text().replace(header['replacement'],header['needle']) == Path(header['original']['file']).read_text(), 'Bounded-search runtime patch differs')
run = a.run_root.resolve(); require(not run.exists() and run.is_relative_to(ROOT/'selfhost/build/phase166'), 'Fresh phase166 run root required')
out = fresh_output(a.out,ROOT)
inputs = [main_pin,pin(ROOT/'selfhost/tests/phase166/lookup-consumer-control.bend'),pin(__file__),pin(ROOT/'experiments/phase166/lookup-emit.mjs'),pin(a.preparation),source,
          pin(spec_path),pin(api_path),api_receipt['api'],pin(parent_path),*providers.values(),
          pin(assets_path),pin(seed_path),seed['binary'],pin(recipe_path),pin(recipe[0]),
          pin(header_path),header['candidate'],header['original']]
for row in inputs: verify(row)
plan = dict(kind='phase166-lookup-three-path-plan',version=3,complete=True,targetsRun=False,rounds=a.rounds,role=a.role,
            inputs=inputs,source=source,apiReceipt=pin(api_path),api=api_receipt['api'],exports=exports,
            providers=providers,bendc=seed['binary'],runRoot=str(run),expectedStdout=spec['expectedStdout'][str(a.rounds)],
            executionArgs=['--threads','1','--gpu','off'],
            runtimeEnvironment={'BEND_RC':'0','BEND_NO_FREE':'1','BEND_AUTO_PAR':'0','BANGS':'0'},
            environmentClear=['all inherited BEND_*','BANGS','LD_PRELOAD','LD_AUDIT'],
            unboxingPolicy='Default unchanged; BEND_UNBOX is explicitly absent. Any fallback needs a fresh observed-failure treatment.',
            scope='Same extracted source and Base through qualified hosted QBE/mature C and bounded-search Bendc C. Pure computation; complete-value controls required before native digest/timing. No acquisition, execution or speed claim.')
ours = run/'ours'
clang, c = assets['assets']['clang'], assets['toolchains']['c']; verify(clang)
c_command = [clang['file'],*c['flags'],*c.get('includeFlags',[]),str(ours/'program.c'),'-o',str(run/'mature-c'),*c['libraries']]
bendc_command = list(recipe)
bendc_command[bendc_command.index('-I'):bendc_command.index('-I')] = ['-I',str(Path(header['candidate']['file']).parent)]
bendc_command[bendc_command.index('-o')-1] = str(run/'bendc.c')
bendc_command[bendc_command.index('-o')+1] = str(run/'bendc-program')
plan['controlScope'] = ('Actual lookup+fixture producer with complete consumer' if a.role == 'lookup' else 'Counterfactual independently specified complete records with identical digest/fold; producer/reachability/inlining/lifetime change, so timing differences are not exact component subtraction.')
plan['jobs'] = [
    dict(name='ours-emission',command=[providers['bun']['file'],str(ROOT/'experiments/phase166/lookup-emit.mjs'),str(out/'plan.json'),str(ours)],seconds=60),
    dict(name='bendc-checked-emission',command=[seed['binary']['file'],'--threads','1','--gpu','off','--',providers['base']['file'],source['file']],stdout=str(run/'bendc.c'),seconds=60),
    dict(name='qbe-machine',command=[sys.executable,'-B','selfhost/tools/build/native.py','--assets',str(assets_path),'--target','qbe','--ir',str(ours/'program.ssa'),'--out',str(run/'qbe-machine'),'--seconds','45'],seconds=55),
    dict(name='mature-c-machine',command=c_command,seconds=60),
    dict(name='bendc-machine',command=bendc_command,seconds=60),
]
plan['binaries'] = {'qbe':str(run/'qbe-machine/program'),'c':str(run/'mature-c'),'bendc':str(run/'bendc-program')}
plan['executionPlan'] = dict(first='Each product once; exact stdout, empty stderr and successful exit required.',
    repeats='Root-selected 0..4 balanced reversed-order cycles only after raw controls and native oracles pass; preserve each whole-process clock. Adapt source rounds in a fresh pinned main if unresolved.',
    resources='Root creates run root, guards the whole declared job/artifact budget, keeps 5GiB reserve, and closes receipts; no nested guard.')
write_json(out/'plan.json',plan)
print(json.dumps(dict(plan=str(out/'plan.json'),targetsRun=False,jobs=len(plan['jobs']),source=source)))
