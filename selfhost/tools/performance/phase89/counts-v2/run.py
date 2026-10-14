#!/usr/bin/env python3
"""Run an explicitly bound counter derivative; never admit a production image."""
import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
P = ROOT / 'selfhost/tools/performance'
sys.path.insert(0, str(P / 'phase88'))
from broad import guard, save
from native_support import authenticate, native_args, DEFAULT_CACHE, pin, verify, require

BASELINE = ROOT / 'selfhost/build/phase88/screen01/report.json'
ANALYZER = P / 'phase89/counts/analyze.py'
ASSETS = ['base', 'runtime', 'runtimeParts', 'template', 'effectsDir', 'effects']


def read(path):
    return json.loads(Path(path).read_bytes())


def collect_pins(value):
    if isinstance(value, dict):
        if 'sha256' in value and ('file' in value or 'path' in value):
            yield verify(value)
        else:
            for child in value.values():
                yield from collect_pins(child)
    elif isinstance(value, list):
        for child in value:
            yield from collect_pins(child)


def command_ends(process, command):
    require(process.get('complete') is True and process.get('returncode') == 0,
            'Incomplete or failed guarded process')
    require(process['command'][-len(command):] == command, 'Guard command does not bind the expected request')


def validate_parent(image, live_path, names):
    """Read-only preflight, callable before a diagnostic binary exists."""
    old = authenticate(ROOT / 'selfhost/build/phase88/compiler-native02', DEFAULT_CACHE)
    parent = authenticate(image, None)
    require(all(parent[k] == old[k] for k in ASSETS), 'Parent external assets differ from authenticated baseline')
    live = read(live_path)
    require(live.get('complete') is True and live.get('passed') is True and live['new'] == parent,
            'Live gate does not qualify this clean parent image')
    require(live['old'] == old, 'Live gate baseline/cache binding changed')
    require(len(live['live']) == 3 and {r['case'] for r in live['live']} == {'small', 'map_closed', 'unicode'},
            'Expected the three clean-parent live controls')
    baseline = read(BASELINE)
    require(baseline.get('complete') is True and baseline.get('allJobsSucceeded') is True,
            'Incomplete independent B2 oracle acquisition')
    inputs = [pin(live_path), pin(BASELINE), verify(live['method'])]
    cases = {}
    for name in dict.fromkeys([*names, 'small', 'map_closed', 'unicode']):
        source = verify(live['sourcePins'][name])
        require(source == pin(baseline['cases'][name]), 'Live source differs from oracle source: ' + name)
        rows = [r for r in baseline['rows'] if r['case'] == name and r['role'] == 'b2']
        require(len(rows) == 1 and len(rows[0]['outputs']) == 1, 'Ambiguous oracle: ' + name)
        row = rows[0]
        require(row['guard'].get('complete') is True and row['guard'].get('returncode') == 0
                and source['file'] in row['guard']['command'], 'Failed or unbound oracle: ' + name)
        historical = row['outputs'][0]
        retained = [historical] + [o for r in live['live'] + live['rows']
                                  if r['case'] == name and r['exact'] and r['job']['pass_']
                                  for o in r['outputs']]
        available = [v for v in retained if Path(v.get('file', v.get('path'))).is_file()
                     and (v['sha256'], v['bytes']) == (historical['sha256'], historical['bytes'])]
        require(available, 'No retained complete C matches the historical B2 oracle: ' + name)
        oracle = verify(available[0])
        cases[name] = dict(source=source, oracle=oracle, historicalOracle=historical)
        inputs.extend([source, oracle])
    for row in live['live']:
        require(row['exact'] is True and row['job']['pass_'] is True and len(row['outputs']) == 1,
                'Failed clean-parent live control')
        output = verify(row['outputs'][0])
        oracle = cases[row['case']]['oracle']
        require((output['sha256'], output['bytes']) == (oracle['sha256'], oracle['bytes']),
                'Live C differs from independent B2 oracle')
        require(output['file'].endswith('.1.c'), 'Unexpected live output name')
        command = native_args(parent, cases[row['case']]['source']['file'], output['file'][:-4], 1)
        process_path = Path(row['job']['guard']) / 'process.json'
        command_ends(read(process_path), command)
        inputs.extend([output, pin(process_path)])
    inputs.extend(collect_pins(old))
    inputs.extend(collect_pins(parent))
    return old, parent, cases, inputs


