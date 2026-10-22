"""Account for the serial measurement lane, retaining failed attempts."""
import argparse, datetime, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args()
assert not a.out.exists()
rows=[]
for f in sorted((ROOT/'selfhost/build/phase125').glob('*guard*/process.json')):
    r=json.loads(f.read_text());assert 'finished' in r, str(f)
    rows.append(dict(file=str(f.relative_to(ROOT)),sha256=hashlib.sha256(f.read_bytes()).hexdigest(),**r))
rows.sort(key=lambda r:r['started'])
assert all(x['finished']<=y['started']+.01 for x,y in zip(rows,rows[1:])), 'Overlapping target lanes'
def category(command):
    c=' '.join(command)
    if 'qualification' in c: return 'native self-hosting qualification'
    if 'transport' in c or 'timing-run' in c: return 'native compiler timing'
    if 'cost-v2.mjs' in c: return 'hosted compiler timing'
    if 'check-api' in c or 'api-plan' in c: return 'checked API acquisition'
    if 'emit-integrated' in c or 'emit-plan' in c: return 'checked program emission'
    if 'screen' in c or 'repeat-products' in c: return 'program execution and correctness'
    if 'counts/' in c: return 'allocation diagnostics'
    return 'controls, runtime builds and bounded diagnostics'
groups={}
for r in rows:
    g=groups.setdefault(category(r['command']),dict(attempts=0,failures=0,wallSeconds=0,failedWallSeconds=0))
    g['attempts']+=1;g['wallSeconds']+=r['wallSeconds']
    if not r['complete']:g['failures']+=1;g['failedWallSeconds']+=r['wallSeconds']
start=datetime.datetime.fromisoformat('2026-10-22T20:50:53+00:00');now=datetime.datetime.now(datetime.timezone.utc)
r=dict(complete=True,started=start.isoformat(),measuredThrough=now.isoformat(),elapsedWallSeconds=(now-start).total_seconds(),
       guardedWallSeconds=sum(x['wallSeconds'] for x in rows),maximumTreeRssBytes=max(x['peakTreeRssBytes'] for x in rows),
       minimumAvailableBytes=min(x['minimumAvailableBytes'] for x in rows),categories=groups,rows=rows,
       scope='Exclusive outer-guard categories; mixed plans include their child jobs and setup. Failed attempts are included once. Child job receipts provide finer stage splits. Editing, agent reasoning, quota and billing are not metered; residual wall time must not be called inference time.')
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps({k:v for k,v in r.items() if k!='rows'},indent=2))
