// Run only under the root's outer guard. Frozen native entry, original sources.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
const [planFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
assert.ok(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const plan=JSON.parse(fs.readFileSync(planFile,'utf8'));
const report={kind:'phase92-native-rejection-observations',complete:false,passed:false,
  sourceChanged:false,rows:[],scope:'Three original rejection controls per native image. No parse-only/check-only API or rich error-page qualification.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
function diagnostic(stderr) {
  // Remove only the exact leading native entry telemetry protocol, never text
  // inside the diagnostic. Keep every raw byte in each captured observation.
  return stderr.replace(/^base_prepare_ms=\d+\nruntime_prepare_ms=\d+\nrequest=1 request_ms=\d+ consumed_chars=\d+\n/,'');
}
try {
  for(const role of ['b1','b2']) {
    process.env.BEND_NATIVE_CONFORMANCE_PLAN=path.resolve(planFile);
    process.env.BEND_NATIVE_CONFORMANCE_ROLE=role;
    const adapter=await import('./conformance-adapter.mjs?diagnosticRole='+role);
    report.method=adapter.pin(import.meta.filename);report.plan=adapter.pin(planFile);
    for(let i=0;i<plan.negatives.length;i++) {
      const fixture=plan.negatives[i],dir=path.join(out,role+'-'+i);fs.mkdirSync(dir);
      const result=adapter.compileNative(fixture.source.file,dir,15000);
      const text=diagnostic(result.job.stderr),prefix=fixture.expectedPhase+': ';
      const row={id:fixture.id,role,...result,diagnostic:text,
        passed:result.job.status===1&&!result.job.error&&!result.job.signal&&!result.job.oversized&&
          result.job.stdout===''&&result.outputAbsent&&text.startsWith(prefix)};
      if(fixture.historicalStderr!==undefined) {
        row.exactHistoricalNativeDiagnostic=text===diagnostic(fixture.historicalStderr);
        row.passed&&=row.exactHistoricalNativeDiagnostic;
      }
      if(fixture.expectedConcise!==undefined) {
        row.exactExpectedConcise=text===prefix+fixture.expectedConcise+'\n';
        row.passed&&=row.exactExpectedConcise;
        row.historicalJS={fullLength:fixture.historicalJS.before.length,
          fallbackLength:fixture.historicalJS.after.length,
          equalWholeFullPage:text.trim()===fixture.historicalJS.before,
          equalWholeFallback:text.trim()===fixture.historicalJS.after,
          equalFallbackCheckerPayload:fixture.historicalJS.after==='SOME PROOFS FAIL\nError: '+fixture.expectedConcise};
        row.limitation=fixture.limitation;
      }
      report.rows.push(row);save();
    }
    adapter.verifyInputs();
  }
  report.crossRole=plan.negatives.map(f=>{
    const [a,b]=report.rows.filter(r=>r.id===f.id);
    return {id:f.id,exactDiagnostic:a.diagnostic===b.diagnostic,
      exactCompilerExit:a.job.status===b.job.status,bothOutputAbsent:a.outputAbsent&&b.outputAbsent};
  });
  report.complete=true;report.inputsUnchanged=true;
  report.passed=report.rows.every(r=>r.passed)&&report.crossRole.every(r=>r.exactDiagnostic&&r.exactCompilerExit&&r.bothOutputAbsent);
} catch(error) {report.error=error.stack||String(error);}
save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,observations:report.rows.length,out}));
if(!report.passed)process.exitCode=1;
