#!/usr/bin/env python3
"""Add a separately pinned and qualified HEAD TypeScript role to the frozen method."""
import argparse, ast, hashlib, json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT/'selfhost/build/phase66'
PARENT = RAW/'latency-method01'
PARENT_SHA = '644223f35890963307c407b7869f524e126ab6bcd9ad463894e0392249870d06'
HEAD_PIN = '059266225b77c8ca256ac6b25ee5c21449bab151'

def identity(file):
    file=Path(file).resolve(strict=True)
    return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('out',type=Path)
a=p.parse_args();out=a.out.resolve()
assert out.is_relative_to(RAW) and not out.exists()
parent=identity(PARENT/'derivation.json');assert parent['sha256']==PARENT_SHA
manifest=json.loads((PARENT/'derivation.json').read_text())
parents={Path(r['output']['file']).name:r['output'] for r in manifest['derivations']}
texts={};rows=[]
for name in ['profile.mjs','setup.mjs','worker.mjs','run.py']:
    before=identity(PARENT/name);assert before==parents[name]
    text=(PARENT/name).read_text();edits=[]
    def edit(old,new,count=1):
        global text
        assert text.count(old)==count,(name,old,text.count(old),count)
        text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
    count=text.count(str(PARENT))
    if count:edit(str(PARENT),str(out),count)
    if name=='worker.mjs':
        edit("let staged,D,B,C;", "let staged,D,B,C;\nconst typescriptRole=['typescript','typescript_head'].includes(request.role);\nconst typescriptRoot=request.role==='typescript_head'?config.headUpstream:config.upstream;")
        count=text.count("request.role==='typescript'")
        edit("request.role==='typescript'","typescriptRole",count)
        count=text.count("request.role!=='typescript'")
        edit("request.role!=='typescript'","!typescriptRole",count)
        edit("path.join(config.upstream,", "path.join(typescriptRoot,",3)
        edit("report.upstreamCommit=config.upstreamCommit", "report.upstreamCommit=request.role==='typescript_head'?config.headUpstreamCommit:config.upstreamCommit")
        edit("['kind','imageBindings','upstream','upstreamCommit','node']", "['kind','imageBindings','upstream','upstreamCommit','headUpstream','headUpstreamCommit','node']")
    if name=='run.py':
        edit("p.add_argument('--cases',default='all')", "p.add_argument('--head-upstream',type=Path,default=ROOT/'selfhost/.bootstrap/upstream-phase66')\np.add_argument('--head-oracles',type=Path,required=True)\np.add_argument('--cases',default='all')")
        edit("set(binding['roles'])|{'typescript'} and 'typescript' not in binding['roles']", "set(binding['roles'])|{'typescript','typescript_head'} and not ({'typescript','typescript_head'} & set(binding['roles']))")
        edit("policies={};oracle_inputs=[]", """head_upstream=a.head_upstream.resolve();head_pin='059266225b77c8ca256ac6b25ee5c21449bab151'
assert subprocess.check_output(['git','-C',str(head_upstream),'rev-parse','HEAD'],text=True).strip()==head_pin
subprocess.run(['git','-C',str(head_upstream),'diff','--exit-code','HEAD','--','bend2'],check=True,stdout=subprocess.DEVNULL)
head_id=identity(a.head_oracles);head=read(a.head_oracles)
assert head['kind']=='phase66-typescript-output-oracles' and head['complete'] and head['pass']
assert head['sourceCatalog']==identity(catalog) and head['upstreamCommit']==head_pin
verify(head['inputs']);verify(head['compilerInputs']);verify([head['semanticQualification']])
assert {x['file'] for x in head['compilerInputs']}=={str(head_upstream/'bend2'/n) for n in ['bend.ts','comp.ts','base.bend']}
head_qualification=read(head['semanticQualification']['file'])
assert head_qualification['complete'] and head_qualification['passed'] and len(head_qualification['cases'])==45
policies={};oracle_inputs=[head_id,*head['compilerInputs'],head['semanticQualification']]""")
        edit("for role in roles:\n spec=", """for role in roles:
 if role=='typescript_head':
  policies[role]={'kind':'upstream-qualified','manifest':head_id,'upstreamCommit':head_pin,'compilerInputs':head['compilerInputs']}
  for case in cases:
   entry=next(x for x in head['cases'] if x['id']==case['id'])
   assert entry['source']==case['source'] and entry['pointIds']==case['pointIds'] and entry['oracleValues']==case['oracles']
   assert entry['semanticQualification']=={'receipt':head['semanticQualification'],'pass':True}
   verify([entry['output']]);case.setdefault('candidateReferences',{})[role]=entry['output']
  continue
 spec=""")
        edit("upstream=str(upstream),upstreamCommit=PIN,cases=cases,inputs=inputs", "upstream=str(upstream),upstreamCommit=PIN,headUpstream=str(head_upstream),headUpstreamCommit=head_pin,cases=cases,inputs=inputs")
        edit("old['upstream']==str(upstream) and old['node']==identity(node)", "old['upstream']==str(upstream) and old['headUpstream']==str(head_upstream) and old['headUpstreamCommit']==head_pin and old['node']==identity(node)")
        ast.parse(text)
    texts[name]=text
    rows.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
out.mkdir(parents=True)
for name,text in texts.items():(out/name).write_text(text)
products=ROOT/'selfhost/build/phase65/latency-method02/derivation.json'
product_manifest=json.loads(products.read_text())
result=dict(kind='phase61-candidate-fast-loop-method',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,
    producer=identity(__file__),parentDerivation=parent,derivations=rows,
    explicitCacheAdmission=manifest['explicitCacheAdmission'],immutableAuditSnapshot=manifest['immutableAuditSnapshot'],
    optionalProductAdmission=product_manifest['optionalProductAdmission'],optionalProductParent=identity(products),
    scope='Add separately pinned HEAD TypeScript role with checked whole-library output and all45 original point oracles. '
          'Old TypeScript/old Bend target and oracles remain fixed. Every request remains fresh; unchanged clocks, guards, cache and product verification.')
(out/'derivation.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(method=identity(out/'derivation.json'))))
