#!/usr/bin/env python3
"""One fresh-process complete live-Base source-to-executable experiment."""
import argparse,json,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import run,pin,write_json,fresh_output,require
import assets
p=argparse.ArgumentParser();p.add_argument('--receipt',required=True);p.add_argument('--source',required=True);p.add_argument('--role',required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--preparation',choices=['live','cache'],default='live');a=p.parse_args()
out=fresh_output(a.out,ROOT);report=dict(complete=False,role=a.role,inputs=[pin(__file__),pin(a.receipt),pin(a.source)],stages={})
start=time.monotonic()
extra=[]
if a.preparation=='cache':
 doc=assets.load_assets(ROOT/'selfhost/manifests/assets-native.json');base,carrier,stamp,inputs=assets.prepared_base(doc,'cache');binding=out/'base-binding.json';write_json(binding,dict(base=base,carrier=carrier,stamp=stamp,manifest=doc['_manifest']));extra=[str(binding)];report['inputs']+=inputs+[doc['_manifest']]
report['preparationPolicy']=a.preparation
try:
 job=run(['selfhost/.assets/bin/bun','experiments/phase168/tools/request-v4.mjs',a.receipt,a.source,'selfhost/.bootstrap/upstream-phase66/bend2/base.bend',a.role,str(out/'emit'),*extra],cwd=ROOT,stdout=out/'emit.stdout',stderr=out/'emit.stderr',seconds=120)
 report['emission']=job;write_json(out/'report.json',report);require(job['complete'],'Emission failed')
 emit=json.loads((out/'emit/report.json').read_text());require(emit['complete'],'Incomplete emission');report['stages']=emit['stages'];report['functions']=emit['functions'];report['ir']=emit['ir']
 job=run([sys.executable,'-B','selfhost/tools/build/native.py','--assets','selfhost/manifests/assets-native.json','--target','qbe','--ir',str(out/'emit/program.ssa'),'--out',str(out/'machine'),'--seconds','45'],cwd=ROOT,stdout=out/'machine.stdout',stderr=out/'machine.stderr',seconds=50)
 report['construction']=job;report['sourceToExecutableSeconds']=time.monotonic()-start;write_json(out/'report.json',report);require(job['complete'],'Machine construction failed')
 native=json.loads((out/'machine/report.json').read_text());require(native['complete'],'Incomplete machine');report['binary']=native['binary'];report['machineStages']=native.get('stages',native.get('steps'))
 report['complete']=True
finally:write_json(out/'report.json',report);print(json.dumps(report))
