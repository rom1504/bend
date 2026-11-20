"""Build source-level projections with the same native compiler as the ordinary suite."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import time

HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'fusion'))
from screen import read,pin,checked_tool,BUILD

p=argparse.ArgumentParser()
p.add_argument('--out',type=Path,required=True)
p.add_argument('--cases',default='lexer,coverage-unicode-text-64')
a=p.parse_args()
assert os.sched_getaffinity(0)=={3}
out=a.out;out.mkdir(parents=True,exist_ok=False)
m=BUILD/'phase198/native45-01/programs.manifest.json'
cases={c['id']:c for c in read(m)['cases']}
r={'complete':False,'scope':'source ceiling','driver':pin(__file__),'manifest':pin(m),'cases':[]}
def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
for id in a.cases.split(','):
    c=cases[id];src=Path(checked_tool(c['source']))
    original=src.read_text()
    if 'scalar-region' in id or 'mandelbrot' in id:
        import runpy
        patch=HERE/'fixed-state.py'
        text=runpy.run_path(str(patch))['source'](original)
    elif 'lexer' in id:
        old='def line(i: U32) -> U32:\n  lex(gen(tpl(), seed(i), 0), (Gap{}, 0))'
        patch=HERE/'lexer.bend';assert original.count(old)==1
        text=original.replace(old,patch.read_text().strip())
    else:
        assert 'unicode-text' in id
        prefix,after=original.split('def bench(size: U32, seed: U32) -> String:')
        body,h=after.split('# Phase93:')
        assert body.strip()=='text = p37.text.repeat(U32.to_nat(size), String.append("α,β,🍎,中,", String.append(U32.show(seed), ",")))\n  sjoin("|", ssplit(44, text))'
        patch=HERE/'unicode.bend';text=prefix+patch.read_text()+'\n# Phase93:'+h
    assert text.split('# Phase93:',1)[1]==original.split('# Phase93:',1)[1]
    folder=out/id;folder.mkdir()
    source=(folder/'main.bend').resolve();source.write_text(text)
    q=read(BUILD/'phase198/native45-01'/id/'machine/report.json')
    assert q['complete'] and q['binary']==c['products']['candidate']['artifact']
    cmd=next(x['command'][:] for x in q['jobs'] if x['label']=='compiler')
    cmd[cmd.index(str(src))]=str(source)
    obj=folder/'program.o';t0=time.monotonic()
    with obj.open('wb') as f:
        result=subprocess.run(cmd,stdout=f,stderr=subprocess.PIPE,timeout=40)
    row={'id':id,'ordinary':c['source'],'source':pin(source),'projection':pin(patch),
         'compiler':q['request']['image'],'argv':cmd,'seconds':time.monotonic()-t0,
         'exit':result.returncode,'stderr':result.stderr.decode(errors='replace')[:2500]}
    r['cases'].append(row);save()
    if result.returncode==0 and obj.read_bytes()[:4]==b'\x7fELF':row['object']=pin(obj)
    save()
r['complete']=all('object'in x for x in r['cases']);save()
if not r['complete']:raise SystemExit(1)
