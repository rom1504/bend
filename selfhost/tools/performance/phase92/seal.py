#!/usr/bin/env python3
"""Seal a completed Phase92 raw tree; verify every member before publication."""
import argparse, fcntl, hashlib, json, os, pathlib, zipfile
ROOT=pathlib.Path(__file__).resolve().parents[4]
def pin(path):
 data=path.read_bytes()
 return dict(file=path.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',required=True);p.add_argument('--roots',nargs='*');a=p.parse_args()
 os.sched_setaffinity(0,{0})
 out=(ROOT/a.out).resolve();assert out.is_relative_to(ROOT/'selfhost/tools/performance/phase92') and not out.exists()
 raw=ROOT/'selfhost/build/phase92'
 roots=[raw/name for name in a.roots] if a.roots else [raw]
 assert all(r.is_dir() and (r==raw or r.parent==raw) for r in roots)
 def selected():return sorted({x for root in roots for x in root.rglob('*') if x.is_file()})
 with (ROOT/'selfhost/build/phase32/execution.lock').open() as lock:
  fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
  files=selected()
  for f in files:
   assert not f.is_symlink()
   if f.name=='process.json':
    r=json.loads(f.read_text());assert r.get('finished') and 'wallSeconds' in r
  rows=[pin(f) for f in files]
  out.mkdir(parents=True)
  archive=out/'raw.zip'
  with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
   for f,r in zip(files,rows): z.write(f,r['file'])
  with zipfile.ZipFile(archive) as z:
   assert z.namelist()==[r['file'] for r in rows]
   for f,r in zip(files,rows):
    data=z.read(r['file']);assert len(data)==r['bytes'] and hashlib.sha256(data).hexdigest()==r['sha256']
    assert pin(f)==r
  assert files==selected()
  manifest=out/'manifest.json';manifest.write_text(json.dumps(rows,indent=2)+'\n')
  result=dict(complete=True,method=pin(pathlib.Path(__file__).resolve()),archive=pin(archive),manifest=pin(manifest),files=len(rows),rawBytes=sum(r['bytes'] for r in rows),roots=[str(r.relative_to(ROOT)) for r in roots],scope='Complete closed selected Phase92 raw trees at sealing time; historical dependencies retain their original committed capsules. No raw deletion.')
  receipt=out/'receipt.json';receipt.write_text(json.dumps(result,indent=2)+'\n')
  print(json.dumps(result))
if __name__=='__main__':main()
