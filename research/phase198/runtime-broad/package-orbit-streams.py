"""Verify and package just the raw observations absent from the native-chain replay."""
import gzip
import io
import json
import tarfile
from pathlib import Path
from package import BUILD,EVIDENCE,HERE,ROOT,item

def package():
    timed=BUILD/'orbit-live-broad01/report.json'
    preflight=BUILD/'orbit-live-plan01/report.json'
    summary=HERE/'orbit-summary.json'
    raw=json.loads(timed.read_text())
    plan=json.loads(preflight.read_text())
    authenticated=json.loads(summary.read_text())
    assert raw['complete'] and plan['complete'] and authenticated['complete'] and len(plan['cases'])==45
    for actual,expected in [(timed,authenticated['report']),(preflight,authenticated['producer'])]:
        pin=item(actual)
        assert pin['bytes']==expected['bytes'] and pin['sha256']==expected['sha256']
    files={}
    def add(process):
        for stream in ['stdout','stderr']:
            p=process[stream]
            path=Path(p['file']).resolve()
            assert path.name==stream and ROOT in path.parents and path not in files
            pin=item(path)
            assert pin['bytes']==p['bytes'] and pin['sha256']==p['sha256']
            files[path]=pin
    for c in raw['cases']:
        for row in [*c['pilots'],*c['samples']]:
            assert row['correct'];add(row['process'])
    timing_streams=len(files)
    assert timing_streams==2*sum(authenticated['oracleRevalidated'].values())==2688
    for c in plan['cases'].values():
        for oracle in c['oracles'].values():add(oracle['process'])
    assert len(files)-timing_streams==360
    target=EVIDENCE/'orbit-process-streams.tar.gz'
    with target.open('xb') as output,gzip.GzipFile(filename='',fileobj=output,mode='wb',mtime=0) as gz:
        with tarfile.open(fileobj=gz,mode='w') as tar:
            for p in sorted(files):
                data=p.read_bytes();member=tarfile.TarInfo(files[p]['path'])
                member.size=len(data);member.mtime=0;member.mode=0o644;tar.addfile(member,io.BytesIO(data))
    index=dict(complete=True,method=item(Path(__file__)),archive=item(target),summary=item(summary),
        timedReport=item(timed),preflightReport=item(preflight),streamFiles=len(files),
        pilotAndMeasuredStreams=timing_streams,preflightStreams=len(files)-timing_streams,
        scope='The tar contains raw stdout/stderr only. The separately owned orbit native-chain package retains native source, guard, top-level reports and argv. Each stream was independently rehashed against its archived process record.')
    with (EVIDENCE/'orbit-process-streams.json').open('x') as f:json.dump(index,f,indent=2);f.write('\n')

if __name__=='__main__':package()
