"""Discriminate producer retention from new physical homes on two real families."""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import runpy
import statistics
import subprocess
import sys
from project import BUILD, EMIT, HERE, ROOT, sha
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import ASSETS, REFERENCES, checked_tool, execute, read

CASES=['editdist','mandelbrot']
ROLES=['baseline','producer','physical']
PLACEMENT=HERE/'hot-placement.py'
FREEZE=HERE/'hot-freeze.json'
def digest(text):return hashlib.sha256(text.encode()).hexdigest()

def freeze():
    native={r['id']:r for r in read(BUILD/'phase198/native45-01/report.json')['rows']}
    project=runpy.run_path(str(PLACEMENT))['project']
    spec=dict(driver=sha(Path(__file__)),algorithm=sha(PLACEMENT),cases={},criteria='2% shorter on both layouts and 3/4 positive pairs on an admitted family. All outputs required.')
    for case in CASES:
        src=EMIT/case/'program.s';obj=src.with_suffix('.o')
        assert sha(obj)==native[case]['object']['sha256']
        text=src.read_text()
        spec['cases'][case]=dict(source=sha(src),object=sha(obj),direct=native[case]['artifact'],
                                 variants={k:digest(project(text,k)) for k in ROLES})
    FREEZE.write_text(json.dumps(spec,indent=2)+'\n')

def run(out):
    assert os.sched_getaffinity(0)=={3}
    spec=read(FREEZE)
    assert spec['driver']==sha(Path(__file__)) and spec['algorithm']==sha(PLACEMENT)
    project=runpy.run_path(str(PLACEMENT))['project']
    refs={r['id']:r for r in read(REFERENCES)['cases']}
    assets=read(ASSETS)
    policy=assets['toolchains']['x86']
    assembler,link,runtime=[checked_tool(assets['assets'][k]) for k in ['assembler','linker','qbe-runtime']]
    out.mkdir(parents=True)
    report=dict(complete=False,freeze=sha(FREEZE),cases={})
    def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    for ci,case in enumerate(CASES):
        ref=refs[case];p=ref['point'];sp=spec['cases'][case]
        src=EMIT/case/'program.s';assert sha(src)==sp['source'] and sha(src.with_suffix('.o'))==sp['object']
        products={}
        row=dict(checks=[],times=[],calibration=[],products={},ratios={})
        report['cases'][case]=row
        for role in ROLES:
            txt=project(src.read_text(),role)
            assert digest(txt)==sp['variants'][role]
            for layout,flags in [('project',policy['assemblerFlags']),('default',[])]:
                label=layout+'-'+role
                folder=out/case/label;folder.mkdir(parents=True)
                a,o,e=[folder/('program'+suffix) for suffix in ['.s','.o','']]
                a.write_text(txt)
                for cmd in [[assembler,*flags,'-o',o,a],[link,*policy['linkerFlags'],o,runtime,*policy['libraries'],'-o',e]]:
                    subprocess.run(cmd,check=True,capture_output=True,timeout=15)
                products[label]=e
                row['products'][label]=dict(object=sha(o),binary=sha(e))
        direct=checked_tool(sp['direct'])
        for j,args in enumerate([p['runtimeArgs'],[0,3],[1,17],[3,23]]):
            c=ref['products']['c'];reps=int(j==0)
            obs,expected=execute(checked_tool(c['artifact']),args,reps,0,p['expectedStdout'] if j==0 else None,c['runtimeArgumentConvention'])
            other={k:execute(b,args,reps,0,expected)[0] for k,b in [('direct',direct),*products.items()]}
            row['checks'].append(dict(inputs=args,c=obs,others=other))
        count=max(1,p['repetitions']//4)
        for _ in range(10):
            obs,_=execute(direct,p['runtimeArgs'],count,3,p['expectedStdout'])
            row['calibration'].append(dict(count=count,elapsed=obs['elapsedMs']))
            if 130<=obs['elapsedMs']<=240:break
            count=max(1,round(count*180/max(1,obs['elapsedMs'])))
        else:raise ValueError('calibration '+case)
        for turn in range(4):
            for layout in (['project','default'] if (turn+ci)%2==0 else ['default','project']):
                order=list(ROLES) if layout=='project' else list(reversed(ROLES))
                q=(turn+ci)%3
                for pos,role in enumerate(order[q:]+order[:q]):
                    obs,_=execute(products[layout+'-'+role],p['runtimeArgs'],count,3,p['expectedStdout'])
                    row['times'].append(dict(turn=turn,layout=layout,role=role,position=pos,count=count,**obs))
            save()
        for layout in ['project','default']:
            def raw(role):return [x['elapsedMs'] for x in row['times'] if x['layout']==layout and x['role']==role]
            for a,b in [('baseline','producer'),('baseline','physical'),('producer','physical')]:
                rat=[y/x for x,y in zip(raw(a),raw(b))]
                row['ratios'][layout+':'+b+'/'+a]=dict(raw=rat,median=statistics.median(rat),wins=sum(v<1 for v in rat))
        save()
    report['complete']=True;save()

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--freeze',action='store_true');p.add_argument('--out',type=Path)
    a=p.parse_args()
    if a.freeze:freeze()
    else:run(a.out)
