#!/usr/bin/env python3
"""Authenticated transport for the qualified native selected-library image.
Compiler algorithms run in the native Bend executable. Guard externally.
"""
import argparse,importlib.util,json,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
s=importlib.util.spec_from_file_location('r',HERE.parent.parent/'phase108/run.py');R=importlib.util.module_from_spec(s);s.loader.exec_module(R)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);p.add_argument('--contract',choices=['reverse','discard','duplicate'],default='reverse');p.add_argument('--policy',choices=['raw','trusted','fused'],default='raw');p.add_argument('--format',choices=['qbe','ir'],default='qbe');p.add_argument('--live',action='store_true');a=p.parse_args()
selection=HERE/'image.json';image=json.loads(selection.read_text());assert image['qualified'];out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase109') and not out.exists()
inputs=[R.pin(Path(__file__)),R.pin(selection),*image['inputs']]
for item in inputs:R.N.verify(item)
out.mkdir(parents=True);source=image['contracts'][a.contract]['file'];binary=image['binary']['file'];argv=[binary,'--threads','1','--gpu','off','--','phase109',source,a.contract,a.format,a.policy,'live' if a.live else 'cache']
report=dict(kind='phase109-native-selected-library-request',complete=False,inputs=inputs,command=argv,scope=image['scope']);R.save(out/'report.json',report);start=time.monotonic()
with (out/'program.txt').open('xb') as so,(out/'stderr.log').open('xb') as se:r=R.P.run(argv,cwd=ROOT,stdout=so,stderr=se,timeout=30)
report.update(status=r.returncode,seconds=time.monotonic()-start,output=R.pin(out/'program.txt'),stderr=R.pin(out/'stderr.log'))
for item in inputs:R.N.verify(item)
report['complete']=r.returncode==0 and not (out/'stderr.log').read_bytes();R.save(out/'report.json',report);print(json.dumps(dict(complete=report['complete'],seconds=report['seconds'],output=report['output'])))
if not report['complete']:raise SystemExit(1)
