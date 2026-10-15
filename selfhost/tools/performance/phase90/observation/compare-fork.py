#!/usr/bin/env python3
"""Compare 2 or 4 guarded legacy/indexed stdout files and every fixture field."""
import argparse, importlib.util, json
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('p90_display',HERE/'compare.py')
d=importlib.util.module_from_spec(spec);spec.loader.exec_module(d)
p=argparse.ArgumentParser();p.add_argument('manifest',type=Path);p.add_argument('logs',nargs='+',type=Path);p.add_argument('--out',required=True,type=Path)
a=p.parse_args();assert len(a.logs) in (2,4),'Compare both roles, optionally in both JS and native C.'
m=json.loads(a.manifest.read_text());assert m['kind']=='phase90-indexed-fork-controls'
raw=[x.read_bytes() for x in a.logs];assert len(set(raw))==1,'Complete stdout differs'
r=d.Reader(raw[0].decode());actual=r.value();r.space();assert r.at==len(r.text),'Unexpected trailing stdout'
assert len(actual)==m['cases']
for i,(got,want) in enumerate(zip(actual,m['expected'])):assert got==want,('Whole product mismatch',i,m['labels'][i],got,want)
report=dict(kind=m['kind'],complete=True,passed=True,cases=m['cases'],exactOutputs=len(raw),retainedWholeSegments=True,oracle=m['oracle'],collision=m['collision'],inputs=[d.pin(a.manifest)]+[d.pin(x) for x in a.logs],methods=[d.pin(Path(__file__)),d.pin(HERE/'compare.py')])
with a.out.open('x') as f:json.dump(report,f,ensure_ascii=False,indent=2);f.write('\n')
print(json.dumps(dict(complete=True,passed=True,cases=m['cases'],exactOutputs=len(raw))))
