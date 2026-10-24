#!/usr/bin/env python3
"""Archive completed first-stream checkpoint evidence; data only, no targets."""
import gzip, hashlib, io, json, tarfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[4]
OUT=ROOT/'implementation/phase134/stream'
FILES={
 'source-manifest.json':'selfhost/build/phase134/stream-source02/manifest.json',
 'checked-api.json':'selfhost/build/phase111/p134-stream-api02/report.json',
 'finite.json':'selfhost/build/phase128/p134-stream-finite03/report.json',
 'qualification.json':'selfhost/build/phase134/stream-qualification01.json',
 'acquisition.json':'selfhost/build/phase130/p134-acquisition01/report.json',
 'self-emission.json':'selfhost/build/phase130/p134-self01/report.json',
 'n1-build.json':'selfhost/build/phase111/p134-n1/report.json',
 'n2-build.json':'selfhost/build/phase111/p134-n2/report.json',
 'n1-focused.json':'selfhost/build/phase111/p134-n1-validation01-focused19/report.json',
 'n2-focused.json':'selfhost/build/phase111/p134-n2-validation01-focused19/report.json',
 'n2-ordinary45.json':'selfhost/build/phase111/p134-n2-validation01-ordinary45/report.json',
 'timing.json':'selfhost/build/phase112/p134-stream-timing01/report.json',
 'timing-summary.json':'selfhost/build/phase134/stream-timing-summary01.json',
 'baseline-observation.json':'selfhost/build/phase132/p134-acquisition-observation01/report.json',
 'stream-observation.json':'selfhost/build/phase132/p134-self-observation01/report.json',
 'baseline-samples.jsonl':'selfhost/build/phase132/p134-acquisition-observation01/samples.jsonl',
 'stream-samples.jsonl':'selfhost/build/phase132/p134-self-observation01/samples.jsonl',
 'hosted-evidence.json':'selfhost/tools/performance/phase134/emission/hosted-evidence.json',
 'io-controls.json':'selfhost/build/phase134/io-result01/report.json',
}
def pin(p):
 p=Path(p).resolve(); b=p.read_bytes(); return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 assert not OUT.exists(); OUT.mkdir(parents=True)
 members=[]; raw=io.BytesIO()
 with tarfile.open(fileobj=raw,mode='w') as tar:
  for name,path in FILES.items():
   p=ROOT/path; b=p.read_bytes(); row=dict(name=name,source=pin(p)); members.append(row)
   if name.endswith('.json'): assert json.loads(b).get('complete') is True, name
   ti=tarfile.TarInfo(name);ti.size=len(b);ti.mtime=0;ti.mode=0o644;tar.addfile(ti,io.BytesIO(b))
 compressed=gzip.compress(raw.getvalue(),compresslevel=9,mtime=0)
 (OUT/'evidence.tar.gz').write_bytes(compressed)
 with tarfile.open(fileobj=io.BytesIO(gzip.decompress(compressed)),mode='r:') as tar:
  for row in members:
   b=tar.extractfile(row['name']).read(); assert hashlib.sha256(b).hexdigest()==row['source']['sha256']
 source=ROOT/'selfhost/build/phase134/stream-source02/compiler.bend'
 (OUT/'compiler.bend.gz').write_bytes(gzip.compress(source.read_bytes(),compresslevel=9,mtime=0))
 assert gzip.decompress((OUT/'compiler.bend.gz').read_bytes())==source.read_bytes()
 baseline=json.loads((ROOT/FILES['baseline-observation.json']).read_text())
 streamed=json.loads((ROOT/FILES['stream-observation.json']).read_text())
 req0=json.loads((ROOT/FILES['acquisition.json']).read_text());req1=json.loads((ROOT/FILES['self-emission.json']).read_text())
 assert req0['source']==req1['source'] and req1['byteExact']
 metrics=dict(baselineNativeSeconds=req0['nativeSeconds'],streamNativeSeconds=req1['nativeSeconds'],
  observedNativeRatio=req1['nativeSeconds']/req0['nativeSeconds'],
  baselineSampledPeakRss=baseline['sampledPeakDescendantRssBytes'],streamSampledPeakRss=streamed['sampledPeakDescendantRssBytes'],
  peakRatio=streamed['sampledPeakDescendantRssBytes']/baseline['sampledPeakDescendantRssBytes'],
  scope='One observed acquisition/self-emission pair on identical source and exact QBE. Different compiler executables; CPU6 correctness overlap during acquisition. Not a calibrated full-source speed claim.')
 (OUT/'memory-summary.json').write_text(json.dumps(metrics,indent=2)+'\n')
 receipt=dict(complete=True,targetsRun=False,source=pin(source),sourceArchive=pin(OUT/'compiler.bend.gz'),
  archive=pin(OUT/'evidence.tar.gz'),members=members,method=pin(__file__),
  scope='Qualified experimental streaming checkpoint. Production selection unchanged; memory gain and initial time regression retained; batching is a separate candidate.')
 (OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 print(json.dumps(metrics))
if __name__=='__main__': main()
