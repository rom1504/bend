#!/usr/bin/env python3
"""Unrelated IO/owned-map correctness gate using frozen native45 oracle."""
import json,sys,argparse
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'selfhost/tools/build'));sys.path.insert(0,str(ROOT/'selfhost/tools/bench'))
from common import pin,verify,require,run,write_json,fresh_output
import bench
p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=fresh_output(a.out,ROOT)
report=dict(complete=False,inputs=[pin(__file__),pin(a.build)])
try:
 build=json.loads(a.build.read_text());require(build['complete'],'Incomplete build');verify(build['binary']);report['inputs'].append(build['binary'])
 cat=ROOT/'selfhost/tools/bench/catalogs/native45/catalog.json';doc=json.loads(cat.read_text());case=next(x for x in doc['cases'] if x['id']=='coverage-map-churn-128');point=dict(case['point'],repetitions=1,warmups=0)
 require(build['inputs'][2]['sha256']==case['source']['sha256'],'Different frozen source');report['inputs'].append(pin(cat));report['point']=point
 job=run([build['binary']['file'],'--threads','1','--gpu','off','--',str(point['repetitions']),str(point['warmups']),*map(str,point['runtimeArgs'])],cwd=ROOT,stdout=out/'stdout',stderr=out/'stderr',seconds=20)
 report['job']=job;require(job['complete'],'Native execution failed');report['internalMilliseconds']=bench.observation(Path(job['stdout']['file']).read_bytes(),Path(job['stderr']['file']).read_bytes(),job['exitCode'],point,job['seconds']);report['complete']=True
finally:write_json(out/'report.json',report);print(json.dumps(report))
