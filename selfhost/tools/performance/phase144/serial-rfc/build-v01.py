"""Build/relink the frozen serial-RFC comparison; root guard owns resources."""
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
p.add_argument('--manifest', type=Path, required=True)
a = p.parse_args()
m = json.loads(a.manifest.read_text())
assert m['complete'] and m['kind'] == 'phase144-serial-rfc-preparation-v01'
out = a.manifest.resolve().parent
assert out.is_relative_to(ROOT/'selfhost/build/phase144')
assert not (out/'build.json').exists()
inputs = [pin(__file__), pin(a.manifest), *m['inputs'], *m['outputs']]
for x in inputs:
    assert pin(x['file']) == x
r = dict(kind='phase144-serial-rfc-build', complete=False, inputs=inputs, jobs=[], variants={})
save = lambda: (out/'build.json').write_text(json.dumps(r, indent=2)+'\n')
save()
try:
    for j in m['commands']:
        row = dict(label=j['label'], command=j['argv'])
        r['jobs'].append(row)
        save()
        start = time.monotonic()
        with (out/(j['label']+'.stdout')).open('xb') as so, (out/(j['label']+'.stderr')).open('xb') as se:
            child = subprocess.run(j['argv'], cwd=ROOT, stdout=so, stderr=se, timeout=60)
        row.update(seconds=time.monotonic()-start, exitCode=child.returncode)
        assert child.returncode == 0
        save()
    for name in ['atomic-control', 'serial-rfc']:
        r['variants'][name] = dict(object=pin(out/(name+'.o')), binary=pin(out/(name+'-compiler')))
    r['atomicObjectByteIdenticalToQualified'] = (out/'atomic-control.o').read_bytes() == (ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.o').read_bytes()
    for x in inputs:
        assert pin(x['file']) == x
    r['complete'] = True
except BaseException as e:
    r['error'] = repr(e)
finally:
    save()
print(json.dumps({k:r[k] for k in ['complete','atomicObjectByteIdenticalToQualified','error'] if k in r}))
raise SystemExit(0 if r['complete'] else 1)
