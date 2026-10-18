// The host only selects fixtures and records checked Bend transformations.
import fs from 'node:fs';import path from 'node:path';import{pathToFileURL}from'node:url';import crypto from'node:crypto';
const[apiFile,out]=process.argv.slice(2),api=(await import(pathToFileURL(path.resolve(apiFile)))).default;
fs.mkdirSync(out,{recursive:false});const names=['promotion','memory'],controls=names.map(n=>JSON.parse(fs.readFileSync(path.join(import.meta.dirname,'inline',n+'-controls.json'))));
const rows=[];
for(const name of [...new Set(controls.flatMap(c=>c.cases.map(c=>c.fixture))),...['shared','shared_borrow','text','list','tree','closure','tail','many']]){
 const fixture=name.startsWith('promotion_')?'nx_p_fixture':name.startsWith('memory_')?'nx_m_fixture':'nx_workload';
 let before=api[fixture](name).value;if(!before)throw Error(name);
 if(fixture==='nx_workload')before=api.nx_pipeline_fast(before);
 const start=performance.now(),after=api.nx_scalar_promote(before),seconds=(performance.now()-start)/1000,stem=path.join(out,name);
 if(!api.nx_verify(before)||!api.nx_verify(after))throw Error('invalid '+name);
 const texts=[api.nx_json_program(before),api.nx_json_program(after)];
 if(name in controls[0].expectedChanged && (texts[0]!==texts[1])!==controls[0].expectedChanged[name])throw Error('change/refusal contract '+name);
 fs.writeFileSync(stem+'.before.json',texts[0]);fs.writeFileSync(stem+'.json',texts[1]);
 for(const[ext,fn]of[['c','nx_c_program'],['ssa','nxq_program_fused']])fs.writeFileSync(stem+'.'+ext,api[fn](after));
 rows.push({name,fixture,stem,seconds,changed:texts[0]!==texts[1]});
}
fs.writeFileSync(path.join(out,'rows.json'),JSON.stringify(rows,null,2)+'\n');
for(const n of names)fs.copyFileSync(path.join(import.meta.dirname,'inline',n+'-controls.json'),path.join(out,n+'-controls.json'));
fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
fs.writeFileSync(path.join(out,'inputs.json'),JSON.stringify([apiFile,import.meta.filename,...names.map(n=>path.join(import.meta.dirname,'inline',n+'-controls.json'))].map(file=>({file:path.resolve(file),sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')})),null,2)+'\n');
