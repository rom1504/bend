#!/usr/bin/env python3
"""Data-only portable join of actual Reuse11 helpers and complete C equality."""
import argparse
import hashlib
import json
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
RAW = ROOT/'selfhost/build/phase68'
inputs = {}


def pin(value):
    expected = value if isinstance(value, dict) else None
    p = Path(expected.get('file', expected.get('path')) if expected else value).resolve(strict=True)
    data = p.read_bytes()
    result = dict(file=str(p), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert result['sha256'] == expected['sha256']
        assert 'bytes' not in expected or result['bytes'] == expected['bytes']
    inputs[str(p)] = result
    return result


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def verify_pins(value):
    if isinstance(value, dict):
        if 'sha256' in value and ('file' in value or 'path' in value):
            pin(value)
        else:
            for item in value.values():
                verify_pins(item)
    elif isinstance(value, list):
        for item in value:
            verify_pins(item)


ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('--out', type=Path, required=True)
args = ap.parse_args()
assert not args.out.exists()
method = pin(__file__)
proposal_pin = pin(HERE/'candidate-v2.json')
proposal = read(proposal_pin)
verify_pins(proposal)
attempt_pin = pin(RAW/'reuse-build11/attempt.json')
attempt = read(attempt_pin)
for row in attempt['snapshot']['sources']:
    pin(row['frozen'])
for key in ['api', 'checkedApi', 'bootstrapReport', 'derivationReport', 'base', 'runtime', 'node', 'artifacts']:
    verify_pins(attempt[key])
assert attempt['checked'] and attempt['config']['strictExact'] and attempt['artifactKind'] == 'derived-b1'
strict_pin = pin(RAW/'reuse-build11/validation-001/report.json')
strict = read(strict_pin)
assert strict['complete'] and strict['pass']
controls_pin = pin(RAW/'reuse-controls11/report.json')
controls = read(controls_pin)
verify_pins(controls)
assert controls['complete'] and controls['pass'] and controls['inputsUnchanged']
assert pin(controls['method']) == pin(HERE/'controls-v2.mjs')
assert pin(controls['proposal']) == proposal_pin
images = {x['role']: x for x in controls['images']}
assert pin(images['candidate']['attempt']) == attempt_pin
assert pin(images['candidate']['api']) == pin(attempt['api'])
assert pin(images['baseline']['attempt']) == pin(proposal['baselineAttempt'])
for image in images.values():
    assert Path(image['derived']['file']).read_bytes() == (
        Path(image['api']['file']).read_bytes()+image['append'].encode())
helper_rows = [r for r in controls['rows'] if 'baseline' in r]
product_rows = [r for r in controls['rows'] if 'productCase' in r]
assert len(helper_rows) == 3520 and len(product_rows) == 4
assert all(row['pass'] for row in controls['rows'])
totals = {role:dict(Counter({k:sum(row[role][k] for row in helper_rows)
                            for k in ['body', 'value', 'total']}))
          for role in ['baseline', 'candidate']}
assert totals['baseline'] == dict(body=7360, value=4640, total=15544)
assert totals['candidate'] == dict(body=3880, value=2640, total=9350)
helper_guard = read(RAW/'reuse-controls11-supervisor/process.json')
assert helper_guard['complete'] and helper_guard['returncode'] == 0
c_plan_pin = pin(RAW/'reuse-c11/plan.json')
c_plan = read(c_plan_pin)
verify_pins(c_plan)
assert pin(c_plan['attempt']) == attempt_pin
c_report_pin = pin(RAW/'reuse-c11/report.json')
c_report = read(c_report_pin)
assert c_report['complete'] and c_report['pass_'] and len(c_report['rows']) == 3
c_rows = []
for job in c_plan['jobs']:
    matches = [r for r in c_report['rows'] if r['case'] == job['case']]
    assert len(matches) == 1 and matches[0]['fullCEqual'] and matches[0]['returncode'] == 0
    row = matches[0]
    output, baseline = pin(job['output']), pin(job['baselineIdentity'])
    assert output['sha256'] == baseline['sha256']
    emission_pin = pin(job['output']+'.json')
    emission = read(emission_pin)
    verify_pins(emission)
    assert emission['complete'] and pin(emission['output']) == output
    assert pin(emission['compiler'][0]) == pin(attempt['api'])
    assert pin(emission['recipe']) == pin(c_plan['recipe'])
    baseline_emission = read(job['baselineEmission'])
    assert baseline_emission['complete']
    assert pin(baseline_emission['output']) == baseline
    assert pin(baseline_emission['compiler'][0]) == pin(proposal['baselineApi'])
    guard = read(Path(job['output']).parent/'supervisor/process.json')
    assert guard['complete'] and guard['returncode'] == 0
    assert guard['command'] == ['taskset', '-c', '3']+job['command'][job['command'].index('--')+1:]
    c_rows.append(dict(case=job['case'], output=output, baseline=baseline,
        baselineEmission=pin(job['baselineEmission']), emission=emission_pin,
        baselineRequestMs=baseline_emission['timings']['loadCheckEmitMs'],
        candidateRequestMs=emission['timings']['loadCheckEmitMs']))
result = dict(kind='phase68-local-occurrence-reuse11-audit', complete=True,
    dataOnly=True, targetExecuted=False, method=method, proposal=proposal_pin,
    attempt=attempt_pin, api=pin(attempt['api']), strict=strict_pin,
    controls=controls_pin, helperSummary=controls['summary'], collectorCalls=totals,
    helperWallSeconds=helper_guard['wallSeconds'], cPlan=c_plan_pin, cReport=c_report_pin,
    wholeC=c_rows, lineDelta=6, newTypes=0, newFunctions=0,
    scope='Finite actual B1 helper equality and three entire-C equalities. Acquisition request clocks are separate single observations, not balanced performance estimates. No genuine B2, broad conformance or production selection claim.',
    inputs=list(inputs.values()))
result['pass'] = True
args.out.parent.mkdir(parents=True, exist_ok=True)
args.out.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(pin(args.out)))
