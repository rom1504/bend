"""Count calls per ordinary complete benchmark invocation by paired integer differences."""
from pathlib import Path
import argparse
import hashlib
import json
import importlib.util
import os
import subprocess
import sys
import time

HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'fusion'))
from screen import read,pin,checked_tool,BUILD,bench
spec=importlib.util.spec_from_file_location('physical_profiler',BUILD.parent/'tools/profiler/analyze.py')
prof=importlib.util.module_from_spec(spec);spec.loader.exec_module(prof)
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--cases',default='all');p.add_argument('--ownership',action='store_true');p.add_argument('--catalog-dir',type=Path,default=BUILD/'phase198/native45-01')
a=p.parse_args();assert os.sched_getaffinity(0)=={3}
out=a.out;out.mkdir(parents=True,exist_ok=False)
manifest=a.catalog_dir/'programs.manifest.json'
m=read(manifest);nc=BUILD/'phase194/assets.json'
asset=read(nc);cc=checked_tool(asset['assets']['linker'])
probe=HERE/('ownership.c' if a.ownership else 'operations.c');obj=out/'observer.o'
subprocess.run([cc,'-O2','-c',probe,'-o',obj],capture_output=True,check=True,timeout=15)
symbols=['p111_rt_op',*[f'p125_rt_{name}{i}' for name in ['ctor','take'] for i in range(1,5)]]
if a.ownership:symbols=['p111_rt_keep','p111_rt_sink','p118_rt_borrow_fields','p118_rt_borrow_scalar_safe']
r={'complete':False,'symbols':symbols,'scope':'Generated-object calls to external ABI only. Exact integer deltas between repetitions 2 and 1; independent repeat verifies linearity. 0 reps separately observes setup and first result. Loader/runtime-internal calls and inlined work excluded; these are operation counts, not cycle or latency samples.',
   'inputs':[pin(p) for p in [manifest,probe,__file__,obj,nc]],'cases':[]}
def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
for c in m['cases']:
    if a.cases!='all' and c['id'] not in a.cases.split(','):continue
    role=c['products']['candidate'];q=read(a.catalog_dir/c['id']/'machine/report.json');assert q['complete']
    exe=(out/c['id']).resolve();cmd=next(j['command'][:] for j in q['jobs'] if j['label']=='link')
    cmd[cmd.index(role['artifact']['file'])]=str(exe)
    cmd[1:1]=[*['-Wl,--wrap='+s for s in symbols],str(obj)]
    checked_tool(role['generatedSource'])
    subprocess.run(cmd,check=True,capture_output=True,timeout=15)
    point=c['point'];rows=[]
    for reps in [0,1,2]:
        cmd=[str(exe),*bench.native_runtime_arguments(role),str(reps),'0',*map(str,point['runtimeArgs'])]
        t=time.monotonic();p1=subprocess.run(cmd,capture_output=True,timeout=12)
        counts={};left=[]
        for line in p1.stderr.splitlines(keepends=True):
            if line.startswith(b'P198 '):
                words=line.decode().split()
                key=' '.join(words[1:-1]);assert key not in counts
                counts[key]=int(words[-1])
            else:left.append(line)
        bench.observation(p1.stdout,b''.join(left),p1.returncode,dict(expectedStdout=point['expectedStdout'],repetitions=reps,warmups=0),time.monotonic()-t)
        rows.append(counts)
    assert all('lost' not in z for z in rows)
    if not a.ownership:
        _,symbol_index=prof.load_object(exe)
    site_names={}
    for k in set().union(*rows):
        if k.startswith('site '):
            _,op,pc=k.split()
            found=symbol_index.resolve(int(pc,16)-1)
            site_names[k]=prof.decode_name(found['name'])+'+'+hex(found['offset']) if found else 'unresolved'
    for z in rows:
        for k,count in z.items():
            if k.startswith('op '):
                assert sum(v for s,v in z.items() if s.startswith('site '+k.split()[1]+' '))==count
    keys=set().union(*rows)
    first={k:rows[1].get(k,0)-rows[0].get(k,0) for k in keys}
    second={k:rows[2].get(k,0)-rows[1].get(k,0) for k in keys}
    # Printing larger timing/status digits can add a small amount of formatting work.
    # Preserve both exact integer observations; never silently discard a mismatch.
    row={'id':c['id'],'source':c['source'],'object':role['generatedSource'],'observerBinary':pin(exe),'initial':rows[0],
         'siteNames':site_names,'first':{k:v for k,v in sorted(first.items()) if v},'second':{k:v for k,v in sorted(second.items()) if v},'stable':first==second}
    r['cases'].append(row);save()
r['complete']=True;save();print('cases',len(r['cases']),'exact-delta-pairs',sum(c['stable'] for c in r['cases']))
