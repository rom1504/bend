#!/usr/bin/env python3
"""Offline audit of native69 oracles, provenance and recorded complete-C hashes."""
import argparse,hashlib,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
from prepare import pin,read,write

def tidy(text):return re.sub(r'[ \t]+$','',text,flags=re.M).strip()
def sha(data):return hashlib.sha256(data).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plan',type=Path,required=True);parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args();assert not args.out.exists();plan=read(args.plan);directory=args.plan.resolve().parent
    for item in plan['inputs']:assert pin(item['file'])==item
    prior=read(plan['reference']['file']);old={x['id']:x for x in prior['results'] if x['lane']=='native'}
    fixtures={x['id']:x for x in plan['eligible']};assert len(fixtures)==69
    roles={};products={}
    for role in ['b1','b2']:
        report_path=directory/role/'report.json';guard_path=directory/(role+'-guard')/'process.json'
        report=read(report_path);guard=read(guard_path)
        assert report['selectedComplete'] and report['finished'] and report['summary']['statuses']=={'pass':69}
        assert not report['changedInputs'] and not report['identity']['adapterChangedDuringRun'] and not report['identity']['changedArtifacts']
        assert report['identity']['adapter']=='phase92-native-host-'+role
        assert report['identity']['artifacts']['plan']['sha256']==pin(args.plan)['sha256']
        assert guard['complete'] and guard['returncode']==0 and not guard.get('stoppedFor')
        assert len(report['results'])==69 and {r['id'] for r in report['results']}==set(fixtures)
        exits={};codes={};evidence=[]
        for row in report['results']:
            identity=row['id'];result=row['result'];fixture=fixtures[identity]
            assert row['status']=='pass' and row['evidence']=='checked-execution'
            output=tidy(result['output']);code=result['exitCode'];exits[str(code)]=exits.get(str(code),0)+1
            if code and not re.search(r'(?:^|\n)exit '+str(code)+r'$',output):output=tidy(output+'\nexit '+str(code))
            assert output==fixture['expected'],identity
            fields=['status','phase','checked','typeAccepted','exitCode','stdout','stderr','output']
            assert all(result.get(k)==old[identity]['result'].get(k) for k in fields),identity
            emission=result['nativeHost'];assert emission['role']==role and emission['source']==fixture['source']
            assert emission['job']['status']==0 and not emission['job']['error'] and not emission['job']['signal'] and not emission['outputAbsent']
            argv=emission['job']['command'];prefix=next(x for x in argv if x.endswith('/compiler-output'))
            expected=[fixture['source']['file'] if x==plan['sourceMarker'] else prefix if x==plan['outputMarker'] else x for x in plan['roles'][role]['argv']]
            assert expected==argv,identity
            c=emission['output'];assert c['bytes']>0 and re.fullmatch('[a-f0-9]{64}',c['sha256'])
            build=result['build'];assert build['command'][0]==plan['clang']['file'] and build['command'][1:5]==plan['clangArgs']
            assert build['command'][5]==c['file'] and build['status']==0 and not build['error'] and not build['signal']
            assert result['run']['command']==[result['nativeBuild']['executable']['file'],'--threads','1','--gpu','off']
            for job in [emission['job'],build,result['run']]:
                assert not job['error'] and not job['signal'] and not job['oversized']
                for capture in job['captures']:
                    stream='stderr' if capture['file'].endswith('.stderr') else 'stdout'
                    data=job[stream].encode();assert len(data)==capture['bytes'] and sha(data)==capture['sha256']
            codes[identity]=c
            evidence.append(dict(id=identity,originalGolden=True,exactHistoricalObservedFields=True,
                exitCode=code,completeC=c,compiledAndExecuted=True,rawCaptureHashesVerified=True))
        roles[role]=dict(report=pin(report_path),guard=pin(guard_path),producer=plan['roles'][role]['producer'],
            originalGoldenPasses=69,historicalRuntimeMatches=69,programExits=exits,
            completeCBytes=sum(c['bytes'] for c in codes.values()),observations=evidence)
        products[role]=codes
    comparisons=[dict(id=identity,b1=products['b1'][identity],b2=products['b2'][identity],
        sameRecordedCompleteCHash=(products['b1'][identity]['sha256'],products['b1'][identity]['bytes'])==
          (products['b2'][identity]['sha256'],products['b2'][identity]['bytes'])) for identity in fixtures]
    for item in plan['inputs']:assert pin(item['file'])==item
    matches=sum(x['sameRecordedCompleteCHash'] for x in comparisons)
    result=dict(kind='phase92-native69-offline-product-audit',complete=True,passed=matches==69,
        targetExecuted=False,method=pin(__file__),plan=pin(args.plan),roles=roles,products=comparisons,
        crossRoleRecordedCompleteCHashMatches=matches,productsCompared=69,inputsReverified=len(plan['inputs']),
        sourceUnchanged=True,exclusions=31,
        scope='Actual original golden executions and matching observed fields verified from frozen reports. C SHA256 and length concordance only: successful raw C/ELF were ephemeral under retain-failed. No reread bytewise C comparison, fresh speed measurement, native100/frontend/JS/parallel/GPU claim.')
    args.out.parent.mkdir(parents=True,exist_ok=True);write(args.out,result)
    print(json.dumps(dict(complete=True,passed=result['passed'],matches=matches,out=str(args.out))))
    if not result['passed']:sys.exit(1)

if __name__=='__main__':main()
