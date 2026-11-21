"""Measure bounded partial evaluation of a constant template with dynamic parameters."""
import argparse
import ast
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'fusion'))
from screen import BUILD,read,pin,checked_tool
ORIGINAL='def line(i: U32) -> U32:\n  lex(gen(tpl(), seed(i), 0), (Gap{}, 0))'
def specialize(text,stream):
    m=re.findall(r'^def tpl\(\) -> String:\n  ("[^"\n]*")$',text,re.M)
    assert len(m)==1 and text.count(ORIGINAL)==1
    chars=ast.literal_eval(m[0]);assert len(chars)<=64
    # Only the character and the template position are static. The seed and
    # identifier/number lengths remain derived from the live line argument.
    old=(HERE.parent/'streams/lexer.bend').read_text()
    if stream:
        helpers=old.split('def line(i: U32)')[0]+'def seq.finish(st: Mode & U32) -> U32:\n  (m, a) = st\n  flush(m, a)\n\n'
        expr=['  +s = seed(i)','  v0 = {(Gap{}, 0) : Mode & U32}']
    else:
        helpers='def seq.literal(c: U32, s: String) -> String:\n  SCon{Chr{c}, s}\n\n';expr=['  +s = seed(i)','  v0 = {SNil{} : String}']
    for j,k in enumerate(range(len(chars)) if stream else reversed(range(len(chars)))):
        c=chars[k];arg='v'+str(j);a='t'+str(j);b='v'+str(j+1)
        if c in 'ino':expr.append(f'  +{a} = salt(s, {k})')
        if c=='i':
            length=f'U32.to_nat(U32.inc(U32.and({a}, 7)))'
            call=('stream.ident' if stream else 'ident')+f'({length}, {a}, {arg})'
        elif c=='n':
            length=f'U32.to_nat(U32.inc(U32.mod({a}, 6)))'
            call=('stream.num' if stream else 'num')+f'({length}, {a}, {arg})'
        elif c=='o':
            call=(f'stream.char(op.pick(U32.is_ne(U32.and({a},2),0), U32.is_ne(U32.and({a},1),0)),{arg})' if stream else f'op({a},{arg})')
        else:
            call=f'stream.word({ord(c)}, {arg})' if stream else f'seq.literal({ord(c)}, {arg})'
        expr.append(f'  {b} = {call}')
    last='v'+str(len(chars))
    if stream:expr.append(f'  seq.finish({last})')
    else:expr.append(f'  lex({last}, (Gap{{}}, 0))')
    return text.replace(ORIGINAL,helpers+'def line(i: U32) -> U32:\n'+'\n'.join(expr))
def run(a):
    assert os.sched_getaffinity(0)=={3}
    out=a.out.resolve();out.mkdir(parents=True)
    case='lexer';m=BUILD/'phase198/native45-01/programs.manifest.json';c=next(x for x in read(m)['cases'] if x['id']==case)
    old=Path(checked_tool(c['source']));txt=old.read_text()
    r={'complete':False,'scope':'source ceiling','driver':pin(__file__),'catalog':pin(m),'cases':[]}
    save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
    # One ordinary program per receipt keeps the existing authenticated native
    # runtime comparison usable, including its independent alternate C inputs.
    f=out/'main.bend';f.write_text(specialize(txt,a.stream))
    assert f.read_text().split('# Phase93:',1)[1]==txt.split('# Phase93:',1)[1]
    q=read(BUILD/'phase198/native45-01/lexer/machine/report.json')
    jobs=next(j['command'][:] for j in q['jobs'] if j['label']=='compiler')
    jobs[jobs.index(str(old))]=str(f)
    obj=out/'program.o';t=time.monotonic()
    with obj.open('wb') as fd:child=subprocess.run(jobs,stdout=fd,stderr=subprocess.PIPE,timeout=35)
    rec={'id':case,'source':pin(f),'ordinary':c['source'],'seconds':time.monotonic()-t,'exit':child.returncode,
         'stderr':child.stderr.decode(),'argv':jobs,'sourceChangeBytes':f.stat().st_size-old.stat().st_size}
    if child.returncode==0 and obj.read_bytes()[:4]==b'\x7fELF':rec['object']=pin(obj)
    r['cases'].append(rec);r['complete']='object' in rec;save()
    if not r['complete']:raise SystemExit(rec['stderr'])
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--stream',action='store_true');p.add_argument('--out',required=True,type=Path);run(p.parse_args())
