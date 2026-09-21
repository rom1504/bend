// Compare two generated parser libraries with identical representation.
// Usage: node src/back/js/benchmark-parser.mjs BASELINE.mjs CANDIDATE.mjs [SOURCE.bend]
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const [baselinePath,candidatePath,sourcePath]=process.argv.slice(2).map(p=>path.resolve(p));
if(!baselinePath||!candidatePath)throw Error('Provide baseline and candidate generated parser libraries.');
const baseline=(await import(pathToFileURL(baselinePath))).default,candidate=(await import(pathToFileURL(candidatePath))).default;
const sourceFile=sourcePath||path.resolve(import.meta.dirname,'../../core/term.bend'),source=fs.readFileSync(sourceFile,'utf8');
for(const api of [baseline,candidate])api.f_parse('import Base\n\ndef main() -> U32:\n  1\n');
const warmups=Number(process.env.BEND_BENCHMARK_WARMUPS||0);for(let i=0;i<warmups;i++)for(const api of [baseline,candidate])api.f_parse(source);
let outputHash;const rows=[];
for(const name of ['baseline','candidate','candidate','baseline']){const api=name==='baseline'?baseline:candidate;const start=performance.now(),output=api.f_parse(source),ms=performance.now()-start;const hash=crypto.createHash('sha256').update(JSON.stringify(output)).digest('hex');outputHash??=hash;assert.equal(hash,outputHash);const row={name,ms,outputHash:hash};rows.push(row);console.log(JSON.stringify(row));}
const hash=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const report={host:{engine:process.versions.bun?'Bun':'Node',version:process.versions.bun||process.versions.node},sourceFile,bytes:Buffer.byteLength(source),sourceSha256:hash(sourceFile),baselinePath,baselineSha256:hash(baselinePath),candidatePath,candidateSha256:hash(candidatePath),method:'Raw API; ABBA order; identical parsed output',fullInputWarmups:warmups,rows};
const directory=path.resolve(import.meta.dirname,'../../../build/js-prof');fs.mkdirSync(directory,{recursive:true});fs.writeFileSync(process.env.BEND_BENCHMARK_REPORT||path.join(directory,'fusion-parser-report.json'),JSON.stringify(report,null,2)+'\n');
