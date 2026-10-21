"""Prepare pinned RLE state-lane ceilings and independent exact-value controls.

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


OUTER = '''# Diagnostic: cur is a lane; (count, accumulator) remains one shell.
law p123.runs.outer:
  for xs: List<&2, U32>
  for +cur: U32
  for state: U32 & List<&2, P2()>
  List<&2, P2()>

def p123.runs.outer(xs, cur, state):
  match xs:
    case Nil{}:
      (n, acc) = state
      lrevp((n, cur) <> acc)
    case h0 <> t:
      (n, acc) = state
      +h = {h0 : U32}
      match U32.is_eq(h, cur):
        case False{}:
          p123.runs.outer(t, h, (1, (n, cur) <> acc))
        case True{}:
          p123.runs.outer(t, cur, (U32.add(n, 1), acc))

'''

FULL = '''# Diagnostic: all three state fields cross the loop edge as arguments.
law p123.runs.full:
  for xs: List<&2, U32>
  for +cur: U32
  for n: U32
  for acc: List<&2, P2()>
  List<&2, P2()>

def p123.runs.full(xs, cur, n, acc):
  match xs:
    case Nil{}:
      lrevp((n, cur) <> acc)
    case h0 <> t:
      +h = {h0 : U32}
      match U32.is_eq(h, cur):
        case False{}:
          p123.runs.full(t, h, 1, (n, cur) <> acc)
        case True{}:
          p123.runs.full(t, cur, U32.add(n, 1), acc)

'''


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
    result = before + helper + 'law rle:\n' + signature + 'def rle(xs, st):\n  (cur, n, acc) = st\n  ' + call + '\n\nlaw expand:\n' + after
    assert result.split('# Phase93:', 1)[1] == wrapper
    row = copy.deepcopy(case)
    row.update(name='test-rle-roundtrip-' + mode, parentName=case['name'],
               source=save('rle-' + mode + '.bend', result),
               diagnosticOnly=True, benchmarkClaim=False)
    rows.append(row)
save_json('rle-cases.json', dict(kind='phase123-source-only-RLE-state-ceilings', cases=rows))


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
prefix = before + 'law rle:\n' + old + OUTER + FULL
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
control_source = save('rle-controls.bend', prefix + 'def main() -> IO(Unit):\n  do IO<Unit>:\n' + '\n'.join(calls) + '\n')
expected_stdout = save('rle-controls.expected.stdout', '\n'.join(expected) + '\n')
expected_json = save_json('rle-controls.expected.json', dict(stdout='\n'.join(expected) + '\n', stderr='', status=0))
save_json('rle-controls.json', dict(cases=[dict(name='rle-controls', source=control_source,
                                            expected=expected_json, expectedStdoutEvidence=expected_json)]))
save_json('rle-manifest.json', dict(kind='phase123-RLE-state-ceiling-preparation', targetRuns=False,
    compilerTransformation=False, original=case['source'], catalog=pin(CATALOG), generator=pin(Path(__file__)),
    wrapperSuffixSha256=hashlib.sha256(wrapper.encode()).hexdigest(), cases=rows,
    controls=dict(source=control_source, expected=expected_stdout, cases=controls,
                  oracle='Independent imperative run-list model with exact U32 count wrapping; complete pairs and live aliases retained.')))
print(json.dumps(dict(variants=len(rows), controls=len(controls), expectedLines=len(expected), targetRuns=False)))
