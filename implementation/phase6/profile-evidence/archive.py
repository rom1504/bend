from pathlib import Path
import json,hashlib,tarfile,io,datetime
root=Path.cwd();out=root/'implementation/phase6/profile-evidence'
report=root/'selfhost/build/phase6/optimized-core-profile-01/profile/report.json'
r=json.loads(report.read_text());files=set()
for p in (root/'selfhost/build/phase6/optimized-core-profile-01').rglob('*'):
 if p.is_file():files.add(p)
for name in ['selfhost/build/phase6/profile-preparation.json','selfhost/build/phase6/profile-timestamp-correction.json','selfhost/build/phase6/optimized-core-profile-config.json','experiments/phase6/P6-001-optimized-residual-profile.md','selfhost/tools/performance/phase4/bounded-profile.mjs','selfhost/tools/performance/phase4/cpu-profile.mjs','selfhost/build/phase5/full-source-final/derived/api.mjs.derivation.json']:
 files.add(root/name)
external=[]
for x in r['inputs']:
 p=Path(x['file']);assert hashlib.sha256(p.read_bytes()).hexdigest()==x['sha256']
 if p==Path(r['node']['path']):external.append(x)
 else:files.add(p)
files.add(Path(__file__).resolve())
objects={};entries=[]
for p in sorted(files):
 data=p.read_bytes();h=hashlib.sha256(data).hexdigest();objects[h]=data;entries.append({'file':str(p),'sha256':h,'bytes':len(data)})
archive=out/'raw.tar.gz'
with tarfile.open(archive,'w:gz') as tar:
 for h,data in sorted(objects.items()):
  info=tarfile.TarInfo('objects/'+h);info.size=len(data);info.mtime=0;tar.addfile(info,io.BytesIO(data))
with tarfile.open(archive,'r:gz') as tar:
 for item in tar:
  data=tar.extractfile(item).read();assert hashlib.sha256(data).hexdigest()==item.name.split('/')[-1]
for item in entries:assert hashlib.sha256(Path(item['file']).read_bytes()).hexdigest()==item['sha256']
manifest={'created':datetime.datetime.now(datetime.timezone.utc).isoformat(),'complete':True,'archive':{'file':archive.name,'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'bytes':archive.stat().st_size},'entries':entries,'externalPrerequisites':external,'scope':'Exact profile files and consumed inputs; current release/source/proof lineage is preserved separately in Phase5 evidence. Historical paths remain unchanged.'}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({'identities':len(entries),'objects':len(objects),**manifest['archive']}))
