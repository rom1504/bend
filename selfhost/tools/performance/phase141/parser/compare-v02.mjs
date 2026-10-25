// Independent old/new observable parser comparison. No parsing in host tooling.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..');
const [oldFile,newFile,outArg,mode='corpus']=process.argv.slice(2),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase141/'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p);
const receipts=[oldFile,newFile].map(f=>JSON.parse(fs.readFileSync(f)));
for(const r of receipts){assert(r.checked&&r.complete);r.inputs.forEach(verify);verify(r.api);}
const apis=await Promise.all(receipts.map(async r=>(await import(pathToFileURL(r.api.file))).default));
const report={kind:'phase141-independent-parser-differential',mode,complete:false,
 inputs:[pin(import.meta.filename),pin(oldFile),pin(newFile),...receipts.flatMap(r=>[r.api,...r.inputs])],rows:[]};
fs.mkdirSync(out,{recursive:true});fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
function exact(a,b){
 const todo=[[a,b]],seen=new WeakMap();let objects=0,scalars=0;
 while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y)){scalars++;continue;}
  if(x===null||y===null||typeof x!=='object'||typeof y!=='object'){assert.deepEqual(x,y);scalars++;continue;}
  let ys=seen.get(x);if(ys?.has(y))continue;if(!ys){ys=new WeakSet();seen.set(x,ys);}ys.add(y);objects++;
  const kx=Object.keys(x).sort(),ky=Object.keys(y).sort();assert.deepEqual(kx,ky);for(const k of kx)todo.push([x[k],y[k]]);
 }return{objects,scalars};
}
const clock=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000};};
const scopes=apis.map(a=>a.f_parse_scope_empty());
function parse(name,text,start=1){
 fs.writeFileSync(out+'/current.json',JSON.stringify({name,sourceBytes:Buffer.byteLength(text),start}));
 const runs=apis.map((a,i)=>{
  try{return clock(()=>a.p140pt_fresh(text,scopes[i],start));}
  catch(e){if(e instanceof RangeError)return {hostFailure:String(e)};throw e;}
 });
 if(runs.some(r=>r.hostFailure)){
  report.rows.push({name,sourceBytes:Buffer.byteLength(text),origin:start,hostFailures:runs.map(r=>r.hostFailure??null),compared:false});
  save();return;
 }
 const equality=exact(runs[0].value,runs[1].value);
 report.rows.push({name,sourceBytes:Buffer.byteLength(text),origin:start,error:runs[0].value.error,
  seconds:runs.map(r=>r.seconds),equality});
}
function files(dir){return fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?files(path.join(dir,e.name)):e.name.endsWith('.bend')?[path.join(dir,e.name)]:[]).sort();}
try{
 if(mode==='corpus'){
  const upstream=ROOT+'/selfhost/.bootstrap/upstream-phase66';
  const sources=[...files(upstream+'/tests'),...files(upstream+'/demos'),...files(upstream+'/bench').filter(f=>fs.statSync(f).size<100000)];
  for(const f of sources){report.inputs.push(pin(f));parse(path.relative(upstream,f),fs.readFileSync(f,'utf8'));if(report.rows.length%100===0)save();}
  // Parser contracts include errors and UTF16 origins, independently of checking.
  const fixture='@unsafe\ndef first(x: U32) -> U32:\n  x\n\ndef main() -> U32:\n  first(1)\n';
  for(const origin of [0,1,17,4294967000])for(const prefix of ['', '# 😀 comment\n'])parse('origin-'+origin+'-'+prefix.length,prefix+fixture,origin);
  for(let n=0;n<=fixture.length;n++)parse('truncated-'+n,fixture.slice(0,n));
 }else if(mode==='large'){
  for(const rel of ['selfhost/.bootstrap/upstream-phase66/bend2/base.bend','selfhost/build/phase137/integrated-source03/compiler.bend','selfhost/build/phase140/native-source18/compiler.bend']){
   const f=ROOT+'/'+rel;report.inputs.push(pin(f));parse(rel,fs.readFileSync(f,'utf8'));save();
  }
 }else if(mode==='checkpoint'){
  const first='def first(x: U32) -> U32:\n  x\n\n',last='def main() -> U32:\n  first(1)\n';
  const heads=[first,'# 😀\n'+first,'@unsafe\n'+first,'import Base\n'+first,
   'type Pair is Data:\n  Pair{a: U32, b: U32}\n\n'+first,
   'law work:\n  for +x: U32\n  U32\ndef work(x):\n  x\n\n'+first];
  for(let h=0;h<heads.length;h++){
   const text=heads[h]+last,hint=heads[h].length+1;
   const seeds=apis.map((a,i)=>a.p140p_seed(text,a.p140pt_header(text,1),scopes[i],1,hint));
   exact(seeds[0],seeds[1]);assert.equal(seeds[0].cache.$,'Some');
   for(const[label,current]of [['same',text],['body',text.replace('first(1)','first(2)')],['bad',heads[h]+'def main( -> U32:\n'],
    ['prefix','# changed\n'+text],['plus',heads[h]+'+ 2\n'],['minus',heads[h]+'- 2\n'],['union',heads[h]+'| U32\n'],['recover',text]]){
    const warm=apis.map((a,i)=>a.p140p_resume(current,a.p140pt_header(current,1),scopes[i],1,seeds[i].cache));
    const fresh=apis[0].p140pt_fresh(current,scopes[0],1);
    report.rows.push({name:`head${h}-${label}`,hit:warm[0].hit,error:warm[0].result.error,
     equality:exact(warm[0],warm[1]),freshEquality:exact(fresh,warm[1].result)});
   }
  }
 }else throw Error('Unknown mode');
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}
finally{report.peakRssBytes=process.resourceUsage().maxRSS*1024;report.successfulParses=report.rows.filter(r=>r.error==='').length;save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,successfulParses:report.successfulParses,error:report.error}));}
