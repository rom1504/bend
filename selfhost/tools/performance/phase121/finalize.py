"""Index completed Phase121 evidence without selecting an installed compiler."""
import argparse, hashlib, json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
def read(f): return json.loads((ROOT/f).read_text())
def pin(f):
    f = (ROOT/f).resolve(); b = f.read_bytes()
    return dict(file=str(f), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())
def checked(f):
    r = read(f); assert r['complete'], f
    return r
def save(f, r):
    assert not f.exists(), f
    f.write_text(json.dumps(r, indent=2)+'\n')
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, default=ROOT/'implementation/phase121')
a = p.parse_args(); a.out.mkdir(parents=True, exist_ok=True)
sm = 'selfhost/build/phase121/fusion-source04/manifest.json'
ar = 'selfhost/build/phase111/p121-api04/report.json'
em = 'selfhost/build/phase118/p121-broad-emit04/report.json'
oldem = 'selfhost/build/phase118/safe-broad-emit04/report.json'
s, api, emitted, old = map(checked, [sm, ar, em, oldem])
assert api['checked'] and s['source'] in api['inputs'] and emitted['source'] == s['source']
assert emitted['runtime'] == old['runtime'] and len(emitted['cases']) == len(old['cases']) == 45
for item in [s['source'], api['api'], emitted['runtime'], *s['inputs']]: assert pin(item['file']) == item
bridge = []
for row in emitted['cases']:
    before = next(x for x in old['cases'] if x['name'] == row['name'])
    assert row['verified'] and before['verified'] and row['source'] == before['source']
    for item in [row['qbe'], before['qbe']]: assert pin(item['file']) == item
    bridge.append(dict(name=row['name'], parent=before['qbe'], candidate=row['qbe'],
                       byteIdentical=Path(row['qbe']['file']).read_bytes()==Path(before['qbe']['file']).read_bytes()))
fastfile = 'selfhost/build/phase118/p121-fusion-emit04/report.json'
fast = checked(fastfile)
assert fast['source'] == emitted['source'] and fast['runtime'] == emitted['runtime']
for row in fast['cases']:
    broadrow = next(x for x in emitted['cases'] if x['name']==row['name'])
    assert row['source'] == broadrow['source'] and pin(row['qbe']['file']) == row['qbe']
    assert Path(row['qbe']['file']).read_bytes() == Path(broadrow['qbe']['file']).read_bytes()
costfile = 'selfhost/build/phase118/p121-cost04/report.json'
cost = checked(costfile); assert len(cost['rows']) == 24
control_files = ['selfhost/build/phase121/admission05.json',
                 'selfhost/build/phase118/p121-controls-run04/report.json']
controls = [checked(f) for f in control_files]
assert len(controls[0]['rows']) == 9 and all(x['admitted']==x['expected']==x['emitted'] for x in controls[0]['rows'])
assert len(controls[1]['rows']) == 3 and all(x['status']==0 for x in controls[1]['rows'])
broadfile = 'selfhost/build/phase121/broad-analysis04.json'
broad = checked(broadfile)
longfile = 'selfhost/build/phase121/long-summary04.json'
long = checked(longfile)
machinefile = 'selfhost/build/phase121/machine04/report.json'; checked(machinefile)
candidate = dict(complete=True, experimental=True, installed=False, nativeQualified=False,
                 source=s['source'], api=api['api'], runtime=emitted['runtime'],
                 sourceManifest=pin(sm), checkedApi=pin(ar), emission=pin(em),
                 controls=[pin(f) for f in control_files], timing=pin(broadfile),
                 longTiming=pin(longfile), compilerCost=pin(costfile), machine=pin(machinefile),
                 recipe=pin('selfhost/tools/performance/phase121/candidate-recipe.json'),
                 scope='Checked-hosted source04 on qualified Phase118, without Phase120 numeric modules. Original45 correctness/timing and focused controls; no new native image, N1/N2 measurement or installed promotion.')
save(a.out/'candidate.json', candidate)
save(a.out/'results.json', dict(complete=True, method=pin(__file__), candidate=candidate,
     broad=broad, longTiming=long,
     compilerCost=dict(receipt=pin(costfile), summaries=cost['summaries'],
                       geometricCandidateOverParent=cost['geometricCandidateOverParent'],
                       geometricAdmittedCandidateOverParent=cost['geometricAdmittedCandidateOverParent']),
     exactParentQbeBridge=dict(parent=pin(oldem), candidate=pin(em), rows=bridge),
     exactFastBroadBridge=dict(fast=pin(fastfile), broad=pin(em), cases=len(fast['cases'])),
     sourceLines=dict(parent=s['parentLines'], candidate=s['physicalLines']),
     addedDeclarations=len(s['added'])))
print(json.dumps(dict(complete=True, runtimeRatio=broad['equalPoint']['candidateOverUpstream'],
                     relativeRuntime=broad['equalPoint']['candidateOverBaseline'],
                     compilerCostRatio=cost['geometricCandidateOverParent'],
                     identicalPrograms=sum(x['byteIdentical'] for x in bridge))))
