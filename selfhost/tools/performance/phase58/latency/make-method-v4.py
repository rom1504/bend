#!/usr/bin/env python3
"""Data-only, exact successor of the frozen Phase57 latency method."""
import argparse, ast, hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]; TOOLS=HERE.parents[1]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase58') and not out.exists()
parents=[(TOOLS/'phase57/latency/worker.mjs','5cdf4d68af75bf2d6fbb6eb0fbbce4c0de9c7d25ab7a689298c40f1870f43c24'),
         (TOOLS/'phase57/latency/run.py','351fa319a527000ac2b4d6c10e1b2e5829023e48682dbc76f67bacdc758b2e4a')]
def identity(p):
 p=Path(p);return dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def text_literal(p):return repr(str(p.resolve()))
derivations=[];outputs=[]
profile_parent=TOOLS/'phase57/profile-v2.mjs';profile_before=identity(profile_parent)
assert profile_before['sha256']=='f472c5e565827e7a8cfc4181e19dffe61f4485c63a3d137c1315c82e388064f6'
profile_text=profile_parent.read_text();profile_edits=[]
for old,new in [
 ("from '../programs/profile.mjs'",'from '+json.dumps((TOOLS/'programs/profile.mjs').as_uri())),
 ("new URL('../programs/profile.mjs',import.meta.url)",'new URL('+json.dumps((TOOLS/'programs/profile.mjs').as_uri())+')'),
 ("path.resolve(import.meta.dirname,'../../../build/phase57')",'path.resolve('+json.dumps(str(ROOT/'selfhost/build/phase58'))+')'),
 ("new URL('./profile.mjs',import.meta.url)",'new URL('+json.dumps((TOOLS/'phase57/profile.mjs').as_uri())+')'),
 ('phase57-async-compiler-profile','phase58-async-compiler-profile'),
 ('phase57:unspecified-compiler-module','phase58:unspecified-compiler-module')]:
 count=profile_text.count(old);assert count,old;profile_text=profile_text.replace(old,new)
 profile_edits.append(dict(old=old,new=new,count=count))
