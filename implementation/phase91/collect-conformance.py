#!/usr/bin/env python3
"""Verify completed Phase91 conformance reports without executing any target or comparator."""
import argparse,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
from census import ROOT,PROJECT,UPSTREAM,pin,read,reference,INPUTS

def stable(report):
    assert report.get('finished') and report['changedInputs']==[]
    assert report['identity']['adapterChangedDuringRun'] is False and report['identity']['changedArtifacts']==[]
    assert report['inventory']['revision']==UPSTREAM
    assert not any(row.get('errors') for row in (report.get('workers') or []))
    for file,digest in report['inputHashes'].items():
        assert pin(file)['sha256']==digest
        assert str(Path(file).resolve())==report['inputPaths'][file]
    for name,record in report['identity']['artifacts'].items():
        reference(record);assert report['identity']['finalArtifactHashes'][name]==record['sha256']
    reference(dict(file=report['options']['adapter'],sha256=report['identity']['adapterSha256']))

def rows(report,normalize=True):
    result={}
    for row in report['results']:
        key=(row['id'],row['lane']);assert key not in result
        observation=row.get('result') or {}
        value=dict(verdict=row['status'],evidence=row.get('evidence'))
        for field in ['status','phase','checked','typeAccepted','proofTrust','kernelChecked','unsafeDefinitions','exitCode']:
            value[field]=observation.get(field)
        for field in ['diagnostic','output']:
            item=observation.get(field)
            if field=='output' and item is None:item=observation.get('stdout')
            value[field]=item.replace(report['options']['upstream'],'$UPSTREAM') if normalize and isinstance(item,str) else item
        result[key]=value
    return result

def fixtures(report):
    result={}
    for row in report['inventory']['tests']:
        assert row['id'] not in result,'Duplicate fixture identity'
        result[row['id']]={field:row.get(field) for field in ['file','sha256','bytes','expected','negative','failureKind','main']}
    return result

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('plan',type=Path)
    parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    args.output.parent.mkdir(parents=True,exist_ok=True)
    result=dict(kind='phase91-fresh-conformance-collection',complete=False,passed=False,dataOnly=True,targetExecuted=False,
        method=pin(__file__),rows=[])
    with args.output.open('x') as stream:json.dump(result,stream,indent=2);stream.write('\n')
    def save():args.output.write_text(json.dumps(result,indent=2)+'\n')
    try:
        plan,plan_pin=read(args.plan);assert plan['complete'] and plan['targetExecuted'] is False
        for record in plan['inputs']:reference(record)
        census,census_pin=read(reference(plan['census'])['file'])
        release,release_pin=read(reference(census['release'])['file'])
        for row in release['checkout']+release['files']:
            actual=pin(PROJECT/row['path']);assert (actual['sha256'],actual['bytes'])==(row['sha256'],row['bytes'])
        result.update(plan=plan_pin,census=census_pin,release=release_pin,referenceMode='Historical reference retained, freshly verified source/harness/input identities; no new reference execution')
        for job in plan['jobs']:
            report,report_pin=read(job['report']);stable(report)
            guard=Path(job['report']).parent/'guard';process,process_pin=read(guard/'process.json')
            expected=job['expectedCompilerExit']
            assert process['returncode']==expected and not process.get('stoppedFor') and not process.get('interrupted')
            assert isinstance(process.get('finished'),(int,float)) and isinstance(process.get('wallSeconds'),(int,float)) and process['wallSeconds']>=0
            assert process['complete'] is (expected==0)
            argv=job['command'][job['command'].index('--')+1:]
            assert process['command'][-len(argv):]==argv
            for key in ['jobs','timeout','worker-mode','recycle-after','rss-limit-mb','stack-kb','heap-mb','lanes','retain','selected-exit']:
                expected_option=job['command'][job['command'].index('--'+key)+1]
                assert str(report['options'][key])==expected_option,(job['name'],key)
            assert report['identity']['artifacts']['compiler']['sha256']==census['images']['installedB2']['sha256']
            actual=rows(report);assert len(actual)==job['expectedObservations']
            requested={(row['id'],row['lane']) for row in report['selection']['requested']}
            assert requested==set(actual) and len(report['selection']['requested'])==len(actual)
            prior_file=job['comparisonCommand'][-3];prior,prior_pin=read(prior_file)
            assert prior['options']['upstream']==report['options']['upstream'],'Different upstream paths'
            old=rows(prior);assert set(actual)==set(old) and actual==old,'Observed semantics changed: '+job['name']
            assert rows(prior,False)==rows(report,False),'Raw observed fields changed: '+job['name']
            assert fixtures(prior)==fixtures(report),'Different fixture paths, bytes or oracles'
            comparison,comparison_pin=read(job['comparisonCommand'][-1])
            assert comparison['before']['sha256']==prior_pin['sha256'] and comparison['after']['sha256']==report_pin['sha256']
            assert comparison['sameObservedBehavior'] and comparison['changes']==[] and comparison['missing']==[]
            if job['name']=='frontend01':
                assert report['summary']['probes']==3174 and report['summary']['allTests']==1587
                assert report['summary']['lanes']=={'parse':{'observed':505,'pass':1082},'check':{'pass':1583,'fail':4}}
                failed={key for key,value in actual.items() if value['verdict']=='fail'}
                assert failed=={(name,'check') for name in ['io/cid_unknown.bend','io/effect_ctr_name.bend','io/main_foreign.bend','reg/array_open_element.bend']}
                assert all(actual[key]['phase']=='check' and actual[key]['typeAccepted'] is True for key in failed)
                assert report['complete'] is False and report['selectedComplete'] is False
            else:
                assert job['name']=='native100-01' and report['summary']['statuses']=={'pass':100}
                assert report['selectedComplete'] is True and report['complete'] is False
            result['rows'].append(dict(name=job['name'],passed=True,report=report_pin,guard=process_pin,
                guardFiles=[pin(file) for file in sorted(guard.glob('*')) if file.is_file()],comparison=comparison_pin,
                prior=prior_pin,observations=len(actual),summary=report['summary'],seconds=process['wallSeconds'],
                exactUpstreamPath=True,exactFixturePathsBytesOracles=True,rawObservedFieldsEqual=True,
                comparedFields=['verdict','evidence','status','phase','checked','typeAccepted','proofTrust','kernelChecked','unsafeDefinitions','exitCode','diagnostic','output-or-stdout']))
            save()
        prior_native,prior_pin=read(reference(plan['nativeHistoricalReference'])['file'])
        assert prior_native['summary']['statuses']=={'pass':93,'fail':7}
        result['retainedNativeReference']=dict(report=prior_pin,executedInPhase91=False,
            statuses=prior_native['summary']['statuses'],failures=[dict(id=row['id'],lane=row['lane'],status=row['status'],
                phase=(row.get('result') or {}).get('phase'),reason=row.get('reason')) for row in prior_native['results'] if row['status']=='fail'])
        for record in list(INPUTS.values()):pin(record['file'])
        result.update(complete=True,passed=True,inputsUnchanged=True,verifiedInputs=len(INPUTS),
            limits='Fresh candidate frontend3174 and selected native100 only. Historical TypeScript reference observations reused. JS1170 union remains historical; no full-language/native07-host/GPU/kernel proof or aggregate conformance percentage.')
        save();print(json.dumps(dict(complete=True,passed=True,targetExecuted=False,report=str(args.output.resolve()))))
    except Exception as error:
        result['error']=str(error);result['retainedFailure']=True;save();raise

if __name__=='__main__':main()
