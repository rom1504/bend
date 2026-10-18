import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
const [apiFile,out]=process.argv.slice(2),api=(await import(pathToFileURL(path.resolve(apiFile)))).default;
fs.mkdirSync(out,{recursive:false});const rows=[];
for(const name of ['reach_direct','reach_stored','reach_returned','reach_dead_cycle','reach_branch','reach_cycle','reach_cap','tail_dead','many']){
 const raw=name==='tail_dead'?api.nx_i_fixture(name).value:name==='many'?api.nx_inline_entry(api.nx_workload(name).value,4096):api.nx_r_fixture(name).value;
 const program=api.nx_reachable(raw),stem=path.join(out,name),valid=api.nx_verify(program);
 if(name==='tail_dead'){if(valid)throw Error('invalid control accepted');}else if(!valid)throw Error('invalid '+name);
 if(JSON.stringify(api.nx_reachable(program))!==JSON.stringify(program))throw Error('not idempotent '+name);
 fs.writeFileSync(stem+'.before.json',api.nx_json_program(raw));fs.writeFileSync(stem+'.json',api.nx_json_program(program));
 if(valid)for(const [ext,fn]of [['c','nx_c_program'],['ssa','nxq_program_fused']])fs.writeFileSync(stem+'.'+ext,api[fn](program));
 rows.push({name,stem,valid});
}
fs.writeFileSync(path.join(out,'rows.json'),JSON.stringify(rows,null,2)+'\n');
