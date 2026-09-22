// Read-only scheduler metadata evidence; no flag overrides or attribution claim.
import fs from 'node:fs';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
const [buildReport, output] = process.argv.slice(2);
if (!output || fs.existsSync(output)) throw Error('Usage: native-annotation-flags.mjs CHECKED_REPORT NEW_REPORT');
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex'),report=JSON.parse(fs.readFileSync(buildReport));
assert.equal(report.complete,true);assert.equal(sha(report.c.file),report.c.sha256);
const source=fs.readFileSync(report.c.file,'utf8'),ids=Object.fromEntries([...source.matchAll(/^#define (FID_[A-Z_0-9]+) (\d+)$/gm)].map(m=>[m[1],+m[2]]));
const flags=/CONSTV u8 FID_FLAG_T\[\] = \{([^}]+)\}/.exec(source)[1].split(',').map(Number);
const names=['FID_KA_DEFS_EXCEPT','FID_AP_DEFS','FID_AP_HASH_DEFS','FID_AP_PREPARE','FID_AP_FORK2','FID_CLO_APPLY'];
const compiler=report.upstream+'/bend2/comp.ts';assert.equal(sha(compiler),report.upstreamFiles.find(f=>f.file==='bend2/comp.ts').sha256);
const text=fs.readFileSync(compiler,'utf8'),start=text.indexOf('  // A segment may fork when it, or one it reaches, does;'),end=text.indexOf('  table("FID_RESW_T"',start);assert.ok(start>=0&&end>start);
const result={kind:'native-annotation-static-fork-flags',complete:true,at:new Date().toISOString(),toolSha256:sha(import.meta.filename),buildReport:{file:buildReport,sha256:sha(buildReport)},c:report.c,compiler:{file:compiler,sha256:sha(compiler),pin:report.pin},rows:names.map(name=>({name,id:ids[name],flags:flags[ids[name]],markedForkFree:Boolean(flags[ids[name]]&2)})),compilerRule:text.slice(start,end),conclusion:'Pinned closure-apply reachability includes every closure. The real annotation worker and hash/preparation entries are conservatively marked may-fork after the wrapper fork is introduced. This is a static fact and a plausible overhead mechanism, not a measured attribution of all regression. No scheduler metadata was overridden.'};
fs.writeFileSync(output,JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({complete:true,output}));
