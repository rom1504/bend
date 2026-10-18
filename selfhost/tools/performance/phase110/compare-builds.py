#!/usr/bin/env python3
"""Bind already-qualified workers to a common frozen oracle for paired ablation."""
import argparse,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=p.resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(r):
 assert pin(Path(r['file']))==r,r['file']
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--worker',nargs=3,action='append',required=True,metavar=('BUILD','NAME','RENAMED'));a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase110') and not out.exists()
workers=[];inputs=[pin(Path(__file__))];oracle=None;runtime=None
for build,name,renamed in a.worker:
 report=Path(build)/'report.json';m=json.loads(report.read_text());assert m['complete']
 w=next(w for w in m['workers'] if w['name']==name);assert m['semantics'][name]['exact'];verify(w['binary']);verify(w['object'])
 o=next(r for r in m['inputs'] if r['file'].endswith('/expected.jsonl'));verify(o)
 rt=next((r for r in m['inputs'] if r['file'].endswith('/runtime.c')),None)
 if oracle is None:oracle=o;runtime=rt
 assert o['sha256']==oracle['sha256'] and rt and rt['sha256']==runtime['sha256'],'oracle or runtime differs'
 workers.append({**w,'name':renamed,'originName':name,'origin':pin(report)});inputs += [pin(report),o,rt]
assert len(set(w['name'] for w in workers))==len(workers)
out.mkdir(parents=True);(out/'report.json').write_text(json.dumps(dict(kind='phase110-paired-qualified-builds',complete=True,inputs=inputs,workers=workers,semantics={w['name']:dict(exact=True) for w in workers},scope='No code changes or executions; rename only immutable qualified binaries against identical oracle and runtime.'),indent=2)+'\n')
print(out/'report.json')
