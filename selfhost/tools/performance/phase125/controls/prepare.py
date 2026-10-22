"""Independent ordinary owned-append oracle; no compiler/runtime execution."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
MASK = (1 << 32) - 1


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def save(name, value):
    path = HERE / name
    if path.exists():
        assert path.read_text() == value, 'refuse changed frozen output: ' + str(path)
    else:
        path.write_text(value)
    return pin(path)


def save_json(name, value):
    return save(name, json.dumps(value, indent=2) + '\n')


def words(values):
    return ''.join(str(value) + ';' for value in values)


lines = []
def shared(left, right):
    lines.extend([words(left + right), words(left), words(right)])

shared(list(range(24, 7, -1)), [MASK, 0, 17])
tail = list(range(19, 2, -1))
lines.extend([words([99] + tail + [111, 222]), words(tail)])
lines.extend([words([99] + tail + tail), words(tail)])
lines.append(words([2, 5, 9, 11, 13]))
shared([2, 5, 9], [11, 13])
word = 'seed:12345'
lines.extend([''.join('[' + value + ']' for value in [word, word, word, 'x', word]), word])
shared([], [0, MASK])
shared([], [])
lines.append(words([0, 3, 8]))
deep = list(range(4095, -1, -1)) + [MASK, 17]
digest = 2166136261
for value in deep:
    digest = (digest * 65599 + value) & MASK
lines.append(f'{len(deep)}:{digest}')
stdout = '\n'.join(lines) + '\n'
stdout_pin = save('owned-append01.expected.stdout', stdout)
expected = save_json('owned-append01.expected.json', dict(status=0, stdout=stdout, stderr=''))
source = pin(HERE / 'owned-append01.bend')
cases = save_json('cases.json', dict(cases=[dict(name='p125-owned-append01', source=source,
    expected=expected, expectedStdoutEvidence=expected, stdoutEvidence=stdout_pin)]))
admission = save_json('admission-expectations.json', dict(checked=False, executed=False,
    queries=[dict(name='ledger.join', expected=True), dict(name='label.join', expected=True),
             dict(name='ledger.changed', expected=False)],
    scope='p125p_inspect equation/type admission only; not runtime fast-path success'))
save_json('manifest01.json', dict(sourceChecked=False, targetExecuted=False, source=source,
    generator=pin(Path(__file__).resolve()), cases=cases, oracle=expected, admission=admission,
    stdoutLines=len(lines), deep=dict(length=len(deep), orderedDigest=digest, modulus=1 << 32,
                                   multiplier=65599, seed=2166136261)))
print(json.dumps(dict(lines=len(lines), deepLength=len(deep), deepDigest=digest)))
