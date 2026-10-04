const $p43Names=__DEPENDENCIES__;
for(const n of $p43Names)scalarCapture(n,G[n]);
const $p43String=String,$p43StringProto=String.prototype;
const $p43Pairs=[[globalThis,'String'],[$p43String,'prototype'],[$p43String,'fromCodePoint'],[$p43StringProto,'codePointAt'],[$p43StringProto,'slice'],[$p43StringProto,'charCodeAt'],[$p43StringProto,'constructor']];
const $p43Descriptors=$p43Pairs.map(p=>regionGetDescriptor(p[0],p[1]));
const $p43StringNames=regionGetNames($p43StringProto),$p43StringAll=$p43StringNames.map(k=>regionGetDescriptor($p43StringProto,k));
let $p43Active=false,$p43Entries=0,$p43Fallbacks=0,$p43Bits=0,$p43Operations=0;
function $p43Guard(){
 if(regionProof!==null||!regionHostGuard()||!localGuard($p43Names)||regionGetPrototype($p43StringProto)!==scalarObjectPrototype)return false;
 const ns=regionGetNames($p43StringProto);if(ns.length!==$p43StringNames.length)return false;
 for(let i=0;i<ns.length;i++){if(ns[i]!==$p43StringNames[i])return false;const d=regionGetDescriptor($p43StringProto,ns[i]),o=$p43StringAll[i];for(const k of ['value','get','set','writable','enumerable','configurable'])if(d[k]!==o[k])return false;}
 for(let i=0;i<$p43Pairs.length;i++){const p=$p43Pairs[i],o=$p43Descriptors[i],d=regionGetDescriptor(p[0],p[1]);if(!o||!d||!regionOwn(o,'value')||!regionOwn(d,'value')||d.value!==o.value||d.writable!==o.writable||d.enumerable!==o.enumerable||d.configurable!==o.configurable)return false;}
 return true;
}
function $p43Scope(a,body){
 if($p43Active||!$p43Guard()||a.length!==2||!a.every(x=>typeof x==='number'&&Number.isInteger(x)&&x>=0&&x<=4294967295)){++$p43Fallbacks;return body();}
 ++$p43Entries;$p43Active=true;try{return body();}finally{$p43Active=false;}
}
function $p43ASCII(s){if(typeof s!=='string'||s.length>64)return false;for(let i=0;i<s.length;i++)if(s.charCodeAt(i)>127)return false;return true;}
function $p43Bit(key,pos){
 ++$p43Bits;const qr=callOwned(get(G,'Nat.divmod'),[pos,33n]);let q=qr[0],s=key,b=false,heads=[],top=0;
 while(s!==''){const ht=project('SCon',s),h=ht[0],tail=ht[1];if(q===0n){const v=callOwned(callOwned(get(G,'Map.bit.chr'),[h]),[qr[1]]);s=ctor('SCon',[v[0],tail]);b=v[1];break;}heads[top++]=h;s=tail;q-=1n;}
 while(top)s=ctor('SCon',[heads[--top],s]);return ctor('Tuple',[s,b]);
}
const $p43Tip=()=>ctor('MTip',[]),$p43Leaf=(k,v)=>ctor('MLeaf',[k,v]),$p43Node=(p,l,h)=>ctor('MNode',[p,l,h]);
function $p43Rebuild(frames,m,collapse=false){while(frames.length){const[p,other,right]=frames.pop();m=collapse&&m.$==='MTip'?other:right?$p43Node(p,other,m):$p43Node(p,m,other);}return m;}
const $p43Copy=m=>m.$==='MNode'?$p43Node(m.a[0],m.a[1],m.a[2]):m.$==='MLeaf'?$p43Leaf(m.a[0],m.a[1]):$p43Tip();
function $p43Seek(m,key){const frames=[];while(m.$==='MNode'){const p=m.a[0],l=$p43Copy(m.a[1]),h=$p43Copy(m.a[2]),kb=$p43Bit(key,p);key=kb[0];const right=kb[1];frames.push([p,right?l:h,right]);m=right?h:l;}
 const found=m.$==='MLeaf'?ctor('Some',[m.a[0]]):ctor('None',[]);m=m.$==='MLeaf'?$p43Leaf(m.a[0],m.a[1]):$p43Tip();return [$p43Rebuild(frames,m),[key,found]];}
