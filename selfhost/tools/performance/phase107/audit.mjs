import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
const [apiArg,outArg]=process.argv.slice(2),api=(await import(pathToFileURL(path.resolve(apiArg)))).default;
fs.mkdirSync(outArg,{recursive:false});const rows=[];
for(const name of ['snapshot','collision','branch','merge','reset','nested','cycle','shared','shared_borrow']){
 const chosen=api.nx_i_fixture(name);const raw=chosen.$==='Some'?chosen.value:api.nx_workload(name).value;
 for(const method of ['nx_inline','nx_inline_deep','nx_inline_entry'])for(const budget of [0,1,32,4096]){
  const program=api[method](raw,budget);if(!api.nx_verify(program))throw Error('invalid '+name+'/'+method);
  const stem=path.join(outArg,name+'-'+method+'-'+budget);
  fs.writeFileSync(stem+'.before.json',api.nx_json_program(raw));fs.writeFileSync(stem+'.json',api.nx_json_program(program));rows.push({name,method,budget,stem});
 }
}
fs.writeFileSync(path.join(outArg,'rows.json'),JSON.stringify(rows,null,2)+'\n');
