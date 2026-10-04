#!/usr/bin/env python3
"""Frozen saved-output one acyclic wrapper-hop ablation; not compiler emission."""
import argparse,hashlib,json,pathlib,re,subprocess
p=argparse.ArgumentParser();p.add_argument('--module',required=True);p.add_argument('--out',required=True);p.add_argument('--node',required=True);a=p.parse_args();module=pathlib.Path(a.module).resolve();out=pathlib.Path(a.out).resolve();s=module.read_text();r=json.loads(pathlib.Path(str(module)+'.json').read_text())
assert r['complete'] and r['observation']['checked'] and r['observation']['status']=='ok';assert hashlib.sha256(s.encode()).hexdigest()==r['output']['sha256']
source=pathlib.Path(r['input'].get('canonicalPath',r['input']['file']));assert hashlib.sha256(source.read_bytes()).hexdigest()==r['input']['sha256']
assert 'def gen.at(+c: U32, t: U32, rest: String) -> String:\n  expand(slot(c), c, t, rest)' in source.read_text(), 'unreviewed typed wrapper source'
assert 'function stringHostGuard()' in s and 'if(needsString&&!stringHostGuard())return false;' in s
assert re.search(r'G\["gen.at"\]=scalarCapture\("gen.at",.*?,true\);',s)
deps=['gen.at','ident','prng','num','op.pick','op','expand','slot.go','slot']
for name in deps:assert '"'+name+'"' in s
worker='$R_103_101_110$tree';needle='callOwned(get(G,"gen.at"),[$frame.before[0],$frame.before[1],$value,])'
replacement='(regionProof!==null&&regionProofCovers($p43GenAtDeps)?$p43GenAt($frame.before[0],$frame.before[1],$value):'+needle+')'
def transform(text):
 assert 'function $p43GenAt(' not in text
 line=next(l for l in text.splitlines() if l.startswith('G["gen.at"]='))
 m=re.fullmatch(r'G\["gen\.at"\]=scalarCapture\("gen\.at",fn\(3,function\(a\)\)\{(.*)\}\),true\);',line)
 # Generated syntax is function(a){...}, not an arrow.
 if not m:m=re.fullmatch(r'G\["gen\.at"\]=scalarCapture\("gen\.at",fn\(3,function\(a\)\{(.*)\}\),true\);',line)
 assert m,'unreviewed exact generated wrapper shape';body=m[1]
 assert set(re.findall(r'get\(G,"([^"]+)"\)',body))=={'slot','expand'}
 for i in range(3):assert body.count('a['+str(i)+']')==1;body=body.replace('a['+str(i)+']','$p'+str(i))
 assert 'a[' not in body
 lines=text.splitlines(True);i=next(i for i,l in enumerate(lines) if l.startswith('function '+worker+'('));line=lines[i];begin=line.index('if($frame.phase===2){');end=line.index('--$top;}else if($frame.phase===0)',begin);phase=line[begin:end];assert phase.count(needle)==1
 lines[i]=line[:begin]+phase.replace(needle,replacement)+line[end:]
 return ''.join(lines)+'\nconst $p43GenAtDeps='+json.dumps(deps,separators=(',',':'))+';\nfunction $p43GenAt($p0,$p1,$p2){/* private saved acyclic wrapper */'+body+'}\n'
clean=transform(s)
root=pathlib.Path(__file__).resolve().parents[5];instrument=root/'selfhost/tools/performance/phase43/strings/source-instrument-v5.mjs';subprocess.run([a.node,str(instrument),str(module),str(module),str(out)],check=True)
full=out/'full.mjs';full.write_text(transform(full.read_text()));(out/'original.clean.mjs').write_text(s);(out/'full.clean.mjs').write_text(clean)
# Paired fenced Unicode helpers; source String graph/ABI/dependency guard stays live.
extra='''\nexport function privateResumeGenerate(tpl,s,k){const names=sourceGuards()['root:bench'];if(regionProof!==null||!regionHostGuard()||typeof tpl!=='string'||!Number.isInteger(s)||s<0||s>4294967295||!Number.isInteger(k)||k<0||k>4294967295||!localGuard(names))return call(G.gen,[tpl,s,k]);const previous=regionProofOpen(names);try{return $R_103_101_110$tree(tpl,s,k);}finally{regionProofClose(previous);}}\n'''
for role in ['original','full']:
 f=out/(role+'.mjs');f.write_text(f.read_text()+extra)
m=json.loads((out/'derive.json').read_text())
for row in m['modules']:row['sha256']=hashlib.sha256(pathlib.Path(row['path']).read_bytes()).hexdigest()
m['savedAblation']={'kind':'one-acyclic-wrapper-hop','compilerEmittedCandidate':False,'checkedParentReceipt':str(module)+'.json','checkedParentSha256':r['output']['sha256'],'typedWrapperSource':str(source),'deps':deps,'scope':'gen phase2 only; original public wrapper untouched; full dependency proof conditional with identical generic fallback arguments.'}
m['cleanModules']={n:hashlib.sha256((out/n).read_bytes()).hexdigest() for n in ['original.clean.mjs','full.clean.mjs']};(out/'derive.json').write_text(json.dumps(m,indent=2)+'\n')
print(json.dumps({'complete':True,'candidate':hashlib.sha256(clean.encode()).hexdigest(),'dependencies':deps,'scope':'saved ablation, not checked compiler output'}))
