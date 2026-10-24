"""Summarize frozen Phase137 evidence; never execute compiler/program targets."""
import argparse,hashlib,json,math,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[5]
p=argparse.ArgumentParser();p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args();assert not a.out.exists()
inputs=[]
def pin(p):
 p=p.resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(s):
 path=ROOT/s;r=json.loads(path.read_text());assert r['complete'],s;inputs.append(pin(path));return r
def ratios(r,a,b):return {w:vs[a]['clean']['wallSeconds']['median']/vs[b]['clean']['wallSeconds']['median'] for w,vs in r['summary'].items()}
def gm(v):return math.exp(sum(map(math.log,v))/len(v))
q=read('selfhost/build/phase137/native-qualification01.json');kern=read('selfhost/build/phase137/query-timing03/report.json');small=read('selfhost/build/phase137/generations-fast01/report.json');ap=read('selfhost/build/phase137/A-program-speed01/report.json');wrap=read('selfhost/build/phase137/n3-wrappers01/report.json');up=read('selfhost/build/phase112/p137-final-timing01/report.json')
sm=read('selfhost/build/phase137/integrated-source03/manifest.json')
cold=[read('selfhost/build/phase134/p137-cold-'+role+'01/report.json')for role in ['parent','candidate']]
assert cold[0]['source']==cold[1]['source'] and cold[0]['runtime']==cold[1]['runtime']
requests=[read('selfhost/build/phase130/'+name+'/report.json')for name in ['p137-acquire01','p137-self01','p137-reproduce01']]
assert requests[1]['source']==requests[2]['source'] and requests[1]['product']['sha256']==requests[2]['product']['sha256']
assert len(wrap['rows'])==45 and all(r['correct']for r in wrap['rows'])
guards=[]
for path in sorted((ROOT/'selfhost/build/phase137').glob('*-guard*/process.json')):
 r=json.loads(path.read_text());assert r['complete'];guards.append(dict(name=path.parent.name,seconds=r['wallSeconds'],success=r['returncode']==0,peakBytes=r['peakTreeRssBytes']));inputs.append(pin(path))
r=dict(complete=True,targetsRun=False,source=sm['source'],qualification=pin(ROOT/'selfhost/build/phase137/native-qualification01.json'),
 kernelTimeRatios=ratios(kern,'retain-wide-fused-v02','narrow-original'),
 coldPipeline=dict(source=cold[0]['source'],seconds=[x['wallSeconds']for x in cold],ratio=cold[1]['wallSeconds']/cold[0]['wallSeconds'],samplesPerRole=1,irBytes=[x['irDigest']['bytes']for x in cold],irRatio=cold[1]['irDigest']['bytes']/cold[0]['irDigest']['bytes'],clock='Complete native source-to-executable pipeline, same fixed source, prepared Base and runtime; no reused semantic/object result. OS page caches were not flushed.'),
 sameSourceGeneration=dict(nativeSeconds=[x['nativeSeconds']for x in requests],n2OverN1=requests[2]['nativeSeconds']/requests[1]['nativeSeconds'],samplesPerRole=1,byteExactReproduction=True),
 smallRequests=dict(n2OverParent=gm(list(ratios(small,'n2','qualified').values())),n2OverN1=gm(list(ratios(small,'n2','n1').values())),rows=27,rounds=3,sourceAndCodeChangedVersusParent=True),
 unmodifiedCompilerProgram=dict(perCase=ratios(ap,'candidate-A','parent-A'),geomean=gm(list(ratios(ap,'candidate-A','parent-A').values())),rows=27,rounds=3,sameSource=cold[0]['source'],scope='Generated execution of unchanged compiler A on three small compilation requests; not the full language benchmark.'),
 upstream=up['summary']['cache']['threeCaseGeometricRatios'],programCodePreservation=dict(exactQbeWrappers=45,changed=0,freshBroadRuntimeTiming=False),
 correctness=dict(finiteControls=q['sourceContract']['finiteCount'],nativeQbeFixedPoint=q['reproducedQbe'],focusedGenerations=['N2','N3'],focusedCasesEach=19,ordinaryPrograms=45,installedChanged=False),
 complexity=dict(parentLines=sm['qualifiedLines'],candidateLines=sm['physicalLines'],addedLines=sm['physicalLines']-sm['qualifiedLines'],addedSourceBytes=sm['source']['bytes']-sm['qualified']['bytes'],changedExistingDefinitions=len(sm['allChangesFromQualified']),unchangedProofDeclarations=len(sm['unchangedProofDeclarations'])),
 targetCost=dict(guardCount=len(guards),guardSeconds=sum(x['seconds']for x in guards),maximumTreeRssBytes=max(x['peakBytes']for x in guards),guards=guards,scope='Serial target guards; excludes agent reasoning, read-only metadata work, rejected CLI syntax before target launch and commit/push. This is not billing/token/quota accounting.'),inputs=[pin(pathlib.Path(__file__)),*inputs])
a.out.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({k:r[k]for k in ['kernelTimeRatios','coldPipeline','smallRequests','upstream','complexity']}))
