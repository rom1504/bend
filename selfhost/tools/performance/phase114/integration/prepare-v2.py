#!/usr/bin/env python3
"""Version 2: replay an admitted recipe including optional recursive tables."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
ADMIT_SHA = 'd54a57341fcad50483533253a08e885a2415848ea66e39c8535391cf184fc9a6'
COMPOSER_SHA = 'd354403aa40030a93f597b785037a57401641f5ce1ecf66675f0a130691c2c37'


def pinned_method(path, sha):
    raw = path.read_bytes()
    if hashlib.sha256(raw).hexdigest() != sha:
        raise ValueError('preparation dependency changed: ' + str(path))
    return runpy.run_path(str(path))


def compose(recipe_path):
    admission = pinned_method(HERE / 'admit-v2.py', ADMIT_SHA)
    composer_path = ROOT / 'selfhost/tools/performance/phase113/prepare.py'
    composer = pinned_method(composer_path, COMPOSER_SHA)
    pin = admission['pin']
    inputs = {}
    helpers = admission['load_helpers'](inputs)
    recipe = pin(recipe_path)
    inputs[recipe['file']] = recipe
    baseline, expected, inventories, overrides, modules = admission['expected_source'](
        json.loads(recipe_path.read_text()), inputs, helpers)
    source = Path(baseline['file']).read_text()
    contents, edits = [], []
    # Exact declaration transport from Phase113 prepare.py, using its original
    # block parser. The authenticated recipe has already validated collisions.
    for module in modules:
        raw = Path(module['file']).read_bytes()
        content = raw.decode()
        contents.append(raw)
        for kind, name, a, b in composer['blocks'](content):
            body = content[a:b].rstrip() + '\n\n'
            matches = [(x, y) for k, n, x, y in composer['blocks'](source)
                       if k == kind and n == name]
            if len(matches) > 1:
                raise ValueError('ambiguous source declaration: ' + name)
            edit = dict(kind=kind, name=name, module=module['file'])
            if matches:
                x, y = matches[0]
                edit.update(action='replace', oldSha256=hashlib.sha256(source[x:y].encode()).hexdigest())
                source = source[:x] + body + source[y:]
            else:
                edit['action'] = 'append'
                source += '\n' + body
            edits.append(edit)
    helpers['validate'](helpers['declarations'](source), expected)
    if sum(kind == 'def' and name == 'main' for kind, name, _, _ in composer['blocks'](source)) != 1:
        raise ValueError('exactly one main declaration required')
    for row in [baseline, recipe, *modules]:
        admission['authenticate'](row, inputs)
    for path in [HERE / 'admit-v2.py', composer_path, Path(__file__)]:
        row = pin(path)
        inputs[row['file']] = row
    return dict(source=source, recipe=recipe, baseline=baseline,
                expectedDeclarations=len(expected), overrides=overrides,
                modules=modules, contents=contents, edits=edits,
                inputs=list(inputs.values())), pin


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
    result.update(kind='phase114-recipe-source-composition', version=2,
                  prepared=True, checked=False, targetsRun=False,
                  source=pin(out / 'compiler.bend'), method=pin(out / 'method.py'),
                  recipeSnapshot=pin(out / 'recipe.json'), moduleSnapshots=snapshots,
                  limitation='Exact source transport only; checked API, composition admission '
                             'and ordinary semantic/native qualification remain separate gates.')
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(source=result['source'], declarations=result['expectedDeclarations'],
                          edits=len(result['edits']))))


if __name__ == '__main__':
    main()
