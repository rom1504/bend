// Data-only saved-compiler derivation. Root separately schedules the emitted runner.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {verifyAttempt} from '../../development/workflow.mjs';

const [attemptArg,expectedArg,outArg]=process.argv.slice(2);
assert(attemptArg&&expectedArg&&outArg,'array-admission-probe-v2.mjs ATTEMPT EXPECTED_MODULE NEW_OUT');
const identity=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex'),bytes:fs.statSync(file).size});
const out=path.resolve(outArg);assert(!fs.existsSync(out));
const attempt=await verifyAttempt(path.resolve(attemptArg));
assert.equal(attempt.api.sha256,'f9cfc861081f70e1f9ee6054b938cc3ebbec060e7451c16f3a8d47d66fc9f5a4');
const expected=identity(expectedArg),receiptId=identity(expectedArg+'.json');
assert.equal(expected.sha256,'2c5335baaff3248bcde0c618ef4567704bf7c9963b1529ba16fd5c56c0779fe5');
const receipt=JSON.parse(fs.readFileSync(receiptId.file,'utf8'));
assert.equal(receipt.kind,'bend-program-checked-emission');assert(receipt.complete&&receipt.observation.checked);
assert.equal(receipt.observation.status,'ok');assert.equal(receipt.output.sha256,expected.sha256);
assert.equal(receipt.compiler.api.sha256,attempt.api.sha256);
assert.equal(receipt.compiler.runtime.sha256,attempt.runtime.sha256);
const input=identity(receipt.input.file??receipt.input.canonicalPath);
assert.equal(input.sha256,receipt.input.sha256);
const driver=identity(receipt.compiler.driver.file??receipt.compiler.driver.canonicalPath);
assert.equal(driver.sha256,receipt.compiler.driver.sha256);
const apiText=fs.readFileSync(attempt.api.file,'utf8');assert(!apiText.includes('$p47ArrayAdmission'));
const names=['j_array_view_plan','j_array_view_helpers','j_array_view_node','j_array_view_app','j_array_view_native_app'];
for(const name of names)assert.equal(apiText.split('function $'+name+'$(').length,2,'Exact unique binding '+name);
const inputs=[identity(import.meta.filename),identity(attempt.api.file),identity(attempt.runtime.file),identity(attempt.base.file),
  identity(path.join(attemptArg,'attempt.json')),expected,receiptId,input,driver,
  identity(path.join(path.dirname(driver.file),'compiler-abi.mjs'))];
