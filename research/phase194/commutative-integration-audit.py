#!/usr/bin/env python3
"""Offline source transport audit; does not run compiler/target or modify maintained source."""
from pathlib import Path
import importlib.util,json
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('source',ROOT/'selfhost/tools/build/source.py')
s=importlib.util.module_from_spec(spec);spec.loader.exec_module(s)
def pin(p):return s.pin(ROOT/p)
def groups(path):return s.grouped(s.blocks((ROOT/path).read_bytes())[1])
manifest='selfhost/src/compiler.json';out=ROOT/'selfhost/build/phase194/selected-source02'
expected=json.loads((ROOT/'research/phase194/float-integration-audit.json').read_text())
profile_checks={}
for profile,old in expected['canonicalProfiles'].items():
 data=s.maintained_assemble(ROOT/manifest,ROOT/'selfhost',profile)
 after={'bytes':len(data),'sha256':s.digest(data)}
 assert after==old['after'],profile
 profile_checks[profile]={'previous':old['after'],'assembled':after,'byteIdentity':True}
roots=['p88_cache_prepare','p86_plan','p169np_plan','x181_prepared','x188_many','x188_render','x188_assemble']
audit_manifest=json.loads((ROOT/manifest).read_text());audit_manifest['profiles']['x86']['roots']=roots;audit_manifest['profiles']['x86']['omitMain']=True
mp=out/'seven-root-manifest.json';mp.write_text(json.dumps(audit_manifest,indent=2)+'\n')
closure=s.maintained_assemble(mp,ROOT/'selfhost','x86');cp=out/'seven-root-closure.bend';cp.write_bytes(closure)
checked='selfhost/build/phase194/commutative-api-source02/compiler.bend'
api_blocks=s.blocks((ROOT/checked).read_bytes())[1]
rows=[((0,b['kind'],b['name']),b['data'],None)for b in api_blocks]
selected=s.declaration_closure(rows,roots)
a=s.grouped([{'name':key[2],'data':data}for key,data,location in selected])
b=s.grouped(s.blocks(closure)[1])
assert a.keys()==b.keys(),(a.keys()-b.keys(),b.keys()-a.keys())
differences=[name for name in a if s.normalized(a[name])!=s.normalized(b[name])]
assert not differences,differences
module='selfhost/tests/phase194/commutative-select-v2.bend';hook='selfhost/tests/phase194/commutative-hook-v2.bend'
maintained='selfhost/src/back/x86/register-binary.bend';installed=groups(maintained)
checks=[]
for path in [module,hook]:
 for name,defs in groups(path).items():
  assert s.normalized(defs)==s.normalized(installed[name])==s.normalized(a[name]),name
  checks.append({'name':name,'normalizedSha256':s.digest(s.normalized(defs))})
report={'kind':'phase194-commutative-maintained-integration','complete':True,'targetExecuted':False,
 'scope':'Metadata assembly and normalized declaration transport only. Source acceptance and native qualification remain separate root-owned gates.',
 'nativeSelected':pin('selfhost/build/phase194/selected-source02/compiler.bend'),'maintainedModule':pin(maintained),
 'frozenInputs':[pin(module),pin(hook)],'manifest':pin(manifest),'manifestUnchanged':pin(manifest)==expected['manifest'],
 'checkedApiSource':pin(checked),'checkedApiReceipt':pin('selfhost/build/phase194/commutative-api01/report.json'),
 'sevenRoots':roots,'closure':s.pin(cp),'closureDeclarations':len(selected),'normalizedDifferences':differences,
 'commutativeDeclarations':checks,'canonicalProfiles':profile_checks}
assert report['manifestUnchanged']
(ROOT/'research/phase194/commutative-integration-audit.json').write_text(json.dumps(report,indent=2)+'\n')
argv=['python3','-B','selfhost/tests/phase194/job.py','--rss-mib','3072','selected-source-check02','120','48',
 str(ROOT/'selfhost/.assets/bin/bun'),'selfhost/tools/build/check-source.mjs','--source',
 'selfhost/build/phase194/selected-source02/compiler.bend','--out','selfhost/build/phase194/selected-source-check02']
(ROOT/'selfhost/build/phase194/selected-source-check02-argv.json').write_text(json.dumps(argv,indent=2)+'\n')
print(json.dumps({'nativeSelected':report['nativeSelected'],'closureDeclarations':len(selected),'normalizedDifferences':differences,'commutativeDeclarations':len(checks),'otherProfilesIdentical':len(profile_checks),'manifestUnchanged':report['manifestUnchanged']}))
