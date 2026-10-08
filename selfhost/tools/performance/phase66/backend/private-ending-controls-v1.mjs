// Source-transform compatibility controls, executed only by root's target lane.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const args=process.argv.slice(2),opts={};for(let i=0;i<args.length;i+=2)opts[args[i].replace(/^--/,'')]=args[i+1];
if(!opts.out)throw Error('Required --out fresh-directory');
const root=path.resolve(import.meta.dirname,'../../../../..'),meta=JSON.parse(fs.readFileSync(path.join(import.meta.dirname,'backend-v1.json'),'utf8'));
const item=meta.files.find(x=>x.path==='selfhost/tools/private-compiler/calls.mjs');
const input=path.resolve(opts.transform??path.join(root,item.path));const hash=x=>crypto.createHash('sha256').update(x).digest('hex');
assert.equal(hash(fs.readFileSync(input)),item.afterSha256,'Require exact selected transform');
const {transformPrivateCalls}=await import(pathToFileURL(input).href);const out=path.resolve(opts.out);fs.mkdirSync(out,{recursive:false});
const old='export {G,call,list,ctor};\nexport default Object.fromEntries(Object.keys(G).map(k=>[k,(...args)=>call(get(G,k),args)]));';
const current="export {G,call,list,ctor};\nexport default Object.fromEntries(Object.keys(G).map(k=>[k.replace(':','.'),(...args)=>call(get(G,k),args)]));";
const body='const G=Object.create(null);const fn=(arity,code)=>({arity,code});const call=(f,a)=>f.code(a);const get=(g,k)=>g[k];const list=x=>x,ctor=(k,a)=>({$:k,a});\nG["module:value"]=fn(1,function(a){return a[0]+1;});\nG["module.value"]=fn(1,function(a){return a[0]+2;});\n';
const cases=[];
for(const [name,ending] of [['legacy',old],['current',current]]){
 const result=transformPrivateCalls(body+ending,{exports:['module:value','module.value'],mode:'control'});assert.ok(result.source.includes('privateImageMarker'));
 const p=path.join(out,name+'.mjs');fs.writeFileSync(p,result.source);const api=(await import(pathToFileURL(p).href)).default;
 assert.deepEqual(Object.keys(api),['module:value','module.value']);assert.equal(api['module:value'](40),41);assert.equal(api['module.value'](40),42);cases.push({name,pass:true});
}
for(const [name,ending] of [['absent',''],['duplicate-old',old+'\n'+old],['duplicate-current',current+'\n'+current],['mixed',old+'\n'+current]]){
 assert.throws(()=>transformPrivateCalls(body+ending,{exports:['module:value'],mode:'control'}),/Expected exact self-emitted public ABI/);cases.push({name,pass:true});
}
const report={kind:'phase66-private-ending-controls',version:1,pass:true,input:{path:input,sha256:hash(fs.readFileSync(input))},controller:{path:fs.realpathSync(import.meta.filename),sha256:hash(fs.readFileSync(import.meta.filename))},cases};fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({pass:true,total:cases.length}));
