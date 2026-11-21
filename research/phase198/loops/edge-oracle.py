#!/usr/bin/env python3
"""Finite complete-program edge comparisons with retained independent mature C."""
import hashlib,json,os,pathlib,subprocess,sys,time
ROOT=pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'))
import bench
OUT=pathlib.Path(sys.argv[1]);OUT.mkdir(exist_ok=False)
assert os.sched_getaffinity(0)=={3}
paths=[ROOT/'selfhost/build/phase198/loops-build01/programs.manifest.json',ROOT/'selfhost/build/phase194/runtime-plan01/manifest.json']
docs=[json.loads(p.read_text())for p in paths]
def pin(p):return {'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size}
rows=[];report={'complete':False,'method':pin(pathlib.Path(__file__)),'manifests':[pin(p)for p in paths],'rows':rows,'scope':'Independent mature C versus candidate: first three complete output/value-count lines. Fourth line is elapsed time and must be numeric; not compared.'}
start=time.monotonic()
try:
 for case,points in [('editdist',[(0,0),(1,0),(1,4294967295),(2,17),(3,123),(4,1)]),('local-fold',[(0,0),(1,4294967295),(2,17),(127,123),(128,0),(129,4294967295),(257,17),(8192,123)])]:
  cc=next(c for c in docs[0]['cases']if c['id']==case);ref=next(c for c in docs[1]['cases']if c['id']==case)
  assert cc['source']==ref['source'] and cc['sourceGroup']==ref['sourceGroup']
  products={'loops':cc['products']['loops'],'c':ref['products']['c']}
  for product in products.values():assert pin(pathlib.Path(product['artifact']['file']))==product['artifact']
  for index,args in enumerate(points):
   outputs={};row={'case':case,'arguments':args,'products':{r:p['artifact']for r,p in products.items()},'runs':{}}
   for role,product in products.items():
    cmd=[product['artifact']['file'],*bench.native_runtime_arguments(product),'1','0',*map(str,args)]
    child=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=10,cwd=ROOT)
    base=OUT/f'{case}-{index}-{role}';stdout=base.with_suffix('.stdout');stderr=base.with_suffix('.stderr');stdout.write_bytes(child.stdout);stderr.write_bytes(child.stderr)
    row['runs'][role]={'command':cmd,'exit':child.returncode,'stdout':pin(stdout),'stderr':pin(stderr)}
    assert child.returncode==0 and not child.stderr
    lines=child.stdout.decode().splitlines();assert len(lines)==4 and all(x.isdigit()for x in lines) and lines[1]=='0' and lines[2]in ['0','1']
    outputs[role]=lines[:3]
   assert outputs['loops']==outputs['c'],(case,args,outputs)
   row['matched']=True;row['value']=outputs['c'][0];rows.append(row)
 report['complete']=True
finally:
 report['seconds']=time.monotonic()-start;(OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'complete':report['complete'],'pairs':len(rows),'seconds':report['seconds']}))
