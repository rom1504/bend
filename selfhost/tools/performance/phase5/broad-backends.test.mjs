import test from 'node:test';import assert from 'node:assert/strict';
import {parseProgress,infrastructureCounts,pairedCoverageComplete} from './broad-backends.mjs';
test('paired coverage refuses adapter drift or unfinished comparison, permits known strict failures',()=>{
 const execution={exitCode:1,error:null,signal:null,timedOut:false,overflow:false};
 const row={observations:2,adapterChangedDuringRun:false,changedInputs:[],changedArtifacts:[],selectedComplete:false};
 const rows={reference:{...row},candidate:{...row}},paired={rows:[{},{}],missing:[],selectedComplete:false};
 assert.equal(pairedCoverageComplete(execution,rows,paired,2),true);
 assert.equal(pairedCoverageComplete(execution,{...rows,candidate:{...row,adapterChangedDuringRun:true}},paired,2),false);
 for(const p of [null,{}, {...paired,error:'comparison failed'}, {...paired,missing:[{}]}, {...paired,rows:[{}]}])assert.equal(pairedCoverageComplete(execution,rows,p,2),false);
 assert.equal(pairedCoverageComplete({...execution,timedOut:true},rows,paired,2),false);
});
test('partial progress counts only valid complete observations and retains fragment facts',()=>{
 const row={id:'case',lane:'native',status:'pass'};
 assert.deepEqual(parseProgress(JSON.stringify(row)+'\n{"id":'),{rows:[row],invalidLines:[],trailingFragmentBytes:6});
 assert.equal(parseProgress(JSON.stringify(row)).rows.length,1);
 const bad=parseProgress('not-json\n'+JSON.stringify(row)+'\n');assert.equal(bad.rows.length,1);assert.equal(bad.invalidLines.length,1);assert.equal(bad.trailingFragmentBytes,0);
 assert.equal(parseProgress('{}\n').rows.length,0);
});
test('infrastructure failures remain distinct from expected compiler rejections and N/A',()=>{
 assert.deepEqual(infrastructureCounts([{status:'pass',result:{status:'error',phase:'parse'}},{status:'fail',result:{status:'error',phase:'check'}},{status:'not-applicable'},{status:'timeout'},{status:'crash'},{status:'unsupported'},{status:'fail',result:{status:'crash'}}]),{crash:2,timeout:1,unsupported:1,'hardware-gated':0});
});
