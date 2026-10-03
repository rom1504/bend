#!/usr/bin/env python3
"""Static Nat→U32 refusal and retained scalar-island identity; no execution timing."""
import hashlib,json,pathlib,re,shutil,sys
assert len(sys.argv)==4,'usage: list-scalar-island-controls.py BASELINE_RAYTRACE CANDIDATE_RAYTRACE NEW_OUT'
a,b=map(lambda p:pathlib.Path(p).resolve(),sys.argv[1:3]);out=pathlib.Path(sys.argv[3]).resolve();assert not out.exists()
root=pathlib.Path(__file__).resolve().parents[4];fixture=root/'selfhost/tools/performance/phase37/fixtures-historical/raytrace.bend'
def identity(p):
 raw=p.read_bytes();return {'path':str(p),'sha256':hashlib.sha256(raw).hexdigest(),'bytes':len(raw)}
inputs=[identity(a),identity(b),identity(fixture)];out.mkdir(parents=True);consumed=out/'consumed-controls.py';shutil.copyfile(__file__,consumed);inputs.insert(0,identity(consumed))
report={'kind':'phase40-list-scalar-island-static-controls','complete':False,'pass':False,'inputs':inputs,'checks':[]}
try:
 source=fixture.read_text();old=a.read_text();new=b.read_text()
 assert old==new,'raytrace candidate must retain exact Phase39 bytes'
 report['checks'].append('entire-raytrace-module-byte-identical')
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
