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
ap.add_argument('--runtime-prefix',type=Path,help='Authenticated existing Bend-produced runtime chunks')
ap.add_argument('--keep-going',action='store_true',help='Retain expected refusal controls instead of stopping at the first failed worker')
ap.add_argument('--calls',type=int,default=1);ap.add_argument('--seconds',type=int,default=30)
a=ap.parse_args();assert a.calls in (1,5) and a.rounds>=1
build=a.build.resolve();binary=a.binary.resolve();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
js=a.js_image.resolve() if a.js_image else build/'compiler.cjs'
parent=ROOT/'selfhost/build/phase83/survey01/plan.json';old=json.loads(parent.read_text())
receipt=json.loads((build/'report.json').read_text());assert receipt['complete']
for k in ('source','js','c'):
    p=receipt[k];assert S.identity(p['file'])['sha256']==p['sha256']
node=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
base=ROOT/'selfhost/.bootstrap/upstream-phase66/bend2/base.bend'
runtime=a.runtime_prefix.resolve() if a.runtime_prefix else ROOT/'selfhost/src/runtime/native/runtime.c';effects=ROOT/'selfhost/src/runtime/native/effs'
extra=json.loads((ROOT/'selfhost/build/phase86/fixtures/provenance.json').read_text())
extra['lexer_original']=dict(file=str(ROOT/'selfhost/tools/performance/phase37/fixtures-historical/lexer.bend'))
extra['extra_import_valid']=dict(file=str(ROOT/'selfhost/build/phase86/fixtures-extra/main.bend'))
cases={k:(extra[k]['file'] if k in extra else old['cases'][k]['input']['file']) for k in a.cases.split(',')}
roles=a.roles.split(',');assert set(roles)<=set(['native','js','b2','typescript'])
if 'native' in roles:
    native_receipt=Path(str(binary)+'.build.json');native=json.loads(native_receipt.read_text())
    assert native['complete'] and native['source']['sha256']==receipt['c']['sha256']
    assert S.identity(binary)==native['binary']
if a.js_image:
    derivation=json.loads((js.parent/'derivation.json').read_text())
    assert derivation['parent']==receipt['js'] and derivation['output']['sha256']==S.identity(js)['sha256']
inputs=[parent,build/'report.json',build/'compiler.bend',build/'compiler.cjs',build/'compiler.c',js,binary,node,base,runtime,HERE/'node-files.cjs',HERE/'reference.mjs',Path(__file__),*(Path(f) for f in cases.values()),*effects.glob('*.c')]
if 'extra_import_valid' in cases:
    inputs.extend([ROOT/'selfhost/build/phase86/fixtures-extra/helper.bend',ROOT/'selfhost/build/phase86/fixtures-extra/provenance.json'])
if 'native' in roles:inputs.append(native_receipt)
if a.js_image:inputs.append(js.parent/'derivation.json')
if a.runtime_prefix:
    transport=runtime.parent/'receipt.json';t=json.loads(transport.read_text())
    assert t['templateSha256']=='f9f5a1c98f17f892d891032ca35489234e43d3b4112a18e592e6da408b09736c'
    template=Path(t['template']);assert S.identity(template)['sha256']==t['templateSha256']
    canonical=json.loads(template.read_text());assert canonical['runtimeSha256']==S.identity(runtime)['sha256']
    for ix,p in enumerate(t['parts']):
        assert Path(p['path']).resolve()==Path(str(runtime)+f'.part{ix}')
        assert S.identity(p['path'])==p and Path(p['path']).read_text()==canonical['parts'][ix]
        inputs.append(Path(p['path']))
    assert len(t['parts'])==5
    inputs.extend([transport,template])
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
                if g['complete']:assert len(row['outputs'])==a.calls,'Successful worker omitted a C output'
                ref=Path(str(prefix)+'.json')
                if ref.exists():row['reference']=json.loads(ref.read_text())
                report['rows'].append(row);S.save(out/'report.json',report)
                print(json.dumps(dict(name=name,complete=g['complete'],wallSeconds=g['wallSeconds'],outputs=len(row['outputs']),metrics=row['metrics'])),flush=True)
                if not g['complete'] and not a.keep_going:raise SystemExit('Worker failed; inspect this attempt before retrying in a fresh lane')
for p in pins:assert S.identity(p['path'])==p
report['complete']=True;report['allJobsSucceeded']=all(r['guard']['complete'] for r in report['rows'])
S.save(out/'report.json',report)
