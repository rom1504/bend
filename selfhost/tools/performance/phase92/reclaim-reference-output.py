#!/usr/bin/env python3
"""Deduplicate the closed TS/Bun output against its already committed exact C."""
import fcntl,hashlib,json,os,pathlib,stat,subprocess,zipfile
ROOT=pathlib.Path(__file__).resolve().parents[4]
CAP=ROOT/'selfhost/tools/performance/phase92/evidence01';COMMIT='f026ace'
OUTPUT=ROOT/'selfhost/build/phase92/full-ts-bun01/compiler.1.c'
MEMBER='selfhost/build/phase92/upstream-checked01/compiler.c'
def digest(b):return hashlib.sha256(b).hexdigest()
os.sched_setaffinity(0,{0})
with (ROOT/'selfhost/build/phase32/execution.lock').open() as lock:
 fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 receipt=json.loads((CAP/'receipt.json').read_text())
 for key in ['archive','manifest']:
  r=receipt[key];b=(ROOT/r['file']).read_bytes();assert (len(b),digest(b))==(r['bytes'],r['sha256'])
  actual=subprocess.check_output(['git','hash-object','--stdin'],cwd=ROOT,input=b).decode().strip()
  assert actual==subprocess.check_output(['git','rev-parse',COMMIT+':'+r['file']],cwd=ROOT,text=True).strip()
 r=json.loads((OUTPUT.parent/'report.json').read_text());assert r['complete'] and r['passed'] and r['exactC']
 with zipfile.ZipFile(CAP/'raw.zip') as z:b=z.read(MEMBER);mode=stat.S_IMODE(z.getinfo(MEMBER).external_attr>>16)
 s=OUTPUT.lstat();assert stat.S_ISREG(s.st_mode) and s.st_nlink==1 and OUTPUT.resolve()==OUTPUT
 assert OUTPUT.read_bytes()==b==(ROOT/MEMBER).read_bytes()
 assert (len(b),digest(b))==(r['output']['bytes'],r['output']['sha256'])
 result=dict(complete=True,action='deduplicate-closed-output',output=r['output'],archive=receipt['archive'],member=MEMBER,mode=mode,committedAt=subprocess.check_output(['git','rev-parse',COMMIT],cwd=ROOT,text=True).strip(),bytes=len(b),restore='Extract archive member to a fresh destination, verify SHA256 and length, then explicitly restore output.file if missing. Exact upstream-checked C remains locally.')
 out=ROOT/'implementation/phase92/reclamation-reference.json'
 with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
 OUTPUT.unlink();print(json.dumps(dict(complete=True,bytes=len(b))))
