#!/usr/bin/env python3
"""Authenticate an exact Phase114 composition; run no compiler or target."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PHASE = HERE.parent
BASE_SHA = '287c85558f3eb40d5576b51a4f7c0238100a9c4c93fc36ee52e3b8bc4e2ac303'
PACKING_METHOD_SHA = '3a589881be41a0aa655414a465c63feab7a94c88ecbfe19631276fea74da6187'
# An inventory revision is an explicit method change, never an unchecked
# recipe permission to substitute arbitrary modules or override another gate.
SPECS = {
    'verification-session': ('scaling/modules.json',
        '37bc38671cb4a6a743308bca7aae3b9367ee990f2fffa50cb346eeacf5778531',
        ['modules', 'override'], ['p113d_lower_request']),
    'catalogue-index': ('scaling/catalogue-modules01.json',
        '4a589f2328f1d1002bbbf4df402ab59c37851588ee033e02214391c04babab9c',
        ['override'], ['p113pl_plan', 'p113pl_inspect_prepared']),
    'unary-packing': ('packing/modules01.json',
        '0a8351f6ff541bf3e84afaf6b26cdfe30d8602271dd8921f60a0baaac6b34ce4',
        ['modules'], ['p111_constructor']),
    'recursive-general': ('recursive-general/modules02.json',
        'd1ce4c8dd9041f99f005a8a168e7bf8165ef5bdf74201f723a36f53830c7ea17',
        ['modules', 'overrides'], ['p113e_public_chunk']),
    'transport': ('transport/modules01.json',
        '6ee601762afd81803e5d5eec25687f2ab952b669515b09413c599365b34cd5e5',
        ['modules'], ['p111q_stmt', 'p113a_verify']),
}
ORDER = ['verification-session', 'catalogue-index', 'unary-packing', 'recursive-general']


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def local_path(value):
    path = Path(value)
    return (path if path.is_absolute() else ROOT / path).resolve()


def authenticate(row, inputs):
    actual = pin(local_path(row.get('file', row.get('path', ''))))
    if actual['sha256'] != row['sha256'] or actual['bytes'] != row['bytes']:
        raise ValueError('changed frozen input: ' + actual['file'])
    inputs[actual['file']] = actual
    return actual


def authenticate_tree(value, inputs):
    if isinstance(value, dict):
        if ('file' in value or 'path' in value) and 'bytes' in value and 'sha256' in value:
            authenticate(value, inputs)
        for child in value.values():
            authenticate_tree(child, inputs)
    elif isinstance(value, list):
        for child in value:
            authenticate_tree(child, inputs)


def load_helpers(inputs):
    method = pin(PHASE / 'packing/admit.py')
    if method['sha256'] != PACKING_METHOD_SHA:
        raise ValueError('packing admission helpers changed')
    inputs[method['file']] = method
    return runpy.run_path(method['file'])


def load_component(component, baseline, inputs):
    name = component['name']
    path, sha, fields, allowed = SPECS[name]
    expected_pin = pin(PHASE / path)
    if expected_pin['sha256'] != sha or component['inventory'] != expected_pin:
        raise ValueError('unrecognized inventory revision: ' + name)
    if component['moduleFields'] != fields or component['allowedOverrides'] != allowed:
        raise ValueError('changed extraction/override policy: ' + name)
    inputs[expected_pin['file']] = expected_pin
    inventory = json.loads(Path(expected_pin['file']).read_text())
    authenticate_tree(inventory, inputs)
    base = inventory.get('base', inventory.get('baseline'))
    if isinstance(base, dict):
        if base != baseline:
            raise ValueError('component baseline mismatch: ' + name)
    elif local_path(base) != Path(baseline['file']) or inventory.get('baselineSha256') != BASE_SHA:
        raise ValueError('component baseline mismatch: ' + name)
    for field, value in inventory.items():
        if field.endswith('Inventory') and field + 'Sha256' in inventory:
            parent = pin(local_path(value))
            if parent['sha256'] != inventory[field + 'Sha256']:
                raise ValueError('linked inventory changed: ' + field)
            inputs[parent['file']] = parent
            authenticate_tree(json.loads(Path(parent['file']).read_text()), inputs)
    modules = []
    for field in fields:
        rows = inventory[field]
        modules.extend(rows if isinstance(rows, list) else [rows])
    return inventory, modules, set(allowed)


def expected_source(recipe, inputs, helpers):
    if recipe.get('kind') != 'phase114-composition-recipe' or recipe.get('version') != 1:
        raise ValueError('unsupported recipe')
    selected = [row['name'] for row in recipe['components']]
    if selected not in [ORDER, ORDER + ['transport']]:
        raise ValueError('unsupported component order or set')
    baseline = authenticate(recipe['baseline'], inputs)
    if baseline['sha256'] != BASE_SHA:
        raise ValueError('exact candidate31 baseline required')
    declarations, code = helpers['declarations'], helpers['code']
    expected = declarations(Path(baseline['file']).read_text())
    original = dict(expected)
    inventories, changes, modules = {}, [], []
    for component in recipe['components']:
        inventory, files, allowed = load_component(component, baseline, inputs)
        inventories[component['name']] = inventory
        seen = set()
        for row in files:
            file = authenticate(row, inputs)
            modules.append(file)
            for key, body in declarations(Path(file['file']).read_text()).items():
                if key in expected:
                    if key[0] != 'def' or key[1] not in allowed or key[1] in seen:
                        raise ValueError('undeclared/repeated override: ' + key[1])
                    seen.add(key[1])
                    changes.append(dict(name=key[1], component=component['name'],
                        oldSha256=hashlib.sha256(expected[key].encode()).hexdigest(),
                        newSha256=hashlib.sha256(body.encode()).hexdigest()))
                expected[key] = body
        if seen != allowed:
            raise ValueError('missing declared override: ' + component['name'])
        replacements = inventory.get('replacements', [])
        if 'replacement' in inventory:
            replacements = [inventory['replacement']]
        for replacement in replacements:
            key = ('def', replacement['name'])
            for part in ['old', 'new']:
                if hashlib.sha256(replacement[part].encode()).hexdigest() != replacement[part + 'Sha256']:
                    raise ValueError('replacement text digest mismatch')
            if original[key] != code(replacement['old']) or expected[key] != code(replacement['new']):
                raise ValueError('exact replacement mismatch: ' + key[1])
    aliases = [('p111_constructor', 'p114p_original_constructor')]
    if 'transport' in selected:
        aliases += [('p111q_stmt', 'p114t_original_stmt'), ('p113a_verify', 'p114t_original_verify')]
    for old, new in aliases:
        if expected['def', new] != original['def', old].replace('def ' + old + '(', 'def ' + new + '(', 1):
            raise ValueError('fallback is not exact: ' + old)
    # The transport layer may strengthen the final gate, but its old alias
    # must remain exact. All other gates are unchanged by the declaration map.
    return baseline, expected, inventories, changes, modules


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--recipe', type=Path, required=True)
    ap.add_argument('--compiler', type=Path, required=True)
    ap.add_argument('--api-report', type=Path, required=True)
    ap.add_argument('--runtime-source', type=Path, required=True)
    ap.add_argument('--runtime-object', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase114'):
        raise ValueError('fresh Phase114 output required')
    inputs = {}
    helpers = load_helpers(inputs)
    recipe_pin = pin(args.recipe)
    inputs[recipe_pin['file']] = recipe_pin
    baseline, expected, inventories, changes, modules = expected_source(
        json.loads(args.recipe.read_text()), inputs, helpers)
    packing = inventories['unary-packing']
    base_receipt_pin = authenticate(packing['baseAdmission'], inputs)
    base_receipt = json.loads(Path(base_receipt_pin['file']).read_text())
    if not base_receipt.get('complete') or not base_receipt.get('admitted') or base_receipt['compiler'] != baseline:
        raise ValueError('baseline admission incomplete/mismatched')
    for row in base_receipt['inputs']:
        authenticate(row, inputs)
    runtime, obj = pin(args.runtime_source), pin(args.runtime_object)
    for key, actual in [('runtimeSource', runtime), ('runtimeObject', obj)]:
        if actual != packing[key] or actual != base_receipt[key]:
            raise ValueError('exact baseline runtime required: ' + key)
        for inventory in inventories.values():
            if key in inventory and inventory[key] != actual:
                raise ValueError('component runtime mismatch: ' + key)
        inputs[actual['file']] = actual
    helpers['validate'](helpers['declarations'](args.compiler.read_text()), expected)
    compiler = pin(args.compiler)
    checked = json.loads(args.api_report.read_text())
    if not checked.get('complete') or not checked.get('checked') or checked.get('status') != 0:
        raise ValueError('successful checked API required')
    if compiler not in checked['inputs']:
        raise ValueError('checked compiler mismatch')
    authenticate(checked['api'], inputs)
    for name in ['p113a_lower_request', 'p113a_verify', 'p113a_admitted_chunks']:
        if name not in checked['exports']:
            raise ValueError('missing checked export: ' + name)
    inputs[compiler['file']] = compiler
    api_receipt_pin = pin(args.api_report)
    inputs[api_receipt_pin['file']] = api_receipt_pin
    method = pin(__file__)
    inputs[method['file']] = method
    result = dict(kind='phase114-composition-admission', version=1, complete=True,
        admitted=True, targetsExecuted=False, compiler=compiler, runtimeSource=runtime,
        runtimeObject=obj, checkedApi=checked['api'], checkedApiReceipt=api_receipt_pin,
        recipe=recipe_pin, method=method, baseAdmission=base_receipt_pin,
        components=list(inventories), modules=modules, overrides=changes,
        exactDeclarations=len(expected), inputs=list(inputs.values()),
        limitation='Exact checked source/runtime composition only. No semantic, native, performance, '
                   'concurrency or arbitrary reflected-IR ownership qualification. '
                   'Original final verifier remains mandatory; transport adds its namespace gate.')
    out.mkdir(parents=True)
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, declarations=len(expected), overrides=len(changes))))


if __name__ == '__main__':
    main()
