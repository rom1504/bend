import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
const [apiArg,outArg]=process.argv.slice(2),api=(await import(pathToFileURL(path.resolve(apiArg)))).default;
fs.mkdirSync(outArg,{recursive:false});const rows=[];
for(const name of ['tail_sum','tail_snapshot','tail_reset','tail_nontail','tail_dead','tail_existingloop','tail_pointer','tail_mutual']){
 const selected=api.nx_i_fixture(name);if(selected.$!=='Some')throw Error('missing '+name);
 const before=selected.value,after=api.nx_tail_optimize(before);const verified=api.nx_verify(after);if(!verified&&name!=='tail_dead')throw Error('invalid '+name);if(name==='tail_dead'&&(api.nx_verify(before)||verified||api.nx_json_program(before)!==api.nx_json_program(after)))throw Error('invalid refusal failed');
 const stem=path.join(outArg,name);fs.writeFileSync(stem+'.before.json',api.nx_json_program(before));fs.writeFileSync(stem+'.json',api.nx_json_program(after));fs.writeFileSync(stem+'.c',api.nx_c_program(after));fs.writeFileSync(stem+'.ssa',api.nxq_program_fused(after));rows.push({name,stem,verified});
}
fs.writeFileSync(path.join(outArg,'rows.json'),JSON.stringify(rows,null,2)+'\n');
