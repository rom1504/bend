#!/usr/bin/env python3
"""Plan or archive compact Phase145 evidence. Metadata only; no target execution.

The archive authenticates recorded evidence, not a self-contained compiler SDK.
Absolute paths and omitted parent images/tools still require explicit recovery.
"""
import argparse,collections,gzip,hashlib,json,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];MIB=1024*1024
SCOPE=['selfhost/build/phase145','selfhost/tools/performance/phase145','research/phase145','design/phase145','experiments/phase145','implementation/phase145']
REQUIRED=['native-build02/report.json','native-control02/report.json','native-observe02/report.json','native-stages-build01/report.json','native-stages-observe01/report.json','execution-clean01/report.json','execution-counts01/report.json','execution-verified01/report.json','execution-warm02/report.json','upstream03/summary01.json']
EXPLICIT=['implementation/phase144/final04/candidate.json','implementation/phase144/final04/qualification.json','selfhost/build/phase111/p144-integrated-api04/api.mjs','selfhost/build/phase111/p144-integrated-api04/report.json','selfhost/build/phase144/final04-source01/manifest.json','selfhost/build/phase134/p144-final04-n2/report.json','selfhost/build/phase144/final04-small-products01/report.json','selfhost/build/phase130/base-carrier01/receipt.json']
def pin(p):
 p=Path(p).resolve();h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(MIB),b''):h.update(b)
 return dict(file=str(p),bytes=p.stat().st_size,sha256=h.hexdigest())
def read(p):return json.loads(Path(p).read_text())
def verify(x):assert pin(x['file'])==x,x['file']
def pins(x):
 if isinstance(x,dict):
  if {'file','bytes','sha256'}<=x.keys() and isinstance(x['file'],str) and type(x['bytes'])is int:yield {k:x[k] for k in ['file','bytes','sha256']}
  for y in x.values():yield from pins(y)
 elif isinstance(x,list):
  for y in x:yield from pins(y)
def path(x):
 p=Path(x);return (ROOT/p).resolve() if not p.is_absolute() else p.resolve()
def omitted(p):
 if p.is_symlink():return 'symlink-not-followed'
 if '__pycache__' in p.parts or p.suffix in {'.pyc','.tmp','.lock'}:return 'transient'
 if p.suffix in {'.ssa','.s','.o','.so','.a','.zip','.xz'}:return 'regenerable-IR-machine-or-parent-archive'
 if p.name.endswith(('.tar.gz','.tar')):return 'archive-not-nested'
 if p.name in {'stdout','compiler.stdout'} and p.stat().st_size>64*1024:return 'large-generated-stdout'
 if p.stat().st_size>20*MIB:return 'over20MiB'
 with p.open('rb') as f:
  if f.read(4)==b'\x7fELF':return 'executable-image'
 return None
