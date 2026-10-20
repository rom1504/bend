#!/usr/bin/env python3
"""Pinned v2 composition admission plus explicit, optional table overlays."""
import argparse
from contextlib import redirect_stdout
import hashlib
import io
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PHASE = HERE.parent
V2_SHA = 'd54a57341fcad50483533253a08e885a2415848ea66e39c8535391cf184fc9a6'
CORE_ORDER = ['verification-session', 'catalogue-index', 'unary-packing',
              'recursive-table', 'transport']
OVERLAYS = {
    'structured-unwind': ('recursive-table/unwind-modules01.json',
        '847c6075b8b584fe7238afdc4e0804ea672f06f5191518c85ba862115c9df622',
        ['p114h_cases', 'p114h_unwind']),
    'table-first': ('recursive-table/first-modules01.json',
        '1eba86303bba0766b87b7dd46d8cef9975c33ae6a6b49a3e2abc6aa519b40b17',
        ['p113e_public_chunk']),
    'packed-take': ('packed-take/modules01.json',
        '7f2879103f37f9cdffa5f51ebb0a5e1498e77e54b9f9c3f0530213e686ef9456',
        ['p111q_stmt', 'p113a_verify']),
}


def load_v2():
    path = HERE / 'admit-v2.py'
    if hashlib.sha256(path.read_bytes()).hexdigest() != V2_SHA:
        raise ValueError('frozen v2 admission changed')
    return runpy.run_path(str(path))


V2 = load_v2()
pin = V2['pin']
authenticate = V2['authenticate']
authenticate_tree = V2['authenticate_tree']
load_helpers = V2['load_helpers']


def checked_parent(inventory, core_expected, core_inventories, inputs, helpers):
    """Authenticate the unoverlaid table parent, never a preceding overlay."""
    parent = authenticate(inventory.get('parentSource', inventory.get('base')), inputs)
    helpers['validate'](helpers['declarations'](Path(parent['file']).read_text()), core_expected)
    if 'parentApiReceipt' in inventory:
        receipt = authenticate(inventory['parentApiReceipt'], inputs)
        checked = json.loads(Path(receipt['file']).read_text())
        authenticate_tree(checked, inputs)
        api = authenticate(inventory['parentApi'], inputs)
        if (not checked.get('complete') or not checked.get('checked')
                or checked.get('status') != 0 or parent not in checked['inputs']
                or checked['api'] != api):
            raise ValueError('overlay checked parent mismatch')
        dependencies = [authenticate(row, inputs) for row in inventory['dependencies']]
        expected_dependencies = [pin(PHASE / V2['SPECS'][name][0])
                                 for name in ['recursive-table', 'transport']]
        if dependencies != expected_dependencies:
            raise ValueError('overlay table/transport dependency mismatch')
        for field, name in [('tableSources', 'recursive-table'), ('transportSources', 'transport')]:
            rows = core_inventories[name]['modules']
            if name == 'recursive-table':
                rows = rows + core_inventories[name]['overrides']
            if [authenticate(row, inputs) for row in inventory[field]] != [
                    authenticate(row, inputs) for row in rows]:
                raise ValueError('overlay parent module list mismatch: ' + name)
    else:
        receipt = authenticate(inventory['baseAdmission'], inputs)
        admitted = json.loads(Path(receipt['file']).read_text())
        authenticate_tree(admitted, inputs)
        if (admitted.get('kind') != 'phase114-composition-admission'
                or not admitted.get('complete') or not admitted.get('admitted')
                or admitted['compiler'] != parent):
            raise ValueError('packed-take parent admission mismatch')
        for field in ['runtimeSource', 'runtimeObject']:
            if admitted[field] != inventory[field] or inventory[field] != core_inventories['unary-packing'][field]:
                raise ValueError('packed-take parent runtime mismatch: ' + field)
    return parent


