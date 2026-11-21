"""Authenticate and archive the completed controlled two-program experiment."""
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BUILD=ROOT/'selfhost/build/phase198'

def read(p):return json.loads(p.read_text())
def pin(p):
    return dict(file=str(p.relative_to(ROOT)),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())

def package():
    main=BUILD/'quotient-machine-focused01'
    count=BUILD/'quotient-machine-focused-count01'
    api=BUILD/'quotient-machine-api01'
    timing=read(main/'timing/report.json');census=read(count/'comparison.json');controls=read(main/'controls/report.json')
    assert all(read(f/'report.json')['complete'] for f in (main,count,api))
    assert timing['complete'] and census['complete'] and controls['complete']
    assert controls['oracle']=='5200 checks\n' and len(controls['negative'])==13
    assert all(c['objectChanged'] for c in read(main/'emission/report.json')['cases'])
    results={}
    for case in timing['rows']:
        name=case['id'];samples=case['samples']
        assert len(samples)==3 and all(len(v)==6 for v in samples.values())
        paired=[(a['elapsedMs']/a['repetitions'])/(b['elapsedMs']/b['repetitions']) for a,b in zip(samples['candidate'],samples['baseline'])]
        results[name]=dict(candidateOverOriginal=case['candidateOverBaseline'],candidateOverC=case['candidateOverC'],paired=paired,
                          roundsFaster=sum(x<1 for x in paired),extraOracleInputs=len(case['oracles']),
                          countedBoundary=census['cases'][name],inputBucketNote='Divisor index 256 groups powers of two above 255 and 257 groups other divisors above 255.')
    assert set(results)=={'lexer','coverage-record-aggregation-256'}
    files={p for f in (main,count,api,BUILD/'quotient-machine-source02') for p in f.rglob('*') if p.is_file()}
    for name in ('quotient-machine-api01','quotient-machine-focused01','quotient-machine-focused-count01'):
        files.update([BUILD/(name+'-guard')/'process.json',BUILD/(name+'-guard')/'retention.json',
                      ROOT/'selfhost/build-retention/phase198'/(name+'-close')/'report.json'])
    for p in [ROOT/'selfhost/build/phase194/assets.json',BUILD/'runtime-count01/report.json',
              BUILD/'native45-01/programs.manifest.json',BUILD/'quotient-emit01/report.json']:files.add(p)
    archive=HERE/'evidence/focused-replay.tar.gz'
    with archive.open('xb') as output,gzip.GzipFile(filename='',mode='wb',mtime=0,fileobj=output) as gz:
        with tarfile.open(fileobj=gz,mode='w') as tar:
            for p in sorted(files):
                data=p.read_bytes();path=str(p.relative_to(ROOT))
                member=tarfile.TarInfo(path);member.size=len(data);member.mtime=0;member.mode=0o755 if p.stat().st_mode&0o111 else 0o644
                tar.addfile(member,io.BytesIO(data))
    result=dict(complete=True,method=pin(Path(__file__)),archive=pin(archive),members=len(files),cases=results,
        checkedSource=read(api/'report.json')['source'],controls=dict(negative=13,publicOperationWordChecks=5200,functions=26),
        timing=pin(main/'timing/report.json'),emission=pin(main/'emission/report.json'),counter=pin(count/'comparison.json'),
        dependencies='Runtime/compiler dependencies and independent C/reference ELF files are addressed by the archived manifests. Only the focused candidate objects and executables are included.',
        scope='Checked hosted API operating on the ordinary frontend plan. These two targeted cases establish reach, verified outputs and observed hardware benefit. They do not establish a portfolio all45 gain or a self-hosted compiler chain.')
    with (HERE/'evidence/focused-summary.json').open('x') as f:json.dump(result,f,indent=2);f.write('\n')

if __name__=='__main__':package()
