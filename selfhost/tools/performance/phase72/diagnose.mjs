// Read-only inspection through an explicitly derived diagnostic API.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const root='/home/ai/bend2/build/publish/bend';
const [attemptArg,inputArg,outArg]=process.argv.slice(2);
const attempt=JSON.parse(fs.readFileSync(attemptArg)), out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const pin=p=>({path:p,sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const source=fs.readFileSync(attempt.api.file,'utf8');
assert.equal(pin(attempt.api.file).sha256,attempt.api.sha256);
const helper=String.raw`
export function inspectProducts(book) {
 const c=(f,...a)=>run_loop(f(...a)),nil={$:'Nil'},list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
 const array=x=>{const r=[];while(x?.$==='Con'){r.push(x.head);x=x.tail;}return r;};
 const tag=t=>c($tg$,t), term=(t,n=5)=>({tag:tag(t),name:c($nm$,t),id:c($ix$,t),kids:n?array(c($ks$,t)).map(k=>term(k,n-1)):array(c($ks$,t)).length});
 const names=c($nc_live_names$,book,list(['main']),nil),sigs=c($book_cached$,c($nq_signatures$,book,names),0),rows=[];
 for(const name of array(names)) {
  if(!name.includes('Array.map.go')&&!name.endsWith('p37.bst.insert'))continue;
  const d=c($lookup$,book,name),info=c($lookup$,sigs,name),sig=c($dv$,info),body=c($nc_compact_definition$,book,d,0);
  const row={name,signature:term(sig),result:term(c($dt$,info)),body:term(body,16)};
  if(tag(sig)==='NQSig') {
   const entry=c($nq_entry$,c($ks$,sig),0,c($da$,info));
   const normal=c($nq_candidate$,book,name,sigs,entry);
   row.error=c($nc_error$,normal.code);
   const shape=c($dt$,info),target={$:'NC_Destination',words:c($nq_words$,'nf_out',c($nq_width$,shape),0),shape,join:'',owner:c($nm$,sig),params:entry.params,tail:true,signatures:sigs};
   const code=c($nc_lower_to$,book,c($nd_reapply$,body,entry.args),entry.params,entry.fresh,target);
   row.withoutDemand={error:c($nc_error$,code),body:c($nc_body$,code),calls:array(c($nc_calls$,code))};
  }
  rows.push(row);
 }
 return rows;
}
`;
const derived=path.join(out,'api.mjs');fs.writeFileSync(derived,source+helper,{flag:'wx'});
process.env.BEND_TYPED_API=attempt.api.file;
process.env.BEND_TYPED_RUNTIME=path.join(root,'selfhost/src/runtime.mjs');
process.env.BEND_BASE=path.join(root,'selfhost/dist/base.bend');
const A=await import(pathToFileURL(derived));let rows;
const capture=book=>{rows=A.inspectProducts(book);throw Error('CAPTURE_COMPLETE');};
const api={...A.default,nc_compile:capture,nc_compile_checked:capture};
const D=await import(pathToFileURL(path.join(root,'selfhost/tools/typed-driver.mjs')));
const observation=await D.inspect(path.resolve(inputArg),{mode:'native',api,withReport:true});
assert(rows,'No checked book captured');
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({attempt:pin(attemptArg),input:pin(inputArg),producer:pin(import.meta.filename),api:pin(attempt.api.file),derived:pin(derived),rows,observation},null,2));
console.log(JSON.stringify(rows.map(({body,withoutDemand,...r})=>({...r,withoutDemandError:withoutDemand?.error}))));
