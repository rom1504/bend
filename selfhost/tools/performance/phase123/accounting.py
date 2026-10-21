"""Account for serial guarded work, including failed attempts, without double counting."""
import argparse
import datetime
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
rows = []
for file in sorted((ROOT / 'selfhost/build/phase123').glob('*guard*/process.json')):
    r = json.loads(file.read_text())
    assert 'finished' in r, 'Guard still active: ' + str(file)
    command = ' '.join(r['command'])
    if 'check-api.py' in command:
        category = 'checked API acquisition'
    elif 'cost-v2.mjs' in command or 'stage-cost.mjs' in command:
        category = 'compiler cost measurement'
    elif 'emit-integrated.mjs' in command:
        category = 'checked program emission'
    elif 'screen.py' in command or 'functional-v2.py' in command or 'replay.py' in command:
        category = 'native build and output/runtime measurement'
    else:
        category = 'finite controls and analysis'
    raw = file.read_bytes()
    rows.append(dict(file=str(file.relative_to(ROOT)), sha256=hashlib.sha256(raw).hexdigest(),
                     category=category, **r))
ordered = sorted(rows, key=lambda x: x['started'])
assert all(a['finished'] <= b['started'] + 0.01 for a, b in zip(ordered, ordered[1:])), 'Overlapping target lanes'
groups = {}
for row in rows:
    group = groups.setdefault(row['category'], dict(attempts=0, failures=0, wallSeconds=0, failedWallSeconds=0))
    group['attempts'] += 1
    group['wallSeconds'] += row['wallSeconds']
    if not row['complete']:
        group['failures'] += 1
        group['failedWallSeconds'] += row['wallSeconds']
start = datetime.datetime.fromisoformat('2026-10-21T19:22:05+00:00')
now = datetime.datetime.now(datetime.timezone.utc)
result = dict(complete=True, started=start.isoformat(), measuredThrough=now.isoformat(),
              elapsedWallSeconds=(now-start).total_seconds(), guardedWallSeconds=sum(x['wallSeconds'] for x in rows),
              maximumTreeRssBytes=max(x['peakTreeRssBytes'] for x in rows),
              minimumAvailableBytes=min(x['minimumAvailableBytes'] for x in rows),
              categories=groups, rows=rows,
              scope='Guarded wall time includes child compilation, output checks and timing. Categories are exclusive. Failures are included, not added again. Agent inference/token cost and unguarded editing/disassembly are not metered; residual wall time is not a measurement of inference time.')
a.out.parent.mkdir(parents=True, exist_ok=True)
a.out.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k != 'rows'}, indent=2))
