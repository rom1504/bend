#!/usr/bin/env python3
"""Execute the root-approved Phase147 archive-only close plan; never prune."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[4]


def pin(path):
    data=path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def check(row):
    actual=pin(ROOT/row['file'])
    assert all(actual[k]==row[k]for k in ['bytes','sha256'])


def main():
    assert len(sys.argv)==3
    plan_path=(ROOT/sys.argv[1]).absolute();out=(ROOT/sys.argv[2]).absolute()
    assert out.is_relative_to(ROOT/'selfhost/build-retention/phase147') and not out.exists()
    plan=json.loads(plan_path.read_text())
    assert plan['kind']=='phase147-proposed-final-retention-plan-v1' and plan['complete']
    assert not plan['pendingGuards'] and plan['qualification']
    check(plan['qualification'])
    for row in plan['guards']:
        check(row['process']);check(row['retention'])
        argv=row['closeArgv']
        assert argv[:3]==['python3','-B','selfhost/tools/build-retention/close.py'] and '--prune'not in argv
    out.mkdir(parents=True)
    result=dict(kind='phase147-approved-archive-only-close-batch-v1',complete=False,
                plan=pin(plan_path),method=pin(Path(__file__).resolve()),
                closeMethod=pin(ROOT/'selfhost/tools/build-retention/close.py'),
                rootAuthorization='Root explicitly authorized close/archive/verify; skip raw pruning.',
                started=time.time(),pruningRequested=False,rows=[])
    (out/'intent.json').write_text(json.dumps(result,indent=2)+'\n')
    try:
        for row in plan['guards']:
            assert shutil.disk_usage(ROOT).free>6*1024**3,'Keep 5GiB reserve plus bounded archive scratch'
            check(row['process']);check(row['retention'])
            argv=['taskset','-c','0',*row['closeArgv']]
            done=subprocess.run(argv,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            observed=dict(guard=row['guard'],classification=row['classification'],returncode=done.returncode,
                          stdout=done.stdout.decode(),stderr=done.stderr.decode())
            result['rows'].append(observed)
            assert done.returncode==0,'Close failed: '+row['guard']
            state=json.loads((ROOT/row['retention']['file']).read_text())
            assert state['closed'] and state['state']=='sealed'
            closure=state['closure'];check(dict(file=closure.get('file',closure.get('path')),
                                             bytes=closure['bytes'],sha256=closure['sha256']))
            observed['closure']=closure
        result['complete']=True
    finally:
        result['finished']=time.time()
        (out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(complete=True,closed=len(result['rows']),seconds=result['finished']-result['started'])))


if __name__=='__main__':main()
