#!/usr/bin/env python3
"""Read-only checked14 source/accounting binding; JSON receipt on stdout, no execution."""
import argparse, datetime, hashlib, json, pathlib, re
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--attempt',default='selfhost/build/phase43/checked14/attempt.json')
a=p.parse_args();root=pathlib.Path(__file__).resolve().parents[5]
ATTEMPT_SHA='74253f5020e40dad706d352744694f67569a91a3beefb7834ba2c9c9ff2ee5f3'
API_SHA='222902e565253ae20c628301a9191c6d71e47b211f1dc463da4e8eb1b51c86eb'
RUNTIME_SHA='e62cf92d8b600fdc2eb44029b1945f288c81bf878931f883a1b6f4fb5774aaeb'
def identity(path):
 path=pathlib.Path(path).resolve();b=path.read_bytes()
 return {'file':str(path),'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)}
def checked(row):
 result=identity(row.get('canonicalPath',row['file']));assert result['sha256']==row['sha256'], 'identity mismatch: '+result['file'];return result
attempt_path=(root/a.attempt).resolve();attempt_identity=identity(attempt_path);assert attempt_identity['sha256']==ATTEMPT_SHA,'tool binds checked14 only'
attempt=json.loads(attempt_path.read_bytes());assert attempt['checked'] is True;assert attempt['artifactKind']=='derived-b1'
api=checked(attempt['api']);runtime=checked(attempt['runtime']);base=checked(attempt['base']);assert api['sha256']==API_SHA;assert runtime['sha256']==RUNTIME_SHA
snapshot=pathlib.Path(attempt['snapshot']['root']).resolve();assert snapshot==attempt_path.parent/'snapshot'
frozen_rows={}
for row in attempt['snapshot']['sources']:
 f=pathlib.Path(row['frozen'].get('canonicalPath',row['frozen']['file'])).resolve()
 assert f.is_relative_to(snapshot);name=str(f.relative_to(snapshot));assert name not in frozen_rows
 frozen_rows[name]=row
files=[]
def join(name):
 assert name in frozen_rows,'missing frozen provenance '+name
 row=frozen_rows[name];frozen=checked(row['frozen']);current=identity(root/'selfhost'/name)
 assert frozen['sha256']==row['original']['sha256'];assert current['sha256']==frozen['sha256'],'canonical source drift '+name
 files.append({'name':name,'frozen':frozen,'current':current});return pathlib.Path(frozen['file']).read_bytes()
manifest=join('src/compiler.json');names=json.loads(manifest)['modules'];assert len(names)==70;assert len(set(names))==70
counts={'modules':len(names),'physicalLines':0,'nonblankLines':0,'bytes':0,'defs':0,'types':0,'laws':0}
for name in names:
 assert name.startswith('src/') and name.endswith('.bend')
 b=join(name);counts['physicalLines']+=len(b.splitlines());counts['nonblankLines']+=sum(bool(l.strip()) for l in b.splitlines());counts['bytes']+=len(b)
 for key,token in [('defs','def'),('types','type'),('laws','law')]:counts[key]+=len(re.findall(('^'+token+r'\b').encode(),b,re.M))
assert counts=={'modules':70,'physicalLines':21440,'nonblankLines':18414,'bytes':927243,'defs':2413,'types':72,'laws':640}
runtime_names=sorted(str(f.relative_to(snapshot)) for f in (snapshot/'src/runtime/js').rglob('*.mjs'))
assert len(runtime_names)==9
current_runtime_names=sorted(str(f.relative_to(root/'selfhost')) for f in (root/'selfhost/src/runtime/js').rglob('*.mjs'))
assert current_runtime_names==runtime_names,'runtime module membership drift'
for name in runtime_names:join(name)
assembled=join('src/runtime.mjs');assert hashlib.sha256(assembled).hexdigest()==RUNTIME_SHA
report={'kind':'phase43-checked14-source-accounting-binding','complete':True,'pass':True,'execution':False,'created':datetime.datetime.now(datetime.timezone.utc).isoformat(),'producer':identity(__file__),'attempt':attempt_identity,'api':api,'runtime':runtime,'base':base,'manifestSha256':hashlib.sha256(manifest).hexdigest(),'compilerCounts':counts,'canonicalRuntimeModules':len(runtime_names),'assembledRuntimePhysicalLines':len(assembled.splitlines()),'canonicalMatchesSelectedSnapshot':True,'files':files,'scope':'Static selected checked14 identity join for maintained70-module compiler graph,manifest,nine canonical runtime modules and assembled runtime. No checker/bootstrap/program execution,semantic or timing claim. Other repository source/tools and campaign intervals remain separate accounting inventories.'}
print(json.dumps(report,indent=2))
