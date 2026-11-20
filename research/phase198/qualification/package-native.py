#!/usr/bin/env python3
"""Package source, exact argv and completed native receipts; run no targets."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).parent;BUILD=ROOT/'selfhost/build/phase198'
def pin(path):
    p=Path(path).resolve();data=p.read_bytes()
    return dict(file=str(p),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def read(p):return json.loads(Path(p).read_text())
summary=read(HERE/'native-summary01.json');assert summary['complete']
files=set()
def add(p):
    p=Path(p)
    if not p.is_absolute():p=ROOT/p
    assert p.is_file(),p
    assert ROOT in p.resolve().parents
    files.add(p)
for p in (BUILD/'selected-source01').rglob('*'):
    if p.is_file():add(p)
for name in ['qualification-plan01.json','native-gates-journal01.json','native-gates-run-argv01.json','native-image01-close-location-failure.json','qualification-job-initial.py']:
    add(BUILD/name)
for gate in summary['gates']:
    name=gate['name'];add(BUILD/name/'report.json');add(BUILD/(name+'-guard')/'process.json');add(BUILD/(name+'-guard')/'retention.json')
    add(ROOT/'selfhost/build-retention/phase198'/(name+'-close')/'report.json')
    argv=BUILD/(name+'-argv.json')
    if not argv.exists():argv=BUILD/(name+'-argv01.json')
    add(argv)
    for n in ['request.json','build-request.json']:
        p=BUILD/name/n
        if p.exists():add(p)
for p in ['selfhost/build/phase197/full-source-check01/report.json','research/phase198/qualification/source-audit.json','research/phase198/qualification/native-summary01.json','selfhost/build/phase194/assets.json','selfhost/build/phase186/release-qbe-chain01/n2/report.json']:
    add(p)
rows=[]
for gate in summary['gates']:
    g=read(gate['guard']['file'])
    rows.append(dict(name=gate['name'],complete=True,reportedSeconds=gate['seconds'],guardSeconds=g['wallSeconds'],peakTreeRssBytes=g['peakTreeRssBytes'],peakRunAllocatedBytes=g['peakRunAllocatedBytes'],minimumDiskFreeBytes=g['minimumDiskFreeBytes']))
contents=[dict(path=str(p.relative_to(ROOT)),**{k:v for k,v in pin(p).items() if k!='file'}) for p in sorted(files)]
archive=HERE/'native-replay01.tar.gz';assert not archive.exists()
with archive.open('wb') as raw:
    with gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0) as compressed:
        with tarfile.open(fileobj=compressed,mode='w',format=tarfile.PAX_FORMAT) as tar:
            for row in contents:
                data=(ROOT/row['path']).read_bytes();info=tarfile.TarInfo(row['path']);info.size=len(data);info.mode=0o644;info.mtime=0;tar.addfile(info,io.BytesIO(data))
index=dict(kind='phase198-native-qualification-replay-bundle',complete=True,targetsRun=False,method=pin(__file__),sourceCommit='aff3683350a5bcc691b2db75e44a18dff90aef2f',summary=pin(HERE/'native-summary01.json'),archive=pin(archive),selectedSource=summary['selectedSource'],archiveContents=contents,counts=dict(native45N1=45,native45N2=45,exactObjects=45,exactLinkedSections=135,conformance=64,runtimeControls=10,compilerObjectsExactlyReproduced=True),walls=rows,dependenciesNotBundled=['Pinned Phase194 toolchain/runtime/Base assets and upstream checker; see archived assets.json.','Frozen Phase186 QBE N2 seed program; its image receipt is archived and binary remains in retained build evidence.','Phase197 checked hosted API and source preparation artifacts used by audit-source.py and compare-hosted-subset.py.','Generated N1/N2/N3 binaries and benchmark binaries/objects remain in guarded retained build trees; this small bundle contains their exact receipt pins rather than copying them.'],replay='Extract only into a fresh evidence directory; preserve existing receipts. Run from a checkout retaining the pinned original methods. Use archived argv with fresh output names and consistent dependent paths. Source can be retrieved byte-exact from the archive or rebuilt from the tracked Phase197 stage-compiler.py at the sourceCommit using --minimum --decrement research/phase197/decrement/select-v2.bend. Its required SHA is selectedSource.sha256. No targets were rerun for packaging.')
(HERE/'native-replay-index01.json').write_text(json.dumps(index,indent=2)+'\n')
print(json.dumps({'archive':pin(archive),'files':len(contents),'walls':rows},indent=2))
