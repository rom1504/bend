#!/usr/bin/env python3
"""Replay optional table overlays through the frozen v2 source transporter."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PREPARE_V2_SHA = '85ae738a1fc1b9598a6f42ddc7d76b71222d64cbd1c9b1da69e3a6a19e14a530'
ADMIT_V3_SHA = 'adca7db92ce86b82b4c1fdd3d08349c1dbc09f3391049671a7a258b86245e0ba'


def pinned(path, sha):
    if hashlib.sha256(path.read_bytes()).hexdigest() != sha:
        raise ValueError('preparation dependency changed: ' + str(path))
    return runpy.run_path(str(path))


def compose(recipe_path):
    admission = pinned(HERE / 'admit-v3.py', ADMIT_V3_SHA)
    transport = pinned(HERE / 'prepare-v2.py', PREPARE_V2_SHA)
    original_loader = transport['pinned_method']

    def extended_loader(path, sha):
        loaded = original_loader(path, sha)
        if path.resolve() == (HERE / 'admit-v2.py').resolve():
            # The original loader still authenticates v2. Its declaration-map
            # callback alone is extended; its parser and transport are exact.
            loaded['expected_source'] = admission['expected_source']
        return loaded

    transport['compose'].__globals__['pinned_method'] = extended_loader
    result, pin = transport['compose'](recipe_path)
    inputs = {row['file']: row for row in result['inputs']}
    for path in [HERE / 'admit-v3.py', HERE / 'prepare-v2.py', Path(__file__)]:
        row = pin(path)
        inputs[row['file']] = row
    result['inputs'] = list(inputs.values())
    result['delegatedMethod'] = pin(HERE / 'prepare-v2.py')
    result['overlays'] = [row['name'] for row in json.loads(recipe_path.read_text())['overlays']]
    return result, pin


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--recipe', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase114'):
        raise ValueError('fresh Phase114 output required')
    result, pin = compose(args.recipe.resolve())
    out.mkdir(parents=True)
    (out / 'modules').mkdir()
    snapshots = []
    for index, (module, content) in enumerate(zip(result['modules'], result.pop('contents'))):
        dest = out / 'modules' / (str(index).zfill(2) + '-' + Path(module['file']).name)
        dest.write_bytes(content)
        snapshots.append(dict(original=module, snapshot=pin(dest)))
    (out / 'compiler.bend').write_text(result.pop('source'))
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    (out / 'recipe.json').write_bytes(Path(result['recipe']['file']).read_bytes())
    result.update(kind='phase114-recipe-source-composition', version=3,
                  prepared=True, checked=False, targetsRun=False,
                  source=pin(out / 'compiler.bend'), method=pin(out / 'method.py'),
                  recipeSnapshot=pin(out / 'recipe.json'), moduleSnapshots=snapshots,
                  limitation='Exact source transport only; checked API, composition admission '
                             'and ordinary semantic/native qualification remain separate gates.')
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(source=result['source'], declarations=result['expectedDeclarations'],
                          edits=len(result['edits']), overlays=result['overlays'])))


if __name__ == '__main__':
    main()
