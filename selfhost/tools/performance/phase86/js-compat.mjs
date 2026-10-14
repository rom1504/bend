// IO-program analogue of the reviewed B1 primitive String equality guard.
// Preserve raw upstream output and identify this derivative separately.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [buildArg,outArg]=process.argv.slice(2),build=path.resolve(buildArg),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const hash=s=>createHash('sha256').update(s).digest('hex');
const report=JSON.parse(fs.readFileSync(path.join(build,'report.json')));
assert(report.complete&&report.upstream==='059266225b77c8ca256ac6b25ee5c21449bab151');
const source=fs.readFileSync(report.js.file,'utf8');assert.equal(hash(source),report.js.sha256);
const old='function $String$eq$(_a_0, _b_0) {\n  return $Cmp$is_eq$(($String$order$(_a_0, _b_0)));\n}';
assert.equal(source.split(old).length,2);
const guard='  if (typeof _a_0 === "string" && typeof _b_0 === "string") return _a_0 === _b_0;\n';
const transformed=source.replace(old,old.replace('\n','\n'+guard));
const output=path.join(out,'compiler.cjs');fs.writeFileSync(output,transformed,{flag:'wx'});
const catchOld='throw e instanceof RangeError ? "bend: memory fault (machine stack overflow?)" : e;';
assert.equal(source.split(catchOld).length,2);assert.equal(source.split('io_errs(String(e));').length,2);
fs.writeFileSync(path.join(out,'diagnostic.cjs'),source.replace(catchOld,'throw e;').replace('io_errs(String(e));','io_errs(e.stack ?? String(e));'),{flag:'wx'});
fs.writeFileSync(path.join(out,'derivation.json'),JSON.stringify({kind:'phase86-io-program-equality-only',parent:report.js,
  parentBuildSha256:hash(fs.readFileSync(path.join(build,'report.json'))),methodSha256:hash(fs.readFileSync(import.meta.filename)),
  output:{file:output,sha256:hash(transformed)},old,guard,
  scope:'Same primitive-string equality guard as checked B1 profile7. Compiler-owned well-formed Unicode strings under standard JS builtins; retain original fallback. No literal-choice rewrite, changed compiler algorithms, new bootstrap provenance, or raw-upstream-JS performance claim.'},null,2)+'\n');
console.log(output);
