// Presentation only: preserve a complete Bend-produced diagnostic at existing boundaries.
import fs from'node:fs';import path from'node:path';import assert from'node:assert/strict';import{createHash}from'node:crypto';
const file=path.resolve(process.argv[2]),report=path.resolve(process.argv[3]);const sha=x=>createHash('sha256').update(x).digest('hex');
const before=fs.readFileSync(file,'utf8');let after=before;
for(const[old,next]of[["diagnostic:'Error: '+loaded.error","diagnostic:loaded.error.startsWith('Error:')?loaded.error:'Error: '+loaded.error"],["diagnostic:'Error: '+error.message","diagnostic:error.message.startsWith('Error:')?error.message:'Error: '+error.message"]]){assert.equal(after.split(old).length,2);after=after.replace(old,next);}
fs.writeFileSync(report,JSON.stringify({kind:'phase5-parser-presentation-overlay',file,beforeSha256:sha(before),afterSha256:sha(after),tool:{file:import.meta.filename,sha256:sha(fs.readFileSync(import.meta.filename))},scope:'Only full-diagnostic presentation; no parsing or semantic decision.'},null,2)+'\n',{flag:'wx'});fs.writeFileSync(file,after);
