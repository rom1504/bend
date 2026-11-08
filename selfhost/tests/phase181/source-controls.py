#!/usr/bin/env python3
"""Serial independent-output controls; every compiler operation runs in Bend."""
import argparse,json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import fresh_output,pin,verify,write_json,require
p=argparse.ArgumentParser();p.add_argument('--emitter',required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=fresh_output(a.out,ROOT)
rows=[]
for name,expected in [('u32-wide-wrap','94 q\n'),('u32-divmod','9\n'),('pure-aggregate',"([7, 7, 7], (1, 2n, 'c'), [[True{}], []], [3, 3], [])\n"),('higher-order-capture','captured=42\n')]:
    ep=out/(name+'.expected');ep.write_text(expected)
    rows.append((name,ROOT/'selfhost/tests/consolidation/native-focused'/f'{name}.bend',ep))
for name in ['tail-argument-permutation','closed-branch-suffix','array-scalar-return','string-field-alias','non-tail-reconstruction']:
    root=ROOT/'selfhost/tools/performance/phase113/controls'
    rows.append((name,root/'fixtures'/f'{name}.bend',root/'expected'/f'{name}.stdout'))
report=dict(kind='phase181-source-output-controls',complete=False,inputs=[pin(__file__),pin(a.emitter)],runs=[],scope='Nine unchanged positive source fixtures, literal/frozen complete stdout, both current x86 emitter and paired retained QBE emitter. Not broad target qualification.')
def save():write_json(out/'report.json',report)
save()
try:
 for name,source,expected in rows:
    report['inputs'] += [pin(source),pin(expected)]
    cmd=[str(ROOT/'selfhost/.assets/bin/bun'),str(ROOT/'selfhost/tests/phase181/hosted-build.mjs'),'--baseline',str(ROOT/'selfhost/build/phase171/descendant-api15/report.json'),'--emitter',a.emitter,'--binding',str(ROOT/'selfhost/build/phase181/emitter-source01/base-binding.json'),'--source',str(source),'--expected',str(expected),'--out',str(out/name)]
    result=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=65)
    (out/(name+'.stdout')).write_bytes(result.stdout);(out/(name+'.stderr')).write_bytes(result.stderr)
    receipt=out/name/'report.json';d=json.loads(receipt.read_text())if receipt.exists()else{}
    report['runs'].append(dict(name=name,command=cmd,status=result.returncode,receipt=pin(receipt)if receipt.exists()else None,complete=d.get('complete',False),error=d.get('error')));save()
    require(result.returncode==0 and d.get('complete'),'failed '+name+': '+str(d.get('error')))
 for item in report['inputs']:verify(item)
 report['complete']=True
except Exception as e:report['error']=repr(e)
finally:save();print(json.dumps(dict(complete=report['complete'],runs=len(report['runs']),error=report.get('error'))))
if not report['complete']:raise SystemExit(1)
