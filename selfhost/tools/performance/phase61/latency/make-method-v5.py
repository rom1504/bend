#!/usr/bin/env python3
"""Data-only successor: campaign hashes include diagnostic Node identity; active inputs unchanged."""
import argparse, ast, hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]; RAW=ROOT/'selfhost/build/phase61'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(RAW.resolve()) and not out.exists()
parent=RAW/'latency-method03'
pins={'run.py':'ec4aad5237207dc65867dc055b07fc0070987075c7cd5734ef82730c3b82c460',
'worker.mjs':'d90c71f483f4d653d69bc5abb7f6fb9fb5fabe499553305078885545ba2bd447',
'setup.mjs':'71997aa4ffcf9d4d6a10a53c410e9d772734ba9e97bc4a1b598afc6822eac0df',
'profile.mjs':'6bbb65cf02b47a06a3193ca595f8fcdcd0ca73c408233ac28ee1dfb183348068'}
def identity(file):
 file=Path(file).resolve(strict=True);return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())
profile_old="samplingIntervalBytes=131072,maxRequests=1,moduleUrl="
profile_new="samplingIntervalBytes=131072,maxRequests=1,nodeVerification,moduleUrl="
node_old="node:identity(process.execPath),nodeVersion:process.version"
node_new="node:{...nodeVerification.identity,bytes:Number(nodeVerification.stat.size)},nodeVersion:process.version"
profile_guard=""" assert.equal(fs.realpathSync(process.execPath),nodeVerification.identity.file);
 const nodeStat=fs.statSync(process.execPath,{bigint:true});
 assert.deepEqual(Object.fromEntries(['dev','ino','size','mtimeNs','ctimeNs'].map(k=>[k,String(nodeStat[k])])),nodeVerification.stat);
 assert(['cpu','allocation'].includes(mode));"""
