#!/usr/bin/env python3
"""Read-only Phase90 release census and historical continuity audit; no target execution."""
import argparse,collections,hashlib,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2]
PROJECT=ROOT/'selfhost'
UPSTREAM='059266225b77c8ca256ac6b25ee5c21449bab151'
INPUTS={}

def pin(file):
    file=Path(file).resolve();digest=hashlib.sha256()
    with file.open('rb') as stream:
        for data in iter(lambda:stream.read(1024*1024),b''):digest.update(data)
    row=dict(file=str(file),sha256=digest.hexdigest(),bytes=file.stat().st_size)
    prior=INPUTS.setdefault(str(file),row);assert row==prior,'Input changed: '+str(file)
    return row

def reference(row):
    actual=pin(row['file']);assert actual['sha256']==row['sha256']
    if 'bytes' in row:assert actual['bytes']==row['bytes']
    return actual

def read(file):
    identity=pin(file);return json.loads(Path(identity['file']).read_text()),identity

def metrics(file,bend=False):
    identity=pin(file);lines=Path(file).read_text().splitlines()
    result=dict(physicalLines=len(lines),utf8Bytes=identity['bytes'])
    if bend:
        result['codeLines']=sum(bool(s.strip()) and not s.lstrip().startswith('#') for s in lines)
        for key,pattern in [('definitions',r'^def\s'),('laws',r'^law\s'),('types',r'^type\s')]:
            result[key]=sum(bool(re.match(pattern,s)) for s in lines)
    return dict(identity=identity,metrics=result)

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();assert not args.output.exists(),'Fresh census output required'
    release,release_pin=read(PROJECT/'dist/release.json')
    attempt,attempt_pin=read(PROJECT/'build/phase90/compiler07/attempt.json')
    image_pins,image_pin=read(PROJECT/'build/phase90/compiler07-b2/image-pins.json')
    assert release['artifact']=='self-emitted-b2' and attempt['checked'] and attempt['config']['strictExact']
    assert release['lineage']['upstreamRevision']==UPSTREAM
    assert release['lineage']['selfEmittedSha256']=='284f6e9b88614c4cbd60812a7641fb03d9b9c49892c9bb0d692b1b2c31b5bd30'
    assert reference(image_pins['attempt'])==attempt_pin
    snapshot=Path(attempt['snapshot']['root']);manifest,manifest_pin=read(PROJECT/'src/compiler.json')
    assert manifest['upstream']==UPSTREAM and pin(snapshot/'src/compiler.json')['sha256']==manifest_pin['sha256']
    names=[name for name in manifest['modules'] if name.endswith('.bend')]
    assert len(names)==len(set(names)) and len(names)==132
    checkout={row['path']:row for row in release['checkout']};modules={};total=collections.Counter()
    for name in names:
        file=(PROJECT/name).resolve();assert file.is_relative_to(PROJECT)
        row=metrics(file,True);frozen=pin(snapshot/name);installed=checkout[name]
        assert row['identity']['sha256']==frozen['sha256']==installed['sha256']
        assert row['identity']['bytes']==frozen['bytes']==installed['bytes']
        row['checkedSnapshot']=frozen;modules[name]=row;total.update(row['metrics'])
    release_files=[]
    for row in release['files']:
        actual=pin(PROJECT/row['path']);assert (actual['sha256'],actual['bytes'])==(row['sha256'],row['bytes'])
        release_files.append(actual)
    images=dict(rawCheckedB1=reference(attempt['checkedApi']),selectedB1=reference(attempt['api']),
        genuineB2=reference(image_pins['b2']),installedB2=pin(PROJECT/'dist/typed-api.mjs'))
    assert images['selectedB1']==reference(image_pins['b1'])
    assert images['installedB2']['sha256']==images['genuineB2']['sha256']==release['lineage']['selfEmittedSha256']
    emission,emission_pin=read(reference(image_pins['emission'])['file'])
    assert emission['complete'] and emission['pass'] and reference(emission['module'])==images['genuineB2']
    pointer,pointer_pin=read(PROJECT/'tools/performance/phase90/runtime-migration01/native-admission.json')
    native,native_pin=read(reference(pointer['admission'])['file'])
    assert native['complete'] and native['selfQualified'] and not native['cPatched']
    images['native07']=reference(native['binary']);native_source=reference(native['source'])
    groups={
        'fourEstablishedHostHelpers':['tools/typed-driver.mjs','tools/base-cache-graph.mjs','tools/development/workflow.mjs','tools/development/release.mjs'],
        'ordinaryJSFragmentsAndDirect':['src/runtime/js/'+name+'.mjs' for name in ['core','base','effects','readback','foreign','direct']],
        'nativeRuntime':['src/runtime/native/runtime.c'],
        'jsEffects':[str(p.relative_to(PROJECT)) for p in sorted((PROJECT/'src/runtime/js/effs').glob('*.js'))],
        'nativeEffects':[str(p.relative_to(PROJECT)) for p in sorted((PROJECT/'src/runtime/native/effs').glob('*.c'))],
        'publicNativeLauncher':['tools/performance/phase90/runtime-migration01/native.py']}
    support={}
    for label,files in groups.items():
        rows={name:metrics(PROJECT/name) for name in files};counts=collections.Counter()
        for row in rows.values():counts.update(row['metrics'])
        support[label]=dict(files=len(rows),totals=dict(counts),rows=rows)
    old82,old82_pin=read(PROJECT/'build/phase82/compiler04/attempt.json')
    old82_modules={str(Path(row['original']['file']).relative_to(PROJECT)):row['original']['sha256']
        for row in old82['snapshot']['sources'] if row['original']['file'].endswith('.bend')}
    old66,old66_pin=read(ROOT/'implementation/phase66/evidence/simplicity-final07.json')
    old66_modules={name:row['identity']['sha256'] for name,row in old66['candidate']['modules'].items()}
    continuity={}
    for label,prior in [('phase66',old66_modules),('phase82',old82_modules)]:
        same=[name for name,row in modules.items() if row['identity']['sha256']==prior.get(name)]
        changed=[name for name,row in modules.items() if name in prior and row['identity']['sha256']!=prior[name]]
        added=[name for name in names if name not in prior]
        continuity[label]=dict(unchanged=same,changed=changed,added=added,
            allChangesNativeOnly=all(name.startswith('src/back/native/') for name in changed+added),
            limitation='Source identity only. Does not rerun tests or prove unchanged whole compiler/image execution.')
    prior_front,prior_front_pin=read(ROOT/'implementation/phase66/evidence/conformance-front-paired03.json')
    prior_js,prior_js_pin=read(ROOT/'implementation/phase66/evidence/conformance-final07.json')
    prior_native,prior_native_pin=read(PROJECT/'build/phase82/native100-inventory04.json')
    phase90,phase90_pin=read(ROOT/'implementation/phase90/summary.json')
    front_runs=[{key:row[key] for key in ['name','rows','exactLanes','typeAcceptance','failures']}
        for row in prior_front['runs'] if row['name'] in ['typescript-new-frontend','bend-candidate-new-base-frontend']]
    historical=dict(frontend=dict(receipt=prior_front_pin,phase=66,observations=3174,fixtureCount=1587,runs=front_runs),
        directJS=dict(receipt=prior_js_pin,phase=66,primaryNode=prior_js['primaryNode'],mixedRuntimeCoverage=prior_js['mixedRuntimeCoverage'],
            referencePassingCandidateFailures=prior_js['referencePassingCandidateFailures']),native100=dict(receipt=prior_native_pin,phase=82,summary=prior_native),
        scope='Historical observations only. No Phase91 target is executed by this census; no combined conformance percentage is meaningful.')
    method=pin(__file__)
    result=dict(kind='phase91-current-release-census',complete=True,dataOnly=True,targetJobsRun=0,method=method,
        rules=dict(bend='Manifest-only .bend; UTF-8 splitlines; code excludes blank and first-nonspace # lines; declarations use line-start def/law/type followed by whitespace.',
            support='Separate physical-line and UTF-8-byte groups; generated ordinary runtime and images are not added to maintained source totals.',
            concepts='Declarations are proxies, not semantic concepts. No numeric concept total or reduction is claimed.'),
        release=release_pin,checkedAttempt=attempt_pin,imagePins=image_pin,emission=emission_pin,manifest=manifest_pin,
        upstream=UPSTREAM,moduleCount=len(names),bendTotals=dict(total),modules=modules,images=images,support=support,
        native=dict(selection=pointer_pin,admission=native_pin,source=native_source,declaredC=native['c'],
            scope='Native image/source freshly hashed; C identity is retained admission metadata, not a new C comparison.'),
        continuity=continuity,priorSourceReceipts=[old66_pin,old82_pin],historicalConformance=historical,
        freshPhase90Evidence=phase90_pin,phase91ConformanceExecuted=False,
        boundaries='All active Bend modules match checked compiler07 and installed release.checkout; all installed release files are rehashed. Historical semantic evidence is not promoted by source hashes alone.')
    for row in list(INPUTS.values()):pin(row['file'])
    result['inputs']=list(INPUTS.values());result['inputsUnchanged']=True
    args.output.parent.mkdir(parents=True,exist_ok=True)
    with args.output.open('x') as stream:json.dump(result,stream,indent=2);stream.write('\n')
    print(json.dumps(dict(complete=True,targetJobsRun=0,output=str(args.output.resolve()),modules=len(names),bendTotals=dict(total),verifiedInputs=len(INPUTS))))

if __name__=='__main__':main()
