// Data transport and byte identities only; no host compiler implementation.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
export const root=path.resolve(import.meta.dirname,'../../..');
export const read=file=>JSON.parse(fs.readFileSync(file));
export const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
export const same=(a,b)=>a?.bytes===b?.bytes&&a?.sha256===b?.sha256;
export const verify=p=>assert(same(pin(p.file),p),'Changed input: '+p.file);
export const save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n');
export function options(){const out={};for(let i=2;i<process.argv.length;i+=2){assert(process.argv[i].startsWith('--')&&process.argv[i+1]);out[process.argv[i].slice(2)]=process.argv[i+1]}return out}
export function output(file){file=path.resolve(file);assert(file.startsWith(root+'/selfhost/build/phase148/')&&!fs.existsSync(file));fs.mkdirSync(file,{recursive:true});return file}
export const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
export function items(value){const out=[];while(value?.$==='Con'){out.push(value.head);assert(out.length<=1000000);value=value.tail}assert.equal(value?.$,'Nil');return out}
export async function checked(file){
 const receipt=read(file),preparationFile=path.resolve(path.dirname(file),'../manifest.json'),preparation=read(preparationFile);
 assert(receipt.kind==='bend-checked-hosted-api'&&receipt.complete&&receipt.checked);
 assert(preparation.kind==='phase148-unit-api-preparation'&&preparation.complete&&preparation.originalBodiesUnchanged);
 assert(same(receipt.source,preparation.source));assert.deepEqual(receipt.exports,read(preparation.exports.file).exports);
 const inputs=[pin(file),pin(preparationFile),receipt.api,receipt.source,preparation.exports,...preparation.inputs];inputs.forEach(verify);
 return{api:(await import(pathToFileURL(receipt.api.file))).default,receipt,preparation,inputs};
}
export function context(api,segments,constructors,ready){return{ids:{$:'N111Ids',functions:api.p113e_originals(segments,api.missing()),constructors:api.ns_ctor_index(constructors,api.missing())},ready:api.p113e_signatures(ready,api.missing())}}
export function renderIds(api,segments,constructors){return{$:'N111Ids',functions:api.p111q_function_ids(segments,0,api.missing()),constructors:api.p111q_constructor_ids(constructors,0,api.missing())}}
