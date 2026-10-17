// Measurement adapter only. Input/tool authentication is outside the process clock,
// exactly as for native stages. The runner freezes this manifest before execution.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [manifest, input, prefix] = process.argv.slice(2);
const settings = JSON.parse(fs.readFileSync(manifest, 'utf8'));
const report = {complete: false};
let B;
try {
  const start = performance.now();
  B = await import(pathToFileURL(settings.bend.file));
  const C = await import(pathToFileURL(settings.compiler.file));
  report.importsMs = performance.now() - start;
  const request = performance.now(), book = B.book_nil(), loaded = new Map();
  await B.book_load(book, input, '', loaded);
  B.book_valid(book);
  assert.equal(book.hols, 0);
  const code = C.compile_book(book);
  report.requestMs = performance.now() - request;
  assert.equal(typeof code, 'string');
  assert(code.length > 0);
  fs.writeFileSync(prefix + '.1.c', code, {flag: 'wx'});
  report.loadedFiles = [...loaded.keys()];
  report.checked = true;
  report.holes = book.hols;
  report.complete = true;
} catch (error) {
  report.error = error?.$ === 'Err' ? B.err_show(error) : error.stack ?? String(error);
  process.exitCode = 1;
}
report.maxRssKiB = process.resourceUsage().maxRSS;
fs.writeFileSync(prefix + '.json', JSON.stringify(report, null, 2) + '\n', {flag: 'wx'});
