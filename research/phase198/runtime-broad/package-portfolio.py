"""Package the measured portfolio records and the independent relink observations."""
from pathlib import Path
import gzip
import io
import json
import tarfile
from package import HERE,ROOT,BUILD,EVIDENCE,item

def collect():
    summary=json.loads((HERE/'portfolio-summary.json').read_text())
    assert summary['complete'] and summary['oracleRevalidated']==dict(pilots=616,samples=720)
    prep=BUILD/'portfolio-live-plan01'
    run=BUILD/'portfolio-live-broad01'
    report=json.loads((run/'report.json').read_text())
    producer=json.loads((prep/'report.json').read_text())
    assert producer['complete'] and report['complete']
    files=set()
    def add(path,auth=None):
        p=Path(path).resolve()
        assert p.is_file() and ROOT in p.parents
        if auth:
            got=item(p);assert (got['bytes'],got['sha256'])==(auth['bytes'],auth['sha256'])
        files.add(p)
    measured=0
    for c in report['cases']:
        for s in [*c['pilots'],*c['samples']]:
            assert s['correct']
            for stream in ('stdout','stderr'):
                pin=s['process'][stream];add(pin['file'],pin);measured+=1
    oracles=0
    for c in producer['cases'].values():
        for obs in c['oracles'].values():
            for stream in ('stdout','stderr'):
                pin=obs['process'][stream];add(pin['file'],pin);oracles+=1
    assert measured==2672 and oracles==360
    for p in [prep/'manifest.json',prep/'recipe.json',BUILD/'portfolio-performance-journal01.json',
              producer['native']['file'],producer['source']['file']]:add(p)
    for p in (BUILD/'portfolio-live-argv01').glob('*.json'):add(p)
    for name in ['portfolio-native45-01','portfolio-live-plan01','portfolio-live-broad01']:
        for p in [BUILD/name/'report.json',BUILD/(name+'-guard')/'process.json',BUILD/(name+'-guard')/'retention.json',
                  ROOT/'selfhost/build-retention/phase198'/(name+'-close')/'report.json']:add(p)
    target=EVIDENCE/'portfolio-replay.tar.gz'
    with target.open('xb') as output,gzip.GzipFile(filename='',fileobj=output,mode='wb',mtime=0) as zipped:
        with tarfile.open(fileobj=zipped,mode='w') as archive:
            for p in sorted(files):
                data=p.read_bytes()
                info=tarfile.TarInfo(str(p.relative_to(ROOT)));info.size=len(data);info.mode=0o644;info.mtime=0
                archive.addfile(info,io.BytesIO(data))
    index=dict(complete=True,method=item(Path(__file__)),archive=item(target),members=len(files),measuredAndPilotStreams=measured,
        independentRelinkStreams=oracles,summary=item(HERE/'portfolio-summary.json'),source=producer['source'],
        dependencies='Build inputs, emitted objects, linked ELF files and GCC remain addressed by manifest pins. Use the baseline replay bundle for constructor runtime and reference metadata.')
    with (EVIDENCE/'portfolio-replay.json').open('x') as f:json.dump(index,f,indent=2);f.write('\n')

if __name__=='__main__':collect()
