#!/usr/bin/env python3
"""Offline byte transport for ID18 parser transfer; never execute Bend targets."""
import argparse
import hashlib
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import source as assembly
from common import fresh_output, pin, require, write_json
spec = importlib.util.spec_from_file_location('extract155t', ROOT / 'experiments/phase147/tools/prepare.py')
E = importlib.util.module_from_spec(spec)
spec.loader.exec_module(E)


def rename(data, names):
    """Replace exact identifier tokens outside the retained extractor's literals."""
    text = data.decode()
    output, start = [], 0
    for literal in E.LITERALS.finditer(text):
        output.append(E.WORDS.sub(lambda word: names.get(word[0], word[0]), text[start:literal.start()]))
        output.append(literal[0])
        start = literal.end()
    output.append(E.WORDS.sub(lambda word: names.get(word[0], word[0]), text[start:]))
    return ''.join(output).encode()


def fixture_helpers(label, payload):
    """Transport exact text through bounded literals and balanced named joins."""
    stem = 'p155t_' + label
    chunks = [payload[start:start + 256] for start in range(0, len(payload), 256)]
    literals = [json.dumps(chunk, ensure_ascii=False) for chunk in chunks]
    require(''.join(json.loads(literal) for literal in literals) == payload, 'Fixture literal round-trip differs')
    output, names = [], []
    for index, literal in enumerate(literals):
        name = f'{stem}_chunk_{index}'
        output.append(f'\ndef {name}() -> String:\n  {literal}\n')
        names.append(name)
    level = 0
    while len(names) > 1:
        following = []
        for index in range(0, len(names), 2):
            if index + 1 == len(names):
                following.append(names[index])
            else:
                name = f'{stem}_join_{level}_{index // 2}'
                output.append(f'\ndef {name}() -> String:\n  {names[index]}() ++ {names[index + 1]}()\n')
                following.append(name)
        names = following
        level += 1
    output.append(f'\ndef {stem}_source(n: U32) -> String:\n  "# iteration " ++ U32.show(n) ++ "\\n" ++ {names[0]}()\n')
    return ''.join(output), dict(chunks=len(chunks), maxLiteralCharacters=max(map(len, chunks)),
                                 joinLevels=level, literalRoundTripByteIdentity=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    canonical = assembly.maintained_assemble(ROOT / 'selfhost/src/compiler.json', ROOT / 'selfhost', 'qbe')
    qualification = ROOT / 'implementation/phase152/qualification.json'
    require(hashlib.sha256(canonical).hexdigest() == json.loads(qualification.read_text())['source']['sha256'], 'Qualified source changed')
    _, canonical_blocks = assembly.blocks(canonical)
    no_main = b''.join(row['data'] for row in canonical_blocks if row['name'] != 'main')
    roots = ['f_load_graph_trace']
    closure, inventory = E.extract([('canonical', no_main)], roots)
    _, blocks = assembly.blocks(closure)
    functions = {row['name'] for row in blocks if row['kind'] != 'type'}
    references = {name: set() for name in functions}
    for row in blocks:
        if row['name'] in functions:
            references[row['name']].update(E.referenced_words(row['data']) & functions)
    affected = {'f_valid_name'}
    while True:
        more = {name for name, refs in references.items() if refs & affected}
        if more <= affected:
            break
        affected.update(more)
    names = {name: 'p155t_clone_' + name for name in affected if name != 'f_valid_name'}
    names['f_valid_name'] = 'p155x_valid'
    require(all(root in names for root in roots), 'Parser roots do not reach predicate')
    chosen = [row for row in blocks if row['name'] in affected and row['name'] != 'f_valid_name']
    inverse = {value: key for key, value in names.items()}
    renamed = [rename(row['data'], names) for row in chosen]
    require(all(rename(new, inverse) == row['data'] for row, new in zip(chosen, renamed)), 'Renaming changed non-identifier bytes')
    out = fresh_output(args.out, ROOT)
    clone = out / 'parser-clone.bend'
    clone.write_bytes(b'# Mechanical private parser clone; shared types and unaffected functions.\n' + b'\n'.join(renamed))
    compiler_fixture = out / 'compiler-verifier-slice.bend'
    compiler_payload, compiler_inventory = E.extract([('canonical', no_main)], ['p111v_functions'])
    compiler_fixture.write_bytes(compiler_payload)
    assets_path = ROOT / 'selfhost/manifests/assets-native.json'
    base_asset = json.loads(assets_path.read_text())['assets']['base']
    base_path = ROOT / base_asset['file']
    require(pin(base_path)['sha256'] == base_asset['sha256'], 'Pinned Base changed')
    fixtures = [('compiler', compiler_fixture),
                ('ordinary', ROOT / 'selfhost/tests/consolidation/native-broad/coverage-expression-128.bend'),
                ('base', base_path)]
    fixture_file = out / 'fixtures.bend'
    text = '# Exact fixed payloads; iteration comment forces fresh source preparation.\n'
    fixture_rows = []
    for label, path in fixtures:
        payload = path.read_text()
        prefix = ''
        helpers, chunking = fixture_helpers(label, prefix + payload)
        text += helpers
        fixture_rows.append(dict(label=label, source=pin(path), addedPrefix=prefix,
                                 payloadSha256=hashlib.sha256((prefix + payload).encode()).hexdigest(),
                                 literalPreparation=chunking))
    fixture_file.write_text(text)
    write_json(out / 'manifest.json', dict(kind='phase155-parser-transfer-source', version=1,
        complete=True, targetsRun=False, canonicalSha256=hashlib.sha256(canonical).hexdigest(),
        inputs=[pin(__file__), pin(E.__file__), pin(assembly.__file__), pin(qualification), pin(assets_path), pin(base_path)],
        roots=roots, closure=inventory, rename=names,
        clonedDeclarations=len(chosen), clonedFunctions=len(affected) - 1,
        inverseRenameByteIdentity=True, sharedDatatypes=True,
        predicateSubstitution=dict(old='f_valid_name', new='p155x_valid'),
        fixtures=fixture_rows, compilerFixtureDeclarations=compiler_inventory,
        products=[pin(clone), pin(fixture_file), pin(compiler_fixture)]))
    print(json.dumps(dict(out=str(out), clonedDeclarations=len(chosen), clonedFunctions=len(affected)-1,
                          cloneBytes=clone.stat().st_size, targetsRun=False)))


if __name__ == '__main__':
    main()
