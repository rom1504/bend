from pathlib import Path
import hashlib,json,tarfile,io,datetime
root=Path.cwd();out=root/'implementation/phase6/prefix-semantics-evidence';base=root/'selfhost/build/phase6/campaign/semantics'
assert not (out/'manifest.json').exists(), 'Use a fresh archive destination'
files=set(p for p in base.rglob('*')if p.is_file())
for p in base.glob('baseline-*/freeze.stdout'):
 adapter=Path(p.read_text().strip());assert adapter.is_file();files.update(q for q in adapter.parent.rglob('*')if q.is_file())
for name in ['experiments/phase6/P6-003-prefixed-semantics.md','implementation/phase6/prefix-semantics-candidate.patch','implementation/phase6/prefix-erased-semantics-candidate.patch','implementation/phase6/prefix-semantics-audit.py','implementation/phase6/prefix-semantics-audit.json','selfhost/build/phase5/integration/attempt-05/api.mjs','selfhost/build/phase5/integration/attempt-05/api.mjs.bootstrap.json']:
 files.add(root/name)
files.add(Path(__file__).resolve())
entries=[];objects={}
for p in sorted(files):
 data=p.read_bytes();h=hashlib.sha256(data).hexdigest();objects[h]=data;entries.append({'file':str(p),'sha256':h,'bytes':len(data)})
archive=out/'raw.tar.gz'
with tarfile.open(archive,'w:gz')as tar:
 for h,data in sorted(objects.items()):
  info=tarfile.TarInfo('objects/'+h);info.size=len(data);info.mtime=0;tar.addfile(info,io.BytesIO(data))
with tarfile.open(archive,'r:gz')as tar:
 for member in tar:
  data=tar.extractfile(member).read();assert hashlib.sha256(data).hexdigest()==member.name.split('/')[-1]
for x in entries:assert hashlib.sha256(Path(x['file']).read_bytes()).hexdigest()==x['sha256']
manifest={'complete':True,'created':datetime.datetime.now(datetime.timezone.utc).isoformat(),'archive':{'file':archive.name,'bytes':archive.stat().st_size,'sha256':hashlib.sha256(archive.read_bytes()).hexdigest()},'identities':len(entries),'objects':len(objects),'entries':entries,'externalPrerequisites':'Node24.18.0, pinned upstream6018e28e and retained Clang16/system toolchain remain external; native-environment-v2.json records CC,CPATH,LIBRARY_PATH,LD_LIBRARY_PATH. Bootstrap/conformance reports retain consumed input/tool identities. Every local attempt under this campaign, including generated APIs/Base caches and failed attempts, is archived. Successful execution workdirs were normally deleted by the maintained retain=failed harness; regenerate their C/binaries from retained checked images and fixtures. Historical absolute paths are records, not rewritten proof identities.'}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({k:manifest[k]for k in ['identities','objects','archive']}))
