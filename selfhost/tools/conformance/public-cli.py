#!/usr/bin/env python3
"""Seven finite public hosted CLI controls under one caller-owned resource guard."""
import argparse
import copy
import json
import os
from pathlib import Path
import re
import shutil
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parents[1] / 'build'))
import assets
import qualification as Q
import request
from common import changed_inputs, fresh_output, pin, require, run, verify, workspace, write_json


CATALOG = Path(__file__).with_name('public-cli-catalog.json')


def load_catalog(file=None):
    catalog_file = Path(file or CATALOG).resolve(strict=True)
    catalog = json.loads(catalog_file.read_text())
    cases = catalog.get('cases')
    require(catalog.get('kind') == 'bend-public-cli-controls' and catalog.get('version') == 1
            and re.fullmatch('[0-9a-f]{40}', catalog.get('upstream', ''))
            and isinstance(cases, list) and 0 < len(cases) <= 256,
            'Unknown public CLI catalog')
    ids = [case.get('id') for case in cases]
    require(all(isinstance(value, str) and re.fullmatch('[a-z0-9][a-z0-9_-]*', value) for value in ids)
            and len(set(ids)) == len(ids), 'Invalid or duplicate public CLI case identity')
    if catalog_file == CATALOG.resolve():
        require(catalog['upstream'] == Q.UPSTREAM, 'Retained public CLI catalog upstream changed')
    return catalog, catalog_file


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    request.arguments(parser, source_required=False)
    parser.add_argument('--catalog', type=Path,
                        help='Explicit versioned public CLI controls; upstream must match assets')
    args = parser.parse_args()
    require(args.host == 'js' and args.target == 'js' and args.mode == 'live',
            'Public hosted CLI requires explicit --host js --target js --mode live')
    require(not args.source and not args.expected, 'Fixed catalog owns source/oracle')
    root = workspace(args.workspace)
    catalog, catalog_file = load_catalog(args.catalog)
    document = assets.load_assets(args.assets, root)
    require(document['upstream'] == catalog['upstream'], 'Catalog and asset upstream differ')
    first = copy.copy(args)
    first.source = root / catalog['cases'][0]['source']['file']
    plan = request.plan(first)
    cli = pin(root / 'selfhost/cli.mjs')
    # Freeze the maintained host closure and providers, not historical scripts.
    inputs = [*plan['inputs'], cli, pin(__file__), pin(catalog_file), pin(Q.__file__)]
    inputs += [pin(p) for p in sorted((root / 'selfhost/tools').glob('*.mjs'))]
    inputs += [pin(p) for p in sorted((root / 'selfhost/src/runtime').rglob('*')) if p.is_file()]
    inputs += [pin(root / 'selfhost/src/runtime.mjs'), pin(root / 'selfhost/src/compiler.json')]
    template_key = document.get('providers', {}).get('c', {}).get('runtimeTemplate')
    runtime_template = assets.asset(document, template_key) if template_key else None
    if runtime_template:
        inputs.append(runtime_template)
    def cache_state():
        prefix = 'base-' + plan['image']['sha256'] + '-' + plan['base']['sha256']
        return [pin(p) for name in ('cache', 'base-products')
                for p in sorted((root / 'selfhost/build/typed' / name).glob(prefix + '*')) if p.is_file()]
    caches = cache_state()
    inputs += caches
    report = dict(kind='bend-public-cli-qualification', version=1, complete=False, passed=False,
                  fullConformance=False, upstream=catalog['upstream'], catalog=pin(catalog_file),
                  image=plan['image'], inputs=inputs,
                  scope=catalog['scope'], rows=[],
                  cachePolicy='Explicit BEND_TYPED_BASE_CACHE=off; same image/Base, no cache reads or creation.',
                  cacheBefore=caches)
    if args.plan:
        print(json.dumps(dict(report, planOnly=True), indent=2)); return 0
    out = fresh_output(args.out, root)
    env = {k: v for k, v in os.environ.items() if not k.startswith('BEND_')
           and k not in ('NODE_OPTIONS', 'NODE_PATH', 'LD_PRELOAD')}
    env.update(BEND_TYPED_API=plan['image']['file'], BEND_BASE=plan['base']['file'],
               BEND_TYPED_RUNTIME=str(root / 'selfhost/src/runtime.mjs'), BEND_TYPED_BASE_CACHE='off')
    if runtime_template:
        env['BEND_TYPED_RUNTIME_TEMPLATE'] = runtime_template['file']
    write_json(out / 'report.json', report)
    for case in catalog['cases']:
        row = dict(id=case['id'], expected=case['expected'], passed=False)
        report['rows'].append(row)
        try:
            source = Q.bound(case['source'], root); inputs.append(source)
            directory = out / case['id']; directory.mkdir()
            copied = directory / 'input.bend'; shutil.copyfile(source['file'], copied)
            before = pin(copied)
            command = [plan['engine']['file'], cli['file'],
                       *[v.replace('{source}', str(copied)).replace('{out}', str(directory)) for v in case['args']]]
            child = run(command, cwd=directory, stdout=directory / 'stdout', stderr=directory / 'stderr', seconds=args.seconds, env=env)
            row['process'] = child
            row['sourceUnchanged'] = pin(copied)['sha256'] == before['sha256']
            row['passed'] = row['sourceUnchanged'] and Q.output_exact(child, case['expected'])
            if 'product' in case:
                product = directory / case['product']; row['product'] = pin(product)
                row['passed'] &= row['product']['bytes'] > 0
                if 'contains' in case:
                    row['passed'] &= case['contains'] in product.read_text()
                    row['productScope'] = 'Structural C emission only; use qualification.py for execution'
                if 'executeExpected' in case:
                    child = run([plan['engine']['file'], str(product)], cwd=directory,
                                stdout=directory / 'execute.stdout', stderr=directory / 'execute.stderr', seconds=args.seconds, env=env)
                    row['execution'] = child
                    row['passed'] &= Q.output_exact(child, case['executeExpected'])
        except Exception as error:
            row['error'] = repr(error); row['passed'] = False
        write_json(out / 'report.json', report)
    report['changedInputs'] = changed_inputs(inputs)
    report['cacheAfter'] = cache_state()
    report['cacheUnchanged'] = report['cacheBefore'] == report['cacheAfter']
    report['complete'] = len(report['rows']) == len(catalog['cases'])
    report['passed'] = report['complete'] and report['cacheUnchanged'] and not report['changedInputs'] and all(r['passed'] for r in report['rows'])
    write_json(out / 'report.json', report)
    print(json.dumps({k: report[k] for k in ('complete', 'passed')}))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    sys.exit(main())
