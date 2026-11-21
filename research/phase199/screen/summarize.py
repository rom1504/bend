"""Revalidate the closed focused study and retain all denominators."""
import hashlib,json,statistics,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).parent;B=ROOT/'selfhost/build/phase199'
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'));import bench
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads(Path(p).read_text())
def verify(v):
 q=pin(v['file']);assert all(q[k]==v[k] for k in ['bytes','sha256']);return q
mp=B/'focused-runtime01/report.json';m=read(mp);assert m['complete'];p=read(verify(m['products'])['file']);assert p['complete'];verify(p['study']);verify(m['method']);verify(p['method'])
for v in p['inputs']:verify(v)
for c in p['cases'].values():
 verify(c['source']);verify(c['baselineObject']);verify(c['candidateObject'])
 for arm in c['arms'].values():
  for product in arm['products'].values():verify(product['artifact'])
for x in m['samples']:
 want=p['cases'][x['case']]['point']['expectedStdout'];obs=x['observation'];elapsed=bench.observation(obs['stdout'].encode(),b'',0,dict(expectedStdout=want,repetitions=x['repetitions'],warmups=4),obs['wall']);assert elapsed>=100 and elapsed*1e6/x['repetitions']==x['nsPerWork']
assert len(m['samples'])==225 and m['rounds']==5
for g in m['groups']:
 for role in m['roles']:
  rows=[x for x in m['samples'] if x['case']==g['case'] and x['arm']==g['arm'] and x['role']==role]
  assert len(rows)==5 and sorted(x['position'] for x in rows)==list(range(5))
  base=[x for x in m['samples'] if x['case']==g['case'] and x['arm']==g['arm'] and x['role']=='baseline']
  pairs=[x['nsPerWork']/next(y['nsPerWork'] for y in base if y['round']==x['round']) for x in rows]
  assert statistics.median(pairs)==g['againstMatchedBaseline'][role]['median']
gates=[]
for name in ['baseline-api01','baseline-capture01','focused-emission01','focused-products01','focused-runtime01','scan-controls-old01','scan-selector-controls01','scan-controls-new01','runtime-bundle01']:
 gp=B/(name+'-guard')/'process.json';cp=ROOT/'selfhost/build-retention/phase199'/(name+'-close')/'report.json';g=read(gp);assert g['complete'] and g['returncode']==0 and read(cp)['complete'];gates.append(dict(name=name,guard=pin(gp),close=pin(cp),seconds=g['wallSeconds']))
r=dict(complete=True,targetsRun=False,method=pin(__file__),measurement=pin(mp),products=m['products'],groups=m['groups'],sampleCount=225,pilotCount=len(m['pilots']),positionBalanced=True,minimumSampleMs=min(x['observation']['elapsedMs'] for x in m['samples']),unchangedControlObjects=['editdist','mandelbrot'],gates=gates,projection=dict(computed=False,reason='Only5catalogobjects emitted in this screen; remaining40not certified unchanged. project.py requires an authenticated all45 object set.'),scope='Actual complete-program paired timings from checked Bend lowering plus real C/SSE2 helper; no assembly patch. Original/live runtime and scalar delegate denominators retained. No native self-reproduction or full-suite speed claim for this isolated experiment.')
out=HERE/'results.json';assert not out.exists();out.write_text(json.dumps(r,indent=2)+'\n')
lines=['# Phase199 checked scan results','','All three folds passed ordinary C output checks, extra argument checks, actual helper activation, and independent real-worker state/ownership controls. Both unrelated sentinel objects were byte-identical. Timing used5role positions×5rounds, two live-runtime layouts and one original-runtime cross-check;225samples, minimum '+str(r['minimumSampleMs'])+'ms.','','| Case | Runtime / layout | SIMD / matched baseline | SIMD / mature C | SIMD / scalar delegate |','|---|---|---:|---:|---:|']
for g in m['groups']:lines.append('| '+g['case']+' | '+g['arm']+' | '+f"{g['againstMatchedBaseline']['simd']['median']:.4f} | {g['simdOverC']:.4f} | {g['simdOverDelegate']:.4f} |")
lines+=['','The short128 case remains slower than mature C. The no-helper and matched-baseline results are separately retained in results.json; they are not silently substituted. These observations do not include the independently authored transfer, which has a separate native-integrated protocol. No full45 projection is claimed without the remaining42 exact-object condition.']
(HERE/'RESULTS.md').write_text('\n'.join(lines)+'\n');print(pin(out))
