"""Archive existing derived frontend evidence; never invoke a compiler."""
import datetime,gzip,hashlib,io,json,pathlib,sys,tarfile

def digest(data): return hashlib.sha256(data).hexdigest()
def identity(path):
    path=pathlib.Path(path).absolute()
    return {'file':str(path),'canonicalPath':str(path.resolve(strict=True)),'sha256':digest(path.read_bytes())}
def verify(expected):
    assert identity(expected['file'])=={k:expected[k] for k in ['file','canonicalPath','sha256']},expected['file']
def read(path): return json.loads(pathlib.Path(path).read_text())

if len(sys.argv)!=4: raise SystemExit('Usage: derived-frontend-archive.py RUN_REPORT AUDIT_REPORT NEW_OUTPUT_DIRECTORY')
run_file,audit_file,out=map(lambda p:pathlib.Path(p).absolute(),sys.argv[1:])
run,audit=read(run_file),read(audit_file)
assert run['kind']=='experimental-derived-frontend' and audit['kind']=='experimental-derived-frontend-audit'
assert all(x['complete'] and x['inputsVerified'] and x['newBootstrap'] is False for x in [run,audit])
assert run['probeCount']==audit['probeCount']==2756 and run['differences']==[] and audit['workerHistoriesVerified']
assert any(i==identity(run_file) for i in audit['inputs'])
for item in audit['inputs']: verify(item)
assert not out.exists();out.mkdir()
files={}
def tree(directory,prefix):
    directory=pathlib.Path(directory)
    for p in sorted(directory.rglob('*')):
        assert not p.is_symlink(),'Refuse symlink archive input: '+str(p)
        if p.is_file():files[prefix+'/'+p.relative_to(directory).as_posix()]=p

tree(run_file.parent,'frontend')
preparation=pathlib.Path(run['inputs'][0]['file']);assert read(preparation)['kind']=='phase4-b1-native-equality-preparation'
tree(preparation.parent,'preparation')
files['audit/report.json']=audit_file
snapshot_file=next(pathlib.Path(i['file']) for i in run['inputs'] if pathlib.Path(i['file']).name=='snapshot.json')
snapshot=read(snapshot_file)
files['reference/snapshot.json']=snapshot_file
files['reference/checked-proof.json']=pathlib.Path(run['originalCheckedProof']['file'])
files['reference/historical-observations.json']=pathlib.Path(snapshot['historical'])
proof=read(run['originalCheckedProof']['file']);verify(proof['source']);files['reference/checked-source.bend']=pathlib.Path(proof['source']['file'])
for name in ['derived-frontend.mjs','derived-frontend-audit.mjs','derived-frontend-archive.py','analysis-b1-equality.mjs']:
    files['tools/'+name]=pathlib.Path(__file__).absolute().parent/name
files['tools/private-common.mjs']=pathlib.Path(__file__).absolute().parents[2]/'private-compiler/common.mjs'
for p in [*run_file.parent.parent.glob('frontend-launch.std*'),*audit_file.parent.glob('frontend-audit.std*')]:files['logs/'+p.name]=p
members=[]
for name,p in sorted(files.items()):
    assert not p.is_symlink() and not name.startswith('/') and '..' not in pathlib.PurePosixPath(name).parts
    members.append({'archivePath':name,'identity':identity(p),'bytes':p.stat().st_size})
archive=out/'raw.tar.gz'
with archive.open('wb') as raw:
    with gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0,compresslevel=6) as compressed:
        with tarfile.open(mode='w',fileobj=compressed) as tar:
            for member in members:
                data=pathlib.Path(member['identity']['file']).read_bytes();assert digest(data)==member['identity']['sha256']
                entry=tarfile.TarInfo(member['archivePath']);entry.mode=0o644;entry.mtime=0;entry.size=len(data);tar.addfile(entry,io.BytesIO(data))
# Verify the actual compressed archive's complete member set, paths and bytes.
expected={m['archivePath']:m for m in members};seen=set()
with tarfile.open(archive,'r:gz') as tar:
    for item in tar:
        assert item.isfile() and item.name in expected and item.name not in seen
        assert not item.name.startswith('/') and '..' not in pathlib.PurePosixPath(item.name).parts
        data=tar.extractfile(item).read();m=expected[item.name]
        assert len(data)==m['bytes'] and digest(data)==m['identity']['sha256'];seen.add(item.name)
assert seen==set(expected)
for member in members:verify(member['identity'])
for item in audit['inputs']:verify(item)
manifest={'kind':'experimental-derived-frontend-evidence','complete':True,'newBootstrap':False,'created':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Existing exact frontend gate and independent read-only audit. The checked proof covers the original control, not the transformed candidate. No new compiler execution or performance comparison.','archive':identity(archive),'archiveBytes':archive.stat().st_size,'archiveMembersVerified':len(members),'archivePathsVerified':True,'run':identity(run_file),'audit':identity(audit_file),'control':run['control'],'candidate':run['candidate'],'originalCheckedProof':run['originalCheckedProof'],'probes':run['probeCount'],'histories':len(run['histories']),'inputMappings':audit['inputMappings'],'summary':run['summary'],'fullConformance':run['fullConformance'],'tool':identity(__file__),'python':{'version':sys.version,'executable':identity(sys.executable)},'files':members}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({'complete':True,'newBootstrap':False,'membersVerified':len(members),'archiveBytes':archive.stat().st_size,'archiveSha256':manifest['archive']['sha256']}))
