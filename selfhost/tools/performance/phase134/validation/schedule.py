#!/usr/bin/env python3
"""Give groups unique guard directories and resume only uncompleted target jobs."""
import argparse
import copy
import hashlib
import json
from pathlib import Path


def pin(path):
    p = Path(path).resolve(); data = p.read_bytes()
    return dict(file=str(p), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan', type=Path, required=True)
    p.add_argument('--completed', type=Path)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); assert not a.out.exists()
    plan = json.loads(a.plan.read_text()); jobs = plan['jobs']; offset = 0
    inputs = [pin(__file__), pin(a.plan)]
    if a.completed:
        prior = json.loads(a.completed.read_text()); inputs.append(pin(a.completed))
        assert pin(a.plan) in prior['inputs']
        for index, row in enumerate(prior['jobs']):
            assert row['command'] == jobs[index]['command']
            if row.get('status') != 0: break
            for name in ['stdout', 'stderr']: assert pin(row[name]['file']) == row[name]
            offset += 1
    remaining = []
    for index, old in enumerate(jobs[offset:], start=offset):
        job = copy.deepcopy(old); cmd = job['command']
        assert 'phase111/guard.py' in ' '.join(cmd)
        at = cmd.index('--out') + 1
        old_guard = Path(cmd[at]); fresh = a.out.parent / f'{a.out.stem}-{index}-{job.get("group", "job")}-{job["name"]}-guard'
        assert not fresh.exists()
        cmd[at] = str(fresh.resolve())
        assert [x for i,x in enumerate(cmd) if i != at] == [x for i,x in enumerate(old['command']) if i != at]
        job['guardRelocation'] = dict(before=str(old_guard), after=cmd[at])
        remaining.append(job)
    a.out.write_text(json.dumps(dict(complete=True, targetsRun=False, inputs=inputs,
        completedPrefix=offset, jobs=remaining,
        scope='Only guard output directories differ. Original target commands, destinations, source/oracle identities and semantic checks are unchanged; completed prefix is preserved.'), indent=2) + '\n')
    print(json.dumps(dict(skipped=offset, scheduled=len(remaining))))


if __name__ == '__main__': main()
