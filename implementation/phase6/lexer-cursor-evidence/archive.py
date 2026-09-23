from pathlib import Path
import json,hashlib,tarfile,gzip,io
ROOT=Path(__file__).resolve().parents[3]; OUT=Path(__file__).resolve().parent;RUN=ROOT/'selfhost/build/phase6/campaign/diagnostics';sha=lambda b:hashlib.sha256(b).hexdigest()
files=set()
for p in RUN.iterdir():
 if p.name.startswith('lexer'):
  files.update(q for q in p.rglob('*') if q.is_file()) if p.is_dir() else files.add(p)
for n in ['implementation/phase6/lexer-cursor.md','implementation/phase6/lexer-cursor-candidate.patch','experiments/phase6/P6-004-source-provenance.md','selfhost/tools/performance/phase6/lexer-position-controls.mjs']:files.add(ROOT/n)
files.add(Path(__file__).resolve());files.add(Path('/tmp/prepare_p6_diagnostics.py'))
for n in ['selfhost/build/phase5/integration/attempt-05/api.mjs','selfhost/build/phase5/integration/attempt-05/api.mjs.bootstrap.json','selfhost/.bootstrap/upstream/bend2/bend.ts','selfhost/.bootstrap/upstream/bend2/comp.ts','selfhost/.bootstrap/upstream/bend2/base.bend']:files.add(ROOT/n)
assert json.loads((RUN/'lexer-comparison.json').read_text())['lostExact']==0
members=[];archive=OUT/'raw.tar.gz'
with archive.open('xb') as raw,gzip.GzipFile(fileobj=raw,mode='wb',mtime=0,filename='') as gz,tarfile.open(fileobj=gz,mode='w|') as tar:
 for p in sorted(files):
  data=p.read_bytes();name=str(p.relative_to(ROOT)) if p.is_relative_to(ROOT) else 'reproduction/'+p.name
  info=tarfile.TarInfo(name);info.size=len(data);info.mode=0o644;tar.addfile(info,io.BytesIO(data));members.append({'path':name,'original':str(p),'bytes':len(data),'sha256':sha(data)})
index={m['path']:m for m in members}
with tarfile.open(archive,'r:gz') as tar:
 assert len(tar.getmembers())==len(index)
 for m in tar:
  data=tar.extractfile(m).read();assert sha(data)==index[m.name]['sha256'];assert len(data)==index[m.name]['bytes']
for m in members:assert sha(Path(m['original']).read_bytes())==m['sha256']
manifest={'kind':'phase6-lexer-cursor-evidence','complete':True,'archive':archive.name,'bytes':archive.stat().st_size,'sha256':sha(archive.read_bytes()),'membersVerified':True,'members':members,'scope':'Isolated checked compiler,20 paired focused observations,36 direct controls,21 default controls; no full-suite or controlled timing claim. Two old escape-precedence differences remain.','externalPrerequisites':'Recorded Node/Linux tools and upstream Git metadata; historical absolute paths are identities, not relocated bootstrap claims.'}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({k:v for k,v in manifest.items() if k!='members'}))
