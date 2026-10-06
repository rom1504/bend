#!/usr/bin/env python3
"""Data-only relocation of the exact Phase57 two-stage own-source emission probe."""
import argparse, hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]; TOOLS=HERE.parents[1]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase58') and not out.exists()
def identity(file):
 file=Path(file).resolve();return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())
def url(file):return json.dumps(Path(file).resolve().as_uri())
def literal(file):return json.dumps(str(Path(file).resolve()))
outputs=[];derivations=[]
for name,pin,target in [
 ('profile-v3.mjs','d5044de9f3e056fb300b7fbdc93afe9820164fe87830efd366d72b6a8ed39a69','profile.mjs'),
 ('emission-profile-v2.mjs','a7d6ae0d980146a327ecda9c6e22d3f6181fe79ff8ff79f5c2ec0f8634370fa4','emission.mjs')]:
 parent=TOOLS/'phase57'/name;before=identity(parent);assert before['sha256']==pin
 text=parent.read_text();edits=[]
 def edit(old,new):
  global text
  count=text.count(old);assert count,old[:120];text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
 if name=='profile-v3.mjs':
  edit("from '../programs/profile.mjs'",'from '+url(TOOLS/'programs/profile.mjs'))
  edit("new URL('../programs/profile.mjs',import.meta.url)",'new URL('+url(TOOLS/'programs/profile.mjs')+')')
  for old in ['profile-v2.mjs','profile.mjs']:
   edit("new URL('./"+old+"',import.meta.url)",'new URL('+url(TOOLS/'phase57'/old)+')')
  edit("path.resolve(import.meta.dirname,'../../../build/phase57')",'path.resolve('+literal(ROOT/'selfhost/build/phase58')+')')
  edit("assert.equal(mode,'cpu','This successor is fixed CPU-only')","assert.ok(['cpu','allocation'].includes(mode))")
  edit('131072','1048576');edit('128KiB','1MiB')
  edit('phase57-async-compiler-profile','phase58-own-source-stage-profile')
  edit('phase57:unspecified-compiler-module','phase58:unspecified-compiler-module')
  text='// Phase58:25ms CPU or 1MiB collected-object allocation, separate inspector sessions.\n'+text
 else:
  edit("from './setup.mjs'",'from '+url(HERE/'setup-v2.mjs'))
  edit("from './profile-v3.mjs'",'from '+url(out/'profile.mjs'))
  edit("from '../phase54/bootstrap/adapter.mjs'",'from '+url(TOOLS/'phase54/bootstrap/adapter.mjs'))
  edit("const [pinsFile,outArg]=process.argv.slice(2);\nassert.ok(pinsFile&&outArg,'emission-profile.mjs IMAGE_PINS NEW_PHASE57_DIRECTORY');",
       "const [bindingsFile,role,outArg,mode='clean']=process.argv.slice(2);\nassert.ok(bindingsFile&&role&&outArg,'emission.mjs BINDINGS ROLE NEW_PHASE58_DIRECTORY [clean|cpu|allocation]');\nassert.ok(['clean','cpu','allocation'].includes(mode));")
  edit("root=path.resolve(import.meta.dirname,'../../../..')",'root=path.resolve('+literal(ROOT)+')')
  edit("selfhost/build/phase57","selfhost/build/phase58")
  edit("kind:'phase57-b2-own-source-emission-profile-v2',pass:false,complete:false,cleanTiming:false,",
       "kind:'phase58-b2-own-source-emission',pass:false,complete:false,mode,role,cleanTiming:mode==='clean',binding:identity(bindingsFile),")
  edit("scope:'One complete unsplit reproduction using the frozen Phase56 pipeline and exact B2/B3 byte oracle. Independent 25ms inspector sessions enclose only emitted-reachability and unsplit-library, not other stages/setup/import/counting/byte-oracle/final hashing. No compiler warmup or repeated request. These diagnostic times are not benchmark ratios.',",
       "scope:'One complete unsplit own-source reproduction using the retained pipeline and exact per-image B2/B3 byte oracle. Clean mode has no inspector; CPU25ms or allocation1MiB captures only emitted-reachability and unsplit-library in separate sessions. No warmup/repeats or fresh source self-check. Across images this is an explicit changed-source comparison, not isolated lookup causality; profile times are never clean ratios.',")
  edit("if(!['emitted-reachability','unsplit-library'].includes(name))", "if(mode==='clean'||!['emitted-reachability','unsplit-library'].includes(name))")
  edit('cpuCaptured:false','profileMode:null');edit('cpuCaptured:true','profileMode:mode')
  edit("profile({mode:'cpu',samplingIntervalUs:25000,targetMs:100,maxRequests:1,", "profile({mode,samplingIntervalUs:25000,samplingIntervalBytes:1048576,targetMs:100,maxRequests:1,")
  edit("out:path.join(out,'cpu',name)","out:path.join(out,mode,name)")
  for rel,source in [('../phase56/bootstrap/reproduce-v2.mjs',TOOLS/'phase56/bootstrap/reproduce-v2.mjs'),
                     ('./setup.mjs',TOOLS/'phase57/setup.mjs'),('./profile-v3.mjs',TOOLS/'phase57/profile-v3.mjs'),
                     ('./emission-profile.mjs',TOOLS/'phase57/emission-profile.mjs')]:
   edit("new URL('"+rel+"',import.meta.url)",'new URL('+url(source)+')')
  edit("const s=await setup(pinsFile,path.join(out,'private'),{role:'direct',progress});\n  const {api,D,subject,emission,roots}=s;apiUrl=pathToFileURL(s.image.api.file).href;",
       "const s=await setup(bindingsFile,path.join(out,'private'),{role,progress});\n  assert.equal(s.image.kind,'direct','Own-source reproduction requires a genuine emitted B2');\n  const {api,D,subject}=s,emission=JSON.parse(fs.readFileSync(s.image.emission.file,'utf8')),roots=emission.roots;\n  assert.equal(s.image.api.sha256,emission.module.sha256);apiUrl=pathToFileURL(s.image.api.file).href;\n  parents.push(identity(new URL("+url(HERE/'setup-v2.mjs')+")),identity(new URL("+url(out/'profile.mjs')+")),identity(new URL("+url(out/'derivation.json')+")),report.binding);")
  # Allocation has no CPU count-summary; all actually returned files remain pinned.
  edit("const pin=phase.profile[key];verify({file:pin.file,sha256:pin.sha256});",
       "const pin=phase.profile[key];if(!pin)continue;verify({file:pin.file,sha256:pin.sha256});")
  text='// Phase58 clean/CPU/allocation successor; inherited-source provenance is not kernel proof trust.\n'+text
 output=dict(file=str(out/target),sha256=hashlib.sha256(text.encode()).hexdigest())
 outputs.append((out/target,text));derivations.append(dict(parent=before,output=output,edits=edits,
  prefix='// Phase58:25ms CPU or 1MiB collected-object allocation, separate inspector sessions.\n' if name=='profile-v3.mjs' else '// Phase58 clean/CPU/allocation successor; inherited-source provenance is not kernel proof trust.\n'))
receipt=dict(kind='phase58-own-source-emission-method',producer=identity(__file__),setup=identity(HERE/'setup-v2.mjs'),
 derivations=derivations,scope='Exact parent transformations only; no compiler imported or executed. Preserve complete unsplit emission and per-image byte equality. Root supplies serial CPU3/420s/1GiB heap/2GiB tree RSS/4GiB available guard. Allocation is a separately guarded attempt, not guaranteed to fit.')
out.mkdir(parents=True)
for file,text in outputs:file.write_text(text)
(out/'derivation.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps(dict(worker=identity(out/'emission.mjs'),profiler=identity(out/'profile.mjs'),derivation=identity(out/'derivation.json'))))