let overlay=`
// Diagnostic only: completed results add native frames and are excluded from timing.
const $p47ArrayAdmission={plans:[],falseNodes:[],falseApps:[],nativeApps:[],helpers:[],dropped:0};
let $p47Root='', $p47Helper='';
function $p47Add(key,row){if($p47ArrayAdmission[key].length<128)$p47ArrayAdmission[key].push(row);else $p47ArrayAdmission.dropped++;}
const $p47OldPlan=$j_array_view_plan$;
$j_array_view_plan$=function(book,d,s){const previous=$p47Root;$p47Root=$dn$(d);try{
  const value=run_loop($p47OldPlan(book,d,s));
  $p47Add('plans',{root:$p47Root,value,valid:$j_region_valid$(s),signature:run_loop($j_region_signature$(book,$dt$(d),$da$(d))),
    hasNew:$dk$(run_loop($lookup$($j_region_helpers$(s),'Array.new')))==='Def'});return value;
}finally{$p47Root=previous;}};
const $p47OldHelpers=$j_array_view_helpers$;
$j_array_view_helpers$=function(book,helpers,todo){const previous=$p47Helper;
  if(todo.$==='Con')$p47Helper=$dn$(todo.head);
  try{const value=run_loop($p47OldHelpers(book,helpers,todo));if(todo.$==='Con')
    $p47Add('helpers',{root:$p47Root,helper:$p47Helper,native:$db$(todo.head),tag:$tg$($dv$(todo.head)),suffixResult:value});return value;
  }finally{$p47Helper=previous;}};
const $p47OldNode=$j_array_view_node$;
$j_array_view_node$=function(book,helpers,t,rest,fuel,tag){const value=run_loop($p47OldNode(book,helpers,t,rest,fuel,tag));
  if(value===false)$p47Add('falseNodes',{root:$p47Root,helper:$p47Helper,tag,name:$nm$(t),fuel,remaining:rest.$,
    note:'Completed node plus pending worklist result; ancestors of a later rejection also report false.'});return value;};
const $p47OldApp=$j_array_view_app$;
$j_array_view_app$=function(book,helpers,spine,rest,fuel){const value=run_loop($p47OldApp(book,helpers,spine,rest,fuel));
  if(value===false){const name=$nm$(spine),target=run_loop($lookup$(helpers,name));
    $p47Add('falseApps',{root:$p47Root,helper:$p47Helper,tag:$tg$(spine),name,fuel,
      primitive:run_loop($j_primitive_call$(book,spine)),targetKind:$dk$(target),targetNative:$db$(target),targetTag:$tg$($dv$(target))});}return value;};
const $p47OldNativeApp=$j_array_view_native_app$;
$j_array_view_native_app$=function(book,helpers,spine){const value=run_loop($p47OldNativeApp(book,helpers,spine));
  const name=$nm$(spine);
  if(['Array.new','Array.get','Array.set'].includes(name)){
    const helper=run_loop($lookup$(helpers,name)),target=run_loop($lookup$(book,name));
    const element=$kid$(spine,0),head=run_loop($wnf$(book,$dt$(target)));
    $p47Add('nativeApps',{root:$p47Root,helper:$p47Helper,name,result:value,tag:$tg$(spine),
      arity:run_loop($terms_len$($ks$(spine))),helperKind:$dk$(helper),helperNative:$db$(helper),
      localNative:run_loop($j_region_local_native$(book,spine)),
      element:{tag:$tg$(element),name:$nm$(element),u32:run_loop($j_primitive_type$(book,run_loop($wnf$(book,element)),'U32'))},
      target:{kind:$dk$(target),native:$db$(target),arity:$da$(target),erased:$dx$(target),body:$tg$(run_loop($j_strip$($dv$(target)))),typeTag:$tg$(head),typeQuantity:$qt$(head)}});
  }return value;};
export function phase47ArrayAdmission(){return $p47ArrayAdmission;}
`;
fs.mkdirSync(out);
const diagnostic=path.join(out,'api-admission.mjs');fs.writeFileSync(diagnostic,apiText+overlay,{flag:'wx'});
const frozen=[...inputs,identity(diagnostic)];
const runner=`import fs from 'node:fs';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [report]=process.argv.slice(2);assert(report&&!fs.existsSync(report));
const frozen=${JSON.stringify(frozen)};const hash=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex');
for(const x of frozen)assert.equal(hash(x.file),x.sha256);
for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
process.env.BEND_TYPED_API=${JSON.stringify(diagnostic)};process.env.BEND_TYPED_RUNTIME=${JSON.stringify(attempt.runtime.file)};process.env.BEND_BASE=${JSON.stringify(attempt.base.file)};
const probe=await import(pathToFileURL(${JSON.stringify(diagnostic)}));
const D=await import(pathToFileURL(${JSON.stringify(driver.file)}));
const r={kind:'phase47-array-admission-diagnostic',diagnosticVersion:2,complete:false,pass:false,diagnosticOnly:true,inputs:frozen,
  scope:'One checked library emission; completed-result logging changes stack behavior and is never timing evidence.'};
try{const result=await D.inspect(${JSON.stringify(input.file)},{mode:'library'});const {code,...observation}=result;
  r.observation=observation;assert.equal(result.status,'ok');assert.equal(result.checked,true);
  r.outputSha256=createHash('sha256').update(code).digest('hex');r.outputBytes=Buffer.byteLength(code);
  assert.equal(r.outputSha256,${JSON.stringify(expected.sha256)},'Diagnostic changed emitted bytes');
  for(const x of frozen)assert.equal(hash(x.file),x.sha256);r.complete=r.pass=true;
}catch(error){r.error=error.stack;process.exitCode=1;}
r.admission=probe.phase47ArrayAdmission();fs.writeFileSync(report,JSON.stringify(r,null,2)+'\\n',{flag:'wx'});
console.log(JSON.stringify({complete:r.complete,pass:r.pass,outputSha256:r.outputSha256,admission:r.admission,error:r.error}));
`;
const runnerFile=path.join(out,'run-admission.mjs');fs.writeFileSync(runnerFile,runner,{flag:'wx'});
for(const item of inputs)assert.deepEqual(identity(item.file),item);
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify({kind:'phase47-array-admission-derivation',diagnosticVersion:2,complete:true,
  diagnosticOnly:true,compilerExecuted:false,inputs,bindings:names,outputs:[identity(diagnostic),identity(runnerFile)],
  expectedOutput:expected,scope:'Exact checked-array03 API overlay; native App predicate subfacts included; bounded128 records per category; root owns execution.'},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,diagnostic,runner:runnerFile,executed:false}));
