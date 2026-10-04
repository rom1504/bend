#!/usr/bin/env python3
"""Separate CPU profiles and native operation counts; never timing evidence."""
import argparse, importlib.util, json, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
def module(name,file):
 spec=importlib.util.spec_from_file_location(name,file);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
s=module('support',ROOT/'selfhost/tools/performance/programs/support.py');o=module('oracle',HERE/'oracle.py')
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args()
a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
acquired=ROOT/'selfhost/build/phase46/batch03';plan=json.loads((ROOT/'selfhost/build/phase46/timing-plan01.json').read_text())
oracles={r['name']:r for r in json.loads((ROOT/'selfhost/build/phase46/oracles.json').read_text())['cases']}
node='/home/ai/.nvm/versions/node/v24.18.0/bin/node';lean=Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0')
records=[]
def save():s.save(a.out/'report.json',dict(diagnosticOnly=True,producer=s.identity(__file__),records=records))
def observe(dest,record,count,warm,case):
 if not record['complete']:return {'correct':False}
 words=(dest/'stdout.log').read_text().strip().splitlines()
 expected=[oracles[case]['base'],o.digest(oracles[case]['values'],warm),o.digest(oracles[case]['values'],count)]
 return dict(correct=len(words)==4 and all(w.isdecimal() for w in words) and list(map(int,words[:3]))==expected,expected=expected,stdout=words)
with s.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
 dest=a.out/'perf-capability';r=guard.run(['taskset','-c','3','perf','stat','-e','task-clock','--','true'],dest,time.monotonic()+10)
 records.append(dict(kind='perf-capability',process=r));save()
 for case in ['numeric','array']:
  for role in ['upstream','selfhost']:
   source=acquired/(case+'-'+role+'-js')/('program.cjs' if role=='upstream' else 'program.mjs')
   dest=a.out/(case+'-'+role+'-profile');count=plan[case]['repetitions']
   cmd=[node,'--max-old-space-size=1024','--cpu-prof','--cpu-prof-dir='+str(dest),'--cpu-prof-name=profile.cpuprofile',str(source),'--threads','1','--gpu','off','--',str(count),str(count)]
   r=guard.run(['taskset','-c','3',*cmd],dest,time.monotonic()+30)
   record=dict(kind='v8-cpu-profile',case=case,role=role,source=s.identity(source),process=r,**observe(dest,r,count,count,case))
   if (dest/'profile.cpuprofile').exists():
    profile=json.loads((dest/'profile.cpuprofile').read_text());total=sum(n.get('hitCount',0) for n in profile['nodes'])
    record['samples']=total;record['topFrames']=[dict(function=n['callFrame']['functionName'],url=n['callFrame']['url'],line=n['callFrame']['lineNumber']+1,hits=n.get('hitCount',0),fraction=n.get('hitCount',0)/max(1,total)) for n in sorted(profile['nodes'],key=lambda n:n.get('hitCount',0),reverse=True)[:20]]
   records.append(record);save();print(json.dumps({'kind':record['kind'],'case':case,'role':role,'correct':record['correct']}),flush=True)
 for case in ['numeric','array']:
  for role in ['upstream','selfhost']:
   source=acquired/(case+'-'+role+'-c')/'program.c';derived=a.out/(case+'-'+role+'-counts');dest=a.out/(case+'-'+role+'-derive')
   r=guard.run(['taskset','-c','3','python3',str(HERE/'native-counts.py'),str(source),str(derived)],dest,time.monotonic()+10)
   record=dict(kind='native-counts',case=case,role=role,derivation=r,runs=[])
   if r['complete']:
    dest=derived/'compile';cc=guard.run(['taskset','-c','3',str(lean/'bin/clang'),'-isystem',str(lean/'include/clang'),'-std=c11','-O3',str(derived/'program.c'),'-lpthread','-lm','-o',str(derived/'program')],dest,time.monotonic()+90)
    record['compile']=cc
    if cc['complete']:
     for count in [1,17]:
      dest=derived/('run'+str(count));cmd=[str(derived/'program'),'--threads','1','--gpu','off','--',str(count),'0']
      run=guard.run(['taskset','-c','3',*cmd],dest,time.monotonic()+20)
      item=dict(repetitions=count,process=run,**observe(dest,run,count,0,case))
      for line in (dest/'stderr.log').read_text().splitlines():
       if line.startswith('{"kind":"phase46-native-counts"'):item['counts']=json.loads(line)
      record['runs'].append(item)
   records.append(record);save();print(json.dumps({'kind':'native-counts','case':case,'role':role,'runs':len(record['runs']),'correct':all(r['correct'] for r in record['runs']) if record['runs'] else False}),flush=True)
