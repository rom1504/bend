#!/usr/bin/env python3
"""Exact table01 + packed-Take1 source admission; no compiler or targets."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
INVENTORY_SHA = '7f2879103f37f9cdffa5f51ebb0a5e1498e77e54b9f9c3f0530213e686ef9456'
HELPER_SHA = '3a589881be41a0aa655414a465c63feab7a94c88ecbfe19631276fea74da6187'


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def authenticate(row, inputs):
    if pin(row['file']) != row:
        raise ValueError('changed frozen input: ' + row['file'])
    inputs[row['file']] = row


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', type=Path, required=True)
    ap.add_argument('--api-report', type=Path, required=True)
    ap.add_argument('--runtime-source', type=Path, required=True)
    ap.add_argument('--runtime-object', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase114'):
        raise ValueError('fresh Phase114 output required')
    method = pin(HERE.parent / 'packing/admit.py')
    if method['sha256'] != HELPER_SHA:
        raise ValueError('declaration helper changed')
    helpers = runpy.run_path(method['file'])
    inventory_pin = pin(HERE / 'modules01.json')
    if inventory_pin['sha256'] != INVENTORY_SHA:
        raise ValueError('source inventory changed')
    inventory = json.loads(Path(inventory_pin['file']).read_text())
    inputs = {method['file']: method, inventory_pin['file']: inventory_pin}
    for row in [inventory['base'], inventory['baseAdmission'], inventory['runtimeSource'],
                inventory['runtimeObject'], inventory['runtimeHeader'], inventory['ordinaryControls'],
                inventory['controls'], *inventory['modules']]:
        authenticate(row, inputs)
    parent = json.loads(Path(inventory['baseAdmission']['file']).read_text())
    if not parent.get('complete') or not parent.get('admitted'):
        raise ValueError('parent admission incomplete')
    for key, expected in [('compiler', inventory['base']), ('runtimeSource', inventory['runtimeSource']),
                          ('runtimeObject', inventory['runtimeObject'])]:
        if parent[key] != expected:
            raise ValueError('parent mismatch: ' + key)
    for row in parent['inputs']:
        authenticate(row, inputs)
    runtime, obj = pin(args.runtime_source), pin(args.runtime_object)
    if runtime != inventory['runtimeSource'] or obj != inventory['runtimeObject']:
        raise ValueError('exact runtime source/object required')
    expected = helpers['declarations'](Path(inventory['base']['file']).read_text())
    original_verify = expected['def', 'p113a_verify']
    allowed, used = set(inventory['overrides']), set()
    for row in inventory['modules']:
        for key, body in helpers['declarations'](Path(row['file']).read_text()).items():
            if key in expected:
                if key[0] != 'def' or key[1] not in allowed or key[1] in used:
                    raise ValueError('unexpected/repeated override: ' + key[1])
                used.add(key[1])
            expected[key] = body
    if used != allowed:
        raise ValueError('missing override')
    if expected['def', 'p114pk_original_verify'] != original_verify.replace(
            'def p113a_verify(', 'def p114pk_original_verify(', 1):
        raise ValueError('original final verifier changed')
    helpers['validate'](helpers['declarations'](args.compiler.read_text()), expected)
    compiler = pin(args.compiler)
    checked = json.loads(args.api_report.read_text())
    if not checked.get('complete') or not checked.get('checked') or checked.get('status') != 0:
        raise ValueError('successful checked API required')
    if compiler not in checked['inputs']:
        raise ValueError('checked compiler mismatch')
    authenticate(checked['api'], inputs)
    for name in ['p113a_lower_request', 'p113a_verify', 'p113a_admitted_chunks', *inventory['exports']]:
        if name not in checked['exports']:
            raise ValueError('missing checked export: ' + name)
    for row in [compiler, pin(args.api_report), pin(__file__)]:
        inputs[row['file']] = row
    result = dict(kind='phase114-packed-take-admission', version=1, complete=True,
        admitted=True, targetsExecuted=False, compiler=compiler, checkedApi=checked['api'],
        checkedApiReceipt=pin(args.api_report), runtimeSource=runtime, runtimeObject=obj,
        inventory=inventory_pin, method=pin(__file__), parentAdmission=inventory['baseAdmission'],
        modules=inventory['modules'], exactDeclarations=len(expected), inputs=list(inputs.values()),
        executionContract=inventory['executionContract'],
        limitation='Source/runtime composition only. Original verification and ordinary native gates '
                   'remain required; no arbitrary reflected ownership/separation proof or performance claim.')
    out.mkdir(parents=True)
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, declarations=len(expected))))


if __name__ == '__main__':
    main()
