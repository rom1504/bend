#!/usr/bin/env python3
"""Actual ABI operator obligations; guard this serial controller externally."""
import argparse,importlib.util,json,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4];HERE=ROOT/'selfhost/tools/performance/phase110'
s=importlib.util.spec_from_file_location('p108',HERE.parent/'phase108/run.py');R=importlib.util.module_from_spec(s);s.loader.exec_module(R)
p=argparse.ArgumentParser();p.add_argument('--runtime',required=True,type=Path);p.add_argument('--out',required=True,type=Path);p.add_argument('--take-pair',action='store_true');a=p.parse_args();out=a.out.resolve();runtime=a.runtime.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase110') and not out.exists();out.mkdir(parents=True)
files=[Path(__file__),*[runtime/n for n in ['runtime.c','abi.h','abi-extension.h','manifest.json']],HERE/'runtime/contract-controls.c'];
if a.take_pair:files.append(HERE/'runtime/take-controls.c')
r=dict(kind='phase110-runtime-contracts',complete=False,inputs=[R.pin(f) for f in files],jobs=[]);save=lambda:R.save(out/'report.json',r)
def run(name,args,expected=None):
 row=dict(name=name,command=list(map(str,args)));r['jobs'].append(row);save();t=time.monotonic()
 with (out/(name+'.stdout')).open('xb') as so,(out/(name+'.stderr')).open('xb') as se:c=R.P.run(row['command'],stdout=so,stderr=se,cwd=ROOT,timeout=30)
 row.update(seconds=time.monotonic()-t,status=c.returncode);save()
 if c.returncode or (expected is not None and (out/(name+'.stdout')).read_text()!=expected):raise ValueError(name+' failed')
try:
 for f in r['inputs']:R.N.verify(f)
 run('runtime',['gcc','-O2','-std=gnu11','-c',runtime/'runtime.c','-o',out/'runtime.o'])
 for kind,source in [('rebuild','contract-controls.c')]+([('take','take-controls.c')] if a.take_pair else []):
  (out/source).write_bytes((HERE/'runtime'/source).read_bytes())
  run('build-'+kind,['gcc','-O2','-I',runtime,out/source,out/'runtime.o','-pthread','-lm','-o',out/kind])
  if kind=='rebuild':
   for mode in ['specialized','pair']:
    for layout in ['c1-k0','c1-k1','c3-k0']:
     for ownership in ['unique','shared','static']:run('-'.join([mode,layout,ownership]),[out/kind,mode,layout,ownership],'rebuild-v2:ok\n')
  else:
   for layout in ['list','string']:
    for ownership in ['unique','shared','static']:run('-'.join([kind,layout,ownership]),[out/kind,layout,ownership],'take-v3:ok\n')
 for f in r['inputs']:R.N.verify(f)
 r['complete']=True;save();print(json.dumps(dict(complete=True,jobs=len(r['jobs']))))
except BaseException as e:r['error']=repr(e);save();raise
