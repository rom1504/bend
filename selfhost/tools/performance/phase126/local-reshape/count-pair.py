"""Root-only paired work counts; unchanged frozen output oracle, no timing claim."""
import argparse
import importlib.util
import os
from pathlib import Path
import json
import subprocess
import time

ROOT=Path(__file__).resolve().parents[5]
ORACLE=ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py'
spec=importlib.util.spec_from_file_location('oracle',ORACLE);O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--counts',type=Path,required=True)
p.add_argument('--parent',type=Path,default=ROOT/'selfhost/build/phase118/p126-combined17-emit/report.json')
p.add_argument('--candidate',type=Path,default=ROOT/'selfhost/build/phase118/p126-reshape24-emit/report.json')
p.add_argument('--out',type=Path,required=True)
a=p.parse_args()
assert sorted(os.sched_getaffinity(0))==[3], 'Root serial CPU3 lane required'
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase126')
counts=O.read(a.counts);assert counts['diagnosticOnly'] and counts['exactInverseVerified'] and not counts['compiled']
manifest_file=ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
manifest=O.read(manifest_file);case=next(c for c in manifest['cases'] if c['name']=='tree-bitonic')
assert case['runtimeArgs']==[8,0];case=dict(case,repetitions=1,warmups=0)
builder=ROOT/'selfhost/tools/performance/phase123/build-aligned.py'
inputs=[O.pin(__file__),O.pin(ORACLE),O.pin(manifest_file),O.pin(builder),O.pin(a.counts),*counts['inputs'],*counts['outputs']]
products=[]
for role,file in [('parent',a.parent),('candidate',a.candidate)]:
 emission=O.read(file);assert emission['complete']
 row=next(c for c in emission['cases'] if c['name']=='tree-bitonic');assert row['verified'] and row['parentVerified']
 assert row['source']==case['source'];O.verify(row['qbe']);O.verify(row['source'])
 inputs.extend([O.pin(file),*emission['inputs'],row['qbe'],row['source']]);products.append((role,row))
for item in inputs:O.verify(item)
out.mkdir(parents=True)
report=dict(kind='phase126-paired-reshape-work-counts',complete=False,diagnosticOnly=True,inputs=inputs,builds=[],rows=[],scope='Exactly one repetition, zero warmups, depth8 seed0. Same counter runtime object and aligned build policy for both frozen QBE sources. Elapsed output checked only by original oracle; no timing or qualification claim.')
save=lambda:O.save(out/'report.json',report);save()
def command(label,args,timeout):
 start=time.monotonic();child=subprocess.run(args,capture_output=True,timeout=timeout)
 so=out/(label+'.stdout');se=out/(label+'.stderr');so.write_bytes(child.stdout);se.write_bytes(child.stderr)
 row=dict(label=label,command=args,status=child.returncode,wallSeconds=time.monotonic()-start,stdout=O.pin(so),stderr=O.pin(se));report['builds'].append(row);save();assert child.returncode==0,(label,child.stderr.decode(errors='replace'))
 return child,row

def value(v):
 assert isinstance(v,int) and not isinstance(v,bool) and 0<=v<2**64
 return v

def validate(record):
 assert record['version']==1 and record['normalReturn'] is True and record['status']==0 and record['overflowOrInvalid']==0
 assert record['parentSourceSha256']==counts['parent']['sha256']
 for name in counts['counters']:value(record[name])
 assert record['reshape_attempts']==record['reshape_successes']+record['reshape_refused_tag']+record['reshape_refused_rfc']+record['reshape_refused_static_or_same']
 assert record['reused_shells']==2*record['reshape_successes']
 ids={};names=set()
 for row in record['constructors']:
  cid=value(row['cid']);assert cid<65536 and cid not in ids and isinstance(row['name'],str) and row['name'] not in names
  for field in ['allocated','takes','reusedShells']:value(row[field])
  assert row['reusedShells']%2==0;ids[cid]=row;names.add(row['name'])
 assert sum(x['allocated'] for x in ids.values())==record['constructor_cells']
 assert sum(x['takes'] for x in ids.values())==record['ctr_take_calls']
 assert sum(x['reusedShells'] for x in ids.values())==record['reused_shells']
 return ids
