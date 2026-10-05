#!/usr/bin/env python3
"""Create three unsafe, clean-host-only RLE guard diagnostics; execute nothing."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PINS = {
    'baseline': 'd62ccfa7e27ef5124877c736b6ed4d39ee507b049b4a86e10b03c0c6b8530c4a',
    'candidate': 'f59106924fdc8022725ea8d722e600bd7d291a4aeb3f10525ea7b11505dfa835',
}
OLD = b'if($entered&&regionProof===null&&regionHostGuard()&&stringHostGuard()&&true&&localGuard($guards))'
BYPASS = b'if($entered&&regionProof===null)'
NAMES = ['lrepeat', 'lconcat', 'expand', 'digest.go', 'digest', 'llenp', 'bu',
         'rle.step', 'lrevp.go', 'lrevp', 'rle', 'go', 'main.out',
         'U32.to_nat', 'U32.add', 'U32.mul', 'U32.is_eq']

def sha(blob):
    return hashlib.sha256(blob).hexdigest()

def identity(path):
    path = Path(path).resolve(strict=True)
    blob = path.read_bytes()
    return dict(path=str(path), bytes=len(blob), sha256=sha(blob))

ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('--out', type=Path, required=True, help='Fresh directory under selfhost/build/phase49')
args = ap.parse_args()
out = args.out.resolve()
assert out.is_relative_to(ROOT / 'selfhost/build/phase49'), 'Phase49 diagnostic output only'
assert not out.exists(), 'Never overwrite consumed evidence'
producer = identity(__file__)
parents = {}
for role, expected in PINS.items():
    path = HERE / 'inputs' / (role + '.mjs')
    item = identity(path)
    assert item['sha256'] == expected, role + ': frozen input changed'
    blob = path.read_bytes()
    assignments = list(re.finditer(rb'(?m)^G\["main\.out"\]=[^\n]+$', blob))
    assert len(assignments) == 1 and blob.count(b'G["main.out"]=') == 1
    assignment = assignments[0]
    root = assignment.group()
    assert root.startswith(b'G["main.out"]=scalarCapture("main.out",')
    assert root.endswith(b'})(),false);')
    assert blob.count(OLD) == root.count(OLD) == 1, 'Exact unique guarded entry required'
    assert root.count(b'/* private contextual instances */') == 1
    start = assignment.start() + root.index(OLD)
    assert blob[start + len(OLD):].startswith(b'{/* private contextual instances */return ')
    lists = re.findall(rb'const \$guards=\[([^\]]*)\];return fn\(', root)
    assert len(lists) == 1
    names = json.loads(b'[' + lists[0].rstrip(b',') + b']')
    assert names == NAMES
    parents[role] = dict(identity=item, blob=blob, root=root, at=start)

variants = []
for name, role, replacement in [
    ('baseline-guard-bypass', 'baseline', BYPASS),
    ('candidate-guard-bypass', 'candidate', BYPASS),
    ('baseline-string-omitted', 'baseline', OLD.replace(b'&&stringHostGuard()', b'')),
]:
    p = parents[role]
    original, at = p['blob'], p['at']
    changed = original[:at] + replacement + original[at + len(OLD):]
    assert changed[:at] == original[:at]
    assert changed[at + len(replacement):] == original[at + len(OLD):]
    assert changed[:at] + OLD + changed[at + len(replacement):] == original
    assert changed.count(replacement) == 1
    variants.append((name, changed, dict(
        name=name, parent=p['identity'], productionSafe=False, checked=False,
        installationEligible=False, classification='unsafe-clean-host-diagnostic',
        edit=dict(byteOffset=at, old=OLD.decode(), new=replacement.decode()),
        rootBefore=dict(bytes=len(p['root']), sha256=sha(p['root'])),
        unchangedPrefixSha256=sha(original[:at]),
        unchangedSuffixSha256=sha(original[at + len(OLD):]),
        scope='One main.out guard expression only. Exact-entry and null-region checks, '
              'private computation, dependency names, public descriptor and original fallback are unchanged. '
              'Fresh host/dependency admission is bypassed or reduced; this is not production-equivalent.'
    )))

out.mkdir(parents=True)
(out / 'consumed-derive-guard-probe.py').write_bytes(Path(__file__).read_bytes())
rows = []
for name, blob, row in variants:
    target = out / (name + '.mjs')
    with target.open('xb') as stream:
        stream.write(blob)
    row['module'] = identity(target)
    rows.append(row)
for p in parents.values():
    assert identity(p['identity']['path']) == p['identity']
assert identity(__file__) == producer
report = dict(
    kind='phase49-unsafe-rle-guard-derivation', complete=True, producer=producer,
    targetExecution=False, productionSafe=False, checked=False, installationEligible=False,
    classification='unsafe-clean-host-diagnostic',
    inputs=[p['identity'] for p in parents.values()], variants=rows,
    staticDependencyNames=NAMES,
    caveats=[
        'No String operation appears in the 17 dependency names; this is static context, not an omission proof.',
        'No result, activation, syntax or performance check has been executed by this producer.',
        'Use separate fresh-process checked-oracle diagnostics; do not install or promote these modules.',
        'No permission result is cached. The full bypass measures a clean-host upper bound, not a legal optimization.',
        'Retain both original roles and the String-only ablation separately; do not multiply their gains.',
    ],
)
with (out / 'derivation.json').open('x') as stream:
    json.dump(report, stream, indent=2)
    stream.write('\n')
print(json.dumps(dict(complete=True, variants=len(rows), productionSafe=False,
                      derivation=identity(out / 'derivation.json'))))
