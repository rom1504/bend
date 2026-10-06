#!/usr/bin/env python3
"""Run a reviewed serial plan; each target command owns its recorded guard."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

plan_file, output = map(Path, sys.argv[1:])
assert not output.exists()
output.mkdir(parents=True)
plan_bytes = plan_file.read_bytes()
plan = json.loads(plan_bytes)
assert Path.cwd() == Path(plan['cwd'])
report = {'kind': 'phase55-retention-execution', 'complete': False,
          'pass': False, 'started': time.time(),
          'command': sys.argv, 'plan': str(plan_file.resolve()),
          'planSha256': hashlib.sha256(plan_bytes).hexdigest(), 'steps': []}

def save():
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')

save()
for item in plan['commands']:
    name = item['name']
    row = {'name': name, 'command': item['command'], 'started': time.time(),
           'environment': item.get('environment', {})}
    report['steps'].append(row)
    save()
    print('START ' + name, flush=True)
    with (output / (name + '.stdout')).open('wb') as stdout, (output / (name + '.stderr')).open('wb') as stderr:
        result = subprocess.run(item['command'], cwd=plan['cwd'],
                                env={**os.environ, **row['environment']},
                                stdout=stdout, stderr=stderr)
    row.update(returncode=result.returncode, finished=time.time())
    save()
    print('DONE ' + name + ' exit=' + str(result.returncode), flush=True)
    if result.returncode:
        report['finished'] = time.time()
        save()
        raise SystemExit(result.returncode)
assert plan_file.read_bytes() == plan_bytes
report.update({'complete': True, 'pass': True, 'finished': time.time(), 'returncode': 0})
save()
