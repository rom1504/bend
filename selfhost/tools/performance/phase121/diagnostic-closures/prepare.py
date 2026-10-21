"""Prepare exact closure ceiling substitutions; no target runs or builds."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
MANIFEST = ROOT / 'selfhost/tools/performance/phase112/benchmark45/manifest01.json'


def pin(path):
    raw = path.read_bytes()
    return {'file': str(path), 'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def save(path, text):
    if path.exists():
        assert path.read_text() == text, f'refuse overwrite: {path}'
    else:
        path.write_text(text)
    return pin(path)


rows = []
for case in json.loads(MANIFEST.read_text())['cases']:
    if case['name'] not in ['coverage-closures-64', 'coverage-closures-256']:
        continue
    source = Path(case['source']['file'])
    assert pin(source) == case['source']
    prefix, suffix = source.read_text().split('# Phase93:', 1)
    old = '  chain(U32.to_nat(size))(seed)'
    assert prefix.count(old) == 1
    before, bench = prefix.split('def bench(', 1)
    text = before + (HERE / 'helper.bend').read_text() + '\ndef bench(' + bench.replace(old, '  p121.closure_loop(U32.to_nat(size), seed)') + '# Phase93:' + suffix
    assert text.split('# Phase93:', 1)[1] == suffix
    n, seed = case['runtimeArgs']
    value = seed
    for pred in range(n - 1, -1, -1):
        value = (value + ((1 + pred) & 0xffffffff)) & 0xffffffff
    assert str(value) + '\n' == case['expectedStdout']
    rows.append({'name': case['name'], 'variant': 'closure-loop',
                 'source': save(HERE / (case['name'] + '-loop.bend'), text),
                 'original': case['source'], 'helper': pin(HERE / 'helper.bend'),
                 'expectedStdout': case['expectedStdout'], 'expectedStdoutEvidence': case['expectedStdoutEvidence'],
                 'runtimeArgs': case['runtimeArgs'], 'manifestRepetitions': case['repetitions'],
                 'manifestWarmups': case['warmups'], 'wrapperSuffixSha256': hashlib.sha256(suffix.encode()).hexdigest()})
out = {'kind': 'phase121-source-specialized-closure-ceiling', 'compilerTransformation': False,
       'targetRuns': False, 'manifest': pin(MANIFEST), 'generator': pin(Path(__file__)), 'cases': rows}
save(HERE / 'manifest.json', json.dumps(out, indent=2) + '\n')
print(json.dumps({'sources': len(rows), 'targetRuns': False}))
