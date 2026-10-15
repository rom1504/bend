#!/usr/bin/env python3
"""Checked upstream-JS sibling: exact same Bend IO entry, without a C build."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PERF = ROOT / 'selfhost/tools/performance'
sys.path.insert(0, str(PERF / 'phase88'))
from native_support import authenticate, DEFAULT_CACHE, native_args, pin, verify, require


def read(path):
    return json.loads(Path(path).read_text())


def transport_definitions(text):
    starts = list(re.finditer(r'(?m)^(?:@unsafe\n)?(?:def|law|type) ([A-Za-z0-9_.]+)', text))
    definitions = {}
    for index, start in enumerate(starts):
        name = start[1]
        if (name.startswith(('p86_', 'p88_', 'P88_'))
                and not name.startswith(('p88_string_eq', 'p88_string_order'))):
            stop = starts[index + 1].start() if index + 1 < len(starts) else len(text)
            key = start[0]
            require(key not in definitions, 'Duplicate transport definition')
            definitions[key] = text[start.start():stop].rstrip()
    require(any('p86_cli' in key for key in definitions), 'Missing IO entry')
    return definitions


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('acquisition', type=Path, help='Completed phase90 checked acquisition report')
    parser.add_argument('out', type=Path, help='Fresh output directory')
    parser.add_argument('--compat-equality', action='store_true', help='Explicit existing primitive String.eq compatibility derivative')
    parser.add_argument('--self-source', action='store_true')
    parser.add_argument('--self-seconds', type=int, choices=[60, 120, 180], default=120)
    parser.add_argument('--calls', type=int, choices=[1, 5], default=1)
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    inputs = {}
    def bound(value):
        actual = verify(value)
        require(inputs.setdefault(actual['file'], actual) == actual, 'Conflicting artifact identity')
        return actual
    def add(path):
        return bound(pin(path))
    def tree(value):
        if isinstance(value, dict):
            if 'sha256' in value and 'bytes' in value and ('file' in value or 'path' in value):
                bound(value)
            else:
                for child in value.values(): tree(child)
        elif isinstance(value, list):
            for child in value: tree(child)
    def unchanged():
        for value in inputs.values(): verify(value)

    acquisition = read(args.acquisition)
    require(acquisition['kind'] == 'phase90-checked-upstream-native-source-derivative'
            and acquisition['complete'] and acquisition['inputsUnchanged'] and acquisition['holes'] == 0
            and acquisition['upstream'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
            and {'load', 'check', 'emit-js', 'emit-c'} <= {p['name'] for p in acquisition['phases']},
            'Expected completed checked Phase90 acquisition')
    require(acquisition['method']['sha256'] == '4acddb595b6359d489b19ab1d59af710d21199f22d3db410249bdad2b9bb55e8', 'Unknown acquisition method')
    add(args.acquisition)
    tree(acquisition['inputs'])
    for key in ['method', 'source', 'js', 'node', 'derivation']: bound(acquisition[key])
    source, image, node = acquisition['source'], acquisition['js'], acquisition['node']
    derivative = read(acquisition['derivation']['file'])
    tree(derivative['inputs']); bound(derivative['output'])
    require(derivative['kind'] == 'phase90-native-source-assembly' and derivative['complete']
            and derivative['exactOutsideDefinitions'] and not derivative['acquisitionComplete'], 'Wrong source derivation')
    original = Path(derivative['inputs'][0]['file']).read_text()
    require(derivative['inputs'][0]['sha256'] == '4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618', 'Wrong frozen ancestor')
    forward = original
    for change in derivative['replacements']:
        require(bool(change['old']) and forward.count(change['old']) == 1, 'Ambiguous source replacement')
        forward = forward.replace(change['old'], change['new'], 1)
    require(forward == Path(source['file']).read_text() == Path(derivative['output']['file']).read_text(), 'Source replay differs')
    for change in reversed(derivative['replacements']):
        require(bool(change['new']) and forward.count(change['new']) == 1, 'Ambiguous reverse replacement')
        forward = forward.replace(change['new'], change['old'], 1)
    require(forward == original, 'Source inverse differs')

    gate_path = ROOT / 'selfhost/build/phase90/native-gates01/gates.json'
    gate = read(gate_path); add(gate_path)
    require(gate['kind'] == 'phase90-combined-native-b1-gates' and gate['complete']
            and gate['passed'] and gate['executionPerformed'] and len(gate['rows']) == 8
            and all(r['passed'] and r['exactC'] for r in gate['rows']), 'Missing same-entry reference gates')
    tree(gate['inputs']); tree(gate['nineEffects'])
    for key in ['source', 'assets', 'method', 'derivation']: bound(gate[key])
    require(gate['assets']['sha256'] == '1894cef9f71d674507aa671cd5c24730ce221b23df7ca0f9675949336671ba2b'
            and len(gate['nineEffects']) == 9, 'Wrong effect proof')
    require(transport_definitions(Path(source['file']).read_text()) ==
            transport_definitions(Path(gate['source']['file']).read_text()), 'IO entry or carrier decoder changed')
    assets = authenticate(ROOT / 'selfhost/build/phase88/compiler-native02', DEFAULT_CACHE)
    require(assets['cache'] == gate['cacheOrigin'], 'Different cache producer/binding')
    tree(assets)
    methods = [__file__, PERF / 'phase86/node-files.cjs', PERF / 'phase86/js-compat.mjs',
               PERF / 'phase86/guard.py', PERF / 'programs/support.py', PERF / 'phase88/native_support.py', sys.executable]
    for path in methods: add(path)
    unchanged()
    if args.check_only:
        print(json.dumps(dict(complete=True, targetExecuted=False, inputs=len(inputs),
            source=source, js=image, role='upstream-generated JS sibling of the Bend IO compiler')))
        return

    out = args.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    report = dict(kind='phase90-same-entry-js-screen', complete=False, inputs=list(inputs.values()),
        source=source, rawJs=image, mode='raw-upstream-js', nativeExecution=False, nativeB2=False,
        inputsUnchanged=False, cacheProducer=assets['cache'], rows=[])
    removed = [key for key in os.environ if key.startswith('BEND_') or key == 'NODE_OPTIONS']
    environment = {key: value for key, value in os.environ.items() if key not in removed}
    report['removedEnvironment'] = removed
    def save():
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    save()
    try:
        if args.compat_equality:
            subprocess.run([node['file'], str(PERF / 'phase86/js-compat.mjs'),
                            str(args.acquisition.resolve().parent), str(out / 'compat')], check=True, env=environment)
            compatibility = read(out / 'compat/derivation.json')
            require(compatibility['parent'] == image, 'Wrong compatibility parent')
            expected = Path(image['file']).read_text()
            require(expected.count(compatibility['old']) == 1, 'Ambiguous primitive guard')
            expected = expected.replace(compatibility['old'], compatibility['old'].replace('\n', '\n' + compatibility['guard'], 1), 1)
            image = add(out / 'compat/compiler.cjs')
            require(Path(image['file']).read_text() == expected, 'Unexpected compatibility changes')
            add(out / 'compat/derivation.json')
            report.update(mode='explicit-primitive-equality-compatibility', compatibility=compatibility)
        report.update(js=image, inputs=list(inputs.values())); save()
        cases = {c['name']: c for c in gate['oracleCases']}
        jobs = [(mode + '-' + name, cases[name]['source'], mode, args.calls, 60, cases[name]['oracle'])
                for mode in ['live', 'cached'] for name in ['small', 'map_closed']]
        if args.self_source: jobs.append(('self-source', source, 'cached', 1, args.self_seconds, None))
        for name, request, mode, calls, seconds, oracle in jobs:
            unchanged()
            producer = dict(assets, cache=assets['cache'] if mode == 'cached' else None)
            prefix, guard = out / name, out / (name + '-guard')
            # Reuse only the original six/eight transport arguments; Node's CLI
            # supplies the JS script head that p86_cli deliberately drops.
            payload = native_args(producer, request['file'], prefix, calls)[6:]
            command = [node['file'], '--max-old-space-size=1024', '--stack-size=4096',
                       '--require', str(PERF / 'phase86/node-files.cjs'), image['file'], *payload]
            row = dict(name=name, source=request, mode=mode, command=command, passed=False)
            report['rows'].append(row); save()
            job = subprocess.run([sys.executable, '-B', str(PERF / 'phase86/guard.py'), '--out', str(guard),
                '--seconds', str(seconds), '--cpu', '3', '--', *command], capture_output=True, text=True, env=environment)
            process = read(guard / 'process.json')
            outputs = [pin(Path(str(prefix) + f'.{i}.c')) for i in range(1, calls + 1) if Path(str(prefix) + f'.{i}.c').exists()]
            row.update(process=process, outputs=outputs, guardReturncode=job.returncode,
                requestMs=list(map(int, re.findall(r'request=\d+ request_ms=(\d+)', (guard / 'stderr.log').read_text()))))
            save()
            require(job.returncode == 0 and process['complete'] and process['returncode'] == 0
                    and len(outputs) == len(row['requestMs']) == calls, 'Sibling emission failed; preserve this attempt')
            if oracle:
                row['exactC'] = all(item[k] == oracle[k] for item in outputs for k in ['sha256', 'bytes'])
                require(row['exactC'], 'Complete C oracle mismatch')
            else:
                row.update(exactC=None, independentlyQualified=False)
            row['passed'] = True; save()
        report['complete'] = True
    except Exception as error:
        report['error'] = str(error)
        raise
    finally:
        try:
            unchanged(); report['inputsUnchanged'] = True
        except Exception as error:
            report.update(complete=False, inputsUnchanged=False, changedInputError=str(error))
        save()
        require(report['inputsUnchanged'], 'Inputs changed; reject this attempt')


if __name__ == '__main__':
    main()
