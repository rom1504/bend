"""Read-only summaries; no timing samples or failed observations are discarded."""
import hashlib,json,math,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];BASE=ROOT/'selfhost/build/phase117';OUT=ROOT/'implementation/phase117'
def read(p):return json.loads(Path(p).read_text())
def pin(p):
 p=Path(p).resolve();return dict(file=str(p.relative_to(ROOT)),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def gm(xs):return math.exp(statistics.mean(math.log(x) for x in xs))
def runtime(p):
 j=read(p);assert j['complete'];out=[]
 for name in dict.fromkeys(r['name'] for r in j['rows']):
  rows=[r for r in j['rows'] if r['name']==name];assert all(r['correct'] for r in rows)
  samples={role:[r['elapsedMs'] for r in rows if r['role']==role] for role in ['candidate','baseline','upstream']};med={k:statistics.median(v) for k,v in samples.items()};row=dict(name=name,samplesMs=samples,medianMs=med,timed=all(med.values()))
  if row['timed']:row.update(speedup=med['baseline']/med['candidate'],candidateVsUpstream=med['candidate']/med['upstream'],baselineVsUpstream=med['baseline']/med['upstream'])
  out.append(row)
 timed=[r for r in out if r['timed']];return dict(receipt=pin(p),observations=len(j['rows']),allCorrect=True,cases=out,timedCases=len(timed),candidateVsUpstream=gm([r['candidateVsUpstream'] for r in timed]),baselineVsUpstream=gm([r['baselineVsUpstream'] for r in timed]),speedup=gm([r['speedup'] for r in timed]))
r=dict(complete=True,method=pin(__file__),scope='Hosted checked Bend emitter; runtime programs are native QBE. No new native compiler image or installed promotion.',campaigns={})
for n in ['scalar-screen03','packed-screen01','hoist-screen01','hoist-screen02','inline-screen01','version-screen01','boolean-screen02','broad-screen01','fallback-screen01','unroll-screen01','unroll-recheck01','o3-screen01','fill-o3-screen01','fill-broad01']:
 p=BASE/n/'report.json'
 if p.exists():r['campaigns'][n]=runtime(p)
p=BASE/'closure-recheck01/report.json'
if p.exists() and read(p).get('complete'):r['campaigns']['closure-recheck01']=runtime(p)
p=BASE/'compiler-cost01/report.json'
if p.exists() and read(p).get('complete'):
 j=read(p);rows=[]
 for n in dict.fromkeys(x['name'] for x in j['rows']):
  samples={role:[x['seconds'] for x in j['rows'] if x['name']==n and x['role']==role and x['round']>=0] for role in ['baseline','candidate']};med={role:statistics.median(v) for role,v in samples.items()};stages={role:{stage:statistics.median(x['stages'][stage] for x in j['rows'] if x['name']==n and x['role']==role and x['round']>=0) for stage in ['frontend','admission','lower','verify','emit']} for role in samples};rows.append(dict(name=n,samplesSeconds=samples,medianSeconds=med,stageMedianSeconds=stages,ratio=med['candidate']/med['baseline']))
 r['compilerCost']=dict(receipt=pin(p),scope=j['scope'],cases=rows,geometricRatio=gm([x['ratio'] for x in rows]))
s=read(BASE/'version-source03/manifest.json');r['source']=dict(manifest=pin(BASE/'version-source03/manifest.json'),source=s['source'],parent=s['parent'],lines=s['physicalLines'],parentLines=s['parentLines'],addedHelpers=len(s['added']),overrides=s['overrides'])
e=read(BASE/'broad-emit01/report.json');b=read(ROOT/'selfhost/build/phase114/final45-audit01-binding.json');r['generated']=dict(qbeBytes=sum(x['qbe']['bytes'] for x in e['cases']),baselineQbeBytes=sum(x['qbe']['bytes'] for x in b['products'].values()),versionedPrograms=[dict(name=x['name'],functions=Path(x['qbe']['file']).read_text().count('function l $p117v_')) for x in e['cases'] if 'function l $p117v_' in Path(x['qbe']['file']).read_text()])
guards=[]
for p in sorted(BASE.glob('*-guard/process.json')):
 j=read(p)
 if 'wallSeconds' in j:guards.append(dict(receipt=pin(p),complete=j['complete'],seconds=j['wallSeconds'],peakBytes=j.get('peakTreeRssBytes')))
r['execution']=dict(guards=guards,guardSeconds=sum(x['seconds'] for x in guards),failedGuardSeconds=sum(x['seconds'] for x in guards if not x['complete']),peakBytes=max(x['peakBytes'] or 0 for x in guards))
(OUT/'results.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({k:v for k,v in r.items() if k not in ['campaigns','compilerCost','execution']},indent=2));print('guardSeconds',r['execution']['guardSeconds'])
