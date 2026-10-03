#!/usr/bin/env python3
"""Terminal streamed raw archive after root closes all writers; execute no targets."""
import argparse,gzip,hashlib,json,os,tarfile
from pathlib import Path
MAX_FILE=2*1024**3;MAX_TOTAL=64*1024**3;MAX_MEMBERS=500000
CHUNK=1024**2
def ident(p):
 p=Path(p).resolve();h=hashlib.sha256()
 with p.open('rb') as f:
  for block in iter(lambda:f.read(CHUNK),b''):h.update(block)
 return dict(file=str(p),bytes=p.stat().st_size,sha256=h.hexdigest())
def token(p):
 s=p.stat();return(s.st_dev,s.st_ino,s.st_size,s.st_mtime_ns,s.st_ctime_ns)
def inventory(raw):
 files={}
 for p in sorted(raw.rglob('*')):
  assert not p.is_symlink(),'Raw symlink requires separately reviewed handling: '+str(p)
  if p.is_dir():continue
  assert p.is_file();name=p.relative_to(raw).as_posix();assert name and '..' not in Path(name).parts and not Path(name).is_absolute();files[name]=token(p)
 assert len(files)<=MAX_MEMBERS and all(t[2]<=MAX_FILE for t in files.values()) and sum(t[2] for t in files.values())<=MAX_TOTAL
 return files
class HashedReader:
 def __init__(self,f):self.f=f;self.h=hashlib.sha256();self.bytes=0
 def read(self,n=-1):
  b=self.f.read(n);self.h.update(b);self.bytes+=len(b);return b
 def __getattr__(self,k):return getattr(self.f,k)
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--raw',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--writers-closed',type=Path,required=True);p.add_argument('--protected-final',type=Path,required=True);a=p.parse_args();raw=a.raw.resolve();out=a.out.resolve();assert raw.is_dir() and not out.exists() and not out.is_relative_to(raw)
 closed=json.loads(a.writers_closed.read_text());assert closed['complete'] is True and closed['writersClosed'] is True and Path(closed['rawRoot']).resolve()==raw
 protected=json.loads(a.protected_final.read_text());assert protected['complete'] is True and protected['checked']==103 and protected['changed']==[] and protected.get('protectedStaged',[])==[]
 for row in [closed['attempt'],closed['api']]:assert ident(row.get('file',row.get('path')))['sha256']==row['sha256']
 start=protected['start'];assert ident(start['file'])==start
 declarations=[ident(a.writers_closed),ident(a.protected_final),start,ident(__file__)];files=inventory(raw);stage=out.with_name(out.name+'.staging-'+str(os.getpid()));assert not stage.exists();stage.mkdir(parents=True,exist_ok=False);archive=stage/'raw-campaign.tar.gz';rows={}
 with archive.open('xb') as f,gzip.GzipFile(fileobj=f,mode='wb',filename='',mtime=0) as gz,tarfile.open(fileobj=gz,mode='w|') as tar:
  for name,t in files.items():
   source=raw/name;assert token(source)==t;info=tarfile.TarInfo(name);info.size=t[2];info.mode=0o644;info.mtime=0;info.uid=info.gid=0;info.uname=info.gname=''
   with source.open('rb') as original:
    reader=HashedReader(original);tar.addfile(info,reader);assert reader.bytes==t[2];rows[name]=dict(bytes=t[2],sha256=reader.h.hexdigest())
   assert token(source)==t
 seen=set()
 with tarfile.open(archive,'r|gz') as tar:
  for member in tar:
   assert member.isfile() and member.name in rows and member.name not in seen and member.size==rows[member.name]['bytes'];seen.add(member.name);h=hashlib.sha256()
   with tar.extractfile(member) as f:
    for block in iter(lambda:f.read(CHUNK),b''):h.update(block)
   assert h.hexdigest()==rows[member.name]['sha256']
 assert seen==set(files) and inventory(raw)==files
 for name,row in rows.items():assert ident(raw/name)['sha256']==row['sha256']
 for row in declarations:assert ident(row['file'])==row
 result=dict(kind='phase42-closed-raw-campaign-archive',complete=True,producer=declarations[-1],rawRoot=str(raw),writersClosed=declarations[0],protectedFinal=declarations[1],protectedStart=start,attempt=closed['attempt'],api=closed['api'],archive=dict(path='raw-campaign.tar.gz',**{k:v for k,v in ident(archive).items() if k!='file'}),members=len(rows),uncompressedBytes=sum(r['bytes'] for r in rows.values()),reopenedVerified=True,inputStabilityVerified=True,bounds=dict(maxFileBytes=MAX_FILE,maxTotalBytes=MAX_TOTAL,maxMembers=MAX_MEMBERS),files=rows,scope='All regular raw campaign files from closed root snapshot, including failed and held evidence. No compiler or target execution. Publication receipt excludes itself from raw archive; do not append later events to the archived raw ledger.')
 (stage/'archive.json').write_text(json.dumps(result,indent=2)+'\n');assert not out.exists();stage.rename(out);print(json.dumps(dict(complete=True,out=str(out),members=len(rows),archiveSha256=result['archive']['sha256'])))
if __name__=='__main__':main()
