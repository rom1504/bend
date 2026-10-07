#!/usr/bin/env python3
"""Time one frozen subset command, including its CLI preflight; no extra guard."""
import hashlib, json, subprocess, sys, time
from pathlib import Path

root = Path(__file__).resolve().parents[4]
plan_file = root / 'selfhost/tools/performance/phase60/analysis/fast-subsets-v1.json'
plan_bytes = plan_file.read_bytes()
plan = json.loads(plan_bytes)
subset, destination = sys.argv[1:]
selection = next(row for row in plan['plans'] if row['id'] == subset)
out = Path(destination).resolve()
assert out.is_relative_to(root / 'selfhost/build/phase60') and not out.exists()
receipt = out.with_name(out.name + '-command-time.json')
assert not receipt.exists()
command = [str(out) if arg == 'FRESH_PHASE60_OUTPUT' else arg for arg in selection['argv']]
for item in plan['inputs']:
    assert hashlib.sha256(Path(item['file']).read_bytes()).hexdigest() == item['sha256']
start = time.monotonic()
result = subprocess.run(command, cwd=root)
elapsed = time.monotonic() - start
with receipt.open('x') as stream:
    json.dump(dict(complete=True, subset=subset, command=command,
                   planSha256=hashlib.sha256(plan_bytes).hexdigest(),
                   producerSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                   wholeCommandWallSeconds=elapsed, exitCode=result.returncode,
                   scope='Includes child runner CLI preflight; excludes this wrapper plan verification and reused preparation.'), stream, indent=2)
    stream.write('\n')
raise SystemExit(result.returncode)
