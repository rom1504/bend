import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
const [apiFile,out,view,kind='rebuild']=process.argv.slice(2);const api=(await import(pathToFileURL(path.resolve(apiFile)))).default;
fs.mkdirSync(out,{recursive:false});
const controls={};
for(const fn of ['nx110rt_control_report','nx110rt_width_report','nx110rt_call_control_report','nx110rt_predicate_report','nx110rtg_control_report','nx110rts_control_report','nx110rtn_control_report','nx110rtw_control_report','nx110rtc_control_report']){
 if(!api[fn])continue;
 const text=api[fn]();if(text.includes('FAIL'))throw Error(fn+' failed');
 controls[fn]={cases:text.trim().split('\n').length,passed:true};
}
fs.writeFileSync(path.join(out,'controls.json'),JSON.stringify(controls,null,2)+'\n');
for(const [ext,fn] of [['ssa','nx110rt_probe_qbe'],['c','nx110rt_probe_c']]){const text=api[kind==='take'?fn.replace('nx110rt_','nx110rtg_'):fn](view);if(text.includes('INVALID_'))throw Error('probe refused');fs.writeFileSync(path.join(out,'program.'+ext),text);}
