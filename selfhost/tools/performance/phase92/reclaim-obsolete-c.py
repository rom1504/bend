#!/usr/bin/env python3
"""Verify exact committed archive copies before reclaiming two obsolete C files."""
import argparse,fcntl,hashlib,json,os,pathlib,stat,subprocess,zipfile
ROOT=pathlib.Path(__file__).resolve().parents[4]
PLAN=ROOT/'implementation/phase92/obsolete-upstream-c-reclaim-plan.json'
def digest(b):return hashlib.sha256(b).hexdigest()
p=argparse.ArgumentParser(description=__doc__);p.add_argument('action',choices=['apply','restore']);p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args()
plan=json.loads(PLAN.read_text());out=a.out.resolve();assert not out.exists();os.sched_setaffinity(0,{0})
if a.action=='restore':assert ROOT not in out.parents
with (ROOT/'selfhost/build/phase32/execution.lock').open() as lock:
 fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB);rows=[]
 for r in plan['files']:
  for c in r['capsules']:
   b=(ROOT/c['file']).read_bytes();assert (len(b),digest(b))==(c['bytes'],c['sha256'])
   assert subprocess.check_output(['git','rev-parse',plan['head']+':'+c['file']],cwd=ROOT,text=True).strip()==c['gitBlob']
   assert subprocess.check_output(['git','hash-object','--stdin'],cwd=ROOT,input=b).decode().strip()==c['gitBlob']
  manifest=json.loads((ROOT/r['capsules'][0]['file']).read_text());m=next(x for x in manifest if x['file']==r['file'])
  assert (m['bytes'],m['sha256'])==(r['bytes'],r['sha256'])
  with zipfile.ZipFile(ROOT/r['capsules'][1]['file']) as z:
   b=z.read(r['archiveMember']);mode=stat.S_IMODE(z.getinfo(r['archiveMember']).external_attr>>16)
  assert (len(b),digest(b),mode)==(r['bytes'],r['sha256'],r['mode'])
  if a.action=='apply':
   f=ROOT/r['file'];s=f.lstat();assert stat.S_ISREG(s.st_mode) and s.st_nlink==1 and f.resolve()==f and f.read_bytes()==b
  rows.append((r,b))
 if a.action=='apply':
  for r,b in rows:assert (ROOT/r['file']).read_bytes()==b;(ROOT/r['file']).unlink()
  receipt=out
 else:
  out.mkdir(parents=True)
  for r,b in rows:
   f=out/r['file'];f.parent.mkdir(parents=True,exist_ok=True);f.write_bytes(b);f.chmod(r['mode']);assert digest(f.read_bytes())==r['sha256']
  receipt=out/'receipt.json'
 receipt.parent.mkdir(parents=True,exist_ok=True)
 result=dict(complete=True,action=a.action,plan=dict(file=str(PLAN),sha256=digest(PLAN.read_bytes())),files=[r for r,b in rows],bytes=sum(r['bytes'] for r,b in rows))
 with receipt.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
 print(json.dumps(dict(complete=True,action=a.action,bytes=result['bytes'])))
