"""Freeze independent ordinary construction/borrowing controls. No target runs."""
import hashlib, importlib.util, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
out=HERE/'controls01.json';assert not out.exists();rows=[]
def add(name, source, stdout, note):
 expected=HERE/(name+'.expected.json');assert not expected.exists()
 expected.write_text(json.dumps(dict(status=0,stdout=stdout,stderr=''),indent=2,ensure_ascii=False)+'\n')
 rows.append(dict(name=name,source=pin(source),expected=pin(expected),expectedStdoutEvidence=pin(expected),provenance=note))
for name,source in [('construction',ROOT/'selfhost/tools/performance/phase102/fusion/fixtures-v3/construction.bend'),('observer',HERE/'observer-control.bend')]:
 text=source.read_text();stdout=''.join(x[2:]+'\n' for x in text.splitlines() if x.startswith('#|'));assert stdout
 add(name,source,stdout,'Independent full literal #| output; ordinary source only.')
m=ROOT/'selfhost/tools/performance/phase102/fusion/controls-v5.json';old=json.loads(m.read_text())
c=next(x for x in old['records'] if x['id']=='refusals');add('refusals',Path(c['source']),c['stdout'],'Retained qualified ordinary non-final/multiple/mutual recursion refusal witnesses.')
method=ROOT/'selfhost/tools/performance/phase102/trmc-cold/controls/prepare.py'
spec=importlib.util.spec_from_file_location('expected',method);M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
source=method.parent/'mixed-construction.bend'
add('mixed',source,'\n'.join([M.value(0,False),M.value(1,False),M.value(1,True),M.value(5,False),M.value(6,True),'λleft','🙂right'])+'\n','Prior independent flat output oracle; alternating final slots1/3 and owned terminal.')
shared=HERE/'shared-construction.bend';assert not shared.exists()
shared.write_text(source.read_text().split('def main()')[0]+'''def main() -> IO(Unit):
  +left : String = String.append("λ", "left")
  +right : String = String.append("🙂", "right")
  +trail : MixedTrail = mixed_build(6n, left, right, True{})
  do IO<Unit>:
    IO.print(mixed_text(trail))
    IO.print(mixed_text(trail))
    IO.print(left)
    IO.print(right)
''')
add('shared',shared,'\n'.join([M.value(6,True),M.value(6,True),'λleft','🙂right'])+'\n','Duplicate completed root; children retain ordinary sealing; both release orders represented by repeated observers.')
out.write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(method),pin(m)],cases=rows),indent=2)+'\n')
print(len(rows))
