#!/usr/bin/env python3
"""Run explicit frozen-plan stages serially; preserve skipped names and exact commands."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[4]
PARENT = ROOT/'selfhost/tools/performance/phase35/final-integration-run.py'


def identity(file):
    file = Path(file).resolve()
    digest = hashlib.sha256()
    with file.open('rb') as stream:
        for chunk in iter(lambda: stream.read(2**20), b''):
            digest.update(chunk)
    return dict(file=str(file), sha256=digest.hexdigest(), bytes=file.stat().st_size)


def select(plan, stage, skipped, start):
    assert plan['complete'] and not plan['executed'] and plan['kind'] == 'phase35-final-integration-plan'
    rows = [r for r in plan['commands'] if r['stage'] == stage]
    names = [r['name'] for r in rows]
    assert rows and len(names) == len(set(names))
    assert len(skipped) == len(set(skipped)) and set(skipped) <= set(names), 'Unknown/duplicate skip'
    rows = [r for r in rows if r['name'] not in skipped]
    if start:
        names = [r['name'] for r in rows]
        assert names.count(start) == 1, 'Start must name a selected command'
        rows = rows[names.index(start):]
    assert rows, 'Empty selected command list'
    return rows


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('plan_directory', type=Path)
    ap.add_argument('--stage', choices=['preinstall', 'owner', 'postinstall'], required=True)
    ap.add_argument('--skip', action='append', default=[])
    ap.add_argument('--start')
    ap.add_argument('--out', type=Path, required=True, help='Fresh launcher receipt directory')
    a = ap.parse_args()
    base = a.plan_directory.resolve(); planfile = base/'plan.json'
    plan = json.loads(planfile.read_text()); rows = select(plan, a.stage, a.skip, a.start)
    out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    report = dict(kind='phase40-selected-final-gate-launch', complete=False, stage=a.stage,
                  plan=identity(planfile), producer=identity(__file__), parentRunner=identity(PARENT),
                  skippedNames=a.skip, start=a.start, selectedNames=[r['name'] for r in rows], steps=[],
                  scope='Explicit selected commands only. Skips remain outstanding until separate reviewed '
                        'successor reports/closures complete. No implicit promotion or complete-gate claim.')
    (out/'consumed-run.py').write_bytes(Path(__file__).read_bytes())
    def save():
        temporary = out/'report.tmp'
        temporary.write_text(json.dumps(report, indent=2)+'\n'); temporary.replace(out/'report.json')
    def verify():
        assert identity(planfile) == report['plan']
        for ref in plan['inputs']:
            assert identity(ref['file']) == ref, ref['file']
    env = {k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['NODE_OPTIONS', 'NODE_PATH']}
    save()
    try:
        for row in rows:
            verify(); command = row['supervisedCommand']; name = row['name']
            print(json.dumps(dict(start=name, stage=a.stage)), flush=True)
            item = dict(name=name, command=command, complete=False, started=time.time())
            report['steps'].append(item); save()
            with (out/(name+'.stdout')).open('x') as stdout, (out/(name+'.stderr')).open('x') as stderr:
                process = subprocess.run(command, stdout=stdout, stderr=stderr, env=env, cwd=ROOT)
            item.update(returncode=process.returncode, finished=time.time(),
                        stdout=identity(out/(name+'.stdout')), stderr=identity(out/(name+'.stderr')))
            item['complete'] = process.returncode == 0; save()
            assert item['complete'], name+' failed; original output/receipt retained'
            verify()
        report['complete'] = True
    except Exception as error:
        report['error'] = repr(error); raise
    finally:
        save()
    print(json.dumps(dict(complete=True, stage=a.stage, steps=len(rows), skipped=a.skip, report=str(out/'report.json'))))


if __name__ == '__main__':
    main()
