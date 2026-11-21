"""Archive the reproducible transfer receipts without copying generated binaries."""
import argparse
from pathlib import Path
import json
import shutil

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]


def retain(job):
    run=ROOT/'selfhost/build/phase199'/job
    guard=run.with_name(job+'-guard')
    status=json.loads((guard/'retention.json').read_text())
    assert status['closed'],job
    dest=HERE/'evidence'/job
    dest.mkdir(exist_ok=False)
    for path in sorted(run.glob('*.json')):
        shutil.copy2(path,dest/path.name)
    for name in ('process.json','retention.json','stderr.log'):
        shutil.copy2(guard/name,dest/('guard-'+name))
    close=ROOT/'selfhost/build-retention/phase199'/(job+'-close')/'report.json'
    shutil.copy2(close,dest/'close.json')


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('jobs',nargs='+');a=p.parse_args()
    for j in a.jobs:retain(j)
