#!/usr/bin/env python3
"""Measure an explicitly linked runtime pair with independent complete outputs."""
import argparse,json,os,statistics,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,fresh_output,write_json
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--pair',type=Path,required=True);p.add_argument('--provenance',type=Path,required=True)
p.add_argument('--expected',type=Path,required=True);p.add_argument('--rounds',type=int,choices=[1,4],default=4)
p.add_argument('--out',type=Path,required=True);a=p.parse_args()
pair=json.loads(a.pair.read_text());origin=json.loads(a.provenance.read_text())
require(pair['kind']=='phase172-static-seal-linked-pair' and pair['complete'],'Linked pair required')
require(origin['kind']=='bend-native-build' and origin['complete'],'Authentic machine receipt required')
require(pair['programObject']==origin['object'],'Program object differs from original receipt')
require(origin['irDigest']['sha256']==pair['programIR']['sha256'],'Program IR differs from machine receipt')
rows=pair['variants'];require([r['label'] for r in rows]==['baseline','static-seal'],'Expected pair')
inputs=[pin(__file__),pin(a.pair),pin(a.provenance),pin(a.expected),*pair['inputs'],*[r['binary'] for r in rows]]
for i in inputs:verify(i)
out=fresh_output(a.out,ROOT);expected=a.expected.read_bytes()
env={k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['BANGS','LD_PRELOAD','LD_AUDIT']}
report=dict(kind='phase172-static-seal-runtime-pair',complete=False,inputs=inputs,rounds=a.rounds,runs=[],scope='Identical generated program machine object; runtime differs. Complete ordinary output oracle. Whole fresh process including setup and teardown; not full compiler speed or proof.')
def save():write_json(out/'report.json',report)
save()
try:
 for cycle in range(a.rounds):
  for row in rows if cycle%2==0 else rows[::-1]:
   name=row['label'];verify(row['binary']);cmd=[row['binary']['file'],'--threads','1','--gpu','off'];t=time.perf_counter()
   run=subprocess.run(cmd,cwd=ROOT,env=env,capture_output=True,timeout=20);seconds=time.perf_counter()-t
   so=out/f'{cycle}-{name}.stdout';se=out/f'{cycle}-{name}.stderr';so.write_bytes(run.stdout);se.write_bytes(run.stderr)
   passed=run.returncode==0 and run.stdout==expected and run.stderr==b''
   report['runs'].append(dict(cycle=cycle,role=name,command=cmd,seconds=seconds,exitCode=run.returncode,stdout=pin(so),stderr=pin(se),outputExact=passed));save();require(passed,'Complete output mismatch '+name)
 report['medians']={r['label']:statistics.median(x['seconds'] for x in report['runs'] if x['role']==r['label']) for r in rows}
 report['resolved']=a.rounds==4 and min(x['seconds'] for x in report['runs'])>=.03
 if report['resolved']:report['ratio']=report['medians']['static-seal']/report['medians']['baseline']
 for i in inputs:verify(i)
 report['complete']=True
except Exception as e:report['error']=repr(e)
finally:save();print(json.dumps({k:v for k,v in report.items() if k in ['complete','resolved','medians','ratio','error']}))
if not report['complete']:raise SystemExit(1)
