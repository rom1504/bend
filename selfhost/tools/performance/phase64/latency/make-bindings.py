#!/usr/bin/env python3
"""Bind State09 and a genuine candidate, and print root-only target recipes."""
import argparse
import hashlib
import json
import shlex
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase64'
SOURCE_BINDING = ROOT / 'selfhost/build/phase63/state09-b2-latency/bindings.json'


def identity(value):
    file = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
    result = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if isinstance(value, dict):
        assert result['sha256'] == value['sha256'], str(file)
    return result


inputs = {}


def pin(value):
    result = identity(value)
    inputs[result['file']] = result
    return result


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def save(file, value):
    with file.open('x') as stream:
        stream.write(json.dumps(value, indent=2) + '\n')


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('out', type=Path)
p.add_argument('--method', type=Path, required=True)
p.add_argument('--image', choices=['b1', 'b2'], default='b2')
p.add_argument('--baseline-image', choices=['b1', 'b2'],
               help='Defaults to candidate generation; cross-generation comparisons are explicitly labelled')
p.add_argument('--candidate-attempt', type=Path)
p.add_argument('--candidate-emission', type=Path)
p.add_argument('--candidate-admission', type=Path)
p.add_argument('--candidate-roots-reference', type=Path)
p.add_argument('--candidate-oracles', type=Path)
p.add_argument('--without-typescript', action='store_true')
p.add_argument('--include-baseline-b1', action='store_true',
               help='Also bind old checked B1; selected only by the generations recipe')
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(RAW.resolve()) and not out.exists()
assert bool(a.candidate_admission) == bool(a.candidate_roots_reference)
assert not a.candidate_admission or a.candidate_attempt
assert not a.candidate_emission or a.candidate_attempt
assert not a.candidate_oracles or a.candidate_attempt

baseline = read(SOURCE_BINDING)['roles']['candidate']
assert baseline['kind'] == 'direct'
old_attempt = read(baseline['attempt'])
old_emission = read(baseline['emission'])
assert pin(old_attempt['api'])['sha256'] == '4a208bffcf47b5d19f8ff18be1fc01b2faf988b37d38e7f5db9e6bd42d79905f'
assert pin(old_emission['module'])['sha256'] == 'e838cbab6e6543d1785da0474c50c1c33ab91e6806d2e6796cfcbeabf5b98003'
assert old_attempt['checked'] is True and old_emission['complete'] is True and old_emission['pass'] is True
old_b1 = {**baseline, 'kind': 'checked'}
del old_b1['emission']
baseline_image = a.baseline_image or a.image
roles = {'baseline': baseline if baseline_image == 'b2' else old_b1}
comparison = 'fixed-source'
if a.candidate_attempt:
    attempt_file = a.candidate_attempt / 'attempt.json' if a.candidate_attempt.is_dir() else a.candidate_attempt
    attempt_id = pin(attempt_file)
    attempt = read(attempt_id)
    assert attempt['checked'] is True and isinstance(attempt['config']['strictExact'], bool)
    for name in ['api', 'checkedApi', 'bootstrapReport', 'runtime', 'base']:
        pin(attempt[name])
    boot = read(attempt['bootstrapReport'])
    assert pin(boot['source'])['sha256'] == boot['sourceSha256']
    candidate = dict(kind='checked', attempt=attempt_id)
    if a.image == 'b2':
        assert a.candidate_emission, 'A genuine B2 requires its complete own-source emission receipt'
        emission_id = pin(a.candidate_emission)
        emission = read(emission_id)
        assert emission['kind'] == 'phase55-split-compiler-emission'
        assert emission['complete'] is True and emission['pass'] is True
        assert pin(emission['generator']['attempt']) == attempt_id
        for key in ['api', 'runtime']:
            assert pin(emission['generator'][key]) == pin(attempt[key])
        assert pin(emission['generator']['bootstrap']) == pin(attempt['bootstrapReport'])
        assert emission['checking']['lane'] == 'inherited-exact-bootstrap'
        assert emission['checking']['freshSelfCheck'] is False
        assert emission['checking']['sourceSha256'] == pin(emission['subject']['source'])['sha256']
        pin(emission['module']); pin(emission['directRuntime'])
        candidate.update(kind='direct', emission=emission_id)
    else:
        assert not a.candidate_emission
    if a.candidate_admission:
        admission_id = pin(a.candidate_admission)
        reference_id = pin(a.candidate_roots_reference)
        admission, reference = read(admission_id), read(reference_id)
        assert admission['kind'] == 'phase61-bootstrap-export-admission' and admission['version'] == 1
        assert reference['kind'] == 'phase61-checked-bootstrap-export-reference'
        assert reference['admission'] == admission_id and reference['attempt'] == attempt_id
        assert pin(reference['bootstrap']) == pin(attempt['bootstrapReport'])
        assert reference['roots'] == boot['exports']
        assert pin(Path(attempt['snapshot']['root'])/'tools/typed-driver.mjs')['sha256'] == pin(admission['driver'])['sha256']
        candidate.update(admission=admission_id, rootsReference=reference_id)
    roles['candidate'] = candidate
    comparison = 'changed-source'
