#!/usr/bin/env python3
"""Bound the remaining maintained controls without taking their internal lock.

execute.test.mjs already passed separately in Phase37; --include-execute is for
a complete reproduction, not a requirement to repeat a completed root check.
"""
import argparse
import json
from pathlib import Path
import shutil
import sys
import time

HERE = Path(__file__).resolve().parent
PROGRAMS = HERE.parent / 'programs'
sys.path.insert(0, str(PROGRAMS))
from support import ExecutionGuard, identity, save

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--node', type=Path, required=True)
parser.add_argument('--out', type=Path, required=True)
parser.add_argument('--include-execute', action='store_true')
args = parser.parse_args()
out = args.out.resolve()
node = args.node.resolve()
assert node.is_file() and not out.exists()
sources = [Path(__file__).resolve(), *sorted(PROGRAMS.glob('*.py')),
           *sorted(PROGRAMS.glob('*.mjs')), *sorted((PROGRAMS / 'tests').glob('test_*.py'))]
inputs = [identity(file) for file in sources] + [identity(node), identity(sys.executable)]
scripts = (['execute.test.mjs'] if args.include_execute else []) + ['analyze.test.mjs', 'profile.test.mjs']
commands = [(name, ['taskset', '-c', '3', str(node), '--max-old-space-size=256', str(PROGRAMS / name)])
            for name in scripts]
commands.append(('python-unittest', ['taskset', '-c', '3', sys.executable, '-m', 'unittest', 'discover',
    '-s', str(PROGRAMS / 'tests'), '-p', 'test_*.py', '-v']))
report = dict(kind='phase37-maintained-harness-controls', complete=False, inputs=inputs, steps=[],
    scope='Synthetic worker/AST/profile/orchestration/source-confinement controls; no Bend compilation or corpus timing.',
    externalExecuteControl=None if args.include_execute else 'execution-worker-controls02; check its independent root receipt')
# The tests themselves acquire the normal campaign lock. The root must schedule
# this whole job serially; this separate outer lock bounds the total process tree.
with ExecutionGuard(rss_mib=2048, available_mib=2048,
                    lock_path=HERE.parents[2] / 'build/phase37/outer-tests.lock') as guard:
    out.mkdir(parents=True, exist_ok=False)
    (out / 'consumed').mkdir()
    for file in sources:
        name = ('phase37-' + file.name) if file == Path(__file__).resolve() else str(file.relative_to(PROGRAMS))
        target = out / 'consumed' / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(file, target)
    save(out / 'report.json', report)
    for name, command in commands:
        process = guard.run(command, out / name, time.monotonic() + 120,
                            env={'PROGRAMS_TEST_NODE': str(node)})
        report['steps'].append(dict(name=name, process=process))
        save(out / 'report.json', report)
        if not process['complete']:
            break
    assert all(identity(item['path']) == item for item in inputs), 'Consumed harness input changed'
    report['complete'] = len(report['steps']) == len(commands) and all(row['process']['complete'] for row in report['steps'])
    save(out / 'report.json', report)
print(json.dumps(dict(complete=report['complete'], steps=len(report['steps']), report=str(out / 'report.json'))))
raise SystemExit(0 if report['complete'] else 1)
