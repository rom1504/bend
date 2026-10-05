#!/usr/bin/env python3
"""Prepare hash-bound release argv only; never install, compile or execute targets."""
import argparse, hashlib, json
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('attempt',type=Path);p.add_argument('new_output',type=Path)
p.add_argument('--ledger',type=Path);p.add_argument('--plan',type=Path,required=True)
a=p.parse_args();assert not a.plan.exists(),'Fresh plan output required; consumed plans stay unchanged'
assert a.ledger is None or a.ledger.is_file(),'An optional journal ledger must already exist'
root=Path(__file__).resolve().parents[4];project=root/'selfhost';attempt=a.attempt.resolve()
read=lambda f:json.loads(Path(f).read_text())
def identity(f):
 f=Path(f).resolve();return dict(file=str(f),sha256=hashlib.sha256(f.read_bytes()).hexdigest(),bytes=f.stat().st_size)
d=read(attempt/'attempt.json');assert d['checked'] and d['artifactKind']=='derived-b1','Existing 42-CLI gate expects equality-derived release'
b=read(d['bootstrapReport']['file']);api=d['api'];assert identity(api['file'])['sha256']==api['sha256']
assert identity(d['bootstrapReport']['file'])['sha256']==d['bootstrapReport']['sha256']
snapshot=Path(d['snapshot']['root']);runtime=snapshot/'src/runtime/js/direct.mjs';runtime_pin=identity(runtime)['sha256']
assert identity(project/'src/runtime/js/direct.mjs')['sha256']==runtime_pin
vendor=read(snapshot/'src/runtime/js/effs/manifest.json');assert vendor['base']['sha256']==d['base']['sha256'] and len(vendor['files'])==37
for item in vendor['files']:
 f=snapshot/'src/runtime/js/effs'/item['path'];i=identity(f);assert i['sha256']==item['sha256'] and i['bytes']==item['bytes']
for name in ['tools/typed-driver.mjs','tools/development/release.mjs','src/runtime/js/effs/manifest.json']:
 assert identity(project/name)['sha256']==identity(snapshot/name)['sha256'],name
legacy=root/'selfhost/build/phase43/integration01/final-plan/tools/release-smoke-launch.mjs'
legacy_runner=legacy.with_name('release-smoke.mjs');direct=Path(__file__).with_name('direct-release-smoke.mjs')
assert legacy.is_file() and legacy_runner.is_file() and direct.is_file()
node=d['node']['file'];out=a.new_output.resolve();assert not out.exists(),'Fresh future execution output required'
release=project/'tools/development/release.mjs';job=root/'selfhost/tools/performance/phase43/job.py';guard=root/'selfhost/tools/performance/phase46/job.py'
base=[node,'--stack-size=4096','--max-old-space-size=1024'];steps=[]
def step(name,argv,seconds,expected):
 guarded=['python3',str(guard),'--out',str(out/('job-'+name)),'--seconds',str(seconds),'--',*argv]
 if a.ledger:guarded=['python3',str(job),'--ledger',str(a.ledger.resolve()),'--out',str(out/('run-'+name)),'--',*guarded]
 steps.append(dict(name=name,argv=argv,seconds=seconds,expected=expected,guardedArgv=guarded))
step('install',base+[str(release),'--install-attempt',str(attempt)],300,dict(complete=True,apiSha256=api['sha256'],sourceSha256=b['sourceSha256']))
step('verify-before',base+[str(release),'--verify'],120,dict(complete=True,apiSha256=api['sha256'],sourceSha256=b['sourceSha256']))
step('legacy42',base+[str(legacy),str(project),str(out/'legacy42'),api['sha256']],1200,{'report':str(out/'legacy42/launcher.json'),'complete':True,'pass':True,'steps':42})
step('direct18',base+[str(direct),str(project),str(out/'direct18'),api['sha256'],b['sourceSha256'],runtime_pin],900,{'report':str(out/'direct18/report.json'),'complete':True,'pass':True,'steps':18})
step('verify-after',base+[str(release),'--verify'],120,dict(complete=True,apiSha256=api['sha256'],sourceSha256=b['sourceSha256']))
plan=dict(kind='phase52-final-release-qualification-plan',version=1,executed=False,cwd=str(root),output=str(out),
 attempt=identity(attempt/'attempt.json'),api=api,sourceSha256=b['sourceSha256'],directRuntime=identity(runtime),
 node=d['node'],vendorManifest=identity(snapshot/'src/runtime/js/effs/manifest.json'),
 tools=[identity(f) for f in [__file__,legacy,legacy_runner,direct,release,job,guard]],steps=steps,
 guardPolicy='Use guardedArgv only from an unlocked serial scheduler. phase43/job journals only; phase46/job owns the sole ExecutionGuard. Smoke children have no execution lock. If the parent already owns a guard, use argv directly instead. Never nest guardedArgv under another ExecutionGuard.',
 admission='Root must close selected semantics, maintained conformance, full45 performance and cost/release selection before install. This plan neither grants admission nor executes.',
 closure='Require all five supervised jobs complete; legacy launcher+checks pass exactly42, direct report pass exactly18, all direct inventory/input/output hashes unchanged, tampered copied runtime rejected and restored; final release API/source/directRuntime match selected identities.')
a.plan.parent.mkdir(parents=True,exist_ok=True)
with a.plan.open('x') as output:output.write(json.dumps(plan,indent=2)+'\n')
print(json.dumps(dict(plan=str(a.plan),executed=False,api=api['sha256'],source=b['sourceSha256'],directRuntime=runtime_pin)))
