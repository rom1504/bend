from pathlib import Path
import hashlib,json,tarfile,io,datetime
root=Path.cwd();out=root/'implementation/phase5/native-exit-fix-evidence'
files=set(p for p in (root/'selfhost/build/phase5/native-exit-fix').rglob('*') if p.is_file())
for name in ['selfhost/tools/native-build.mjs','selfhost/tests/native-build.test.mjs','selfhost/tools/development/release.mjs','selfhost/dist/release.json','selfhost/dist/typed-api.mjs','selfhost/dist/base.bend','design/phase5/consolidated-release.md']:
 files.add(root/name)
files.update(p for p in (root/'selfhost/dist/release-lineage').rglob('*') if p.is_file());files.add(Path(__file__).resolve())
entries=[];objects={}
for p in sorted(files):
 data=p.read_bytes();h=hashlib.sha256(data).hexdigest();objects[h]=data;entries.append({'file':str(p),'sha256':h,'bytes':len(data)})
archive=out/'raw.tar.gz'
with tarfile.open(archive,'w:gz') as tar:
 for h,data in sorted(objects.items()):
  info=tarfile.TarInfo('objects/'+h);info.size=len(data);info.mtime=0;tar.addfile(info,io.BytesIO(data))
with tarfile.open(archive,'r:gz') as tar:
 for member in tar:
  data=tar.extractfile(member).read();assert hashlib.sha256(data).hexdigest()==member.name.split('/')[-1]
for x in entries:assert hashlib.sha256(Path(x['file']).read_bytes()).hexdigest()==x['sha256']
manifest={'complete':True,'created':datetime.datetime.now(datetime.timezone.utc).isoformat(),'archive':{'file':archive.name,'bytes':archive.stat().st_size,'sha256':hashlib.sha256(archive.read_bytes()).hexdigest()},'entries':entries,'externalPrerequisites':'Node24.18 and pinned upstream/toolchain remain external; exact consumed identities are in original build/bootstrap and CLI reports. Historical paths are retained.'}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({'identities':len(entries),'objects':len(objects),**manifest['archive']}))
