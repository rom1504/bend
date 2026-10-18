#!/usr/bin/env python3
"""Materialize an exact portable runtime variant from the selected pinned base.

This is source preparation only. No compiler, C preprocessor or target is run.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
LAUNCH = ROOT / 'selfhost/tools/native/launch.py'
RECIPE = HERE / 'runtime-recipes.json'
BASE = dict(bytes=83683, sha256='9e1c59078878be94052cb4d2d63a713e19e29b41ed3f94b034f2175a50efd0a9')
OUTPUTS = {
    'v1': dict(bytes=85595, sha256='d56fe7a06086aa23cd8154698d81df14732bed517adadf9a164e02c4a22dff43'),
    'v2': dict(bytes=85696, sha256='17cece2e0cf301472cb7f9b131337ebaa2cb0eb870f67af73566c8cb6c29eec3'),
    'v3': dict(bytes=86187, sha256='bffb4258ac362a338b18bb7a6ece1c816a46e6f3112a3cb594d65ae79cdde0dc'),
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def content(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def apply_variant(raw, variant, recipe):
    """Apply only exact unique byte blocks; verify every chain boundary."""
    require(variant in OUTPUTS, 'unknown runtime variant')
    definitions = recipe['variants']
    chain = ['v1', 'v2', 'v3'][:['v1', 'v2', 'v3'].index(variant)+1]
    require(content(raw) == BASE, 'runtime baseline bytes differ')
    applied = []
    for index, name in enumerate(chain):
        item = definitions[name]
        require(item['parent'] == ('base' if index == 0 else chain[index - 1]),
                'unexpected recipe parent for ' + name)
        require(item['output'] == OUTPUTS[name], 'recipe output identity differs for ' + name)
        require(isinstance(item['edits'], list) and item['edits'], 'empty runtime edit recipe')
        for edit in item['edits']:
            old, new = edit['old'].encode(), edit['new'].encode()
            require(old and raw.count(old) == 1, 'edit block must occur exactly once: ' + name + '/' + edit['name'])
            raw = raw.replace(old, new, 1)
            applied.append(dict(variant=name, name=edit['name'], old=content(old), new=content(new)))
        require(content(raw) == OUTPUTS[name], 'materialized runtime identity differs for ' + name)
    return raw, applied


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--variant', choices=sorted(OUTPUTS), required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--selection', type=Path, default=ROOT / 'selfhost/tools/native/selection.json')
    args = parser.parse_args()
    output = args.out.resolve()
    receipt = Path(str(output) + '.materialization.json')
    require(output.is_relative_to(ROOT / 'selfhost/build/phase108'), 'output must be under selfhost/build/phase108')
    require(not output.exists() and not receipt.exists(), 'output and receipt must be fresh paths')

    spec = importlib.util.spec_from_file_location('phase108_runtime_native_launch', LAUNCH)
    native = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(native)
    release, binding = native.load(args.selection, stage='b2', live=True)
    baseline = native.verify(release['assets']['runtime'])
    require({key: baseline[key] for key in BASE} == BASE, 'selected runtime is not the admitted baseline')
    recipe_pin = native.pin(RECIPE)
    recipe = json.loads(Path(recipe_pin['file']).read_bytes())
    require(recipe['kind'] == 'phase108-portable-runtime-exact-edits' and recipe['version'] == 1,
            'unsupported runtime recipe')
    require(recipe['base'] == BASE and set(recipe['variants']) == set(OUTPUTS), 'runtime recipe identities differ')
    result, applied = apply_variant(Path(baseline['file']).read_bytes(), args.variant, recipe)
    inputs = [native.pin(__file__), native.pin(LAUNCH), recipe_pin,
              binding['selection'], binding['admission'], baseline]
    for record in inputs:
        native.verify(record)

    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('xb') as stream:
        stream.write(result)
    actual = native.pin(output)
    require({key: actual[key] for key in BASE} == OUTPUTS[args.variant], 'written runtime identity differs')
    record = dict(kind='phase108-portable-runtime-materialization', version=1, complete=True,
                  targetsRun=False, variant=args.variant, selection=binding, baseline=baseline,
                  recipe=recipe_pin, inputs=inputs, edits=applied, output=actual,
                  scope='Exact runtime source preparation; no compiler algorithms or target execution.')
    with receipt.open('x') as stream:
        json.dump(record, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(complete=True, targetsRun=False, variant=args.variant,
                          output=actual, receipt=str(receipt))))


if __name__ == '__main__':
    main()