def select(out):
 files=set();excluded=[];roots=[]
 for name in SCOPE:
  root=ROOT/name
  if not root.exists():continue
  roots.append(str(root.relative_to(ROOT)))
  for p in sorted(root.rglob('*')):
   if out and (p==out or out in p.parents):continue
   if not p.is_file():continue
   why=omitted(p)
   if why:excluded.append(dict(file=str(p.relative_to(ROOT)),bytes=p.stat().st_size,reason=why))
   else:files.add(p.resolve())
 for name in EXPLICIT:
  p=ROOT/name;assert p.is_file(),p;files.add(p.resolve())
 # A single bounded dependency pass; no recursive historical archive crawl.
 dep_pins={}
 for p in sorted(files):
  if p.suffix!='.json':continue
  for x in pins(read(p)):
   dp=path(x['file']);x=dict(x,file=str(dp));dep_pins[(str(dp),x['sha256'],x['bytes'])]=x
 dependencies=[]
 for x in sorted(dep_pins.values(),key=lambda x:(x['file'],x['sha256'])):
  p=Path(x['file']);inside=p.is_relative_to(ROOT);rel=str(p.relative_to(ROOT)) if inside else str(p)
  include=inside and x['bytes']<=8*MIB and (
   rel.startswith('selfhost/tools/') and p.suffix in {'.py','.mjs','.js','.ts','.bend','.c','.h','.json','.md'} or
   rel.startswith('selfhost/.bootstrap/upstream-phase66/bend2/') and p.suffix in {'.ts','.js','.c','.h','.bend','.json'} or
   p.suffix=='.bend' and x['bytes']<=512*1024 or
   rel.startswith(('research/phase144/','implementation/phase144/final04/')) and p.suffix in {'.json','.md'})
  status='not-rehashed-external-dependency'
  if p in files or include:
   if not p.is_file():status='missing-direct-dependency'
   else:
    actual=pin(p)
    if actual!=x:status='historical-pin-differs-from-current-file'
    else:status='included';files.add(p)
  dependencies.append(dict(recorded=x,status=status,reason=None if status=='included' else 'Pin retained; no claim this archive alone rebuilds all historical products.'))
 return sorted(files),dict(roots=roots,excluded=excluded,dependencies=dependencies)
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--inventory-only',action='store_true');ap.add_argument('--out',type=Path);ap.add_argument('--require',action='append',type=Path,default=[]);a=ap.parse_args()
 out=a.out.resolve() if a.out else None
 if not a.inventory_only:assert out and out.is_relative_to(ROOT/'implementation/phase145') and not out.exists(),'Fresh implementation/phase145 output required'
 files,details=select(out);total=sum(p.stat().st_size for p in files);assert total<=128*MIB,('raw budget exceeded',total)
 if a.inventory_only:
  print(json.dumps(dict(kind='phase145-archive-preview',archiveWritten=False,files=len(files),rawBytes=total,excluded=collections.Counter(x['reason'] for x in details['excluded']),unresolvedDependencies=collections.Counter(x['status'] for x in details['dependencies'] if x['status']!='included'),largest=[dict(file=str(p.relative_to(ROOT)),bytes=p.stat().st_size) for p in sorted(files,key=lambda p:-p.stat().st_size)[:12]]),indent=2));return
 # Failed attempts are retained; only the selected successful campaign receipts
 # are gates. Root adds every final late job via repeatable --require arguments.
 required=[ROOT/'selfhost/build/phase145'/x for x in REQUIRED]+[p.resolve() for p in a.require];gates=[]
 for p in required:
  d=read(p);assert d.get('complete') is True,('Selected campaign incomplete',p);gates.append(pin(p));files.append(p)
 for p in files:
  if p.name=='process.json' and p.parent.name.endswith('-guard'):
   d=read(p);assert 'finished' in d and 'returncode' in d,('Target guard still active',p)
 files=sorted(set(files));rows=[dict(pin(p),file=str(p.relative_to(ROOT)),mode=p.stat().st_mode&0o777) for p in files];total=sum(x['bytes'] for x in rows);assert total<=128*MIB
 # Validate the principal retained lineage without copying its binary/object.
 candidate=read(ROOT/'implementation/phase144/final04/candidate.json');assert candidate['complete'] and candidate['nativeQualified']
 parent={k:candidate[k] for k in ['source','nativeObject','n2','nativeBuild','runtime','api','checkedApi','preferredCarrier','preferredCarrierReceipt','base']}
 for x in parent.values():verify(x)
 scope=['This is a measured-evidence capsule, not a portable or hermetic compiler distribution.','Exact final04 native compiler/object, tool executables, carrier and parent qualification archives remain separate pinned dependencies.','Generated SSA/assembly/binaries are excluded; independent expected hashes remain in receipts.','Current small diagnostic APIs and runtime hook source are preserved. Restoring absolute paths or relinking on another machine requires renewed output and identity checks.','Full stage/sample re-symbolization needs the exact omitted diagnostic ELF. The archived validated FID/source/clock results remain independently readable; rebuilding an equivalent image is not proof of identical addresses.','Failed attempts remain evidence, not successful qualification. The archive does not rerun compiler or correctness gates.']
 inventory=dict(kind='phase145-compact-evidence-inventory',complete=True,targetsRun=False,method=pin(__file__),gates=gates,principalParent=parent,files=rows,rawBytes=total,limits=dict(rawBytes=128*MIB,compressedBytes=16*MIB),scope=scope,**details)
 out.mkdir(parents=True);manifest=out/'inventory.json';manifest.write_text(json.dumps(inventory,indent=2)+'\n');archive=out/'evidence.tar.gz'
 with archive.open('xb') as target,gzip.GzipFile(fileobj=target,mode='wb',mtime=0,filename='',compresslevel=6) as gz,tarfile.open(fileobj=gz,mode='w|') as tar:
  for p in [manifest,*files]:
   name='inventory.json' if p==manifest else str(p.relative_to(ROOT));info=tar.gettarinfo(str(p),arcname=name);info.uid=info.gid=0;info.uname=info.gname='';info.mtime=0
   with p.open('rb') as f:tar.addfile(info,f)
 assert archive.stat().st_size<=16*MIB,'Compressed budget exceeded; retain failed artifact, do not claim complete'
 expected={x['file']:dict(bytes=x['bytes'],sha256=x['sha256']) for x in rows};expected['inventory.json']={k:v for k,v in pin(manifest).items() if k!='file'};seen=set()
 with tarfile.open(archive,'r:gz') as tar:
  for member in tar:
   assert member.isfile() and member.name in expected and member.name not in seen;seen.add(member.name);h=hashlib.sha256();size=0
   with tar.extractfile(member) as f:
    for b in iter(lambda:f.read(MIB),b''):h.update(b);size+=len(b)
   assert dict(bytes=size,sha256=h.hexdigest())==expected[member.name]
 assert seen==set(expected)
 # Explicit postflight hash check catches edits during archival.
 for p,row in zip(files,rows):
  actual=pin(p);assert all(actual[k]==row[k] for k in ['bytes','sha256']),p
 receipt=dict(kind='phase145-compact-evidence-archive',complete=True,targetsRun=False,archive=pin(archive),inventory=pin(manifest),method=pin(__file__),members=len(seen),rawBytes=total,allMembersRehashed=True,sourceFilesUnchanged=True,scope=scope)
 (out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps(receipt,indent=2))
if __name__=='__main__':main()
