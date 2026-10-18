import fs from 'node:fs';import path from 'node:path';import{pathToFileURL}from'node:url';import crypto from'node:crypto';
const[apiFile,out]=process.argv.slice(2),api=(await import(pathToFileURL(path.resolve(apiFile)))).default;
fs.mkdirSync(out,{recursive:false});const rows=[];
const cases=[...['snapshot','collision','branch','merge','reset','nested','cycle','tail_dead'].map(n=>[n,'nx_i_fixture']),...['reach_direct','reach_stored','reach_returned','reach_dead_cycle','reach_cycle','reach_cap'].map(n=>[n,'nx_r_fixture']),...['many','shared','shared_borrow','text','list','tree','closure','tail'].map(n=>[n,'nx_workload'])];
for(const[name,fn]of cases){const raw=api[fn](name).value;if(!raw)throw Error(name);for(const budget of[0,1,32,4096]){
 const start=performance.now(),p=api.nx_inline_demand(raw,budget),seconds=(performance.now()-start)/1000,stem=path.join(out,name+'-'+budget),valid=api.nx_verify(p);
 if(valid!==(name!=='tail_dead'))throw Error('verification '+name);
 const rawText=api.nx_json_program(raw),text=api.nx_json_program(p);fs.writeFileSync(stem+'.before.json',rawText);fs.writeFileSync(stem+'.json',text);
 if(valid&&budget===4096)for(const[ext,emit]of[['c','nx_c_program'],['ssa','nxq_program_fused']])fs.writeFileSync(stem+'.'+ext,api[emit](p));
 rows.push({name,budget,stem,valid,seconds});
}}
fs.writeFileSync(path.join(out,'rows.json'),JSON.stringify(rows,null,2)+'\n');
fs.writeFileSync(path.join(out,'method.mjs'),fs.readFileSync(import.meta.filename));
fs.writeFileSync(path.join(out,'inputs.json'),JSON.stringify([apiFile,import.meta.filename].map(file=>({file:path.resolve(file),sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')})),null,2)+'\n');
