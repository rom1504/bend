#!/usr/bin/env python3
"""Bind the explicit Phase39 counter-control successor; execute no gate or program."""
import argparse
import copy
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
PARENT_SHA = 'c89b315bd4ef368da9dfa74ba3bae1f8ef574124be6bcbfe63763a6f9370435c'
TOOL_SHA = 'a41b7506c98d2ac12b30799d8fa94d03e2e3364158aba2c9cbbd133f12b6106e'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('plan_directory', type=Path)
p.add_argument('successor_report', type=Path)
p.add_argument('out', type=Path)
p.add_argument('--failed-launch', type=Path, required=True)
a = p.parse_args()
base, successor_file, out = (x.resolve() for x in [a.plan_directory, a.successor_report, a.out])
assert not out.exists(), 'Output must be new'
inputs = {}


def identity(file):
    file = Path(file).resolve()
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(2**20), b''):
            h.update(block)
    return dict(file=str(file), sha256=h.hexdigest(), bytes=file.stat().st_size)


def keep(file, expected=None):
    row = identity(file)
    if expected:
        assert row['sha256'] == expected['sha256'], row['file']
        assert 'bytes' not in expected or row['bytes'] == expected['bytes'], row['file']
    if row['file'] in inputs:
        assert inputs[row['file']] == row, row['file']
    inputs[row['file']] = row
    return row


def ref(row):
    return Path(keep(row.get('file', row.get('path')), row)['file'])


def read(file):
    keep(file)
    return json.loads(Path(file).read_text())


plan_file = base/'plan.json'
plan = read(plan_file)
assert plan['kind'] == 'phase35-final-integration-plan' and plan['complete'] and not plan['executed']
for row in plan['inputs']:
    ref(row)
attempt_file = ref(plan['attempt'])
attempt = read(attempt_file)
assert attempt['checked'] and attempt['api']['sha256'] == plan['api']['sha256']
launch = read(a.failed_launch)
assert launch['kind'] == 'phase35-serial-final-gate-launch' and not launch['complete']
assert ref(launch['plan']) == plan_file
steps = launch['steps']
assert steps and steps[-1]['name'] == 'owner-counters' and not steps[-1]['complete']
assert steps[-1]['returncode'] != 0 and all(s['complete'] and s['returncode'] == 0 for s in steps[:-1])
for step in steps:
    for key in ['stdout', 'stderr']:
        ref(step[key])
close = next(c for c in plan['commands'] if c['name'] == 'owner-close')
config_file = Path(close['command'][-2])
config = read(config_file)
assert config['attempt']['sha256'] == plan['attempt']['sha256']
assert config['api']['sha256'] == plan['api']['sha256']
assert sorted(config['cases']) == sorted(plan['ownerGates'])
assert len(config['cases']['counters']) == 1
failure_file = Path(config['cases']['counters'][0])
failure = read(failure_file)
assert failure['kind'] == 'phase35-counter-predicate-fixture-controls'
assert not failure['complete'] and not failure['pass']
assert 'count.scalar retained Nat representation' in failure['error']
assert len(failure['oracle']) == 35 and len(failure['structure']) == 3 and failure['boundaries'] == []
for row in failure['inputs']:
    ref(row)
parent = HERE.parent/'phase35/vector-counter-fixture-controls.mjs'
tool = HERE/'vector-counter-fixture-controls-v1.mjs'
assert keep(parent)['sha256'] == PARENT_SHA
assert keep(tool)['sha256'] == TOOL_SHA
successor = read(successor_file)
assert successor['kind'] == 'phase39-counter-predicate-fixture-controls-v1'
assert successor['complete'] and successor['pass'] and not successor.get('error')
assert successor['oracle'] == failure['oracle'], 'All prior independent oracle results must remain identical'
assert len(successor['structure']) == 5 and len(successor['boundaries']) == 5
assert successor['structure'][:3] == failure['structure']
assert ref(successor['derivation']['parent']) == parent
for row in successor['inputs']:
    ref(row)
