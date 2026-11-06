#!/usr/bin/env python3
"""Apply explicit Phase171 overlays to ALL canonical source; no target execution."""
import argparse
import base64
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
import common
import source as assembly
from common import fresh_output, pin, require, verify, write_json

PARENT = dict(bytes=3150535, sha256='434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71')


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def signature(row):
    text = row['data'][row['headerOffset']-row['offset']:]
    lines = text.splitlines()
    result = []
    for line in lines:
        result.append(line)
        if line.rstrip().endswith(b':'):
            return re.sub(rb'\s+', b' ', b'\n'.join(result)).strip()
    raise ValueError('Definition has no complete signature: '+row['name'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--module', type=Path, action='append', default=[])
    p.add_argument('--prelude', type=Path, action='append', default=[])
    p.add_argument('--replace', action='append', default=[])
    p.add_argument('--export', action='append', default=[])
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    recipe = ROOT/'selfhost/src/compiler.json'
    config = json.loads(recipe.read_text())
    canonical, source_map = assembly.maintained_assemble(recipe, ROOT/'selfhost', 'qbe', with_map=True)
    require(identity(canonical) == PARENT, 'Fixed Phase170 parent differs')
    preamble, originals = assembly.blocks(canonical)
    original_by_key = {(r['kind'], r['name']): r for r in originals}
    names = {r['name'] for r in originals}
    require(len(original_by_key) == len(originals), 'Duplicate canonical declarations')
    require(('def', 'main') in original_by_key, 'Canonical native main missing')
    allowed = set(a.replace)
    require(len(allowed) == len(a.replace), 'Duplicate --replace')
    require('main' not in allowed, 'Original native main must remain unchanged')
    require(not allowed.intersection(config.get('protectedDeclarations', {})), 'Protected declaration replacement refused')
    require(all(('def', name) in original_by_key for name in allowed), 'Replacement must name an existing definition')
    spec = importlib.util.spec_from_file_location('phase171_native_words', ROOT/'experiments/phase147/tools/prepare.py')
    lexical = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(lexical)
    inputs = [pin(__file__), pin(common.__file__), pin(assembly.__file__), pin(lexical.__file__), pin(recipe)]
    maintained = set(config['modules']) | {config['preamble']}
    entry = config['profiles']['qbe'].get('entryModule')
    if entry:
        maintained.add(entry)
    inputs.extend(pin(ROOT/'selfhost'/name) for name in sorted(maintained))
    replacements, extra, laws, seen = {}, [], [], set()
    for paths, is_prelude in [(a.prelude, True), (a.module, False)]:
        for path in paths:
            path = path.resolve(strict=True)
            inputs.append(pin(path))
            prefix, rows = assembly.blocks(path.read_bytes())
            require(not prefix.strip(), 'Overlay preamble/imports are not transported: '+str(path))
            for row in rows:
                key = (row['kind'], row['name'])
                require(key not in seen, 'Repeated experimental declaration: '+repr(key))
                seen.add(key)
                row = dict(row, experimentalSource=str(path))
                if key in original_by_key:
                    require(not is_prelude and key[0] == 'def' and key[1] in allowed,
                            'Unlisted original replacement: '+repr(key))
                    require(signature(row) == signature(original_by_key[key]),
                            'Replacement changes original signature: '+key[1])
                    replacements[key] = row
                else:
                    # A missing implementation may be appended under an existing
                    # original law. Neither the law nor its position is replaced.
                    require(row['name'] not in names or
                            (row['kind'] == 'def' and ('law', row['name']) in original_by_key),
                            'Experimental declaration conflicts with original owner: '+row['name'])
                    require(not is_prelude or row['kind'] == 'law', 'Prelude permits new laws only')
                    (laws if is_prelude else extra).append(row)
    require({name for _, name in replacements} == allowed, 'Unused replacement name')
    pending = {r['name']: r for r in laws}
    chunks, trace, inverse_blocks, law_positions = [preamble], [], {}, []
    offset = len(preamble)

    def add(data, operation, row, original=None):
        nonlocal offset
        if chunks and chunks[-1] and not chunks[-1].endswith(b'\n') and data and not data.startswith(b'\n'):
            chunks.append(b'\n')
            trace.append(dict(operation='separator', begin=offset, end=offset+1, **identity(b'\n')))
            offset += 1
        begin = offset
        chunks.append(data)
        offset += len(data)
        record = dict(operation=operation, begin=begin, end=offset, kind=row['kind'], name=row['name'], **identity(data))
        if original is not None:
            record['originalBegin'] = original['offset']
            record['originalEnd'] = original['offset'] + len(original['data'])
            record['originalIdentity'] = identity(original['data'])
        if 'experimentalSource' in row:
            record['experimentalSource'] = row['experimentalSource']
        trace.append(record)

    def insert_laws(row):
        refs = lexical.referenced_words(row['data'])
        for name in list(pending):
            if name in refs:
                law = pending.pop(name)
                add(law['data'], 'insert-law', law)
                law_positions.append(dict(name=name, before=row['name']))

    for original in originals:
        key = (original['kind'], original['name'])
        chosen = replacements.get(key, original)
        insert_laws(chosen)
        if key in replacements:
            inverse_blocks[original['name']] = base64.b64encode(original['data']).decode('ascii')
        add(chosen['data'], 'replace' if key in replacements else 'keep', chosen, original)
    for row in extra:
        insert_laws(row)
        add(row['data'], 'append', row)
    require(not pending, 'Unused helper forward law')
    output = b''.join(chunks)
    require(len(output) <= 8_000_000, 'Full source exceeds 8 MB bound')
    # Validate the recorded inverse against the ACTUAL output spans, rather than
    # just replaying the original rows that we already hold in memory.
    inverse = [output[:len(preamble)]]
    for row in trace:
        data = output[row['begin']:row['end']]
        require(identity(data) == {k: row[k] for k in ('bytes', 'sha256')}, 'Trace span differs')
        if row['operation'] == 'keep':
            inverse.append(data)
        elif row['operation'] == 'replace':
            inverse.append(base64.b64decode(inverse_blocks[row['name']], validate=True))
    require(b''.join(inverse) == canonical, 'Recorded inverse does not recover every original byte')
    _, final_rows = assembly.blocks(output)
    final_keys = [(r['kind'], r['name']) for r in final_rows]
    require(len(final_keys) == len(set(final_keys)), 'Duplicate final declaration')
    require(set(original_by_key) <= set(final_keys), 'Canonical declaration lost')
    # Additional comments/newlines can attach to a following block, so use the
    # maintained normalized protected-declaration contract as well as span checks.
    for name, expected in config.get('protectedDeclarations', {}).items():
        selected = [r for r in final_rows if r['name'] == name]
        require(assembly.digest(assembly.normalized(selected)) == expected['normalizedSha256'],
                'Protected declaration changed in final source: '+name)
    main_part = next(r for r in trace if r.get('kind') == 'def' and r.get('name') == 'main')
    require(main_part['operation'] == 'keep', 'Original main replaced')
    exports = a.export or ['main']
    require(len(exports) == len(set(exports)) and all(('def', x) in final_keys for x in exports), 'Invalid exports')
    for item in inputs:
        verify(item)
    out = fresh_output(a.out, ROOT)
    (out/'compiler.bend').write_bytes(output)
    write_json(out/'inverse-originals.json', dict(encoding='base64', originalBlocks=inverse_blocks))
    write_json(out/'exports.json', dict(kind='bend-hosted-api-exports', version=1, exports=exports,
        protocol='hosted-api-v1', targets=['qbe'], preparationModes=['live','cache'],
        scope='Checking full native source only; no declaration pruning or image qualification.'))
    write_json(out/'report.json', dict(kind='phase171-full-native-source', version=1, complete=True,
        targetsRun=False, source=pin(out/'compiler.bend'), parent=PARENT, inputs=inputs,
        originalPreamble=identity(preamble), originalSourceMap=source_map, operations=trace,
        inverse=pin(out/'inverse-originals.json'), inverseExact=True, signaturesPreserved=True,
        mainUnchanged=True, protectedUnchanged=True, canonicalDeclarations=len(originals),
        finalDeclarations=len(final_rows), prunedDeclarations=0, helperLawPositions=law_positions,
        exportManifest=pin(out/'exports.json'), exports=exports,
        scope='All canonical source and native main retained. Full emitted-source checking and native image qualification remain required.'))
    print(json.dumps(dict(source=pin(out/'compiler.bend'), declarations=len(final_rows),
                          replacements=len(replacements), pruned=0, inverseExact=True)))


if __name__ == '__main__':
    main()
