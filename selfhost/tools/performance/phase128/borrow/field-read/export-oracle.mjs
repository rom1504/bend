// Write the checked Bend emitter's ABI fixture verbatim; no host lowering.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [receipt, directory] = process.argv.slice(2);
const pin = file => {file=path.resolve(file); const b=fs.readFileSync(file); return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const verify = row => {const actual=pin(row.file); if(actual.bytes!==row.bytes || actual.sha256!==row.sha256) throw Error('Changed '+row.file);};
const r=JSON.parse(fs.readFileSync(receipt));
if(!r.complete || !r.checked || !r.exports.includes('p128bf_oracle_module')) throw Error('Checked oracle export required');
for(const x of [...r.inputs,r.api]) verify(x);
const out=path.resolve(directory); if(fs.existsSync(out)) throw Error('Fresh output required');
const api=(await import(pathToFileURL(r.api.file))).default;
const text=api.p128bf_oracle_module(); if(typeof text!=='string') throw Error('Expected QBE string');
fs.mkdirSync(out,{recursive:true}); fs.writeFileSync(path.join(out,'program.ssa'),text,{flag:'wx'});
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:true,api:r.api,inputs:[pin(import.meta.filename),pin(receipt),...r.inputs],product:pin(path.join(out,'program.ssa')),scope:'Verbatim checked Bend ABI fixture export. No machine execution or production qualification.'},null,2)+'\n');
