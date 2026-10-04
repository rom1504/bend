#!/usr/bin/env python3
"""Saved-output discriminator only: no compiler invocation or target execution."""
import argparse, re, json, hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('module',type=Path);p.add_argument('out',type=Path);p.add_argument('--root',required=True);a=p.parse_args()
s=a.module.read_text();defs={}
for line in s.splitlines():
 m=re.search(r'G\["([^"\n]+)"\]=',line)
 if m:defs[m[1]]=line
for m in re.finditer(r"native\('([^']+)'",s):
 if m[1] not in defs or defs[m[1]].startswith('if('):defs[m[1]]='native:'+m[1]
for ty in ['U32','Nat','F32']:
 for op in ['add','sub','mul','div','mod','is_eq','is_ne','is_lt','is_le','is_gt','is_ge','min','max','show','is_zero','read','cmp']:
  n=ty+'.'+op
  if n not in defs or defs[n].startswith('if('):defs[n]='native:'+n
assert a.root in defs and 'scalarCapture(' in defs[a.root] and 'fn(2,function(a)' in defs[a.root]
assert 'get(G,"Map.new")' in defs[a.root]
seen=set();todo=[a.root]
while todo:
 n=todo.pop()
 if n in seen:continue
 seen.add(n)
 for dep in re.findall(r'get\(G,"([^"\n]+)"\)',defs[n]):
  assert dep in defs,dep
  todo.append(dep)
deps=sorted(seen)
# This diagnostic refuses effectful/unanalysed roots, rather than trusting a label.
assert not any(re.search(r'get\(G,"(?:IO|Effect|Host|JS)\.',defs[n]) for n in seen)
worker=Path(__file__).with_name('worker.mjs').read_text().replace('__DEPENDENCIES__',json.dumps(deps))
original=s+"""
export const phase43MapDebug={complete:force,counts:()=>({entries:0,fallbacks:0,bits:0,operations:0}),proof:()=>regionProof!==null,
deep:n=>{let m=ctor('MLeaf',['b',1]);for(let i=0;i<n;i++)m=ctor('MNode',[0n,ctor('MLeaf',['a',i>>>0]),m]);const r=callOwned(callOwned(callOwned(get(G,'Map.seek'),[null,null]),[m]),['b']);m=callOwned(callOwned(callOwned(callOwned(get(G,'Map.put'),[null,null]),[r[0]]),['b']),[7]);const pop=callOwned(callOwned(callOwned(get(G,'Map.pop'),[null,null]),[m]),['b']);let depth=0,t=pop[0];while(t.$==='MNode'){depth++;t=t.a[2];}return {key:r[1][0],found:r[1][1],pop:pop[1],depth,tail:t};},
fixture:(rows,removals=[])=>{let m=callOwned(get(G,'Map.new'),[null,null]);for(const[k,v]of rows)m=callOwned(get(G,'Map.set'),[null,null,m,k,v]);const pops=[];for(const k of removals){const r=callOwned(callOwned(callOwned(get(G,'Map.pop'),[null,null]),[m]),[k]);m=r[0];pops.push(r[1]);}return {map:m,pops};}};
"""
roles={'original':original}
for role in ['amortized','whole']:
 t=s
 # Only exact saturated calls. Public G definitions/descriptors remain untouched.
 names=['Map.bit'] if role=='amortized' else ['Map.new','Map.set','Map.del','Map.bit']
 for name in names:
  needle='callOwned(get(G,"'+name+'"),[';at=0
  while True:
   i=t.find(needle,at)
   if i<0:break
   j=i+len(needle);depth=1;quote=None;escape=False;k=j
   while depth:
    c=t[k]
    if quote:
     if escape:escape=False
     elif c=='\\':escape=True
     elif c==quote:quote=None
    elif c in '\"\'`':quote=c
    elif c=='[':depth+=1
    elif c==']':depth-=1
    k+=1
   assert t[k]==')'
   arg=t[j:k-1]
   repl='$p43Call('+json.dumps(name)+',['+arg+'])'
   t=t[:i]+repl+t[k+1:];at=i+len(repl)
 # Wrap the complete scalar request: a closed fresh graph cannot escape between
 # operations. Arbitrary imported/public Map calls never open this boundary.
 line=next(x for x in t.splitlines() if x.startswith('G["'+a.root+'"]='))
 i=line.index('return ')+7;j=line.rfind(';}')
 line2=line[:i]+'$p43Scope(a,()=>'+line[i:j]+')'+line[j:]
 t=t.replace(line,line2)
 roles[role]=t+'\nconst $p43Whole='+str(role=='whole').lower()+';\n'+worker
out=a.out.resolve();assert not out.exists();out.mkdir()
sha=lambda b:hashlib.sha256(b).hexdigest()
for role,text in roles.items():(out/(role+'.mjs')).write_text(text)
report={'kind':'phase43-map-whole-discriminator','complete':True,'checked':False,'compilerAdmission':False,'root':a.root,'dependencies':deps,'producer':{'file':str(Path(__file__).resolve()),'sha256':sha(Path(__file__).read_bytes())},'input':{'file':str(a.module.resolve()),'sha256':sha(a.module.read_bytes())},'worker':{'file':str(Path(__file__).with_name('worker.mjs').resolve()),'sha256':sha(Path(__file__).with_name('worker.mjs').read_bytes())},'modules':{r:{'file':str(out/(r+'.mjs')),'sha256':sha((out/(r+'.mjs')).read_bytes())}for r in roles},'scope':'two UInt32 scalar root arguments; synchronous fresh nonescaping Map graph, ASCII <=64 keys; guarded transitive graph and native String hooks; no proof open'}
(out/'preparation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
