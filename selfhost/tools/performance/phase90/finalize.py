#!/usr/bin/env python3
"""Join completed Phase90 release/native evidence without executing targets."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
RAW=ROOT/'selfhost/build/phase90'
inputs=[]
def pin(path):
    path=Path(path).resolve();h=hashlib.sha256()
    with path.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
    return dict(file=str(path.relative_to(ROOT)),sha256=h.hexdigest(),bytes=path.stat().st_size)
def read(name,complete=None,passed=None):
    p=RAW/name;record=pin(p);inputs.append(record);x=json.loads(p.read_text())
    if complete:assert x[complete] is True,name
    if passed:assert x[passed] is True,name
    return x
def checked(record):
    item=pin(record['file']);assert item['sha256']==record['sha256']
    if 'bytes' in record:assert item['bytes']==record['bytes']
    inputs.append(item);return item

attempt=read('compiler07/attempt.json',passed='checked')
pins=read('compiler07-b2/image-pins.json')
b1,b2=(checked(pins[key]) for key in ['b1','b2'])
assert b1['sha256']==attempt['api']['sha256']
selfcheck=read('qualification07/self-check/report.json','complete','pass')
fixed=read('qualification07/fixed-point/report.json','complete','pass')
assert selfcheck['freshTypeCheck'] and fixed['byteEquality']
assert checked(fixed['b3'])['sha256']==b2['sha256']
driver=read('compiler07-b2/driver-comparison.json','complete','pass')
legacy=read('release07-retry01/legacy42/checks/report.json',passed='pass')
default=read('release07-retry01/default24/report.json','complete','pass')
assert len(legacy['steps'])==42 and all(x['pass'] for x in legacy['steps'])
assert len(default['steps'])==24 and all(x['pass'] for x in default['steps'])
verify=read('release07-retry01/job-verify-after/stdout.log','complete')
assert verify['artifact']=='self-emitted-b2' and verify['api']['sha256']==b2['sha256']
release_file=ROOT/'selfhost/dist/release.json';release=json.loads(release_file.read_text());inputs.append(pin(release_file))
for record in release['files']+release['checkout']:
    actual=pin(ROOT/'selfhost'/record['path'])
    assert actual['sha256']==record['sha256'] and actual['bytes']==record['bytes'],record['path']
assert release['sourceSha256']==pins['source']['sha256']
native=read('native07-self01/report.json','complete','passed')
assert native['exactC'] and native['inputsUnchanged']
js=read('js-new-runtime02/report.json','complete')
parent=read('native06-new-runtime01/report.json','complete','passed')
cs=[checked(x['output']) for x in [parent,js,native]]
assert len({(x['sha256'],x['bytes']) for x in cs})==1
build=read('own-native07-build-guard/process.json','complete')
assert build['returncode']==0 and not build.get('stoppedFor')
image=pin(RAW/'compiler-own-native07');inputs.append(image)
selection_file=ROOT/'selfhost/tools/performance/phase90/runtime-migration01/native-admission.json'
selection=json.loads(selection_file.read_text());inputs.append(pin(selection_file))
checked(selection['admission']);admission=json.loads(Path(selection['admission']['file']).read_text())
assert admission['complete'] and admission['selfQualified'] and not admission['cPatched']
assert checked(admission['binary'])==image
qualified=read('native07-qualification01/report.json','complete','passed')
assert [len(qualified[k]) for k in ['compilerRows','negativeRows','programRows']]==[8,2,4]
cli=read('native-cli01/report.json','complete','passed');assert len(cli['rows'])==6
broad=read('broad-token45/report.json','complete','pass');assert broad['all45'] and len(broad['rows'])==45
cpp=read('runtime-cpp45/report.json','complete','pass_');assert len(cpp['rows'])==45
assert all(x['exactPreprocessed'] and x['exactInverse'] for x in cpp['rows'])
boundary=read('runtime-boundary01-results/report.json','complete');assert len(boundary['rows'])==4 and all(x['passed'] for x in boundary['rows'])
screen=read('final-screen01/report.json','complete','passed');assert len(screen['rows'])==36
size_file=ROOT/'implementation/phase90/production-size.json';size=json.loads(size_file.read_text());inputs.append(pin(size_file))
manifest=json.loads((ROOT/'selfhost/src/compiler.json').read_text())
assert len(manifest['modules'])==size['modules']==132
assert sum(len((ROOT/'selfhost'/f).read_text().splitlines()) for f in manifest['modules'])==size['physicalLines']==32692
result=dict(kind='phase90-completed-native-and-js-release',complete=True,passed=True,targetJobsRun=0,method=pin(__file__),
    installedJs=dict(b1=b1,b2=b2,source=checked(pins['source']),ownSourceCheck=True,exactB3=True,driverObservations=driver['observations'],legacyChecks=42,defaultChecks=24,releaseVerified=True),
    native=dict(binary=image,source=checked(admission['source']),c=cs[2],independentJsC=cs[1],nativeProducerC=cs[0],cPatched=False,exactSelfC=True,requestMs=native['requestMs'],selfPeakRssBytes=native['process']['peakTreeRssBytes'],buildSeconds=build['wallSeconds'],buildPeakRssBytes=build['peakTreeRssBytes'],liveCacheChecks=8,negativeChecks=2,executedPrograms=4,publicCliChecks=6),
    continuity=dict(formattingPreprocessingPoints=45,runtimePreprocessingPoints=45,runtimeBoundaryExecutions=4,newProgramSpeedCampaign=False),
    performance=dict(screenCases=6,screenRequests=36,rounds=2,ratios=screen['summary']['equalCaseGeometricRatios'],timedCampaignSeconds=screen['timedCampaignSeconds'],scope=screen['scope'],fullCompilerJsB2RequestMs=js['requestMs'],fullCompilerNativeOverJsB2=native['requestMs'][0]/js['requestMs']),
    production=dict(modules=size['modules'],physicalBendLines=size['physicalLines'],addedPhysicalBendLines=size['deltaPhysicalLines'],runtimeNetAddedLines=7),inputs=inputs,
    limitations=['Fixed C/source/runtime tuple and finite selected gates, not a compiler correctness proof or unrestricted conformance.',
      'Native public entry is canonical-path single Base-importing source, nine effects, one CPU worker; GPU/parallel hosting is unqualified.',
      'Prepared Base and worker overhead differ across measured roles; six-case two-round ratios are not broad algorithmic or installed-CLI parity.',
      'Initial legacy smoke failed under sandbox pipe capture. Identical diagnostic and unchanged guarded smoke passed outside sandbox; all records retained.',
      'The large-table threshold is conservative and arbitrary large-program dispatch overhead remains unmeasured.'])
out=ROOT/'implementation/phase90/summary.json'
with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps(dict(complete=True,summary=pin(out))))