old_inputs = {(r['file'], r['sha256']) for r in failure['inputs']}
new_inputs = {(r['file'], r['sha256']) for r in successor['inputs']}
assert old_inputs <= new_inputs and (str(tool), TOOL_SHA) in new_inputs
structures = {r['name']: r for r in successor['structure']}
assert len(structures) == 5
for name in ['count.keep', 'count.scalar']:
    assert structures[name]['number'] > 0
for name in ['count.observe', 'count.store']:
    assert structures[name]['number'] == 0 and structures[name]['bigint'] > 0
assert structures['count.alias']['number'] == 0
expected = [('benchKeep', 'count.keep'), ('benchObserve', 'count.observe'),
            ('benchStore', 'count.store'), ('benchScalar', 'count.scalar'), ('benchAlias', 'count.alias')]
assert [(r['entry'], r['helper']) for r in successor['boundaries']] == expected
for row in successor['boundaries']:
    observations = row['observations']
    assert len(observations) == 2 and observations[0] == observations[1]
    for observation in observations:
        assert observation['events'] == [row['helper']]
        assert observation['error'] == 'mutation:'+row['helper']
cohort_files = [Path(r['file']) for r in successor['inputs'] if Path(r['file']).name == 'derive.json']
assert len(cohort_files) == 1
cohort = read(cohort_files[0])
assert cohort['complete'] and list(cohort['variants']) == ['baseline', 'candidate', 'typescript']
source = ref(cohort['source'])
for role in ['baseline', 'candidate', 'typescript']:
    module = ref(cohort['variants'][role])
    assert (str(module), cohort['variants'][role]['sha256']) in new_inputs
    receipt = read(ref(cohort['emissions'][role]))
    assert receipt['kind'] == 'bend-program-checked-emission' and receipt['complete'] and receipt['observation']['checked']
    assert ref(receipt['input']) == source and ref(receipt['output']) == module
    assert receipt['compiler'] == cohort['compilers'][role]
    if role == 'candidate':
        assert ref(receipt['attempt']) == attempt_file
        for key in ['api', 'runtime', 'base']:
            assert ref(receipt['compiler'][key]) == ref(attempt[key])
new = copy.deepcopy(config)
new['cases']['counters'] = [str(successor_file)]
assert {k:v for k,v in new['cases'].items() if k != 'counters'} == {k:v for k,v in config['cases'].items() if k != 'counters'}
keep(__file__)
for row in inputs.values():
    assert identity(row['file']) == row
out.mkdir(parents=True)
new_config = out/'reports.json'
new_config.write_text(json.dumps(new, indent=2)+'\n')
report = dict(kind='phase39-counter-owner-rebinding-v1', complete=True, executed=False,
    parentPlan=keep(plan_file), originalMapping=keep(config_file), mapping=keep(new_config),
    failedReport=keep(failure_file), failedLaunch=keep(a.failed_launch), successorReport=keep(successor_file),
    parentTool=keep(parent), successorTool=keep(tool), inputs=list(inputs.values()),
    semanticCounts=dict(oracle=35, structure=5, boundaries=5),
    scope='Only counters report pointer replaced. Original plan, failed report, other groups, collector and final auditor remain unchanged. Scalar Number admission is now required; every oracle and mutation/refusal assertion remains.',
    closeCommand=['python3', str(HERE.parent/'phase35/final-owner-close.py'), str(plan_file), str(new_config), str(out/'owner-report.json')],
    auditOverride=['--owner-controls', str(out/'owner-report.json')])
(out/'rebinding.json').write_text(json.dumps(report, indent=2)+'\n')
(out/'consumed-rebind.py').write_bytes(Path(__file__).read_bytes())
print(json.dumps(dict(complete=True, executed=False, mapping=str(new_config), ownerReport=str(out/'owner-report.json'))))
