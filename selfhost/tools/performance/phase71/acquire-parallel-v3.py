#!/usr/bin/env python3
import importlib.util,json,time,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase71';HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('support',ROOT/'selfhost/tools/performance/programs/support.py');S=importlib.util.module_from_spec(s);s.loader.exec_module(S)
r=json.loads((RAW/'recipe-v2.json').read_text());out=RAW/'acquire04';out.mkdir(exist_ok=False)
report=dict(complete=False,recipe=S.identity(RAW/'recipe-v2.json'),producer=S.identity(__file__),jobs=[])
def save():S.save(out/'report.json',report)
def run(g,name,cmd):
 d=out/name;result=g.run(['taskset','-c','3',*cmd],d,time.monotonic()+90);report['jobs'].append(dict(name=name,result=result));save();print(name,result['complete'],round(result['wallSeconds'],3),flush=True)
 if not result['complete']:
  print((d/'stderr.log').read_text()[-2500:]);raise RuntimeError(name)
with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as g:
 for role in ['upstream','selfhost']:
  c=out/(role+'.c')
  run(g,'emit-'+role,[r['node'],*r['nodeArgs'],str(HERE/'emit.mjs'),str(RAW/'recipe-v2.json'),role,str(HERE/'balanced.bend'),str(c)])
  run(g,'clang-'+role,[r['clang'],*r['clangArgs'],str(c),*r['linkArgs'],'-o',str(out/role)])
report['artifacts']=[S.identity(p) for p in [RAW/'array-map-virtual.c',RAW/'array-map-virtual',out/'upstream.c',out/'upstream',out/'selfhost.c',out/'selfhost']];report['complete']=True;save()
