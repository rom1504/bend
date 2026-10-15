#!/usr/bin/env python3
"""Require the fixed law to reject three deliberately wrong implementations."""
import hashlib, json, pathlib, subprocess, sys
ROOT=pathlib.Path(__file__).resolve().parents[4]
source=ROOT/'selfhost/proofs/phase94/candidate01';out=pathlib.Path(sys.argv[1]).resolve()
assert not out.exists();out.mkdir(parents=True)
original=(source/'helper.bend').read_text()
mutations={
 'reverse-live':('NPE_Part{Con{head, rows}, drop}', 'NPE_Part{List.append(&2, A, rows, Con{head, Nil{}}), drop}'),
 'omit-drop':('NPE_Part{Nil{}, drop(binding, zero)}','NPE_Part{Nil{}, zero}'),
 'retain-dead':('case False{}: more','case False{}:\n      match more:\n        case NPE_Part{rows, drop}: NPE_Part{Con{head, rows}, drop}')}
rows=[]
for name,(before,after) in mutations.items():
 d=out/name;d.mkdir();assert original.count(before)==1
 for file in ['reference.bend','proof.bend']:(d/file).write_bytes((source/file).read_bytes())
 text=original.replace(before,after);(d/'helper.bend').write_text(text)
 command=[sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase86/guard.py'),'--out',str(d/'guard'),
  '--seconds','30','--cpu','3','--','env','BEND_NO_TELEMETRY=1',str(ROOT/'selfhost/build/phase66/bun-toolchain01/bun'),
  str(ROOT/'bend2/main.ts'),str(d/'proof.bend'),'--check-only']
 result=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
 receipt=json.loads((d/'guard/process.json').read_text());log=(d/'guard/stdout.log').read_text()+(d/'guard/stderr.log').read_text()
 rejected=receipt['returncode']==1 and not receipt.get('stoppedFor') and 'SOME PROOFS FAIL' in log and 'expected' in log and 'observed' in log
 rows.append(dict(name=name,before=before,after=after,sha256=hashlib.sha256(text.encode()).hexdigest(),rejected=rejected,process=receipt,log=log))
 (out/'report.json').write_text(json.dumps(dict(complete=len(rows)==3,passed=all(r['rejected'] for r in rows),rows=rows),indent=2)+'\n')
 assert rejected, name
print(json.dumps(dict(complete=True,passed=True,mutations=len(rows))))
