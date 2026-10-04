#!/usr/bin/env python3
"""Frozen saved-JS resume ablation; no checked-source or compiler-output claim."""
import argparse,hashlib,json,pathlib,re,subprocess,sys
p=argparse.ArgumentParser();p.add_argument('--module',required=True);p.add_argument('--out',required=True);p.add_argument('--node',required=True);p.add_argument('--mode',choices=['both','prefix','projections'],default='both');a=p.parse_args();module=pathlib.Path(a.module).resolve();out=pathlib.Path(a.out).resolve();s=module.read_text();r=json.loads(pathlib.Path(str(module)+'.json').read_text())
assert r['complete'] and r['observation']['checked'] and r['observation']['status']=='ok';assert hashlib.sha256(s.encode()).hexdigest()==r['output']['sha256']
assert 'function stringHostGuard()' in s and 'if(needsString&&!stringHostGuard())return false;' in s
assert re.search(r'G\["gen"\]=scalarCapture\("gen",.*?,true\);',s), 'gen lacks String-family capture'
assert re.search(r'G\["bench"\]=scalarCapture\("bench",.*?,true\);',s) or 'localGuard($guards)' in s
names={'both':['ident','num','gen'],'prefix':['ident','num'],'projections':['gen']}[a.mode];changes=[]
def transform(text,diagnostic=False):
 lines=text.splitlines(True)
 for name in names:
  tag='$R'+''.join('_'+str(ord(c)) for c in name)+'$tree';indexes=[i for i,l in enumerate(lines) if l.startswith('function '+tag+'(')];assert len(indexes)==1
  at=indexes[0];line=lines[at];begin=line.index('if($frame.phase===2){')+len('if($frame.phase===2){');end=line.index('--$top;}else if($frame.phase===0)',begin);phase=line[begin:end];old=phase
  if name in ['ident','num']:
   pattern=r'\{const \$v0=(.+?);\{const (x\d+)=\$v0;(\$value=ctor\("SCon",\[\$frame.before\[0\],\$value,\]\);)\}\}'
   m=re.search(pattern,phase);assert m,name
   expr=m[1]
   if not diagnostic:
    assert not re.search(r'\b(?:call|callOwned|get|ctor|fields|project|force|new|Object|Array|G)\b',expr)
    assert not re.search(r'Math\.(?!imul\b)',expr)
   phase=phase[:m.start()]+'{'+m[3]+'}'+phase[m.end():]
  else:
   pattern=r'const \$nativeSCon0=project\("SCon",\$s0\);if\(true\)\{const \$nativeChr0=project\("Chr",\$nativeSCon0\[0\]\);const (x\d+)=\$nativeChr0\[0\];const (x\d+)=\$nativeSCon0\[1\];'
   m=re.search(pattern,phase);assert m,name
   suffix=phase[m.end():];assert not re.search(r'\b(?:'+m[1]+'|'+m[2]+r')\b',suffix),'projected values are live on resume'
   assert '$frame.before[0],$frame.before[1],$value' in suffix
   phase=phase[:m.start()]+'if(true){'+suffix
  assert phase!=old;lines[at]=line[:begin]+phase+line[end:]
  if not diagnostic:changes.append({'worker':name,'phase':2,'removed':old,'replacement':phase})
 return ''.join(lines)
clean=transform(s)
# Existing AST instrumentation runs on ACTUAL checked emission twice. Only its
# full diagnostic descendant is then changed; do not forge an emission receipt.
root=pathlib.Path(__file__).resolve().parents[5];instrument=root/'selfhost/tools/performance/phase43/strings/source-instrument-v5.mjs'
subprocess.run([a.node,str(instrument),str(module),str(module),str(out)],check=True)
full=out/'full.mjs';full.write_text(transform(full.read_text(),True));(out/'full.clean.mjs').write_text(clean)
# Fenced diagnostic calls exercise the changed worker with Unicode templates;
# they do not claim compiler-emitted ordinary Unicode root activation.
for role in ['original','full']:
 f=out/(role+'.mjs');text=f.read_text()
 extra='''\nexport function privateResumeGenerate(tpl,s,k){
 const names=sourceGuards()['root:bench'];
 if(regionProof!==null||!regionHostGuard()||typeof tpl!=='string'||!Number.isInteger(s)||s<0||s>4294967295||!Number.isInteger(k)||k<0||k>4294967295||!localGuard(names))return call(G.gen,[tpl,s,k]);
 const previous=regionProofOpen(names);try{return $R_103_101_110$tree(tpl,s,k);}finally{regionProofClose(previous);}
}\n'''
 f.write_text(text+extra)

m=json.loads((out/'derive.json').read_text())
for row in m['modules']:
 if row['counters'] or row['variant']=='full':row['sha256']=hashlib.sha256(pathlib.Path(row['path']).read_bytes()).hexdigest()
m['savedAblation']={'kind':'dead-phase2-total-U32-prefix-and-String-projections','mode':a.mode,'compilerEmittedCandidate':False,'checkedParentReceipt':str(module)+'.json','checkedParentSha256':r['output']['sha256'],'changes':changes,'scope':'Only admitted private ident/num/gen phase2; public G bindings/guards/constructors/order unchanged.'}
(out/'derive.json').write_text(json.dumps(m,indent=2)+'\n');(out/'original.clean.mjs').write_text(s)
m['cleanModules']={n:hashlib.sha256((out/n).read_bytes()).hexdigest() for n in ['original.clean.mjs','full.clean.mjs']}
(out/'derive.json').write_text(json.dumps(m,indent=2)+'\n')
print(json.dumps({'complete':True,'checkedParent':r['output']['sha256'],'changedWorkers':names,'candidate':hashlib.sha256(clean.encode()).hexdigest(),'instrumentedManifest':str(out/'derive.json')}))
