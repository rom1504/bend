// Independent reference adapter: public pinned upstream APIs, no selfhost compiler.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [specFile, reportFile] = process.argv.slice(2);
assert.ok(specFile && reportFile && process.argv.length === 4, 'upstream.mjs SPEC FRESH_REPORT');
const spec = JSON.parse(fs.readFileSync(specFile, 'utf8'));
const pin = file => { const bytes=fs.readFileSync(file); return {file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')}; };
const verify = row => {const got=pin(row.file);assert.equal(got.bytes,row.bytes);assert.equal(got.sha256,row.sha256,'Changed reference input: '+row.file);};
const report={kind:'bend-benchmark-reference-emission',complete:false,checked:false,spec:pin(specFile),inputs:spec.inputs};
const out=fs.openSync(reportFile,'wx');
try {
  assert.equal(spec.kind,'bend-benchmark-reference-request-v1');
  assert.ok(['js','c'].includes(spec.target));
  for(const row of spec.inputs)verify(row);
  assert.equal(pin(process.execPath).sha256,spec.engine.sha256,'Wrong reference engine');
  for(const name of Object.keys(process.env))if(name.startsWith('BEND_'))delete process.env[name];
  const B=await import(pathToFileURL(spec.bend.file));
  const C=await import(pathToFileURL(spec.comp.file));
  const book=B.book_nil();
  await B.book_load(book,spec.source.file,'',new Map());
  B.book_valid(book);
  assert.equal(book.hols,0,'Unresolved source holes');
  const code=spec.target==='js'?C.js_lib(book,true):C.compile_book(book);
  assert.equal(typeof code,'string');assert.ok(code.length>0);
  for(const row of spec.inputs)verify(row);
  report.checked=report.complete=true;
  report.product={bytes:Buffer.byteLength(code),sha256:crypto.createHash('sha256').update(code).digest('hex')};
  fs.writeSync(1,code);
} catch(error) { report.error=String(error.stack??error);process.exitCode=1; }
finally {fs.writeSync(out,JSON.stringify(report,null,2)+'\n');fs.closeSync(out);}
