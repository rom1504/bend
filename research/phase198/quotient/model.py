"""Model known-divisor replacement exposure on this host's recorded Ivy Bridge model."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import time

p=argparse.ArgumentParser()
p.add_argument('--out',required=True,type=Path)
a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
root=Path(__file__).resolve().parents[3]
def pin(p):
    p=Path(p).resolve()
    return {'file':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
tool=json.loads((root/'selfhost/build/phase195/hardware-tool01/acquisition.json').read_text())
for obj in [tool['tool'],*tool['libraries']]: assert pin(obj['file'])['sha256']==obj['sha256']
r={'complete':False,'model':'ivybridge','tool':tool['tool'],'traceSource':pin(root/'research/phase195/profiles/remaining-machine/lexer-remainder.asm'),
   'method':pin(__file__),'scope':'Straight-line loop-carried input/remainder. Existing runtime arity, dispatch and memory traffic are excluded from the DIV baseline. Immediates in this arithmetic witness represent a prospective selector. No claim about the emitted native worker or whole elapsed runtime.','cases':[]}
for d in (3,5,6,10,26):
    for s in range(d.bit_length()):
        m=((1<<(32+s))+d-1)//d
        if m<2**32 and m*d-(1<<(32+s))<=1<<s:break
    else:raise AssertionError(d)
    for role,lines in [('hardware-divide',['movl %r12d, %eax','xorl %edx, %edx','divl %ecx','movl %edx, %r12d']),
            ('multiply-and-shift',['movl %r12d, %eax',f'movl ${m}, %edx','imulq %rax, %rdx',f'shrq ${32+s}, %rdx',
                                  f'imull ${d}, %edx, %edx','subl %edx, %eax','movl %eax, %r12d'])]:
        asm=a.out/f'{d}-{role}.s';asm.write_text('.text\n'+'\n'.join(lines)+'\n')
        cmd=[tool['tool']['file'],'-mtriple=x86_64-unknown-linux-gnu','-mcpu=ivybridge','-iterations=100',str(asm)]
        t=time.monotonic();result=subprocess.run(cmd,capture_output=True,text=True,check=True,timeout=3)
        stdout=a.out/f'{d}-{role}.stdout';stdout.write_text(result.stdout)
        metrics={}
        for line in result.stdout.splitlines():
            if ':' in line and line.split(':',1)[0] in ['Total Cycles','Total uOps','Block RThroughput']:
                k,v=line.split(':',1);metrics[k]=float(v)
        assert len(metrics)==3
        r['cases'].append({'divisor':d,'role':role,'m':m,'s':s,'metrics':metrics,'seconds':time.monotonic()-t,
                           'assembly':pin(asm),'output':pin(stdout)})
r['complete']=True;(a.out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
print([(x['divisor'],x['role'],x['metrics']) for x in r['cases']])
