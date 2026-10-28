#!/usr/bin/env python3
"""Apply the reviewed initial archive-backed tranche, one verified plan at a time."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[3]
POLICY=ROOT/'selfhost/tools/build-retention/initial-policy.json'
METHOD=ROOT/'selfhost/tools/build-retention/archive-v02.py'
OUT=ROOT/'selfhost/build-retention/2026-10-28'
ORDER=[58,45,42,43,48,60,64,62,63,65,47,52,44,56,55,54,53,59,57,51,50,49]


def pin(path):
    data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    report_path=OUT/'campaign.json'
    assert not report_path.exists()
    policy=json.loads(POLICY.read_text())
    inputs=[pin(Path(__file__).resolve()),pin(POLICY),pin(METHOD)]
    baseline=json.loads((OUT/'phase61-apply/report.json').read_text())
    restored=json.loads((OUT/'restore-after-receipt/report.json').read_text())
    assert baseline['complete'] and restored['complete'] and restored['restored']==1
    report=dict(kind='archive-backed-initial-retention-campaign',complete=False,inputs=inputs,jobs=[],
                started=time.time(),freeBeforeBytes=shutil.disk_usage(ROOT).free,
                earlierPhase61=pin(OUT/'phase61-apply/report.json'),scope='Only explicit reviewed policy roots; each apply follows a complete archive/current-file verification. No directory deletion. Stop at10GiB free or end of initial tranche.')
    def save():
        report['freeAfterBytes']=shutil.disk_usage(ROOT).free
        temp=report_path.with_suffix('.tmp');temp.write_text(json.dumps(report,indent=2)+'\n');temp.replace(report_path)
    save()
    recovered=baseline['selectedAllocatedBytes']
    try:
        for phase in ORDER:
            if recovered>=5*1024**3 and shutil.disk_usage(ROOT).free>=10*1024**3:
                report['stoppedAtFreeTarget']=True
                break
            receipt=next(p for p,r in policy['archiveRoots'].items() if r==f'selfhost/build/phase{phase}')
            for action in ['verify','apply']:
                assert [pin(Path(p['file'])) for p in inputs]==inputs
                folder=OUT/f'phase{phase}-{action}'
                command=[sys.executable,'-B',str(METHOD),action,'--out',str(folder)]
                command+=['--policy',str(POLICY),'--receipt',str(ROOT/receipt)] if action=='verify' else ['--plan',str(OUT/f'phase{phase}-verify/plan.json')]
                job=dict(phase=phase,action=action,command=command,started=time.time())
                report['jobs'].append(job);save()
                print(json.dumps(dict(phase=phase,action=action,state='started')),flush=True)
                with (OUT/f'phase{phase}-{action}.stdout').open('x') as stdout,(OUT/f'phase{phase}-{action}.stderr').open('x') as stderr:
                    process=subprocess.run(command,cwd=ROOT,stdout=stdout,stderr=stderr,timeout=300)
                job.update(returncode=process.returncode,finished=time.time());save()
                assert process.returncode==0, f'Phase{phase} {action} failed; inspect preserved logs'
                receipt_path=folder/('plan.json' if action=='verify' else 'report.json')
                value=json.loads(receipt_path.read_text());assert value['complete']
                if action=='apply':
                    recovered+=value['selectedAllocatedBytes']
                    report['selectedRecoveryIncludingPhase61']=recovered
                job['receipt']=pin(receipt_path);save()
                print(json.dumps(dict(phase=phase,action=action,state='complete',freeGiB=shutil.disk_usage(ROOT).free/1024**3)),flush=True)
        report['complete']=True
    except BaseException as error:
        report['error']=repr(error)
    finally:
        report['finished']=time.time();save()
    print(json.dumps({k:report.get(k) for k in ['complete','freeBeforeBytes','freeAfterBytes','error']}),flush=True)
    return 0 if report['complete'] else 1


if __name__=='__main__':
    raise SystemExit(main())
