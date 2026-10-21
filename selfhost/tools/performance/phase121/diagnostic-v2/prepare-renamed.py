"""Finite independent outputs for legal admitted/refused source shapes."""
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


def values(n, seed):
    answer = []
    for _ in range(n):
        if seed % 5 > 1:
            answer.append(seed)
        seed = ((seed * 1664525 & MASK) + 1013904223) & MASK
    return answer


def fold(xs, acc):
    for head in xs:
        acc = ((acc * 33 & MASK) + head) & MASK
    return acc


calls = []
expected = []
rows = []
for n in [0, 1, 2, 17, 257]:
    for seed in [0, 1, MASK]:
        xs = values(n, seed)
        mapped = [((x * 4294967291 & MASK) + 4294967280) & MASK for x in xs]
        answers = [fold(mapped, MASK), (fold(mapped, 1) + fold(mapped, 2)) & MASK,
                   fold(mapped, 27), fold(xs, MASK)]
        expected.extend(map(str, [n, seed, *answers]))
        rows.append({'count': n, 'seed': seed, 'values': answers})
        exprs = [str(n), str(seed), f'renamed({n}, {seed})', f'shared({n}, {seed})',
                 f'accumulated(returned({n}, {seed}), 27)', f'user_named({n}, {seed})']
        calls.extend(f'    Unit <- IO.print(U32.show({x}))' for x in exprs)
calls[-1] = calls[-1].replace('Unit <- ', '', 1)
text = (HERE / 'renamed-pipeline-prefix.bend').read_text() + '\ndef main() -> IO(Unit):\n  do IO<Unit>:\n' + '\n'.join(calls) + '\n'
source = save(HERE / 'renamed-pipeline-controls.bend', text)
oracle = save(HERE / 'renamed-pipeline-controls.expected.stdout', '\n'.join(expected) + '\n')
manifest = {'kind': 'phase121-renamed-pipeline-independent-controls', 'targetRuns': False,
            'source': source, 'expected': oracle, 'prefix': pin(HERE / 'renamed-pipeline-prefix.bend'),
            'generator': pin(Path(__file__)), 'columns': ['count', 'seed', 'renamed', 'shared', 'returned_fold27', 'user_named'],
            'expectedAdmission': {'renamed': True, 'shared': False, 'returned': False, 'user_named': False},
            'identityScope': 'user u32_add alias; no invalid redeclaration of Base U32.add', 'cases': rows}
save(HERE / 'renamed-manifest.json', json.dumps(manifest, indent=2) + '\n')
print(json.dumps({'cases': len(rows), 'outputLines': len(expected), 'targetRuns': False}))
