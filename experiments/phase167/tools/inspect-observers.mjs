// Diagnostic-only native-plan census. Not a clean performance observation.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
import {pin,verify,items} from '../../phase147/tools/support.mjs';
const [receipt,source,out]=process.argv.slice(2);fs.mkdirSync(out,{recursive:false});
const r=JSON.parse(fs.readFileSync(receipt));assert(r.complete&&r.checked);verify(r.api);const api=(await import(pathToFileURL(r.api.file))).default;
const base='selfhost/.bootstrap/upstream-phase66/bend2/base.bend';
const report={complete:false,inputs:[pin(import.meta.filename),pin(receipt),pin(source),pin(base),r.api],rows:[]};
try{const prep=api.p86_prepare(fs.realpathSync(base),fs.readFileSync(base,'utf8'));assert.equal(prep.$,'P86PreparationReady');
 const plan=api.p86_plan(prep.seed,fs.realpathSync(source),fs.readFileSync(source,'utf8'));assert.equal(plan.$,'P86PlanReady');
 for(const mode of [0]){const lowered=api.p167ob_request(plan.request);assert.equal(lowered.error,'');
  const stats=items(lowered.stats),functions=items(lowered.program.functions),segments=items(lowered.program.original.program.segments);
  report.rows.push({mode,stats,labels:['sourceNames','admittedDirect','fallbackFamilies','demandedFactories','adapters','scheduledSegments','demandedIds','selectedObserverOwners','seedFunctions','remainingSourceNames','rawCandidates','finalFunctions','nonseedAdmitted'],direct:functions.map(x=>x.name),segments:segments.map(x=>({name:x.name,arity:x.arity,incoming:x.incoming}))});}
 report.complete=true;
}catch(e){report.error=String(e.stack??e);process.exitCode=1;}
finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,error:report.error}));}
