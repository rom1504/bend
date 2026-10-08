#!/usr/bin/env python3
"""Document exact new-Base permission only after closed integration evidence."""
from pathlib import Path
import difflib, hashlib, json, os

assert os.sched_getaffinity(0) == {0}
OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[4]
sha = lambda raw: hashlib.sha256(raw).hexdigest()
parent = json.loads((OUT/'documentation-v2.json').read_text())
assert sha((OUT/'documentation-v2.patch').read_bytes()) == parent['patchSha256']
integration_path = ROOT/'selfhost/build/phase66/integration-base-annotations01.json'
integration_raw = integration_path.read_bytes()
integration = json.loads(integration_raw)
assert integration['complete'] and integration['pass']
evidence = [{'file':str(integration_path.relative_to(ROOT)), 'sha256':sha(integration_raw)}]
assert sha((ROOT/'selfhost/tools/typed-driver.mjs').read_bytes()) == integration['proposal']['afterSha256']
for row in integration['controls']:
    raw = (ROOT/row['file']).read_bytes()
    assert sha(raw) == row['sha256']
    report = json.loads(raw)
    assert report['complete'] and report['pass'] and report['inputsUnchanged']
    assert report['generation']['candidate']['sha256'] == integration['proposal']['afterSha256']
    evidence.append(row)

before, after = {}, {}
for row in parent['files']:
    name = row['path']
    before[name] = (OUT/'before-v2'/name).read_bytes()
    raw = (ROOT/row['candidate']).read_bytes()
    assert sha(before[name]) == row['beforeSha256']
    assert sha(raw) == row['afterSha256']
    assert sha((ROOT/name).read_bytes()) == row['beforeSha256']
    after[name] = raw.decode()

def replace(name, old, new):
    assert after[name].count(old) == 1, (name,old)
    after[name] = after[name].replace(old,new)

replace('selfhost/README.md', '''marshalling. The new Base needs fresh prepared artifacts. Optional annotation
products require their own exact-content qualification; see the
[Base contract](../implementation/phase66/base-host.md).''', '''marshalling. The new Base needs fresh prepared artifacts. Its exact-content
optional annotation permission passed actual owned/product and custom-Base
fallback controls before being enabled; see the
[Base contract](../implementation/phase66/base-host.md).''')
replace('selfhost/docs/ARCHITECTURE.md', '''## Historical Phase65 installed integration''', '''The new Base's optional annotation permission was enabled only after fresh
checked-image producer, complete-product, owned-route and custom-Base controls.
It admits exactly `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`;
custom or later Base bytes use ordinary annotation. This changes an existing
permission, not the frame4/world3 formats or the product algorithm. See the
[Base qualification](../../implementation/phase66/base-host.md).

## Historical Phase65 installed integration''')
replace('docs/BEND-IN-BEND.md', '''Optional products for the updated Base require independent qualification; old
prepared data or benchmark ratios do not transfer by changing a pin.''', '''Optional products for the exact updated Base passed independent qualification
before permission was enabled; custom or later Base bytes retain ordinary
annotation. Old prepared data or benchmark ratios do not transfer by changing
a pin. See the [Base qualification](../implementation/phase66/base-host.md).''')
replace('docs/self_hosted/prepared-base-artifacts.md', '''an old Base frame is not relabeled. The initial migration keeps optional
annotations disabled for this Base. Their permission may change only after
fresh complete-product, whole-module, owned-route and custom-Base controls;
the [Phase66 Base report](../../implementation/phase66/base-host.md) records
that separate qualification and the actual selected permission.''', '''an old Base frame is not relabeled. The initial migration denied optional
annotations until their new producer and consumers were qualified. Fresh
checked-attempt03 controls then passed complete-product, whole-module,
owned-route and custom-Base fallback checks. The selected host now permits
optional production and reading only for the exact new hash above. Its driver
SHA256 is `e093483d5103a8e833b6ca710246b1ec3c579b7fac5060c8e42f626c5e25ec85`.
The [Phase66 Base report](../../implementation/phase66/base-host.md) records
these closed gates and their source/image identities. This is an independently
qualified replacement of the historical permission below, not permission for
arbitrary updated Base bytes.''')
replace('docs/self_hosted/prepared-base-artifacts.md', '''does not implicitly create an optional sidecar. While new-Base permission is
absent, explicit preparation also omits optional annotation products; later
compilation uses ordinary annotation.''', '''does not implicitly create an optional sidecar. Explicit preparation on the
qualified new Base also creates the optional product. A different/custom Base
omits it and later compilation uses ordinary annotation. Current stops,
request ownership, compiler/API identity and full parent-graph validation remain
required after exact-content permission; a matching Base alone is insufficient.''')
replace('docs/self_hosted/compiler-request-pipeline.md', '''New-Base mandatory state uses fresh identities; optional annotations require
their own content permission and qualification.''', '''New-Base mandatory state uses fresh identities. Optional annotations were
enabled for the exact new Base only after independent checked-image product,
owned-route and custom-Base fallback qualification.''')

rows, patch = [], []
for name in sorted(after):
    b, a = before[name], after[name].encode()
    for prefix, raw in [('before-v3',b),('candidate-v3',a)]:
        p=OUT/prefix/name;p.parent.mkdir(parents=True,exist_ok=True)
        with p.open('xb') as f:f.write(raw)
    rows.append({'path':name,'beforeSha256':sha(b),'afterSha256':sha(a),
        'beforeBytes':len(b),'afterBytes':len(a),'candidate':str((OUT/'candidate-v3'/name).relative_to(ROOT))})
    patch += list(difflib.unified_diff(b.decode().splitlines(True),a.decode().splitlines(True),fromfile='a/'+name,tofile='b/'+name))
raw=''.join(patch).encode()
with (OUT/'documentation-v3.patch').open('xb') as f:f.write(raw)
meta=dict(parent,version=3,files=rows,patchSha256=sha(raw),producerSha256=sha(Path(__file__).read_bytes()),
    parentPatchSha256=parent['patchSha256'],newBasePermissionEvidence=evidence,
    permissionDriverSha256=integration['proposal']['afterSha256'],
    pending=[x for x in parent['pending'] if x!='New-Base optional product permission result'])
with (OUT/'documentation-v3.json').open('x') as f:json.dump(meta,f,indent=2);f.write('\n')
print(json.dumps({'files':len(rows),'patchSha256':sha(raw),'status':meta['status']}))
