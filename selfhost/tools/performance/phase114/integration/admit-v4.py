#!/usr/bin/env python3
"""Selected v3 table/unwind/first composition plus flat namespace tail loops."""
import argparse
from contextlib import redirect_stdout
import hashlib
import io
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
V3_SHA = 'adca7db92ce86b82b4c1fdd3d08349c1dbc09f3391049671a7a258b86245e0ba'
RECIPE_SHA = 'e06a122e846283bbe12fbe42c59d736f632cc9b980883fd396d3d80345e63b65'
OVERLAY_SHA = '524b5213e36db61b7902a11ee9247a642a692884003a750044c241eff35944ba'
ALLOWED = ['p114t_names', 'p114t_params', 'p114t_scalar_list_names',
           'p114t_body_names', 'p114t_function_names', 'p114t_segment_names']
ADDITIONS = ['p114ts_names', 'p114ts_params', 'p114ts_scalar_list',
             'p114ts_body', 'p114ts_functions', 'p114ts_segments']
path = HERE / 'admit-v3.py'
if hashlib.sha256(path.read_bytes()).hexdigest() != V3_SHA:
    raise ValueError('frozen v3 admission changed')
V3 = runpy.run_path(str(path))
pin, authenticate, authenticate_tree = V3['pin'], V3['authenticate'], V3['authenticate_tree']


def expected_source(recipe, inputs, helpers):
    if recipe.get('kind') != 'phase114-composition-recipe' or recipe.get('version') != 4:
        raise ValueError('version 4 recipe required')
    parent_recipe = authenticate(recipe['parentRecipe'], inputs)
    if parent_recipe != pin(HERE / 'recipes-v3/table-unwind-first.json') or parent_recipe['sha256'] != RECIPE_SHA:
        raise ValueError('exact selected v3 recipe required')
    baseline, expected, inventories, changes, modules = V3['expected_source'](
        json.loads(Path(parent_recipe['file']).read_text()), inputs, helpers)
    original = dict(expected)
    overlay = recipe['namespaceOverlay']
    inventory_pin = authenticate(overlay['inventory'], inputs)
    if (inventory_pin != pin(HERE.parent / 'transport/namespace-tail-modules01.json')
            or inventory_pin['sha256'] != OVERLAY_SHA or overlay['moduleFields'] != ['modules']
            or overlay['allowedOverrides'] != ALLOWED):
        raise ValueError('unrecognized namespace overlay policy')
    inventory = json.loads(Path(inventory_pin['file']).read_text())
    authenticate_tree(inventory, inputs)
    if inventory['overrides'] != ALLOWED or inventory['additions'] != ADDITIONS:
        raise ValueError('namespace declaration policy mismatch')
    parent = authenticate(inventory['parentSource'], inputs)
    helpers['validate'](helpers['declarations'](Path(parent['file']).read_text()), original)
    admission = json.loads(Path(authenticate(inventory['parentAdmission'], inputs)['file']).read_text())
    checked = json.loads(Path(authenticate(inventory['parentApiReceipt'], inputs)['file']).read_text())
    authenticate_tree(admission, inputs)
    authenticate_tree(checked, inputs)
    if (not admission.get('complete') or not admission.get('admitted')
            or admission['compiler'] != parent or admission['recipe'] != parent_recipe
            or not checked.get('complete') or not checked.get('checked') or checked.get('status') != 0
            or parent not in checked['inputs'] or checked['api'] != authenticate(inventory['parentApi'], inputs)):
        raise ValueError('selected parent admission/API mismatch')
    for key in ['runtimeSource', 'runtimeObject']:
        if admission[key] != inventories['unary-packing'][key]:
            raise ValueError('selected parent runtime mismatch')
    if [authenticate(row, inputs) for row in inventory['dependencies']] != [pin(HERE.parent / 'transport/modules01.json')]:
        raise ValueError('transport dependency mismatch')
    if [authenticate(row, inputs) for row in inventory['transportSources']] != [
            authenticate(row, inputs) for row in inventories['transport']['modules']]:
        raise ValueError('transport source list mismatch')
    replaced, added = set(), set()
    for row in inventory['modules']:
        module = authenticate(row, inputs)
        modules.append(module)
        for key, body in helpers['declarations'](Path(module['file']).read_text()).items():
            if key[0] != 'def':
                raise ValueError('namespace overlay may only contain definitions')
            if key in expected:
                if key[1] not in ALLOWED or key[1] in replaced:
                    raise ValueError('undeclared/repeated namespace override: ' + key[1])
                replaced.add(key[1])
                changes.append(dict(name=key[1], component='namespace-tail',
                    oldSha256=hashlib.sha256(expected[key].encode()).hexdigest(),
                    newSha256=hashlib.sha256(body.encode()).hexdigest()))
            else:
                if key[1] not in ADDITIONS or key[1] in added:
                    raise ValueError('undeclared namespace addition: ' + key[1])
                added.add(key[1])
            expected[key] = body
    if replaced != set(ALLOWED) or added != set(ADDITIONS):
        raise ValueError('missing namespace declarations')
    for name in inventory['unchanged']:
        if expected['def', name] != original['def', name]:
            raise ValueError('original predicate/verifier changed: ' + name)
    inventories['namespace-tail'] = inventory
    for path in [Path(__file__), HERE / 'admit-v3.py']:
        row = pin(path)
        inputs[row['file']] = row
    return baseline, expected, inventories, changes, modules


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    for name in ['recipe', 'compiler', 'api-report', 'runtime-source', 'runtime-object', 'out']:
        ap.add_argument('--' + name, type=Path, required=True)
    args = ap.parse_args()
    delegated = V3['load_v2']()
    delegated['main'].__globals__['expected_source'] = expected_source
    with redirect_stdout(io.StringIO()):
        delegated['main']()
    receipt = args.out.resolve() / 'manifest.json'
    result = json.loads(receipt.read_text())
    result.update(version=4, method=pin(__file__), delegatedMethod=pin(HERE / 'admit-v2.py'),
        parentMapMethod=pin(HERE / 'admit-v3.py'),
        overlays=['structured-unwind', 'table-first', 'namespace-tail'],
        limitation='Exact checked source/runtime composition only. Original verifier and namespace '
                   'predicates remain mandatory. Flat traversals use tail accumulators; nested branch '
                   'depth remains recursive. Compiler/native qualification is separate.')
    temporary = receipt.with_suffix('.json.tmp')
    temporary.write_text(json.dumps(result, indent=2) + '\n')
    temporary.replace(receipt)
    print(json.dumps(dict(complete=True, declarations=result['exactDeclarations'], overrides=len(result['overrides']))))


if __name__ == '__main__':
    main()
