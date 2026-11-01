#!/usr/bin/env node
// Execute the Bend frontend/kernel on an explicitly selected compiler source.
// Generated APIs are inputs; this command never invokes upstream parsing/checking.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const usage='Usage: node tools/selfcheck.mjs --source COMPILER.bend --api API.mjs --base BASE.bend [--report FRESH.json]\nUse --frontend FRONTEND.mjs --checker CHECKER.mjs instead of --api for independent split images.\nThis checks the selected source; it is not a fixed-point or whole-compiler correctness proof.';
const argv=process.argv.slice(2),options={};
if(argv.length===1&&argv[0]==='--help'){console.log(usage);process.exit(0)}
try{
  for(let i=0;i<argv.length;i+=2){
    const key=argv[i].slice(2);
    if(!argv[i].startsWith('--')||!['source','api','frontend','checker','base','report'].includes(key)||
       !argv[i+1]||argv[i+1].startsWith('--')||Object.hasOwn(options,key))throw Error('Expected unique --option value arguments');
    options[key]=argv[i+1];
  }
  if(!options.source||!options.base||!(options.api||(options.frontend&&options.checker)))throw Error('Explicit source, Base and API identities are required');
  if(options.api&&(options.frontend||options.checker))throw Error('Choose --api or the frontend/checker pair');
  if(options.report&&fs.existsSync(path.resolve(options.report)))throw Error('Report output must be fresh');
}catch(error){console.error(error.message+'\n'+usage);process.exit(2)}
const source=path.resolve(options.source);
const frontend=path.resolve(options.api||options.frontend);
const checker=path.resolve(options.api||options.checker);
const base=path.resolve(options.base);
const sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const sourceBytes=fs.readFileSync(source),baseBytes=fs.readFileSync(base);
const F=(await import(pathToFileURL(frontend))).default,C=(await import(pathToFileURL(checker))).default;
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const begin=performance.now();
const result=(F.f_load_graph||F.f_load)('__main__',list([
  {$:'FSource',name:'__main__',path:source,text:sourceBytes.toString()},
  {$:'FSource',name:'Base',path:base,text:baseBytes.toString()}
]));
const loadSeconds=(performance.now()-begin)/1000;
let events=0;for(let ds=result.book;ds.$==='Con';ds=ds.tail)events++;
process.stdout.write(`Loaded ${events} declaration events in ${loadSeconds.toFixed(3)}s\n`);
const checkBegin=performance.now();
const diagnostic=result.error||C.check_book(result.book);
const report={scope:'compiler source checked by the Bend frontend and Bend kernel; not a bootstrap fixed-point proof',
  pass:!diagnostic,source,sourceSha256:sha(sourceBytes),frontend,frontendSha256:sha(fs.readFileSync(frontend)),
  checker,checkerSha256:sha(fs.readFileSync(checker)),baseSha256:sha(baseBytes),events,loadSeconds,
  checkSeconds:(performance.now()-checkBegin)/1000,diagnostic,generated:new Date().toISOString()};
if(options.report){const file=path.resolve(options.report);fs.mkdirSync(path.dirname(file),{recursive:true});fs.writeFileSync(file,JSON.stringify(report,null,2)+'\n',{flag:'wx'});}
else console.log(JSON.stringify(report));
console.log(diagnostic||`PASS self-typecheck (${report.checkSeconds.toFixed(3)}s checking)`);
if(diagnostic)process.exitCode=1;
