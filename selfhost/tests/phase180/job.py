#!/usr/bin/env python3
"""Run one bounded Phase180 job, recording failures and retention closure."""
from pathlib import Path
import argparse
import json
import subprocess
import sys

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--rss-mib', default='2048')
p.add_argument('--cpu', default='3')
p.add_argument('--extra-root', action='append', default=[])
p.add_argument('name')
p.add_argument('seconds')
p.add_argument('disk_mib')
p.add_argument('command', nargs=argparse.REMAINDER)
a = p.parse_args()
if not a.command or '/' in a.name or a.name in ('.', '..'):
    p.error('a fresh simple name and command are required')
root = Path('selfhost/build/phase180')
out = root / a.name
guard = root / (a.name + '-guard')
log = Path('/tmp') / ('p180-' + a.name + '.log')
if '--out' in a.command:
    target = Path(a.command[a.command.index('--out')+1]).absolute()
    declared = [out.absolute(), *[Path(x).absolute() for x in a.extra_root]]
    if not any(target == root or root in target.parents for root in declared):
        p.error('Command --out is outside declared artifact roots')
args = [sys.executable, '-B', 'selfhost/tools/build-retention/guard.py',
        '--out', str(guard), '--run-root', str(out),
        *[word for root in a.extra_root for word in ['--run-root', root]], '--seconds', a.seconds,
        '--disk-mib', a.disk_mib, '--rss-mib', a.rss_mib,
        '--available-mib', '16384', '--file-mib', '128', '--cpu', a.cpu,
        '--', *a.command]
with log.open('w') as f:
    result = subprocess.run(args, stdout=f, stderr=subprocess.STDOUT)
subprocess.run([sys.executable, '-B', 'selfhost/tools/build-retention/close.py',
    '--run', str(guard), '--classification',
    'completed' if result.returncode == 0 else 'failed', '--keep-root', str(out),
    '--out', 'selfhost/build-retention/phase180/' + a.name + '-close'],
    stdout=subprocess.DEVNULL, check=True)
print('job', a.name, 'exit', result.returncode, flush=True)
if result.returncode:
    diagnostics = [out / 'stderr', out / 'compiler.stderr', out / 'qbe.stderr', guard / 'stderr.log']
    printed = False
    report = out / 'report.json'
    if report.exists():
        detail = json.loads(report.read_text()).get('error')
        if detail:
            print(str(detail)[:2500], flush=True)
            printed = True
    for file in diagnostics:
        if file.exists() and file.stat().st_size:
            print(str(file), file.read_text()[-3500:], flush=True)
            printed = True
    if not printed:
        print(log.read_text()[-1500:], flush=True)
sys.exit(result.returncode)
