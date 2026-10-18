#!/usr/bin/env python3
"""Compare all final emitter products and evaluate the independent effect result."""
from pathlib import Path
import hashlib,json,sys
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4];b=ROOT/'selfhost/build/phase107';out=b/'constant-final01';out.mkdir(exist_ok=False)
sys.path.insert(0,str(ROOT/'selfhost/tools/performance/phase106'));from reference import Interpreter
pin=lambda p:dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
r=dict(complete=False,products=[],effectModels=[],method=pin(Path(__file__)),interpreter=pin(ROOT/'selfhost/tools/performance/phase106/reference.py'))
(out/'method.py').write_bytes(Path(__file__).read_bytes())
try:
 for row in json.loads((b/'artifacts-constant01/report.json').read_text())['rows']:
  for ext in ['json','c','ssa']:
   old=Path(row['stem']+'.'+ext);new=b/'artifacts-constant02'/old.name;assert old.read_bytes()==new.read_bytes(),old
   r['products'].append(dict(before=pin(old),after=pin(new)))
 for mode in ['before','after']:
  p=b/'constant-capacity02'/('effect-operands.'+mode+'.json');v=Interpreter(json.loads(p.read_text())).run([]);assert v['value']==9
  r['effectModels'].append(dict(input=pin(p),args=[],expected=9,observation=v))
 r['complete']=True
finally:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(dict(complete=True,products=len(r['products']),effectModels=len(r['effectModels']))))
