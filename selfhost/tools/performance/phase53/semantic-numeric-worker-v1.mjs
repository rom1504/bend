// Fresh-process numeric observations. The caller separates source and TS verdicts.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [moduleFile,configFile,out]=process.argv.slice(2);
const config=JSON.parse(fs.readFileSync(configFile,'utf8'));
const mod=await import(pathToFileURL(moduleFile));
assert(mod.default&&typeof mod.default==='object');
const values=[];let pass=true;
for(let turn=0;turn<config.repetitions;turn++){
 let value;
 if(config.mode==='source-table')value=mod.default[config.exportName??'main']();
 else if(config.mode==='roundtrip')value=mod.default.word(mod.default.raw(config.bits));
 else value=mod.default[config.exportName]();
 values.push(value);if(value!==config.expected)pass=false;
}
fs.writeFileSync(out,JSON.stringify({kind:'phase53-cold-numeric-observation',complete:true,oraclePass:pass,expected:config.expected,values,firstCall:values[0],mode:config.mode,repetitions:config.repetitions,scope:'First value is observed before any warmup; every repeated value remains part of the independent oracle.'},null,2)+'\n',{flag:'wx'});
