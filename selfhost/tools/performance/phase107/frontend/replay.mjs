// Transport checked named ADTs into the Bend-written lowering/optimizer/emitter.
import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
const [apiArg,graphArg,outArg,entry='bench',budget='0']=process.argv.slice(2);
const api=(await import(pathToFileURL(path.resolve(apiArg)))).default;
const graph=JSON.parse(fs.readFileSync(graphArg));
const start=performance.now();const result=api.nxk_lower(graph,entry);
if(result.error){console.error(result.error);process.exit(2);}
const raw=result.program,program=api.nx_optimize(api.nx_inline(raw,Number(budget)));
if(api.nx_verify(program)!==true)throw Error('IR verifier refused optimized program');
const out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
for(const [ext,f] of [['json','nx_json_program'],['c','nx_c_program'],['ssa','nxq_program']])fs.writeFileSync(path.join(out,'program.'+ext),api[f](program));
fs.writeFileSync(path.join(out,'raw.json'),api.nx_json_program(raw));
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:true,lowerEmitSeconds:(performance.now()-start)/1000,entry,budget:Number(budget)},null,2)+'\n');
console.log('lowered '+entry);
