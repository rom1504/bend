"""Independent replay of original full-output oracle over frozen observations."""
import importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];BASE=ROOT/'selfhost/build/phase117'
s=importlib.util.spec_from_file_location('oracle',ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py');O=importlib.util.module_from_spec(s);s.loader.exec_module(O)
m=O.read(ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json');cases={c['name']:c for c in m['cases']};rows=[]
for p in sorted(BASE.glob('*/report.json')):
 j=O.read(p)
 if not j.get('complete') or not j.get('rows') or not all('binary' in r and 'elapsedMs' in r for r in j['rows']):continue
 for r in j['rows']:
  cmd=r['command'];assert cmd[1:6]==['--threads','1','--gpu','off','--'];c=dict(cases[r['name']],repetitions=int(cmd[6]),warmups=int(cmd[7]));assert list(map(str,c['runtimeArgs']))==cmd[8:];O.verify(r['binary']);O.verify(c['source']);O.verify(c['expectedStdoutEvidence']);O.verify(r['stdout']);O.verify(r['stderr'])
  elapsed=O.observation(Path(r['stdout']['file']).read_bytes(),Path(r['stderr']['file']).read_bytes(),0,c,r['wallSeconds']);assert elapsed==r['elapsedMs'];assert elapsed>=20 or r['name']=='scalar-region-0'
 rows.append(dict(receipt=O.pin(p),observations=len(j['rows']),complete=True))
out=BASE/'independent-output-check01.json';assert not out.exists();O.save(out,dict(complete=True,inputs=[O.pin(__file__),O.pin(O.__file__)],campaigns=rows,observations=sum(r['observations'] for r in rows),scope='Original full-output/count/elapsed oracle; all non-sentinel intervals >=20ms; pins rechecked. Historical ordinary-oracle schema failure retained separately.'))
print(sum(r['observations'] for r in rows),'observations replayed')
