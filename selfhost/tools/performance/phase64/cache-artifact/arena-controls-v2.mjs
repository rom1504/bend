#!/usr/bin/env node
// Isolated production-helper controls. Root owns guarded target execution.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [baselineFile,candidateFile,frameFile,outputFile]=process.argv.slice(2).map(x=>path.resolve(x));
if(!outputFile)throw Error('Usage: arena-controls-v2.mjs BASELINE_HELPER CANDIDATE_HELPER FRAME3 OUTPUT.json');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const pin=file=>({file,sha256:sha(fs.readFileSync(file))});
const inputs=[baselineFile,candidateFile,frameFile,import.meta.filename,process.execPath].map(pin);
const old=await import(pathToFileURL(baselineFile)),api=await import(pathToFileURL(candidateFile));
const controls=[],check=(name,fn)=>{fn();controls.push({name,pass:true});};
const exact=(xs,ys)=>{
  assert.equal(xs.length,ys.length);const forward=new WeakMap(),reverse=new WeakMap(),stack=xs.map((x,i)=>[x,ys[i]]);
  while(stack.length){const [a,b]=stack.pop();if(a===null||typeof a!=='object'){assert.ok(Object.is(a,b));continue;}
    assert.ok(b!==null&&typeof b==='object');if(forward.has(a)){assert.equal(forward.get(a),b);continue;}
    assert.equal(reverse.has(b),false);forward.set(a,b);reverse.set(b,a);assert.deepEqual(Object.keys(a),Object.keys(b));
    for(const k of Object.keys(a))stack.push([a[k],b[k]]);
  }
};
const options={range:{begin:1,end:100},termAbi:1};
const decode=(bytes,kinds,extra={})=>api.decodeBaseArena(bytes,{...options,rootKinds:kinds,...extra});
const nil={$:'Nil'},list=(...values)=>values.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
const term=(name='x')=>({$:'KTerm',tag:'Ref',name,id:0,quant:0,kids:nil,removed:nil,originBegin:0,originEnd:0});
const t=term('__proto__\0\ud800\udc00\udfff');
const lit={$:'KLiteral',kind:'String',number:0,text:'\0A\u00e9\ud83d\ude42',originBegin:1,originEnd:2};
const lam={$:'KLambda',name:'constructor',id:0xffffffff,quant:0xffffffff,kids:list(t,lit),removed:list('prototype','\ud800'),originBegin:0,originEnd:0,quantityPresent:false};
const def={$:'KDef',name:'__proto__',kind:'Def',arity:0xffffffff,templates:0xffffffff,typ:t,value:lam,ctors:nil,native:true,unsafe:false};
const book=list(def),leaf={$:'KIndexLeaf',hash:0xffffffff,bucket:book},index={$:'KIndexNode',hash:0xffffffff,mask:0xffffffff,left:leaf,right:leaf};
const checked={$:'KBasePrefixState',bound:0xffffffff,delta:0xffffffff,stamp:0xffffffff,patches:book,ready:true};
const fresh={$:'FFreshPrefixState',next:0xffffffff,ready:true};
const world={$:'KBasePreparedWorld',state:checked,prefix:book,final:book,book,checked:book,seen:book,todos:0xffffffff,checkedBound:0xffffffff};
const frontend={$:'FReadyPrefixState',names:index,ctors:leaf,count:0xffffffff,ready:true};
const roots=[world,frontend,list(t,lit,lam),list('__proto__','constructor','prototype','\ud800'),def,fresh,null,nil],rootKinds=['world','frontend','terms','strings','def','fresh','term','empty'];
const encoded=api.encodeBaseArena(roots),json=old.encodeBaseGraph(roots),expected=old.decodeBaseGraph(json.bytes,{...options,rootKinds});
check('all constructors exact values and sharing',()=>exact(expected.roots,decode(encoded.bytes,rootKinds).roots));
check('JSON encoder bytes unchanged',()=>assert.deepEqual(api.encodeBaseGraph(roots).bytes,json.bytes));
check('unaligned input copied without semantic change',()=>{const b=Buffer.concat([Buffer.alloc(1),encoded.bytes]).subarray(1);assert.equal(b.byteOffset%4,1);exact(expected.roots,decode(b,rootKinds).roots);});
check('empty graph null roots',()=>assert.deepEqual(decode(api.encodeBaseArena([null]).bytes,['term']).roots,[null]));
check('null empty-kind root compatibility',()=>assert.deepEqual(decode(api.encodeBaseArena([null]).bytes,['empty']).roots,[null]));
check('empty exact Nil root compatibility',()=>assert.equal(decode(api.encodeBaseArena([nil]).bytes,['empty']).roots[0].$, 'Nil'));
check('empty kind rejects nonempty list',()=>assert.throws(()=>decode(api.encodeBaseArena([book]).bytes,['empty'])));
check('public object prototypes unchanged',()=>{const c=decode(encoded.bytes,rootKinds);assert.equal(Object.getPrototypeOf(c.roots[4]),Object.prototype);assert.equal(c.roots[4].name,'__proto__');assert.equal(Object.prototype.polluted,undefined);});
const align=x=>(x+3)&~3;
function layout(b){const n=b.readUInt32LE(8),nr=b.readUInt32LE(28),nf=b.readUInt32LE(20),ns=b.readUInt32LE(16),units=b.readUInt32LE(24),tags=32+nr*4,offsets=tags+align(n),fields=offsets+4*(n+1),strings=fields+4*nf,text=strings+4*(ns+1);return {n,nr,nf,ns,units,tags,offsets,fields,strings,text,end:text+2*units};}
function raw(b){const l=layout(b),word=at=>b.readUInt32LE(at),text=b.toString('utf16le',l.text,l.end);return {bn:word(4),bs:word(12),roots:Array.from({length:l.nr},(_,i)=>word(32+i*4)),records:Array.from({length:l.n},(_,i)=>[b[l.tags+i],...Array.from({length:word(l.offsets+(i+1)*4)-word(l.offsets+i*4)},(_,j)=>word(l.fields+(word(l.offsets+i*4)+j)*4))]),strings:Array.from({length:l.ns},(_,i)=>text.slice(word(l.strings+i*4),word(l.strings+(i+1)*4)))};}
// Test-only table reconstruction deliberately permits invalid records.
function pack(w){const nf=w.records.reduce((n,r)=>n+r.length-1,0),units=w.strings.reduce((n,s)=>n+s.length,0),n=w.records.length,nr=w.roots.length,ns=w.strings.length;
  const b=Buffer.alloc(align(32+4*nr+align(n)+4*(n+1)+4*nf+4*(ns+1)+2*units));let at=0;const word=x=>{b.writeUInt32LE(x,at);at+=4;};
  for(const x of [0x31494142,w.bn,n,w.bs,ns,nf,units,nr,...w.roots])word(x);for(const r of w.records)b[at++]=r[0];at=align(at);let offset=0;word(0);for(const r of w.records){offset+=r.length-1;word(offset);}for(const r of w.records)for(const x of r.slice(1))word(x);offset=0;word(0);for(const s of w.strings){offset+=s.length;word(offset);}for(const s of w.strings){b.write(s,at,'utf16le');at+=s.length*2;}return b;
}
const modify=fn=>{const b=Buffer.from(encoded.bytes);fn(b,layout(b));return b;};
const reject=(name,fn,kinds=rootKinds)=>check(name,()=>assert.throws(()=>decode(modify(fn),kinds)));
const rowField=(b,l,tag,field)=>{let i=0;while(i<l.n&&b[l.tags+i]!==tag)i++;assert.ok(i<l.n);return {node:i,at:l.fields+4*(b.readUInt32LE(l.offsets+i*4)+field)};};
for(const [name,at,value] of [['magic',0,0],['base node count',4,1],['base string count',12,1],['node cap',8,1048577],['string cap',16,1048577],['field cap',20,0xffffffff],['text extent',24,0xffffffff],['root count',28,9]])reject('reject '+name,b=>b.writeUInt32LE(value,at));
for(const n of [0,1,31])check('reject short header '+n,()=>assert.throws(()=>decode(encoded.bytes.subarray(0,n),rootKinds)));
check('reject truncated payload',()=>assert.throws(()=>decode(encoded.bytes.subarray(0,-1),rootKinds)));
check('reject trailing words',()=>assert.throws(()=>decode(Buffer.concat([encoded.bytes,Buffer.alloc(4)]),rootKinds)));
for(const range of [{begin:0,end:10},{begin:1,end:1},{begin:2,end:1},{begin:1,end:4294967296},{begin:'1',end:5}])check('reject range '+JSON.stringify(range),()=>assert.throws(()=>decode(encoded.bytes,rootKinds,{range})));
reject('reject initial record offset',(b,l)=>b.writeUInt32LE(1,l.offsets));
reject('reject final record offset',(b,l)=>b.writeUInt32LE(l.nf-1,l.offsets+l.n*4));
reject('reject descending record offset',(b,l)=>b.writeUInt32LE(l.nf,l.offsets+4));
reject('reject unknown constructor',(b,l)=>{b[l.tags]=255;});
reject('reject initial string offset',(b,l)=>b.writeUInt32LE(1,l.strings));
reject('reject final string offset',(b,l)=>b.writeUInt32LE(l.units-1,l.strings+l.ns*4));
reject('reject descending string offsets',(b,l)=>b.writeUInt32LE(l.units,l.strings+4));
reject('reject out of range string offset',(b,l)=>b.writeUInt32LE(l.units+1,l.strings+4));
reject('reject string dictionary index',(b,l)=>b.writeUInt32LE(0xffffffff,rowField(b,l,2,0).at));
reject('reject forward child reference',(b,l)=>b.writeUInt32LE(l.n,rowField(b,l,2,4).at));
reject('reject self child reference',(b,l)=>{const x=rowField(b,l,2,4);b.writeUInt32LE(x.node,x.at);});
reject('reject list subtype mismatch',(b,l)=>{const x=rowField(b,l,5,4);b.writeUInt32LE(0,x.at);});
reject('reject source endpoint',(b,l)=>b.writeUInt32LE(options.range.end,rowField(b,l,2,6).at));
for(const [tag,field] of [[3,7],[5,7],[5,8],[8,4],[9,1],[11,3]])reject('reject Boolean '+tag+'/'+field,(b,l)=>b.writeUInt32LE(2,rowField(b,l,tag,field).at));
check('reject term ABI downgrade',()=>assert.throws(()=>decode(encoded.bytes,rootKinds,{termAbi:0})));
check('reject unknown root kind',()=>assert.throws(()=>decode(encoded.bytes,['__proto__',...rootKinds.slice(1)])));
const padded=api.encodeBaseArena([list('x')]).bytes,pad=layout(padded);
check('reject nonzero constructor padding',()=>{const b=Buffer.from(padded);assert.ok(pad.tags+pad.n<pad.offsets);b[pad.tags+pad.n]=1;assert.throws(()=>decode(b,['strings']));});
check('reject nonzero text padding',()=>{const b=Buffer.from(padded);assert.ok(pad.end<b.length);b[pad.end]=1;assert.throws(()=>decode(b,['strings']));});
for(const text of ['', '\0','\u00e9','\ud83d\ude42','\udbff\udfff'])check('literal scalar exact '+JSON.stringify(text),()=>{const v={...lit,text},a=api.encodeBaseArena([v]);assert.equal(decode(a.bytes,['term']).roots[0].text,text);});
for(const text of ['\ud800','\udfff','a\ud800b','\udfff\ud800'])check('reject literal lone surrogate '+JSON.stringify(text),()=>assert.throws(()=>decode(api.encodeBaseArena([{...lit,text}]).bytes,['term'])));
for(const v of [{...lit,number:1},{...lit,kind:'Nat',text:'x'},{...lit,kind:'Other',text:''}])check('reject literal payload '+JSON.stringify(v),()=>assert.throws(()=>decode(api.encodeBaseArena([v]).bytes,['term'])));
for(const id of [-0,-1,0.5,4294967296,'0',{},null])check('writer refuses noncanonical U32 '+String(id)+' '+typeof id,()=>assert.throws(()=>api.encodeBaseArena([{...t,id}])));
for(const ids of [[0,-0],[-0,0]])check('writer refuses pre-intern negative zero order '+ids.map(v=>Object.is(v,-0)?'-0':'0').join(','),()=>assert.throws(()=>api.encodeBaseArena(ids.map(id=>({...t,id})))));
for(const v of [{...t,extra:0},Object.fromEntries(Object.entries(t).filter(([k])=>k!=='id')),{$:'Unknown'}])check('writer rejects shape '+Object.keys(v).join(','),()=>assert.throws(()=>api.encodeBaseArena([v])));
check('writer rejects cycle',()=>{const cycle={$:'Con',head:t};cycle.tail=cycle;assert.throws(()=>api.encodeBaseArena([cycle]));});
for(const size of [6,7,8])check('world historical field count '+size,()=>{const w=raw(encoded.bytes);w.records.find(r=>r[0]===10).length=size+1;const got=decode(pack(w),rootKinds).roots[0];assert.equal(Object.hasOwn(got,'todos'),size>=7);assert.equal(Object.hasOwn(got,'checkedBound'),size>=8);assert.equal(got.state.patches,got.prefix);});
for(const [name,append] of [['unknown constructor',w=>w.records.push([255])],['self reference',w=>w.records.push([1,w.records.length,w.records.length])],['invalid Boolean',w=>w.records.push([9,0,2])],['invalid literal scalar',w=>{const kind=w.strings.push('String')-1,text=w.strings.push('\ud800')-1;w.records.push([4,kind,0,text,0,0]);}]])check('unused record rejected '+name,()=>{const w=raw(encoded.bytes);append(w);assert.throws(()=>decode(pack(w),rootKinds));});
const actual=fs.readFileSync(frameFile),cut=actual.indexOf(10),header=JSON.parse(actual.subarray(0,cut));assert.equal(header.format,'bend-base-cache-frame-3');
const payload=actual.subarray(cut+1),bookBytes=payload.subarray(0,header.segments[0]),preparedBytes=payload.subarray(header.segments[0]);
assert.equal(sha(bookBytes),header.bookGraphSha256);assert.equal(sha(preparedBytes),header.preparedGraphSha256);
const actualOptions={range:{begin:header.sourceBegin,end:header.sourceEnd},termAbi:header.termAbi??0};
const originalBook=old.decodeBaseGraph(bookBytes,{...actualOptions,rootKinds:['defs']}),originalPrepared=old.decodeBaseGraph(preparedBytes,{...actualOptions,base:originalBook,rootKinds:['checked','fresh','world','frontend']});
const encodedBook=api.encodeBaseArena(originalBook.roots),encodedPrepared=api.encodeBaseArena(originalPrepared.roots,encodedBook);
const decodedBook=api.decodeBaseArena(encodedBook.bytes,{...actualOptions,rootKinds:['defs']}),decodedPrepared=api.decodeBaseArena(encodedPrepared.bytes,{...actualOptions,base:decodedBook,rootKinds:['checked','fresh','world','frontend']});
check('actual cache exact roots and sharing',()=>exact([...originalBook.roots,...originalPrepared.roots],[...decodedBook.roots,...decodedPrepared.roots]));
check('actual world roots remain coupled',()=>{assert.equal(decodedPrepared.roots[2].prefix,decodedBook.roots[0]);assert.equal(decodedPrepared.roots[2].state,decodedPrepared.roots[0]);});
check('actual JSON mandatory encoder unchanged',()=>assert.deepEqual(api.encodeBaseGraph(originalBook.roots).bytes,old.encodeBaseGraph(originalBook.roots).bytes));
check('actual JSON optional encoder unchanged',()=>{const a=api.encodeBaseGraph(originalBook.roots),b=old.encodeBaseGraph(originalBook.roots);assert.deepEqual(api.encodeBaseGraph(originalPrepared.roots,a).bytes,old.encodeBaseGraph(originalPrepared.roots,b).bytes);});
check('optional cannot use wrong mandatory base',()=>assert.throws(()=>api.decodeBaseArena(encodedPrepared.bytes,{...actualOptions,rootKinds:['checked','fresh','world','frontend']})));
check('unused optional malformed record rejected without mutating mandatory',()=>{const w=raw(encodedPrepared.bytes),before=decodedBook.nodes.length;w.records.push([255]);assert.throws(()=>api.decodeBaseArena(pack(w),{...actualOptions,base:decodedBook,rootKinds:['checked','fresh','world','frontend']}));assert.equal(decodedBook.nodes.length,before);exact(originalBook.roots,decodedBook.roots);});
for(const item of inputs)assert.equal(sha(fs.readFileSync(item.file)),item.sha256,'input changed: '+item.file);
const report={schema:'phase64-production-arena-controls-2',pass:true,controls,inputs,nodeVersion:process.version,actual:{frame3Bytes:actual.length,bookArenaBytes:encodedBook.bytes.length,preparedArenaBytes:encodedPrepared.bytes.length,worldVersion:header.preparedWorldVersion},limits:['No compiler execution or timing claim.','This tests codec schema/transport, not semantic truth of prepared facts or driver metadata admission.','All canonical input U32 values are representable; noncanonical negative zero is explicitly refused by the new writer.','Prototype inputs and earlier controls remain unchanged.']};
fs.mkdirSync(path.dirname(outputFile),{recursive:true});fs.writeFileSync(outputFile,JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({pass:true,controls:controls.length}));
