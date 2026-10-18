import fs from 'node:fs';import path from 'node:path';import{pathToFileURL}from'node:url';import crypto from'node:crypto';
const[apiFile,out]=process.argv.slice(2),api=(await import(pathToFileURL(path.resolve(apiFile)))).default;
fs.mkdirSync(out,{recursive:false});const controlFile=path.join(import.meta.dirname,'inline/strength-controls-v3.json'),ctl=JSON.parse(fs.readFileSync(controlFile)),rows=[];
function record(name,raw,meta){
 const after=api.nx_strength_reduce(raw),valid=api.nx_verify(raw);if(api.nx_verify(after)!==valid)throw Error('validity '+name);
 const a=api.nx_json_program(raw),b=api.nx_json_program(after),stem=path.join(out,name);fs.writeFileSync(stem+'.before.json',a);fs.writeFileSync(stem+'.json',b);
 if(meta.unchanged!==undefined&&(a===b)!==meta.unchanged)throw Error('change '+name);
 if(meta.native&&valid)for(const[ext,fn]of[['c','nx_c_program'],['ssa','nxq_program_fused']])fs.writeFileSync(stem+'.'+ext,api[fn](after));
 rows.push({name,stem,valid,changed:a!==b,...meta});
}
for(const width of ctl.widths)for(const factor of ctl.coefficients)for(const left of ctl.coefficientOnLeft)
 record(`${width}-${factor}-${left}`,api.nx_sr_fixture(width,factor,left),{width,factor,left,native:ctl.nativeScreen.coefficients.includes(factor),unchanged:ctl.expectedUnchangedCoefficients.includes(factor)});
for(const extra of ctl.extraCases)record('extra-'+extra.name,api.nx_sr_fixture_extra(extra.name).value,{extra,native:extra.valid,unchanged:extra.unchanged});
fs.writeFileSync(path.join(out,'rows.json'),JSON.stringify(rows,null,2)+'\n');fs.copyFileSync(controlFile,path.join(out,'controls.json'));fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
fs.writeFileSync(path.join(out,'inputs.json'),JSON.stringify([apiFile,import.meta.filename,controlFile].map(file=>({file:path.resolve(file),sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')})),null,2)+'\n');
