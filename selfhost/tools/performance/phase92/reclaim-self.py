#!/usr/bin/env python3
"""Verify/prune two archived duplicate Phase92 self outputs, or restore to a fresh root."""
import argparse, fcntl, hashlib, json, os, pathlib, stat, subprocess, zipfile
ROOT=pathlib.Path(__file__).resolve().parents[4]
CAP='selfhost/tools/performance/phase92/evidence01/'
COMMIT='f026aceb729cdc3d08331650ea9c194ba133fc7c'
FILES=['selfhost/build/phase92/self-b1-01/self.1.c','selfhost/build/phase92/self-b2-01/self.1.c']
def digest(data): return hashlib.sha256(data).hexdigest()
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('action',choices=['apply','restore']);p.add_argument('--out',required=True);a=p.parse_args()
 os.sched_setaffinity(0,{0})
 with (ROOT/'selfhost/build/phase32/execution.lock').open() as lock:
  fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
  pins=[]
  for name in ['manifest.json','raw.zip']:
   path=ROOT/(CAP+name);data=path.read_bytes()
   stored=subprocess.check_output(['git','cat-file','blob',COMMIT+':'+CAP+name],cwd=ROOT)
   assert data==stored
   pins.append(dict(file=CAP+name,sha256=digest(data),bytes=len(data)))
  entries={r['file']:r for r in json.loads((ROOT/(CAP+'manifest.json')).read_text())}
  rows=[]
  out=pathlib.Path(a.out).absolute();assert not out.exists()
  with zipfile.ZipFile(ROOT/(CAP+'raw.zip')) as archive:
   for name in FILES:
    r=entries[name];data=archive.read(name);info=archive.getinfo(name)
    assert (len(data),digest(data))==(r['bytes'],r['sha256'])
    mode=stat.S_IMODE(info.external_attr>>16)
    if a.action=='apply':
     path=ROOT/name;st=path.lstat()
     assert path.resolve()==path and stat.S_ISREG(st.st_mode) and st.st_nlink==1
     assert path.read_bytes()==data
    rows.append(dict(r,mode=mode))
   if a.action=='apply':
    # Verify every file above before the first unlink. Current native07 assets stay.
    for r in rows:
     path=ROOT/r['file'];assert digest(path.read_bytes())==r['sha256'];path.unlink()
    receipt=out
   else:
    assert ROOT not in out.parents
    out.mkdir(parents=True)
    for r in rows:
     path=out/r['file'];path.parent.mkdir(parents=True,exist_ok=True)
     path.write_bytes(archive.read(r['file']));path.chmod(r['mode'])
     assert digest(path.read_bytes())==r['sha256']
    receipt=out/'restore-receipt.json'
  result=dict(complete=True,action=a.action,committedCapsule=COMMIT,capsule=pins,files=rows,bytes=sum(r['bytes'] for r in rows),scope='Two exact self-emission duplicates only; committed evidence and current native07 build C remain. Both passed complete byte comparison before sealing.')
  receipt.parent.mkdir(parents=True,exist_ok=True)
  with receipt.open('x') as f: json.dump(result,f,indent=2);f.write('\n')
  print(json.dumps(dict(complete=True,action=a.action,files=len(rows),bytes=result['bytes'])))
if __name__=='__main__': main()
