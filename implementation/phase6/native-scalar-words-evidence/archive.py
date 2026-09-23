#!/usr/bin/env python3
"""Preserve the closed P6-005 attempts as deduplicated immutable byte objects."""
import datetime, gzip, hashlib, io, json, pathlib, tarfile

ROOT=pathlib.Path(__file__).resolve().parents[3]
HERE=pathlib.Path(__file__).resolve().parent
HOME=ROOT/'selfhost/build/phase6/campaign/native'
sha=lambda b:hashlib.sha256(b).hexdigest()
paths={p.resolve() for p in HOME.rglob('*') if p.is_file()}
paths.update(p.resolve() for p in [pathlib.Path(__file__),
    ROOT/'experiments/phase6/P6-005-native-scalar-words.md',
    ROOT/'implementation/phase6/native-scalar-words.md',
    ROOT/'implementation/phase6/native-scalar-words-candidate.patch',
    ROOT/'implementation/phase6/native-scalar-audit.py',
    ROOT/'implementation/phase6/native-scalar-independent-review.md'])
paths.update(p.resolve() for p in (ROOT/'selfhost/tools/performance/phase6').glob('native-scalar-*.mjs'))
expected={};external={}
def excluded(p):
    return '/.nvm/versions/node/' in str(p) or '/build/phase1/clang/' in str(p)
def require(file,digest=None):
    p=pathlib.Path(file)
    if not p.is_absolute() or not p.is_file():return
    p=p.resolve()
    if digest:
        assert p not in expected or expected[p]==digest,(p,expected[p],digest)
        expected[p]=digest
    if excluded(p):external[p]=digest
    else:paths.add(p)
def walk(x):
    if isinstance(x,dict):
        if isinstance(x.get('file'),str) and isinstance(x.get('sha256'),str):require(x['file'],x['sha256'])
        if isinstance(x.get('inputPaths'),dict) and isinstance(x.get('inputHashes'),dict):
            for k,f in x['inputPaths'].items():
                if isinstance(f,str):require(f,x['inputHashes'].get(k))
        for v in x.values():walk(v)
    elif isinstance(x,list):
        for v in x:walk(v)
for p in list(paths):
    if p.suffix=='.json':
        try:walk(json.loads(p.read_text()))
        except (UnicodeDecodeError,json.JSONDecodeError):pass
toolchain=json.loads((HOME/'native-toolchain.json').read_text())['toolchain']
require(toolchain['CC'])
for name in ['libLLVM-16.so.1','libclang-cpp.so.16']:
    require(str(pathlib.Path(toolchain['LD_LIBRARY_PATH'])/name))
objects={};identities=[]
for p in sorted(paths):
    b=p.read_bytes();h=sha(b)
    if p in expected:assert h==expected[p],str(p)
    objects.setdefault(h,b)
    identities.append({'file':str(p),'sha256':h,'bytes':len(b),'mode':p.stat().st_mode&0o777,'object':'objects/'+h})
externals=[]
for p,digest in sorted(external.items()):
    b=p.read_bytes();h=sha(b)
    if digest:assert h==digest,str(p)
    externals.append({'file':str(p),'sha256':h,'bytes':len(b),'retained':False,'reason':'External Node or Clang toolchain prerequisite; recorded separately from compiler evidence.'})
archive=HERE/'raw.tar.gz';assert not archive.exists()
with archive.open('xb') as raw,gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0,compresslevel=6) as gz,tarfile.open(fileobj=gz,mode='w|') as tar:
    for h,b in sorted(objects.items()):
        info=tarfile.TarInfo('objects/'+h);info.size=len(b);info.mode=0o644;info.mtime=0;tar.addfile(info,io.BytesIO(b))
with tarfile.open(archive,'r:gz') as tar:
    actual={m.name:sha(tar.extractfile(m).read()) for m in tar if m.isfile()}
assert actual=={'objects/'+h:h for h in objects}
for row in identities:assert sha(pathlib.Path(row['file']).read_bytes())==row['sha256']
manifest={'kind':'phase6-native-scalar-words-evidence','created':datetime.datetime.now(datetime.timezone.utc).isoformat(),
  'archive':{'file':archive.name,'sha256':sha(archive.read_bytes()),'bytes':archive.stat().st_size},
  'identityCount':len(identities),'objectCount':len(objects),'identities':identities,'externalPrerequisites':externals,
  'toolchainEnvironment':toolchain,'allArchiveObjectsVerified':True,'allOriginalBytesReverified':True,
  'scope':'All owned closed attempts, failures, fixture copies, C/binaries, genuine build/derivation, caches and consumed source/tools. Absolute paths are historical identities, not an automatic relocation promise.'}
(HERE/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({k:manifest[k] for k in ['identityCount','objectCount','archive','allArchiveObjectsVerified','allOriginalBytesReverified']}))
