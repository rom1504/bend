#!/usr/bin/env node
// Generate data with a checked Bend compiler. No template parsing lives here.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [attemptFile,runtimeFile,outputFile,receiptFile]=process.argv.slice(2);
assert(attemptFile&&runtimeFile&&outputFile&&receiptFile,
  'Usage: native-template.mjs ATTEMPT.json RUNTIME.c OUTPUT.json RECEIPT.json');
const hash=bytes=>createHash('sha256').update(bytes).digest('hex');
const pin=file=>({file:path.resolve(file),sha256:hash(fs.readFileSync(file))});
const attempt=JSON.parse(fs.readFileSync(attemptFile,'utf8'));
assert.equal(attempt.checked,true);assert.equal(pin(attempt.api.file).sha256,attempt.api.sha256);
const api=(await import(pathToFileURL(attempt.api.file))).default;
const runtime=fs.readFileSync(runtimeFile,'utf8'),prepared=api.ne_runtime_prepare(runtime);
assert.equal(prepared.$,'NE_Parts');
const parts=[];let list=prepared.parts;
while(list.$==='Con'){parts.push(list.head);list=list.tail;}
assert.equal(list.$,'Nil');assert.equal(parts.length,5);assert.equal(parts.join(''),runtime);
const artifact={version:1,runtimeSha256:hash(runtime),parts};
fs.writeFileSync(outputFile,JSON.stringify(artifact)+'\n',{flag:'wx'});
const receipt={kind:'bend-native-template',producer:pin(attempt.api.file),attempt:pin(attemptFile),
  generator:pin(import.meta.filename),runtime:pin(runtimeFile),artifact:pin(outputFile),
  chunks:parts.length,exactRoundTrip:true};
fs.writeFileSync(receiptFile,JSON.stringify(receipt,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify(receipt));
