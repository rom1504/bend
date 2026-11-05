#!/usr/bin/env python3
"""Admission and single-result native transfer, never a frozen benchmark ratio."""
import argparse,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,run,write_json,fresh_output
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=fresh_output(a.out,ROOT)
manifest=ROOT/'selfhost/build/phase163/transfer-source01/manifest.json';cases=json.loads(manifest.read_text());require(cases['complete'],'Unprepared transfer')
build=ROOT/'selfhost/build/phase163/direct-native-recovery01/report.json';image=json.loads(build.read_text())['binary'];verify(image)
request=json.load(open(ROOT/'selfhost/build/phase163/reverse-baseline01/request.json'));base,carrier,stamp=request['base'],request['carrier'],request['stamp'];verify(base);verify(carrier)
r=dict(complete=False,inputs=[pin(__file__),pin(manifest),pin(build),image,base,carrier],rows=[],scope='Eight preselected families, unchanged computation at frozen point with pure readback adapter; unsupported roots are refusals, not passes. Ordinary source checking and full oracle output; no frozen timing or full-language qualification.')
def save():write_json(out/'report.json',r)
try:
 for case in cases['cases']:
  source,expected=case['source'],case['expected'];verify(source);verify(expected);r['inputs'] += [source,expected,case['transformation']];row=dict(id=case['id'],source=source,expected=expected,complete=False);r['rows'].append(row);save()
  dest=out/case['id'];dest.mkdir();ir=dest/'program.ssa'
  cmd=[image['file'],'--threads','1','--gpu','off','--','phase111',source['file'],base['file'],'cache',carrier['file'],stamp]
  job=run(cmd,cwd=ROOT,stdout=ir,stderr=dest/'compiler.stderr',seconds=20);row['compile']=job;save()
  if not job['complete']:
   diagnostic=Path(job['stderr']['file']).read_text();row['status']='refused';row['diagnostic']=diagnostic
   require(not job['timedOut'] and job.get('exitCode')==1 and 'direct' in diagnostic,'Unexpected failure '+case['id'])
   row['complete']=True;save();continue
  require(job['stderr']['bytes']==0 and job['stdout']['bytes']>0,'Invalid emission');row['status']='admitted'
  command=[sys.executable,'-B','selfhost/tools/build/native.py','--assets','selfhost/manifests/assets-native.json','--ir',str(ir),'--target','qbe','--out',str(dest/'machine'),'--seconds','20','--expected-stdout',expected['file']]
  machine=run(command,cwd=ROOT,stdout=dest/'machine.stdout',stderr=dest/'machine.stderr',seconds=25);row['machineJob']=machine;save();require(machine['complete'],'Machine or independent output failed '+case['id'])
  receipt=json.loads((dest/'machine/report.json').read_text());require(receipt['complete'] and receipt['outputExact'],'Independent oracle mismatch');row['build']=pin(dest/'machine/report.json');row['status']='output-passed';row['complete']=True;save()
 r['complete']=True
except Exception as e:r['error']=str(e);raise
finally:save();print(json.dumps(dict(complete=r['complete'],rows=len(r['rows']),error=r.get('error'))))
