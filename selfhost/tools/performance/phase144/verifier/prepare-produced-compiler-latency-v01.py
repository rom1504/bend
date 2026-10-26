"""Prepare one exact-output request measuring generated-compiler quality."""
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[5]


def pin(p):
    p = Path(p).resolve()
    h = hashlib.sha256()
    size = 0
    with p.open('rb') as f:
        while chunk := f.read(1024*1024):
            h.update(chunk)
            size += len(chunk)
    return dict(file=str(p), bytes=size, sha256=h.hexdigest())


def read(p):
    return json.loads(Path(p).read_text())


baseline_file = ROOT/'selfhost/build/phase130/p144-final03-fixed-cold01/report.json'
product_file = ROOT/'selfhost/build/phase134/p144-range-fast-final03-product01/report.json'
original_file = ROOT/'selfhost/build/phase134/p144-final03-n2/report.json'
baseline, product, original = map(read, [baseline_file, product_file, original_file])
assert all(r['complete'] for r in [baseline, product, original])
assert product['source'] == original['source']
assert product['source']['sha256'] == '31e1b13a8584130c6a6be67ef6e1f2a6a373433c9c5cac9e880fa3fe403e3ea2'
assert product['runtime'] == original['runtime'] and baseline['image'] == original['binary']
assert baseline['product']['sha256'] == 'ac29be094a56cb5e5125b7982a083a15b8e2d5f8c3505b7c1e484c65675abd36'
guard = ROOT/'selfhost/tools/performance/phase111/guard.py'
request = ROOT/'selfhost/tools/performance/phase130/native-request.py'
carrier = ROOT/'selfhost/build/phase130/base-carrier01/receipt.json'
out = ROOT/'selfhost/build/phase144/range-produced-latency-plan01'
dest = ROOT/'selfhost/build/phase130/p144-range-produced-final03-fixed142-01'
assert not out.exists() and not dest.exists()
inputs = [pin(__file__), pin(baseline_file), pin(product_file), pin(original_file),
    product['binary'], product['source'], product['runtime'], baseline['image'], baseline['source'],
    baseline['product'], pin(guard), pin(request), pin(carrier)]
for p in inputs:
    assert pin(p['file']) == p
command = [sys.executable, '-B', str(guard), '--out', str(out/'request-guard'),
    '--seconds', '630', '--cpu', '3', '--rss-mib', '3072', '--available-mib', '16384',
    '--file-mib', '256', '--', sys.executable, '-B', str(request),
    '--image', product['binary']['file'], '--source', baseline['source']['file'],
    '--carrier-receipt', str(carrier), '--expected-qbe', baseline['product']['file'],
    '--out', str(dest), '--seconds', '600']
report = dict(kind='phase144-produced-compiler-latency-plan', complete=True, targetsRun=False,
    selected=False, inputs=inputs, compilerSource=product['source'], actualLinkedRuntime=product['runtime'],
    baseline=dict(image=baseline['image'], receipt=pin(baseline_file), nativeSeconds=baseline['nativeSeconds']),
    candidate=dict(image=product['binary'], build=pin(product_file), report=str(dest/'report.json')),
    input=baseline['source'], exactQbeOracle=baseline['product'],
    jobs=[dict(name='produced-full-policy-compiler-fixed142', seconds=660, command=command)],
    scope='Both executables implement identical final03 source with normal full-range policy and link the same serial runtime. They differ only in the policy used to produce their machine code. One fixed-input request isolates generated-compiler runtime; exact ac29 QBE is mandatory. This is separate from fast-policy compilation savings, and one pair is exploratory.')
out.mkdir()
(out/'jobs.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(dict(plan=pin(out/'jobs.json'), image=product['binary'], exactOracle=baseline['product'])))
