#!/usr/bin/env python3
"""Reuse a fresh, same-entry String proof at structurally verified contextual roots."""
import argparse
import hashlib
import json
from pathlib import Path
import re

def identity(path):
    path = Path(path).resolve(strict=True); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('--module', type=Path, required=True)
ap.add_argument('--sha256', required=True)
ap.add_argument('--out', type=Path, required=True)
a = ap.parse_args(); assert not a.out.exists(), 'Fresh output only'
parent = identity(a.module); producer = identity(__file__)
assert parent['sha256'] == a.sha256
original = a.module.read_text(); assert 'stringHostChecked' not in original
capture = 'const callbackU32Guard={__proto__:null};'
new_capture = capture + 'const stringHostChecked={__proto__:null};'
test = 'if(capability!==callbackU32Guard)'
new_test = 'if(capability!==callbackU32Guard&&capability!==stringHostChecked)'
assert original.count(capture) == original.count(test) == 1
pattern = re.compile(r'fn\((\d+),exactCode\(function\(a,\$entered\)\{((?:let \$s\d+=a\[\d+\];)*)if\(\$entered&&regionProof===null&&regionHostGuard\(\)&&stringHostGuard\(\)&&([^\n]*?)&&localGuard\(\$guards\)\)\{/\* private contextual instances \*/')
edits = []

def replace(match):
    arity = int(match[1]); assert 0 <= arity <= 8
    assert match[2] == ''.join('let $s%d=a[%d];' % (i, i) for i in range(arity))
    remaining = match[3]; kinds = []
    for i in range(arity):
        s = '$s' + str(i)
        predicates = {
            'U32': f'(typeof {s}==="number"&&Number.isInteger({s})&&{s}>=0&&{s}<=4294967295)',
            'Bool': f'(typeof {s}==="boolean")',
            'Nat': f'(typeof {s}==="bigint"&&{s}>=0n&&{s}<=281474976710655n)',
            'F32': f'(typeof {s}==="number"&&(Math.fround({s})==={s}||Number.isNaN({s})))',
        }
        accepted = [(k, p) for k, p in predicates.items() if remaining.startswith(p + '&&')]
        assert len(accepted) == 1, 'Unknown input check: refuse proof reuse'
        kind, predicate = accepted[0]; kinds.append(kind); remaining = remaining[len(predicate) + 2:]
    assert remaining == 'true'
    edits.append(dict(characterOffset=match.start(), arity=arity, scalarKinds=kinds,
                      proof='All source argument reads precede fresh full host and String checks; only validated scalar/native predicates precede localGuard.'))
    return match[0].replace('localGuard($guards)', 'localGuard($guards,stringHostChecked)')

changed = pattern.sub(replace, original)
assert edits and len(edits) == original.count('/* private contextual instances */'), 'Every contextual entry must have the proved shape'
changed = changed.replace(capture, new_capture).replace(test, new_test)
assert changed.replace(new_capture, capture).replace(new_test, test).replace('localGuard($guards,stringHostChecked)', 'localGuard($guards)') == original
a.out.mkdir(parents=True)
target = a.out / 'same-entry-string-proof.mjs'; target.write_text(changed)
(a.out / 'consumed-guards-token-derive.py').write_bytes(Path(__file__).read_bytes())
assert identity(a.module) == parent and identity(__file__) == producer
report = dict(kind='phase51-same-entry-string-proof', complete=True, qualified=False, installed=False,
              targetExecution=False, parent=parent, candidate=identity(target), producer=producer, edits=edits,
              scope='A private token suppresses only the second String-family scan after a fresh successful String proof. No cross-entry cache, public entry permission change, moved argument read, or removed dependency/prototype check.')
(a.out / 'derivation.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(dict(complete=True, sites=len(edits), report=identity(a.out / 'derivation.json'))))
