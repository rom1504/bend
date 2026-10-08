#!/usr/bin/env python3
"""Freeze selected B1/B2 and explicitly owned prior exact-C oracles; data only."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
RAW = ROOT/'selfhost/build/phase68'
inputs = {}


def pin(p):
    p = Path(p).resolve(strict=True)
    b = p.read_bytes()
    value = dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))
    inputs[str(p)] = value
    return value


def verified(value):
    p = pin(value.get('file', value.get('path')))
    assert p['sha256'] == value['sha256']
    assert 'bytes' not in value or p['bytes'] == value['bytes']
    return p


def read(p):
    return json.loads(Path(pin(p)['file']).read_text())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--attempt', type=Path, required=True)
    ap.add_argument('--image-pins', type=Path, required=True)
    ap.add_argument('--oracle-attempt', type=Path,
        help='Actual checked B1 that emitted acquired C; defaults to selected attempt. Fresh workers must reproduce complete C.')
    ap.add_argument('--acquired', type=Path, action='append', required=True,
        help='Repeat for selected native acquisition reports, covering numeric/array/lexer exactly once')
    ap.add_argument('--reference-acquired', type=Path, action='append', required=True,
        help='Repeat for pinned TypeScript acquisition reports, covering numeric/array/lexer exactly once')
    ap.add_argument('--rounds', type=int, default=1, choices=[1, 2, 3])
    args = ap.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    out.mkdir(parents=True)
    for p in [__file__, HERE/'worker.mjs', HERE/'run.py', HERE/'analyze.py', ROOT/'selfhost/tools/performance/programs/support.py']:
        pin(p)
    attempt_pin = pin(args.attempt)
    attempt = read(attempt_pin['file'])
    assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1' and attempt['config']['strictExact']
    oracle_pin = pin(args.oracle_attempt or args.attempt)
    oracle_attempt = read(oracle_pin['file'])
    assert oracle_attempt['checked'] and oracle_attempt['artifactKind'] == 'derived-b1' and oracle_attempt['config']['strictExact']
    oracle_api = verified(oracle_attempt['api'])
    for key in ['checkedApi', 'derivationReport', 'bootstrapReport']:
        verified(oracle_attempt[key])
    b2_pin = pin(args.image_pins)
    image = read(b2_pin['file'])
    assert verified(image['attempt']) == attempt_pin
    assert verified(image['b1']) == verified(attempt['api'])
    for key in ['source', 'emission', 'comparison', 'plan', 'rootsReference', 'admission']:
        verified(image[key])
    emission, comparison = read(image['emission']['file']), read(image['comparison']['file'])
    assert emission['complete'] and emission['pass'] and comparison['complete'] and comparison['pass']
    assert verified(emission['module']) == verified(image['b2'])
    assert verified(emission['subject']['attempt']) == verified(emission['generator']['attempt']) == attempt_pin
    assert verified(emission['subject']['source']) == verified(image['source'])
    assert verified(emission['generator']['api']) == verified(attempt['api'])
    snapshot = Path(attempt['snapshot']['root'])
    frozen = {x['frozen']['file']: x['frozen'] for x in attempt['snapshot']['sources']}
    base = verified(attempt['base'])
    assert base['sha256'] == '99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf'
    node = pin('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
    source_files = [snapshot/'tools'/n for n in ['typed-driver.mjs','assemble.mjs','native-build.mjs','node-resource-args.mjs','compiler-abi.mjs','base-cache-graph.mjs']]
    source_files += [snapshot/'src/runtime.mjs', snapshot/'src/compiler.json']
    source_files += [p for p in (snapshot/'src/runtime/native').rglob('*') if p.is_file()]
    roles = {}
    copies = []
    for name, api in [('b1', attempt['api']), ('b2', image['b2'])]:
        project = out/name/'project'
        for source in source_files:
            original = verified(frozen[str(source)])
            target = project/source.relative_to(snapshot)
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(source.read_bytes())
            copied = pin(target);assert copied['sha256'] == original['sha256']
            copies.append(dict(original=original, copy=copied))
        roles[name] = dict(api=verified(api), node=node, base=base, project=str(project),
            driver=pin(project/'tools/typed-driver.mjs'), runtime=pin(project/'src/runtime.mjs'),
            preparation=str(out/'runs'/('prepare-'+name)/'report.json'))
    upstream = ROOT/'selfhost/.bootstrap/upstream-phase66/bend2'
    roles['typescript'] = dict(node=node, bend=pin(upstream/'bend.ts'), compiler=pin(upstream/'comp.ts'), base=pin(upstream/'base.bend'))
    for p in (upstream/'effs').glob('*.c'):
        pin(p)
    catalog = read(ROOT/'selfhost/tools/performance/phase46/cases.json')
    for row in catalog:
        verified(dict(file=str(ROOT/row['source']), sha256=row['sha256']))
        pin(ROOT/'selfhost/tools/performance/phase46'/(row['name']+'-batch.bend'))
    def acquisitions(paths, role):
        selected = {}
        for path in paths:
            identity, report = pin(path), read(path)
            assert report['complete']
            for record in report['records']:
                case = record['case']
                if case not in ['numeric', 'array', 'lexer'] or record['role'] != role:
                    continue
                assert case not in selected, ('ambiguous acquired case', role, case)
                assert record['correct']
                for phase in ['emission', 'toolchain', 'process']:
                    assert record[phase]['complete'] and record[phase]['returncode'] == 0
                verified(record['executable'])
                selected[case] = identity, report, record
        assert set(selected) == {'numeric', 'array', 'lexer'}, ('missing acquired cases', role)
        return selected
    selected = acquisitions(args.acquired, 'selfhost')
    references = acquisitions(args.reference_acquired, 'upstream')
    cases = {}
    for case in ['numeric', 'array', 'lexer']:
        current_pin, current_report, current = selected[case]
        reference_pin, reference_report, prior = references[case]
        assert current_report['complete'] and reference_report['complete'] and current['correct'] and prior['correct']
        current_recipe = read(verified(current_report['recipe'])['file'])
        reference_recipe = read(verified(reference_report['recipe'])['file'])
        assert Path(current_recipe['api']).resolve() == Path(oracle_api['file']).resolve()
        assert current_recipe['upstreamCommit'] == reference_recipe['upstreamCommit'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
        source = pin(ROOT/'selfhost/tools/performance/phase46'/(case+'-batch.bend'))
        current_emit = read(verified(current['emissionReceipt'])['file'])
        reference_emit = read(verified(prior['emissionReceipt'])['file'])
        assert current_emit['complete'] and reference_emit['complete']
        assert verified(current_emit['recipe']) == verified(current_report['recipe'])
        assert verified(reference_emit['recipe']) == verified(reference_report['recipe'])
        assert verified(current['source']) == verified(prior['source']) == source
        assert verified(current_emit['input']) == verified(reference_emit['input']) == source
        assert verified(current_emit['output']) == verified(current['nativeSource'])
        assert verified(reference_emit['output']) == verified(prior['nativeSource'])
        assert any(p['sha256'] == oracle_api['sha256'] and Path(p['path']).resolve()==Path(oracle_api['file']).resolve() for p in current_emit['compiler'])
        assert any(p['sha256'] == roles['typescript']['compiler']['sha256'] for p in reference_emit['compiler'])
        assert current['expected'] == prior['expected']
        cases[case] = dict(input=source,
            expected=dict(b1=verified(current['nativeSource']), b2=verified(current['nativeSource']), typescript=verified(prior['nativeSource'])),
            nativeOracleEvidence=verified(current['emissionReceipt']), acquisition=current_pin,
            referenceAcquisition=reference_pin, expectedRuntime=current['expected'])
    jobs = [dict(name='prepare-'+role, role=role, action='prepare', profile=False) for role in ['b1','b2']]
    for round_ in range(args.rounds):
        for offset, case in enumerate(cases):
            order=['typescript','b1','b2']; shift=(round_+offset)%3;order=order[shift:]+order[:shift]
            for role in order:
                jobs.append(dict(name=f'clean-{round_}-{case}-{role}', action='request', role=role, case=case, profile=False, round=round_))
    jobs += [dict(name='profile-'+case+'-b2', action='request', role='b2', case=case, profile=True) for case in cases]
    jobs += [dict(name='profile-numeric-b1', action='request', role='b1', case='numeric', profile=True)]
    plan = dict(kind='phase68-native-compilation-plan', version=3, status='prepared-unexecuted',
        predecessorMethod=pin(HERE/'prepare-selected-v1.py'), oracleAttempt=oracle_pin, oracleApi=oracle_api,
        attempt=attempt_pin, imagePins=b2_pin, copies=copies, roles=roles, cases=cases, jobs=jobs,
        cpu=3, nodeArgs=['--max-old-space-size=1024','--stack-size=4096'], seconds=90,
        rssMiB=2048, availableMiB=4096, inputs=list(inputs.values()),
        scope='Fresh processes and mandatory prepared Bend Base. Imports/API loading, explicit preparation, full checked C-emission request, Clang and runtime are separate clocks. TS ordinary book_load checks Base within its request. Exact C must match independently validated native acquisitions from the separately identified oracleAttempt; fresh selected B1/B2 workers earn this complete-byte equality and no earlier producer is relabeled. Profile workers are diagnostics, never timing samples. One round is a screen; three rotations are required for a position-balanced TS/B1/B2 comparison.')
    path = out/'plan.json'
    path.write_text(json.dumps(plan, indent=2)+'\n')
    print(json.dumps(dict(plan=pin(path), jobs=len(jobs), roles=list(roles))))


if __name__ == '__main__':
    main()
