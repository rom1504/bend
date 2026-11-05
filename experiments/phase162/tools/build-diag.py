#!/usr/bin/env python3
"""Build frozen diagnostic preparation into a separate fresh guarded root."""
import argparse,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,write_json,fresh_output,run
p=argparse.ArgumentParser();p.add_argument('--prep',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
prep=a.prep.resolve();plan=json.loads((prep/'plan.json').read_text());out=fresh_output(a.out,ROOT)
for row in plan['inputs']:verify(row)
cmd=list(plan['command']);cmd[cmd.index('-o')+1]=str(out/'program')
r=run(cmd,cwd=ROOT,stdout=out/'stdout',stderr=out/'stderr',seconds=185)
d=dict(complete=r['complete'],plan=pin(prep/'plan.json'),method=pin(__file__),process=r,inputs=plan['inputs'])
if r['complete']:d['binary']=pin(out/'program')
write_json(out/'report.json',d);require(d['complete'],'Diagnostic build failed')
print(json.dumps(dict(complete=True,binary=d['binary'],seconds=r.get('wallSeconds'))))
