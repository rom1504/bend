#!/usr/bin/env python3
"""Checked B1/B2 whole-C identity for validated prior programs; no native reruns."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path('/home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase70/methods/compilation')
ROOT = Path('/home/ai/bend2/build/publish/bend')
RAW = ROOT/'selfhost/build/phase72'
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
        help='Prior independently native-validated selfhost acquisitions, no duplicate cases')
    ap.add_argument('--expected-cases', type=int, required=True)
    args = ap.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    assert 0 < args.expected_cases <= 100
    out.mkdir(parents=True)
    for p in [__file__, Path(__file__).with_suffix('.derivation.json'), HERE.parent/'analyze-c-identity.py', HERE/'worker.mjs', HERE/'run.py', ROOT/'selfhost/tools/performance/programs/support.py']:
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
    # Complete emitted C can reference runtime/effect sources. Reusing native
    # evidence also requires byte-identical host and native support on both sides.
    oracle_snapshot = Path(oracle_attempt['snapshot']['root'])
    oracle_frozen = {str(Path(x['frozen']['file']).relative_to(oracle_snapshot)): x['frozen']
        for x in oracle_attempt['snapshot']['sources']}
    assert verified(oracle_attempt['base'])['sha256'] == base['sha256']
    host_equality = []
    for source in source_files:
        relative = str(source.relative_to(snapshot))
        previous = verified(oracle_frozen[relative])
        current = verified(frozen[str(source)])
        assert current['sha256'] == previous['sha256'], ('host/runtime drift', relative)
        host_equality.append(dict(relative=relative, previous=previous, current=current))
    assert {str(p.relative_to(snapshot/'src/runtime/native')) for p in source_files if p.is_relative_to(snapshot/'src/runtime/native')} == {str(p.relative_to(oracle_snapshot/'src/runtime/native')) for p in (oracle_snapshot/'src/runtime/native').rglob('*') if p.is_file()}
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
    cases = {}
    for path in args.acquired:
        acquisition = pin(path)
        report = read(path)
        assert report['complete']
        recipe_pin = verified(report['recipe'])
        recipe = read(recipe_pin['file'])
        assert Path(recipe['api']).resolve() == Path(oracle_api['file']).resolve()
        assert recipe['upstreamCommit'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
        for record in report['records']:
            if record['role'] != 'selfhost':
                continue
            case = record['case']
            assert case not in cases, ('duplicate acquired case', case)
            assert record['correct']
            for phase in ['emission', 'toolchain', 'process']:
                assert record[phase]['complete'] and record[phase]['returncode'] == 0
            source = verified(record['source'])
            emitted_pin = verified(record['emissionReceipt'])
            emitted = read(emitted_pin['file'])
            assert emitted['complete'] and emitted['role'] == 'selfhost' and emitted['target'] == 'c'
            assert emitted['observation']['status'] == 'ok' and emitted['observation']['checked']
            assert verified(emitted['input']) == source
            assert verified(emitted['recipe']) == recipe_pin
            code = verified(record['nativeSource'])
            assert verified(emitted['output']) == code
            assert any(verified(item) == oracle_api for item in emitted['compiler'])
            for key in ['inputs', 'programInputs', 'effectInputs', 'compiler']:
                for item in emitted[key]: verified(item)
            for item in emitted['effectInputs'] + emitted['compiler']:
                original = Path(item.get('path', item.get('file'))).resolve()
                if original.is_relative_to(ROOT/'selfhost/src') or original.is_relative_to(ROOT/'selfhost/tools'):
                    relative = str(original.relative_to(ROOT/'selfhost'))
                    assert verified(item)['sha256'] == verified(oracle_frozen[relative])['sha256'], ('acquired runtime/host drift', relative)
            assert {str(Path(p).resolve()) for p in emitted['observation']['files']} == {item['path'] for item in emitted['inputs']}
            executable = verified(record['executable'])
            cases[case] = dict(input=source, expected=dict(b1=code, b2=code),
                nativeOracleEvidence=emitted_pin, acquisition=acquisition,
                expectedRuntime=record['expected'], validatedExecutable=executable, recipe=recipe_pin)
    assert len(cases) == args.expected_cases, ('case count', len(cases), args.expected_cases)
    jobs = [dict(name='prepare-'+role, role=role, action='prepare', profile=False) for role in ['b1','b2']]
    for index, case in enumerate(cases):
        order = ['b1', 'b2'] if index % 2 == 0 else ['b2', 'b1']
        for role in order:
            jobs.append(dict(name=f'clean-identity-{case}-{role}', action='request', role=role,
                case=case, profile=False, round=0, qualificationOnly=True))
    plan = dict(kind='phase68-native-compilation-plan', version=6, status='prepared-unexecuted', qualificationOnly=True, expectedCases=args.expected_cases,
        predecessorMethod=pin(ROOT/'selfhost/tools/performance/phase68/compilation/prepare-selected-v1.py'), oracleAttempt=oracle_pin, oracleApi=oracle_api,
        attempt=attempt_pin, imagePins=b2_pin, hostRuntimeEquality=host_equality, copies=copies, roles=roles, cases=cases, jobs=jobs,
        cpu=3, nodeArgs=['--max-old-space-size=1024','--stack-size=4096'], seconds=90,
        rssMiB=2048, availableMiB=4096, inputs=list(inputs.values()),
        scope='Qualification only, not a new timing campaign. Fresh checked B1 and genuine B2 each emit every validated prior program through unchanged checked worker. Complete C bytes must match the explicitly owned prior oracle. Source, effects, host runtime, independent acquisition and executable identities remain pinned. No Clang/runtime is repeated for byte-identical C; historical clocks remain attributed to their original compiler acquisition. Two private prepared Bases and one request per case per stage. Compiler latency requires a separate balanced comparison.')
    path = out/'plan.json'
    path.write_text(json.dumps(plan, indent=2)+'\n')
    print(json.dumps(dict(plan=pin(path), jobs=len(jobs), roles=list(roles))))


if __name__ == '__main__':
    main()
