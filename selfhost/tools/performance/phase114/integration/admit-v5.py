#!/usr/bin/env python3
"""Optional P114-010: exact source02 plus authenticated H scratch coverage."""
import argparse
from contextlib import redirect_stdout
import hashlib
import io
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
V4_SHA = '90259912337ceb45ab164f7e9ad799435ea9437a686ea2352a573abc5675960e'
RECIPE_SHA = '938868799d09cde2929ca487067e28393fb3f106c4ad7e4d6f7955a7b7ef64c1'
OVERLAY_SHA = '1109ddeac2f1f56c34b28aa9de3a3a38679cdc0af89dec47d0a4239b8d8f0513'
ALLOWED = ['p114t_buffer', 'p114t_local_name']
ADDITIONS = ['p114t_table_buffer_at', 'p114t_table_buffer']
EXPORTS = ['p114t_table_buffer', 'p114t_buffer', 'p114t_local_name']
path = HERE / 'admit-v4.py'
if hashlib.sha256(path.read_bytes()).hexdigest() != V4_SHA:
    raise ValueError('frozen v4 admission changed')
V4 = runpy.run_path(str(path))
pin, authenticate, authenticate_tree = V4['pin'], V4['authenticate'], V4['authenticate_tree']


def expected_source(recipe, inputs, helpers):
    if recipe.get('kind') != 'phase114-composition-recipe' or recipe.get('version') != 5:
        raise ValueError('version 5 optional recipe required')
    parent_recipe = authenticate(recipe['parentRecipe'], inputs)
    if (parent_recipe != pin(HERE / 'recipe-table-unwind-first-namespace01.json')
            or parent_recipe['sha256'] != RECIPE_SHA):
        raise ValueError('exact source02 recipe required')
    baseline, expected, inventories, changes, modules = V4['expected_source'](
        json.loads(Path(parent_recipe['file']).read_text()), inputs, helpers)
    original = dict(expected)
    overlay = recipe['bufferOverlay']
    inventory_pin = authenticate(overlay['inventory'], inputs)
    if (inventory_pin != pin(HERE.parent / 'transport/table-buffers-modules01.json')
            or inventory_pin['sha256'] != OVERLAY_SHA or overlay['moduleFields'] != ['modules']
            or overlay['allowedOverrides'] != ALLOWED):
        raise ValueError('unrecognized table-buffer overlay policy')
    inventory = json.loads(Path(inventory_pin['file']).read_text())
    authenticate_tree(inventory, inputs)
    if (inventory['overrides'] != ALLOWED or inventory['additions'] != ADDITIONS
            or inventory['exports'] != EXPORTS):
        raise ValueError('table-buffer declaration/export policy mismatch')
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
        raise ValueError('source02 parent admission/API mismatch')
    for key in ['runtimeSource', 'runtimeObject']:
        if admission[key] != inventories['unary-packing'][key]:
            raise ValueError('source02 runtime mismatch')
    dependencies = ['transport/modules01.json', 'transport/namespace-tail-modules01.json',
                    'recursive-table/modules01.json']
    if [authenticate(row, inputs) for row in inventory['dependencies']] != [pin(HERE.parent / path) for path in dependencies]:
        raise ValueError('table/namespace/transport dependency mismatch')
    for name, sha in inventory['parentDeclarations'].items():
        if hashlib.sha256(original['def', name].encode()).hexdigest() != sha:
            raise ValueError('parent factory/template declaration changed: ' + name)
    replaced, added = set(), set()
    for row in inventory['modules']:
        module = authenticate(row, inputs)
        modules.append(module)
        for key, body in helpers['declarations'](Path(module['file']).read_text()).items():
            if key[0] != 'def':
                raise ValueError('table-buffer overlay may only contain definitions')
            if key in expected:
                if key[1] not in ALLOWED or key[1] in replaced:
                    raise ValueError('undeclared/repeated table-buffer override: ' + key[1])
                replaced.add(key[1])
                changes.append(dict(name=key[1], component='table-buffers',
                    oldSha256=hashlib.sha256(expected[key].encode()).hexdigest(),
                    newSha256=hashlib.sha256(body.encode()).hexdigest()))
            else:
                if key[1] not in ADDITIONS or key[1] in added:
                    raise ValueError('undeclared table-buffer addition: ' + key[1])
                added.add(key[1])
            expected[key] = body
    if replaced != set(ALLOWED) or added != set(ADDITIONS):
        raise ValueError('missing table-buffer declarations')
    inventories['table-buffers'] = inventory
    for path in [Path(__file__), HERE / 'admit-v4.py']:
        row = pin(path)
        inputs[row['file']] = row
    return baseline, expected, inventories, changes, modules


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    for name in ['recipe', 'compiler', 'api-report', 'runtime-source', 'runtime-object', 'out']:
        ap.add_argument('--' + name, type=Path, required=True)
    args = ap.parse_args()
    checked = json.loads(args.api_report.read_text())
    if any(name not in checked['exports'] for name in EXPORTS):
        raise ValueError('checked table-buffer recognizer exports required')
    delegated = V4['V3']['load_v2']()
    delegated['main'].__globals__['expected_source'] = expected_source
    with redirect_stdout(io.StringIO()):
        delegated['main']()
    receipt = args.out.resolve() / 'manifest.json'
    result = json.loads(receipt.read_text())
    result.update(version=5, optionalExperiment='P114-010', method=pin(__file__),
        delegatedMethod=pin(HERE / 'admit-v2.py'), parentMapMethod=pin(HERE / 'admit-v4.py'),
        overlays=['structured-unwind', 'table-first', 'namespace-tail', 'table-buffers'],
        limitation='Exact optional source/runtime composition only. The same eight accepted H scratch '
                   'names are reserved in original verified graphs. Original verifier, factory layouts '
                   'and transport templates remain mandatory. Semantic/performance/selection gates are separate.')
    temporary = receipt.with_suffix('.json.tmp')
    temporary.write_text(json.dumps(result, indent=2) + '\n')
    temporary.replace(receipt)
    print(json.dumps(dict(complete=True, optionalExperiment='P114-010',
                          declarations=result['exactDeclarations'], overrides=len(result['overrides']))))


if __name__ == '__main__':
    main()
