#!/usr/bin/env python3
"""Paired cold-process native source-to-QBE requests; fixed cached Base mode."""
import argparse,json,sys,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,run,write_json,fresh_output
p=argparse.ArgumentParser();p.add_argument('--emission',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--candidate',type=Path,default=ROOT/'selfhost/build/phase163/direct-native-recovery01/report.json');p.add_argument('--mode',type=int);a=p.parse_args()
cases=json.loads(a.emission.read_text());require(cases['complete'],'Incomplete input');out=fresh_output(a.out,ROOT)
baseline=json.load(open(ROOT/'selfhost/build/phase152/native-n2/report.json'))
candidate=json.load(open(a.candidate))
require(baseline['complete'] and candidate['complete'],'Build gate failed')
images={'baseline':baseline['binary'],'direct':candidate['binary']}
request=json.load(open(ROOT/'selfhost/build/phase163/reverse-baseline01/request.json'))
base,carrier,stamp=request['base'],request['carrier'],request['stamp'];[verify(x) for x in [base,carrier,*images.values()]]
r=dict(complete=False,inputs=[pin(__file__),pin(a.emission),pin(a.candidate),base,carrier,*images.values()],rows=[],scope='New processes, same input/Base/carrier/CPU/runtime policy; source-to-QBE including frontend and output. Candidate has explicit machine-build receipt; no production promotion or self-reproduction claim.')
def save():write_json(out/'report.json',r)
def normalize(file):return b'\n'.join(x for x in Path(file).read_bytes().splitlines() if x.strip())
try:
 for case in cases['rows']:
  if a.mode is not None and case.get('mode')!=a.mode:continue
  if not case.get('direct'):continue
  source=case['source'];verify(source);r['inputs'].append(source);row=dict(name=case['name'],source=source,samples=[],complete=False);r['rows'].append(row);save()
  expected={mode:normalize(case[mode]['file']) for mode in images}
  for i,mode in enumerate(['baseline','direct','direct','baseline']):
   binary=images[mode];cmd=[binary['file'],'--threads','1','--gpu','off','--','phase111',source['file'],base['file'],'cache',carrier['file'],stamp]
   job=run(cmd,cwd=ROOT,stdout=out/(case['name']+f'-{i}-{mode}.ssa'),stderr=out/(case['name']+f'-{i}-{mode}.stderr'),seconds=30)
   require(job['complete'] and job['stderr']['bytes']==0,'Native request failed '+case['name']+' '+mode)
   require(normalize(job['stdout']['file'])==expected[mode],'Nonblank QBE differs from independently executed hosted route')
   row['samples'].append(dict(mode=mode,**job));save()
  row['medianSeconds']={mode:statistics.median(x['seconds'] for x in row['samples'] if x['mode']==mode) for mode in images}
  row['ratio']=row['medianSeconds']['direct']/row['medianSeconds']['baseline'];row['complete']=True;save()
 r['complete']=True
except Exception as e:r['error']=str(e);raise
finally:save();print(json.dumps(dict(complete=r['complete'],rows=len(r['rows']),error=r.get('error'))))
