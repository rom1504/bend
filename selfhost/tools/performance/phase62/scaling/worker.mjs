// Ordinary first compilation; synthetic semantic checks stay outside timing.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const verify=item=>assert.equal(identity(item.file).sha256,item.sha256,item.file);
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const [requestFile,resultFile]=process.argv.slice(2);
assert(requestFile&&resultFile&&!fs.existsSync(resultFile));
const request=read(requestFile);verify(request.plan);const plan=read(request.plan.file);
const report={kind:'phase62-synthetic-scaling-worker',complete:false,pass:false,
  request:identity(requestFile),plan:request.plan,role:request.role,case:request.case,
  affinity:fs.readFileSync('/proc/self/status','utf8').split('\n').find(x=>x.startsWith('Cpus_allowed_list:'))};
const started=performance.now();
try {
  assert.equal(plan.kind,'phase62-synthetic-scaling-plan');
  assert(plan.roles.includes(request.role));
  assert.equal(fs.realpathSync(process.execPath),plan.node.file);
  assert.deepEqual(process.execArgv,plan.execArgv);
  assert.equal(process.env.NODE_OPTIONS??'','');
  assert.equal(report.affinity.split(':',2)[1].trim(),'3');
  plan.inputs.forEach(verify);
  const row=plan.cases.find(x=>x.id===request.case);assert(row);verify(row.source);
  const preparation=plan.preparations[request.role];verify(preparation);
  const prep=read(preparation.file);assert(prep.complete&&prep.pass&&prep.role===request.role);
  report.preparation=preparation;report.image=prep.image??null;report.source=row.source;
  let D,B,C;
  const importStart=performance.now();
  if(request.role==='typescript') {
    B=await import(pathToFileURL(path.join(plan.upstream,'bend2/bend.ts')));
    C=await import(pathToFileURL(path.join(plan.upstream,'bend2/comp.ts')));
  } else {
    for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
    process.env.BEND_TYPED_API=prep.image.api.file;
    process.env.BEND_TYPED_RUNTIME=prep.image.runtime.file;
    process.env.BEND_BASE=prep.image.base.file;
    D=await import(pathToFileURL(prep.image.driver.file));
    assert.equal(D.apiPath,prep.image.api.file);
    assert.equal(D.directRuntimePath,prep.image.directRuntime.file);
  }
  report.hostImportMs=performance.now()-importStart;
  const apiStart=performance.now();
  if(D)await D.loadApi();
  report.apiLoadMs=D?performance.now()-apiStart:0;
  async function compile() {
    if(B) {
      const book=B.book_nil();await B.book_load(book,row.source.file,'',new Map());B.book_valid(book);
      assert.equal(book.hols,0);return {code:C.js_lib(book,true),checked:true};
    }
    const result=await D.inspect(row.source.file,{mode:'library',backend:'direct'});
    assert.equal(result.status,'ok');assert.equal(result.checked,true);
    assert.equal(result.backend,'direct');assert.equal(result.interface,'upstream-callable');
    return result;
  }
  let first;
  const begin=performance.now();
  try {first=await compile()}finally{report.firstRequestMs=performance.now()-begin}
  report.importApiAndFirstMs=report.hostImportMs+report.apiLoadMs+report.firstRequestMs;
  assert.equal(typeof first.code,'string');assert(first.code.length);
  report.warmRequests=[];
  for(let index=0;index<plan.warmRequests;index++) {
    const begin=performance.now(),next=await compile(),requestMs=performance.now()-begin;
    assert.equal(next.code,first.code,'Repeated request output changed');
    report.warmRequests.push({index,requestMs});
  }
  // All first/repeated request clocks end before code import and exact runtime oracles.
  fs.writeFileSync(request.output,first.code,{flag:'wx'});
  report.output={...identity(request.output),bytes:Buffer.byteLength(first.code)};
  const module=(await import(pathToFileURL(request.output))).default;
  assert(module&&typeof module==='object');
  report.oracles=[];
  for(const point of row.points) {
    assert.equal(typeof module[point.exportName],'function',point.exportName);
    const actual=module[point.exportName](...point.args);
    assert.equal(actual,point.expected,point.exportName);
    report.oracles.push({...point,actual,pass:true});
  }
  report.checked=true;report.freshRuntimeExecutions=row.points.length;
  report.scope='Clean first compile of a generated synthetic source; every fixture export checked against an independent numeric oracle after clocks. No cross-compiler raw-byte equality requirement.';
  plan.inputs.forEach(verify);verify(row.source);verify(preparation);verify(request.plan);
  report.complete=report.pass=true;
} catch(error) {report.error=String(error?.stack??error);process.exitCode=1;}
finally {
  report.workerElapsedMs=performance.now()-started;report.maxRssKiB=process.resourceUsage().maxRSS;
  fs.writeFileSync(resultFile,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
  console.log(JSON.stringify({complete:report.complete,pass:report.pass,role:report.role,case:report.case,error:report.error}));
}
