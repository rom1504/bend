#!/usr/bin/env python3
"""Seal all Phase93 raw evidence and verify every archive member byte-for-byte."""
import fcntl, hashlib, json, os, pathlib, zipfile
ROOT=pathlib.Path(__file__).resolve().parents[4]
RAW=ROOT/'selfhost/build/phase93'
OUT=ROOT/'selfhost/tools/performance/phase93/evidence01'
def pin(path):
    data=path.read_bytes()
    return dict(file=path.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
os.sched_setaffinity(0,{0})
with (ROOT/'selfhost/build/phase32/execution.lock').open() as lock:
    fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    assert not OUT.exists()
    files=sorted(p for p in RAW.rglob('*') if p.is_file())
    for p in files:
        assert not p.is_symlink()
        if p.name=='process.json':
            r=json.loads(p.read_text());assert r.get('finished') and 'wallSeconds' in r
    rows=[pin(p) for p in files]
    OUT.mkdir(parents=True)
    with zipfile.ZipFile(OUT/'raw.zip','w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for p,r in zip(files,rows):z.write(p,r['file'])
    with zipfile.ZipFile(OUT/'raw.zip') as z:
        assert z.namelist()==[r['file'] for r in rows]
        for p,r in zip(files,rows):
            data=z.read(r['file'])
            assert len(data)==r['bytes'] and hashlib.sha256(data).hexdigest()==r['sha256'] and pin(p)==r
    assert files==sorted(p for p in RAW.rglob('*') if p.is_file())
    (OUT/'manifest.json').write_text(json.dumps(rows,indent=2)+'\n')
    receipt=dict(complete=True,method=pin(pathlib.Path(__file__).resolve()),archive=pin(OUT/'raw.zip'),
        manifest=pin(OUT/'manifest.json'),files=len(rows),rawBytes=sum(r['bytes'] for r in rows),
        scope='All Phase93 raw files, including failed offline preflight, calibration, actual compiler products and executables, disassembly, timing and scaling. Identical B1 C copies are reconstructed using each acquisition deduplicated mapping to retained B2 C.')
    (OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print(json.dumps(receipt))
