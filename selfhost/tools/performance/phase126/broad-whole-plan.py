#!/usr/bin/env python3
"""Place a frozen broad-plan command list inside one authorized8MiB-file guard."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import shutil
import sys

ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent


def read(path): return json.loads(Path(path).read_text())


def pin(path):
    path=Path(path).resolve(); raw=path.read_bytes()
    return dict(file=str(path),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__); modes=p.add_subparsers(dest='mode',required=True)
    prep=modes.add_parser('prepare'); prep.add_argument('--plan',type=Path,required=True); prep.add_argument('--out',type=Path,required=True)
    check=modes.add_parser('verify'); check.add_argument('--plan',type=Path,required=True)
    a=p.parse_args(); original=read(a.plan)
    if a.mode=='verify':
        assert original['kind']=='phase126-whole-broad45-command-plan'
        for row in original['inputs']: assert pin(row['file'])==row,row['file']
        print(json.dumps(dict(complete=True,targetsRun=False,plan=pin(a.plan)))); return
    assert original['kind']=='phase126-frozen-broad45-command-plan'
    assert [len(batch) for batch in original['batches']]==[8,8,8,8,8,5]
    assert original['rounds']==3 and original['scale']==4
    for row in original['inputs']: assert pin(row['file'])==row,row['file']
    out=a.out.resolve(); assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase126')
    guard=HERE/'guard-small-files.py'; derivation=HERE/'guard-small-files-derivation01.json'; d=read(derivation)
    for key in ['original','derived','support']: assert pin(d[key]['file'])==d[key]
    reconstructed=Path(d['original']['file']).read_text()
    for edit in d['edits']:
        assert reconstructed.count(edit['before'])==1; reconstructed=reconstructed.replace(edit['before'],edit['after'])
    assert reconstructed==guard.read_text()
    jobs=[]; removed=[]; old_guard=str(ROOT/'selfhost/tools/performance/phase111/guard.py')
    for original_job in original['jobs']:
        job=copy.deepcopy(original_job); command=job['command']
        if old_guard in command:
            assert command[2]==old_guard and command[command.index('--cpu')+1]=='3'
            for flag,value in [('--rss-mib','2048'),('--available-mib','16384'),('--file-mib','64')]:
                assert command[command.index(flag)+1]==value
            split=command.index('--'); job['seconds']=int(command[command.index('--seconds')+1])
            removed.append(dict(job=job['name'],originalGuard=command[:split],innerCommand=command[split+1:]))
            job['command']=command[split+1:]
        else: job['seconds']=60
        jobs.append(job)
    assert len(removed)==7 and len(jobs)==11
    paths=[Path(path) for path in original['artifacts'].values()]+[Path(path).parent for path in original['batchReports']]
    screen=next(job['command'] for job in jobs if job['name']=='screen'); label=screen[screen.index('--label')+1]
    paths += [ROOT/'selfhost/build/phase111'/('p126-'+label+'-'+name+'-build') for name in original['names']]
    guard_out=out.with_name(out.stem+'-guard'); jobs_out=ROOT/'selfhost/build/phase113'/('p126-'+out.stem+'-jobs')
    assert all(not path.exists() for path in [*paths,guard_out,jobs_out]),'Fresh campaign destinations required'
    py=[sys.executable,'-B']; runner=ROOT/'selfhost/tools/performance/phase113/run-jobs.py'
    jobs.insert(0,dict(name='authenticate-whole-campaign',seconds=30,command=py+[str(Path(__file__).resolve()),'verify','--plan',str(out)]))
    seconds=sum(job['seconds'] for job in jobs)+60
    command=py+[str(guard),'--out',str(guard_out),'--seconds',str(seconds),'--rss-mib','2048',
        '--available-mib','16384','--file-mib','8','--cpu','3','--',*py,str(runner),'--plan',str(out),'--out',str(jobs_out)]
    result=dict(kind='phase126-whole-broad45-command-plan',targetsRun=False,
        inputs=[*original['inputs'],pin(a.plan),pin(__file__),pin(guard),pin(derivation),pin(runner)],
        basePlan=pin(a.plan),names=original['names'],batches=original['batches'],jobs=jobs,
        artifacts=dict(original['artifacts'],guard=str(guard_out),jobs=str(jobs_out)),rootGuardCommand=command,
        derivation=dict(removedInnerResourceGuards=removed,allInnerCommandsOtherwiseUnchanged=True,
            policy='One root execution lock/RSS/available-memory/deadline supervisor for the entire serial campaign. Same per-job deadlines, fresh emitter processes, merger, exact45 assertion, aligned builds, rounds/counts/oracles and summarizer. Stop on failure.'),
        disk=dict(observedFreeBytes=shutil.disk_usage(ROOT).free,guardStartupRequiresMoreThanBytes=176*1024**2,
            perFileLimitBytes=8*1024**2,scope='Existing startup formula with explicitly authorized stricter8MiB file cap. Historical total-size estimate is not a worst-case candidate bound; no cleanup or dynamic disk guarantee. Full native builds excluded.'))
    for row in result['inputs']: assert pin(row['file'])==row,row['file']
    with out.open('x') as stream: json.dump(result,stream,indent=2); stream.write('\n')
    print(json.dumps(dict(complete=True,targetsRun=False,plan=pin(out),rootGuardCommand=command)))


if __name__=='__main__': main()