if a.include_baseline_b1:
    roles['baseline_b1'] = old_b1
policies = {role: dict(kind='catalog', referenceRole='direct') for role in roles}
if a.candidate_oracles:
    oracle_id = pin(a.candidate_oracles)
    oracle = read(oracle_id)
    assert oracle['kind'] == 'phase61-qualified-compiler-output-oracles'
    assert oracle['complete'] is True and oracle['pass'] is True
    policies['candidate'] = dict(kind='qualified', manifest=oracle_id)
binding = dict(kind='phase61-compiler-image-bindings', version=1, comparison=comparison,
    roles=roles, outputPolicies=policies,
    scope='Actual State09 checked B1/genuine B2 versus independently checked candidate B1/genuine B2. '
          'No synthesized bootstrap sidecars or correctness/promotion claims.')
method = a.method.resolve(strict=True)
assert method.is_relative_to(RAW.resolve())
derivation = read(method/'derivation.json')
assert derivation['kind'] == 'phase61-candidate-fast-loop-method' and derivation['complete'] and derivation['pass']
for row in derivation['derivations']:
    pin(row['parent']); pin(row['output'])
pin(derivation['producer'])
runner = pin(method/'run.py')
producer = pin(__file__)
role_list = ['baseline'] + (['candidate'] if a.candidate_attempt else [])
if not a.without_typescript:
    role_list += ['typescript']
assert len(role_list) >= 2
prepared_roles = role_list + (['baseline_b1'] if a.include_baseline_b1 else [])
base = [sys.executable, runner['file']]
common = ['--bindings', str(out/'bindings.json'), '--roles', ','.join(role_list)]
prepared = ['--preparations', str(out/'preparation/report.json')]
commands = dict(prepare=base+[str(out/'preparation'), '--bindings', str(out/'bindings.json'),
    '--roles', ','.join(prepared_roles), '--cases', 'all', '--prepare-only', '--seconds', '240'])
for label, cases, rounds, seconds, warm in [
    ('baseline-three', 'numeric-recurrence,lexer,test-map-set-ops', len(role_list), 90, 0),
    ('screen', 'numeric-recurrence,test-map-set-ops', 1, 35, 0),
    ('screen-balanced', 'numeric-recurrence,test-map-set-ops', len(role_list), 90, 0),
    ('confirm', 'numeric-recurrence,test-map-set-ops,raytrace-active', 2, 90, 0),
    ('heldout', 'lexer,test-evening-program', len(role_list), 180, 0),
    ('broad', 'all', 3, 600, 0),
    ('later', 'numeric-recurrence,test-map-set-ops,raytrace-active', len(role_list), 180, 3),
]:
    commands[label] = base+[str(out/label), *common, *prepared, '--cases', cases,
        '--rounds', str(rounds), '--warm-requests', str(warm), '--seconds', str(seconds)]
if a.include_baseline_b1:
    gen_roles = role_list + ['baseline_b1']
    commands['generations'] = base+[str(out/'generations'), '--bindings', str(out/'bindings.json'),
        '--roles', ','.join(gen_roles), *prepared, '--cases', 'numeric-recurrence,test-map-set-ops,lexer,raytrace-active',
        '--rounds', str(len(gen_roles)), '--warm-requests', '0', '--seconds', '300']
for mode in ['cpu', 'allocation']:
    commands[mode] = base+[str(out/mode), *common, *prepared, '--cases', 'numeric-recurrence,lexer,test-map-set-ops',
        '--rounds', '1', '--warm-requests', '0', '--mode', mode, '--seconds', '120']
for item in inputs.values():
    assert identity(item) == item
out.mkdir(parents=True)
save(out/'bindings.json', binding)
report = dict(kind='phase64-fast-loop-recipe', complete=True, **{'pass': True}, dataOnly=True,
    targetExecuted=False, producer=producer, inputs=list(inputs.values()),
    bindings=identity(out/'bindings.json'), commands=commands, image=a.image, baselineImage=baseline_image,
    crossGenerationComparison=baseline_image != a.image, roles=role_list,
    candidatePending='candidate' not in roles,
    scope='Screen is one pair/triple per source, not a position-balanced population claim. '
          'screen-balanced explicitly rotates every role position; confirm is two rounds. '
          'Broad has three rounds (position-balanced with the intended three roles), zero later requests. '
          'Prepared persistent cache, fresh process per sample, genuine lineage and full raw-output checks. '
          'Later requests and profiles remain separately labelled. Installed files are untouched.')
save(out/'recipe.json', report)
(out/'commands.txt').write_text('\n\n'.join('# '+key+'\n'+shlex.join(value) for key,value in commands.items())+'\n')
print(json.dumps(dict(recipe=identity(out/'recipe.json'), commands=str(out/'commands.txt'))))
