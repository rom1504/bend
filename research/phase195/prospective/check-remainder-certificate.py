#!/usr/bin/env python3
"""Independent Python % oracle for the bounded-U32 Bend prototype, no compiler."""
import json,random,pathlib,os,hashlib
os.sched_setaffinity(0,{0});M=2**32-1

def magic(d):
 if d<=1 or d>M:return None
 q,r=divmod(M,d)
 if r==d-1:q,r=q+1,0
 else:r+=1
 power,k=1,32
 while True:
  assert q==(1<<k)//d and r==(1<<k)%d
  if r==0:return q,k
  if q==M:return None
  if d-r<=power:return q+1,k
  if not(k<63 and q<=2147483647):return None
  power,k=power*2,k+1
  if r>=d-r:q,r=2*q+1,r-(d-r)
  else:q,r=2*q,2*r
  assert max(q,r,power)<=M

def execute(n,d,c):
 m,k=c
 # Five typed integer IR operations emitted by x195rem_expand.
 name=n&M
 name=(name*m)&(2**64-1)
 name>>=k
 name=((name&M)*d)&M
 return ((n&M)-name)&M

rng=random.Random(195261);checks=0;admitted=0;refused=0
D=list(range(257))+[2**k+off for k in range(8,32) for off in (-1,0,1)]+[M-1,M]+[rng.randrange(2,M+1) for _ in range(2048)]
for d in D:
 c=magic(d)
 if c is None:refused+=1;continue
 admitted+=1;m,k=c
 assert 0<m<=M
 assert 0<=m*d-(1<<k)<=1<<(k-32)
 points={0,1,d-1,d,d+1,M,M-1,2**31,2**31-1}
 for q in [0,1,2,M//d,max(0,M//d-1)]+[rng.randrange(M//d+1) for _ in range(20)]:
  points|={q*d+off for off in [-1,0,1,d-1]}
 points|={rng.getrandbits(32) for _ in range(64)}
 for n in points:
  if n<0 or n>M:continue
  assert execute(n,d,c)==n%d,(n,d,c)
  raw=n+(rng.getrandbits(32)<<32)
  assert execute(raw,d,c)==n%d,(raw,d,c)
  checks+=2
assert magic(0) is None and magic(1) is None and magic(7) is None
assert magic(6)==(2863311531,34) and magic(10)==(3435973837,35) and magic(26)==(1321528399,35)
p=pathlib.Path(__file__).resolve().parent
report={'passed':True,'seed':195261,'oracle':'Python integer modulo; exact low32 semantic results for nonzero divisors','checks':checks,'divisorTrials':len(D),'admitted':admitted,'refused':refused,'zeroOneSevenRefused':True,'prototypeSha256':hashlib.sha256((p/'constant-remainder.bend').read_bytes()).hexdigest(),'status':'Arithmetic-only prototype simulator; Bend source/emitted machine/ABI integration untested.','targetRuns':0,'compilerRuns':0}
(p/'certificate-check.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
