// Host records results; all propagation runs the checked Bend implementation.
import fs from 'node:fs';import path from 'node:path';import{pathToFileURL}from'node:url';import crypto from'node:crypto';import{decodeNxProgram}from'./ir-json.mjs';
const[apiFile,out]=process.argv.slice(2),api=(await import(pathToFileURL(path.resolve(apiFile)))).default;
fs.mkdirSync(out,{recursive:false});const ctlFile=path.join(import.meta.dirname,'inline/constant-controls.json'),ctl=JSON.parse(fs.readFileSync(ctlFile)),rows=[];
const text=p=>api.nx_json_program(p),effects=new Set(['call','icall','load','alloc','store','free']);
function shape(v,p='',r=[]){if(Array.isArray(v))v.forEach((x,i)=>shape(x,p+'/'+i,r));else if(v&&typeof v==='object'){if(effects.has(v.kind)||['set','return','if','while'].includes(v.kind))r.push([p,v.kind,v.name??null]);for(const[k,x]of Object.entries(v))shape(x,p+'/'+k,r);}return r;}
for(const name of [...new Set(ctl.cases.map(x=>x.fixture)),...['shared','shared_borrow','text','list','tree','closure','tail','many']]){
 const fixture=name.startsWith('constant_')?'nx_cp_fixture':'nx_workload';let before=api[fixture](name).value;if(!before)throw Error(name);
 if(fixture==='nx_workload')before=api.nx_scalar_promote(api.nx_pipeline_fast(before));
 const start=performance.now(),after=api.nx_constant_propagate(before),seconds=(performance.now()-start)/1000,stem=path.join(out,name),a=text(before),b=text(after);
 if(!api.nx_verify(before)||!api.nx_verify(after))throw Error('invalid '+name);
 if(name in ctl.expectedChanged&&(a!==b)!==ctl.expectedChanged[name])throw Error('change contract '+name);
 if(JSON.stringify(shape(JSON.parse(a)))!==JSON.stringify(shape(JSON.parse(b))))throw Error('effect/control shape '+name);
 fs.writeFileSync(stem+'.before.json',a);fs.writeFileSync(stem+'.json',b);
 for(const[ext,fn]of[['c','nx_c_program'],['ssa','nxq_program_fused']])fs.writeFileSync(stem+'.'+ext,api[fn](after));
 rows.push({name,fixture,stem,seconds,changed:a!==b});
}
const mutants=[];for(const[name,variable,value]of[['constant_cascade','a',0],['constant_join_different','value',7]]){
 const p=JSON.parse(fs.readFileSync(path.join(out,name+'.json'))),last=p.functions.at(-1).body.at(-1);
 function replace(v){if(v&&v.kind==='var'&&v.name===variable)return{kind:'const',type:'u32',value};if(Array.isArray(v))return v.map(replace);if(v&&typeof v==='object')return Object.fromEntries(Object.entries(v).map(([k,x])=>[k,replace(x)]));return v;}
 p.functions.at(-1).body[p.functions.at(-1).body.length-1]=replace(last);if(!api.nx_verify(decodeNxProgram(p)))throw Error('mutant must typecheck');fs.writeFileSync(path.join(out,name+'.mutant.json'),JSON.stringify(p));mutants.push(name);
}
const bad=JSON.parse(fs.readFileSync(path.join(out,'constant_snapshot.before.json')));bad.functions.at(-1).body.at(-1).value={kind:'var',name:'missing'};const ir=decodeNxProgram(bad);if(api.nx_verify(ir)||text(ir)!==text(api.nx_constant_propagate(ir)))throw Error('invalid identity');
fs.writeFileSync(path.join(out,'invalid.json'),JSON.stringify(bad));fs.writeFileSync(path.join(out,'rows.json'),JSON.stringify(rows,null,2)+'\n');fs.writeFileSync(path.join(out,'mutants.json'),JSON.stringify(mutants));
fs.copyFileSync(ctlFile,path.join(out,'constant-controls.json'));fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
fs.writeFileSync(path.join(out,'inputs.json'),JSON.stringify([apiFile,ctlFile,import.meta.filename,path.join(import.meta.dirname,'ir-json.mjs')].map(file=>({file:path.resolve(file),sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')})),null,2)+'\n');
console.log(JSON.stringify({pairs:rows.length,typedMutants:mutants.length,invalidIdentity:1}));
