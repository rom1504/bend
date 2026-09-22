"""Preserve and verify an existing derived-B1 whole-source gate, without compiling."""
import datetime,gzip,hashlib,io,json,pathlib,sys,tarfile

def digest(data):return hashlib.sha256(data).hexdigest()
def identity(path):
    path=pathlib.Path(path).absolute()
    return {'file':str(path),'canonicalPath':str(path.resolve(strict=True)),'sha256':digest(path.read_bytes())}
def verify(item):assert identity(item['file'])=={k:item[k] for k in ['file','canonicalPath','sha256']},item['file']
def read(path):return json.loads(pathlib.Path(path).read_text())
if len(sys.argv)!=4:raise SystemExit('Usage: derived-b1-full-archive.py FULL_REPORT AUDIT_REPORT NEW_EVIDENCE_DIRECTORY')
run_file,audit_file,out=map(lambda x:pathlib.Path(x).absolute(),sys.argv[1:]);run,audit=read(run_file),read(audit_file)
assert run['kind']=='phase4-derived-b1-full-source' and audit['kind']=='phase4-derived-b1-full-source-audit'
assert run['complete'] and run['inputsUnchanged'] and audit['complete'] and audit['inputsVerified']
assert run['newBootstrap'] is False and audit['newBootstrap'] is False and audit['bothOriginalFixedpointOutputsByteEqual']
assert identity(run_file) in audit['inputs']
for item in audit['inputs']:verify(item)
assert not out.exists();out.mkdir();files={}
for p in sorted(run_file.parent.rglob('*')):
    assert not p.is_symlink()
    if p.is_file():files['full-source/'+p.relative_to(run_file.parent).as_posix()]=p
files['audit/report.json']=audit_file
# Retain every consumed regular artifact; Node's executable is externally identified.
external=[]
for index,item in enumerate(run['inputs']):
    p=pathlib.Path(item['file']);verify(item)
    if p.name=='node' and p.parent.name=='bin':external.append(item);continue
    assert not p.is_symlink();files[f'inputs/{index:04d}-{p.name}']=p
for name in ['derived-b1-full.mjs','derived-b1-full-audit.mjs','derived-b1-full-archive.py','analysis-b1-equality.mjs']:
    files['tools/'+name]=pathlib.Path(__file__).absolute().parent/name
files['tools/private-common.mjs']=pathlib.Path(__file__).absolute().parents[2]/'private-compiler/common.mjs'
for p in sorted(run_file.parent.parent.glob('full-source*.std*')):files['logs/'+p.name]=p
members=[]
for name,p in sorted(files.items()):
    assert not name.startswith('/') and '..' not in pathlib.PurePosixPath(name).parts
    members.append({'archivePath':name,'identity':identity(p),'bytes':p.stat().st_size})
archive=out/'raw.tar.gz'
with archive.open('wb') as raw:
    with gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0,compresslevel=6) as compressed:
        with tarfile.open(mode='w',fileobj=compressed) as tar:
            for member in members:
                data=pathlib.Path(member['identity']['file']).read_bytes();assert digest(data)==member['identity']['sha256']
                item=tarfile.TarInfo(member['archivePath']);item.mode=0o644;item.mtime=0;item.size=len(data);tar.addfile(item,io.BytesIO(data))
expected={m['archivePath']:m for m in members};seen=set()
with tarfile.open(archive,'r:gz') as tar:
    for item in tar:
        assert item.isfile() and item.name in expected and item.name not in seen
        assert not item.name.startswith('/') and '..' not in pathlib.PurePosixPath(item.name).parts
        data=tar.extractfile(item).read();m=expected[item.name];assert len(data)==m['bytes'] and digest(data)==m['identity']['sha256'];seen.add(item.name)
assert seen==set(expected)
for member in members:verify(member['identity'])
for item in audit['inputs']:verify(item)
manifest={'kind':'phase4-derived-b1-full-source-evidence','complete':True,'newBootstrap':False,'created':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'A single complete-source correctness observation and independent read-only audit. No fresh checked bootstrap or paired full-source speed claim.','archive':identity(archive),'archiveBytes':archive.stat().st_size,'archiveMembersVerified':len(members),'archivePathsVerified':True,'run':identity(run_file),'audit':identity(audit_file),'candidate':audit['candidate'],'control':audit['control'],'source':audit['source'],'runtime':audit['runtime'],'base':audit['base'],'actualOutputBytes':audit['actualOutputBytes'],'outputSha256':audit['outputSha256'],'bothOriginalFixedpointOutputsByteEqual':True,'originalCheckedProof':audit['originalCheckedProof'],'originalFixedpointProof':audit['originalFixedpointProof'],'reportedObservation':audit['reportedObservation'],'externalExecutables':external,'tool':identity(__file__),'python':{'version':sys.version,'executable':identity(sys.executable)},'files':members}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({'complete':True,'newBootstrap':False,'membersVerified':len(members),'archiveBytes':archive.stat().st_size,'archiveSha256':manifest['archive']['sha256']}))
