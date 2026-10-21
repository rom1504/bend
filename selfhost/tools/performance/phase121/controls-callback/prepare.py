"""Prepare independent whole-value callback controls, without compiler runs."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
MASK = (1 << 32) - 1


def pin(path):
    raw = path.read_bytes()
    return {'file': str(path), 'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def save(path, text):
    if path.exists():
        assert path.read_text() == text, f'refuse overwrite: {path}'
    else:
        path.write_text(text)
    return pin(path)


def model(n, value, reverse):
    # Independent imperative evaluator, preserving separate U32 wrap points.
    order = range(n) if reverse else range(n - 1, -1, -1)
    for pred in order:
        capture = (((pred & MASK) * 4294967291 & MASK) + 7) & MASK
        value = ((value * 33 & MASK) + capture) & MASK
    return value


calls = []
expected = []
rows = []
for n in [0, 1, 2, 17, 257]:
    for seed in [0, 1, MASK]:
        forward, reverse = model(n, seed, False), model(n, seed, True)
        if n == 2:
            assert forward != reverse, 'control must expose composition order'
        expected.extend(map(str, [n, seed, forward, forward, reverse]))
        rows.append({'count': n, 'seed': seed, 'braided': forward, 'throughEscaped': forward, 'backwards': reverse})
        exprs = [str(n), str(seed), f'braided({n}, {seed})', f'through_escaped({n}, {seed})', f'backwards({n}, {seed})']
        calls.extend(f'    Unit <- IO.print(U32.show({expr}))' for expr in exprs)
calls[-1] = calls[-1].replace('Unit <- ', '', 1)
source = (HERE / 'prefix.bend').read_text() + '\ndef main() -> IO(Unit):\n  do IO<Unit>:\n' + '\n'.join(calls) + '\n'
out = {'kind': 'phase121-renamed-callback-independent-controls', 'targetRuns': False,
       'source': save(HERE / 'callback-controls.bend', source),
       'expected': save(HERE / 'callback-controls.expected.stdout', '\n'.join(expected) + '\n'),
       'prefix': pin(HERE / 'prefix.bend'), 'generator': pin(Path(__file__)),
       'columns': ['count', 'seed', 'braided', 'through_escaped', 'backwards'],
       'expectedAdmission': {'braided': True, 'escaped': False, 'through_escaped': False, 'backwards': False},
       'cases': rows}
save(HERE / 'manifest.json', json.dumps(out, indent=2) + '\n')
print(json.dumps({'cases': len(rows), 'outputLines': len(expected), 'targetRuns': False}))
