"""Archive completed Phase137 experiment inputs/results without chasing old DAGs."""
import argparse,gzip,hashlib,json,pathlib,tarfile,io
ROOT=pathlib.Path(__file__).resolve().parents[5]
p=argparse.ArgumentParser();p.add_argument('--out',type=pathlib.Path,required=True);p.add_argument('--phase137-dir',action='append',required=True);p.add_argument('--phase111-dir',action='append',default=[]);a=p.parse_args()
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'implementation/phase137');out.mkdir(parents=True)
def pin(p):
 p=pathlib.Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
files=[]
for phase,names in [('phase137',a.phase137_dir),('phase111',a.phase111_dir)]:
 for name in names:
  d=ROOT/'selfhost/build'/phase/name;assert d.is_dir() and d.resolve().parent==ROOT/'selfhost/build'/phase
  for f in sorted(d.rglob('*')):
   if not f.is_file() or f.is_symlink() or '__pycache__'in f.parts:continue
   # Native ELF/objects remain retained at their exact recorded paths. Their
   # generated IR, machine excerpts, construction recipes and hashes are kept.
   if f.name in ['program','program.o','program.s'] or f.suffix in ['pyc']:continue
   files.append(f)
rows=[dict(pin(f),archivePath=str(f.relative_to(ROOT)))for f in sorted(set(files))]
with (out/'evidence.tar.gz').open('xb') as raw,gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0) as z,tarfile.open(fileobj=z,mode='w|') as t:
 for row in rows:
  data=pathlib.Path(row['file']).read_bytes();assert hashlib.sha256(data).hexdigest()==row['sha256'];ti=tarfile.TarInfo(row['archivePath']);ti.size=len(data);ti.mtime=0;ti.mode=0o644;t.addfile(ti,io.BytesIO(data))
r=dict(complete=True,targetsRun=False,method=pin(__file__),archive=pin(out/'evidence.tar.gz'),files=rows,scope='Explicit frozen Phase137 directories only. No claim of a standalone toolchain bundle. Parent artifacts remain bound by their committed phase reports and receipts; native ELF/objects are retained locally, not duplicated here.')
(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(dict(files=len(rows),rawBytes=sum(x['bytes']for x in rows),archiveBytes=r['archive']['bytes'])))
