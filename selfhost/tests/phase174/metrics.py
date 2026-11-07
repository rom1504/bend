#!/usr/bin/env python3
"""Summarize completed release observations with explicit unchanged-workload checks."""
import json,sys,hashlib
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3];sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,same_bytes,write_json
P=ROOT/'selfhost/build/phase174';inputs=[pin(__file__)]
def read(name):
 p=P/name;inputs.append(pin(p));j=json.loads(p.read_text());require(j.get('complete') is True and not j.get('error') and not j.get('changedInputs'),'Incomplete evidence: '+name);return j
identity=lambda x:{k:x[k] for k in ['bytes','sha256']}
a=read('fixed-baseline/report.json');b=read('fixed-candidate/report.json');n=read('native-n2/report.json');q=read('q3/report.json');install=read('install/report.json')
require(a['comparedToReference'] and b['comparedToReference'],'Complete QBE comparisons required')
for k in ['runtime','toolchain','irDigest']:require(a[k]==b[k],'Different machine boundary: '+k)
for k in ['source','base','carrier','stamp']:require(a['request'][k]==b['request'][k],'Different request boundary: '+k)
for k in ['source','base','carrier']:verify(a['request'][k]);inputs.append(a['request'][k])
for k in ['assembly','object']:
 require(identity(a[k])==identity(b[k]) and same_bytes(a[k]['file'],b[k]['file']),'Different complete '+k)
 inputs.extend([a[k],b[k]])
# The old installed pathname was intentionally replaced after its measurement.
# Its exact pre-publication executable survives in the installation rollback.
backup=pin(install['backups']['selfhost/dist/qbe/bend']);inputs.append(backup)
require(identity(backup)==identity(a['request']['image']),'Old measured image not preserved')
verify(b['request']['image']);inputs.append(b['request']['image'])
checks={}
for name in ['controls','qbe64','qbe-hosted','timed-products','js-b2-retry','js-b3','js45','js-public','js-negative','js-c-focused','public-controls','c45','native-session-bootstrap','native-session-normal','session-hosted']:
 j=read(name+'/report.json');checks[name]={k:j[k] for k in ['complete','passed','qualified','counts','total','expectedCount','freshSelfCheck','typeAccepted','byteEquality','seconds'] if k in j}
public=read('public-products.json');require(public['allExact'] and public['counts']=={'js':45,'c':45},'Public products changed')
source=Path(n['imageBinding']['sourceIdentity']['file']).read_bytes();old=Path(a['request']['source']['file']).read_bytes()
r=dict(kind='phase174-published-compiler-metrics',version=1,complete=True,installed=True,
 canonicalSource=n['imageBinding']['sourceIdentity'],sourceGrowth=dict(originalBytes=len(old),currentBytes=len(source),originalPhysicalLines=len(old.splitlines()),currentPhysicalLines=len(source.splitlines()),changedDefinitions=16,newDeclarations=28,protectedDeclarationsUnchanged=112),
 fixedInput=dict(source=a['request']['source'],baselineImage=a['request']['image'],baselinePreservedAt=backup,candidateImage=b['request']['image'],baselineSeconds=a['wallSeconds'],candidateSeconds=b['wallSeconds'],ratio=b['wallSeconds']/a['wallSeconds'],reductionPercent=100*(1-b['wallSeconds']/a['wallSeconds']),qbe=a['irDigest'],qbeAssemblyObjectExact=True,order=['candidate','baseline'],observationsEach=1,preparation='cache',cpu=3,filesystemCachesFlushed=False,scope='Fresh-process same-source source-to-executable native.py wall time; compiler/QBE overlap, assembly/link included. Source checking and prepared-Base acquisition separate; no new upstream comparison.'),
 currentSourceSelfBuild=dict(seconds=n['wallSeconds'],emitAndQbeSeconds=n['emitAndQbeSeconds'],source=n['imageBinding']['sourceIdentity'],scope='Actual historical N1 builds fresh N2 from the integrated canonical source; a different input from fixedInput.'),q3=dict(totalSeconds=q['totalSeconds'],nativeSeconds=q['nativeSeconds'],byteExact=q['byteExact'],scope='Actual N2 emission-only request; excludes QBE/assembly/link.'),
 historicalPhase171=dict(baselineSeconds=188.619676,candidateSeconds=180.677191,scope='Earlier single-observation pair on the same original source; retained separately, not combined into a new mean.'),
 checks=checks,generatedPrograms=dict(ordinaryQbeExact=45,timedQbeExact=45,jsExact=45,cExact=45,newRuntimeBenchmark=False),inputs=inputs)
write_json(ROOT/'implementation/phase174/metrics.json',r)
print(json.dumps({'complete':True,'fixedInput':r['fixedInput'],'selfBuildSeconds':n['wallSeconds']},indent=2))
