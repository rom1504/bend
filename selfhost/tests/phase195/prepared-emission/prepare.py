#!/usr/bin/env python3
"""Freeze a small same-process emission batch; metadata only, no compiler calls."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import assets
from common import pin, require, verify

METHOD = ROOT / 'experiments/phase147/tools/prepare.py'
spec = importlib.util.spec_from_file_location('prepared_emission_extract', METHOD)
extractor = importlib.util.module_from_spec(spec)
spec.loader.exec_module(extractor)
ROOTS = ['p88_cache_prepare', 'p86_plan', 'p169np_plan']
EMIT = ['x181_prepared', 'x188_many', 'x188_render', 'x188_assemble']


def read(file):
    return json.loads(Path(file).read_text())


def authority(file):
    receipt = pin(file)
    api = read(receipt['file'])
    require(api.get('kind') == 'bend-checked-hosted-api' and api.get('complete') is True
            and api.get('checked') is True and not api.get('error') and not api.get('changedInputs'),
            'Complete checked API required: ' + str(file))
    require(all(x in api['exports'] for x in ROOTS + EMIT), 'Missing checked exports')
    source = verify(api['source']).read_bytes()
    manifest = pin(Path(api['source']['file']).with_name('manifest.json'))
    preparation = read(manifest['file'])
    require(preparation.get('kind') == 'phase190-api-source' and preparation.get('complete') is True
            and preparation['source'] == api['source'], 'Exact source preparation required')
    # Reuse the existing conservative extractor, never infer a closure by naming conventions.
    closure, declarations = extractor.extract([('source', source)], ROOTS)
    recorded = {(r['kind'], r['name']): (r['bytes'], r['sha256']) for r in preparation['declarations']}
    _, actual_blocks = extractor.assembly.blocks(source)
    actual = {(r['kind'], r['name']): r['data'] for r in actual_blocks}
    for row in declarations:
        key = (row['kind'], row['name'])
        data = actual[key]
        # Phase147 extract joins original blocks with one literal newline. The
        # parser attaches that separator to the next block, including the first
        # block after its import header. Authenticate exactly that known framing.
        require(data.startswith(b'\n'), 'Missing extractor block separator')
        original = data[1:]
        require(recorded.get(key) == (len(original), hashlib.sha256(original).hexdigest()),
                'Actual preparation declaration differs from manifest: ' + row['name'])
    binding_pin = preparation['binding']
    binding = read(verify(binding_pin))
    require(binding.get('kind') == 'phase175-prepared-base' and binding.get('stamp'), 'Prepared Base required')
    inputs = [receipt, api['source'], api['api'], manifest, binding_pin,
              *api['inputs'], *preparation['inputs'], binding['assets'], binding['base'],
              binding['carrier'], binding['engine']]
    for item in inputs:
        verify(item)
    binding_identity = dict(binding, assets={k: binding['assets'][k] for k in ['bytes', 'sha256']})
    return dict(receipt=receipt, api=api['api'], source=api['source'], manifest=manifest,
                binding=binding_pin, bindingValue=binding, bindingIdentity=binding_identity, inputs=inputs,
                preparationIdentity=dict(roots=ROOTS, declarations=len(declarations), bytes=len(closure),
                                         sha256=hashlib.sha256(closure).hexdigest()))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--producer', type=Path, required=True)
    p.add_argument('--emitter', action='append', required=True, help='NAME=checked API report.json')
    p.add_argument('--cases', required=True, help='Explicit native45 comma-separated IDs, maximum six')
    p.add_argument('--assets', type=Path, required=True)
    p.add_argument('--compare-ordinary', action='store_true', help='Also prepare independently per emitter and require exact assembly/object bytes')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    require(not a.out.exists(), 'Fresh metadata plan required')
    producer = authority(a.producer)
    roles = []
    for text in a.emitter:
        name, sep, file = text.partition('=')
        require(sep and re.fullmatch(r'[a-z][a-z0-9-]*', name) and name not in [r['name'] for r in roles], 'Unique simple role name required')
        role = authority(file)
        require(role['preparationIdentity'] == producer['preparationIdentity'], 'Preparation closure differs: ' + name)
        require(role['bindingIdentity'] == producer['bindingIdentity'], 'Base/assets/engine binding differs: ' + name)
        roles.append(dict(name=name, **role))
    require(1 <= len(roles) <= 4, 'One to four explicit emitters required')
    catalog_pin = pin(ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json')
    split_pin = pin(ROOT / 'selfhost/tests/phase195/cases.json')
    catalog, split = read(catalog_pin['file']), read(split_pin['file'])
    require(all(split['catalog'][k] == catalog_pin[k] for k in ['bytes', 'sha256']), 'Frozen catalog differs')
    ids = a.cases.split(',')
    require(1 <= len(ids) <= 6 and len(set(ids)) == len(ids), 'One to six unique explicit cases')
    known = {c['id']: c for c in catalog['cases']}
    partition = split['development'] + split['heldout']
    require(len(known) == 45 and len(partition) == 45 and set(partition) == set(known), 'Frozen native45 partition differs')
    cases = []
    for name in ids:
        require(name in known, 'Unknown case: ' + name)
        case = known[name]
        row = dict(id=name, partition='development' if name in split['development'] else 'heldout')
        for key in ['source', 'expectedFile']:
            item = pin(Path(catalog_pin['file']).parent / '../..' / case[key]['file'])
            require(all(item[k] == case[key][k] for k in ['bytes', 'sha256']), 'Case identity differs: ' + name)
            row[key] = item
        cases.append(row)
    document = assets.load_assets(a.assets, ROOT)
    require(all(document['_manifest'][k] == producer['bindingValue']['assets'][k]
                for k in ['bytes', 'sha256']), 'Machine assets differ from preparation binding')
    runtime = assets.asset(document, 'qbe-runtime')
    inputs = [pin(__file__), pin(Path(__file__).with_name('driver.mjs')), pin(METHOD),
              pin(extractor.assembly.__file__), pin(ROOT / 'selfhost/tools/build/hosted.mjs'),
              pin(assets.__file__), catalog_pin, split_pin, document['_manifest'], runtime,
              *producer['inputs'], *[x for r in roles for x in r['inputs']],
              *[c[k] for c in cases for k in ['source', 'expectedFile']]]
    unique = {}
    for item in inputs:
        verify(item)
        require(item['file'] not in unique or unique[item['file']] == item, 'Conflicting input pins')
        unique[item['file']] = item
    result = dict(kind='phase195-shared-preparation-plan', version=1, complete=True, targetsRun=False,
                  producer=producer, roles=roles, cases=cases, catalog=catalog_pin, partition=split_pin,
                  runtime=runtime, assets=document['_manifest'], compareOrdinary=a.compare_ordinary,
                  inputs=list(unique.values()),
                  scope='Exact same preparation declaration closure and Base binding; checked Bend owns all source/compiler logic. Request-local in-memory sharing only; no checking certificate or persistent cache.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(plan=pin(a.out), roles=[r['name'] for r in roles], cases=ids,
                          preparation=producer['preparationIdentity'], targetsRun=False)))


if __name__ == '__main__':
    main()
