#!/usr/bin/env python3
"""Rebind frozen worker objects to an independent harness without recompiling workers."""
import argparse,importlib.util,json,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4];HERE=ROOT/'selfhost/tools/performance/phase110'
s=importlib.util.spec_from_file_location('p108',HERE.parent/'phase108/run.py');R=importlib.util.module_from_spec(s);s.loader.exec_module(R)
p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--harness',type=Path,required=True);p.add_argument('--selection',type=Path);p.add_argument('--workers',nargs='+');p.add_argument('--out',type=Path,required=True);a=p.parse_args();build=a.build.resolve();harness=a.harness.resolve();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase110') and not out.exists();old=json.loads((build/'report.json').read_text());assert old['complete'];out.mkdir(parents=True)
selection=json.loads(a.selection.read_text()) if a.selection else None
if selection:assert selection['complete'] and selection['selectionFrozen']
names={selection['reference'],selection['globalWinner'],selection['qbeWinner']} if selection else set(a.workers or [w['name'] for w in old['workers']]);workers=[w for w in old['workers'] if w['name'] in names];assert len(workers)==len(names)
inputs=[R.pin(Path(__file__)),R.pin(build/'report.json'),R.pin(build/'runtime.o'),*[R.pin(harness/n) for n in ['manifest.json','harness.c','cases.inc.c','abi.h','expected.jsonl']],*[w['object'] for w in workers]]
if a.selection:inputs.append(R.pin(a.selection))
r=dict(kind='phase110-frozen-worker-relink',complete=False,variant=old['variant'],inputs=inputs,workers=[],semantics={},jobs=[]);save=lambda:R.save(out/'report.json',r);save()
def run(label,args):
 t=time.monotonic();row=dict(label=label,command=list(map(str,args)));r['jobs'].append(row);save()
 with (out/(label+'.stdout')).open('xb') as so,(out/(label+'.stderr')).open('xb') as se:c=R.P.run(row['command'],cwd=ROOT,stdout=so,stderr=se,timeout=60)
 row.update(seconds=time.monotonic()-t,status=c.returncode);save()
 if c.returncode:raise ValueError(label+' failed')
try:
 for f in inputs:R.N.verify(f)
 (out/'method.py').write_bytes(Path(__file__).read_bytes());run('harness',['gcc','-O2','-std=gnu11','-c',harness/'harness.c','-o',out/'harness.o'])
 for w in workers:
  name=w['name'];binary=out/name;run(name+'-link',['gcc','-no-pie',w['object']['file'],build/'runtime.o',out/'harness.o','-pthread','-lm','-o',binary]);run(name+'-controls',[binary])
  actual=(out/(name+'-controls.stdout')).read_bytes();assert actual==(harness/'expected.jsonl').read_bytes(),name+' independent oracle differs'
  r['workers'].append({**w,'binary':R.pin(binary)});r['semantics'][name]=dict(exact=True,cases=len(actual.splitlines()));save()
 for f in inputs:R.N.verify(f)
 r['complete']=True;save();print(json.dumps(dict(complete=True,workers=len(workers),cases=len(actual.splitlines()))))
except BaseException as e:r['error']=repr(e);save();raise
