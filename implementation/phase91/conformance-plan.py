#!/usr/bin/env python3
"""Bind retained references and print fresh installed-B2 conformance commands; no targets."""
import argparse,hashlib,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
from census import ROOT,PROJECT,UPSTREAM,pin,read,reference,INPUTS

def verify_report(file):
    report,identity=read(file)
    assert report['finished'] and report['changedInputs']==[]
    assert report['identity']['adapterChangedDuringRun'] is False and report['identity']['changedArtifacts']==[]
    assert report['inventory']['revision']==UPSTREAM
    assert not any(row.get('errors') for row in (report.get('workers') or []))
    for file,digest in report['inputHashes'].items():
        assert pin(file)['sha256']==digest
        assert str(Path(file).resolve())==report['inputPaths'][file]
    reference(dict(file=report['options']['adapter'],sha256=report['identity']['adapterSha256']))
    for record in report['identity']['artifacts'].values():reference(record)
    return report,identity

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();assert not args.output.exists()
    census,census_pin=read(ROOT/'implementation/phase91/census01.json')
    assert census['complete'] and census['inputsUnchanged'] and census['phase91ConformanceExecuted'] is False
    for record in census['inputs']:reference(record)
    front,front_pin=verify_report(PROJECT/'build/phase66/conformance-new-ts-full01/typescript-new/frontend/report.json')
    old_candidate,old_candidate_pin=read(PROJECT/'build/phase82/compiler04-native100/execution/selected/candidate.json')
    old_reference,old_reference_pin=verify_report(PROJECT/'build/phase82/compiler04-native100/execution/selected/reference.json')
    # Native candidate source/runtime identities are intentionally historical.
    # Its report supplies expected observed results, not admission of today's inputs.
    assert old_candidate['finished'] and old_candidate['changedInputs']==[] and old_candidate['selectedComplete']
    assert old_candidate['summary']['statuses']=={'pass':100}
    assert old_reference['summary']['statuses']=={'pass':93,'fail':7}
    harness=[]
    for name,old in front['identity']['artifacts'].items():
        if not name.startswith('harness/') or name=='harness/compilerManifest':continue
        current=pin(PROJECT/'tools/conformance'/name.removeprefix('harness/'))
        rule='exact bytes'
        if name=='harness/run.mjs':
            prior=Path(old['file']).read_text();now=Path(current['file']).read_text()
            before="path.join(project,'.bootstrap/upstream-phase23')";after="path.join(project,'.bootstrap/upstream-phase66')"
            assert prior.count(before)==1 and prior.replace(before,after)==now
            rule='Only default upstream path changed; both actual commands specify identical explicit --upstream.'
        else:assert current['sha256']==old['sha256'],name
        harness.append(dict(name=name,prior=old,current=current,rule=rule))
    selected,selection_pin=read(PROJECT/'build/phase82/compiler04-native100/selection.json')
    assert len(selected['cases'])==100 and all(row['lanes']==['native'] for row in selected['cases'])
    fixture_ids={row['id']:row for row in old_reference['inventory']['tests']}
    fixtures=[]
    for row in selected['cases']:
        fixture=pin(row['file']);assert fixture['sha256']==fixture_ids[row['id']]['sha256']
        fixtures.append(dict(id=row['id'],identity=fixture))
    node=pin('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
    clang=pin('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
    upstream=PROJECT/'.bootstrap/upstream-phase66';raw=PROJECT/'build/phase91'
    guard=pin(PROJECT/'tools/performance/phase86/guard.py');pin(PROJECT/'tools/performance/programs/support.py')
    environment=dict(BEND_UPSTREAM=str(upstream),BEND_BASE=str(upstream/'bend2/base.bend'),
        BEND_TYPED_API=str(PROJECT/'dist/typed-api.mjs'),BEND_TYPED_RUNTIME=str(PROJECT/'src/runtime.mjs'),
        BEND_TYPED_TRACE='',NODE_OPTIONS='',NODE_PATH='',CC=clang['file'],CPATH=str(Path(clang['file']).parent.parent/'include/clang'))
    jobs=[]
    for label,lanes,worker,timeout,seconds,selection,expected in [
        ('frontend01','parse,check','persistent',10000,300,None,3174),
        ('native100-01','native','isolated',120000,300,selection_pin,100)]:
        out=raw/label;assert not out.exists(),'Fresh target path required: '+str(out)
        command=[node['file'],'--stack-size=4096','--max-old-space-size=1024',str(PROJECT/'tools/conformance/run.mjs'),
            '--upstream',str(upstream),'--adapter',str(PROJECT/'tools/conformance/adapters/typed.mjs'),
            '--output',str(out/'report.json'),'--jobs','1','--timeout',str(timeout),'--worker-mode',worker,
            '--recycle-after','64','--rss-limit-mb','1536' if worker=='persistent' else '1024',
            '--stack-kb','4096','--heap-mb','1024','--lanes',lanes,'--retain','failed','--selected-exit','1']
        if selection:command.extend(['--selection',selection['file']])
        wrapped=[sys.executable,'-B',guard['file'],'--out',str(out/'guard'),'--seconds',str(seconds),
            '--rss-mib','2048','--available-mib','4096','--cpu','3','--','env',
            *[key+'='+value for key,value in environment.items()],*command]
        prior=front_pin if label=='frontend01' else old_candidate_pin
        compare=[node['file'],str(PROJECT/'tools/conformance/compare-artifacts.mjs'),prior['file'],str(out/'report.json'),str(out/'comparison.json')]
        jobs.append(dict(name=label,command=wrapped,report=str(out/'report.json'),expectedObservations=expected,
            expectedCompilerExit=1 if label=='frontend01' else 0,comparisonCommand=compare,
            comparisonScope='Historical TypeScript reference reused' if label=='frontend01' else 'Historical candidate outcomes reused; reference remains the retained 93/100 result',
            acceptance='Guard must finish without stoppedFor; require all requested unique observations, unchanged inputs/artifacts, healthy workers, matching pin/fixture bytes and comparison.sameObservedBehavior with no changes or missing rows. Frontend retains the four known shared check-oracle failures; native candidate must pass all100. Comparator exit0 alone is not acceptance.',
            historicalSeconds=194 if label=='frontend01' else 119,
            diskExpectation='About15–25 MiB frontend /5–15 MiB native with failed-only retention; estimates, not measured new bounds. Stop at160 MiB free. Do not retain100 C/ELF pairs.',
            environmentNote='Frontend does not invoke Clang; inventory Git capture is file-backed.' if label=='frontend01' else
                'Use the approved outside-sandbox environment of the successful Phase90 legacy replay. Native-build.mjs synchronous Clang pipes returned EPERM inside sandbox despite exit0; retain any error, never waive it.'))
    method=pin(__file__);pin(PROJECT/'tools/conformance/compare-artifacts.mjs');pin(PROJECT/'tools/conformance/semantic-summary.mjs')
    for record in list(INPUTS.values()):pin(record['file'])
    result=dict(kind='phase91-conformance-refresh-plan',complete=True,targetExecuted=False,method=method,census=census_pin,
        frontendReference=front_pin,nativeHistoricalCandidate=old_candidate_pin,nativeHistoricalReference=old_reference_pin,
        referenceInputsVerified=True,effectiveFrontendHarness=harness,selection=selection_pin,fixtures=fixtures,
        node=node,clang=clang,jobs=jobs,inputs=list(INPUTS.values()),inputsUnchanged=True,
        scope='One fresh installed genuine-B2 frontend census plus selected native100. Prior TypeScript observations are explicitly reused after file/harness/source binding. No fresh JS1170, full native inventory, GPU, native07-host broad execution or mathematical proof is claimed.')
    args.output.parent.mkdir(parents=True,exist_ok=True)
    with args.output.open('x') as stream:json.dump(result,stream,indent=2);stream.write('\n')
    print(json.dumps(dict(complete=True,targetExecuted=False,output=str(args.output.resolve()),jobs=len(jobs),verifiedInputs=len(INPUTS))))

if __name__=='__main__':main()
