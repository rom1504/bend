#!/usr/bin/env node
// Runtime proof that the Bend frontend and kernel accept compiler source.
// Generated APIs are inputs; this command never invokes upstream parsing/checking.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'..');
const source=path.resolve(process.argv[2]||path.join(root,'dist/selfcheck/compiler.bend'));
const frontend=path.resolve(process.env.BEND_SELFCHECK_API||path.join(root,'dist/selfcheck/frontend-api.mjs'));
const checker=path.resolve(process.env.BEND_KERNEL_API||(process.env.BEND_SELFCHECK_API?frontend:path.join(root,'dist/selfcheck/checker-api.mjs')));
const base=path.resolve(process.env.BEND_BASE||path.join(root,'dist/base.bend'));
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
fs.writeFileSync(path.join(root,'dist/selfcheck-report.json'),JSON.stringify(report,null,2)+'\n');
console.log(diagnostic||`PASS self-typecheck (${report.checkSeconds.toFixed(3)}s checking)`);
if(diagnostic)process.exitCode=1;