def expected_source(recipe, inputs, helpers):
    if recipe.get('kind') != 'phase114-composition-recipe' or recipe.get('version') != 3:
        raise ValueError('version 3 recipe required')
    if [row['name'] for row in recipe['components']] != CORE_ORDER:
        raise ValueError('exact table-plus-transport core required')
    selected = [row['name'] for row in recipe['overlays']]
    if selected != [name for name in OVERLAYS if name in selected]:
        raise ValueError('unknown, duplicate or unordered overlay')
    core = {key: recipe[key] for key in ['kind', 'baseline', 'components']}
    core['version'] = 1
    baseline, expected, inventories, changes, modules = V2['expected_source'](core, inputs, helpers)
    core_expected = dict(expected)
    parent = None
    for component in recipe['overlays']:
        name = component['name']
        path, sha, allowed = OVERLAYS[name]
        inventory_pin = pin(PHASE / path)
        if inventory_pin['sha256'] != sha or component['inventory'] != inventory_pin:
            raise ValueError('unrecognized overlay inventory: ' + name)
        if component['moduleFields'] != ['modules'] or component['allowedOverrides'] != allowed:
            raise ValueError('changed overlay extraction/override policy: ' + name)
        inputs[inventory_pin['file']] = inventory_pin
        inventory = json.loads(Path(inventory_pin['file']).read_text())
        authenticate_tree(inventory, inputs)
        if inventory['overrides'] != allowed:
            raise ValueError('overlay override list mismatch: ' + name)
        this_parent = checked_parent(inventory, core_expected, inventories, inputs, helpers)
        if parent is not None and this_parent != parent:
            raise ValueError('overlay parent bytes differ')
        parent = this_parent
        seen = set()
        for row in inventory['modules']:
            module = authenticate(row, inputs)
            modules.append(module)
            for key, body in helpers['declarations'](Path(module['file']).read_text()).items():
                if key in expected:
                    if key[0] != 'def' or key[1] not in allowed or key[1] in seen:
                        raise ValueError('undeclared/repeated overlay override: ' + key[1])
                    seen.add(key[1])
                    changes.append(dict(name=key[1], component=name,
                        oldSha256=hashlib.sha256(expected[key].encode()).hexdigest(),
                        newSha256=hashlib.sha256(body.encode()).hexdigest()))
                expected[key] = body
        if seen != set(allowed):
            raise ValueError('missing overlay override: ' + name)
        inventories[name] = inventory
    if 'packed-take' in selected:
        if expected['def', 'p114pk_original_verify'] != core_expected['def', 'p113a_verify'].replace(
                'def p113a_verify(', 'def p114pk_original_verify(', 1):
            raise ValueError('packed-take final verifier fallback changed')
    for path in [HERE / 'admit-v2.py', Path(__file__)]:
        row = pin(path)
        inputs[row['file']] = row
    return baseline, expected, inventories, changes, modules


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    for name in ['recipe', 'compiler', 'api-report', 'runtime-source', 'runtime-object', 'out']:
        ap.add_argument('--' + name, type=Path, required=True)
    args = ap.parse_args()
    recipe = json.loads(args.recipe.read_text())
    # Keep the standalone packed-take gate's checked-export requirement too.
    if any(row['name'] == 'packed-take' for row in recipe.get('overlays', [])):
        checked = json.loads(args.api_report.read_text())
        for name in ['p114pk_shape', 'p114pk_buffer', 'p114pk_stmt', 'p114pk_namespace', 'p111q_ids']:
            if name not in checked['exports']:
                raise ValueError('missing checked packed-take export: ' + name)
    # A fresh runpy namespace supplies one extended map callback. The pinned
    # v2 main still performs every full-source, runtime, checked-API and receipt
    # check, with the unchanged CLI. No frozen method is edited on disk.
    delegated = load_v2()
    delegated['main'].__globals__['expected_source'] = expected_source
    with redirect_stdout(io.StringIO()):
        delegated['main']()
    receipt = args.out.resolve() / 'manifest.json'
    result = json.loads(receipt.read_text())
    method = pin(__file__)
    result.update(version=3, method=method, delegatedMethod=pin(HERE / 'admit-v2.py'),
                  overlays=[row['name'] for row in recipe['overlays']],
                  limitation='Exact checked source/runtime composition only. Original final verifier '
                             'and namespace gates remain mandatory. Semantic, native and performance '
                             'qualification are separate; no reflected ownership certificate.')
    temporary = receipt.with_suffix('.json.tmp')
    temporary.write_text(json.dumps(result, indent=2) + '\n')
    temporary.replace(receipt)
    print(json.dumps(dict(complete=True, declarations=result['exactDeclarations'],
                          overrides=len(result['overrides']), overlays=result['overlays'])))


if __name__ == '__main__':
    main()
