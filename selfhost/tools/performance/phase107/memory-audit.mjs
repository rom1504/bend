import fs from 'node:fs';import path from 'node:path';import{pathToFileURL}from'node:url';import crypto from'node:crypto';
const[apiFile,out]=process.argv.slice(2),api=(await import(pathToFileURL(path.resolve(apiFile)))).default;
fs.mkdirSync(out,{recursive:false});const controls=JSON.parse(fs.readFileSync(path.join(import.meta.dirname,'inline/memory-controls.json'))),rows=[];
for(const name of [...new Set(controls.cases.map(c=>c.fixture)),...['shared','shared_borrow','text','list','tree','closure','tail','many']]){
 let before=name.startsWith('memory_')?api.nx_m_fixture(name).value:api.nx_workload(name).value;if(!before)throw Error(name);
 if(!name.startsWith('memory_'))before=api.nx_reachable(api.nx_inline_leaf(api.nx_inline_demand(before,4096),4096));
 const start=performance.now(),after=api.nx_memory_forward(before),seconds=(performance.now()-start)/1000,stem=path.join(out,name);
 if(!api.nx_verify(before)||!api.nx_verify(after))throw Error('invalid '+name);
 fs.writeFileSync(stem+'.before.json',api.nx_json_program(before));fs.writeFileSync(stem+'.json',api.nx_json_program(after));
 for(const[ext,fn]of[['c','nx_c_program'],['ssa','nxq_program_fused']])fs.writeFileSync(stem+'.'+ext,api[fn](after));rows.push({name,stem,seconds});
}
const intervals=[];for(const ar of[0,1])for(const br of[0,1])for(const ao of[0,1,4,8,4294967287,4294967291])for(const bo of[0,1,4,8,4294967287,4294967291])for(const aw of[4,8])for(const bw of[4,8]){
 const a={$:'NxMAddr',root:ar,offset:ao,extent:4294967295},b={$:'NxMAddr',root:br,offset:bo,extent:4294967295};
 const expected=ar!==br||ao+aw<=bo||bo+bw<=ao,actual=api.nx_m_disjoint(a,aw,b,bw);if(actual!==expected)throw Error('interval');intervals.push({ar,br,ao,bo,aw,bw,actual});
}
fs.writeFileSync(path.join(out,'rows.json'),JSON.stringify(rows,null,2)+'\n');fs.writeFileSync(path.join(out,'intervals.json'),JSON.stringify(intervals)+'\n');
fs.copyFileSync(path.join(import.meta.dirname,'inline/memory-controls.json'),path.join(out,'controls.json'));fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
fs.writeFileSync(path.join(out,'inputs.json'),JSON.stringify([apiFile,import.meta.filename,path.join(import.meta.dirname,'inline/memory-controls.json')].map(file=>({file:path.resolve(file),sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')})),null,2)+'\n');
