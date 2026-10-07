#!/usr/bin/env python3
"""Data-only candidate-aware successor of the frozen Phase60 request method."""
import argparse, ast, hashlib, json
from pathlib import Path

HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]
PARENT=ROOT/'selfhost/build/phase60/method03'; RAW=ROOT/'selfhost/build/phase61'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert RAW.is_dir() and out.is_relative_to(RAW.resolve()) and not out.exists()
def identity(file):
 file=Path(file).resolve(strict=True);b=file.read_bytes();return dict(file=str(file),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
pins={'setup.mjs':'2f80b30229c9d189e5e1765aa3c1085e91c6249a039953e20b401fc5be257399',
 'profile.mjs':'5df8aed83fdd2e573a3989ffa4d8ebf1e26d995b0dbabea9031d28e59ead5313',
 'worker.mjs':'a6234b8b7f1a00fc666b673451797fc9e30999366ce4dc28749f39ccf65b3bdb',
 'run.py':'4d013e0ae2692170f0f675665a8a2916a869e8eedf6c0fdc6956caa3d86f19ab'}
outputs={};derivations=[]
for name,sha in pins.items():
 before=identity(PARENT/name);assert before['sha256']==sha
 text=Path(before['file']).read_text();edits=[]
 def edit(old,new,count=1):
  global text
  assert text.count(old)==count,(name,old[:100],text.count(old),count)
  text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
 if name=='setup.mjs':
  edit('phase60','phase61',text.count('phase60'))
  edit("      assert.equal(d.complete,true);assert.equal(d.pass,true);assert.equal(typeof d.scope,'string');\n      assert.equal(pin(d.parent).sha256,parent.api.sha256);pin(d.producer);\n      return {...parent,kind:'syntax',api:pin(d.output),diagnosticDerivation:id,scope:d.scope};", """      assert.equal(d.complete,true);assert.equal(d.pass,true);assert.equal(typeof d.scope,'string');
      assert.equal(typeof spec.receiptKind,'string');assert.equal(d.kind,spec.receiptKind);
      assert.equal(d.diagnosticOnly,true);assert.equal(d.productionQualified,false);
      assert.equal(pin(d.parent).sha256,parent.api.sha256);pin(d.producer);
      const api=pin(d.output),runtime=pin(path.join(parent.attempt.snapshot.root,'src/runtime/js/direct.mjs'));
      assert.equal(pin(d.runtime).sha256,runtime.sha256);
      const prefix=fs.readFileSync(runtime.file,'utf8')+'\\n';
      for(const file of [parent.api.file,api.file])assert.ok(fs.readFileSync(file,'utf8').startsWith(prefix));
      return {...parent,kind:'syntax',api,diagnosticDerivation:id,scope:d.scope};""")
 elif name=='profile.mjs':
  edit('phase60','phase61',text.count('phase60'))
 elif name=='worker.mjs':
  edit((PARENT/'setup.mjs').as_uri(),(out/'setup.mjs').as_uri())
  edit((PARENT/'profile.mjs').as_uri(),(out/'profile.mjs').as_uri())
  edit('phase60','phase61',text.count('phase60'))
  edit("    report.oracleFreshness='inherited-qualified; fresh measured compilations must match complete raw bytes';", """    report.oracleFreshness='Retained catalog or separately qualified candidate raw bytes; no fresh runtime execution here';
    const policy=config.outputPolicies[request.role];assert.ok(policy);
    if(staged) {
      const image=staged.image;
      if(policy.kind==='catalog') {
        assert.equal(image.base.sha256,config.cases[0].files[1].sha256);
        assert.equal(image.directRuntime.sha256,config.cases[0].emissionInputs[2].sha256);
      } else {
        assert.equal(policy.kind,'qualified');
        for(const key of ['api','source','base','runtime','directRuntime','driver'])
          assert.equal(image[key].sha256,policy.image[key].sha256,key);
      }
    }""")
  edit("          catalog:config.catalog,pointIds:row.pointIds,points:row.oracles}});", "          catalog:config.catalog,pointIds:row.pointIds,points:row.oracles,outputPolicy:policy}});")
  edit("    assert.deepEqual(oldConfig.cases.find(x=>x.id===row.id),row);", "    const prior=oldConfig.cases.find(x=>x.id===row.id);\n    for(const key of ['id','source','files','emissionInputs','pointIds','oracles','catalogReferences'])assert.deepEqual(prior[key],row[key]);\n    assert.deepEqual(prior.references[request.role],row.references[request.role]);\n    assert.deepEqual(oldConfig.outputPolicies[request.role],config.outputPolicies[request.role]);")
 elif name=='run.py':
  edit(str(PARENT),str(out),text.count(str(PARENT)))
  edit("HERE=Path('/home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase60/latency')",'HERE=Path('+repr(str(HERE))+')')
  # Preserve the fixed Phase60 catalog and kind; only new output/method labels change.
  edit("default=HERE.parent/'catalog.json'", "default=HERE.parents[1]/'phase60/catalog.json'")
  edit("ROOT/'selfhost/build/phase60'", "ROOT/'selfhost/build/phase61'",text.count("ROOT/'selfhost/build/phase60'"))
  edit("'phase60-compiler-image-bindings'","'phase61-compiler-image-bindings'")
  edit("'phase60-candidate-image-library-latency'","'phase61-candidate-image-library-latency'",2)
  edit("'phase60-candidate-image-library-plan'","'phase61-candidate-image-library-plan'")
  edit('Phase60 report','Phase61 report')
  start=text.index("assert binding['comparison']=='fixed-source'");end=text.index('\nnames=a.cases',start)
  edit(text[start:end],"""assert binding['comparison'] in ['fixed-source','changed-source'] and binding['roles']
roles=a.roles.split(',');assert roles and len(set(roles))==len(roles) and all(x.isidentifier() for x in roles)
assert set(roles)<=set(binding['roles'])|{'typescript'} and 'typescript' not in binding['roles']
assert all(s['kind'] in ['checked','direct','syntax'] for s in binding['roles'].values())""")
  edit("p.add_argument('--roles',default='direct,typescript')","p.add_argument('--roles',default='baseline,candidate,typescript')")
  edit("p.add_argument('--bindings',type=Path,default=Path("+repr(str(out/'bindings.json'))+"))", "p.add_argument('--bindings',type=Path,required=True)")
  edit("p.add_argument('--driver-receipt',type=Path,help='Required only for stage mode; adjacent private instrumented driver')\n",'')
  edit("choices=['clean','cpu','allocation','stages']","choices=['clean','cpu','allocation']")
  start=text.index('stage_driver=None\n');end=text.index('reuse=None\n',start)
  edit(text[start:end],'')
  edit("str(Path("+repr(str(out/'worker-stages.mjs'))+") if a.mode=='stages' and request['stage']=='sample' else WORKER)","str(WORKER)")
  edit('stageDriver=identity(a.driver_receipt) if stage_driver else None,','outputPolicies=policies,')
  edit("assert identity("+repr(str(out/'profile.mjs'))+")[\'sha256\']=='5df8aed83fdd2e573a3989ffa4d8ebf1e26d995b0dbabea9031d28e59ead5313'", "assert identity("+repr(str(out/'profile.mjs'))+")[\'sha256\']=='PROFILE_HASH'")
  # Resolve output policies once, prior to private image preparation. Worker joins actual image hashes.
  marker="assert identity("+repr(str(out/'profile.mjs'))+")[\'sha256\']=='PROFILE_HASH'"
  edit(marker,"""policies={};oracle_inputs=[]
for role in roles:
 spec={'kind':'catalog','referenceRole':'typescript'} if role=='typescript' else binding.get('outputPolicies',{}).get(role,{'kind':'catalog','referenceRole':'direct'})
 if spec['kind']=='catalog':
  assert spec=={'kind':'catalog','referenceRole':'typescript' if role=='typescript' else 'direct'}
  policies[role]=spec
 else:
  assert role!='typescript' and spec['kind']=='qualified'
  verify([spec['manifest']]);q=read(spec['manifest']['file'])
  assert q['kind']=='phase61-qualified-compiler-output-oracles' and q['complete'] is True and q['pass'] is True
  assert q['catalog']==identity(catalog) and q['backend']=='direct'
  assert set(q['image'])=={'api','source','base','runtime','directRuntime','driver'}
  verify([*q['image'].values(),*q['inputs']]);oracle_inputs += [spec['manifest']]
  assert len({x['id'] for x in q['cases']})==len(q['cases'])
  policies[role]={'kind':'qualified','manifest':spec['manifest'],'image':q['image']}
  for case in cases:
   entry=next(x for x in q['cases'] if x['id']==case['id'])
   assert entry['source']==case['source'] and entry['pointIds']==case['pointIds']
   assert entry['oracleValues']==case['oracles'] and entry['semanticQualification']['pass'] is True
   verify([entry['output'],entry['semanticQualification']['receipt']])
   qualification=read(entry['semanticQualification']['receipt']['file'])
   assert qualification.get('complete') is True and (qualification.get('pass') is True or qualification.get('passed') is True)
   # Qualification adapter owns detailed runtime/observer proof; this method pins its reviewed packet.
   # The frozen packet binds historical qualification; samples rehash only their active raw reference.
   case.setdefault('candidateReferences',{})[role]=entry['output']
for case in cases:
 original=case['references'];case['catalogReferences']=original
 case['references']={role:(original[policies[role]['referenceRole']] if policies[role]['kind']=='catalog' else case['candidateReferences'][role]) for role in roles}
"""+marker)
  edit(" *[upstream/'bend2'/n for n in ['bend.ts','comp.ts','base.bend']]]]", " *[upstream/'bend2'/n for n in ['bend.ts','comp.ts','base.bend']]]]+oracle_inputs") if " *[upstream/'bend2'/n for n in ['bend.ts','comp.ts','base.bend']]]]" in text else None
  edit(" *[upstream/'bend2'/n for n in ['bend.ts','comp.ts','base.bend']]]", " *[upstream/'bend2'/n for n in ['bend.ts','comp.ts','base.bend']]]+oracle_inputs")
  # Subset preparation reuse can include additional image roles: compare active references only.
  edit(" for row in cases:assert row in old['cases']", """ for row in cases:
  previous=next(x for x in old['cases'] if x['id']==row['id'])
  for key in ['id','source','files','emissionInputs','pointIds','oracles','catalogReferences']:assert previous[key]==row[key]
  for role in roles:assert previous['references'][role]==row['references'][role] and old['outputPolicies'][role]==policies[role]""")
  edit("oracleFreshness='inherited-qualified'", "oracleFreshness='catalog or image-bound separately qualified outputs'")
  ast.parse(text)
 outputs[name]=text;derivations.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
# Resolve the new profile pin after its phase-confinement-only change.
profile_hash=hashlib.sha256(outputs['profile.mjs'].encode()).hexdigest()
outputs['run.py']=outputs['run.py'].replace('PROFILE_HASH',profile_hash)
derivations[-1]['edits'].append(dict(old='PROFILE_HASH',new=profile_hash,count=1))
derivations[-1]['output']['sha256']=hashlib.sha256(outputs['run.py'].encode()).hexdigest()
ast.parse(outputs['run.py'])
out.mkdir(parents=True)
for name,text in outputs.items():(out/name).write_text(text)
result=dict(kind='phase61-candidate-fast-loop-method',complete=True,dataOnly=True,targetExecuted=False,
 producer=identity(__file__),parentDerivation=identity(PARENT/'derivation.json'),derivations=derivations,
 scope='Phase60 first/later and one-first-request inspector windows retained. Candidate names/provenance/output policies generalized; no stage instrumentation or semantic qualification generated. All targets remain root-owned.')
result['pass']=True
(out/'derivation.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({n:identity(out/n) for n in [*outputs,'derivation.json']}))
