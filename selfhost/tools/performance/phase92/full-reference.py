#!/usr/bin/env python3
"""One fresh TS/Bun full-source C request, contextualizing native self-emission."""
import importlib.util,json,pathlib,shutil,sys,time
sys.dont_write_bytecode=True
HERE=pathlib.Path(__file__).resolve().parent;sys.path.insert(0,str(HERE/'comparison'))
from support import ROOT,P,authenticate,pin,read,verify,unchanged
spec=importlib.util.spec_from_file_location('program_support',P/'programs/support.py')
S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
ctx=authenticate(ROOT/'selfhost/build/phase92/upstream-b1/build.json')
screen=read(ROOT/'selfhost/build/phase92/screen01/report.json');assert screen['complete'] and screen['passed']
bun=verify(screen['provenance']['bun']);worker=verify(screen['provenance']['referenceWorker'])
source=ctx['roles']['b2']['admission']['source'];oracle=read(ctx['build']['file'])['c'];verify(oracle)
out=ROOT/'selfhost/build/phase92/full-ts-bun01';assert not out.exists();assert shutil.disk_usage(ROOT).free>185*1024**2;out.mkdir()
cmd=['bash','-c','ulimit -f 65536; ulimit -c 0; exec "$@"','phase92','taskset','-c','3',bun['file'],worker['file'],'typescript',source['file'],str(out/'compiler'),'1']
report=dict(kind='phase92-full-source-typescript-context',complete=False,passed=False,source=source,oracle=oracle,bun=bun,worker=worker,method=pin(__file__),context=ctx,command=cmd)
S.save(out/'report.json',report)
with S.ExecutionGuard(rss_mib=3072,available_mib=4096) as guard:job=guard.run(cmd,out/'guard',time.monotonic()+150)
report['process']=job
if (out/'compiler.json').exists():report['workerResult']=read(out/'compiler.json')
if (out/'compiler.1.c').exists():
 report['output']=pin(out/'compiler.1.c');report['exactC']=(out/'compiler.1.c').read_bytes()==pathlib.Path(oracle['file']).read_bytes()
unchanged(ctx);verify(bun);verify(worker);report['inputsUnchanged']=True
report['complete']=bool(job['complete'] and job['returncode']==0 and not job.get('stoppedFor'))
w=report.get('workerResult',{});report['passed']=bool(report['complete'] and report.get('exactC') and w.get('complete') and len(w.get('calls',[]))==1)
report['scope']='Fresh single full-source C compilation by pinned TypeScript/Bun; ordinary Base preparation inside request, native prepared-Base decode outside request. TS and Bend backend outputs differ but each is fully checked against its own pinned C oracle. Not a repeated statistical benchmark.'
S.save(out/'report.json',report);print(json.dumps(dict(complete=report['complete'],passed=report['passed'],worker=w,processSeconds=job.get('wallSeconds'))))
sys.exit(0 if report['passed'] else 1)
