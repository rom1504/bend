"""Source-level two-U32 snapshot at the current map root's discriminating character."""
import argparse
import json
from pathlib import Path
import re
from prototype import BASE, EDGE_KEYS, HERE, ROOT, SCOPES, copy_body, edge_generator, pin
from trace import trace

PIVOT_EDGES=(*[tuple(map(ord,k)) for k in (*EDGE_KEYS, '長'*32+'a', '長'*32+'b', '🟦', '長'*31+'🟦', chr(0x10ffff))],
             (0xfffffffe,97), (0xffffffff,97), (0xfffffffd,97))
SCOPES=(*SCOPES,'get.go','get')
CALL=re.compile(r'\bMap\.('+'|'.join(re.escape(s) for s in sorted(SCOPES,key=len,reverse=True))+r')\(')
ARGS='anchor, word0, word1, '
TYPES='+anchor: Nat, +word0: U32, +word1: U32, '


def clone(cached):
    blocks=[]
    for name in SCOPES:
        head,body=copy_body(BASE.read_text(),name).split(':\n',1)
        head=head.replace('def Map.'+name+'(','def kw.'+name+'('+(TYPES if cached else ''),1)
        body=CALL.sub(lambda m:'kw.'+m[1]+'('+(ARGS if cached else ''),body)
        if cached:body=body.replace('Map.bit(','kw.bit('+ARGS)
        blocks.append(head+':\n'+body)
    return '\n\n'.join(blocks)+'\n'


def entries():
    defs=[]
    for op,decl,result,args in [
        ('set','a, -V: Kind(a), m: Map<a, V>, key: String, x: V','Map<a, V>','a, V, m, key, x'),
        ('del','a, -V: Kind(a), m: Map<a, V>, key: String','Map<a, V>','a, V, m, key'),
        ('get','-V: Data, d: V, m: Map<&2, V>, key: String','Map<&2, V> & V','V, d, m, key')]:
        call=f'kw.{op}.start('+args.replace(', m,',', MNode{p, lo, hi},')+', Nat.div(p, 33n))'
        defs.append(f"""def kw.{op}.ready({decl}, anchor: Nat, words: U32 & U32) -> {result}:
  (word0, word1) = words
  kw.{op}(anchor, word0, word1, {args})

def kw.{op}.start({decl.replace('key: String','+key: String')}, +anchor: Nat) -> {result}:
  kw.{op}.ready({args}, anchor, kw.pack(String.drop(key, anchor)))

def kw.{op}.entry({decl}) -> {result}:
  match m:
    case MNode{{+p, lo, hi}}: {call}
    case other: Map.{op}({args.replace(', m,',', other,')})""")
    return '\n\n'.join(defs)+'\n'


def materialize(out):
    out.mkdir(parents=True,exist_ok=False)
    refs=json.loads((ROOT/'selfhost/build/phase195/references01/manifest.json').read_text())['cases']
    cases={}
    for name in ('coverage-map-churn-128','coverage-record-aggregation-256','map-edges'):
        use='coverage-map-churn-32' if name=='map-edges' else name
        row=next(r for r in refs if r['id']==use)
        src=Path(row['source']['file'])
        assert pin(src)['sha256']==row['source']['sha256']
        raw=src.read_text()
        expected=row['point']['expectedStdout'].strip()
        if name=='map-edges':
            raw=raw.replace('def p37.map.key(i: U32) -> String:\n  String.append("key", U32.show(i))',
                edge_generator(PIVOT_EDGES)+f'def p37.map.key(i: U32) -> String:\n  kp.edge0(U32.to_nat(U32.mod(i, {len(PIVOT_EDGES)})))')
            edge=trace(32,17,lambda n:PIVOT_EDGES[n%len(PIVOT_EDGES)])['digest']
            raw=raw.replace(expected,str(edge));expected=str(edge)
        d=out/name;d.mkdir()
        case=dict(expected=expected,inputs=row['point']['runtimeArgs'],roles={})
        for role in ('stock','cached','clone'):
            s=raw
            if role!='stock':
                cached=role=='cached'
                for op in ('get','set','del'):
                    s=s.replace('Map.'+op+'(','kw.'+op+('.entry' if cached else '')+'(')
                parts=(HERE/'pivot.bend').read_text()+'\n'+clone(True)+'\n'+entries() if cached else clone(False)
                s=s.replace('import Base\n','import Base\n\n'+parts+'\n',1)
            p=d/(role+'.bend');p.write_text(s);case['roles'][role]=pin(p)
        cases[name]=case
    (out/'report.json').write_text(json.dumps(dict(complete=True,base=pin(BASE),lookup=pin(HERE/'pivot.bend'),edgeKeys=PIVOT_EDGES,cases=cases),indent=2)+'\n')


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
    materialize(p.parse_args().out.resolve())
