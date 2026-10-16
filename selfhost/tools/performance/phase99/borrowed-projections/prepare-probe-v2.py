#!/usr/bin/env python3
"""Prepare one data-only projection probe using the existing emitter and APIs."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / 'selfhost/build/phase99/borrowed-projections-probe02'

def pin(file):
    file = file.resolve()
    data = file.read_bytes()
    return {'file': str(file), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def write(name, value):
    (OUT / name).write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n')

OUT.mkdir(exist_ok=False)
prior = ROOT / 'selfhost/build/phase99/static-small01'
source = ROOT / 'selfhost/build/phase99/borrowed-projections-source01'
plan = json.loads((prior / 'plan.json').read_text())
plan['method'] = pin(Path(__file__))
plan['recipe'] = pin(source / 'changes.json')
plan['cases'] = []
plan['apis'] = {
    'baseline': str(prior / 'candidate.mjs'),
    'candidate': str(ROOT / 'selfhost/build/phase99/projection-api01/candidate.mjs'),
}
plan['sourceInputs'] = {
    'baseline': pin(prior / 'candidate-api.bend'),
    'candidate': pin(source / 'compiler.bend'),
}
plan['controls'] = [{
    'id': 'tag-projection',
    'source': pin(Path(__file__).with_name('tag-probe.bend')),
    'stdout': 'missing input\n', 'stderr': '', 'scalar': 1,
    'observerOwner': 'p98_tag_eq_read',
    'forbiddenOwners': ['p99_tag_repeat', 'p99_root_dump'],
}]
plan['scope'] = ('One bounded aggregate-tag prototype versus source04, using previously checked source04 API. '
                 'No new finite qualification suite or compiler image. One AST-tag loop uses all three exact '
                 'KTerm layouts, holds every root and prints all fields and aliases afterward. The existing '
                 'emitter additionally preserves its permission-off and unknown-provider checks. Runtime cases '
                 'and expected outputs are in runtime-cases.json; no program execution is performed by this preparer.')
write('plan.json', plan)
commands = json.loads((prior / 'commands.json').read_text())
emission = next(c for c in commands if c['name'] == 'emission')
emission['argv'][-2:] = [str(OUT / 'plan.json'), str(OUT / 'emission')]
write('commands.json', [emission])

def expected(tag, name, count):
    child = ['U32', '71', name, '4', '9']
    generic = [tag, name, '17', '2', *child, 'kids-end', name, 'removed-end', '11', '29']
    lam = ['Lam', name, '23', '1', *child, 'kids-end', name, 'removed-end', '31', '47', '1']
    literal = ['Str', '37', name, '53', '79']
    return '\n'.join([str(count), *generic, *lam, *literal, *child, tag, name]) + '\n'

write('runtime-cases.json', {
    'kind': 'phase99-projection-minimal-native-cases',
    'plan': pin(OUT / 'plan.json'),
    'iterations': 1000000,
    'observationsPerIteration': 3,
    'cases': [
        {'id': 'matched-three-layouts', 'argv': ['Var', 'payloadλ🙂'], 'stdout': expected('Var', 'payloadλ🙂', 3000000), 'stderr': ''},
        {'id': 'generic-mismatch-two-matches', 'argv': ['Other', 'payloadλ🙂'], 'stdout': expected('Other', 'payloadλ🙂', 2000000), 'stderr': ''},
        {'id': 'empty-tag-and-payload', 'argv': ['', ''], 'stdout': expected('', '', 2000000), 'stderr': ''},
    ],
    'measurement': 'After successful compile and exact output checks, use the matched case for alternating source04/candidate native timings; keep all runtime arguments identical. Count is fixed in the source; no compiler self image needed.',
    'sourceOnlyPreparation': True,
})
print(json.dumps({'plan': pin(OUT / 'plan.json'), 'commands': pin(OUT / 'commands.json'), 'runtime': pin(OUT / 'runtime-cases.json')}, indent=2))
