#!/usr/bin/env python3
"""Read symbols and disassemble only selected existing lookup/consumer workers."""
import collections
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
build = ROOT/'selfhost/build/phase166/lookup-products02'
report = json.loads((build/'report.json').read_text())
owners = {'lookup','index_find','index_bucket','index_hash','p88_string_eq_go',
          'p88_string_eq','p163r_scan','p166l_go','p166l_continue'}


def decode(name):
    return re.sub(r'(?<=FID_)(?:[0-9]+_)+',lambda m:''.join(chr(int(x)) for x in m.group().strip('_').split('_')),name)


result = {'kind':'phase166-static-machine-shapes','targetsRun':False,'inputs':report['binaries'],
          'methodSha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'roles':{},
          'scope':'Selected actual symbol bodies only. Sizes/instructions/calls are static, not inclusive work or dynamic time; split public/borrowed/owned bodies are not comparable as single total costs.'}
for role, pin in report['binaries'].items():
    exe=Path(pin['file']);assert hashlib.sha256(exe.read_bytes()).hexdigest()==pin['sha256']
    symbols=[]
    for line in subprocess.check_output(['nm','-S','--defined-only',str(exe)],text=True).splitlines():
        fields=line.split()
        if len(fields)!=4 or fields[2].lower()!='t':continue
        name=fields[3];human=decode(name)
        owner=human.split('FID_',1)[-1].split('.')[-1]
        if role=='bendc':
            wanted=name in {prefix+x.replace('_','__') for x in owners for prefix in ('F_','H_F_')}
        elif role=='qbe':wanted=name.startswith('p113d_') and owner in owners
        else:wanted=owner in owners and (name.startswith('NF_') or owner in {'index_hash','p88_string_eq_go','p166l_go','p166l_continue'})
        if wanted:symbols.append((name,human,int(fields[1],16)))
    rows=[]
    for name,human,size in symbols:
        asm=subprocess.check_output(['objdump','-d','--no-show-raw-insn','--disassemble='+name,str(exe)],text=True)
        instructions=[];calls=collections.Counter();frames=[]
        for line in asm.splitlines():
            m=re.match(r'\s*[0-9a-f]+:\s+([a-z][a-z0-9]*)\s*(.*)',line)
            if not m:continue
            op,args=m.groups();instructions.append((op,args))
            if op in ('call','callq'):
                target=re.search(r'<([^>]+)>',args);calls[decode(target.group(1)) if target else 'INDIRECT:'+args]+=1
            if op=='sub' and args.endswith(',%rsp'):frames.append(args)
        rows.append({'symbol':name,'decoded':human,'bytes':size,'instructions':len(instructions),
                     'callSites':dict(calls),'stackSubtractions':frames,
                     'conditionalBranches':sum(op.startswith('j') and op!='jmp' for op,_ in instructions)})
    result['roles'][role]=rows
out=ROOT/'experiments/phase166/code-shapes.json';assert not out.exists()
out.write_text(json.dumps(result,indent=2)+'\n')
for role,rows in result['roles'].items():
    for r in rows:print(role,r['decoded'],r['bytes'],r['instructions'],r['stackSubtractions'],sum(r['callSites'].values()))
