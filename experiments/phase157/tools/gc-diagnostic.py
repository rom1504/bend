#!/usr/bin/env python3
"""Separate bendc GC diagnostics; never included in clean timing medians."""
import argparse,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,run,write_json,require
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
clean=json.loads((ROOT/'selfhost/build/phase157/measure02/report.json').read_text())
require(clean['complete']and clean['resolved'],'Clean output-checked comparison required')
binary=ROOT/'selfhost/build/phase157/gc03/program'
env={k:v for k,v in os.environ.items()if not k.startswith('BEND_')and k not in ['LD_PRELOAD','LD_AUDIT']};env['BEND_GC_STATS']='1'
r=run(['bash','-c','exec -a compiler-work "$@"','phase157',binary,'--threads','1','--gpu','off','--','bench',str(clean['repeats'])],cwd=ROOT,stdout=out/'stdout',stderr=out/'stderr',seconds=40,env=env)
report=dict(kind='phase157-gc-diagnostic',complete=r['complete']and r['stdout']['bytes']==0,process=r,inputs=[pin(binary),pin(ROOT/'selfhost/build/phase157/measure02/report.json'),pin(__file__)],environment={'BEND_GC_STATS':'1'},repeats=clean['repeats'],scope='Instrumented collection elapsed times, integer-truncated heap figures; not exclusive CPU or total allocation traffic. Timing excluded from clean summaries.')
write_json(out/'report.json',report);print(json.dumps(report));sys.exit(0 if report['complete']else 1)