try:
 runtime_command=counts['command'];assert len(runtime_command)==8 and runtime_command[1:5]==['-O2','-std=gnu11','-ffp-contract=off','-c']
 assert runtime_command[5]==counts['source']['file'] and runtime_command[6]=='-o'
 runtime=Path(runtime_command[7]);assert runtime.parent==Path(counts['source']['file']).parent and not runtime.exists()
 command('runtime-build',runtime_command,45);runtime_pin=O.pin(runtime);report['runtime']=runtime_pin;inputs.append(runtime_pin);save()
 parsed={}
 for role,item in products:
  dest=ROOT/'selfhost/build/phase111'/('p126-'+out.name+'-'+role+'-tree-build')
  cmd=['python3','-B',str(builder),'--source',item['qbe']['file'],'--runtime',str(runtime),'--out',str(dest),'--seconds','30']
  command(role+'-build',cmd,55);built=O.read(dest/'report.json');assert built['complete']
  for x in built['inputs']:O.verify(x)
  assert runtime_pin in built['inputs'];O.verify(built['binary']);inputs.extend([O.pin(dest/'report.json'),built['binary'],*built['inputs']]);save()
  cmd=[built['binary']['file'],'--threads','1','--gpu','off','--','1','0','8','0']
  start=time.monotonic();child=subprocess.run(cmd,capture_output=True,timeout=30);wall=time.monotonic()-start
  so=out/(role+'.stdout');se=out/(role+'.stderr');so.write_bytes(child.stdout);se.write_bytes(child.stderr)
  row=dict(role=role,command=cmd,binary=built['binary'],qbe=item['qbe'],runtime=runtime_pin,status=child.returncode,stdout=O.pin(so),stderr=O.pin(se),correct=False);report['rows'].append(row);save()
  lines=child.stderr.splitlines(keepends=True);diagnostics=[line for line in lines if line.startswith(b'P126_RESHAPE_COUNTS ')]
  assert len(diagnostics)==1 and diagnostics[0].endswith(b'\n')
  remaining=b''.join(line for line in lines if line is not diagnostics[0])
  # Remove only the one exact diagnostic record; every other stderr byte goes
  # unchanged to the original frozen complete-output/status/count oracle.
  elapsed=O.observation(child.stdout,remaining,child.returncode,case,wall)
  record=json.loads(diagnostics[0][len(b'P126_RESHAPE_COUNTS '):]);ids=validate(record)
  row.update(correct=True,counts=record,oracleElapsedSuffixValidated=True);parsed[role]=(record,ids);save()
 parent,pids=parsed['parent'];candidate,cids=parsed['candidate']
 assert parent['reshape_attempts']==0 and candidate['reshape_attempts']>0
 deltas=[]
 for cid in sorted(pids.keys()|cids.keys()):
  left=pids.get(cid);right=cids.get(cid)
  if left and right:assert left['name']==right['name'],'CID/name mismatch'
  name=(left or right)['name'];left=left or dict(allocated=0,takes=0,reusedShells=0);right=right or dict(allocated=0,takes=0,reusedShells=0)
  deltas.append(dict(cid=cid,name=name,constructorCellsRemoved=left['allocated']-right['allocated'],takesRemoved=left['takes']-right['takes'],candidateReusedShells=right['reusedShells']))
 summary={name:parent[name]-candidate[name] for name in ['heap_alloc_calls','constructor_cells','ctr_take_calls','ctr_take_fields','ctr_take_wrapped_calls']}
 expected=2*candidate['reshape_successes'];summary.update(expectedConstructorCellsRemoved=expected,expectedTakesRemoved=expected,rawSuccessRate=candidate['reshape_successes']/candidate['reshape_attempts'],byConstructor=deltas)
 report['comparison']=summary;save()
 assert summary['constructor_cells']==expected and summary['ctr_take_calls']==expected,'Unexpected work delta; inspect retained diagnostic evidence'
 for row in deltas:
  assert row['constructorCellsRemoved']==row['candidateReusedShells'] and row['takesRemoved']==row['candidateReusedShells'],'Per-constructor work delta differs from exact local equation'
 for item in inputs:O.verify(item)
 report['complete']=True
except Exception as error:
 report['error']=str(error)
finally:
 save();print(json.dumps(dict(complete=report['complete'],error=report.get('error'),comparison=report.get('comparison'))))
raise SystemExit(0 if report['complete'] else 1)
