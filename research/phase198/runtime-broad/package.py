"""Collect retained runtime methods, observations and manifests without running targets."""
from pathlib import Path
import gzip
import hashlib
import io
import json
import tarfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BUILD=ROOT/'selfhost/build/phase198'
EVIDENCE=HERE/'evidence'

def item(path):
    return dict(path=str(path.relative_to(ROOT)),bytes=path.stat().st_size,sha256=hashlib.sha256(path.read_bytes()).hexdigest())

def package():
    pins=json.loads((HERE/'portfolio-pins.json').read_text())
    raw=json.loads((BUILD/'runtime-split-broad01/report.json').read_text())
    assert raw['complete'] and raw['positionBalanced'] and raw['rounds']==4
    paths=set()
    def add(path):
        p=Path(path).resolve()
        assert p.is_file() and ROOT in p.parents
        paths.add(p)
    plan=BUILD/'runtime-split-prepare01'
    controls=BUILD/'runtime-split-controls01'
    for p in [plan/'manifest.json',plan/'recipe.json',plan/'runtime-live.c',plan/'runtime-live.o',
              controls/'runtime-live.c',controls/'runtime-live.o',BUILD/'broad-runtime-plan01/recipe.json',
              BUILD/'runtime-screen01/report.json',BUILD/'runtime-screen01/split/runtime.o',
              BUILD/'runtime-screen01/split/runtime.c',ROOT/'selfhost/build/phase195/runtime-calibration.py',
              ROOT/'selfhost/build/phase194/assets.json']:
        add(p)
    for k in ('original','phase197','matureC'):
        add(pins[k]['file'])
    for name in ['runtime-split-prepare01','runtime-split-controls01','runtime-split-broad01']:
        for p in [BUILD/name/'report.json',BUILD/(name+'-guard')/'process.json',BUILD/(name+'-guard')/'retention.json',
                  ROOT/'selfhost/build-retention/phase198'/(name+'-close')/'report.json']:add(p)
    outputs=0
    for case in raw['cases']:
        for row in [*case['pilots'],*case['samples']]:
            assert row['correct']
            for stream in ('stdout','stderr'):
                p=row['process'][stream]
                path=Path(p['file']);sig=item(path)
                assert (sig['bytes'],sig['sha256'])==(p['bytes'],p['sha256'])
                add(path);outputs+=1
    assert outputs==2*(625+720)
    target=EVIDENCE/'baseline-replay.tar.gz'
    with target.open('xb') as output,gzip.GzipFile(filename='',fileobj=output,mode='wb',mtime=0) as zipped:
        with tarfile.open(fileobj=zipped,mode='w') as archive:
            for p in sorted(paths):
                data=p.read_bytes()
                info=tarfile.TarInfo(str(p.relative_to(ROOT)))
                info.size=len(data);info.mtime=0;info.mode=0o644
                archive.addfile(info,io.BytesIO(data))
    index=dict(complete=True,method=item(Path(__file__)),archive=item(target),members=len(paths),
        independentProcessStreams=outputs,
        scope='Includes all native45 pilot and measured stdout/stderr streams, run/guard/closure receipts, program manifests, runtime objects and generated variant C sources. The program objects, linked executables, toolchain and original historical dependencies remain addressed by pins in the manifests; benchmark reruns require those retained inputs or their reproduction.',
        pins=pins)
    with (EVIDENCE/'baseline-replay.json').open('x') as f:json.dump(index,f,indent=2);f.write('\n')

if __name__=='__main__':package()
