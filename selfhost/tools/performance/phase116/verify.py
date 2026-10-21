"""Replay the unchanged Phase112 complete-output gate on every survey observation."""
import importlib.util,json,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];BASE=ROOT/'selfhost/build/phase116'
def load(name,p):
 s=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
S=load('p116survey',Path(__file__).with_name('survey-v2.py'));G=load('p112gate',ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py')
m=S.read(BASE/'manifest01.json');cases={x['name']:x for x in m['cases']};observations=[]
for label in ['clean01','native01','js-profile01']:
 p=BASE/label/'report.json';r=S.read(p);assert r['complete']
 for row in r['rows']:
  c=cases[row['case']];S.verify(row['source']);assert row['source']==c['source'];S.verify(row['product']);S.verify(row['stdout']);S.verify(row['stderr'])
  assert row['command'][-4:]==list(map(str,[row['repetitions'],row['warmups'],*c['args']]))
  if label=='clean01':assert row['repetitions']==4*c['counts']['repetitions'] and row['warmups']==32
  case=dict(expectedStdout=c['expected'],repetitions=row['repetitions'],warmups=row['warmups'])
  elapsed=G.observation(Path(row['stdout']['file']).read_bytes(),Path(row['stderr']['file']).read_bytes(),row['status'],case,row['wallSeconds']);assert elapsed==row['elapsedMs']
  observations.append(dict(report=S.pin(p),case=row['case'],role=row['role'],round=row['round'],passed=True))
cr=S.read(BASE/'compiler01/report.json');oracle=Path(cr['inputs'][-1]['file']).read_bytes();assert cr['complete']
for row in cr['rows']:
 S.verify(row['stdout']);S.verify(row['stderr']);assert row['status']==0 and not Path(row['stderr']['file']).read_bytes() and Path(row['stdout']['file']).read_bytes()==oracle
out=BASE/'independent-output-check01.json';assert not out.exists();S.save(out,dict(complete=True,method=S.pin(__file__),unchangedGate=S.pin(G.__file__),benchmarkObservations=len(observations),compilerExactQbeObservations=len(cr['rows']),observations=observations,scope='Original Phase112 complete-output/count/interval gate, replayed without changes. Not a new full45 conformance campaign.'))
print(len(observations),'original-gate observations and',len(cr['rows']),'exact compiler outputs pass')
