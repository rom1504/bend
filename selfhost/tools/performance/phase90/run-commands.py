#!/usr/bin/env python3
"""Execute a recorded sequence whose commands already contain resource guards."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[4]
plan = Path(sys.argv[1]).resolve(strict=True)
out = Path(sys.argv[2]).resolve()
out.mkdir(parents=True, exist_ok=False)

def pin(path):
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))

inputs = [pin(plan), pin(Path(__file__).resolve())]
report = dict(complete=False, inputs=inputs, rows=[])

def save():
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')

save()
for row in json.loads(plan.read_text())['commands']:
    command = row['command']
    assert str(root / 'selfhost/tools/performance/phase86/guard.py') in command
    assert command.count('--') == 1, 'Expected one guard, without nesting'
    print(json.dumps(dict(starting=row['name'])), flush=True)
    result = subprocess.run(command, cwd=root)
    report['rows'].append(dict(name=row['name'], command=command, returncode=result.returncode))
    save()
    if result.returncode:
        sys.exit(result.returncode)
for item in inputs:
    assert pin(Path(item['file'])) == item
report['complete'] = True
save()
