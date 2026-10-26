"""Serialize accepted real IR into a complete-function native falsifier.

No compiler transformations or validation are implemented here: the generated
Bend calls the original/private checked verifier, including metadata preparation,
per-function schemas, flow, branch joins and disposal of temporary state.
"""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
FIELDS = {
    'N111U32': [], 'N111U64': [], 'N111Ptr': [],
    'N111Local': ['name'], 'N111Const': ['lo', 'hi'],
    'N111Symbol': ['name'], 'N111FuncId': ['name'], 'N111CtorId': ['name'],
    'N111Arg': ['typ', 'value'],
    'N111Set': ['name', 'typ', 'value'],
    'N111Bin': ['name', 'typ', 'op', 'left', 'right'],
    'N111Call': ['name', 'typ', 'symbol', 'args'],
    'N111If': ['condition', 'yes', 'no'], 'N111Return': ['value'],
    'N111Load': ['name', 'typ', 'base', 'offset'],
    'N111Store': ['typ', 'base', 'offset', 'value'],
    'N111Offset': ['name', 'base', 'bytes'], 'N111Alloca': ['name', 'bytes', 'align'],
    'N111Segment': ['name', 'arity', 'result', 'incoming', 'flags', 'body'],
    'N_Constructor': ['name', 'arity', 'hot'],
}


