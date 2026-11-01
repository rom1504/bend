#!/usr/bin/env python3
"""Alternate two runtime modes of one exact native complete-region binary."""
import argparse
import json
from pathlib import Path
import statistics
import sys
import time

ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import fresh_output,pin,require,run,verify,write_json


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--manifest',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--pairs',type=int,default=4);p.add_argument('--minimum-seconds',type=float,default=0.1)
    p.add_argument('--call-seconds',type=float,default=10);p.add_argument('--budget-seconds',type=float,default=45)
    a=p.parse_args();require(2<=a.pairs<=12 and 0.05<=a.minimum_seconds<=1,'Bounded qualified timing policy required')
    plan=json.loads(a.manifest.read_text());require(plan['complete']and plan['kind']=='phase147-native-complete-region-preparation','Completed source preparation required')
    build_file=Path(plan['buildReport']);build=json.loads(build_file.read_text())
    require(build['complete']and not build.get('changedInputs')and not build.get('error'),'Successful native construction required')
    require(build['request']['source']['sha256']==plan['source']['sha256'],'Native binary came from another source')
    binary=pin(plan['binary']);require(binary==build['binary'],'Native image binding differs')
    inputs=[pin(__file__),pin(ROOT/'selfhost/tools/build/common.py'),pin(a.manifest),pin(build_file),binary,plan['source']]
    for row in inputs:verify(row)
    out=fresh_output(a.out,ROOT);start=time.monotonic()
    report=dict(kind='phase147-native-complete-region-timing',version=1,complete=False,passed=False,performanceQualified=False,
        inputs=inputs,family=plan['family'],checksPerIteration=plan['checksPerIteration'],calls=[],pairs=[],
        transportCorrection='QBE IO.args omits argv0: explicit verifier-slice sentinel precedes mode/count. Initial preparation argv metadata omitted it; source and binary are unchanged.',
        scope='Same executable, runtime-selected modes/count. Whole child wall and user/system CPU include metadata/schema/conversion/flow, temporary reclamation, startup and teardown. Zero-repeat observations are reported, never subtracted. No whole-compiler or upstream ratio.')
    def save():write_json(out/'report.json',report)
    save()
    def invoke(mode,repeats,kind):
        require(time.monotonic()-start<a.budget_seconds,'Whole timing soft budget exceeded')
        index=len(report['calls']);folder=out/str(index);folder.mkdir()
        receipt=run([binary['file'],'--threads','1','--gpu','off','--','verifier-slice',mode,str(repeats)],cwd=ROOT,
            stdout=folder/'stdout',stderr=folder/'stderr',seconds=a.call_seconds)
        row=dict(index=index,mode=mode,repeats=repeats,kind=kind,process=receipt);report['calls'].append(row);save()
        expected=(str(repeats*plan['checksPerIteration'])+'\n').encode()
        require(receipt['complete']and receipt['exitCode']==0 and (folder/'stdout').read_bytes()==expected and not(folder/'stderr').read_bytes(),
            'Complete count/stdout/stderr/process control failed')
        row['passed']=True;save();return row
    try:
        for mode in ['old','new']:invoke(mode,0,'startup-control')
        count=1
        while True:
            calls=[invoke(mode,count,'calibration')for mode in ['old','new']]
            if min(row['process']['seconds']for row in calls)>=a.minimum_seconds:break
            require(count<65536,'Maximum repeat budget reached without sufficient signal');count=min(count*4,65536)
        report['repeats']=count
        for pair in range(a.pairs):
            order=['old','new']if pair%2==0 else ['new','old'];rows={mode:invoke(mode,count,'timed')for mode in order}
            report['pairs'].append(dict(index=pair,order=order,calls={mode:row['index']for mode,row in rows.items()},
                ratio=rows['new']['process']['seconds']/rows['old']['process']['seconds']));save()
        timed=[row for row in report['calls']if row['kind']=='timed']
        report['medianSeconds']={mode:statistics.median(row['process']['seconds']for row in timed if row['mode']==mode)for mode in ['old','new']}
        report['ratio']=report['medianSeconds']['new']/report['medianSeconds']['old']
        report['pairRatios']=[row['ratio']for row in report['pairs']]
        report['performanceQualified']=min(row['process']['seconds']for row in timed)>=a.minimum_seconds*0.8
        for row in inputs:verify(row)
        report['complete']=report['passed']=True
    except BaseException as error:report['error']=repr(error);raise
    finally:report['totalSeconds']=time.monotonic()-start;save()
    print(json.dumps({key:report[key]for key in ['complete','passed','performanceQualified','family','repeats','ratio','totalSeconds']}))


if __name__=='__main__':main()
