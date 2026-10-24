#!/usr/bin/env python3
"""Publish compact Phase135 machine evidence, excluding regenerable IR/objects/ELF.
Run after experiment writers finish. All copied members are verified after reopen.
"""
import argparse,hashlib,io,json,lzma,pathlib,tarfile
ROOT=pathlib.Path(__file__).resolve().parents[5];HERE=pathlib.Path(__file__).resolve().parent

def pin(p):
 p=pathlib.Path(p).resolve();h=hashlib.sha256();n=0
 with p.open('rb')as f:
  while b:=f.read(65536):h.update(b);n+=len(b)
 return dict(file=str(p),bytes=n,sha256=h.hexdigest())

def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--out',type=pathlib.Path,required=True);ap.add_argument('--root',action='append',type=pathlib.Path,default=[]);a=ap.parse_args();out=a.out.resolve()
 if out.exists()or not out.is_relative_to(ROOT/'implementation/phase135'):raise ValueError('Fresh Phase135 evidence directory required')
 phase=ROOT/'selfhost/build/phase135';roots=[*sorted(phase.glob('machine-*')),*a.root]
 paths=set()
 for directory in roots:
  directory=directory.resolve()
  if not directory.is_relative_to(ROOT):raise ValueError('Repository evidence only')
  if not directory.exists():raise ValueError('Missing evidence root '+str(directory))
  candidates=directory.rglob('*')if directory.is_dir()else[directory]
  for p in candidates:
   if p.is_file()and (p.suffix in('.json','.stdout','.stderr','.md','.txt','.log')or p.name in('stdout','stderr')):
    if p.stat().st_size>8*1024**2:raise ValueError('Oversized metadata; select explicitly '+str(p))
    paths.add(p.resolve())
 for folder in [HERE,ROOT/'selfhost/tools/performance/phase135/preparation']:
  for p in folder.glob('*'):
   if p.is_file()and p.suffix in('.py','.mjs','.bend','.md','.json'):paths.add(p.resolve())
 for label in ['machine-source01','machine-source02']:
  p=phase/label/'compiler.bend'
  if not p.is_file():raise ValueError('Frozen checked source missing: '+label)
  paths.add(p.resolve())
 if not paths:raise ValueError('No evidence')
 entries=[dict(name=str(p.relative_to(ROOT)),**pin(p))for p in sorted(paths)]
 if sum(x['bytes']for x in entries)>128*1024**2:raise ValueError('Metadata/source archive exceeds declared bound')
 inventory=dict(kind='phase135-machine-evidence',inputs=[pin(__file__)],members=entries,scope='Exact checked source01/source02, methods, metadata, commands and diagnostics. Excludes full generated IR, assembly, objects, executable images and hosted APIs; their identities remain in receipts. Failed attempts retained without qualification claims.')
 raw=(json.dumps(inventory,indent=2)+'\n').encode();out.mkdir(parents=True);archive=out/'evidence.tar.xz'
 with lzma.open(archive,'wb',format=lzma.FORMAT_XZ,preset=6)as compressed,tarfile.open(fileobj=compressed,mode='w|')as tar:
  for entry in entries:
   path=pathlib.Path(entry['file']);current=pin(path)
   if any(current[k]!=entry[k]for k in('file','bytes','sha256')):raise ValueError('Evidence changed before archive')
   info=tarfile.TarInfo(entry['name']);info.size=entry['bytes'];info.mode=0o644;info.mtime=0
   with path.open('rb')as f:tar.addfile(info,f)
  info=tarfile.TarInfo('INVENTORY.json');info.size=len(raw);info.mode=0o644;info.mtime=0;tar.addfile(info,io.BytesIO(raw))
 wanted={x['name']:x for x in entries};seen=set()
 with tarfile.open(archive,'r:xz')as tar:
  for member in tar:
   if not member.isfile()or member.name in seen:raise ValueError('Unexpected archive member')
   seen.add(member.name);f=tar.extractfile(member);h=hashlib.sha256();size=0
   while b:=f.read(65536):h.update(b);size+=len(b)
   if member.name=='INVENTORY.json':expected=dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())
   else:expected=wanted[member.name]
   if size!=expected['bytes']or h.hexdigest()!=expected['sha256']:raise ValueError('Archive round-trip mismatch')
 if seen!=set(wanted)|{'INVENTORY.json'}:raise ValueError('Incomplete archive')
 for entry in entries:
  current=pin(entry['file'])
  if any(current[k]!=entry[k]for k in('file','bytes','sha256')):raise ValueError('Evidence changed during archive')
 report=dict(complete=True,kind=inventory['kind'],method=pin(__file__),archive=pin(archive),members=len(entries),uncompressedMemberBytes=sum(x['bytes']for x in entries),roundTripExact=True,roots=list(map(str,roots)),scope=inventory['scope'])
 (out/'receipt.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
if __name__=='__main__':main()
