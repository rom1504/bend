// Data transport and experiment admission only; all compiler judgments stay in Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
export const root=path.resolve(import.meta.dirname,'../../..');
export const pin=file=>{file=fs.realpathSync(file);const data=fs.readFileSync(file);return{file,bytes:data.length,sha256:crypto.createHash('sha256').update(data).digest('hex')}};
export const same=(a,b)=>a?.bytes===b?.bytes&&a?.sha256===b?.sha256;
export const verify=row=>assert(same(pin(row.file),row),'Changed input: '+row.file);
export const read=file=>JSON.parse(fs.readFileSync(file));
export const save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n');
export function options(){const out={};for(let i=2;i<process.argv.length;i+=2){assert(process.argv[i].startsWith('--')&&process.argv[i+1]);out[process.argv[i].slice(2)]=process.argv[i+1]}return out}
export function output(file){file=path.resolve(file);assert(file.startsWith(root+'/selfhost/build/phase147/')&&!fs.existsSync(file));fs.mkdirSync(file,{recursive:true});return file}
export const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
export function items(value){const result=[];while(value?.$==='Con'){result.push(value.head);assert(result.length<=1000000);value=value.tail}assert.equal(value?.$,'Nil');return result}
export const tag=(value,name)=>{assert.equal(value?.$,name);return value};
export async function checked(file){
 const receipt=read(file);assert(receipt.kind==='bend-checked-hosted-api'&&receipt.complete&&receipt.checked);
 const directory=path.dirname(path.resolve(file)),preparationFile=path.join(directory,'../manifest.json'),preparation=read(preparationFile);
 assert(preparation.kind==='phase147-verifier-slice-preparation'&&preparation.complete&&preparation.originalBodiesUnchanged);
 assert(same(preparation.source,receipt.source));verify(receipt.api);verify(receipt.source);verify(preparation.exports);
 assert.deepEqual(receipt.exports,read(preparation.exports.file).exports);
 const inputs=[pin(file),pin(preparationFile),receipt.api,receipt.source,preparation.exports];
 // Acquisition records authenticate its original methods. Do not silently
 // resolve/reexecute historical method paths when comparing immutable images.
 return{api:(await import(pathToFileURL(receipt.api.file))).default,receipt,preparation,inputs};
}
export function originalIdentity(baseline,candidate){
 assert.deepEqual(baseline.preparation.canonicalSourceIdentity,candidate.preparation.canonicalSourceIdentity);
 const prior=new Map(baseline.preparation.declarations.filter(r=>r.source==='canonical').map(r=>[r.kind+':'+r.name,r]));
 for(const row of candidate.preparation.declarations.filter(r=>r.source==='canonical')){
  const old=prior.get(row.kind+':'+row.name);
  // Candidate observers can expose extra original helpers; where closures
  // overlap they must be byte exact. All rows bind the same canonical identity.
  if(old)assert(same(row,old),'Original declaration changed: '+row.name);
 }
}
export function context(api,row){
 const absent=api.missing();
 if(row.kind==='raw'){
  const functions=api.p111v_functions(row.segments,{$:'P111VScan',index:absent,error:'',count:0});
  const constructors=api.p111v_constructors(row.constructors,{$:'P111VScan',index:absent,error:'',count:0});
  assert.equal(functions.error,'');assert.equal(constructors.error,'');
  return{ids:{$:'N111Ids',functions:functions.index,constructors:constructors.index}};
 }
 return{ids:{$:'N111Ids',functions:api.p113e_originals(row.segments,absent),constructors:api.ns_ctor_index(row.constructors,absent)},
        ready:api.p113e_signatures(row.ready,absent)};
}
export function check(api,row,ctx,candidate=false){
 return row.kind==='raw'?api[candidate?'p147v_segment':'p111v_segment'](row.function,ctx.ids):
  api[candidate?'p147v_function':'p113e_function'](row.function,ctx.ids,ctx.ready);
}
export function semanticRows(tree){
 const rows=[],todo=[tree];
 while(todo.length){const node=todo.pop();
  if(node.$==='KIndexNode'){todo.push(node.left,node.right);continue}
  if(node.$==='KIndexLeaf'){for(const row of items(node.bucket))rows.push([row.name,row.kind,row.arity,row.templates]);continue}
  assert(node.$==='KDef'&&node.kind==='Absent','Unexpected verifier index leaf');
 }
 rows.sort((a,b)=>a[0]<b[0]?-1:a[0]>b[0]?1:0);assert.equal(new Set(rows.map(x=>x[0])).size,rows.length);return rows;
}
