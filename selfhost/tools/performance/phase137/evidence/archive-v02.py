"""Archive completed native evidence, with exact omissions and content deduplication."""
import argparse,gzip,hashlib,json,pathlib,tarfile
ROOT=pathlib.Path(__file__).resolve().parents[5]
p=argparse.ArgumentParser();p.add_argument('--out',type=pathlib.Path,required=True);p.add_argument('--path',action='append',type=pathlib.Path,required=True);p.add_argument('--keep-ir',action='append',type=pathlib.Path,default=[]);a=p.parse_args()
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'implementation/phase137');out.mkdir(parents=True)
keep={x.resolve()for x in a.keep_ir}
def pin(p):
 p=p.resolve();h=hashlib.sha256()
 with p.open('rb')as f:
  for b in iter(lambda:f.read(262144),b''):h.update(b)
 return dict(file=str(p),bytes=p.stat().st_size,sha256=h.hexdigest())
files=set()
for x in a.path:
 x=x.resolve();assert x.exists() and x.is_relative_to(ROOT/'selfhost/build')
 files.update(y for y in (x.rglob('*')if x.is_dir()else[x])if y.is_file()and not y.is_symlink()and '__pycache__'not in y.parts)
rows=[];omitted=[]
for f in sorted(files):
 row=dict(pin(f),archivePath=str(f.relative_to(ROOT)))
 if f.name in ['program','program.o','program.s'] or (f.name=='program.ssa'and f not in keep) or (f.name=='stdout'and f.stat().st_size>1000000):omitted.append(row)
 else:rows.append(row)
seen={}
with (out/'evidence.tar.gz').open('xb')as raw,gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0)as z,tarfile.open(fileobj=z,mode='w|')as t:
 for row in rows:
  key=(row['bytes'],row['sha256']);ti=tarfile.TarInfo(row['archivePath']);ti.mtime=0;ti.mode=0o644
  if key in seen:ti.type=tarfile.LNKTYPE;ti.linkname=seen[key];row['sameBytesAs']=seen[key];t.addfile(ti)
  else:
   seen[key]=ti.name;ti.size=row['bytes']
   with pathlib.Path(row['file']).open('rb')as f:t.addfile(ti,f)
  assert pin(pathlib.Path(row['file']))['sha256']==row['sha256']
r=dict(complete=True,targetsRun=False,method=pin(pathlib.Path(__file__)),archive=pin(out/'evidence.tar.gz'),files=rows,omittedRetainedProducts=omitted,scope='Complete listed metadata, methods, logs and one canonical reproduced full QBE. Exact large machine/IR products omitted from this archive remain retained at pinned local paths and reproducible by recorded methods. Repeated bytes use in-archive hard links; extract into a fresh directory. This is not a standalone toolchain bundle.')
(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(dict(files=len(rows),omitted=len(omitted),archiveBytes=r['archive']['bytes'])))
