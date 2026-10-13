#!/usr/bin/env python3
"""Run the eight frontend diagnostics serially under the existing guard."""
import importlib.util
import json
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
file = ROOT/'selfhost/build/phase83/frontend01/plan.json'
plan = json.loads(file.read_text())
spec = importlib.util.spec_from_file_location('support', ROOT/'selfhost/tools/performance/programs/support.py')
support = importlib.util.module_from_spec(spec)
spec.loader.exec_module(support)
root = file.parent/'runs'
root.mkdir(exist_ok=False)
with support.ExecutionGuard(rss_mib=plan['rssMiB'], available_mib=plan['availableMiB']) as guard:
    for job in plan['jobs']:
        out = root/job['name']
        command = ['taskset', '-c', str(plan['cpu']), plan['roles'][job['role']]['node']['file'],
            *plan['nodeArgs'], str(HERE/'frontend-sweep.mjs'), str(file), job['name'], str(out)]
        result = guard.run(command, out.with_name(out.name+'-guard'), time.monotonic()+plan['seconds'])
        print(json.dumps(dict(job=job['name'], supervisor=result)), flush=True)
        assert result['complete']
        report = json.loads((out/'report.json').read_text())
        assert report['complete'] and report['pass'] and report['inputsUnchanged']
