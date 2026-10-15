#!/usr/bin/env python3
"""Exercise the public native CLI serially; compiler children keep its existing guard."""
import argparse,importlib.util,json,subprocess,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('native90_cli',HERE/'native.py')
N=importlib.util.module_from_spec(spec);spec.loader.exec_module(N)

def same(a,b):return all(a[k]==b[k] for k in ['sha256','bytes'])

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for key in ['pointer','controls','out']:parser.add_argument(key,type=Path)
    args=parser.parse_args();out=args.out.resolve()
    assert out.is_relative_to(N.ROOT/'selfhost/build/phase90');out.mkdir(parents=True,exist_ok=False)
    report=dict(kind='phase90-native-public-cli-controls',complete=False,passed=False,rows=[],method=N.pin(__file__))
    def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    save()
    try:
        admission,binding=N.load(args.pointer);controls=json.loads(args.controls.read_text())
        assert controls['kind']=='phase90-runtime-migrated-semantic-control-plan' and controls['complete']
        cases={row['name']:row for row in controls['cases']};negative=controls['negatives'][0]
        assert negative['expectedError']=='parse'
        inputs=[N.pin(__file__),N.pin(HERE/'native.py'),N.pin(args.pointer),N.pin(args.controls)]
        for name in ['small','map_closed','file-io']:
            inputs.extend([N.verify(cases[name]['source']),N.verify(cases[name]['oracle'])])
        inputs.append(N.verify(negative['source']));report.update(admission=binding,inputs=inputs);save()
        def invoke(name,source,destination,extra=(),pointer=None):
            command=[sys.executable,'-B',str(HERE/'native.py'),source['file'],'-o',str(destination),
                '--admission',str((pointer or args.pointer).resolve()),'--seconds','60',*extra]
            report['current']=name;save()
            result=subprocess.run(command,capture_output=True,text=True,timeout=90)
            (out/(name+'.stdout')).write_text(result.stdout);(out/(name+'.stderr')).write_text(result.stderr)
            assert 'Request evidence: ' in result.stderr,'CLI did not retain request evidence'
            directory=Path(result.stderr.rsplit('Request evidence: ',1)[1].strip());request_file=directory/'report.json'
            request=json.loads(request_file.read_text())
            row=dict(name=name,command=command,returncode=result.returncode,stdout=N.pin(out/(name+'.stdout')),
                stderr=N.pin(out/(name+'.stderr')),request=N.pin(request_file),passed=False)
            report['rows'].append(row);save();return row,request,directory
        for name,case_name,extra,count in [('cached-small','small',[],1),('live-file-io','file-io',['--live'],1),
                ('repeated-map','map_closed',['--calls','5'],5)]:
            case=cases[case_name];target=out/(name+'.c');row,request,directory=invoke(name,case['source'],target,extra)
            assert row['returncode']==0 and request['complete'] and request['calls']==count and request['repeatedCEqual']
            assert len(request['outputs'])==count and same(N.pin(target),case['oracle'])
            assert all(same(N.verify(record),case['oracle']) for record in request['outputs'])
            process=request['process'];assert process['complete'] and process['returncode']==0 and not process.get('stoppedFor')
            argv=N.native_args(admission,case['source']['file'],directory/'program',count,'--live' in extra)
            assert process['command'][-len(argv):]==argv
            row.update(passed=True,output=N.pin(target),calls=count,allOutputsExact=True);save()
        existing=out/'cached-small.c';before=N.pin(existing)
        row,request,directory=invoke('existing-output-refusal',cases['small']['source'],existing)
        assert row['returncode']==1 and not request['complete'] and 'Output already exists' in request['error']
        assert 'process' not in request and not (directory/'guard').exists() and N.pin(existing)==before
        row.update(passed=True,targetExecuted=False,existingOutputUnchanged=True);save()
        changed=json.loads(args.pointer.read_text());changed['admission']['sha256']='0'*64
        bad_pointer=out/'changed-manifest-selection.json';bad_pointer.write_text(json.dumps(changed,indent=2)+'\n')
        target=out/'changed-manifest.c';row,request,directory=invoke('changed-manifest-refusal',cases['small']['source'],target,pointer=bad_pointer)
        assert row['returncode']==1 and not request['complete'] and 'Artifact changed:' in request['error']
        assert 'process' not in request and not (directory/'guard').exists() and not target.exists()
        row.update(passed=True,targetExecuted=False,changedSelection=N.pin(bad_pointer));save()
        target=out/'invalid-source.c';row,request,directory=invoke('invalid-source',negative['source'],target)
        process=request['process'];stderr=(directory/'guard/stderr.log').read_text()
        assert row['returncode']==1 and not request['complete'] and not target.exists()
        assert process['returncode']==1 and process['complete'] is False and not process.get('stoppedFor')
        assert isinstance(process.get('finished'),(int,float)) and isinstance(process.get('wallSeconds'),(int,float))
        assert 'parse:' in stderr and not (directory/'program.1.c').exists()
        row.update(passed=True,expectedRejectionObserved=True,outputAbsent=True);save()
        for record in inputs:N.verify(record)
        assert N.load(args.pointer)==(admission,binding)
        report.pop('current',None);report.update(complete=True,passed=True,inputsUnchanged=True);save()
    except Exception as error:
        report['error']=str(error);save();raise
    print(json.dumps(dict(complete=True,passed=True,controls=len(report['rows']),report=N.pin(out/'report.json'))))

if __name__=='__main__':main()
