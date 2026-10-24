#!/usr/bin/env python3
"""Independent native writer bytes/errors and diagnostic timing, guarded externally."""
import argparse, hashlib, json, pathlib, statistics, subprocess, time
p=argparse.ArgumentParser();p.add_argument('--tiny',required=True,type=pathlib.Path);p.add_argument('--benchmark',type=pathlib.Path);p.add_argument('--out',required=True,type=pathlib.Path);a=p.parse_args()
def pin(f):
 f=f.resolve();b=f.read_bytes();return dict(file=str(f),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
assert not a.out.exists();a.out.mkdir(parents=True)
inputs=[pin(pathlib.Path(__file__)),pin(a.tiny)]+([pin(a.benchmark)]if a.benchmark else [])
r=dict(complete=False,inputs=inputs,controls=[],observations=[],scope='Isolated retained-runtime writer fixture. Diagnostic timings may overlap compiler acquisition; no compiler-speed or production-selection claim.')
def save():(a.out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
def run(binary,mode=None,stdout=subprocess.PIPE):
 cmd=[str(binary.resolve()),'--threads','1','--gpu','off']+(['--',str(mode)]if mode is not None else [])
 t=time.perf_counter();z=subprocess.run(cmd,stdout=stdout,stderr=subprocess.PIPE,timeout=20);return z,time.perf_counter()-t
save()
try:
 z,t=run(a.tiny);assert(z.returncode,z.stdout,z.stderr)==(0,b'one:two\n',b'');r['controls'].append(dict(name='pipe-exact-newline',passed=True))
 f=a.out/'append.stdout';f.write_bytes(b'preserve:')
 with f.open('ab') as out:z,t=run(a.tiny,stdout=out)
 assert z.returncode==0 and not z.stderr and f.read_bytes()==b'preserve:one:two\n';r['controls'].append(dict(name='append-preserves-prefix',passed=True,output=pin(f)))
 with open('/dev/full','wb',buffering=0) as out:z,t=run(a.tiny,stdout=out)
 assert z.returncode>0 and z.stderr and b'No space left on device' in z.stderr,(z.returncode,z.stderr)
 f=a.out/'dev-full.stderr';f.write_bytes(z.stderr);r['controls'].append(dict(name='native-dev-full-fails',passed=True,status=z.returncode,seconds=t,stderr=pin(f)));save()
 if a.benchmark:
  for mode in range(6):
   size,count=(1023,4096) if mode<3 else (8191,512);expected=(b'X'*size+b'\n')*count
   f=a.out/f'mode{mode}.stdout'
   with f.open('wb') as out:z,t=run(a.benchmark,mode,out)
   actual=f.read_bytes();assert z.returncode==0 and not z.stderr and actual==expected,(mode,z.returncode,len(actual),z.stderr)
   r['controls'].append(dict(name=f'mode{mode}-exact-4MiB',passed=True,output=pin(f),seconds=t,pieceChars=size,pieces=count));save()
  for round_ in range(3):
   for offset in range(6):
    mode=(offset+round_)%6
    with open('/dev/null','wb',buffering=0) as out:z,t=run(a.benchmark,mode,out)
    assert z.returncode==0 and not z.stderr
    r['observations'].append(dict(round=round_,mode=mode,seconds=t));save()
  r['medians']={str(m):statistics.median(x['seconds']for x in r['observations']if x['mode']==m)for m in range(6)}
 for x in inputs:assert pin(pathlib.Path(x['file']))==x
 r['complete']=True
except BaseException as e:r['error']=repr(e);raise
finally:save()
print(json.dumps(dict(complete=r['complete'],controls=len(r['controls']),medians=r.get('medians'))))
