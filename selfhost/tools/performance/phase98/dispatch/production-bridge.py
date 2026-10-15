#!/usr/bin/env python3
"""Reuse frozen Phase96 full-value expectations with exact changed core helpers."""
import argparse
import copy
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
from prepare import ROOT, HERE, D04, declaration, pin


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--candidate', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); candidate = a.candidate.resolve(); out = a.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase98') and not out.exists()
    old_dir = ROOT / 'selfhost/build/phase96/production-full02'
    old = json.loads((old_dir / 'manifest.json').read_text())
    receipt = json.loads((candidate / 'receipt.json').read_text())
    assert pin(candidate / 'compiler.bend') == receipt['candidate']
    for row in old['frozenInputs']: assert pin(row['file']) == row
    source = (candidate / 'compiler.bend').read_text()
    changes = [next(r for r in receipt['changes'] if r['name'] == n) for n in ['core_rebuild', 'core_apply_span']]
    d04 = D04.read_text()
    comparators = '\n'.join(declaration(d04, n)[0] for n in ['p88_string_eq_go', 'p88_string_eq'])
    generated = {}
    for filename in ['extracted.bend', 'library.bend', 'native.bend']:
        text = (old_dir / filename).read_text()
        assert text.startswith('import Base\n') and 'def p88_string_eq(' not in text
        text = text.replace('import Base\n', 'import Base\n\n' + comparators + '\n', 1)
        for row in changes:
            assert text.count(row['canonicalBefore']) == 1
            assert row['after'] in source
            text = text.replace(row['canonicalBefore'], row['after'], 1)
        generated[filename] = text
    assert 'def core_beta(' not in generated['library.bend']
    out.mkdir(parents=True)
    outputs = []
    def write(name, data):
        file = out / name; file.parent.mkdir(parents=True, exist_ok=True)
        file.write_bytes(data.encode() if isinstance(data, str) else data)
        value = pin(file); outputs.append(value); return value
    for filename, text in generated.items(): write(filename, text)
    write('native.expected.txt', (old_dir / 'native.expected.txt').read_bytes())
    write('cases.json', json.dumps(old['cases'], indent=2, ensure_ascii=False) + '\n')
    for filename in ['reference.py', 'serialize.bend']:
        write('methods/' + filename, (old_dir / 'methods' / filename).read_bytes())
    runner = ROOT / 'selfhost/proofs/phase96/production/run.mjs'
    write('methods/run.mjs', runner.read_bytes())
    for file in HERE.glob('*.py'): write('methods/' + file.name, file.read_bytes())
    inputs = old['frozenInputs'] + [pin(old_dir / 'manifest.json'), pin(candidate / 'receipt.json'), pin(candidate / 'compiler.bend'), pin(runner), pin(D04)]
    manifest = copy.deepcopy(old)
    manifest.update(kind='phase98-production-finite-regression-bridge', targetsRun=False, complete=True,
                    scope='Unchanged226 independent Phase96 expected results and32 native selections; exact changed core_rebuild/core_apply_span are reached through production substitution. Other17 changed wide callers, including core_beta, are not exercised here.',
                    parent=pin(old_dir / 'manifest.json'), candidate=receipt['candidate'],
                    frozenInputs=inputs + outputs, library=pin(out / 'library.bend'), native=pin(out / 'native.bend'),
                    candidateExtraction=[dict(name=r['name'], exactD04After=r['after'], originalCanonical=r['canonicalBefore'],
                                              canonicalBridge=r['canonicalBridge']) for r in changes],
                    referenceUnchanged=True, cases=old['cases'], nativeCaseIds=old['nativeCaseIds'],
                    originalExtractionScope='Original extraction entries describe the parent snapshot; two explicitly listed declarations are replaced by exact frozen candidate bodies.')
    assert len(manifest['cases']) == 226 and len(manifest['nativeCaseIds']) == 32
    assert (out / 'native.expected.txt').read_bytes() == (old_dir / 'native.expected.txt').read_bytes()
    for row in inputs: assert pin(row['file']) == row
    write('manifest.json', json.dumps(manifest, indent=2, ensure_ascii=False) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, out=str(out), cases=226, nativeCases=32,
                         changedOperations=[r['name'] for r in changes], native=pin(out / 'native.bend'))))


if __name__ == '__main__': main()
