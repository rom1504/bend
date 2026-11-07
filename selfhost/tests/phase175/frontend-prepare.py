#!/usr/bin/env python3
"""Metadata-only Phase175 source transport; never checks or runs Bend."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import source as assembly
import assets
from common import fresh_output, pin, require, verify, write_json

PARENT = dict(bytes=3161409, sha256='74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a')
DEFAULTS = []


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--module', type=Path, action='append', default=[])
    p.add_argument('--prelude', type=Path, action='append', default=[], help='New helper laws immediately before their first lexical use')
    p.add_argument('--replace', action='append', default=[], help='Exact original def name, never a protected declaration')
    p.add_argument('--export', action='append', default=[])
    p.add_argument('--native-main', action='store_true', help='Extract experimental main rather than hosted exports')
    p.add_argument('--assets', type=Path, default=ROOT/'selfhost/manifests/assets-native.json')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    recipe = ROOT/'selfhost/src/compiler.json'
    config = json.loads(recipe.read_text())
    canonical, source_map = assembly.maintained_assemble(recipe, ROOT/'selfhost', 'qbe', with_map=True)
    identity = dict(bytes=len(canonical), sha256=hashlib.sha256(canonical).hexdigest())
    require(identity == PARENT, 'Maintained parent differs from fixed Phase171 source')
    spec = importlib.util.spec_from_file_location('phase175_extract', ROOT/'experiments/phase147/tools/prepare.py')
    extractor = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(extractor)
    inputs = [pin(__file__), pin(assembly.__file__), pin(assets.__file__), pin(extractor.__file__), pin(recipe)]
    maintained = set(config['modules']) | {config['preamble']}
    entry = config['profiles']['qbe'].get('entryModule')
    if entry:
        maintained.add(entry)
    inputs.extend(pin(ROOT/'selfhost'/name) for name in sorted(maintained))
    _, original = assembly.blocks(canonical)
    original = [row for row in original if row['name'] != 'main']
    originals = {(row['kind'], row['name']): row for row in original}
    names = {row['name'] for row in original}
    allowed = set(a.replace)
    require(len(allowed) == len(a.replace), 'Duplicate --replace')
    require(not allowed.intersection(config.get('protectedDeclarations', {})), 'Protected replacement refused')
    require(all(('def', name) in originals for name in allowed), 'Replacement must name an original definition')
    replacements, additions, preludes, seen = {}, [], [], set()
    for paths, is_prelude in [(a.prelude, True), (a.module, False)]:
        for path in paths:
            path = path.resolve(strict=True)
            inputs.append(pin(path))
            _, rows = assembly.blocks(path.read_bytes())
            for row in rows:
                key = (row['kind'], row['name'])
                require(key not in seen, 'Repeated experimental declaration: ' + repr(key))
                seen.add(key)
                if row['name'] in names:
                    require(not is_prelude and key == ('def', row['name']) and row['name'] in allowed,
                            'Unlisted original replacement: ' + row['name'])
                    replacements[key] = row
                else:
                    require(not is_prelude or row['kind'] == 'law', 'Prelude permits new forward laws only')
                    (preludes if is_prelude else additions).append(row)
    require({name for _, name in replacements} == allowed, 'Unused --replace name')
    ordered = [replacements.get((r['kind'], r['name']), r) for r in original] + additions
    pending_laws = {row['name']: row for row in preludes}
    chunks, law_positions = [], []
    for row in ordered:
        refs = extractor.referenced_words(row['data'])
        for name in list(pending_laws):
            if name in refs:
                chunks.append(pending_laws.pop(name)['data'])
                law_positions.append(dict(name=name, before=row['name']))
        chunks.append(row['data'])
    require(not pending_laws, 'Unused helper forward law')
    body = b'\n'.join(chunks)
    exports = list(dict.fromkeys(DEFAULTS + a.export))
    roots = list(dict.fromkeys((['main'] if a.native_main else []) + exports))
    require(roots, 'Explicit --export or --native-main required; no implicit backend roots')
    require(not a.native_main or any(r['name']=='main' for r in additions), 'Experimental native main required')
    selected, inventory = extractor.extract([('phase175-combined', body)], roots, 4_000_000)
    document = assets.load_assets(a.assets, ROOT)
    base, carrier, stamp, base_inputs = assets.prepared_base(document, 'cache')
    engine = assets.asset(document, 'bun')
    inputs.extend([document['_manifest'], *base_inputs, engine])
    for item in inputs:
        verify(item)
    out = fresh_output(a.out, ROOT)
    (out/'compiler.bend').write_bytes(selected)
    write_json(out/'exports.json', dict(kind='bend-hosted-api-exports', version=1,
        exports=exports, protocol='hosted-api-v1', targets=['qbe'], preparationModes=['live', 'cache'],
        scope='Frontend-only private exports; qbe is the hosted transport schema tag, not backend qualification. No image promotion.'))
    write_json(out/'base-binding.json', dict(kind='phase175-prepared-base', version=1,
        assets=document['_manifest'], base=base, carrier=carrier, stamp=stamp, engine=engine))
    write_json(out/'manifest.json', dict(kind='phase175-api-source', version=1,
        complete=True, targetsRun=False, parent=identity, inputs=inputs,
        source=pin(out/'compiler.bend'), exportManifest=pin(out/'exports.json'),
        binding=pin(out/'base-binding.json'), exports=exports, nativeMain=a.native_main,
        replacements=[dict(name=name, originalSha256=hashlib.sha256(originals[(kind,name)]['data']).hexdigest(),
                           replacementSha256=hashlib.sha256(row['data']).hexdigest())
                      for (kind,name), row in replacements.items()],
        declarations=inventory, helperLawPositions=law_positions, originalSourceMap=source_map, protectedUnchanged=True,
        scope='Conservative explicit-export declaration closure after exact named replacements; source checking remains required.'))
    print(json.dumps(dict(source=pin(out/'compiler.bend'), declarations=len(inventory), replacements=len(replacements))))


if __name__ == '__main__':
    main()
