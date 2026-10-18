import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
const [apiFile,out,view]=process.argv.slice(2);const api=(await import(pathToFileURL(path.resolve(apiFile)))).default;
fs.mkdirSync(out,{recursive:false});for(const [ext,fn] of [['ssa','nx110rt_probe_qbe'],['c','nx110rt_probe_c']]){const text=api[fn](view);if(text.includes('INVALID_'))throw Error('probe refused');fs.writeFileSync(path.join(out,'program.'+ext),text);}
