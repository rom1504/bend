#!/usr/bin/env python3
"""Offline one-operation faults in frozen final emitted C; never change compiler source."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def body_span(text, name):
    pattern = r'(?m)^(?:NF_INLINE Term|INLINE Term|INLINE void) ' + re.escape(name) + r'\([^;{}]*\)\s*\{'
    matches = list(re.finditer(pattern, text)); assert len(matches) == 1, name
    start = matches[0].end() - 1; depth = 0
    for token in re.finditer(r'/\*[\s\S]*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|[{}]', text[start:]):
        if token[0] == '{': depth += 1
        elif token[0] == '}':
            depth -= 1
            if depth == 0: return start, start + token.end()
    raise AssertionError('Unterminated C function ' + name)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--controls', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase102') and not out.exists(); out.mkdir(parents=True)
    inputs = {}
    def bind(value):
        actual = pin(value['file'] if isinstance(value, dict) else value)
        if isinstance(value, dict): assert actual == value
        assert inputs.setdefault(actual['file'], actual) == actual
        return actual
    control_pin = bind(a.controls); controls = json.loads(a.controls.read_text()); assert controls['complete'] and not controls.get('error')
    manifest_pin = bind(controls['manifest']); manifest = json.loads(Path(manifest_pin['file']).read_text()); assert manifest['complete']
    emission_pin = bind(controls['emission']); emission = json.loads(Path(emission_pin['file']).read_text()); assert emission['complete']
    bind(emission['compilerSource']); bind(emission['api']); method = bind(__file__)
    symbol = lambda name: 'NF_FID_' + ''.join(str(ord(c)) + '_' for c in name)
    specs = [
        dict(id='trmc-wrong-hole-field', case='trmc-construction', function=symbol('swap_build') + '_trmc',
             old='nf_out[1] = term_loc(ntr_node_35) + 2;', new='nf_out[1] = term_loc(ntr_node_35) + 1;',
             operation='Change one pending-tail field offset from the third field to the second.',
             rationale='The three-field WideStep traversal observes both String fields and the recursive tail. This overwrites a visible String field and leaves the actual tail hole unfilled.'),
        dict(id='trmc-recursive-argument-order', case='trmc-construction', function=symbol('swap_build') + '_trmc',
             old='Term nf_arg_1 = v_4294967268;\nTerm nf_arg_2 = v_4294967267;',
             new='Term nf_arg_1 = v_4294967267;\nTerm nf_arg_2 = v_4294967268;',
             operation='Transpose the two recursive String actuals as one argument-order mutation.',
             rationale='Both owned moves remain present, but the intended recursive swap disappears. The tenth full-output line must change from abcd/cd;cd/abcd;abcd/cd;cdabcd to abcd/cd;abcd/cd;abcd/cd;abcdcd.'),
        dict(id='observer-discard-order-result', case='observer-prefix', function=symbol('$observer.adapter.String.cmp'),
             old='Term no_scalar_result = no_observed[0];', new='Term no_scalar_result = term_pak(CID_EQ, 0);',
             operation='Replace one adapter scalar-result assignment with equality.',
             rationale='The frozen prefix/prefix-tail payload requires less-than while observing both original strings. Returned roots remain owned, but the ordering result is deliberately wrong.'),
    ]
    rows = []
    for spec in specs:
        matches = [x for x in manifest['records'] if x['id'] == spec['case']]; assert len(matches) == 1
        case = matches[0]; product = controls['products'][case['source']]
        source = bind(product['source']); original_c = bind(product['variants']['candidate']['c'])
        prior = [x for x in controls['executions'] if x['case'] == case['id'] and x['workers'] == 1 and x['role'] == 'candidate']
        assert len(prior) == 1 and prior[0]['passed'] and prior[0]['returncode'] == 0
        assert any(x['source'] == source and x['c'] == original_c for x in emission['programs'])
        text = Path(original_c['file']).read_text(); begin, end = body_span(text, spec['function'])
        body = text[begin:end]; assert body.count(spec['old']) == 1
        at = begin + body.index(spec['old']); candidate = text[:at] + spec['new'] + text[at+len(spec['old']):]
        assert candidate[:at] + spec['old'] + candidate[at+len(spec['new']):] == text
        folder = out / spec['id']; folder.mkdir(); path = folder / 'program.c'; path.write_text(candidate)
        expected = Path(bind(case['expected'])['file']).read_bytes() if 'expected' in case else case.get('stdout', '').encode()
        (folder / 'expected.stdout').write_bytes(expected); (folder / 'expected.stderr').write_bytes(case.get('stderr', '').encode())
        rows.append({**spec, 'source':source, 'originalC':original_c, 'mutantC':bind(path),
            'offset':at, 'originalLine':text[:at].count('\n') + 1, 'replacementCount':1, 'inverseExact':True,
            'controlRecord':case, 'priorPassingExecution':prior[0],
            'expectedStdout':bind(folder / 'expected.stdout'), 'expectedStderr':bind(folder / 'expected.stderr'),
            'expectedExit':case.get('returncode', 0), 'argv':case.get('argv', []), 'workers':1})
    for item in inputs.values(): assert pin(item['file']) == item
    result = dict(kind='phase102-generated-C-fault-plan', complete=True, targetsRun=False, imageQualified=False,
        method=method, controls=control_pin, manifest=manifest_pin, emission=emission_pin,
        compilerSource=emission['compilerSource'], inputs=list(inputs.values()), rows=rows,
        scope='Three independent single-operation generated-C mutations. Original compiler/source/products and full oracles unchanged. Successful C build followed by a bounded completed semantic mismatch demonstrates a control catches that fault. Build failure, resource stop or timeout is inconclusive; no universal law or optimization-correctness proof.')
    (out / 'plan.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, plan=pin(out / 'plan.json'), mutations=len(rows))))


if __name__ == '__main__': main()
