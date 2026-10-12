#!/usr/bin/env python3
"""Recheck retained selected controls at threads1/4, including admission shape."""
import argparse,importlib.util,json,time,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
s=importlib.util.spec_from_file_location('support',ROOT/'selfhost/tools/performance/programs/support.py');S=importlib.util.module_from_spec(s);s.loader.exec_module(S)
p=argparse.ArgumentParser();p.add_argument('--gate',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(exist_ok=False)
plan=json.loads((a.gate/'plan.json').read_text());gate=a.gate/'execution/selected/candidate.json';d=json.loads(gate.read_text());assert d['selectedComplete'] and d['summary']['statuses']=={'pass':12}
gold={r['id']:r for r in plan['fixtureGoldens']};report=dict(complete=False,inputs=[S.identity(__file__),S.identity(gate),S.identity(a.gate/'plan.json')],records=[],shapes=[])
with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as g:
 for row in d['results']:
  assert row['status']=='pass' and row['result']['checked'];name=Path(gold[row['id']]['source']['file']).stem;folder=Path(row['artifacts']);source=folder/(name+'.c');exe=folder/name;expected='\n'.join(gold[row['id']]['goldenLines'])+'\n'
  assert S.identity(gold[row['id']]['source']['file'])['sha256']==gold[row['id']]['source']['sha256']
  pins=[S.identity(source),S.identity(exe)];report['inputs']+=pins
  if name in ['escape','reconstruction','sharing','sharing-parallel','shared-tail','mixed-roots']:
   cold=re.findall(r'^#undef NATIVE_HOT_(\w+)',source.read_text(),re.M);want=0 if name in ['escape','reconstruction'] else 2;assert len(cold)==want,(name,cold);report['shapes'].append(dict(case=row['id'],coldConstructors=cold,expectedCount=want))
  for threads in [1,4]:
   out=a.out/(name+'-'+str(threads));proc=g.run(['taskset','-c','3' if threads==1 else '0-3',str(exe),'--threads',str(threads),'--gpu','off'],out,time.monotonic()+45)
   text=(out/'stdout.log').read_text();err=(out/'stderr.log').read_text();ok=proc['complete'] and proc['returncode']==0 and text==expected and not err
   report['records'].append(dict(case=row['id'],threads=threads,process=proc,expected=expected,observed=text,stderr=err,passCheck=ok));S.save(a.out/'report.json',report);assert ok,(name,threads,text,err)
for pin in report['inputs']:assert S.identity(pin['path'])==pin
report['complete']=True;S.save(a.out/'report.json',report);print(json.dumps(dict(complete=True,executions=len(report['records']),shapes=len(report['shapes']))))
