"""Pin exact helper-semantic overlay and an independent ordinary Nat oracle."""
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]

def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())

def save(path, text):
    if path.exists():
        assert path.read_text() == text, 'refuse changed frozen output: ' + str(path)
    else:
        path.write_text(text)
    return pin(path)

def save_json(path, obj):
    return save(path, json.dumps(obj, indent=2) + '\n')

lines = []
for n in [0, 1, 2, 1 << 32, 1 << 40, (1 << 48) - 1]:
    lines.extend(['zero' if n == 0 else str(n-1), str(n)])
lines.append(str(sum(range(4096)) & 0xffffffff))
stdout = '\n'.join(lines) + '\n'
out = save(HERE / 'fixtures/nat-boundaries01.expected.stdout', stdout)
expected = save_json(HERE / 'fixtures/nat-boundaries01.expected.json', dict(status=0, stdout=stdout, stderr=''))
cases = save_json(HERE / 'cases.json', dict(cases=[dict(name='p126-nat-boundaries01',
    source=pin(HERE / 'fixtures/nat-boundaries01.bend'), expected=expected,
    expectedStdoutEvidence=expected, stdoutEvidence=out)]))

parent = ROOT / 'selfhost/build/phase125/verified-source06/compiler.bend'
runtime = ROOT / 'selfhost/build/phase125/runtime-verified01/runtime.c'
source = parent.read_text()
original = re.search(r'(?ms)^def p111q_stmt\(.*?\n  p114t_stmt\(stmt,ids,code\)', source).group(0)
copied = re.search(r'(?ms)^def p126nt_previous_stmt\(.*?\n  p114t_stmt\(stmt,ids,code\)', (HERE / 'model.bend').read_text()).group(0)
assert original.replace('def p111q_stmt(', 'def p126nt_previous_stmt(', 1) == copied
save_json(HERE / 'manifest01.json', dict(kind='phase126-postverified-nat-take-v1', complete=True,
    checked=False, targetsRun=False, parent=pin(parent), runtime=pin(runtime),
    modules=[pin(HERE / f) for f in ['model.bend', 'controls.bend']],
    overrides=['p111q_stmt'], fallbackAliasByteIdentity=True, exports=['p126nt_controls'],
    controls=cases, finiteControlCount=16, ordinaryOutputLineCount=len(lines), oracle=pin(Path(__file__).resolve()),
    scope='Only exact special_take U64 result, state pointer, constant kind4/count1 and typed term/output arguments; original independent verifier required'))
print(json.dumps(dict(manifest=str(HERE / 'manifest01.json'), cases=str(HERE / 'cases.json'), outputs=len(lines))))
