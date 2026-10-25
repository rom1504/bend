"""Read emitted QBE and disassemble only the measured comparison paths."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

p=argparse.ArgumentParser(description=__doc__)
for name in ['qbe','binary','out']:p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();assert not a.out.exists();a.out.mkdir(parents=True)
def pin(f):
 f=Path(f).resolve();b=f.read_bytes();return dict(file=str(f),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def dec(n):return re.sub(r'FID_((?:\d+_)+)',lambda m:''.join(chr(int(x))for x in m[1].split('_')if x),n)
s=a.qbe.read_text();hits=list(re.finditer(r'^(?:export )?function .*\$([^ (]+)\(',s,re.M));functions={}
for i,h in enumerate(hits):
 body=s[h.start():hits[i+1].start()if i+1<len(hits)else len(s)].split('\n}\n')[0]+'\n}\n'
 functions[dec(h[1])]=(h[1],body)
table=re.search(r'data \$p111_segments[^\n]*\{([^}]+)\}',s)[1]
segments=[dec(n)for n in re.findall(r'l \$([^ ,]+)',table)]
names=['p111_$direct.p141b_compare','p111_$direct.p140e_args','p111_$direct.p141st_list~0',
 'p111_$direct.p134v_list','p114r_$direct.p140e_args','p114r_$direct.p141st_list~0']
report=dict(kind='phase141-static-traversal-machine-audit',complete=False,
 inputs=[pin(__file__),pin(a.qbe),pin(a.binary),pin(shutil.which('objdump'))],functions=[])
for i,name in enumerate(names):
 symbol,body=functions[name];(a.out/f'{i}.ssa').write_text(body)
 dis=subprocess.check_output(['objdump','-d','--no-show-raw-insn','--disassemble='+symbol,str(a.binary)],text=True)
 (a.out/f'{i}.asm').write_text(dis)
 instructions=re.findall(r'^\s*[0-9a-f]+:\s+(.*)',dis,re.M)
 jumps=[int(x)for x in re.findall(r'call \$p111_rt_jump\(l %state, w (\d+)',body)]
 row=dict(name=name,symbol=symbol,qbeLines=len(body.splitlines()),qbe=pin(a.out/f'{i}.ssa'),assembly=pin(a.out/f'{i}.asm'),
  instructionCount=len(instructions),directCalls=[dec(x)for x in re.findall(r'call \$([^ (]+)',body)],
  indirectCalls=re.findall(r'call (%[^ (]+)',body),dispatchTargets=[dict(id=n,name=segments[n])for n in jumps])
 report['functions'].append(row)
fast=report['functions'][-2:]
assert fast[0]['directCalls']==fast[1]['directCalls']
assert 'p111_rt_apply' not in fast[0]['directCalls'] and 'p111_rt_apply' not in fast[1]['directCalls']
assert 'p111_rt_apply' in report['functions'][3]['directCalls']
report['scope']='Static reachability through actual entry dispatch and wrappers, not dynamic profile counts. Different temporaries and continuation IDs remain. Equal instruction count is not by itself a runtime proof.'
report['complete']=True
(a.out/'method.py').write_bytes(Path(__file__).read_bytes())
(a.out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps([dict(name=x['name'],instructions=x['instructionCount'],dispatch=x['dispatchTargets'])for x in report['functions']]))
