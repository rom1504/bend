#!/usr/bin/env python3
"""Reclaim two archived self-output duplicates; restore with the recorded ZIP paths."""
import fcntl, hashlib, json, pathlib, stat, subprocess, zipfile
ROOT=pathlib.Path(__file__).resolve().parents[4]
CAP='selfhost/tools/performance/phase90/evidence05/'
NAMES=['selfhost/build/phase90/native07-self01/output.1.c',
       'selfhost/build/phase90/js-new-runtime02/program.c']
def digest(data):return hashlib.sha256(data).hexdigest()
with (ROOT/'selfhost/build/phase32/execution.lock').open() as lock:
    fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
    pins=[]
    for name in ['manifest.json','phase90.zip']:
        file=ROOT/(CAP+name);data=file.read_bytes()
        assert data==subprocess.check_output(['git','cat-file','blob',commit+':'+CAP+name],cwd=ROOT)
        pins.append(dict(file=CAP+name,sha256=digest(data),bytes=len(data)))
    active=json.loads((ROOT/'selfhost/build/phase93/pilot02/report.json').read_text())['authentication']['inputs']
    assert not {str(ROOT/p) for p in NAMES}&{r['file'] for r in active}
    retained=ROOT/'selfhost/build/phase90/native06-new-runtime01/output.1.c'
    canonical=retained.read_bytes()
    rows=[]
    with zipfile.ZipFile(ROOT/(CAP+'phase90.zip')) as archive:
        manifest={r['file']:r for r in json.loads((ROOT/(CAP+'manifest.json')).read_text())}
        for name in NAMES:
            path=ROOT/name;info=path.lstat();r=manifest[name];data=archive.read(name)
            assert stat.S_ISREG(info.st_mode) and info.st_nlink==1 and path.resolve()==path
            assert data==canonical==path.read_bytes()
            assert (len(data),digest(data))==(r['bytes'],r['sha256'])
            rows.append(dict(r,mode=stat.S_IMODE(info.st_mode),archiveMember=name))
    receipt=ROOT/'implementation/phase93/reclamation.json'
    assert not receipt.exists();receipt.parent.mkdir(parents=True,exist_ok=True)
    for row in rows:
        p=ROOT/row['file'];assert digest(p.read_bytes())==row['sha256'];p.unlink()
    receipt.write_text(json.dumps(dict(complete=True,commit=commit,capsule=pins,files=rows,
        bytes=sum(r['bytes'] for r in rows),retainedIdentical=str(retained.relative_to(ROOT)),
        restoration='Extract the exact archiveMember from the committed phase90.zip into a fresh root, verify SHA256/length, restore recorded mode. Current native07 build C remains an identical local copy.'),indent=2)+'\n')
    print(json.dumps(dict(complete=True,reclaimedBytes=sum(r['bytes'] for r in rows))))
