#!/usr/bin/env python3
"""Run frozen Phase85 jobs serially, with wall/RSS/available-memory/output limits."""
import argparse, importlib.util, json, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
spec=importlib.util.spec_from_file_location('support',ROOT/'selfhost/tools/performance/programs/support.py')
S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--plan',type=Path,required=True);ap.add_argument('--only')
a=ap.parse_args();f=a.plan.resolve();p=json.loads(f.read_text());jobs=p['jobs']
if a.only:
    names=set(a.only.split(','));jobs=[j for j in jobs if j['name'] in names];assert {j['name'] for j in jobs}==names
assert jobs
def verify():
    for i in p['inputs']:assert S.identity(i['file'])==dict(path=i['file'],sha256=i['sha256'],bytes=i['bytes']),i['file']
verify();root=f.parent/'runs';root.mkdir(exist_ok=True)
with S.ExecutionGuard(rss_mib=p['rssMiB'],available_mib=p['availableMiB']) as guard:
    for j in jobs:
        out=root/j['name'];g=out.with_name(out.name+'-guard');assert not out.exists() and not g.exists()
        cmd=['bash','-c','ulimit -f 65536; exec "$@"','phase85','env','NODE_OPTIONS=','NODE_PATH=',
            'taskset','-c',str(p['cpu']),p['roles'][j['role']]['node']['file'],*p['nodeArgs'],str(HERE/'worker.mjs'),str(f),j['name'],str(out)]
        result=guard.run(cmd,g,time.monotonic()+p['seconds']);print(json.dumps(dict(job=j['name'],supervisor=result)),flush=True)
        assert result['complete'],'Retain failed evidence; retry with a fresh frozen plan'
        r=json.loads((out/'report.json').read_text());assert r['complete'] and r['pass'] and r['inputsUnchanged']
verify()
