// Parse/check only, using unmodified pinned upstream. No emission or execution.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [inputFile, outputDirectory] = process.argv.slice(2);
const config = JSON.parse(fs.readFileSync(inputFile, 'utf8'));
const pin = file => {
  const canonical = fs.realpathSync(file), data = fs.readFileSync(canonical);
  return {file:canonical, sha256:createHash('sha256').update(data).digest('hex'), bytes:data.length};
};
const verify = item => assert.deepEqual(pin(item.file), item);
config.inputs.forEach(verify);
assert.equal(process.execPath, config.node.file);
assert.equal(process.version, config.nodeVersion);
assert.equal(process.env.BEND_BASE, config.base.file);
assert.equal(config.sources.length, new Set(config.sources.map(x => x.file)).size);
const out = path.resolve(outputDirectory);
fs.mkdirSync(out, {recursive:false});
const report = {kind:'phase68-reference-frontend-smoke', complete:false, pass:false,
  config:pin(inputFile), producer:pin(import.meta.filename), inputs:config.inputs,
  scope:'Fresh books, unmodified pinned upstream book_load/book_valid, zero holes. Type acceptance only; unsafe proof trust is not assessed. No compiler emission, Clang, generated program execution or timing claim.', rows:[]};
const save = () => fs.writeFileSync(path.join(out,'report.json'), JSON.stringify(report,null,2)+'\n');
save();
try {
  const B = await import(pathToFileURL(config.module.file));
  for (const source of config.sources) {
    const row = {source, phase:'parse', parsed:false, typeAccepted:false, pass:false};
    try {
      const book = B.book_nil();
      await B.book_load(book,source.file,'',new Map());
      row.parsed = true; row.phase = 'check';
      B.book_valid(book);
      assert.equal(book.hols || 0, 0, 'Unexpected TODO holes');
      row.typeAccepted = true; row.pass = true;
    } catch (error) {
      row.error = error?.$ === 'Err' ? B.err_show(error) : String(error.stack || error);
    }
    report.rows.push(row); save();
  }
  config.inputs.forEach(verify); verify(report.config); verify(report.producer);
  report.complete = report.rows.length === config.sources.length;
  report.pass = report.complete && report.rows.every(row => row.pass);
} catch (error) { report.error = String(error.stack || error); }
save();
console.log(JSON.stringify({complete:report.complete,pass:report.pass,rows:report.rows.length,failed:report.rows.filter(x=>!x.pass).map(x=>x.source.file)}));
if (!report.pass) process.exitCode = 1;
