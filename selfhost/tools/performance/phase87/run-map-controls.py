#!/usr/bin/env python3
"""Serial bounded checked-source/native/JS controls; retain expected failures."""
import json, pathlib, subprocess, sys
ROOT=pathlib.Path(__file__).resolve().parents[4]
assert len(sys.argv)<=2, 'Usage: run-map-controls.py [FRESH_OUTPUT_DIR]'
OUT=pathlib.Path(sys.argv[1]).resolve() if len(sys.argv)==2 else ROOT/'selfhost/build/phase87/map'
assert OUT.is_relative_to(ROOT), 'Output must stay inside this repository'
OUT.mkdir(parents=True,exist_ok=False)
NODE='/home/ai/.nvm/versions/node/v24.18.0/bin/node'
CLANG='/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang'
INC='/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang'
GUARD=ROOT/'selfhost/tools/performance/phase86/guard.py'
METHOD=ROOT/'selfhost/tools/performance/phase87/map'
def run(name, command, seconds=30):
    out=OUT/(name+'-guard')
    p=subprocess.run([sys.executable,'-B',str(GUARD),'--out',str(out),'--seconds',str(seconds),'--cpu','3','--',*map(str,command)],cwd=ROOT,stdout=subprocess.PIPE,text=True)
    record=json.loads((out/'process.json').read_text())
    return {'guard':str(out.relative_to(ROOT)), 'guardExit':p.returncode, **record}
rows=[]
for case in ['law-eager','law-match','typed-eager','typed-match','typed-thread','safe-eager-negative','typed-double','data-double']:
    out=OUT/case
    r={'case':case}
    r['acquire']=run(case+'-acquire',[NODE,'--max-old-space-size=1024','--stack-size=4096',METHOD/'acquire.mjs',METHOD/(case+'.bend'),out])
    if r['acquire']['complete']:
        r['js']=run(case+'-js',[NODE,'--max-old-space-size=1024','--stack-size=4096',out/'program.cjs'])
        r['build']=run(case+'-build',[CLANG,'-isystem',INC,'-std=c11','-O2',out/'program.c','-lpthread','-lm','-o',out/'program'])
        if r['build']['complete']:
            r['native']=run(case+'-native',[out/'program','--threads','1','--gpu','off'])
    rows.append(r)
    (OUT/'summary.json').write_text(json.dumps(rows,indent=2)+'\n')
    print(json.dumps({'case':case,**{k:(v['complete'],v['wallSeconds']) for k,v in r.items() if isinstance(v,dict)}}),flush=True)
