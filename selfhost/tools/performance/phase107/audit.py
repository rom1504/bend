#!/usr/bin/env python3
import importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;spec=importlib.util.spec_from_file_location('controls',HERE/'inline/controls.py');C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
out=Path(sys.argv[1]);rows=[];programs={}
for r in json.loads((out/'rows.json').read_text()):
 before=json.loads(Path(r['stem']+'.before.json').read_text());after=json.loads(Path(r['stem']+'.json').read_text())
 rows.append(dict(method=r['method'],**C.audit_pair(r['name'],before,after,r['budget'])))
 if r['budget']==4096 and r['method']=='nx_inline_deep':programs[r['name']]=after
result=dict(complete=True,rows=rows,negative=C.negative_controls(programs));(out/'report.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,pairs=len(rows),observations=sum(len(r['observations']) for r in rows),negative=len(result['negative']))))
