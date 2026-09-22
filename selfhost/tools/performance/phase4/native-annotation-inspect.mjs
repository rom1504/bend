// Record proof-relevant emitted C excerpts; does not rewrite or execute them.
import fs from 'node:fs';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
const [reportFile, output] = process.argv.slice(2);
if (!output || fs.existsSync(output)) throw Error('Usage: native-annotation-inspect.mjs BUILD_REPORT NEW_REPORT');
const hash = f => crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const build = JSON.parse(fs.readFileSync(reportFile)); assert.equal(build.complete, true); assert.equal(hash(build.c.file), build.c.sha256);
const source = fs.readFileSync(build.c.file, 'utf8');
let previousOffset = 0, previousLine = 1;
const cases = [...source.matchAll(/^  WL_CASE\((FID_[A-Z_0-9]+)\)\n[\s\S]*?^#endif/gm)].map(m => {
  previousLine += source.slice(previousOffset, m.index).split('\n').length - 1; previousOffset = m.index;
  return {name: m[1], line: previousLine, text: m[0]};
});
const fork = cases.find(c => c.name.startsWith('FID_AP_FORK2_') && c.text.includes('if (!seq)') && c.text.includes('task_node(e, FID_KA_DEFS_EXCEPT,'));
assert.ok(fork); assert.equal((fork.text.match(/task_node\(e, FID_KA_DEFS_EXCEPT,/g) ?? []).length, 2);
assert.match(fork.text, /context_\d+ = term_keep\(e, context_\d+\)/); assert.match(fork.text, /stops_\d+ = term_keep\(e, stops_\d+\)/);
assert.match(fork.text, /return term_tsk\(FID_AP_FORK2_J\d+,/);
const digestCall = cases.find(c => c.name.startsWith('FID_MAIN_') && c.text.includes('WL_JMP(FID_AP_HASH_DEFS)'));
assert.ok(digestCall);
const digestReturn = cases.find(c => c.line > digestCall.line && /u32 digest_\d+ = r0;/.test(c.text)); assert.ok(digestReturn);
assert.match(digestCall.text, new RegExp(digestReturn.name));
const afterClock = cases.find(c => c.line > digestReturn.line && c.text.includes('term_clo(FID_IO_NOW, 0)')); assert.ok(afterClock);
assert.match(digestReturn.text, new RegExp(afterClock.name));
const definitionLoop = cases.filter(c => c.name.startsWith('FID_KA_DEFS_EXCEPT')).slice(0,2);
assert.ok(definitionLoop.some(c => /book_\d+ = term_keep\(e, book_\d+\)/.test(c.text)));
const report = {kind: 'phase4-native-annotation-c-inspection', complete: true, at: new Date().toISOString(), toolSha256: hash(import.meta.filename), buildReport: {file: reportFile, sha256: hash(reportFile)}, c: build.c, observations: ['Actual two-child join calls unchanged KA_DEFS_EXCEPT workers.', 'Fork retains context and stop roots; workers continue existing owned projections and per-definition context retention.', 'Complete structural hash returns a scalar into the continuation before construction of the second IO.now action. Exact serialization follows the timed region.'], excerpts: {fork, definitionLoop, digestCall, digestReturn, afterClock}, limits: 'Static emitted-code gate only. Correct tree results and actual thread paths require separate native execution gates; no concurrency or speedup is inferred from task construction alone.'};
fs.writeFileSync(output, JSON.stringify(report, null, 2) + '\n'); console.log(JSON.stringify({complete: true, output}));
