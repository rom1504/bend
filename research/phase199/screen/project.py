"""Conditional controlled impact projection; never a full-catalog timing claim."""
import argparse,hashlib,json,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser();p.add_argument('--measurement',type=Path,required=True);p.add_argument('--all45',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();assert not a.out.exists()
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads(Path(p).read_text())
def verify(v):
 q=pin(v['file']);assert all(q[k]==v[k] for k in ['bytes','sha256']);return q
m=read(a.measurement);assert m['complete'];prod=read(m['products']['file']);verify(m['products']);assert prod['complete']
basepath=ROOT/'selfhost/build/phase198/progress-native45-02/programs.manifest.json';base=read(basepath);original={x['id']:x for x in base['cases']};wide=read(a.all45);assert wide['complete']
for v in wide.get('inputs',[]):verify(v)
if 'cases' in wide:
 objects={x['id']:x['products']['candidate']['generatedSource'] for x in wide['cases']}
else:objects={x['id']:x['product'] for x in wide['rows']}
assert set(objects)==set(original) and len(objects)==45
focus={x['case'] for x in m['groups']};assert len(focus)==3
fail=[]
for name,obj in objects.items():
 verify(obj);expected=prod['cases'][name]['candidateObject'] if name in focus else original[name]['products']['candidate']['generatedSource'];verify(expected)
 if (obj['bytes'],obj['sha256'])!=(expected['bytes'],expected['sha256']):fail.append(name)
r=dict(complete=True,projected=False,targetsRun=False,method=pin(__file__),measurement=pin(a.measurement),all45=pin(a.all45),baseline=pin(basepath),mismatches=fail,scope='Controlled projection only: same runtime/helper link arm, unaffected cases assigned factor1. Historical work weights held fixed. Does not measure complete-suite timing or infer absent-helper/code-placement effects on unmeasured cases.')
if not fail:
 summarypath=ROOT/'research/phase198/runtime-broad/orbit-summary.json';s=read(summarypath);assert s['complete'];r['weights']=pin(summarypath);r['layouts']=[]
 eligible=[c for c in s['cases'] if c['ratioEligible']];assert len(eligible)==44
 for arm in sorted({g['arm'] for g in m['groups'] if g['arm'].startswith('live/')}):
  factors={g['case']:g['againstMatchedBaseline']['simd']['median'] for g in m['groups'] if g['arm']==arm};assert set(factors)==focus
  geo=math.exp(sum(math.log(factors.get(c['id'],1)) for c in eligible)/len(eligible))
  den=sum(c['fixedEquivalentMs']['live'] for c in eligible);num=sum(c['fixedEquivalentMs']['live']*factors.get(c['id'],1) for c in eligible)
  r['layouts'].append(dict(arm=arm,projectedGeometricFactor=geo,projectedFixedWorkFactor=num/den,measuredCaseFactors=factors,unchangedObjects=42))
 r['projected']=True
else:r['reason']='All45 exact-object precondition failed; no projected effect computed.'
a.out.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))
