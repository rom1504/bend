#!/usr/bin/env python3
"""Run bounded contract campaigns serially; reuse only complete pinned receipts."""
import argparse
import subprocess
import sys
import time
from pathlib import Path
sys.dont_write_bytecode=True
from common import ROOT,BUILD,pin,read,save,verify


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--section',choices=['projection','followups'],required=True)
    p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve()
    assert out.is_relative_to(BUILD);out.mkdir(parents=True,exist_ok=False)
    jobs=[]
    if a.section=='projection':
        source=BUILD/'projection-frozen01'
        for role in ['baseline','candidate']:
            jobs.append((role+'-js',source/role/'manifest.json',BUILD/f'projection-{role}-js01',[]))
        for role in ['baseline','candidate']:
            jobs.append((role+'-native',source/role/'manifest.json',out/(role+'-native'),['--native']))
        for role in ['wrong-query','swap-type-value','lose-unsafe','skip-empty-index','lose-missing-name']:
            jobs.append((role,source/role/'manifest.json',out/role,['--expect-mutation']))
    else:
        source=BUILD/'challenge-targeted01'
        jobs.append(('baseline-js',source/'baseline/manifest.json',out/'baseline-js',[]))
        for role in ['bad05-frame-pop-is-slots','bad08-historical-fid-collision','bad04-empty-chunk-separator']:
            jobs.append((role,source/role/'manifest.json',out/role,['--expect-mutation']))
        jobs.append(('baseline-native',source/'baseline/manifest.json',out/'baseline-native',['--native']))
    worker=Path(__file__).with_name('production.py')
    report=dict(complete=False,started=time.time(),section=a.section,method=pin(__file__),worker=pin(worker),rows=[])
    def write():save(out/'report.json',report)
    try:
        for name,manifest,destination,flags in jobs:
            reused=destination.exists();t=time.monotonic()
            command=[sys.executable,'-B',str(worker),'--manifest',str(manifest),'--out',str(destination),*flags]
            if not reused:
                proc=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
                (out/(name+'.stdout')).write_text(proc.stdout);(out/(name+'.stderr')).write_text(proc.stderr)
            result=read(destination/'report.json')
            row=dict(name=name,reused=reused,command=command,report=pin(destination/'report.json'),wallSeconds=time.monotonic()-t,complete=result['complete'])
            report['rows'].append(row);write()
            assert result['complete'] and result['manifest']==pin(manifest)
            assert result['method']==pin(worker)
            assert result['native']==('--native' in flags) and result['mutationControl']==('--expect-mutation' in flags)
            for item in read(manifest)['frozenInputs']:verify(item)
            if not reused:assert proc.returncode==0,(name,proc.stderr[-1500:])
            print(name,'pass','reused' if reused else 'fresh',flush=True)
        verify(report['method']);verify(report['worker']);report['complete']=True
    except BaseException as error:report['error']=repr(error);raise
    finally:report['wallSeconds']=time.time()-report['started'];write()


if __name__=='__main__':main()