def pin(p):
    p = Path(p).resolve()
    b = p.read_bytes()
    return dict(file=str(p), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


def unlist(value):
    result = []
    while value['$'] == 'Con':
        assert set(value) == {'$', 'head', 'tail'}
        result.append(value['head'])
        value = value['tail']
    assert value == {'$': 'Nil'}
    return result


def literal(value):
    if isinstance(value, bool):
        return 'True{}' if value else 'False{}'
    if isinstance(value, int):
        assert 0 <= value <= 4294967295
        return str(value)
    if isinstance(value, str):
        # JSON string spelling matches these ASCII-only source IR identities;
        # refuse unsupported escapes instead of silently changing the carrier.
        encoded = json.dumps(value, ensure_ascii=False)
        assert '\\u' not in encoded
        return encoded
    tag = value['$']
    if tag in ['Con', 'Nil']:
        return '[' + ','.join(map(literal, unlist(value))) + ']'
    fields = FIELDS[tag]
    assert set(value) == {'$', *fields}, (tag, set(value), fields)
    return tag + '{' + ','.join(literal(value[k]) for k in fields) + '}'


def counts(segment):
    todo, statements, branches = unlist(segment['body']), 0, 0
    while todo:
        stmt = todo.pop()
        statements += 1
        if stmt['$'] == 'N111If':
            branches += 1
            todo.extend(unlist(stmt['yes']))
            todo.extend(unlist(stmt['no']))
    return statements, branches


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--screen', type=Path, required=True)
p.add_argument('--family', required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--functions', type=int, default=8)
p.add_argument('--repeats', type=int, default=256)
a = p.parse_args()
assert 1 <= a.functions <= 32 and 1 <= a.repeats <= 100000
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
screen = json.loads(a.screen.read_text())
assert screen['complete'] and screen['kind'] == 'phase144-complete-real-raw-verifier-screen'
row = next(r for r in screen['rows'] if r['name'] == a.family)
assert row['complete'] and all(call['error'] == '' for r in row['rounds'] for call in r['calls'])
raw = row['raw']
assert pin(raw['file']) == raw
program = json.loads(Path(raw['file']).read_text())
assert program['$'] == 'P111Program'
all_segments = unlist(program['segments'])
selected = sorted(enumerate(all_segments), key=lambda p: (*counts(p[1])[::-1], -p[0]), reverse=True)[:a.functions]
segments = [s for _, s in selected]
headers = [{**s, 'body': {'$': 'Nil'}} for s in all_segments]
as_list = lambda xs: '[' + ','.join(map(literal, xs)) + ']'
fixture = (
    '# Actual accepted IR: full selected bodies; every original metadata header.\n'
    'def p144vn_segments() -> List<&2,N111Segment>:\n  ' + as_list(segments) + '\n\n'
    'def p144vn_headers() -> List<&2,N111Segment>:\n  ' + as_list(headers) + '\n\n'
    'def p144vn_constructors() -> List<&2,N_Constructor>:\n  ' + literal(program['constructors']) + '\n'
)
assert len(fixture.encode()) <= 2_000_000, 'Use fewer functions for bounded acquisition'
workload = '''# Full function checks; independent original verifier remains available.
@unsafe
def p144vn_old_walk(segments: List<&2,N111Segment>, +ids: N111Ids, count: U32) -> U32:
  match segments:
    case Nil{}: count
    case Con{head,rest}:
      p144vn_old_walk(rest,ids,U32.add(count,Bool.to_u32(String.is_empty(p111v_segment(head,ids)))))

@unsafe
def p144vn_new_walk(segments: List<&2,N111Segment>, +ids: P144VIds, count: U32) -> U32:
  match segments:
    case Nil{}: count
    case Con{head,rest}:
      p144vn_new_walk(rest,ids,U32.add(count,Bool.to_u32(String.is_empty(p144v_segment(head,ids)))))

@unsafe
def p144vn_old_scans(functions: P111VScan, constructors: P111VScan) -> U32:
  match functions constructors:
    case P111VScan{fs,+fe,fc} P111VScan{cs,+ce,cc}:
      nt_choose(U32,String.is_empty(fe) && String.is_empty(ce),
        u => p144vn_old_walk(p144vn_segments(),N111Ids{fs,cs},0),u => 0)

@unsafe
def p144vn_new_scans(functions: P144VScan, constructors: P144VScan) -> U32:
  match functions constructors:
    case P144VScan{fs,+fe,fc} P144VScan{cs,+ce,cc}:
      nt_choose(U32,String.is_empty(fe) && String.is_empty(ce),
        u => p144vn_new_walk(p144vn_segments(),P144VIds{fs,cs},0),u => 0)

@unsafe
def p144vn_old_once() -> U32:
  p144vn_old_scans(p111v_functions(p144vn_headers(),P111VScan{missing(),"",0}),
    p111v_constructors(p144vn_constructors(),P111VScan{missing(),"",0}))

@unsafe
def p144vn_new_once() -> U32:
  p144vn_new_scans(p144v_functions(p144vn_headers(),P144VScan{P144VTEmpty{},"",0}),
    p144v_constructors(p144vn_constructors(),P144VScan{P144VTEmpty{},"",0}))

@unsafe
def p144vn_old_loop(left: U32, count: U32) -> U32:
  match left:
    case 0: count
    case _: p144vn_old_loop(U32.sub(left,1),U32.add(count,p144vn_old_once()))

@unsafe
def p144vn_new_loop(left: U32, count: U32) -> U32:
  match left:
    case 0: count
    case _: p144vn_new_loop(U32.sub(left,1),U32.add(count,p144vn_new_once()))
'''
out.mkdir(parents=True)
(out/'fixture.bend').write_text(fixture)
(out/'workload.bend').write_text(workload)
for mode in ['old', 'new']:
    (out/(mode+'-main.bend')).write_text(f'def main() -> U32:\n  p144vn_{mode}_loop({a.repeats},0)\n')
receipt = dict(kind='phase144-native-complete-verifier-slice-source', complete=True, checked=False,
    inputs=[pin(a.screen), raw, pin(__file__)],
    family=a.family, repeats=a.repeats, expected=a.repeats*len(segments),
    segments=[dict(index=i,name=s['name'],statements=counts(s)[0],branches=counts(s)[1]) for i,s in selected],
    metadataHeaders=len(headers), constructors=len(unlist(program['constructors'])),
    files=[pin(f) for f in sorted(out.glob('*.bend'))],
    scope='Serializer of accepted independently checked IR, not an alternate compiler. Complete selected real per-function verification, plus all actual metadata index construction and reclamation each repetition. Native acquisition/execution pending. Metadata-only unselected bodies are not presented as a complete executable program.')
(out/'manifest.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({k:receipt[k] for k in ['family','repeats','expected','metadataHeaders']}))
