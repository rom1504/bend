import fs from 'node:fs';import path from 'node:path';import{pathToFileURL}from'node:url';
const[apiFile,out]=process.argv.slice(2),api=(await import(pathToFileURL(path.resolve(apiFile)))).default;
fs.mkdirSync(out,{recursive:false});const rows=[],controls=JSON.parse(fs.readFileSync(path.join(import.meta.dirname,'inline/leaf-controls.json')));
for(const name of [...new Set(controls.cases.map(c=>c.fixture)),...controls.refusals]){
 const maybe=name.startsWith('leaf_')?api.nx_l_fixture(name):api.nx_i_fixture(name),raw=maybe.value;
 for(const budget of controls.budgets){const program=api.nx_inline_leaf(raw,budget),valid=api.nx_verify(program),stem=path.join(out,name+'-'+budget);
  if(name==='tail_dead'){if(valid)throw Error('invalid accepted');}else if(!valid)throw Error('invalid '+name);
  fs.writeFileSync(stem+'.before.json',api.nx_json_program(raw));fs.writeFileSync(stem+'.json',api.nx_json_program(program));
  if(valid&&budget===4096)for(const[ext,fn]of[['c','nx_c_program'],['ssa','nxq_program_fused']])fs.writeFileSync(stem+'.'+ext,api[fn](program));
  rows.push({name,budget,stem,valid});
 }
}
fs.writeFileSync(path.join(out,'rows.json'),JSON.stringify(rows,null,2)+'\n');
