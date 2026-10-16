#!/usr/bin/env python3
"""Freeze fresh authority controls against an already checked candidate API; no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def read(path): return json.loads(Path(path).read_text())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--api-report', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase102') and not out.exists()
    out.mkdir(parents=True)
    inputs = {}
    def bind(value):
        actual = pin(value['file'] if isinstance(value, dict) else value)
        if isinstance(value, dict): assert actual == value
        assert inputs.setdefault(actual['file'], actual) == actual
        return actual
    def tree(value):
        if isinstance(value, list):
            for x in value: tree(x)
        elif isinstance(value, dict):
            if {'file', 'sha256', 'bytes'} <= value.keys(): bind(value)
            else:
                for x in value.values(): tree(x)
    api_pin = bind(a.api_report); api = read(api_pin['file'])
    assert api['complete'] and not api.get('error'); tree(api)
    required = {'nc_compile_checked', 'nr_compile_prepared', 'nr_prepare', 'nc_compile', 'nc_foreign_paths'}
    assert required <= set(api['exports'])
    recipe = read(api['recipe']['file']); tree(recipe)
    assert recipe['candidate'] == api['source']
    original = Path(recipe['source']['file']).read_text(); text = original
    for edit in recipe['changes']:
        at, old, new = edit['offset'], edit['old'], edit['new']
        assert text[at:at+len(old)] == old
        text = text[:at] + new + text[at+len(old):]
    assert text == Path(api['source']['file']).read_text()
    for edit in reversed(recipe['changes']):
        at, old, new = edit['offset'], edit['old'], edit['new']
        assert text[at:at+len(new)] == new
        text = text[:at] + old + text[at+len(new):]
    assert text == original
    historical_report = bind(ROOT / 'selfhost/build/phase98/observer-permission-qualify05/report.json')
    historical = read(historical_report['file']); tree(historical)
    assert historical['complete'] and historical['inputsUnchanged'] and historical['fullPrograms'] == 7
    original_plan = bind(historical['plan']); old = read(original_plan['file']); tree(old)
    parent_method = bind(ROOT / 'selfhost/tools/performance/phase98/observer-permission/qualify-v2.mjs')
    successor_method = bind(HERE / 'authority.mjs')
    before = Path(parent_method['file']).read_text(); after = Path(successor_method['file']).read_text()
    expected = before.replace('// Root-run finite admission and tiny native emission; no child processes here.',
        '// Phase102 fresh authority/raw boundary replay. Original Phase98 assertions unchanged.\n'
        '// Empty finite-certificate list is intentional: exact source closure is inherited separately.\n'
        '// Root executes serially; this emits C but launches no native child programs.')
    expected = expected.replace("out.startsWith(root+'/selfhost/build/phase98/')", "out.startsWith(root+'/selfhost/build/phase102/')")
    assert after == expected
    plan = {**old, 'kind': 'phase102-authority-inputs', 'method': bind(__file__),
        'recipe': api['recipe'], 'cases': [],
        'apis': {'baseline': old['apis']['candidate'], 'candidate': api['api']['file']},
        'sourceInputs': {'baseline': old['sourceInputs']['candidate'], 'candidate': api['source']},
        'apiAcquisition': api_pin, 'historicalQualification': historical_report, 'historicalPlan': original_plan,
        'parentMethod': parent_method, 'executionMethod': successor_method,
        'scope': 'Fresh exact final-source checked API permission, provider-mutation and raw-input refusal checks. '
                 'Historical comparison API is the actual Phase98 permission experiment API, not relabeled as the installed compiler. '
                 'No new finite permission certificate runs, native program execution, native image admission or proof claim.'}
    tree(plan)
    (out / 'plan.json').write_text(json.dumps(plan, indent=2) + '\n')
    plan_pin = bind(out / 'plan.json')
    for row in inputs.values(): assert pin(row['file']) == row
    result = dict(complete=True, targetsRun=False, source=api['source'], api=api['api'],
        plan=plan_pin, method=bind(__file__), inputs=list(inputs.values()), inputsUnchanged=True,
        command=[api['node']['file'], '--stack-size=16384', '--max-old-space-size=1536',
                 successor_method['file'], plan_pin['file'], str(out / 'emission')],
        targetGuard=dict(seconds=180, rssMiB=2048, availableMiB=4096, cpu=3))
    (out / 'prepared.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, plan=plan_pin, command=result['command'])))


if __name__ == '__main__': main()
