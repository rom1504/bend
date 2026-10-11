#!/usr/bin/env python3
"""Count actual compiler20 and upstream native operations; never use these timings."""
import importlib.util,json,time,argparse
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def module(name,p):
 s=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
S=module('support',ROOT/'selfhost/tools/performance/programs/support.py');N=module('counts',ROOT/'selfhost/tools/performance/phase68/profiles/native-counts.py');O=module('oracle',ROOT/'selfhost/tools/performance/phase46/oracle.py')
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(exist_ok=False)
read=lambda p:json.loads(Path(p).read_text())
acqs=[read(ROOT/p) for p in ['selfhost/build/phase68/native-scalar20-rest/report.json','selfhost/build/phase67/native-baseline02/report.json','selfhost/build/phase67/native-heldout-baseline02/report.json']]
recipe=read(acqs[0]['recipe']['path']);catalog={c['name']:c for c in read(ROOT/'selfhost/tools/performance/phase46/cases.json')}
plan=[]
for name in ['tree','lexer','closures','map']:
 for role in ['selfhost','upstream']:
  rows=[r for acq in (acqs[:1] if role=='selfhost' else acqs[1:]) for r in acq['records'] if r['role']==role and r['case']==name];assert len(rows)==1
  row=rows[0];assert row['correct'];assert S.identity(row['nativeSource']['path'])==row['nativeSource']
  out=a.out/(name+'-'+role);d=N.derive(row['nativeSource']['path'],out)
  plan.append(dict(case=name,role=role,dir=str(out.resolve()),derivation=S.identity(out/'derivation.json'),source=d['output'],segments=d['segments']))
S.save(a.out/'plan.json',dict(producer=S.identity(__file__),recipe=acqs[0]['recipe'],jobs=plan))
report=dict(complete=False,diagnosticOnly=True,timingValid=False,plan=S.identity(a.out/'plan.json'),records=[])
try:
 with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
  for job in plan:
   out=Path(job['dir']);exe=out/'program';cmd=['taskset','-c','3',recipe['clang'],*recipe['clangArgs'],job['source']['path'],*recipe['linkArgs'],'-o',str(exe)]
   build=guard.run(cmd,out/'build',time.monotonic()+90);assert build['complete']
   runs=[]
   for n in [1,17]:
    dest=out/('run-'+str(n));proc=guard.run(['taskset','-c','3',str(exe),'--threads','1','--gpu','off','--',str(n),'0'],dest,time.monotonic()+30);assert proc['complete']
    words=(dest/'stdout.log').read_text().strip().splitlines();assert len(words)==4 and list(map(int,words[:3]))==[catalog[job['case']]['expected'],O.digest(O.points(catalog[job['case']]),0),O.digest(O.points(catalog[job['case']]),n)]
    counts=json.loads((dest/'stderr.log').read_text());runs.append(dict(repetitions=n,counts=counts,process=proc))
   report['records'].append(dict(job=job,executable=S.identity(exe),build=build,runs=runs));S.save(a.out/'report.json',report)
 report['complete']=True
finally:S.save(a.out/'report.json',report)
print(json.dumps(dict(complete=report['complete'],records=len(report['records']))))
