#!/usr/bin/env python3
"""Record a supervised child job and preserve script inputs before execution."""
import argparse, hashlib, importlib.util, json, shutil, subprocess, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('campaign', ROOT / 'selfhost/tools/performance/phase40/campaign-v2.py')
campaign = importlib.util.module_from_spec(spec)
spec.loader.exec_module(campaign)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--ledger', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('command', nargs=argparse.REMAINDER)
a = p.parse_args()
command = a.command[1:] if a.command[:1] == ['--'] else a.command
assert command and a.ledger.is_file()
a.out.mkdir(parents=True, exist_ok=False)
record = dict(command=command, started=time.time(), complete=False,
              producer=campaign.identity(__file__), cwd=str(Path.cwd()), inputs=[],
              scope='Enclosing elapsed job; child owns resource/deadline supervision.')
for item in command:
    f = Path(item)
    if f.suffix in ['.py', '.mjs', '.js', '.json', '.patch'] and f.is_file():
        identity = campaign.identity(f)
        dest = a.out / ('input-%02d-%s' % (len(record['inputs']), f.name))
        shutil.copyfile(f, dest)
        identity['preserved'] = dest.name
        record['inputs'].append(identity)
def save():
    (a.out / 'run.json').write_text(json.dumps(record, indent=2)+'\n')
save()
begin = time.monotonic()
with (a.out/'stdout.log').open('w') as stdout, (a.out/'stderr.log').open('w') as stderr:
    try:
        record['returncode'] = subprocess.run(command, stdout=stdout, stderr=stderr).returncode
    except Exception as error:
        record.update(returncode=-1, error=repr(error))
record.update(finished=time.time(), wallSeconds=time.monotonic()-begin)
record['complete'] = record['returncode'] == 0
record.update(stdout=campaign.identity(a.out/'stdout.log'), stderr=campaign.identity(a.out/'stderr.log'))
save()
campaign.append(a.ledger, dict(kind='event', label=a.out.name, command=command,
    started=record['started'], finished=record['finished'], toolElapsedSeconds=record['wallSeconds'],
    complete=record['complete'], returncode=record['returncode'], receipt=campaign.identity(a.out/'run.json'),
    decision='Enclosing job interval; do not separately add nested child time.'))
print(json.dumps({k:record[k] for k in ['complete','returncode','wallSeconds']}), flush=True)
for name in ['stdout.log','stderr.log']:
    tail=(a.out/name).read_text()[-1600:]
    if tail: print(tail, flush=True)
raise SystemExit(0 if record['complete'] else 1)
