import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
f=ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json';m=json.loads(f.read_text())
names=['tree-bitonic','coverage-list-pipeline-128','coverage-expression-128','lexer','local-pair','variation-ray-active-256-2240']
cases={c['name']:c for c in m['cases']}
s=json.loads((ROOT/'implementation/phase114/selection.json').read_text())['nativeQualified']
a=json.loads((ROOT/'selfhost/build/phase111/p115-api02/report.json').read_text());assert a['complete'] and a['checked']
selected=[]
for i,n in enumerate(names):
 c=cases[n];assert pin(c['source']['file'])==c['source'] and pin(c['expectedStdoutEvidence']['file'])==c['expectedStdoutEvidence']
 selected.append(dict(c,partition='training' if i<3 else 'evaluation'))
x=dict(kind='phase115-frozen-policy-experiment',complete=True,policies=[0,1,2,3],rounds=3,warmupRounds=1,cases=selected,api=a['api'],apiReport=pin(ROOT/'selfhost/build/phase111/p115-api02/report.json'),referenceApi=s['api'],runtime=s['runtime'],parent=s['source'],inputs=[pin(f),pin(__file__),pin(ROOT/'design/phase115/reusable-plans-and-policy-search.md'),pin(ROOT/'selfhost/build/phase115/source02/manifest.json')],scope='Historical sources; evaluation partition excluded from policy selection, not unseen research holdout. Policy0 compared with qualified unmodified API.')
out=ROOT/'selfhost/tools/performance/phase115/manifest01.json';assert not out.exists();out.write_text(json.dumps(x,indent=2)+'\n')
print('frozen',names)
