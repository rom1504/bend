#!/usr/bin/env python3
"""Construct a pinned QBE runtime object from maintained source and headers."""
import argparse
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
import assets
from common import (changed_inputs, clean_environment, fresh_output, pin, require,
                    run, same_bytes, timeout, workspace, write_json)


def build(args):
    root = workspace(args.workspace)
    clean_environment()
    timeout(args.seconds)
    document = assets.load_assets(args.assets, root)
    recipe = document.get('runtimeRecipes', {}).get(args.recipe)
    require(isinstance(recipe, dict), 'Explicit runtime construction recipe required')
    compiler = assets.asset(document, recipe['compiler'])
    source = assets.asset(document, recipe['source'])
    headers = [assets.asset(document, key) for key in recipe['headers']]
    source_dir = Path(source['file']).parent
    require(all(Path(row['file']).parent == source_dir for row in headers),
            'Pinned quoted headers must occupy the source directory')
    names = {Path(row['file']).name for row in headers}
    for row in [source, *headers]:
        quoted = set(re.findall(r'^\s*#\s*include\s*"([^"]+)"', Path(row['file']).read_text(), re.M))
        require(quoted <= names, 'Unbound local runtime include: ' + str(sorted(quoted - names)))
    expected = assets.asset(document, recipe['expectedObject']) if recipe.get('expectedObject') else None
    require(isinstance(recipe.get('flags'), list) and all(isinstance(x, str) for x in recipe['flags']),
            'Explicit runtime compiler flags required')
    inputs = [document['_manifest'], pin(__file__), pin(assets.__file__),
              pin(Path(__file__).with_name('common.py')), pin(sys.executable), compiler, source, *headers]
    if expected:
        inputs.append(expected)
    out = args.out.resolve()
    command = [compiler['file'], *recipe['flags'], '-c', source['file'], '-o', str(out/'runtime.o')]
    report = dict(kind='bend-runtime-build', version=1, complete=False, recipe=args.recipe,
                  inputs=inputs, source=source, headers=headers, compiler=compiler,
                  command=command, runtimePolicy=recipe['policy'], expectedObject=expected,
                  scope='Runtime object construction only. ABI/semantic/native qualification is separate.',
                  environmentScope='Pinned compiler, local runtime headers and flags; system libc/toolchain installation remains external.')
    if args.plan:
        report['planOnly'] = True
        return report
    fresh_output(out, root)
    write_json(out/'report.json', report)
    try:
        report['process'] = run(command, cwd=root, stdout=out/'compile.stdout',
                                stderr=out/'compile.stderr', seconds=args.seconds)
        require(report['process']['complete'], 'Runtime construction failed')
        report['object'] = pin(out/'runtime.o')
        require(report['object']['bytes'] > 0, 'Empty runtime object')
        if expected:
            report['objectExact'] = same_bytes(out/'runtime.o', expected['file'])
            require(report['objectExact'], 'Runtime object differs from the explicit qualified reference')
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = changed_inputs(inputs)
        if report['changedInputs']:
            report['complete'] = False
        write_json(out/'report.json', report)
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workspace', type=Path)
    parser.add_argument('--assets', type=Path, required=True)
    parser.add_argument('--recipe', default='serial-rfc')
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=90)
    parser.add_argument('--plan', action='store_true')
    args = parser.parse_args()
    report = build(args)
    print(json.dumps(report if args.plan else {k: report.get(k) for k in ('complete','object','objectExact','error')}, indent=2))
    return 0 if args.plan or report['complete'] else 1


if __name__ == '__main__':
    sys.exit(main())
