"""Independently authored source transfer controls; no compiler or timing runs."""
from pathlib import Path
import hashlib,json
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
source=ROOT/'selfhost/tools/bench/catalogs/native45/fixtures/scalar-region-8192.bend'
scaffold='# Phase93:'+source.read_text().split('# Phase93:',1)[1]
mask=(1<<32)-1
# Straight iterative oracle, deliberately no fixed-state shortcut or closed form.
def oracle(n,seed,converging):
 state=seed;increment=seed|1;counter=seed^0x9e3779b9
 for _ in range(n):
  counter=(counter+increment+(state&7))&mask
  state=(state>>1) if converging else ((state+1)&mask)
 return counter
cases=[]
for name,converging in [('converging',True),('cycling',False)]:
 expected=oracle(8192,305419896,converging)
 next_state='U32.shrn(state, 1n)' if converging else 'U32.inc(state)'
 body=f'''import Base
# Authored after the numeric compiler rule froze; no Mandelbrot helper reused.
def orbit(n: Nat, +state: U32, +increment: U32, counter: U32) -> U32:
  match n:
    case 0n: counter
    case 1n+p:
      next = {next_state}
      delta = U32.add(increment, U32.and(state, 7))
      orbit(p, next, increment, U32.add(counter, delta))

def bench(size: U32, +seed: U32) -> U32:
  orbit(U32.to_nat(size), seed, U32.or(seed, 1), U32.xor(seed, 2654435769))

'''
 tail=scaffold.replace('U32.is_eq(value, 8192)',f'U32.is_eq(value, {expected})').replace('524800','305419896')
 assert tail!=scaffold and tail.count(f'U32.is_eq(value, {expected})')==1
 (HERE/(name+'.bend')).write_text(body+tail);(HERE/(name+'.expected')).write_text(str(expected)+'\n')
 points=[[8192,305419896],[0,0],[1,0xffffffff],[33,1],[65,0x80000000],[1024,17]]
 cases.append({'id':'orbit-'+name,'source':name+'.bend','expectedFile':name+'.expected','point':[8192,305419896],'expected':expected,'oracle':[{'args':p,'expected':oracle(*p,converging)} for p in points],'prediction':'Fixed state reached after at most32 transitions; expect strong gain for8192, but measure C/native separately.' if converging else 'Every consecutive state differs including wraparound; no shortcut, possible guard overhead.'})
def pin(p):return dict(file=str(p.resolve()),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
r={'kind':'phase198-new-source-heldout-freeze','targetsRun':False,'cases':cases,'scaffold':pin(source),'method':pin(Path(__file__)),'sourcePins':[pin(HERE/c['source']) for c in cases],'partition':'New independently authored heldout cases, not members of native45. Source-level output oracles and physical emissions are distinct from IR rule controls.','before':'numeric-api03 checked escape-only, no stable-orbit rule','after':'numeric-api05 checked collision-free stable-orbit, pending','scope':'Fixed point versus cycling state; no zero seed specialization; unsigned modulo32 arithmetic throughout.'}
(HERE/'frozen.json').write_text(json.dumps(r,indent=2)+'\n')
(HERE/'partition.json').write_text(json.dumps({'development':[],'heldout':[x['id'] for x in cases]},indent=2)+'\n')
print([(c['id'],c['expected']) for c in cases])
