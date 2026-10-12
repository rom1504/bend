#!/usr/bin/env python3
"""Join completed release evidence and independently verify old-release retention."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase73'
def pin(p):return dict(path=str(p.relative_to(ROOT)),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
p=json.loads((RAW/'compiler14-qualification-method/plan.json').read_text());receipts=[]
for n in ['self-check','fixed-point']:
 f=RAW/'compiler14-release-qualification'/n/'report.json';r=json.loads(f.read_text());assert r['complete'] and r['pass'];receipts.append(pin(f))
for f in (RAW/'compiler14-C-identity12/runs').glob('clean-*-b2/report.json'):
 r=json.loads(f.read_text());assert r['complete'] and r['pass'];receipts.append(pin(f))
assert len(receipts)==14
for job in p['deferredReleaseCommands']:
 f=RAW/'release-compiler14'/('job-'+job['name'])/'process.json';r=json.loads(f.read_text());assert r['complete'] and r['returncode']==0;receipts.append(pin(f))
history=ROOT/'selfhost/dist/release-history/0ab62a7a075d7a3574cbb2d797dee696955b70c79fdddb85623ec95d6b961e44';preserved=[]
for before in p['installedBefore']:
 f=history/Path(before['file']).relative_to(ROOT/'selfhost/dist');r=pin(f);assert r['sha256']==before['sha256'] and r['bytes']==before['bytes'];preserved.append(r)
images=json.loads((RAW/'compiler14-b2/image-pins.json').read_text());installed=pin(ROOT/'selfhost/dist/typed-api.mjs');assert installed['sha256']==images['b1']['sha256']
gates=[]
for name in ['compiler14/validation-001','compiler14-new12/execution','compiler14-raw31/execution']:
 f=RAW/name/'report.json';r=json.loads(f.read_text());assert r['complete'] and r['pass'];gates.append(pin(f))
f=RAW/'compiler14-js-identity/report.json';r=json.loads(f.read_text());assert r['complete'] and r['unchangedFunctions']==2992;gates.append(pin(f))
f=RAW/'compiler14-threads-controls/report.json';r=json.loads(f.read_text());assert r['complete'] and len(r['records'])==24 and len(r['shapes'])==6;gates.append(pin(f))
# The paired native controller correctly returns failure for the seven retained
# upstream disagreements. Check both exact outcome inventories, not just totals.
known=[]
for role in ['candidate','reference']:
 f=RAW/f'compiler14-native100/execution/selected/{role}.json';r=json.loads(f.read_text())
 old=ROOT/f'selfhost/build/phase72/compiler02-native100/execution/selected/{role}.json';before=json.loads(old.read_text())
 outcomes=lambda x:[(row['id'],row['lane'],row['status']) for row in x['results']]
 assert outcomes(r)==outcomes(before)
 assert sum(row['status']=='pass' for row in r['results'])==(100 if role=='candidate' else 93)
 gates += [pin(f),pin(old)]
 if role=='reference':known=[row['id'] for row in r['results'] if row['status']!='pass']
assert len(known)==7
result=dict(complete=True,producer=pin(Path(__file__)),installed=installed,b2=images['b2'],source=images['source'],receipts=receipts,preservedOldRelease=preserved,gates=gates,knownReferenceFailures=known,scope='Selected B1 installed; genuine B2 own-source acceptance/exact B3, twelve complete C identities, six release jobs. Unexecuted B1 jobs in the C-identity plan are not claimed; its B2 twelve-job subset is complete.')
out=ROOT/'implementation/phase73/qualification.json';assert not out.exists();out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(receipts=len(receipts),oldFilesPreserved=len(preserved),installed=installed['sha256'])))
