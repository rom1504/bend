#!/usr/bin/env python3
"""Same-entry native/JS screen plus explicitly different production controls."""
import argparse,hashlib,importlib.util,json,re,shutil,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
spec=importlib.util.spec_from_file_location('support',ROOT/'selfhost/tools/performance/programs/support.py')
S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
ap=argparse.ArgumentParser(description=__doc__)
ap.add_argument('--build',type=Path,required=True);ap.add_argument('--binary',type=Path,required=True)
ap.add_argument('--out',type=Path,required=True);ap.add_argument('--cases',default='small,functions65,numeric_closed,map_closed,lexer_original')
ap.add_argument('--roles',default='native,js');ap.add_argument('--rounds',type=int,default=1)
ap.add_argument('--js-image',type=Path,help='Explicit separately recorded JS compatibility derivative')
ap.add_argument('--calls',type=int,default=1);ap.add_argument('--seconds',type=int,default=30)
a=ap.parse_args();assert 1<=a.calls<=5 and a.rounds>=1
build=a.build.resolve();binary=a.binary.resolve();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
js=a.js_image.resolve() if a.js_image else build/'compiler.cjs'
parent=ROOT/'selfhost/build/phase83/survey01/plan.json';old=json.loads(parent.read_text())
receipt=json.loads((build/'report.json').read_text());assert receipt['complete']
for k in ('source','js','c'):
    p=receipt[k];assert S.identity(p['file'])['sha256']==p['sha256']
node=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
base=ROOT/'selfhost/.bootstrap/upstream-phase66/bend2/base.bend'
runtime=ROOT/'selfhost/src/runtime/native/runtime.c';effects=ROOT/'selfhost/src/runtime/native/effs'
extra=json.loads((ROOT/'selfhost/build/phase86/fixtures/provenance.json').read_text())
extra['lexer_original']=dict(file=str(ROOT/'selfhost/tools/performance/phase37/fixtures-historical/lexer.bend'))
cases={k:(extra[k]['file'] if k in extra else old['cases'][k]['input']['file']) for k in a.cases.split(',')}
roles=a.roles.split(',');assert set(roles)<=set(['native','js','b2','typescript'])
inputs=[parent,build/'report.json',build/'compiler.bend',build/'compiler.cjs',build/'compiler.c',js,binary,node,base,runtime,HERE/'node-files.cjs',HERE/'reference.mjs',Path(__file__),*(Path(f) for f in cases.values()),*effects.glob('*.c')]
# The restricted entry's private scalar-effect permission is valid only here.
assert S.identity(base)['sha256']=='99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf'
for f,h in {'args.c':'7209a5fa11396fa8b0667a6738c913c40f554797e442c847a25e13a5f69676e0','print.c':'709500d2ace6e2eaeec0f5f1e4373d4ec5e402b3c1e289bd70dfef7e2a635b26','now.c':'da5fde65701c4fadc7560625c9615b4d60b2eefbd7b6bbe1aedda61887b825b9'}.items():
    assert S.identity(effects/f)['sha256']==h
pins=[S.identity(f) for f in inputs];report=dict(complete=False,cases=cases,roles=roles,calls=a.calls,rounds=a.rounds,jsImage=str(js),inputs=pins,rows=[])
S.save(out/'plan.json',report)
for name in ('compare.py','node-files.cjs','reference.mjs'):shutil.copyfile(HERE/name,out/name)
with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
    for rnd in range(a.rounds):
        for ix,(case,input) in enumerate(cases.items()):
            order=roles[:] if (rnd+ix)%2==0 else list(reversed(roles))
            for role in order:
                assert shutil.disk_usage(ROOT).free>160*1024**2
                name=f'{rnd+1}-{case}-{role}';prefix=out/name
                args=[input,str(base),str(runtime),str(effects),str(prefix),str(a.calls)]
                if role=='native':cmd=[str(binary),'--threads','1','--gpu','off','--',*args]
                elif role=='js':cmd=[str(node),'--max-old-space-size=1024','--stack-size=4096','--require',str(HERE/'node-files.cjs'),str(js),*args]
                else:cmd=[str(node),'--max-old-space-size=1024','--stack-size=4096',str(HERE/'reference.mjs'),role,input,str(prefix),str(a.calls)]
                command=['bash','-c','ulimit -f 65536; ulimit -c 0; exec "$@"','phase86','taskset','-c','3',*cmd]
                g=guard.run(command,out/(name+'-guard'),time.monotonic()+a.seconds)
                logs='\n'.join((out/(name+'-guard')/f).read_text(errors='replace') for f in ('stdout.log','stderr.log'))
                row=dict(name=name,round=rnd+1,case=case,role=role,guard=g,outputs=[S.identity(f) for f in sorted(out.glob(name+'.*.c'))],metrics=re.findall(r'(\w+(?:_ms|_chars))=(\d+)',logs))
                ref=Path(str(prefix)+'.json')
                if ref.exists():row['reference']=json.loads(ref.read_text())
                report['rows'].append(row);S.save(out/'report.json',report)
                print(json.dumps(dict(name=name,complete=g['complete'],wallSeconds=g['wallSeconds'],outputs=len(row['outputs']),metrics=row['metrics'])),flush=True)
for p in pins:assert S.identity(p['path'])==p
report['complete']=True;report['allJobsSucceeded']=all(r['guard']['complete'] for r in report['rows'])
S.save(out/'report.json',report)