profile_target=out/'profile.mjs';profile_hash=hashlib.sha256(profile_text.encode()).hexdigest()
outputs.append((profile_target,profile_text))
derivations.append(dict(parent=profile_before,output=dict(file=str(profile_target),sha256=profile_hash),edits=profile_edits))
for parent,pin in parents:
 before=identity(parent);assert before['sha256']==pin;text=parent.read_text();edits=[]
 def edit(old,new):
  global text
  count=text.count(old);assert count,old[:100]
  text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
 edit('phase57','phase58')
 if 'Phase57' in text:edit('Phase57','Phase58')
 edit('four-image','candidate-image')
 if parent.name=='worker.mjs':
  edit("from '../setup.mjs'","from "+json.dumps((HERE/'setup-v4.mjs').as_uri()))
  edit("from '../profile.mjs'","from "+json.dumps(profile_target.as_uri()))
  edit("from '../../phase54/bootstrap/adapter.mjs'","from "+json.dumps((TOOLS/'phase54/bootstrap/adapter.mjs').as_uri()))
  edit('config.imagePins','config.imageBindings');edit("'imagePins'","'imageBindings'")
 else:
  edit("HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]; PROGRAMS=HERE.parents[1]/'programs'",
       'HERE=Path('+text_literal(HERE)+'); ROOT=Path('+text_literal(ROOT)+'); PROGRAMS=HERE.parents[1]/\'programs\'\nWORKER=Path('+text_literal(out/'worker.mjs')+')')
  edit("p.add_argument('--image-pins',type=Path,default=ROOT/'selfhost/build/phase56/bootstrap-string01-plan/image-pins.json')",
       "p.add_argument('--bindings',type=Path,required=True)")
  edit("p.add_argument('--cases',default='test-evening-program,lexer')","p.add_argument('--cases',default='lexer')")
  edit("p.add_argument('--roles',default='typescript,raw,source,direct')","p.add_argument('--roles',default='baseline,candidate')")
  edit("p.add_argument('--rounds',type=int,default=3)","p.add_argument('--rounds',type=int,default=1)\np.add_argument('--warm-requests',type=int,default=1)")
  edit("p.add_argument('--seconds',type=int,default=1800)","p.add_argument('--seconds',type=int,default=60)")
  edit('60<=a.seconds<=3600','20<=a.seconds<=3600 and 1<=a.warm_requests<=3')
  edit("roles=a.roles.split(',');assert roles and len(set(roles))==len(roles) and set(roles)<={'typescript','raw','source','direct'}",
       "binding=json.loads(a.bindings.read_text());assert binding['kind']=='phase58-compiler-image-bindings' and binding['version']==1\nassert binding['comparison'] in ['fixed-source','changed-source']\nroles=a.roles.split(',');assert roles and len(set(roles))==len(roles) and all(x.isidentifier() for x in roles) and set(roles)<=set(binding['roles'])|{'typescript'}")
  edit("image_pins=read(a.image_pins);assert image_pins['kind']=='phase56-direct-image-pins'",
       ("assert identity(TOOLS_PROFILE)['sha256']=="+repr(profile_hash)).replace('TOOLS_PROFILE',text_literal(profile_target)))
  edit("HERE/'worker.mjs'",'WORKER');edit("HERE.parent/'setup.mjs'","HERE/'setup-v4.mjs'")
  edit("HERE.parent/'profile.mjs'",'Path('+text_literal(profile_target)+')')
  edit('a.image_pins','a.bindings');edit('imagePins','imageBindings')
  edit('warmRequests=3','warmRequests=a.warm_requests,comparison=binding[\'comparison\']')
  edit('assert all(len(x)==3 for x in warm)','assert all(len(x)==a.warm_requests for x in warm)')
  old="""   if outputs:
    for x in outputs[1:]:assert Path(outputs[0]['file']).read_bytes()==Path(x['file']).read_bytes(),'Bend compiler outputs differ'
   report['exactBendOutputComparisons'].append(dict(case=case['id'],roles=bend_roles,outputs=outputs,compared=len(outputs)>1))"""
  new="""   if binding['comparison']=='fixed-source':
    images=[preparations[r]['observation']['image'] for r in bend_roles]
    for key in ['source','driver','runtime','directRuntime','base']:
     assert len({x[key]['sha256'] for x in images})<=1,'Fixed-source comparison changed '+key
   equal=len({x['sha256'] for x in outputs})<=1
   report['exactBendOutputComparisons'].append(dict(case=case['id'],roles=bend_roles,outputs=outputs,textEqual=equal,required=False,oracle='Complete per-role prepared catalog value'))"""
  edit(old,new)
  edit('three more requests','the configured later requests')
  edit('and three more requests','and the configured later requests') if 'and three more requests' in text else None
  edit('three rounds do not fully balance four role positions','role count and rounds determine position balance')
  edit('three-role','candidate-role') if 'three-role' in text else None
  edit('report=dict(kind=',"report=dict(methodDerivation=identity(Path(__file__).with_name('derivation.json')),kind=")
 if parent.suffix=='.py':ast.parse(text)
 target=out/parent.name;outputs.append((target,text))
 derivations.append(dict(parent=before,output=dict(file=str(target),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
receipt=dict(kind='phase58-latency-method-derivation',producer=identity(__file__),setup=identity(HERE/'setup-v4.mjs'),
 scope='Same ordinary clocks/profile helper, new honest candidate bindings; between-image output text equality is observed, not required. Each role retains exact output checks and full prepared value oracle.',derivations=derivations)
out.mkdir(parents=True)
for target,text in outputs:target.write_text(text)
(out/'derivation.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps(dict(runner=identity(out/'run.py'),worker=identity(out/'worker.mjs'),derivation=identity(out/'derivation.json'))))
