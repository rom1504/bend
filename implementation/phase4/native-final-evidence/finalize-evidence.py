from pathlib import Path
import json, hashlib, gzip, statistics, datetime
R=Path('/home/ai/bend2/build/publish/bend'); P=R/'selfhost'; D=P/'build/phase4/native-final'; E=R/'implementation/phase4/native-final-evidence'
def digest(b): return hashlib.sha256(b).hexdigest()
def sha(p): return digest(Path(p).read_bytes())
def load(p): return json.loads(Path(p).read_text())
def write(p,j): Path(p).write_text(json.dumps(j,indent=2)+'\n')
proofpath=P/'build/phase4/combined-fixedpoint/report.json'; proof=load(proofpath); pair=load(D/'paired/report.json'); gate=load(D/'fullsource-gate/report.json')
assert proof['complete'] and len(proof['stages'])==2 and pair['complete'] and gate['complete']
assert pair['changedInputs']==[] and gate['changedInputs']==[]
for file,expected in pair['identity'].items():
 p=Path(file); p=p if p.is_absolute() else R/p
 assert sha(p)==expected,(p,expected)
for identity in [proof['sourceIdentity'],proof['base'],proof['initialCompiler'],proof['driver']]+proof['hostHelpers']:
 assert sha(identity['file'])==identity['sha256']
assert sha(pair['config']['runtime'])==proof['runtimeSha256']
output=Path(proof['stages'][0]['output']).read_bytes(); expected=digest(output)
for stage in proof['stages']:
 assert stage['code']==0 and stage['signal'] is None and stage['inputsVerified']
 assert stage['outputSha256']==expected and Path(stage['output']).read_bytes()==output
native=[]
for row in gate['rows']+pair['rows']:
 result=row['result']; assert result['checked'] and result['status']==0 and result['published']
 assert result['main']==proof['sourceIdentity']['canonicalPath']
 assert result['runtime']['sha256']==proof['runtimeSha256']
 assert any(m['name']=='Base' and m['path']==proof['base']['canonicalPath'] and m['sha256']==proof['base']['sha256'] for m in result['modules'])
 assert Path(result['output']).read_bytes()==output
 native.append({'output':result['output'],'sha256':expected,'bytes':len(output),'compileMs':result['compileMs'],'processWallMs':row['compilationProcessWallMs']})
assert not (D/'completed-proof-snapshot.json').exists()
(D/'completed-proof-snapshot.json').write_bytes(proofpath.read_bytes())
companion={'kind':'phase4-native-completed-fixedpoint-equality','checkedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'complete':True,'completedProof':{'file':str(proofpath),'sha256':sha(proofpath),'snapshot':str(D/'completed-proof-snapshot.json')},'source':proof['sourceIdentity'],'base':proof['base'],'runtimeSha256':proof['runtimeSha256'],'stages':proof['stages'],'nativeOutputs':native,'exactBytesAllOutputs':True,'benchmarkConsumedInputsUnchanged':True,'scope':'Completed JavaScript self-hosting fixed point and seven native-compiler JavaScript emissions have identical bytes for the same source, canonical Base and runtime. This is not a native-code fixed point. Original incomplete proof snapshot and failed orchestration report remain unchanged.'}
write(D/'completed-proof-equality.json',companion)
rows=[]
for i in range(3):
 old=next(r for r in pair['rows'] if r['round']==i and r['variant']=='phase3'); new=next(r for r in pair['rows'] if r['round']==i and r['variant']=='phase4')
 a=old['result']['compileMs'];b=new['result']['compileMs']; rows.append({'round':i,'order':['phase3','phase4'] if i%2==0 else ['phase4','phase3'],'oldCompileMs':a,'newCompileMs':b,'oldProcessWallMs':old['compilationProcessWallMs'],'newProcessWallMs':new['compilationProcessWallMs'],'reductionPercent':100*(1-b/a)})
old=[r['oldCompileMs'] for r in rows];new=[r['newCompileMs'] for r in rows]
summary={'kind':'phase4-native-same-source-summary','complete':True,'sourceSha256':proof['sourceSha256'],'outputSha256':expected,'outputBytes':len(output),'cpu':3,'pairs':rows,'oldMedianMs':statistics.median(old),'newMedianMs':statistics.median(new),'medianReductionPercent':100*(1-statistics.median(new)/statistics.median(old)),'oldMeanMs':statistics.mean(old),'newMeanMs':statistics.mean(new),'meanReductionPercent':100*(1-statistics.mean(new)/statistics.mean(old)),'changedInputs':[],'limitation':'CPU affinity is not host isolation. The third old-control sample is appreciably faster. All samples are retained; this is compiler-throughput evidence, not generated-program runtime evidence. Build costs are separate.'}
write(D/'paired-summary.json',summary)
manifest=load(E/'archive-manifest.json')
add=[(D/'paired-config.json','paired-config.json'),(D/'paired/report.json','paired/report.json'),(D/'paired-summary.json','paired-summary.json'),(D/'completed-proof-snapshot.json','completed-proof-snapshot.json'),(D/'completed-proof-equality.json','completed-proof-equality.json'),(P/'tools/performance/phase4/native-opt-measure.mjs','host/tools/performance/phase4/native-opt-measure.mjs'),(P/'build/phase3/native-o2/compiler-o2.build.json','old/compiler-o2.build.json'),(P/'build/phase3/native-final/checked/native-build-report.json','old/native-build-report.json'),(Path('/tmp/native-final-archive.py'),'finalize-evidence.py')]
for source,target in add:
 data=source.read_bytes(); target=target+('.gz' if len(data)>20000 else ''); archive=E/target; assert not archive.exists(),archive
 archive.parent.mkdir(parents=True,exist_ok=True); encoded=gzip.compress(data,mtime=0) if target.endswith('.gz') else data; archive.write_bytes(encoded)
 manifest.append({'source':str(source),'sha256':digest(data),'bytes':len(data),'archive':target,'archiveSha256':digest(encoded)})
write(E/'archive-manifest.json',manifest)
for m in manifest:
 data=(E/m['archive']).read_bytes(); assert digest(data)==m['archiveSha256']
 if m['archive'].endswith('.gz'): data=gzip.decompress(data)
 assert len(data)==m['bytes'] and digest(data)==m['sha256']
print(json.dumps(summary,indent=2));print('All',len(manifest),'archive entries verified; all proof and native output bytes equal.')
