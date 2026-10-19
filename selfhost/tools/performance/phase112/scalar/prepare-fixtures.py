#!/usr/bin/env python3
"""Write fixed independent scalar oracles and Bend fixtures; execute no targets."""
from pathlib import Path
import hashlib
import json

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]

# Expected numbers are explicit boundary arithmetic, not candidate-generated IR.
# The third item is the complete expected numeric observation.
CASES = [
    ('U32.add(4294967295, 1)', 0),
    ('U32.add(2147483648, 2147483648)', 0),
    ('U32.add(4294967294, 1)', 4294967295),
    ('U32.sub(0, 1)', 4294967295),
    ('U32.sub(2147483648, 2147483649)', 4294967295),
    ('U32.sub(1, 1)', 0),
    ('U32.mul(4294967295, 4294967295)', 1),
    ('U32.mul(2147483648, 2)', 0),
    ('U32.mul(65535, 65537)', 4294967295),
    ('U32.and(2863311530, 1431655765)', 0),
    ('U32.and(4294967295, 2147483648)', 2147483648),
    ('U32.or(2863311530, 1431655765)', 4294967295),
    ('U32.or(0, 2147483648)', 2147483648),
    ('U32.xor(4294967295, 1431655765)', 2863311530),
    ('U32.xor(2147483648, 2147483648)', 0),
    ('U32.inc(4294967295)', 0),
    ('U32.inc(2147483647)', 2147483648),
    ('U32.not(0)', 4294967295),
    ('U32.not(4294967295)', 0),
    ('U32.not(2147483648)', 2147483647),
    ('U32.shl(2147483648)', 0),
    ('U32.shl(4294967295)', 4294967294),
    ('U32.shr(2147483648)', 1073741824),
    ('U32.shr(4294967295)', 2147483647),
    ('U32.shln(4294967295, 0n)', 4294967295),
    ('U32.shln(1, 31n)', 2147483648),
    ('U32.shln(1, 32n)', 0),
    ('U32.shln(4294967295, 33n)', 0),
    ('U32.shln(1, 64n)', 0),
    ('U32.shrn(4294967295, 0n)', 4294967295),
    ('U32.shrn(2147483648, 31n)', 1),
    ('U32.shrn(4294967295, 32n)', 0),
    ('U32.shrn(4294967295, 33n)', 0),
    ('U32.shrn(4294967295, 64n)', 0),
    ('U32.shln(1, Nat.add(U32.to_nat(4294967295), 1n))', 0),
    ('U32.shrn(4294967295, Nat.add(U32.to_nat(4294967295), 1n))', 0),
    ('Bool.to_u32(U32.is_eq(4294967295, 4294967295))', 1),
    ('Bool.to_u32(U32.is_eq(0, 4294967295))', 0),
    ('Bool.to_u32(U32.is_ne(2147483648, 2147483647))', 1),
    ('Bool.to_u32(U32.is_ne(0, 0))', 0),
    ('Bool.to_u32(U32.is_lt(2147483647, 2147483648))', 1),
    ('Bool.to_u32(U32.is_lt(4294967295, 0))', 0),
    ('Bool.to_u32(U32.is_le(4294967295, 4294967295))', 1),
    ('Bool.to_u32(U32.is_le(4294967295, 2147483648))', 0),
    ('Bool.to_u32(U32.is_gt(2147483648, 2147483647))', 1),
    ('Bool.to_u32(U32.is_gt(0, 4294967295))', 0),
    ('Bool.to_u32(U32.is_ge(0, 0))', 1),
    ('Bool.to_u32(U32.is_ge(0, 4294967295))', 0),
    ('Bool.to_u32(U32.is_zero(0))', 1),
    ('Bool.to_u32(U32.is_zero(2147483648))', 0),
    # Deliberate unchanged runtime fallbacks, including division by zero.
    ('U32.div(4294967295, 0)', 0),
    ('U32.mod(4294967295, 0)', 4294967295),
    ('U32.div(4294967295, 10)', 429496729),
    ('U32.mod(4294967295, 10)', 5),
    ('Bool.to_u32(Cmp.is_lt(U32.cmp(0, 4294967295)))', 1),
    ('Bool.to_u32(Cmp.is_eq(U32.cmp(2147483648, 2147483648)))', 1),
    ('Bool.to_u32(Cmp.is_gt(U32.cmp(4294967295, 0)))', 1),
]


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), bytes=len(raw),
                sha256=hashlib.sha256(raw).hexdigest())


def affine_repeat(count, seed):
    """Independent O(log n) composition of x -> 1664525*x+1013904223 mod2^32."""
    modulus = 2**32
    mul, add, out_mul, out_add = 1664525, 1013904223, 1, 0
    while count:
        if count & 1:
            out_mul, out_add = (mul * out_mul) % modulus, (mul * out_add + add) % modulus
        mul, add = (mul * mul) % modulus, (mul * add + add) % modulus
        count //= 2
    return (out_mul * seed + out_add) % modulus


def main():
    fixture = HERE / 'boundaries.bend'
    lines = ['# Frozen boundary expectations; no candidate-generated answers.', 'import Base', '',
             'def main() -> IO(Unit):', '  do IO<Unit>:']
    for i, (expr, expected) in enumerate(CASES):
        prefix = 'Unit <- ' if i + 1 < len(CASES) else ''
        lines.append(f'    {prefix}IO.print(U32.show({expr}))')
    expected = ''.join(f'{value}\n' for _, value in CASES)
    fixture.write_text('\n'.join(lines) + '\n\n' + ''.join(f'#|{v}\n' for _, v in CASES))
    (HERE / 'boundaries.stdout').write_text(expected)
    cases = [dict(index=i, expression=expr, expected=value) for i, (expr, value) in enumerate(CASES)]
    (HERE / 'boundaries.json').write_text(json.dumps(cases, indent=2) + '\n')
    benches = []
    for label, iterations in [('small', 65536), ('large', 1048576)]:
        result = affine_repeat(iterations, 305419896)
        path = HERE / f'loop-{label}.bend'
        path.write_text(f'''# Scalar work is a real dynamic self-tail loop; readback observes its final word.
import Base

@unsafe
def p112_scalar_loop(+remaining: U32, word: U32, done: Bool) -> U32:
  match done:
    case True{{}}: word
    case False{{}}:
      +next = U32.sub(remaining, 1)
      p112_scalar_loop(next, U32.add(U32.mul(word, 1664525), 1013904223), U32.is_zero(next))

def main() -> IO(Unit):
  IO.print(U32.show(p112_scalar_loop({iterations}, 305419896, False{{}})))

#|{result}
''')
        out = HERE / f'loop-{label}.stdout'
        out.write_text(f'{result}\n')
        benches.append(dict(name=f'loop-{label}', iterations=iterations, source=pin(path),
                            expectedStdout=pin(out), result=result))
    report = dict(kind='phase112-scalar-frozen-controls', version=1, targetsRun=False,
                  sourceChecked=False, correctnessPassed=False,
                  oracle='Explicit boundary integers; loop expected by independent logarithmic affine composition.',
                  method=pin(Path(__file__).resolve()), cases=pin(HERE / 'boundaries.json'),
                  source=pin(fixture), expectedStdout=pin(HERE / 'boundaries.stdout'),
                  observations=len(CASES), benches=benches)
    (HERE / 'fixtures.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(prepared=True, targetsRun=False, observations=len(CASES), benches=benches)))


if __name__ == '__main__':
    main()
