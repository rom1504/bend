#!/usr/bin/env python3
"""Freeze executable finite observations of exact dispatch selectors; no targets."""
import argparse
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
from prepare import ROOT, HERE, D04, D04_SHA, declaration, pin, sha
from control_reference import BRANCHES, cases, bend_term


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate', required=True, type=Path)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    candidate = args.candidate.resolve(strict=True)
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase98') and not out.exists()
    receipt = json.loads((candidate / 'receipt.json').read_text())
    assert receipt['candidate'] == pin(candidate / 'compiler.bend')
    d04 = D04.read_text()
    assert sha(d04.encode()) == D04_SHA
    selectors = (candidate / 'selectors.d04.bend').read_text()
    candidate_text = (candidate / 'compiler.bend').read_text()
    assert all(block in candidate_text for block in selectors.split('\n\n') if block.strip())
    start = d04.index('type KTerm is Data:\n')
    typ = d04[start:d04.index('\n\n', start) + 1]
    helpers = [typ]
    spans = []
    for name in ['p88_string_eq_go', 'p88_string_eq', 'tg', 'core_literal']:
        body, span = declaration(d04, name)
        helpers.append(body); spans.append(span)
    serializer_file = ROOT / 'selfhost/proofs/phase96/production/serialize.bend'
    serializer = serializer_file.read_text().split('law p96.def:\n', 1)[0].replace('p96.', 'p98d.')
    renderers = []
    for name, branches in BRANCHES.items():
        enum = 'P98' + ''.join(p.capitalize() for p in name.split('_'))
        ctors = [enum + str(i) for i in range(len(branches))] + [enum + 'Default']
        assert all(c + '{}' in selectors for c in ctors)
        renderers.append('def p98d.' + name + '(x: ' + enum + ') -> String:\n  match x:\n' + ''.join('    case ' + c + '{}: "' + str(i) + '"\n' for i, c in enumerate(ctors)))
    rows = cases()
    wrappers = []
    for i, row in enumerate(rows):
        row['exportName'] = 'p98_dispatch_case_' + str(i).zfill(3)
        choices = ' ++ "," ++ '.join('p98d.' + name + '(p98_' + name + '_select(tag))' for name in BRANCHES)
        wrappers.append('@unsafe\ndef ' + row['exportName'] + '() -> String:\n'
                        '  +t : KTerm = ' + bend_term(row['input']) + '\n'
                        '  +tag : String = tg(t)\n'
                        '  "[[" ++ ' + choices + ' ++ "]," ++ p98d.string(tag) ++ "," ++ p98d.bool(core_literal(t)) ++ "," ++ p98d.term(t) ++ "]"\n')
    library = 'import Base\n\n' + '\n'.join(helpers) + '\n' + selectors + '\n' + serializer + '\n' + '\n'.join(renderers) + '\n' + '\n'.join(wrappers)
    entry = '\n@unsafe\ndef main() -> IO(Unit):\n  do IO<Unit>:\n'
    entry += ''.join('    Unit <- IO.print(' + row['exportName'] + '())\n' for row in rows[:-1])
    entry += '    IO.print(' + rows[-1]['exportName'] + '())\n'
    runner = ROOT / 'selfhost/proofs/phase96/production/run.mjs'
    plan_file = ROOT / 'selfhost/build/phase91/continuity01/plan.json'
    plan = json.loads(plan_file.read_text())
    b2 = dict(api=plan['roles']['b2'], **{key: plan['host'][key] for key in ['driver', 'runtime', 'base', 'directRuntime']})
    assert all(pin(p['file']) == p for p in b2.values())
    inputs = [pin(D04), pin(candidate / 'receipt.json'), pin(candidate / 'compiler.bend'), pin(candidate / 'selectors.d04.bend'), pin(serializer_file), pin(runner), pin(plan_file)]
    out.mkdir(parents=True)
    outputs = []
    def write(name, data):
        file = out / name
        file.parent.mkdir(parents=True, exist_ok=True)
        file.write_bytes(data.encode() if isinstance(data, str) else data)
        outputs.append(pin(file)); return outputs[-1]
    for file in sorted(HERE.glob('*.py')):
        write('methods/' + file.name, file.read_bytes())
    write('methods/run.mjs', runner.read_bytes())
    lib_pin = write('library.bend', library)
    native_pin = write('native.bend', library + entry)
    write('native.expected.txt', ''.join(json.dumps(row['expectedWire'], separators=(',', ':')) + '\n' for row in rows))
    write('cases.json', json.dumps(rows, indent=2, ensure_ascii=False) + '\n')
    manifest = dict(kind='phase98-production-selector-finite-controls', complete=True, targetsRun=False,
                    scope='Finite exact selector results, escaped tag and surviving complete original term. Does not invoke recursive infer/check/annotate branch bodies.',
                    candidate=receipt['candidate'], b2=b2, originalSources=inputs, frozenInputs=inputs+outputs,
                    extraction=spans, library=lib_pin, native=native_pin, cases=rows,
                    nativeCaseIds=[row['id'] for row in rows], independentSpecification='control_reference.py: explicit ordered tag membership, not generated from candidate selectors',
                    domain='All three KTerm constructors; arbitrary generic tags including Lit and Efq; Unicode scalar strings, NUL, duplicate children/removals, boundary U32 payloads and full spans.')
    assert all(pin(p['file']) == p for p in inputs)
    write('manifest.json', json.dumps(manifest, indent=2, ensure_ascii=False) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, out=str(out), cases=len(rows), native=native_pin)))


if __name__ == '__main__':
    main()
