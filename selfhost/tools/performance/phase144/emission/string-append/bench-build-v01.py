"""Root-only small benchmark builds; reuse requires exact IR/runtime/tool policy."""
import argparse, filecmp, importlib.util, json, os, re, shutil, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6]
HERE=Path(__file__).resolve().parent
BUILDER=ROOT/'selfhost/tools/performance/phase123/build-aligned.py'
ORACLE=ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py'
spec=importlib.util.spec_from_file_location('O',ORACLE);O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
pin,verify=O.pin,O.verify

def read(p):return json.loads(Path(p).read_text())

def identical(a,b):
    return (a['bytes'],a['sha256'])==(b['bytes'],b['sha256']) and filecmp.cmp(a['file'],b['file'],shallow=False)

def reusable(receipt,qbe,runtime):
    verify(receipt);r=read(receipt['file'])
    assert r['complete'] and r['kind']=='phase123-branch-aligned-qbe-build'
    for p in r['inputs']+[r['binary'],r['object']]:verify(p)
    if not any(identical(p,qbe) for p in r['inputs'] if p['file'].endswith('.ssa')):return None
    if runtime not in r['inputs']:return None
    if not identical(r['inputs'][0],pin(BUILDER)):return None
    tools=[ROOT/'selfhost/build/phase108/toolchain/qbe-1.3/qbe',Path(shutil.which('as')),Path(shutil.which('gcc'))]
    if not all(pin(t) in r['inputs'] for t in tools):return None
    assert all(j['exitCode']==0 for j in r['jobs'])
    return r

ap=argparse.ArgumentParser(description=__doc__)
for k in ['baseline','candidate','out']:ap.add_argument('--'+k,type=Path,required=True)
a=ap.parse_args();out=a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
assert sorted(os.sched_getaffinity(0))==[3]
manifest=read(HERE/'bench-cases-v01.json');emissions={k:read(getattr(a,k)) for k in ['baseline','candidate']}
assert all(e['complete'] for e in emissions.values())
inputs=[pin(__file__),pin(BUILDER),pin(ORACLE),pin(HERE/'bench-cases-v01.json'),*manifest['inputs'],pin(a.baseline),pin(a.candidate)]
for e in emissions.values():inputs.extend(e['inputs'])
for p in inputs:verify(p)
for c in manifest['cases']:
 for key in ['source','expectedStdoutEvidence','stdoutEvidence','retainedQbe','retainedBuild']:verify(c[key])
 assert Path(c['expectedStdoutEvidence']['file']).read_text()==c['expectedStdout']
 assert c['historicalArgumentVector']==list(map(str,[c['repetitions'],c['warmups'],*c['runtimeArgs']]))
out.mkdir();report=dict(kind='phase144-append-benchmark-builds',complete=False,inputs=inputs,builds=[],smokes=[])
save=lambda:O.save(out/'report.json',report)
save();begun=time.monotonic();available={c['name']:[c['retainedBuild']] for c in manifest['cases']}
try:
 for role,e in emissions.items():
  assert [x['name'] for x in e['cases']]==[x['name'] for x in manifest['cases']]
  for c,x in zip(manifest['cases'],e['cases']):
   assert c['source']==x['source'];verify(x['qbe']);verify(e['runtime'])
   chosen=None;build=None
   for old in available[c['name']]:
    build=reusable(old,x['qbe'],e['runtime'])
    if build is not None:chosen=old;break
   reused=chosen is not None;seconds=0
   if not reused:
    dest=ROOT/'selfhost/build/phase111'/('p144-append-bench-'+role+'-'+c['name']+'-build01')
    assert not dest.exists()
    command=[sys.executable,'-B',str(BUILDER),'--source',x['qbe']['file'],'--runtime',e['runtime']['file'],'--out',str(dest),'--seconds','30']
    with (out/(role+'-'+c['name']+'.build.log')).open('xb') as log:
     t=time.monotonic();p=subprocess.run(command,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,timeout=45);seconds=time.monotonic()-t
    assert p.returncode==0;chosen=pin(dest/'report.json');build=reusable(chosen,x['qbe'],e['runtime']);assert build
   available[c['name']].append(chosen)
   text=Path(x['qbe']['file']).read_text()
   descriptor=next(s for s in text.splitlines() if s.startswith('export data $p111_program ='))
   words=descriptor.split('{',1)[1].rsplit('}',1)[0].split(',');assert len(words)==24
   capabilities=int(words[11].strip().removeprefix('l '))
   row=dict(role=role,name=c['name'],reused=reused,build=chosen,binary=build['binary'],qbe=x['qbe'],runtime=e['runtime'],buildSeconds=seconds,capabilities=capabilities,concatCallSites=len(re.findall(r'call \$p125_rt_concat_typed\(',text)))
   report['builds'].append(row);save()
   smoke=dict(c,repetitions=1,warmups=0)
   command=[build['binary']['file'],'--threads','1','--gpu','off','--','1','0',*map(str,c['runtimeArgs'])]
   t=time.monotonic();p=subprocess.run(command,cwd=ROOT,capture_output=True,timeout=30);wall=time.monotonic()-t
   stem=role+'-'+c['name'];so=out/(stem+'.stdout');se=out/(stem+'.stderr');so.write_bytes(p.stdout);se.write_bytes(p.stderr)
   elapsed=O.observation(p.stdout,p.stderr,p.returncode,smoke,wall)
   report['smokes'].append(dict(role=role,name=c['name'],command=command,status=p.returncode,wallSeconds=wall,elapsedMs=elapsed,stdout=pin(so),stderr=pin(se),correct=True));save()
 for c in manifest['cases']:
  pair={x['role']:x['capabilities'] for x in report['builds'] if x['name']==c['name']}
  assert (pair['baseline'] & ~4)==(pair['candidate'] & ~4),'Other capability bits changed'
  assert not pair['baseline']&4 or pair['candidate']&4,'Live-register bank regressed'
 for row in report['builds']:
  for key in ['build','binary','qbe','runtime']:verify(row[key])
 for p in inputs:verify(p)
 report['complete']=True
except BaseException as err:report['error']=repr(err);raise
finally:report['seconds']=time.monotonic()-begun;save()
print(json.dumps(dict(complete=True,builds=len(report['builds']),reused=sum(x['reused'] for x in report['builds']))))
