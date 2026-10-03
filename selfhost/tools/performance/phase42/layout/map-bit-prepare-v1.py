#!/usr/bin/env python3
"""Prepare a saved-JS ASCII Map.bit structural ablation; run no target/compiler."""
import argparse,re,json,hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('module',type=Path);p.add_argument('out',type=Path);a=p.parse_args();source=a.module.read_text();out=a.out.resolve();assert not out.exists()
sha=lambda b:hashlib.sha256(b).hexdigest()
defs={m[1]:m[0] for m in re.finditer(r'^G\["([^"\n]+)"\]=.*$',source,re.M)}
names=['Map.bit','Map.bit.at','Map.bit.go','Map.bit.go.chr','Map.bit.go.rec','Map.bit.chr','Map.bit.u','Nat.divmod','Nat.sub']
for n in names[:7]:assert n in defs,n
pattern=re.compile(r'callOwned\(get\(G,"Map\.bit"\),\[(x\d+),(x\d+),\]\)');lines=[];sites=[]
for line in source.splitlines(True):
 if line.startswith('G["Map.'):
  count=len(pattern.findall(line))
  if count:sites.append({'definition':line.split('"')[1],'sites':count});line=pattern.sub(r'$p42MapBit(\1,\2)',line)
 lines.append(line)
assert sum(x['sites'] for x in sites)==29
common=r'''
export const phase42MapBitDebug={complete:x=>force(x),bit:(key,pos)=>callOwned(get(G,'Map.bit'),[key,pos]),counts:()=>({entries:0,fallbacks:0}),proof:()=>regionProof!==null};
'''
worker=r'''
// Exact original operations retained; no proof is opened around String observers.
const $p42BitNames=['Map.bit','Map.bit.at','Map.bit.go','Map.bit.go.chr','Map.bit.go.rec','Map.bit.chr','Map.bit.u','Nat.divmod','Nat.sub'];
for(const n of $p42BitNames)scalarCapture(n,G[n]);
const $p42BitStringCtor=String,$p42BitStringPrototype=String.prototype;
const $p42BitHooks=[[globalThis,'String'],[$p42BitStringCtor,'prototype'],[$p42BitStringCtor,'fromCodePoint'],[$p42BitStringPrototype,'codePointAt'],[$p42BitStringPrototype,'slice'],[$p42BitStringPrototype,'charCodeAt'],[$p42BitStringPrototype,'constructor']];
const $p42BitDescriptors=$p42BitHooks.map(p=>regionGetDescriptor(p[0],p[1]));
let $p42BitEntries=0,$p42BitFallbacks=0;
function $p42BitGuard(){
 if(regionProof!==null||!regionHostGuard()||!localGuard($p42BitNames))return false;
 for(let i=0;i<$p42BitHooks.length;i++){const p=$p42BitHooks[i],old=$p42BitDescriptors[i],d=regionGetDescriptor(p[0],p[1]);if(!old||!d||!regionOwn(old,'value')||!regionOwn(d,'value')||d.value!==old.value||d.writable!==old.writable||d.enumerable!==old.enumerable||d.configurable!==old.configurable)return false;}
 return true;
}
function $p42MapBit(key,pos){
 if(!$p42BitGuard()||typeof key!=='string'||typeof pos!=='bigint'||pos<0n||pos>4294967295n||key.length>64){++$p42BitFallbacks;return callOwned(get(G,'Map.bit'),[key,pos]);}
 for(let i=0;i<key.length;i++)if(key.charCodeAt(i)>127){++$p42BitFallbacks;return callOwned(get(G,'Map.bit'),[key,pos]);}
 ++$p42BitEntries;
 const qr=callOwned(get(G,'Nat.divmod'),[pos,33n]);let q=qr[0],s=key,bit=false,heads=[],top=0;
 // Source Map.bit.go descends first and reconstructs inner-to-outer. Preserve
 // project(SCon)'s two codePointAt reads+slice and every ctor(SCon) rebuild.
 while(s!==''){
  const ht=project('SCon',s),h=ht[0],tail=ht[1];
  if(q===0n){const target=callOwned(callOwned(get(G,'Map.bit.chr'),[h]),[qr[1]]);s=ctor('SCon',[target[0],tail]);bit=target[1];break;}
  heads[top++]=h;s=tail;q-=1n;
 }
 while(top)s=ctor('SCon',[heads[--top],s]);
 return ctor('Tuple',[s,bit]);
}
export const phase42MapBitDebug={complete:x=>force(x),bit:(key,pos)=>$p42MapBit(key,pos),counts:()=>({entries:$p42BitEntries,fallbacks:$p42BitFallbacks}),proof:()=>regionProof!==null,guard:$p42BitGuard};
'''
out.mkdir();roles={'original':source+common,'candidate':''.join(lines)+worker}
for role,text in roles.items():(out/(role+'.mjs')).write_text(text)
report={'kind':'phase42-map-bit-structural-ablation','complete':True,'checked':False,'compilerAdmission':False,'producer':{'file':str(Path(__file__).resolve()),'sha256':sha(Path(__file__).read_bytes())},'input':{'file':str(a.module.resolve()),'sha256':sha(a.module.read_bytes())},'sites':sites,'dependencies':names,'modules':{role:{'file':str(out/(role+'.mjs')),'sha256':sha((out/(role+'.mjs')).read_bytes())} for role in roles},'scope':'ASCII keys <=64 UTF16 units and canonical bounded Nat positions; explicit source prefix frames; original project/ctor observations and scalar target/divmod calls retained. No String-native comparison, Map representation, public G descriptor or algorithm replacement. All other inputs and changed postinitialization hooks/dependencies take exact generic call.'}
(out/'preparation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
