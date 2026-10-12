// Private diagnostic observer of checked annotated input; no compiler mutation.
import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
const root='/home/ai/bend2/build/publish/bend';const [input,out]=process.argv.slice(2);fs.mkdirSync(out);const source=root+'/selfhost/dist/typed-api.mjs';
const helper=String.raw`
export function inspectSharing(book) {
 const c=(f,...a)=>run_loop(f(...a)),nil={$:'Nil'},list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
 const arr=x=>{let r=[];for(;x?.$==='Con';x=x.tail)r.push(x.head);return r;};const kids=t=>arr(c($ks$,t)),tag=t=>c($tg$,t),name=t=>c($nm$,t);
 const term=(t,n=2)=>({tag:tag(t),name:name(t),id:c($ix$,t),kids:n?kids(t).map(k=>term(k,n-1)):kids(t).length});
 const names=arr(c($nc_live_names$,book,list(['main']),nil)),rows=[];
 for(const n of names){const d=c($lookup$,book,n);if(c($nc_native_def$,d)||c($nc_foreign$,d))continue;
  const original=c($dv$,d),erased=c($nc_erase$,book,original),seen=new Set();
  function walk(t){if(tag(t)==='Ann'&&tag(kids(t)[0])==='Var'){
   let v=kids(t)[0],id=c($ix$,v);if(!seen.has(id)&&c($nq_uses$,erased,id)>1){seen.add(id);let ty=c($nq_layout_type$,book,kids(t)[1]);rows.push({definition:n,id,type:term(ty,3)});}return;
  }for(const k of kids(t))walk(k);}
  walk(original);
 }
 return rows;
}
`;
const derived=path.resolve(out,'api.mjs');fs.writeFileSync(derived,fs.readFileSync(source,'utf8')+helper);const A=await import(pathToFileURL(derived));let rows;
process.env.BEND_TYPED_API=source;process.env.BEND_TYPED_RUNTIME=root+'/selfhost/src/runtime.mjs';process.env.BEND_BASE=root+'/selfhost/dist/base.bend';
const capture=b=>{rows=A.inspectSharing(b);throw Error('CAPTURE_COMPLETE');};const D=await import(pathToFileURL(root+'/selfhost/tools/typed-driver.mjs'));let observation=await D.inspect(path.resolve(input),{mode:'native',api:{...A.default,nc_compile:capture,nc_compile_checked:capture},withReport:true});assert(rows);
const pin=p=>({path:p,sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({source:pin(source),derived:pin(derived),input:pin(input),rows,observation},null,2));const grouped={};for(const r of rows){const key=r.type.tag+':'+r.type.name;(grouped[key]??=[]).push(r.definition);}console.log(JSON.stringify(grouped));
