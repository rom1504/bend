"""Independent integer/rational F32 conversion oracle; no compiler/target calls."""
from fractions import Fraction
from pathlib import Path
import hashlib
import json

HERE = Path(__file__).resolve().parent
FIXTURES = HERE / 'fixtures'
VALUES = [0, 0x80000000, 1, 0x80000001, 0x007fffff, 0x00800000,
          0x3f7fffff, 0x3f800000, 0xbf800000, 0x3fc00000, 0x3fffffff,
          0x40000000, 0x4effffff, 0x4f000000, 0x4f000001, 0x4f7ffffe,
          0x4f7fffff, 0x4f800000, 0x4f800001, 0x7f800000, 0xff800000,
          0x7fc00001, 0xffc00001, 0x7f800001, 0xff800001]


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data),
                sha256=hashlib.sha256(data).hexdigest())


def write(path, text):
    if path.exists():
        assert path.read_text() == text, 'frozen output differs: ' + str(path)
    else:
        path.write_text(text)
    return pin(path)


def write_json(path, value):
    return write(path, json.dumps(value, indent=2) + '\n')


def convert_bits(bits):
    # Exact IEEE binary32 decomposition using integer/rational arithmetic.
    exponent = (bits >> 23) & 255
    mantissa = bits & ((1 << 23) - 1)
    if exponent == 255:  # All NaNs and either infinity fail the finite interval.
        return 0
    power = exponent - 150 if exponent else -149
    if exponent:
        mantissa += 1 << 23
    value = Fraction(mantissa) * (Fraction(2) ** power)
    if bits >> 31:
        value = -value
    return int(value) if 0 <= value < 1 << 32 else 0


# Original 21 independent witnesses are retained byte-for-byte, followed by
# 25 direct bit-pattern conversions and three exact multiplication→conversion
# results. Their products (3.5, 4294967040 and 4294967296) are representable F32.
stdout = (FIXTURES / 'float-boundaries01.expected.stdout').read_text()
stdout += ''.join(f'{bits}:{convert_bits(bits)}\n' for bits in VALUES)
stdout += '3\n4294967040\n0\n'
out = write(FIXTURES / 'float-boundaries02.expected.stdout', stdout)
expected = write_json(FIXTURES / 'float-boundaries02.expected.json',
                      dict(status=0, stdout=stdout, stderr=''))
source = pin(FIXTURES / 'float-boundaries02.bend')
case = dict(name='p126-float-boundaries02', source=source, expected=expected,
            expectedStdoutEvidence=expected, stdoutEvidence=out)
old_cases = json.loads((HERE / 'cases.json').read_text())['cases']
cases = write_json(HERE / 'cases-v02.json',
                   dict(cases=[case, old_cases[1]]))
write_json(HERE / 'manifest-v02.json', dict(
    sourceChecked=False, targetExecuted=False, generator=pin(Path(__file__)),
    cases=cases, conversionInputs=VALUES,
    expectedConversionResults=[convert_bits(bits) for bits in VALUES],
    expectedLines=49, scope='Native F32 boundary controls; no speed claim.'))
print(json.dumps(dict(cases=2, conversionCases=28, sourceChecked=False,
                      targetExecuted=False)))
