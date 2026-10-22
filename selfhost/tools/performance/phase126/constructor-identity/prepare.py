"""Freeze source and independent complete-output oracle; no compiler execution."""
from pathlib import Path
import hashlib
import json
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PARENT = ROOT / 'selfhost/build/phase125/verified-source06/compiler.bend'

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

def show(tree):
    if isinstance(tree, str):
        return '[' + tree + ']'
    left, right = tree
    return '(' + show(left) + '|' + show(right) + ')'

lines = []
for tree in [('left', 'right'), ('heap:4294967295', ('middle', 'heap:4294967295'))]:
    lines.extend([show(tree), show(tree), show((tree[1], tree[0])), show(tree)])
lines.extend(['heap:4294967295', show(('deep:17', 'done')), show(('kept', 'also-kept'))])
stdout = '\n'.join(lines) + '\n'
out = save(HERE / 'fixtures/owner-identity01.expected.stdout', stdout)
expected = save_json(HERE / 'fixtures/owner-identity01.expected.json', dict(status=0, stdout=stdout, stderr=''))
cases = save_json(HERE / 'cases.json', dict(cases=[dict(name='p126-owner-identity01',
    source=pin(HERE / 'fixtures/owner-identity01.bend'), expected=expected,
    expectedStdoutEvidence=expected, stdoutEvidence=out)]))

def declaration(source, name):
    m = re.search(r'^def ' + re.escape(name) + r'\b', source, re.M)
    assert m
    end = re.search(r'(?m)^(?:@|def |law |type |#)', source[m.end():])
    return source[m.start():m.end()+end.start() if end else len(source)].rstrip()

parent = PARENT.read_text()
lower = (HERE / 'lower.bend').read_text()
aliases = [('p112m_original_match_apply', 'p126ci_old_generic'), ('p113pm_original_match', 'p126ci_old_product')]
for original, copied in aliases:
    assert declaration(parent, original).replace('def ' + original + '(', 'def ' + copied + '(', 1) == declaration(lower, copied)

save_json(HERE / 'manifest01.json', dict(kind='phase126-closed-constructor-identity-v1',
    complete=True, checked=False, targetsRun=False, parent=pin(PARENT),
    modules=[pin(HERE / name) for name in ['plan.bend', 'lower.bend', 'controls.bend']],
    overrides=[item[0] for item in aliases], fallbackAliasByteIdentity=True,
    exports=['p126ci_match', 'p126ci_controls'], controls=cases,
    finiteControlCount=19, ordinaryOutputLineCount=len(lines), oracle=pin(Path(__file__).resolve()),
    scope='closed two-to-eight-field ordinary nondependent user constructors; no matcher rest; opaque product destination only'))
print(json.dumps(dict(cases=str(HERE / 'cases.json'), manifest=str(HERE / 'manifest01.json'), outputs=len(lines))))
