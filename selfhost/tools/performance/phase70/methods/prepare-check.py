#!/usr/bin/env python3
"""Bind an existing persistent checker to fresh private files; no target runs."""
import argparse
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT/'selfhost/build/phase70'


def pin(path, expected=None):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    value = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert value['sha256'] == expected['sha256'], path
    return value


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x') as stream:
        stream.write(json.dumps(value, indent=2)+'\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['attempt','selection','out']:
        parser.add_argument('--'+name, type=Path, required=True)
    parser.add_argument('--expected-cases', type=int, required=True)
    args = parser.parse_args()
    assert os.sched_getaffinity(0) == {0}
    out = args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    attempt_file = args.attempt.resolve(strict=True)/'attempt.json'
    attempt = json.loads(attempt_file.read_text())
    assert attempt['checked'] and attempt['config']['strictExact']
    assert str(attempt['config']['cpu']) == '3' and attempt['config']['jobs'] == 1
    snapshot = Path(attempt['snapshot']['root'])
    api = pin(attempt['api']['file'], attempt['api'])
    base = pin(attempt['base']['file'], attempt['base'])
    node = pin(attempt['node']['file'], attempt['node'])
    selected = json.loads(args.selection.read_text())
    assert set(selected) == {'cases'} and len(selected['cases']) == args.expected_cases
    fixture_inputs, cases = [], []
    for row in selected['cases']:
        assert row['lanes'] == ['native']
        file = Path(row['file']).resolve(strict=True)
        source = file.read_text()
        assert '\ndef main(' in '\n'+source, 'Check-only positive oracle requires a main definition'
        goldens = [line[2:] for line in source.splitlines() if line.startswith('#|')]
        assert goldens, 'Original native oracle must remain present'
        fixture_inputs.append(dict(source=pin(file), nativeGoldenLines=goldens))
        # The existing checker judges a main program by genuine type acceptance.
        # Runtime-failure #| text must not make this a negative checker oracle.
        cases.append(dict(id='phase70/check-only/'+row['id'], file=str(file), lanes=['check'], expected=''))
    assert len({row['id'] for row in cases}) == args.expected_cases
    out.mkdir(parents=True)
    project = out/'project'
    copies = []
    for row in attempt['snapshot']['sources']:
        source = Path(row['frozen']['file'])
        original = pin(source, row['frozen'])
        target = project/source.relative_to(snapshot)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(source.read_bytes())
        copied = pin(target)
        assert copied['sha256'] == original['sha256']
        copies.append(dict(original=original, copy=copied))
    selection = out/'selection-check.json'
    write(selection, dict(cases=cases))
    environment = dict(BEND_TYPED_API=api['file'], BEND_TYPED_RUNTIME=str(project/'src/runtime.mjs'),
        BEND_BASE=base['file'], BEND_TYPED_TRACE='1', NODE_OPTIONS='', NODE_PATH='')
    guard = ROOT/'selfhost/tools/performance/phase32/bounded-run.py'
    runner = project/'tools/conformance/run.mjs'
    upstream = attempt['config']['upstream']

    def command(role, persistent):
        adapter = project/'tools/conformance/adapters'/('typed.mjs' if role=='baseline' else 'upstream.mjs')
        return ['python3','-B',str(guard),'--seconds','180','--rss-mib','2048',
            '--available-mib','4096',str(out/(role+'-supervisor')),'--','taskset','-c','3',
            'env',*[key+'='+value for key,value in environment.items()],node['file'],
            '--max-old-space-size=1024','--stack-size=4096',str(runner),'--upstream',upstream,
            '--adapter',str(adapter),'--selection',str(selection),'--output',str(out/(role+'.json')),
            '--jobs','1','--timeout','30000','--worker-mode','persistent' if persistent else 'isolated',
            '--recycle-after','64','--rss-limit-mb','1024','--stack-kb','4096','--heap-mb','1024',
            '--lanes','check','--retain','all','--selected-exit','1']

    plan = dict(kind='phase70-source-check-plan', targetsExecuted=False, producer=pin(__file__),
        attempt=pin(attempt_file), api=api, base=base, node=node, originalSelection=pin(args.selection),
        selection=pin(selection), fixtureInputs=fixture_inputs, copies=copies,
        expectedCases=args.expected_cases, command=command('baseline', True),
        optionalUpstreamCommand=command('upstream', False), guard=pin(guard),
        requiresEscalatedExecution=True,
        scope='Maintained frozen conformance runner and checker adapter, byte-identical private source/host copies. Only check lane; no interpreter, emission, Clang or native execution. Original native source/goldens retained; positive main-program check oracle verifies actual type acceptance. Baseline persistent session owns one ready Base; upstream optional isolated check has a separate receipt. No runtime or full-conformance claim.')
    write(out/'plan.json', plan)
    print(json.dumps(dict(plan=pin(out/'plan.json'), expectedCases=args.expected_cases, targetsExecuted=False)))


if __name__ == '__main__':
    main()
