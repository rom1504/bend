"""Prepare pinned RLE state-lane ceilings and independent exact-value controls.

Version one and its failed computed-scrutinee emission remain frozen.
This only writes diagnostic Bend/JSON/stdout files; it runs no compiler or target.
"""
import copy
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
CATALOG = ROOT / 'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
MASK = (1 << 32) - 1


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def save(name, text):
    path = HERE / name
    if path.exists():
        assert path.read_text() == text, f'refuse changed frozen output: {path}'
    else:
        path.write_text(text)
    return pin(path)


def save_json(name, value):
    return save(name, json.dumps(value, indent=2) + '\n')


COMMON = '# Diagnostic helpers scrutinize a Bool parameter, as required by Bend.\ndef p123.next_cur(+cur: U32, +h: U32, equal: Bool) -> U32:\n  match equal:\n    case False{}: h\n    case True{}: cur\n\ndef p123.next_count(+n: U32, equal: Bool) -> U32:\n  match equal:\n    case False{}: 1\n    case True{}: U32.add(n, 1)\n\ndef p123.next_acc(+cur: U32, +n: U32, acc: List<&2, P2()>, equal: Bool) -> List<&2, P2()>:\n  match equal:\n    case False{}: (n, cur) <> acc\n    case True{}: acc\n\n'

OUTER = '# Outer state shell removed; count/acc remain a single source-level pair.\nlaw p123.runs.outer:\n  for xs: List<&2, U32>\n  for +cur: U32\n  for state: U32 & List<&2, P2()>\n  List<&2, P2()>\n\ndef p123.runs.outer(xs, cur, state):\n  match xs:\n    case Nil{}:\n      (n, acc) = state\n      lrevp((n, cur) <> acc)\n    case h0 <> t:\n      (n0, acc) = state\n      +n = {n0 : U32}\n      +h = {h0 : U32}\n      +equal = {U32.is_eq(h, cur) : Bool}\n      next_cur = p123.next_cur(cur, h, equal)\n      next_n = p123.next_count(n, equal)\n      next_acc = p123.next_acc(cur, n, acc, equal)\n      p123.runs.outer(t, next_cur, (next_n, next_acc))\n\n'

FULL = '# All state fields cross the backedge as separate scalar/owner arguments.\nlaw p123.runs.full:\n  for xs: List<&2, U32>\n  for +cur: U32\n  for +n: U32\n  for acc: List<&2, P2()>\n  List<&2, P2()>\n\ndef p123.runs.full(xs, cur, n, acc):\n  match xs:\n    case Nil{}:\n      lrevp((n, cur) <> acc)\n    case h0 <> t:\n      +h = {h0 : U32}\n      +equal = {U32.is_eq(h, cur) : Bool}\n      next_cur = p123.next_cur(cur, h, equal)\n      next_n = p123.next_count(n, equal)\n      next_acc = p123.next_acc(cur, n, acc, equal)\n      p123.runs.full(t, next_cur, next_n, next_acc)\n\n'

case = next(c for c in json.loads(CATALOG.read_text())['cases'] if c['name'] == 'test-rle-roundtrip')
source = Path(case['source']['file'])
assert pin(source) == case['source']
text = source.read_text()
before, rest = text.split('law rle:\n', 1)
old, after = rest.split('law expand:\n', 1)
signature = old.split('def rle(xs, st):\n', 1)[0]
wrapper = text.split('# Phase93:', 1)[1]
rows = []
for mode, helper, call in [
    ('outer', OUTER, 'p123.runs.outer(xs, cur, (n, acc))'),
    ('full', FULL, 'p123.runs.full(xs, cur, n, acc)'),
]:
    result = before + COMMON + helper + 'law rle:\n' + signature + 'def rle(xs, st):\n  (cur, n, acc) = st\n  ' + call + '\n\nlaw expand:\n' + after
    assert result.split('# Phase93:', 1)[1] == wrapper
    row = copy.deepcopy(case)
    row.update(name='test-rle-roundtrip-v2-' + mode, parentName=case['name'],
               source=save('rle-v2-' + mode + '.bend', result),
               diagnosticOnly=True, benchmarkClaim=False)
    rows.append(row)
save_json('rle-v2-cases.json', dict(kind='phase123-source-only-RLE-state-ceilings', cases=rows))


def model(xs, cur=None, n=None, acc=None):
    # Independent imperative run encoder. acc is the original reverse accumulator.
    xs = list(xs)
    if cur is None:
        if not xs:
            return []
        cur, xs = xs[0], xs[1:]
        n, acc = 1, []
    pending = list(acc)
    for h in xs:
        if h == cur:
            n = (n + 1) & MASK
        else:
            pending.insert(0, (n, cur))
            cur, n = h, 1
    pending.insert(0, (n, cur))
    return pending[::-1]


def rendered(pairs):
    return ''.join(f'{n}:{v};' for n, v in pairs)


def literal(xs):
    return '[' + ', '.join(map(str, xs)) + ']'


