#!/usr/bin/env python3
"""Offline, source-pinned diagnostic C policy variants; never build or execute."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import re

SOURCE_SHA = 'fc00ef256b469692940c81750e8e57188e165bf112f5aa0ba7a603bdcb8d6f63'
OUTPUT_SHA = 'ba684411b2ef7ffe051c94def9384cbf1051153e224644cec141d8a0f6bf8458'
ROOT = Path(__file__).resolve().parents[6]


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def cid(name):
    return 'CID__CTOR_' + ''.join(str(ord(c)) + '_' for c in name)


def function(text, name):
    matches = list(re.finditer(r'\b' + re.escape(name) + r'\(Env e, bool seq, Term\* nf_out[^;{}]*\)\s*\{', text))
    assert len(matches) == 1, (name, len(matches))
    start = matches[0].end() - 1; depth = 0
    tokens = r'/\*[\s\S]*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|[{}]'
    for token in re.finditer(tokens, text[start:]):
        if token[0] == '{': depth += 1
        elif token[0] == '}':
            depth -= 1
            if depth == 0: return text[start:start + token.end()]
    raise AssertionError('unterminated ' + name)


def policy_block(constructor):
    return ('#if !DEVICE && NATIVE_COLD_CTORS && !NATIVE_HOT_' + constructor + '\n'
            'nf_out[4] = 0;\n#else\n#if NATIVE_COLD_USER_CTORS\n'
            'nf_out[4] = 0;\n#else\nnf_out[4] = 1;\n#endif\n#endif\n')


def audit(text):
    worker = 'NF_FID_' + ''.join(str(ord(c)) + '_' for c in 'mixed_build')
    inner = function(text, worker + '_trmc')
    outer = function(text, worker)
    assert 'Term ntr_state[5] = { TERM_HOLE, 0, 0, 0, 0 };' in outer
    assert worker + '_trmc(e, seq, ntr_state' in outer
    expected = {cid('MixedShort'): 1, cid('MixedWide'): 3}
    observed = {}
    pattern = (r'Term (ntr_node_\d+) = term_ctr\((CID_[A-Z0-9_]+), [^;]+\);\n'
               r'if \(nf_out\[1\] != 0\) \{ e\.mem\[nf_out\[1\]\] = nf_out\[4\] \? rfc_seal\(e, \1\) : \1; \} else \{ nf_out\[0\] = \1; \}\n'
               r'nf_out\[1\] = term_loc\(\1\) \+ (\d+);\n')
    for match in re.finditer(pattern, inner):
        constructor = match[2]
        assert constructor not in observed
        observed[constructor] = int(match[3])
        # Old destination is published first. Only then does the next hole
        # record the current constructor's policy, with ordinary-emitter logic.
        assert inner[match.end():].startswith(policy_block(constructor))
    assert observed == expected, observed
    stores = re.findall(r'e\.mem\[nf_out\[1\]\] = ([^;]+);', inner)
    assert len(stores) == 3, stores
    for store in stores:
        parsed = re.fullmatch(r'nf_out\[4\] \? rfc_seal\(e, (.+)\) : (.+)', store)
        assert parsed and parsed[1] == parsed[2], store
    assert sum('ntr_node_' not in x for x in stores) == 1, 'one terminal publication'
    # There must be no fourth/unaccounted write or reordered policy assignment.
    residual = inner
    for constructor in expected:
        assert residual.count(policy_block(constructor)) == 1
        residual = residual.replace(policy_block(constructor), '')
    assert not re.search(r'nf_out\[4\]\s*=', residual)
    return dict(worker=worker, nodeSlots=observed, terminalStores=1,
                oldPolicyReadBeforeNextPolicyWrite=True, privateStateWords=5)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['controls', 'emission', 'api-report', 'out']:
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args(); inputs = {}
    def bind(value):
        actual = pin(value['file'] if isinstance(value, dict) else value)
        if isinstance(value, dict): assert actual == value
        assert inputs.setdefault(actual['file'], actual) == actual
        return actual
    def read(value):
        item = bind(value); return item, json.loads(Path(item['file']).read_text())
    controls_pin, controls = read(args.controls)
    assert controls['complete']
    matches = [r for r in controls['records'] if r['id'] == 'mixed']
    assert len(matches) == 1; control = matches[0]
    source = bind(control['source']); expected = bind(control['stdout'])
    assert source['sha256'] == SOURCE_SHA and expected['sha256'] == OUTPUT_SHA
    assert control['stderr'] == '' and control['exit'] == 0
    emission_pin, emission = read(args.emission)
    api_pin, api = read(args.api_report)
    assert emission['complete'] and api['complete'] and not emission.get('error') and not api.get('error')
    assert emission['source'] == source
    assert bind(emission['api']) == bind(api['api'])
    compiler_source = bind(api['source']); bind(api['recipe'])
    original = bind(emission['output']); text = Path(original['file']).read_text()
    shape = audit(text)
    constructors = [cid(x) for x in ['MixedShort', 'MixedWide', 'MixedEnd']]
    defined = set(re.findall(r'^#define (CID__CTOR_\d[0-9_]*) \d+$', text, re.M))
    assert defined == set(constructors), ('unexpected user constructor', defined)
    assert re.findall(r'^#define NATIVE_COLD_CTORS (\d+)$', text, re.M) == ['1']
    assert not re.search(r'^#undef NATIVE_COLD_CTORS$', text, re.M)
    marker = '#if !DEVICE\n#if NATIVE_TYPED_SCALARS\n'
    assert text.count(marker) == 1; index = text.index(marker)
    assert all(m.start() < index for m in re.finditer(r'^#(?:define|undef) NATIVE_(?:HOT_|COLD_USER_CTORS)', text, re.M))
    # The only user constructors are the three proven-unique fixture variants.
    # Turning COLD_USER_CTORS off therefore changes no unrelated user type.
    variants = [
        ('all-hot', [1, 1, 1]), ('all-cold', [0, 0, 0]),
        ('short-hot', [1, 0, 0]), ('wide-hot', [0, 1, 0]),
        ('end-hot', [0, 0, 1]),
    ]
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase102')
    out.mkdir(parents=True, exist_ok=False)
    rows = []
    for label, bits in variants:
        overrides = ('/* Diagnostic unique-chain constructor policy matrix. */\n'
                     '#undef NATIVE_COLD_USER_CTORS\n#define NATIVE_COLD_USER_CTORS 0\n')
        for constructor, bit in zip(constructors, bits):
            overrides += f'#undef NATIVE_HOT_{constructor}\n#define NATIVE_HOT_{constructor} {bit}\n'
        changed = text[:index] + overrides + text[index:]
        assert changed[:index] + changed[index + len(overrides):] == text
        assert audit(changed) == shape
        dest = out / (label + '.c'); dest.write_text(changed)
        rows.append(dict(id=label, c=pin(dest), source=source, expectedStdout=expected,
                         expectedStderr='', expectedExit=0, threads=[1, 2, 4],
                         hot=dict(zip(constructors, bits)), coldUserConstructors=0,
                         insertion=dict(offset=index, text=overrides)))
    # Exhaustively document the exact ordinary-emitter policy expression.
    truth = []
    for device, cold, hot, user_cold in itertools.product([0, 1], repeat=4):
        seal = 0 if not device and cold and not hot else 0 if user_cold else 1
        truth.append(dict(device=device, cold=cold, hot=hot, userCold=user_cold, seal=seal))
    for row in inputs.values(): assert pin(row['file']) == row
    report = dict(kind='phase102-trmc-diagnostic-policy-matrix', complete=True,
                  targetsRun=False, method=bind(__file__), inputs=list(inputs.values()),
                  controls=controls_pin, emission=emission_pin, apiAcquisition=api_pin,
                  compilerSource=compiler_source, originalC=original, shape=shape,
                  userConstructorPolicyTruthTable=truth, variants=rows,
                  scope='Source-pinned unique-chain diagnostic C variants only. Exact original C plus macro insertion; structural proof obligations checked, no build/run/preprocessor or native-image qualification.')
    (out / 'plan.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, plan=pin(out / 'plan.json'), variants=len(rows))))


if __name__ == '__main__': main()
