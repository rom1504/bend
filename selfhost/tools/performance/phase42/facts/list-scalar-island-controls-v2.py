#!/usr/bin/env python3
"""V2 exact protected scalar-island identity; module-wide differences explicit."""
import hashlib,json,pathlib,re,shutil,sys
assert len(sys.argv)==4,'usage: list-scalar-island-controls.py BASELINE_RAYTRACE CANDIDATE_RAYTRACE NEW_OUT'
a,b=map(lambda p:pathlib.Path(p).resolve(),sys.argv[1:3]);out=pathlib.Path(sys.argv[3]).resolve();assert not out.exists()
root=pathlib.Path(__file__).resolve().parents[5];fixture=root/'selfhost/tools/performance/phase37/fixtures-historical/raytrace.bend'
def identity(p):
 raw=p.read_bytes();return {'path':str(p),'sha256':hashlib.sha256(raw).hexdigest(),'bytes':len(raw)}
parent=root/'selfhost/tools/performance/phase40/list-scalar-island-controls.py'
assert identity(parent)['sha256']=='06c0e0d1da2533aa82b8fa2ade0084cec1b4d685c494e41a242c29758255034b','changed retained parent controller'
inputs=[identity(a),identity(b),identity(fixture),identity(parent)];out.mkdir(parents=True);consumed=out/'consumed-controls.py';shutil.copyfile(__file__,consumed);inputs.insert(0,identity(consumed))
report={'kind':'phase42-list-scalar-island-static-controls-v2','complete':False,'pass':False,'inputs':inputs,'checks':[]}
try:
 source=fixture.read_text();old=a.read_text();new=b.read_text()
 assert identity(b)['sha256']=='18f02cc4df92dc2bcf5da421ce7c5cc719ad922c984292e0573961c31f2f4af0','successor bound to actual checked16 emission'
 def sections(text):
  rows=re.findall(r'^G\["([^"\n]+)"\]=[^\n]*',text,re.M)
  names=[x for x in rows];assert len(names)==len(set(names))
  return {name:re.search(r'^G\['+re.escape(json.dumps(name))+r'\]=[^\n]*',text,re.M).group(0) for name in names}
 oldSections,newSections=sections(old),sections(new)
 assert oldSections.keys()==newSections.keys(),'source public sections changed'
 protected=['colf','rowf','colf.px','colf.px.go','subray']
 for name in protected:assert oldSections[name]==newSections[name],'protected scalar region changed '+name
 changed=[name for name in oldSections if oldSections[name]!=newSections[name]]
 expected=['sphere','isect.t','isect.go2','isect.go','isect5','sx','sy','sz','sr','skr','nearest','clamp01.go','clamp01','nearest.t','trace','pixel']
 assert changed==expected,'unexpected difference scope'
 normalized=new
 runtimeEdits=[("let scalarNatAddSnapshot=null;\n",''),("const s=name==='Nat.add'?scalarNatAddSnapshot:scalarSnapshots[name],g=Object.getOwnPropertyDescriptor(G,name);","const s=scalarSnapshots[name],g=Object.getOwnPropertyDescriptor(G,name);"),("  // The factory owns these fresh fields; snapshot without calling host hooks.\n  if(name==='Nat.add')scalarNatAddSnapshot={original:value,arity:n,code:value.code,bound:value.bound};\n",'')]
 for current,original in runtimeEdits:
  assert normalized.count(current)==1,'runtime edit occurrence changed'
  normalized=normalized.replace(current,original)
 for name in changed:
  assert normalized.count(newSections[name])==1
  assert '/* private acyclic helper */' in newSections[name],'changed generic section lacks guarded helper '+name
  normalized=normalized.replace(newSections[name],oldSections[name])
 assert normalized==old,'difference outside exact runtime and recorded public sections'
 report['moduleByteIdentical']=old==new
 report['protectedRegions']=[{'name':name,'bytes':len(oldSections[name].encode()),'sha256':hashlib.sha256(oldSections[name].encode()).hexdigest(),'byteIdentical':True} for name in protected]
 report['outsideChanges']={'runtime':'exact inert Nat.add metadata3hunks','publicSections':[{'name':name,'baselineSha256':hashlib.sha256(oldSections[name].encode()).hexdigest(),'candidateSha256':hashlib.sha256(newSections[name].encode()).hexdigest()} for name in changed],'normalizedOutsideRegionsByteIdentical':True,'runtimeAndGenericOutsideChangesAreNotProtectedIdentityClaims':True}
 report['checks'].append('protected-scalar-island-regions-byte-identical')
 for owner in ['colf','rowf']:
  assert re.search(r'def '+owner+r'\(\+d: Nat,[\s\S]*?\) -> U32:',source),'fixture domain '+owner
  encoded='$R_'+'_'.join(str(ord(c)) for c in owner)+'$tree'
  assert 'function '+encoded+'(' not in new,'new Nat-scalar structural worker '+owner
  start=new.index('G['+json.dumps(owner)+']=');end=new.index('\nG[',start+1);section=new[start:end]
  assert '/* private scalar tree */' in section,owner+' scalar island absent'
  guards=re.search(r'const \$guards=(\[[^;]+\]);',section);assert guards,owner+' guards absent'
  names=json.loads(guards.group(1));assert owner in names
  for dependency in ['colf.px','colf.px.go','pixel','subray','trace']:
   assert dependency in names,owner+' missing guard '+dependency
  for phrase in ['exactCode(function(a,$entered)','if($entered&&regionHostGuard()','localGuard($guards)','regionProofOpen($guards)','finally{regionProofClose($previousProof);}']:
   assert phrase in section,owner+' missing authorization '+phrase
  if owner=='colf':assert '$value=$R_99_111_108_102_46_112_120(' in section,'private scalar leaf helper absent'
  report['checks'].append({'owner':owner,'natToScalarRefused':True,'retainedScalarIsland':True,'guards':names})
 assert '/* private scalar root */' not in new,'new raytrace root bypasses scalar-island entry'
 for row in inputs:assert identity(pathlib.Path(row['path']))==row
 report['complete']=True;report['pass']=True
except Exception as e:
 report['error']=str(e);raise
finally:
 (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'pass':report['pass'],'checks':len(report['checks']),'report':str(out/'report.json')}))
