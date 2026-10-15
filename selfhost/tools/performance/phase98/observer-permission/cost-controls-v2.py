#!/usr/bin/env python3
"""Root-run successor: valid NC_Text fixtures; reuse exact admitted API artifacts."""
import argparse
import importlib.util
from pathlib import Path
import subprocess
import sys

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('qualifier',HERE/'qualify-v5.py')
Q=importlib.util.module_from_spec(spec);spec.loader.exec_module(Q)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--previous',type=Path,default=Q.BUILD/'observer-cost-controls01/report.json')
    parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--prepare-only',action='store_true')
    args=parser.parse_args();out=args.out.resolve()
    assert out.is_relative_to(Q.BUILD) and not out.exists();out.mkdir(parents=True)
    inputs={};report=dict(kind='phase98-observer-cost-controls-v2',complete=False,targetsRun=False)
    def bind(path):
        row=Q.pin(path);assert inputs.setdefault(row['file'],row)==row;return row
    def verify(value):
        if isinstance(value,dict):
            if {'file','bytes','sha256'}<=value.keys():assert bind(value['file'])==value
            else:
                for child in value.values():verify(child)
        elif isinstance(value,list):
            for child in value:verify(child)
    def save():
        report['inputs']=list(inputs.values());Q.save(out/'report.json',report)
    try:
        previous=Q.read(args.previous);verify(previous);bind(args.previous)
        assert not previous['complete']
        assert 'TypeError' in Q.read(args.previous.parent/'values/report.json')['error']
        values=Q.read(args.previous.parent/'values/report.json');verify(values);bind(args.previous.parent/'values/report.json')
        plan=Q.read(previous['plan']['file']);verify(plan)
        assert plan['sources']['baseline']['sha256']=='59b36a1ca3f7843ff7a03628cd39ed0f530ed137c4825d508a274a8e1ede2714'
        assert plan['sources']['candidate']['sha256']=='a0254c279cab150aeb5c5e9084e1520ae2c1f8ec4ef9bdd96189eb3364e7d5a5'
        old_rows={row['name']:row for row in previous['rows']}
        api_pins={row['file']:row for row in values['inputs']}
        for role in ['baseline','candidate']:
            row=old_rows['api-'+role];process=Q.read(row['guard']['file'])
            assert row['launcherExit']==0 and process['complete'] and process['returncode']==0 and not process.get('stoppedFor')
            assert bind(plan['apis'][role])==api_pins[plan['apis'][role]]
        plan=dict(plan,kind='phase98-observer-cost-inputs-v2',reusedAcquisition=bind(args.previous),
                  inheritedRejectedAttempt=bind(args.previous.parent/'values/report.json'),
                  correction='Input NC_Code.body uses actual NC_Text constructors; compare complete trees and all worker fields. APIs/source/candidate unchanged.')
        Q.save(out/'plan.json',plan)
        node=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
        for path in [__file__,HERE/'qualify-v5.py',HERE/'cost-controls-v2.mjs',Q.GUARD,node]:bind(path)
        folder=out/'controls-guard'
        command=[sys.executable,'-B',str(Q.GUARD),'--out',str(folder),'--seconds','180','--rss-mib','4096','--available-mib','16384','--cpu','3','--',str(node),'--stack-size=16384','--max-old-space-size=3072',str(HERE/'cost-controls-v2.mjs'),str(out/'plan.json'),str(out/'values')]
        report.update(plan=bind(out/'plan.json'),command=command,reusesAdmittedApis=True);save()
        if args.prepare_only:
            report.update(complete=True,preparedOnly=True);save();return
        report['targetsRun']=True;save()
        job=subprocess.run(command,cwd=Q.ROOT,capture_output=True,text=True)
        (out/'launcher.stdout').write_text(job.stdout);(out/'launcher.stderr').write_text(job.stderr)
        report.update(launcherExit=job.returncode,guard=bind(folder/'process.json'))
        process=Q.read(folder/'process.json');report['process']=process;save()
        assert job.returncode==0 and process['complete'] and process['returncode']==0 and not process.get('stoppedFor')
        result=Q.read(out/'values/report.json');assert result['complete'];verify(result)
        report['controls']=bind(out/'values/report.json')
        for row in inputs.values():assert Q.pin(row['file'])==row
        report.update(complete=True,inputsUnchanged=True)
    except BaseException as error:
        report['error']=repr(error);raise
    finally:save()


if __name__=='__main__':main()
