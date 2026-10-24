"""Compare verified full-image QBE statically; never build or execute targets.

Reports exact function bodies and whole-image static callsites. Instruction
counts and allocation callsites are evidence of code shape, not runtime gains.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[5]
OWNERS={'missing','index_find','index_find_absent','index_find_leaf','index_bucket',
        'ns_ctor_index','p112s_ctors','p111v_put','p113e_signature','atom','kt','p131i_insert',
        'p98_tag_eq','p88_string_eq','p88_string_eq_go','String.eq','String.order','String.cmp',
        'nq_uses','nq_min_uses','ns_unshared_terms','nh_terms'}

def pin(p):
    p=p.resolve();h=hashlib.sha256()
    with p.open('rb') as f:
        for chunk in iter(lambda:f.read(1024*1024),b''):h.update(chunk)
    return dict(file=str(p),bytes=p.stat().st_size,sha256=h.hexdigest())

def decode(symbol):
    if 'FID_' not in symbol:return symbol
    suffix=symbol.split('FID_',1)[1]
    try:return ''.join(chr(int(x)) for x in suffix.split('_') if x)
    except ValueError:return symbol

def inspect(p,label,out):
    total=Counter();selected=[];header=None;lines=[];count=0;static_words=None
    with p.open() as f:
        for line in f:
            if line.startswith('data $p111_program ') or line.startswith('export data $p111_program '):
                fields=line.split('{',1)[1].rsplit('}',1)[0].split(',');assert len(fields)==24
                word=fields[8].strip();assert word.startswith('l ');static_words=int(word[2:])
            if 'call $' in line:
                for helper in re.findall(r'\bcall \$(p\w*?_rt_\w+)\(',line):total[helper]+=1
            if line.startswith('function ') or line.startswith('export function '):
                match=re.search(r'\$([\w]+)\(',line);assert match
                symbol=match[1];name=decode(symbol);count+=1
                matches=[owner for owner in OWNERS if name==owner or name.endswith('.'+owner) or name.endswith(':'+owner)]
                header=(symbol,name,matches) if matches else None
                lines=[line] if header else []
            elif header:
                lines.append(line)
                if line.strip()=='}':
                    symbol,name,owners=header;body=''.join(lines)
                    target=out/(label+'-'+symbol+'.ssa');target.write_text(body)
                    selected.append(dict(symbol=symbol,name=name,owners=owners,qbeLines=len(lines),
                        constructorCallsites=body.count('call $p111_rt_ctor('),
                        genericJumpCallsites=body.count('call $p111_rt_jump('),
                        runtimeCallsites=dict(Counter(re.findall(r'\bcall \$(p\w*?_rt_\w+)\(',body))),body=pin(target)))
                    header=None;lines=[]
    return dict(label=label,source=pin(p),functions=count,staticWords=static_words,staticWordLimit=65536,runtimeCallsites=dict(total),selected=selected)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline',type=Path,required=True);p.add_argument('--candidate',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);args=p.parse_args()
    out=args.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131');out.mkdir()
    report=dict(complete=False,targetsRun=False,inputs=[pin(Path(__file__))],rows=[],
        scope='Static full-image QBE and selected function bodies only. Compare actual native timings/events separately; callsite counts are not dynamic allocation totals.')
    for label,path in [('baseline',args.baseline),('candidate',args.candidate)]:
        report['rows'].append(inspect(path.resolve(),label,out))
    report['complete']=True
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')

if __name__=='__main__':main()
