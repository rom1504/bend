// Actual parsed negative fixtures and independent stale-state challenges.
// No host-side compilation or cache producer exists in this test observer.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import assert from 'node:assert/strict';import{pathToFileURL}from'node:url';
const[apiFile,outArg]=process.argv.slice(2),root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase140/'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p),receipt=JSON.parse(fs.readFileSync(apiFile));assert(receipt.complete&&receipt.checked);
const source=receipt.inputs.find(x=>x.file.endsWith('/compiler.bend')),manifestFile=path.join(path.dirname(source.file),'manifest.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
const inputs=[pin(import.meta.filename),pin(apiFile),receipt.api,...receipt.inputs,pin(manifestFile),...manifest.inputs,pin(process.execPath)];inputs.forEach(verify);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={complete:false,source,api:receipt.api,inputs,rows:[],scope:'Actual parsed controls plus explicitly labeled malformed data/forged-state test challenges. Trusted checkpoint provenance remains required.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
function equal(a,b){const todo=[[a,b]],seen=new WeakMap();let objects=0;while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y))continue;if(!x||!y||typeof x!=='object'||typeof y!=='object'){assert.deepEqual(x,y);continue}let q=seen.get(x);if(q?.has(y))continue;if(!q){q=new WeakSet();seen.set(x,q)}q.add(y);objects++;const k=Object.keys(x).sort();assert.deepEqual(k,Object.keys(y).sort());for(const n of k)todo.push([x[n],y[n]])}return{objects}}
const arr=xs=>{const a=[];while(xs.$==='Con'){a.push(xs.head);xs=xs.tail}assert.equal(xs.$,'Nil');return a};
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
try{
 const api=(await import(pathToFileURL(receipt.api.file))).default,epoch='fixed:'+source.sha256;
 const parse=(name,text)=>{const file=path.join(out,name+'.bend');fs.writeFileSync(file,text,{flag:'wx'});const r=api.p140cc_parse(text);assert.equal(r.error,'',name);return{book:r.book,source:pin(file)}};
 const head='type Bit is Data:\n  Off{}\n  Onn{}\ndef keep() -> Bit:\n  Off{}\n';
 const base=parse('ordinary',head+'def edit() -> Bit:\n  Off{}\n'),seed=api.p140cp_seed(epoch,base.book,2),cache=api.p140cp_saved(seed);
 const check=(name,book,c=cache,hit=false)=>{const row={name,expectedHit:hit};report.rows.push(row);const fresh=api.dg_check_world(book),got=api.p140cp_replay(epoch,book,c);row.actualHit=got.reused;row.reason=got.reason;assert.equal(got.reused,hit);row.fullState=equal(got.checked,fresh);row.complete=true;save();return row};
 // The maximum remains unchanged while an intermediate header ID moves.
 const ba='  x = Off{}\n  x\n',bb='  Off{}'+ ' '.repeat(ba.length-8)+'\n';assert.equal(ba.length,bb.length);
 const sa=parse('balanced-A',head+'def edit() -> Bit:\n'+ba+'def mid(x: Bit) -> Bit:\n  x\ndef tail() -> Bit:\n  Off{}\n');
 const sb=parse('balanced-B',head+'def edit() -> Bit:\n'+bb+'def mid(x: Bit) -> Bit:\n  x\ndef tail() -> Bit:\n  x = Off{}\n  x\n');
 const boundA=api.norm_max_book(sa.book),boundB=api.norm_max_book(sb.book);assert.equal(boundA,boundB);
 const balanced=api.p140cp_saved(api.p140cp_seed(epoch,sa.book,2));
 const row=check('balanced-binders-same-bound',sb.book,balanced);row.bounds=[boundA,boundB];row.sources=[sa.source,sb.source];assert.equal(row.reason,'ordered declaration view');
 // A later law fill is observed by a prefix signature event.
 const lawA=parse('law-A','type Bit is Data:\n  Off{}\n  Onn{}\nlaw pick : Bit\ndef pick():\n  Off{}\n');
 const lawB=parse('law-B','type Bit is Data:\n  Off{}\n  Onn{}\nlaw pick : Bit\n@unsafe\ndef pick():\n  Off{}\n');
 const lawCache=api.p140cp_saved(api.p140cp_seed(epoch,lawA.book,2));assert.equal(lawCache.$,'P140CPSaved');
 check('later-law-fill-unsafe-mode',lawB.book,lawCache);
 // Raw candidate event mutations exercise all retained header fields. These
 // are data-level admission checks, not frontend acceptance claims.
 const events=arr(base.book),last=events.at(-1),clone=structuredClone;
 for(const[name,change]of[
  ['native-flag',d=>({...d,native:!d.native})],['unsafe-flag',d=>({...d,unsafe:!d.unsafe})],
  ['arity',d=>({...d,arity:d.arity+1})],['templates',d=>({...d,templates:d.templates+1})],
  ['type-quantity',d=>({...d,typ:{...d.typ,quant:d.typ.quant+1}})],
  ['type-span',d=>({...d,typ:{...d.typ,originBegin:d.typ.originBegin+1}})],
  ['children',d=>({...d,ctors:list([events[0]])})],
 ]){const book=list([...events.slice(0,-1),change(clone(last))]),ad=api.p140cp_admit(epoch,book,cache);assert.equal(ad.$,'P140CPRefused');report.rows.push({name:'data-'+name,scope:'admission-only data mutation',reason:ad.reason,complete:true});}
 const foreign={...last,value:{$:'KTerm',tag:'Foreign',name:'old',id:0,quant:0,kids:{$:'Nil'},removed:{$:'Nil'},originBegin:0,originEnd:0}};
 const foreignBook=list([...events.slice(0,-1),foreign]),fc=api.p140cp_saved(api.p140cp_seed(epoch,foreignBook,2));assert.equal(fc.$,'P140CPSaved');
 const changed=list([...events.slice(0,-1),{...foreign,value:{...foreign.value,name:'new'}}]);
 assert.equal(api.p140cp_admit(epoch,changed,fc).$,'P140CPRefused');report.rows.push({name:'data-Foreign-body',scope:'admission-only data mutation',complete:true});
 // Demonstrate independent observer sensitivity, not authentication of a
 // forged checkpoint. Such objects are deliberately outside the API contract.
 const world=cache.world;
 for(const[name,patch]of[
  ['fresh',{fresh:{$:'KFreshKnown',next:world.fresh.next+1}}],
  ['checked',{checked:{$:'Nil'}}],
  ['memo',{memo:list([{$:'KSpecMemo',template:'fake',key:'k',name:'x',active:true}])}],
 ]){assert.equal(api.p140ce_world(world,{...world,...patch}),false);report.rows.push({name:'observer-detects-'+name,scope:'forged-state negative observer',complete:true});}
 inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e);process.exitCode=1;}finally{save();console.log(JSON.stringify({complete:report.complete,rows:report.rows,error:report.error}));}
