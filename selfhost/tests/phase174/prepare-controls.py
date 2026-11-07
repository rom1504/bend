#!/usr/bin/env python3
"""Append frozen Phase171 controls to the full maintained source; execute nothing."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import assets
import source as assembly
from common import fresh_output, pin, require, verify, write_json


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--canonical-source', type=Path,
                        help='Optional frozen full source; must equal current maintained assembly')
    parser.add_argument('--assets', type=Path, default=ROOT/'selfhost/manifests/assets-native.json')
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--plan', action='store_true', help='Authenticate and report; create no output')
    args = parser.parse_args()
    recipe = ROOT/'selfhost/src/compiler.json'
    catalog_file = Path(__file__).with_name('controls.json')
    config = json.loads(assembly.read(recipe))
    catalog = json.loads(assembly.read(catalog_file))
    require(catalog.get('kind') == 'phase174-additive-control-source' and catalog.get('version') == 1,
            'Unknown control catalogue')
    require(catalog['canonicalProfile'] == 'qbe' and len(catalog['modules']) == 4,
            'Exactly the four fixed control modules and full QBE profile are required')
    require(sum(row['count'] for row in catalog['groups']) == catalog['expectedControls'] == 77,
            'Expected unchanged 77-control inventory')
    module_names = set(config['modules']) | {config['preamble']}
    entry = config['profiles']['qbe'].get('entryModule')
    if entry:
        module_names.add(entry)
    inputs = [pin(__file__), pin(catalog_file), pin(recipe), pin(assembly.__file__),
              pin(assets.__file__), pin(ROOT/'selfhost/tools/build/common.py')]
    inputs.extend(pin(assembly.safe_path(ROOT/'selfhost', name)) for name in sorted(module_names))
    canonical = assembly.maintained_assemble(recipe, ROOT/'selfhost', 'qbe')
    if args.canonical_source:
        frozen = pin(args.canonical_source)
        require(verify(frozen).read_bytes() == canonical,
                'Frozen canonical source differs from maintained assembly')
        inputs.append(frozen)
    _, original = assembly.blocks(canonical)
    original_names = {row['name'] for row in original}
    require(('def', 'main') in {(row['kind'], row['name']) for row in original},
            'Full canonical native main must remain present')
    require({'p171sc_retry', 'p171s_seed', 'p171s_put'} <= original_names,
            'Phase171 implementation must already be integrated; overlays are not accepted')
    chunks, additions, module_records = [canonical], [], []
    seen, owners = set(), {}
    offset = len(canonical)
    for expected in catalog['modules']:
        path = assembly.safe_path(ROOT, expected['file'])
        bound = pin(path)
        require(all(bound[key] == expected[key] for key in ('bytes', 'sha256')),
                'Frozen Phase171 control module changed: ' + str(path))
        inputs.append(bound)
        data = verify(bound).read_bytes()
        prefix, rows = assembly.blocks(data)
        require(not prefix, 'Control module has a nondeclaration preamble')
        for row in rows:
            key = (row['kind'], row['name'])
            require(row['name'] not in original_names, 'Control would replace canonical declaration: '+row['name'])
            require(key not in seen, 'Duplicate control declaration: '+repr(key))
            require(row['name'] not in owners or owners[row['name']] == str(path),
                    'Control law/definition split across modules')
            seen.add(key)
            owners[row['name']] = str(path)
            additions.append(dict(kind=row['kind'], name=row['name'], source=bound,
                                  generatedStartByte=offset+1+row['offset'], **identity(row['data'])))
        chunks.extend([b'\n', data])
        module_records.append(dict(source=bound, generatedStartByte=offset+1,
                                   declarations=len(rows)))
        offset += 1+len(data)
    candidate = b''.join(chunks)
    require(candidate[:len(canonical)] == canonical, 'Canonical prefix changed')
    _, combined = assembly.blocks(candidate)
    names = {row['name'] for row in combined if row['kind'] in ('def', 'law')}
    exports = catalog['qbeExports'] + [row['export'] for row in catalog['groups']]
    require(len(exports) == len(set(exports)) and len(exports) <= 256 and set(exports) <= names,
            'Missing or duplicate exported roots')
    # Assembly already checks protected declarations. Recheck the appended result
    # independently so additional modules cannot alter any protected name.
    protected = assembly.grouped(combined)
    for name, expected in config.get('protectedDeclarations', {}).items():
        require(name in protected and assembly.digest(assembly.normalized(protected[name])) == expected['normalizedSha256'],
                'Protected declaration changed in control source: '+name)
    document = assets.load_assets(args.assets, ROOT)
    base, carrier, stamp, base_inputs = assets.prepared_base(document, 'cache')
    engine = assets.asset(document, 'bun')
    inputs.extend([document['_manifest'], *base_inputs, engine])
    for item in inputs:
        verify(item)
    summary = dict(canonical=identity(canonical), sourceIdentity=identity(candidate),
                   canonicalDeclarations=len(original), addedDeclarations=len(additions),
                   exports=exports, expectedControls=77, protectedUnchanged=True,
                   canonicalPrefixExact=True, targetsRun=False)
    if args.plan:
        print(json.dumps(dict(summary, planOnly=True), indent=2))
        return
    out = fresh_output(args.out, ROOT)
    (out/'compiler.bend').write_bytes(candidate)
    write_json(out/'exports.json', dict(kind='bend-hosted-api-exports', version=1,
        exports=exports, protocol='hosted-api-v1', targets=['qbe'], preparationModes=['live','cache'],
        scope='Full checked control API source; not the separately acquired canonical release API.'))
    write_json(out/'base-binding.json', dict(kind='phase174-prepared-base', version=1,
        assets=document['_manifest'], base=base, carrier=carrier, stamp=stamp, engine=engine))
    write_json(out/'manifest.json', dict(kind='phase174-control-api-source', version=1,
        complete=True, **summary, inputs=inputs, canonicalProfile='qbe',
        source=pin(out/'compiler.bend'), exportManifest=pin(out/'exports.json'),
        binding=pin(out/'base-binding.json'), modules=module_records, additions=additions,
        groups=catalog['groups'], replacements=[], omittedDeclarations=[],
        inverse=dict(method='Remove exact appended suffix', retainedPrefixBytes=len(canonical),
                     recoveredCanonical=identity(candidate[:len(canonical)])),
        scope='Metadata-only additive source transport. Source checking and all77 observations remain required; no release image or qualification claim.'))
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
