"""Execute frozen RFC word/refusal controls under the root process guard."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[5]
def pin(p):
    p = Path(p).resolve()
    b = p.read_bytes()
    return dict(file=str(p), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
m = json.loads(a.plan.read_text())
assert m['kind'] == 'phase144-rfc-word-controls-v01'
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
inputs = [pin(__file__), pin(a.plan), *m['inputs']]
for x in inputs:
    assert pin(x['file']) == x
out.mkdir(parents=True)
r = dict(kind='phase144-rfc-word-controls-run', complete=False, inputs=inputs, jobs=[])
save = lambda: (out/'report.json').write_text(json.dumps(r, indent=2)+'\n')
save()
try:
    for j in m['commands']:
        start = time.monotonic()
        child = subprocess.run(j['argv'], cwd=ROOT, capture_output=True, timeout=30)
        row = dict(label=j['label'], command=j['argv'], seconds=time.monotonic()-start,
                   exitCode=child.returncode, stdout=child.stdout.decode(), stderr=child.stderr.decode())
        r['jobs'].append(row)
        save()
        assert child.returncode == j['exit'], row
        for name in ['stdout', 'stderr']:
            if name in j:
                assert row[name] == j[name], row
        row['expectedExact'] = True
    for x in inputs:
        assert pin(x['file']) == x
    r['complete'] = True
except BaseException as e:
    r['error'] = repr(e)
finally:
    save()
print(json.dumps({k:r[k] for k in ['complete','error'] if k in r}))
raise SystemExit(0 if r['complete'] else 1)