profile_preview=(parent/'profile.mjs').read_text().replace(profile_old,profile_new).replace(node_old,node_new).replace(" assert(['cpu','allocation'].includes(mode));",profile_guard)
profile_sha=hashlib.sha256(profile_preview.encode()).hexdigest()
outputs={};derivations=[]
for name,pin in pins.items():
 before=identity(parent/name);assert before['sha256']==pin;text=(parent/name).read_text();edits=[]
 def edit(old,new,count=1):
  global text
  assert text.count(old)==count,(name,old[:100],text.count(old),count)
  text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
 count=text.count(str(parent))
 if count:edit(str(parent),str(out),count)
 if name=='profile.mjs':
  edit(profile_old,profile_new)
  edit(node_old,node_new)
  edit(" assert(['cpu','allocation'].includes(mode));",profile_guard)
 if name=='run.py':
  edit('def identity(file):', '''stable_paths=set();stable_cache={}
def stat_identity(file):
 s=Path(file).stat();return {k:str(v) for k,v in dict(dev=s.st_dev,ino=s.st_ino,size=s.st_size,mtimeNs=s.st_mtime_ns,ctimeNs=s.st_ctime_ns).items()}
def identity_fresh(file):''')
  edit('def read(file):', '''def identity(file):
 file=Path(file).resolve(strict=True);key=str(file)
 if key not in stable_paths:return identity_fresh(file)
 current=stat_identity(file)
 if key not in stable_cache:
  value=identity_fresh(file);assert stat_identity(file)==current,'Changed while hashing: '+key
  stable_cache[key]=dict(identity=value,stat=current)
 else:assert stable_cache[key]['stat']==current,'Changed stable input: '+key
 return dict(stable_cache[key]['identity'])
def verify_stable_final():
 for key,item in stable_cache.items():
  assert stat_identity(key)==item['stat'],'Changed stable input: '+key
  assert identity_fresh(key)==item['identity'],'Changed stable hash: '+key
  assert stat_identity(key)==item['stat'],'Changed while final hashing: '+key
 return dict(complete=True,pass_=True,files=len(stable_cache),scope='Full SHA before and after; exact stat checks between')
def read(file):''')
  old="inputs=[identity(x) for x in [__file__,WORKER,Path("
  new="""# Only executable and fixed method/support tools. Catalog, bindings, upstream
# compiler files, candidate images, current sources and references stay hashed.
stable_paths={str(Path(x).resolve(strict=True)) for x in [node,__file__,WORKER,
 Path(__file__).with_name('setup.mjs'),Path(__file__).with_name('profile.mjs'),
 HERE.parents[1]/'phase54/bootstrap/adapter.mjs',ROOT/'selfhost/tools/development/workflow.mjs',
 ROOT/'selfhost/tools/development/process.mjs',ROOT/'selfhost/tools/conformance/inventory.mjs',
 PROGRAMS/'support.py',PROGRAMS/'profile.mjs']}
inputs=[identity(x) for x in [__file__,WORKER,Path("""
  edit(old,new)
  edit("resources=dict(cpu=3,", "stableVerification=list(stable_cache.values()),execArgv=['--stack-size=4096','--max-old-space-size=1024'],\n resources=dict(cpu=3,")
  edit(" report['wallSeconds']=time.monotonic()-started;save(out/'report.json',report)", """ try:report['stableVerificationFinal']=verify_stable_final()
 except BaseException as error:
  report['complete']=False;report['pass']=False;report['stableVerificationError']=repr(error)
 report['wallSeconds']=time.monotonic()-started;save(out/'report.json',report)""")
  edit(pins['profile.mjs'],profile_sha)
  ast.parse(text)
 if name=='worker.mjs':
  edit("const verify=item=>{verifyIdentity({file:item.file,sha256:item.sha256});", """const stable=new Map(config.stableVerification.map(x=>[x.identity.file,x]));
const statIdentity=file=>{const s=fs.statSync(file,{bigint:true});return Object.fromEntries(
  ['dev','ino','size','mtimeNs','ctimeNs'].map(k=>[k,String(s[k])]))};
const verify=item=>{const key=fs.realpathSync(item.file),saved=stable.get(key);
  if(saved){assert.equal(item.sha256,saved.identity.sha256);assert.deepEqual(statIdentity(key),saved.stat)}
  else verifyIdentity({file:item.file,sha256:item.sha256});""")
  edit("report.profile=await profile({mode:config.mode,run:firstWindow,","report.profile=await profile({mode:config.mode,nodeVerification:stable.get(config.node.file),run:firstWindow,")
  edit('  verify(request.config);check(config.inputs);', '''  verify(request.config);
  assert.equal(fs.realpathSync(process.execPath),config.node.file);
  assert.deepEqual(process.execArgv,config.execArgv);
  assert.equal(process.env.NODE_OPTIONS??'','');
  check(config.inputs);report.stableVerification={files:stable.size,scope:'Exact stat per worker; campaign SHA before/after'};''')
  edit("'Catalog and actual method hashes plus current source/imports/runtime/raw oracle, staged API/helpers/cache. Full historical qualification was joined once during preparation; preflight differs from Phase59 and remains excluded.'", "'Campaign-stable executable/tool SHA before/after with per-worker exact stat; active source/imports/runtime/raw oracle and staged API/helpers/cache fully hashed before/after. Historical qualification joined during preparation. Preflight excluded.'")
 outputs[name]=text;derivations.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
out.mkdir(parents=True)
for name,text in outputs.items():(out/name).write_text(text)
report=dict(kind='phase61-candidate-fast-loop-method',complete=True,pass_=True,dataOnly=True,targetExecuted=False,
 producer=identity(__file__),parentDerivation=identity(parent/'derivation.json'),derivations=derivations,
 scope='Stable Node and fixed method/support files: SHA once before/once after each runner campaign, exact dev/ino/size/mtimeNs/ctimeNs checks per launch/worker. Active candidate/source/cache/oracle hashes unchanged. ExecPath/flags exact; NODE_OPTIONS absent. No compiler request or warm-up added; original first/later/profile clocks and prepared output equality retained. Stat is an accidental-change detector, not an adversarial filesystem certificate.')
report['pass']=report.pop('pass_');(out/'derivation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({name:identity(out/name) for name in [*outputs,'derivation.json']}))
