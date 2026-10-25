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
 const head='type Bit is Data:\n  Off{}\n  Onn{}\ndef id(~A: Data, x: A) -> A:\n  x\ndef keep() -> Bit:\n  id(~Bit,Off{})\n';
 const a=parse('memo-A',head+'def edit() -> Bit:\n  id(~Bit,Off{})\n');
 const b=parse('memo-B',head+'def edit() -> Bit:\n  id(~Bit,Onn{})\n');
 const seed=api.p140cp_seed(epoch,a.book,3),cache=api.p140cp_saved(seed);
 assert.equal(seed.checked.result.error,'');assert.equal(cache.$,'P140CPSaved');
 const memos=arr(cache.world.memo);assert(memos.length>0,'must actually retain specialization memo');
 const fresh=api.dg_check_world(b.book),got=api.p140cp_replay(epoch,b.book,cache);
 assert.equal(fresh.result.error,'');assert.equal(got.reused,true);
 report.rows.push({name:'specialization-prefix-full-state',memoEntries:memos,skipped:got.skipped,equality:equal(got.checked,fresh),complete:true});
 const omitted={...cache,world:{...cache.world,memo:{$:'Nil'}}};
 const stale=api.p140cp_replay(epoch,b.book,omitted);
 // Deliberately corrupted in-process capability is outside admission contract;
 // independent complete-state comparison must detect this insufficient cache.
 assert.equal(api.p140ce_checked(stale.checked,fresh),false);
 report.rows.push({name:'missing-memo-stale-output-detected',scope:'deliberately forged-state challenge',freshError:fresh.result.error,staleError:stale.checked.result.error,complete:true});
 inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e);process.exitCode=1;}finally{save();console.log(JSON.stringify({complete:report.complete,rows:report.rows,error:report.error}));}
