#!/usr/bin/env python3
"""One native07 qualification pass: eight C checks, two rejections, four built/executed programs."""
import argparse,json,re,subprocess,sys
from pathlib import Path
sys.dont_write_bytecode=True
from support import ROOT,P,args,read,pin,verify
from image_support_v2 import authenticate_unqualified,exact
GUARD=P/'phase86/guard.py'
CLANG=Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
INCLUDE=CLANG.parent.parent/'include/clang'

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for key in ['image','build','controls','out']:p.add_argument(key,type=Path)
    p.add_argument('--check-only',action='store_true');a=p.parse_args()
    out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase90');out.mkdir(parents=True,exist_ok=False)
    report=dict(kind='phase90-native07-semantic-qualification',complete=False,passed=False,executionPerformed=False,
        checkOnly=a.check_only,method=pin(__file__),compilerRows=[],negativeRows=[],programRows=[],
        scope='Eight exact runtime-derived C controls, two expected compiler rejections and four actual C program builds/executions. Full-source native self equality is a separate required admission gate.')
    def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    save()
    try:
        auth,provenance=authenticate_unqualified(a.image,a.build)
        controls_pin=pin(a.controls);controls=read(a.controls)
        assert controls['kind']=='phase90-runtime-migrated-semantic-control-plan' and controls['complete'] and not controls['executionPerformed']
        assert controls['transport']==provenance['transport'] and controls['transition']==provenance['transition']
        assert [x['name'] for x in controls['cases']]==['small','map_closed','unicode','file-io']
        assert [x['expectedError'] for x in controls['negatives']]==['parse','check']
        inputs=[pin(__file__),pin(Path(__file__).with_name('image_support_v2.py')),pin(Path(__file__).with_name('support.py')),
                pin(GUARD),pin(P/'programs/support.py'),pin(CLANG),controls_pin,provenance['build']]
        for case in controls['cases']:
            inputs.extend([verify(case['source']),verify(case['oracle']),verify(case['parentC'])])
            if 'input' in case['execute']:inputs.append(verify(case['execute']['input']))
        for case in controls['negatives']:inputs.append(verify(case['source']))
        report.update(authentication=auth,build=provenance['build'],controls=controls_pin,inputs=inputs)
        save()
        if a.check_only:report.update(complete=True,passed=True);save();return
        def guarded(name,argv,seconds):
            directory=out/(name+'-guard')
            command=[sys.executable,'-B',str(GUARD),'--out',str(directory),'--seconds',str(seconds),
                '--rss-mib','2048','--available-mib','4096','--cpu','3','--',*map(str,argv)]
            report['current']=name;report['executionPerformed']=True;save()
            r=subprocess.run(command,capture_output=True,text=True)
            process=read(directory/'process.json') if (directory/'process.json').exists() else {}
            stdout=(directory/'stdout.log').read_text() if (directory/'stdout.log').exists() else ''
            stderr=(directory/'stderr.log').read_text() if (directory/'stderr.log').exists() else ''
            return dict(name=name,command=command,guard=str(directory),guardReturncode=r.returncode,guardStdout=r.stdout,
                guardStderr=r.stderr,process=process,stdout=stdout,stderr=stderr,
                receipts=[pin(f) for f in sorted(directory.glob('*')) if f.is_file()])
        def clean(row,code=0):
            process=row['process']
            if process.get('returncode')!=code or process.get('stoppedFor'):return False
            if code==0:return process.get('complete') is True
            assert code==1
            return process.get('complete') is False and isinstance(process.get('finished'),(int,float)) and isinstance(process.get('wallSeconds'),(int,float)) and process['wallSeconds']>=0
        outputs={}
        for mode in ['live','cached']:
            producer=dict(auth,cache=None) if mode=='live' else auth
            for case in controls['cases']:
                name=mode+'-'+case['name'];prefix=out/name
                row=guarded(name,args(producer,case['source']['file'],prefix,1),90)
                target=Path(str(prefix)+'.1.c');row.update(source=case['source'],oracle=case['oracle'],mode=mode)
                row['output']=pin(target) if target.exists() else None
                row['exactC']=bool(row['output'] and exact(row['output'],case['oracle']))
                row['passed']=bool(clean(row) and row['guardReturncode']==0 and row['exactC'])
                report['compilerRows'].append(row);save();assert row['passed'],name
                if mode=='cached':outputs[case['name']]=row['output']
        for case in controls['negatives']:
            prefix=out/case['name'];row=guarded(case['name'],args(auth,case['source']['file'],prefix,1),60)
            row.update(source=case['source'],expectedError=case['expectedError'],outputAbsent=not Path(str(prefix)+'.1.c').exists())
            row['passed']=bool(clean(row,1) and row['guardReturncode']==1 and row['outputAbsent'] and case['expectedError']+':' in row['stderr'])
            report['negativeRows'].append(row);save();assert row['passed'],case['name']
        for case in controls['cases']:
            name=case['name'];binary=out/(name+'-program');code=outputs[name]
            build=guarded(name+'-clang',[CLANG,'-isystem',INCLUDE,'-O2',code['file'],'-o',binary,'-lm','-pthread'],90)
            row=dict(name=name,source=case['source'],c=code,build=build,passed=False);report['programRows'].append(row);save()
            assert clean(build) and build['guardReturncode']==0,name+' build'
            row['binary']=pin(binary);expected=case['execute'];payload=[]
            if 'payload' in expected:
                copy=out/(name+'.copy');payload=[str(copy) if x=='OUTPUT_COPY' else x for x in expected['payload']]
            run=guarded(name+'-execute',[binary,'--threads','1','--gpu','off',*(['--',*payload] if payload else [])],30)
            row.update(run=run,expected=expected)
            passed=clean(run,expected['exitCode']) and run['guardReturncode']==0 and run['stdout']==expected['stdout'] and run['stderr']==expected['stderr']
            if 'outputSha256' in expected:
                row['copiedFile']=pin(copy) if copy.exists() else None
                passed=passed and row['copiedFile'] and row['copiedFile']['sha256']==expected['outputSha256']
            row['passed']=bool(passed);save();assert row['passed'],name+' execution'
        for record in inputs:verify(record)
        current,_=authenticate_unqualified(a.image,a.build);assert current==auth
        report.pop('current',None);report.update(complete=True,passed=True,inputsUnchanged=True,liveQualified=True,cachedQualified=True);save()
    except Exception as error:
        report['error']=str(error);report['retainedRefusalOrFailure']=True;save();raise

if __name__=='__main__':main()