def validate_diagnostic(a, parent):
    derivation = read(a.derivation)
    require(derivation.get('complete') is True and derivation.get('schema') == 2
            and derivation.get('kind') == 'phase89-31-counter-diagnostic-derivative'
            and derivation.get('inverseRecoversSource') is True
            and derivation.get('boundaryBytes') == 1024, 'Wrong diagnostic derivation')
    require(derivation['upstream'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
            and verify(derivation['acquisition']) == parent['checked']
            and verify(derivation['source']) == parent['c'], 'Diagnostic is not derived from this checked parent')
    require(len(derivation['fields']) == len(set(derivation['fields'])) == 31
            and 'match_joins' not in derivation['fields'], 'Wrong diagnostic counter schema')
    require(verify(derivation['method']) == pin(Path(__file__).with_name('instrument.py'))
            and verify(derivation['header']) == pin(Path(__file__).with_name('counters.h')),
            'Diagnostic does not bind this reviewed instrumenter/header')
    image = pin(a.image)
    require(image['sha256'] == a.image_sha256, 'Diagnostic binary differs from explicit pin')
    process_path = a.build_guard / 'process.json'
    inputs_path = a.build_guard / 'inputs.json'
    process, bound = read(process_path), read(inputs_path)
    require(process.get('complete') is True and process.get('returncode') == 0, 'Failed diagnostic build')
    build_inputs = [verify(record) for record in bound]
    source = verify(derivation['output'])
    require(source in build_inputs, 'Instrumented C absent from guarded build inputs')
    command = process['command']
    require(command.count('-o') == 1 and str((ROOT / command[command.index('-o') + 1]).resolve()) == image['file'],
            'Build command output does not bind diagnostic image')
    source_args = [str((ROOT / arg).resolve()) for arg in command if arg.endswith('.c')]
    require(source_args == [source['file']], 'Build command does not bind only this instrumented C')
    require(any(v['file'] in command and Path(v['file']).name == 'clang' for v in build_inputs),
            'Build compiler identity missing from command/inputs')
    inputs = [pin(a.derivation), image, pin(process_path), pin(inputs_path), *build_inputs]
    inputs.extend(collect_pins(derivation))
    return derivation, image, inputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('out', type=Path)
    parser.add_argument('--parent-image', required=True, type=Path)
    parser.add_argument('--derivation', required=True, type=Path)
    parser.add_argument('--build-guard', required=True, type=Path)
    parser.add_argument('--image', required=True, type=Path)
    parser.add_argument('--image-sha256', required=True)
    parser.add_argument('--live-evidence', required=True, type=Path)
    parser.add_argument('--cases', default='map_closed,lexer_original,numeric_closed')
    parser.add_argument('--calls', type=int, choices=[1, 5], default=5)
    parser.add_argument('--check-only', action='store_true', help='Validate inputs and commands; execute/write nothing')
    a = parser.parse_args()
    names = a.cases.split(',')
    require(names and len(set(names)) == len(names) and all(names), 'Cases must be distinct and nonempty')
    old, parent, cases, inputs = validate_parent(a.parent_image, a.live_evidence, names)
    derivation, image, diagnostic_inputs = validate_diagnostic(a, parent)
    inputs.extend(diagnostic_inputs)
    inputs.extend(pin(p) for p in [__file__, ANALYZER, P / 'phase88/native_support.py',
                                  P / 'phase88/broad.py', P / 'phase86/guard.py', sys.executable])
    unique = {}
    for item in inputs:
        require(item['file'] not in unique or unique[item['file']] == item, 'Conflicting input identities')
        unique[item['file']] = item
    inputs = list(unique.values())
    auth = dict(parent, image=image, cache=old['cache'])  # Diagnostic substitution only.
    out = a.out.resolve()
    commands = {name: native_args(auth, cases[name]['source']['file'], out / name, a.calls) for name in names}
    if a.check_only:
        print(json.dumps(dict(complete=True, diagnosticOnly=True, image=image, inputs=len(inputs), commands=commands)))
        return
    out.mkdir(parents=True, exist_ok=False)
    report = dict(complete=False, passed=False, kind='phase89-31-counter-run', parent=parent,
                  authenticatedBaseline=old, inputs=inputs, calls=a.calls, cases=names, rows=[],
                  limitation='Explicit diagnostic derivative with experimental carrier reuse after parent live gates; no public cache admission or timing/promotion claim.')
    save(out / 'report.json', report)
    try:
        for name in names:
            case = cases[name]
            verify(case['source'])
            prefix = out / name
            command = commands[name]
            row = dict(case=name, source=case['source'], oracle=case['oracle'],
                       historicalOracle=case['historicalOracle'], command=command)
            report['rows'].append(row)
            save(out / 'report.json', report)
            row['job'] = guard(Path(str(prefix) + '-guard'), command, 90)
            outputs = [pin(Path(str(prefix) + f'.{i}.c')) for i in range(1, a.calls + 1)
                       if Path(str(prefix) + f'.{i}.c').exists()]
            row.update(outputs=outputs, exact=len(outputs) == a.calls and all(
                (o['sha256'], o['bytes']) == (case['oracle']['sha256'], case['oracle']['bytes']) for o in outputs))
            save(out / 'report.json', report)
            require(row['job']['pass_'] and row['exact'], 'Diagnostic target/output failed; evidence retained')
            process_path = Path(row['job']['guard']) / 'process.json'
            command_ends(read(process_path), command)
            row['process'] = pin(process_path)
            counts = out / f'{name}-counts.json'
            subprocess.run([sys.executable, '-B', str(ANALYZER),
                            str(Path(row['job']['guard']) / 'stderr.log'), str(counts)], check=True)
            parsed = read(counts)
            require(parsed['complete'] is True and len(parsed['phases']) == a.calls + 2
                    and set(parsed['finalCounts']) == set(derivation['fields']), 'Unexpected parsed counter schema')
            row['counts'] = pin(counts)
            verify(case['source'])
            save(out / 'report.json', report)
        require(authenticate(a.parent_image, None) == parent, 'Parent authentication changed during run')
        require(authenticate(ROOT / 'selfhost/build/phase88/compiler-native02', DEFAULT_CACHE) == old,
                'Baseline/cache authentication changed during run')
        report.update(complete=True, passed=True)
    except Exception as error:
        report['error'] = str(error)
        raise
    finally:
        changed = []
        for item in inputs:
            try:
                verify(item)
            except Exception as error:
                changed.append(dict(input=item, error=str(error)))
        report['inputsUnchanged'] = not changed
        if changed:
            report.update(complete=False, passed=False, changedInputs=changed)
        save(out / 'report.json', report)
        require(not changed, 'Inputs changed during diagnostic; evidence retained')


if __name__ == '__main__':
    main()
