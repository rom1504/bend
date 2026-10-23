"""Execute only authorized CPU6 correctness jobs from a frozen projection plan.

Uses the shared existing CPU6 lock/guard. Never runs pilot/calibration/timing.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[5]
GUARD=ROOT/'selfhost/tools/performance/phase131/native/check-guard.py'
def pin(path):
    path=Path(path).resolve();b=path.read_bytes()
    return dict(file=str(path),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    plan=json.loads(a.plan.read_text())
    selected=[j for suffix in ['-emit','-inspect','-admission','-build'] for j in plan['jobs'] if j['name'].endswith(suffix)]
    assert len(selected)==10
    jobs=[]
    for j in selected:
        old=j['command'];command=old[old.index('--')+1:] if '--' in old else old
        limit=min(180,int(old[old.index('--seconds')+1])) if '--seconds' in old else 60
        command=[sys.executable,'-B',str(GUARD),'--out',str(out/(j['name']+'-guard')),
            '--seconds',str(limit),'--rss-mib','3072','--available-mib','16384','--cpu','6','--',*command]
        jobs.append(dict(name=j['name'],originalCommand=old,command=command))
    out.mkdir(parents=True);(out/'method.py').write_bytes(Path(__file__).read_bytes())
    report=dict(complete=False,performance=False,inputs=[pin(__file__),pin(GUARD),pin(a.plan)],
        scope='Root-authorized independent CPU6 correctness lane, shared lock,3GiB/16GiB-free bound. Same original tools/flags/artifact paths; only guard CPU and measurement role differ.',jobs=jobs)
    def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    save()
    try:
        for i,j in enumerate(jobs):
            start=time.monotonic()
            with (out/f'{i}.stdout').open('xb') as so,(out/f'{i}.stderr').open('xb') as se:
                status=subprocess.run(j['command'],cwd=ROOT,stdout=so,stderr=se).returncode
            j.update(status=status,seconds=time.monotonic()-start,stdout=pin(out/f'{i}.stdout'),stderr=pin(out/f'{i}.stderr'));save()
            print(json.dumps({k:j[k] for k in ['name','status','seconds']}),flush=True)
            if status:raise RuntimeError('Failed '+j['name'])
        for item in report['inputs']:assert pin(item['file'])==item
        report['complete']=True
    except BaseException as error:
        report['error']=repr(error);raise
    finally:save()
if __name__=='__main__':main()
