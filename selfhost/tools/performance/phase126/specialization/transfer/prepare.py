"""Prepare unrelated selector-heavy source/oracles; never invokes a compiler."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def save(path, text):
    if path.exists():
        assert path.read_text() == text, 'Refuse changed frozen output: ' + str(path)
    else:
        path.write_text(text)
    return pin(path)


def save_json(path, value):
    return save(path, json.dumps(value, indent=2) + '\n')


# Fixed independent bit patterns. No Bend source or IR is interpreted here.
codes = [0x9E3779B9, 7, 0xFFFFFFFF, 123456789, 0, 0x80000000,
         65537, 97, 0xABCDEF01, 4093, 271828183, 314159265, 42]
weights = [0, 0x3F000000, 0x3F800000, 0xBF800000,
           0x3FC00000, 0x40000000, 0x40400000, 0x40800000]
seed, salt, count = 17, 99, 1024
state, result = seed, 2166136261 ^ salt
for _ in range(count):
    slot = state & 15
    value = (codes[min(slot, 12)] + weights[min(slot, 7)] + salt) & 0xFFFFFFFF
    result = ((result * 65599) ^ value) & 0xFFFFFFFF
    state = (state * 1664525 + 1013904223) & 0xFFFFFFFF

prefix = '''import Base

def routing.code(slot: Nat) -> U32:
  match slot:
'''
prefix += ''.join(f'    case {i}n: {v}\n' for i, v in enumerate(codes[:-1]))
prefix += f'    case 12n+rest: {codes[-1]}\n\n'
prefix += '''def routing.weight(slot: Nat) -> F32:
  match slot:
    case 0n: 0.0
    case 1n: 0.5
    case 2n: 1.0
    case 3n: F32.sub(0.0, 1.0)
    case 4n: 1.5
    case 5n: 2.0
    case 6n: 3.0
    case 7n+rest: 4.0

def routing.fold(left: Nat, +state: U32, +salt: U32, hash: U32) -> U32:
  match left:
    case 0n: hash
    case 1n+rest:
      +slot = U32.to_nat(U32.and(state, 15))
      code = routing.code(slot)
      weight = F32.bits(routing.weight(slot))
      value = U32.add(U32.add(code, weight), salt)
      next = U32.xor(U32.mul(hash, 65599), value)
      routing.fold(rest, U32.add(U32.mul(state, 1664525), 1013904223), salt, next)

def routing.value(seed: U32, +salt: U32) -> U32:
  routing.fold(1024n, seed, salt, U32.xor(2166136261, salt))

'''
wrapper_source = ROOT / 'selfhost/build/phase93/fixtures01/test-rle-roundtrip.bend'
wrapper = '# Phase93:' + wrapper_source.read_text().split('# Phase93:', 1)[1]
wrapper = wrapper.replace('  main.out()', '  routing.value(a,b)')
wrapper = wrapper.replace('U32.is_eq(value, 11)', f'U32.is_eq(value, {result})')
wrapper = wrapper.replace('p93.word(first, 0)', 'p93.word(first, 17)')
wrapper = wrapper.replace('p93.word(second, 0)', 'p93.word(second, 99)')
wrapper = wrapper.replace('((8n, 2n), (0, 0))', '((8n, 2n), (17, 99))')
source = HERE / 'routing1024.bend'
save(source, prefix + wrapper)
stdout = HERE / 'routing1024.expected.stdout'
save(stdout, str(result) + '\n')
case = dict(name='p126-routing1024', source=pin(source), expectedStdoutEvidence=pin(stdout),
            expectedStdout=str(result) + '\n', runtimeArgs=[seed, salt], repetitions=2000,
            warmups=2, ratioEligible=False, family='independent-finite-selectors',
            oracle='Independent 1024-step U32 LCG/integer hash over fixed exact bit tables; unchanged Phase93 complete-result/count observer.',
            selection='New transfer workload; not original45 or a blind heldout, and no production source-name recognition.')
save_json(HERE / 'cases.json', dict(cases=[case], inputs=[pin(__file__), pin(wrapper_source)]))
ordinary_source = HERE / 'routing-ordinary.bend'
save(ordinary_source, prefix + 'def main() -> IO(Unit):\n  IO.print(U32.show(routing.value(17,99)))\n')
ordinary_expected = HERE / 'routing-ordinary.expected.json'
save_json(ordinary_expected, dict(status=0, stdout=str(result) + '\n', stderr=''))
save_json(HERE / 'ordinary-cases.json', dict(cases=[dict(name='p126-routing-ordinary',
    source=pin(ordinary_source), expected=pin(ordinary_expected), expectedStdoutEvidence=pin(ordinary_expected))]))
save_json(HERE / 'oracle.json', dict(seed=seed, salt=salt, iterations=count, expected=result,
    codes=codes, weightBits=weights, arithmetic='U32 wrap after each addition/multiplication; two independent clamped finite selectors.',
    expectedWarmupSuccessCount=2, expectedTimedSuccessCount=2000, targetsRun=False,
    inputs=[pin(__file__), pin(source), pin(ordinary_source), pin(wrapper_source)]))
print(result)
