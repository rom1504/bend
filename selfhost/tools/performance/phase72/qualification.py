#!/usr/bin/env python3
"""Join completed release evidence and independently verify old-release retention."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase72'
def pin(p):return dict(path=str(p.relative_to(ROOT)),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
p=json.loads((RAW/'compiler02-qualification-method/plan.json').read_text());receipts=[]
for n in ['self-check','fixed-point']:
 f=RAW/'compiler02-release-qualification'/n/'report.json';r=json.loads(f.read_text());assert r['complete'] and r['pass'];receipts.append(pin(f))
for f in (RAW/'compiler02-C-identity12/runs').glob('clean-*-b2/report.json'):
 r=json.loads(f.read_text());assert r['complete'] and r['pass'];receipts.append(pin(f))
assert len(receipts)==14
for job in p['deferredReleaseCommands']:
 f=RAW/'release-compiler02'/('job-'+job['name'])/'process.json';r=json.loads(f.read_text());assert r['complete'] and r['returncode']==0;receipts.append(pin(f))
history=ROOT/'selfhost/dist/release-history/386ae358ee8fe33c5af3f7fec16f956b59451ee6004da99a94146140d3e8a162';preserved=[]
for before in p['installedBefore']:
 f=history/Path(before['file']).relative_to(ROOT/'selfhost/dist');r=pin(f);assert r['sha256']==before['sha256'] and r['bytes']==before['bytes'];preserved.append(r)
images=json.loads((RAW/'compiler02-b2/image-pins.json').read_text());installed=pin(ROOT/'selfhost/dist/typed-api.mjs');assert installed['sha256']==images['b1']['sha256']
result=dict(complete=True,producer=pin(Path(__file__)),installed=installed,b2=images['b2'],source=images['source'],receipts=receipts,preservedOldRelease=preserved,scope='Selected B1 installed; genuine B2 own-source acceptance/exact B3, twelve complete C identities, six release jobs. Unexecuted B1 jobs in the C-identity plan are not claimed; its B2 twelve-job subset is complete.')
out=ROOT/'implementation/phase72/qualification.json';assert not out.exists();out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(receipts=len(receipts),oldFilesPreserved=len(preserved),installed=installed['sha256'])))