assert rendered(model([7, 7, 7, 2, 9, 9])) == '3:7;1:2;2:9;'
prefix = before + 'law rle:\n' + old + COMMON + OUTER + FULL
prefix += '''def verify.pairs(xs: List<&2, P2()>) -> String:
  match xs:
    case Nil{}: ""
    case (n, v) <> rest:
      U32.show(n) ++ ":" ++ U32.show(v) ++ ";" ++ verify.pairs(rest)

def verify.words(xs: List<&2, U32>) -> String:
  match xs:
    case Nil{}: ""
    case h <> rest: U32.show(h) ++ ";" ++ verify.words(rest)

def verify.reference(xs: List<&2, U32>) -> List<&2, P2()>:
  match xs:
    case Nil{}: Nil{}
    case h <> t: rle(t, (h, 1, Nil{}))

def verify.outer(xs: List<&2, U32>) -> List<&2, P2()>:
  match xs:
    case Nil{}: Nil{}
    case h <> t: p123.runs.outer(t, h, (1, Nil{}))

def verify.full(xs: List<&2, U32>) -> List<&2, P2()>:
  match xs:
    case Nil{}: Nil{}
    case h <> t: p123.runs.full(t, h, 1, Nil{})

def verify.input(+xs: List<&2, U32>) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(verify.pairs(verify.reference(xs)))
    Unit <- IO.print(verify.pairs(verify.outer(xs)))
    Unit <- IO.print(verify.pairs(verify.full(xs)))
    IO.print(verify.words(xs))

def verify.state(+xs: List<&2, U32>, +cur: U32, +n: U32, +acc: List<&2, P2()>) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(verify.pairs(rle(xs, (cur, n, acc))))
    Unit <- IO.print(verify.pairs(p123.runs.outer(xs, cur, (n, acc))))
    Unit <- IO.print(verify.pairs(p123.runs.full(xs, cur, n, acc)))
    IO.print(verify.pairs(acc))

'''
# Renaming avoids dependence on original benchmark worker identities.
for old_name, new_name in [('p123.runs.outer', 'lanes.outer'), ('p123.runs.full', 'lanes.full'),
                           ('rle.step', 'archive.step'), ('lrevp.go', 'archive.reverse.go'),
                           ('lrevp', 'archive.reverse'), ('rle', 'archive.scan'), ('P2', 'SamplePair')]:
    prefix = re.sub(r'(?<![A-Za-z0-9_.])' + re.escape(old_name) + r'(?![A-Za-z0-9_.])', new_name, prefix)

ordinary = [[], [0], [MASK], [7, 7, 7, 2, 9, 9], [0, 1, 0, 1],
            [MASK, MASK, 0, 0, MASK], [1] * 17, list(range(17))]
states = [([], 7, 0), ([], MASK, MASK), ([7], 7, MASK),
          ([7, 7], 7, MASK), ([0, 0, MASK], MASK, MASK),
          ([1, 1, 2, 2, 1], 1, MASK - 1)]
calls, expected, controls = [], [], []
for xs in ordinary:
    calls.append(f'    Unit <- verify.input({literal(xs)})')
    value = rendered(model(xs))
    expected += [value] * 3 + [''.join(f'{v};' for v in xs)]
    controls.append(dict(kind='input', input=xs, expectedPairs=model(xs)))
acc = [(3, 99), (4, 0)]
for xs, cur, n in states:
    calls.append(f'    Unit <- verify.state({literal(xs)}, {cur}, {n}, [(3, 99), (4, 0)])')
    value = rendered(model(xs, cur, n, acc))
    expected += [value] * 3 + [rendered(acc)]
    controls.append(dict(kind='seeded-state', input=xs, current=cur, count=n,
                         accumulator=acc, expectedPairs=model(xs, cur, n, acc)))
calls[-1] = calls[-1].replace('Unit <- ', '', 1)
control_source = save('rle-v2-controls.bend', prefix + 'def main() -> IO(Unit):\n  do IO<Unit>:\n' + '\n'.join(calls) + '\n')
expected_stdout = save('rle-v2-controls.expected.stdout', '\n'.join(expected) + '\n')
expected_json = save_json('rle-v2-controls.expected.json', dict(stdout='\n'.join(expected) + '\n', stderr='', status=0))
save_json('rle-v2-controls.json', dict(cases=[dict(name='rle-v2-controls', source=control_source,
                                            expected=expected_json, expectedStdoutEvidence=expected_json)]))
save_json('rle-v2-manifest.json', dict(kind='phase123-RLE-state-ceiling-preparation', targetRuns=False,
    compilerTransformation=False, original=case['source'], catalog=pin(CATALOG), generator=pin(Path(__file__)),
    wrapperSuffixSha256=hashlib.sha256(wrapper.encode()).hexdigest(), cases=rows,
    rejectedV1=pin(HERE / 'rle-manifest.json'), controls=dict(source=control_source, expected=expected_stdout, cases=controls,
                  oracle='Independent imperative run-list model with exact U32 count wrapping; complete pairs and live aliases retained.')))
print(json.dumps(dict(variants=len(rows), controls=len(controls), expectedLines=len(expected), targetRuns=False)))
