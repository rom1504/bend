#!/usr/bin/env python3
"""Sequentially execute existing guarded argv files, retaining a fresh journal."""
import argparse
import hashlib
import json
import subprocess
import time
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
def pin(path):
    p = Path(path).resolve(); data = p.read_bytes()
    return dict(file=str(p), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
p = argparse.ArgumentParser()
p.add_argument('--journal', required=True)
p.add_argument('argv', nargs='+')
a = p.parse_args()
journal = Path(a.journal).resolve()
assert not journal.exists(), journal
files = [Path(x).resolve() for x in a.argv]
pins = [pin(x) for x in files]
commands = [json.loads(x.read_text()) for x in files]
for command in commands:
    assert isinstance(command, list) and all(isinstance(x, str) for x in command)
    assert 'research/phase198/qualification/job.py' in command, 'Only guarded jobs admitted'
r = dict(kind='phase198-sequential-frozen-guarded-jobs', complete=False,
         method=pin(__file__), argv=pins, jobs=[])
def save():
    journal.write_text(json.dumps(r, indent=2)+'\n')
save()
for path, expected, command in zip(files, pins, commands):
    assert pin(path) == expected, path
    row = dict(argv=expected, started=time.time()); r['jobs'].append(row); save()
    print('START '+str(path), flush=True)
    result = subprocess.run(command, cwd=ROOT)
    row.update(returncode=result.returncode, finished=time.time()); save()
    print('END '+str(path)+' '+str(result.returncode), flush=True)
    if result.returncode:
        raise SystemExit(result.returncode)
r['complete'] = True; save()
