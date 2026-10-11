"""Collect the closed compiler23 campaign, retaining every paired timing."""
import hashlib, json, math, statistics
from pathlib import Path
root=Path(__file__).resolve().parents[5];raw=root/'selfhost/build/phase68';inputs=[]
def pin(p):
 p=Path(p).resolve();r=dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest());inputs.append(r);return r
def read(p):return json.loads(Path(pin(p)['file']).read_text())
base=raw/'facts-compilation-paired23-v2';plan=read(base/'plan.json');obs=[]
for job in [j for j in plan['jobs'] if j['action']=='request']:
 f=base/'runs'/job['name']/'report.json';r=read(f)
 assert r['complete'] and r['pass'] and r['exactC'] and r['inputsUnchanged']
 assert r['plan']['sha256']==pin(base/'plan.json')['sha256']
 assert pin(r['output']['file'])['sha256']==r['output']['sha256']
 guard=read(f.parent.with_name(f.parent.name+'-guard')/'process.json');assert guard['complete'] and guard['returncode']==0
 obs.append(dict(job=job,timings=r['timings'],report=pin(f),guardWallSeconds=guard['wallSeconds']))
assert len(obs)==48
rows=[]
for c in plan['cases']:
 for stage in ['b1','b2']:
  med={v:statistics.median(x['timings']['requestMs'] for x in obs if x['job']['case']==c and x['job']['role']==v+'-'+stage) for v in ['old','new']}
  rows.append(dict(case=c,stage=stage,mediansMs=med,newOverOld=med['new']/med['old']))
paired=dict(complete=True,observations=obs,rows=rows,geomeanNewOverOld={s:math.prod(r['newOverOld'] for r in rows if r['stage']==s)**(1/3) for s in ['b1','b2']})
pairedfile=raw/'facts-paired23-summary.json';assert not pairedfile.exists();pairedfile.write_text(json.dumps(paired,indent=2)+'\n')
qualifications={}
for name,path in [('integration','facts-integration23/execution/report.json'),('raw','facts-raw-controls23/report.json'),('queries','facts-query-controls23/report.json'),('jsClosure','facts-js-closure23-replay/report.json'),('b2Driver','facts-build23-b2/driver-comparison.json')]:
 r=read(raw/path);assert r['complete'];assert r.get('pass',True)
 qualifications[name]=dict(report=pin(raw/path),complete=True,pass_=True,rows=len(r.get('rows',[])),unchangedFunctions=r.get('unchangedFunctions'),observations=r.get('observations'))
integration=read(raw/'facts-integration23/execution/selected/paired.json');assert integration['selectedComplete'] and not integration['discrepancies'];qualifications['integration']['rows']=len(integration['rows'])
runtime=read(raw/'facts-native-comparison23/report.json');assert runtime['complete'] and len(runtime['records'])==54
compiler=read(raw/'facts-compilation23-summary.json');assert compiler['complete']
sizes={}
for n in ['scalar-build20','facts-build23']:
 attempt=read(raw/n/'attempt.json');assert attempt['checked'] and attempt['config']['strictExact'];s=Path(attempt['snapshot']['root']);modules=read(s/'src/compiler.json')['modules'];lines=[l for m in modules for l in (s/m).read_text().splitlines()];sizes[n]=dict(modules=len(modules),physical=len(lines),code=sum(bool(l.strip()) and not l.lstrip().startswith('#') for l in lines))
evidence=dict(complete=True,sourceCommit='b2ec0a2',upstream='059266225b77c8ca256ac6b25ee5c21449bab151',images=read(raw/'facts-build23-b2/image-pins.json'),runtime=runtime,compilation=compiler,pairedCompilation=paired,profileAttribution=read(raw/'facts-profile-attribution23.json'),qualifications=qualifications,complexity=sizes,inputs=inputs,producer=pin(__file__),scope='Finite selected source-candidate gates; no full-language, physical GPU, full B2 self-check/B3 fixed point or installed-release claim.')
out=root/'implementation/phase68/evidence/native-facts23.json';assert not out.exists();out.write_text(json.dumps(evidence,indent=2)+'\n')
print(json.dumps(dict(pairedRows=rows,pairedRatios=paired['geomeanNewOverOld'],evidence=str(out))))
