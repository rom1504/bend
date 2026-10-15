#!/usr/bin/env python3
"""Check the frozen law and its exact safe dependency closure independently.

Kernel compilation is cached by source, toolchain and artifact hashes, never
by a successful Bend frontend verdict. The cache is a derived Lean module, not
a changed or truncated kernel. All actual targets use the common serial guard.
"""
import argparse, hashlib, json, os, pathlib, re, shutil, subprocess, sys
ROOT=pathlib.Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser();p.add_argument('--out',type=pathlib.Path,required=True)
p.add_argument('--toolchain',type=pathlib.Path,default=ROOT/'selfhost/build/phase94/toolchain/lean-4.34.0-linux')
p.add_argument('--kernel',type=pathlib.Path,default=ROOT/'selfhost/build/phase94/kernel')
p.add_argument('--audit-toolchain',action='store_true',help='Rehash all 12,695 installed toolchain files; outside the hot proof loop')
a=p.parse_args();out=a.out.resolve();assert not out.exists();out.mkdir(parents=True)
def pin(path):
 path=pathlib.Path(path).resolve();h=hashlib.sha256()
 with path.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
 return dict(file=str(path),bytes=path.stat().st_size,sha256=h.hexdigest())
def read(path):return json.loads(pathlib.Path(path).read_text())
inputs=[]
def bind(path):
 item=pin(path);inputs.append(item);return item
def run(name,argv,expected=0,seconds=60):
 d=out/name;cmd=[sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase86/guard.py'),'--out',str(d),'--seconds',str(seconds),'--cpu','3','--',*map(str,argv)]
 result=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True)
 proc=read(d/'process.json');stdout=(d/'stdout.log').read_text();stderr=(d/'stderr.log').read_text()
 rows[name]=dict(process=proc,stdout=stdout,stderr=stderr)
 save();assert proc['returncode']==expected and not proc.get('stoppedFor'),(name,stdout,stderr)
 return stdout,stderr
rows={};report=dict(complete=False,independentlyChecked=False,rows=rows,inputs=inputs)
def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
try:
 bind(__file__);bind(ROOT/'selfhost/tools/performance/phase86/guard.py');bind(ROOT/'selfhost/tools/performance/programs/support.py')
 proof=ROOT/'selfhost/proofs/phase94/candidate01/proof.bend'
 frozen=read(ROOT/'selfhost/build/phase94/proof-frozen01/manifest.json')
 for item in frozen:assert bind(item['file'])==item
 kernel=a.kernel.resolve();assert pin(ROOT/'bend2/bendtt.lean')['sha256']==pin(kernel/'BendTT.lean')['sha256']=='83cdd36e66dcd2cabcc3d10556c9c874f8d823956feab88f8bb5a81473d51be3'
 for f in ['BendTT.lean','BendTT.olean','Run.lean']:bind(kernel/f)
 assert (kernel/'Run.lean').read_text()=='import BendTT\n'
 build=read(ROOT/'selfhost/build/phase94/kernel-build02/process.json');assert build['complete'] and build['returncode']==0
 bind(ROOT/'selfhost/build/phase94/kernel-build02/process.json')
 assert pin(kernel/'BendTT.olean')['sha256']=='5dea85a37284670001eb590e9ec49ffe0fc7889390cf29e05a7ba66c1eb9b9cb'
 for f in ['bin/lean','lib/lean/libleanshared.so']:bind(a.toolchain/f)
 assert pin(a.toolchain/'lib/lean/libleanshared.so')['sha256']=='ab523f803d805db2c08eb755f0fa8189345bf6ae9b408664cdf3cf67fa0112d9'
 for name in ['extraction.json','server-files.json','release.json','relocation.json']:bind(ROOT/'selfhost/build/phase94/toolchain'/name)
 if a.audit_toolchain:
  for r in read(ROOT/'selfhost/build/phase94/toolchain/extraction.json')['files']+read(ROOT/'selfhost/build/phase94/toolchain/server-files.json'):
   suffix=pathlib.Path(r['file']).relative_to('/dev/shm/bend-phase94-lean/lean-4.34.0-linux')
   actual=pin(a.toolchain/suffix);assert (actual['sha256'],actual['bytes'])==(r['sha256'],r['bytes'])
  report['toolchainFilesVerified']=12695
 else:
  # The first replay completed the full file audit before its inventory parser
  # failed. Reuse only that sub-result, never its overall proof verdict.
  audit=ROOT/'selfhost/build/phase94/proof-replay01/report.json';bind(audit)
  assert read(audit)['toolchainFilesVerified']==12695
  report['toolchainFilesVerified']=0
  report['toolchainAudit']='Previously verified installation; this fast run rehashes executable/shared library and manifest, not every module.'
 bun=ROOT/'selfhost/build/phase66/bun-toolchain01/bun';bind(bun)
 for f in ['bend2/main.ts','bend2/bend.ts','bend2/safe.ts','bend2/base.bend']:bind(ROOT/f)
 outtext,err=run('check',['env','BEND_NO_TELEMETRY=1',bun,ROOT/'bend2/main.ts',proof,'--check-only'])
 assert outtext=='ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and not err
 tt=out/'environment.bendtt';outtext,err=run('elaborate',['env','BEND_NO_TELEMETRY=1',bun,ROOT/'bend2/main.ts',proof,'-o',tt]);assert not outtext and not err
 report['elaboration']=bind(tt)
 assert report['elaboration']['sha256']=='64ca377400730bc349a75e44f7dac417b0cb7000b82b71be2e32028b442e9a83'
 report['definitions']=re.findall(r'^(?:opaque )?(\S+) :',tt.read_text(),re.M);assert len(report['definitions'])==36
 prefix=['env','LEAN_STACK_SIZE_KB=4096','LEAN_PATH='+str(kernel),a.toolchain/'bin/lean','-M1400','--run',kernel/'Run.lean']
 stdout,stderr=run('kernel-positive',prefix+[tt],seconds=30);assert stdout=='ALL PROOFS CHECK\n' and not stderr
 negative=ROOT/'selfhost/proofs/phase67/reject-unequal-labels.bendtt';bind(negative)
 stdout,stderr=run('kernel-negative',prefix+[negative],expected=1,seconds=30)
 assert stdout.startswith('SOME PROOFS FAIL\nIn phase67_false:') and 'expected: .left' in stdout and 'observed: .right' in stdout and not stderr
 for item in inputs:assert pin(item['file'])==item
 report.update(complete=True,independentlyChecked=True,scope='Exact generic helper equivalence under typed pure total callbacks; no proof of unsafe adapters, emitter or runtime.')
except BaseException as error:
 report['error']=repr(error);save();raise
save();print(json.dumps({k:report[k] for k in ['complete','independentlyChecked','toolchainFilesVerified']}))
