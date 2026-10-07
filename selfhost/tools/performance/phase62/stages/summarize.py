#!/usr/bin/env python3
"""Read diagnostic stage receipts only; emit disjoint request partitions and CSV."""
import argparse,csv,hashlib,json,statistics
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('report',type=Path);p.add_argument('out',type=Path)
a=p.parse_args();assert not a.out.exists();r=json.loads(a.report.read_text())
assert r['complete'] and r['pass'] and r['mode']=='stages'
def identity(path):return dict(file=str(path.resolve()),sha256=hashlib.sha256(path.read_bytes()).hexdigest())
def group(name,role):
 if role=='typescript':return {'typescript.book-load':'load','typescript.book-valid':'check','typescript.js-lib':'backend'}.get(name,'request-other')
 if name.startswith(('driver.cache-','driver.base-','driver.checked-state-','driver.fresh-state-')) or name in ['driver.json-tree-validation','driver.prepare-base']:return 'cache'
 if name in ['driver.source-graph','driver.span-validation'] or name.startswith(('compiler.source-','compiler.prefix-')) and name!='compiler.source-reach':return 'load'
 if name=='compiler.check-and-complete':return 'check'
 if name.startswith('compiler.') or name in ['driver.foreign-source','driver.foreign-resolver','driver.output-assembly']:return 'backend'
 return 'request-other'
rows=[];flat=[]
for row in r['rows']:
 assert row['success'];o=row['observation'];assert not o['cleanTiming'] and o['stages']['incomplete']==0
 assert identity(Path(row['result']['file']))==row['result']
 assert json.loads(Path(row['result']['file']).read_text())==o
 events=o['stages']['events'];index={x['id']:x for x in events}
 first=next(x for x in events if x['name']=='worker.first-window');compile=next(x for x in events if x['name']=='worker.compile')
 assert first['parent'] is None
 def inside(event,parent):
  while event['id']!=parent and event['parent'] is not None:event=index[event['parent']]
  return event['id']==parent
 request=[x for x in events if inside(x,compile['id'])]
 assert abs(sum(x['exclusiveMs'] for x in events)-first['inclusiveMs'])<1e-5
 assert abs(sum(x['exclusiveMs'] for x in request)-compile['inclusiveMs'])<1e-5
 groups={key:0.0 for key in ['cache','load','check','backend','request-other']};stages={}
 for event in request:
  groups[group(event['name'],row['role'])]+=event['exclusiveMs']
  stages[event['name']]=stages.get(event['name'],0)+event['exclusiveMs']
 record=dict(case=row['case'],role=row['role'],sample=row['sample'],combinedFirstMs=o['importApiAndFirstMs'],
  firstRequestMs=o['firstRequestMs'],clockCompileMs=compile['inclusiveMs'],clockWindowMs=first['inclusiveMs'],
  groupsExclusiveMs=groups,stagesExclusiveMs=stages,output=o['output'],result=row['result'])
 rows.append(record)
 for key,value in groups.items():flat.append(dict(case=row['case'],role=row['role'],sample=row['sample'],group=key,exclusiveMs=value))
summary=dict(kind='phase62-disjoint-stage-summary',complete=True,diagnosticOnly=True,input=identity(a.report),producer=identity(Path(__file__)),rows=rows,
 scope='Exclusive stage wall times include instrumentation overhead and GC/scheduling within each interval. This is not a clean latency result. TS load/check/backend boundaries are book_load/book_valid/js_lib; Bend has cached Base and distinct passes. Compare combined frontend+checking or full backend cautiously; inner stage names are not equivalent algorithms. Startup is outside worker.compile; repeated driver.api-load inside a request remains request-other. No statistically isolated per-stage speed attribution.')
summary['pass']=True
a.out.mkdir(parents=True);(a.out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
with (a.out/'groups.csv').open('x',newline='') as f:
 w=csv.DictWriter(f,fieldnames=['case','role','sample','group','exclusiveMs']);w.writeheader();w.writerows(flat)
print(json.dumps(dict(rows=len(rows),output=str(a.out/'summary.json'))))
