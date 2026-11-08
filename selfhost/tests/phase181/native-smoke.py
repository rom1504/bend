#!/usr/bin/env python3
"""Independent literal-output smoke controls for an explicit native x86 image."""
import argparse,json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,fresh_output,write_json
p=argparse.ArgumentParser();p.add_argument('--image-receipt',required=True);p.add_argument('--binding',required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=fresh_output(a.out,ROOT)
cases=[('higher-order-capture',ROOT/'selfhost/tests/consolidation/native-focused/higher-order-capture.bend','captured=42\n'),('pure-aggregate',ROOT/'selfhost/tests/consolidation/native-focused/pure-aggregate.bend',"([7, 7, 7], (1, 2n, 'c'), [[True{}], []], [3, 3], [])\n"),('tail-argument-permutation',ROOT/'selfhost/tools/performance/phase113/controls/fixtures/tail-argument-permutation.bend',None)]
report=dict(kind='phase181-native-source-smoke',complete=False,inputs=[pin(__file__),pin(a.image_receipt),pin(a.binding)],runs=[],scope='Three independent literal/frozen output controls, including closure/static data, aggregates and a 100001-iteration tail permutation. Not broad conformance or promotion.')
def save():write_json(out/'report.json',report)
save()
try:
 for name,source,literal in cases:
    expected=out/(name+'.expected')
    if literal is None:
        oracle=ROOT/'selfhost/tools/performance/phase113/controls/expected'/f'{name}.stdout'
        report['inputs'].append(pin(oracle));expected.write_bytes(oracle.read_bytes())
    else:expected.write_text(literal)
    report['inputs'] += [pin(source),pin(expected)]
    cmd=[sys.executable,'-B',str(ROOT/'selfhost/tests/phase181/native-build.py'),'--image-receipt',a.image_receipt,'--binding',a.binding,'--source',str(source),'--expected',str(expected),'--seconds','40','--out',str(out/name)]
    result=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=45)
    (out/(name+'.stdout')).write_bytes(result.stdout);(out/(name+'.stderr')).write_bytes(result.stderr)
    file=out/name/'report.json';row=json.loads(file.read_text())if file.exists()else{}
    report['runs'].append(dict(name=name,command=cmd,exit=result.returncode,receipt=pin(file)if file.exists()else None,complete=row.get('complete',False)));save()
    require(result.returncode==0 and row.get('complete')and row.get('outputExact'),'failed '+name)
 for item in report['inputs']:verify(item)
 report['complete']=True
except Exception as e:report['error']=repr(e)
finally:save();print(json.dumps(dict(complete=report['complete'],runs=len(report['runs']),error=report.get('error'))))
if not report['complete']:raise SystemExit(1)