function $p43Put(m,key,x){const frames=[];while(m.$==='MNode'){const p=m.a[0],l=$p43Copy(m.a[1]),h=$p43Copy(m.a[2]),kb=$p43Bit(key,p);key=kb[0];const right=kb[1];frames.push([p,right?l:h,right]);m=right?h:l;}return $p43Rebuild(frames,$p43Leaf(m.$==='MLeaf'?m.a[0]:key,x));}
function $p43Splice(m,key,x,p){const kb=$p43Bit(key,p),leaf=$p43Leaf(kb[0],x);return kb[1]?$p43Node(p,m,leaf):$p43Node(p,leaf,m);}
function $p43Ins(m,key,x,p){const frames=[];if(m.$==='MTip')return $p43Leaf(key,x);
 while(m.$==='MNode'){const q=m.a[0],l=$p43Copy(m.a[1]),h=$p43Copy(m.a[2]),kb=$p43Bit(key,q);key=kb[0];if(!(q<p))return $p43Rebuild(frames,$p43Splice($p43Node(q,l,h),key,x,p));const right=kb[1];frames.push([q,right?l:h,right]);m=right?h:l;if(m.$==='MTip')return $p43Rebuild(frames,$p43Leaf(key,x));}
 return $p43Rebuild(frames,$p43Splice($p43Leaf(m.a[0],m.a[1]),key,x,p));}
// Residual cmp/diff retain complete reconstructed strings and original numeric
// algorithm. Their removal is a separate String component discriminator.
function $p43Set(m,key,x){const r=$p43Seek(m,key);m=r[0];key=r[1][0];const found=r[1][1];if(found.$==='None')return $p43Leaf(key,x);
 const cmp=callOwned(callOwned(get(G,'String.cmp'),[key]),[found.a[0]]);return cmp[1].$==='EQ'?$p43Put(m,key,x):$p43Ins(m,key,x,callOwned(callOwned(get(G,'Map.diff'),[cmp[0][0]]),[cmp[0][1]]));}
function $p43Pop(m,key){const frames=[];while(m.$==='MNode'){const p=m.a[0],l=$p43Copy(m.a[1]),h=$p43Copy(m.a[2]),kb=$p43Bit(key,p);key=kb[0];const right=kb[1];frames.push([p,right?l:h,right]);m=right?h:l;}
 let found=ctor('None',[]);if(m.$==='MLeaf'){const cmp=callOwned(callOwned(get(G,'String.cmp'),[key]),[m.a[0]]);if(cmp[1].$==='EQ'){found=ctor('Some',[m.a[1]]);m=$p43Tip();}else m=$p43Leaf(cmp[0][1],m.a[1]);}else m=$p43Tip();return [$p43Rebuild(frames,m,true),found];}
function $p43Call(name,a){
 if(!$p43Active)return callOwned(get(G,name),a);
 if(name==='Map.bit')return $p43ASCII(a[0])&&typeof a[1]==='bigint'&&a[1]>=0n?$p43Bit(a[0],a[1]):callOwned(get(G,name),a);
 if(name==='Map.new'){++$p43Operations;return $p43Tip();}
 if(!$p43ASCII(a[3]))return callOwned(get(G,name),a);
 ++$p43Operations;return name==='Map.set'?$p43Set(a[2],a[3],a[4]):$p43Pop(a[2],a[3])[0];
}
export const phase43MapDebug={complete:force,counts:()=>({entries:$p43Entries,fallbacks:$p43Fallbacks,bits:$p43Bits,operations:$p43Operations}),proof:()=>regionProof!==null,guard:$p43Guard,
 deep:n=>{if(!$p43Guard()||!Number.isInteger(n)||n<0||n>20000)throw Error('refused deep');$p43Active=true;try{let m=$p43Leaf('b',1);for(let i=0;i<n;i++)m=$p43Node(0n,$p43Leaf('a',i>>>0),m);const r=$p43Whole?$p43Seek(m,'b'):callOwned(callOwned(callOwned(get(G,'Map.seek'),[null,null]),[m]),['b']);m=$p43Whole?$p43Put(r[0],'b',7):callOwned(callOwned(callOwned(callOwned(get(G,'Map.put'),[null,null]),[r[0]]),['b']),[7]);const pop=$p43Whole?$p43Pop(m,'b'):callOwned(callOwned(callOwned(get(G,'Map.pop'),[null,null]),[m]),['b']);let depth=0,t=pop[0];while(t.$==='MNode'){depth++;t=t.a[2];}return {key:r[1][0],found:r[1][1],pop:pop[1],depth,tail:t};}finally{$p43Active=false;}},
 fixture:(rows,removals=[])=>{if(!$p43Guard()||!rows.every(r=>$p43ASCII(r[0])&&typeof r[1]==='number'&&Number.isInteger(r[1])&&r[1]>=0&&r[1]<=4294967295)||!removals.every($p43ASCII))throw Error('refused fixture');++$p43Entries;$p43Active=true;try{let m=$p43Tip();for(const[k,v]of rows)m=$p43Whole?$p43Set(m,k,v):callOwned(get(G,'Map.set'),[null,null,m,k,v]);const pops=[];for(const k of removals){const r=$p43Whole?$p43Pop(m,k):callOwned(callOwned(callOwned(get(G,'Map.pop'),[null,null]),[m]),[k]);m=r[0];pops.push(r[1]);}return {map:m,pops};}finally{$p43Active=false;}}};
