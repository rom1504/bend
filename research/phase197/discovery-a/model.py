#!/usr/bin/env python3
"""Model the frozen ray alternatives; never executes target products."""
import argparse
import json
from pathlib import Path
import re
import resource
import subprocess
import time
from prepare import ROOT, HERE, read, pin, verify


def main(out):
    out.mkdir(parents=True,exist_ok=False)
    frozen=read(HERE/'frozen.json')
    for row in [frozen[k] for k in ('source','object','binary')]+frozen['inputs']:
        verify(row)
    acquisition=read(ROOT/'selfhost/build/phase195/hardware-tool01/acquisition.json')
    for row in [acquisition['tool'],*acquisition['libraries']]:verify(row)
    result=dict(complete=False,targetsRun=False,freeze=pin(HERE/'frozen.json'),method=pin(__file__),
                acquisition=acquisition,candidates=[],modelWallSeconds=0,modelCpuSeconds=0)
    for candidate in frozen['candidates']:
        patch=candidate['patches'][candidate['modelPatch']]
        row=dict(name=candidate['name'],case=candidate['case'],runs={},
                 historicalOwnerHotness=candidate['historicalOwnerHotness'],hotnessKind=candidate['hotnessKind'])
        result['candidates'].append(row)
        for role in ('before','after'):
            source=out/(candidate['name']+'-'+role+'.s')
            source.write_text('.text\n'+'\n'.join(patch[role])+'\n')
            argv=[acquisition['tool']['file'],'-mtriple=x86_64-unknown-linux-gnu',
                  '-mcpu=ivybridge','-iterations=100','-noalias=true',str(source)]
            start=time.monotonic();usage=resource.getrusage(resource.RUSAGE_CHILDREN)
            process=subprocess.run(argv,capture_output=True,text=True,timeout=3)
            endusage=resource.getrusage(resource.RUSAGE_CHILDREN)
            elapsed=time.monotonic()-start
            cpu=endusage.ru_utime+endusage.ru_stime-usage.ru_utime-usage.ru_stime
            stdout=out/(candidate['name']+'-'+role+'.stdout');stdout.write_text(process.stdout)
            stderr=out/(candidate['name']+'-'+role+'.stderr');stderr.write_text(process.stderr)
            metrics={}
            for key,label in [('cycles','Total Cycles'),('throughput','Block RThroughput'),('instructions','Instructions'),('iterations','Iterations')]:
                match=re.search('^'+label+r':\s*([\d.]+)',process.stdout,re.M)
                if match:metrics[key]=float(match[1])
            run=dict(argv=argv,source=pin(source),stdout=pin(stdout),stderr=pin(stderr),exitCode=process.returncode,
                     elapsedSeconds=elapsed,cpuSeconds=cpu,metrics=metrics)
            row['runs'][role]=run
            result['modelWallSeconds']+=elapsed;result['modelCpuSeconds']+=cpu
            (out/'model.json').write_text(json.dumps(result,indent=2)+'\n')
            assert process.returncode==0 and not process.stderr,(candidate['name'],process.stderr)
            assert metrics['iterations']==100 and metrics['instructions']==100*len(patch[role])
        before,after=(row['runs'][role]['metrics'] for role in ('before','after'))
        row['cycleRatio']=after['cycles']/before['cycles'];row['throughputRatio']=after['throughput']/before['throughput']
        row['instructionRatio']=after['instructions']/before['instructions']
    result['rankings']={key:[r['name'] for r in sorted(result['candidates'],key=lambda x:(x[key],x['name']))]
                        for key in ('cycleRatio','throughputRatio','instructionRatio')}
    result['complete']=True
    (out/'model.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({'rankings':result['rankings'],'modelWallSeconds':result['modelWallSeconds']}))


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--out',required=True,type=Path)
    main(parser.parse_args().out)
