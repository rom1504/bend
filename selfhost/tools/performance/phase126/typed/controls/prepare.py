"""Independent finite native F32 oracles; never invokes Bend or generated targets."""
import hashlib
import json
from fractions import Fraction
from pathlib import Path
import struct

HERE = Path(__file__).resolve().parent
FIXTURES = HERE / 'fixtures'
MASK = (1 << 32) - 1


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def save(path, text):
    if path.exists():
        assert path.read_text() == text, 'refuse changed frozen output: ' + str(path)
    else:
        path.write_text(text)
    return pin(path)


def json_file(path, value):
    return save(path, json.dumps(value, indent=2) + '\n')


def bits(exact):
    # All finite expected values here are dyadic and fit exactly in binary64.
    return struct.unpack('<I', struct.pack('<f', float(exact)))[0]


boundaries = [0, 0x80000000, 0x7f800000, 0xff800000, 0x7fc00001,
              0xffc00001, 1, 0, 0, 0,
              bits(Fraction(1)), bits(Fraction(7, 2)),
              1065353217, bits(Fraction(2)), 0, 1,
              bits(Fraction(5, 2)), bits(Fraction(3, 2)),
              'first', 'second', bits(Fraction(-1))]


def closed_state(n):
    half = n // 2
    if n % 2:
        x, y = Fraction(5) + Fraction(half, 4), Fraction(1) + Fraction(half + 1, 4)
    else:
        x, y = Fraction(1) + Fraction(half, 4), Fraction(5) + Fraction(half, 4)
    # s(0)=-1 and s(n+1)=3*s(n)+1: s(n)=-(3**n+1)/2 mod 2**32.
    stamp = -((pow(3, n, 1 << 33) + 1) // 2) & MASK
    return bits(x), bits(y), stamp


states = [':'.join(map(str, closed_state(n))) for n in (0, 1, 2, 17, 4096)]
for n in (17, 4096):
    x, y, stamp = closed_state(n)
    states.append(f'{stamp}:{x}:heap:47:{y}')
    states.append(f'{MASK}:{bits(1)}:heap:47:{bits(5)}')

cases = []
for name, lines in [('float-boundaries01', boundaries), ('float-state01', states)]:
    stdout = '\n'.join(map(str, lines)) + '\n'
    out = save(FIXTURES / (name + '.expected.stdout'), stdout)
    expected = json_file(FIXTURES / (name + '.expected.json'),
                         dict(status=0, stdout=stdout, stderr=''))
    source = pin(FIXTURES / (name + '.bend'))
    cases.append(dict(name='p126-' + name, source=source, expected=expected,
                      expectedStdoutEvidence=expected, stdoutEvidence=out))

case_pin = json_file(HERE / 'cases.json', dict(cases=cases))
json_file(HERE / 'manifest01.json', dict(sourceChecked=False, targetExecuted=False,
    generator=pin(Path(__file__).resolve()), cases=case_pin,
    sources=[row['source'] for row in cases], expectedLines=[21, 9],
    scope='Native ordinary-source correctness only; admission/performance unmeasured.'))
print(json.dumps(dict(cases=len(cases), lines=30, sourceChecked=False, targetExecuted=False)))
