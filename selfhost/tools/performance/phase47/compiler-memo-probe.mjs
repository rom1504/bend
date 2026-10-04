// Producer only: save baseline and request-local completed-Boolean counterfactual.
// Compiler requests and generated-target execution belong to the coordinator.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {verifyAttempt} from '../../development/workflow.mjs';

const [attemptArg,sourceArg,inventoryArg,outArg]=process.argv.slice(2);
assert(attemptArg&&sourceArg&&inventoryArg&&outArg,
  'usage: compiler-memo-probe.mjs CHECKED_WORKER23 SOURCE_BEND SOURCE_OBSERVATION_JSON NEW_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out),'output must be fresh');
const hash=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(file),bytes:fs.statSync(file).size});
const attemptPath=fs.realpathSync(attemptArg),source=fs.realpathSync(sourceArg);
const attempt=await verifyAttempt(attemptPath);
const pins={api:'e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c',
  runtime:'4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26',
  base:'c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661'};
for(const key of Object.keys(pins))assert.equal(hash(attempt[key].file),pins[key],`exact worker23 ${key}`);
const original=fs.readFileSync(attempt.api.file,'utf8');
const pureAnchor='function $j_pure_type$(_book_0, _ty_0) {\n  return $j_region_local_ok$(run_loop($j_pure_type_check$(_book_0, _ty_0, {$: "Nil"}, 512)));\n}';
const booleanAnchor='function $j_region_local_ok$(_result_0) {\n  if (_result_0.$ === "Some") {\n    return true;\n  } else {\n    return false;\n  }\n}';
for(const anchor of [pureAnchor,booleanAnchor])assert.equal(original.split(anchor).length-1,1,'exact completed-Boolean anchor');

// The earlier real request provides source discovery, not a cache correctness proof.
const prior=JSON.parse(fs.readFileSync(inventoryArg,'utf8'));
assert.equal(prior.complete,true);assert.equal(prior.observation?.status,'ok');
assert.equal(fs.realpathSync(prior.input),source);
assert(Array.isArray(prior.observation.files)&&prior.observation.files.length>0,'successful source inventory required');
const sourceFiles=prior.observation.files.map(f=>fs.realpathSync(f));
const baseCanonical=fs.realpathSync(attempt.base.file),foreignFiles=new Set();
assert.equal(new Set(sourceFiles).size,sourceFiles.length);assert(sourceFiles.includes(source));
assert(sourceFiles.includes(fs.realpathSync(attempt.base.file)),'Base must appear in source inventory');
for(const f of sourceFiles){
  const old=prior.inputs?.find(i=>i.file===f);
  if(old)assert.equal(hash(f),old.sha256,'changed prior source '+f);
  // The exact pinned Base declares native files, even when the lexer never uses them.
  // Freeze all of them conservatively; refuse non-Base foreign sources for now.
  const text=fs.readFileSync(f,'utf8');
  const quoted=[...text.matchAll(/\bimport\s*(?:#[^\n]*(?:\n|$)\s*)*["']/g)];
  if(f===baseCanonical){
    const rows=[...text.matchAll(/^\s*import\s+"([^"\\]+)"\s*$/gm)];
    assert.equal(rows.length,quoted.length,'all pinned Base quoted imports inventoried');
    for(const [,name] of rows)foreignFiles.add(fs.realpathSync(path.resolve(path.dirname(f),name)));
  }else assert.equal(quoted.length,0,'non-Base foreign inventory unsupported by this narrow producer');
}
const driver=fs.realpathSync(new URL('../../typed-driver.mjs',import.meta.url));
const producer=fs.realpathSync(import.meta.filename);
const hostFiles=new Set();
function hostClosure(file){
  file=fs.realpathSync(file);if(hostFiles.has(file))return;hostFiles.add(file);
  const text=fs.readFileSync(file,'utf8');
  const imports=[...text.matchAll(/(?:\bfrom\s*|\bimport\s*\(\s*|\bimport\s*)['"]([^'"]+)['"]/g)];
  for(const [,specifier] of imports)if(specifier.startsWith('.'))hostClosure(path.resolve(path.dirname(file),specifier));
}
hostClosure(driver);hostClosure(producer);
for(const f of foreignFiles)if(f.endsWith('.js')||f.endsWith('.mjs'))hostClosure(f);
const equalityHelper=path.join(attempt.snapshot.root,'tools/development/equality.mjs');
hostClosure(equalityHelper);
const compilerConfig=fs.realpathSync(new URL('../../../src/compiler.json',import.meta.url));
const inputPaths=[attempt.api.file,attempt.runtime.file,attempt.base.file,path.join(attemptPath,'attempt.json'),
  attempt.checkedApi.file,attempt.bootstrapReport.file,attempt.derivationReport.file,
  inventoryArg,producer,compilerConfig,...attempt.snapshot.sources.map(r=>r.frozen.file),...sourceFiles,...foreignFiles,...hostFiles];
const inputs=[...new Set(inputPaths.map(f=>fs.realpathSync(f)))].map(identity);
fs.mkdirSync(out);fs.mkdirSync(path.join(out,'snapshots'));
for(const [n,input] of inputs.entries()){
  const snapshot=path.join(out,'snapshots',String(n).padStart(3,'0')+'-'+path.basename(input.file));
  fs.copyFileSync(input.file,snapshot,fs.constants.COPYFILE_EXCL);
  assert.equal(hash(snapshot),input.sha256);input.snapshot=identity(snapshot);
}
const variants={baseline:path.join(out,'api-baseline.mjs'),memo:path.join(out,'api-memo.mjs'),
  'memo-count':path.join(out,'api-memo-count.mjs')};
fs.writeFileSync(variants.baseline,original,{flag:'wx'});
assert.equal(hash(variants.baseline),pins.api,'baseline must be byte-identical');
function overlay(counted){
  return `\n// Phase47 diagnostic only: exact outer Nil/512 query, completed Boolean results.\nlet $p47Memo=null,$p47Entries=0;${counted?'let $p47Stats=null;':''}\nconst $p47OriginalPureType=$j_pure_type$;\nexport function phase47BeginMemoRequest(){if($p47Memo!==null)throw Error('memo request already active');$p47Memo=new WeakMap();$p47Entries=0;${counted?'$p47Stats={calls:0,hits:0,misses:0,stored:0,nonObject:0,nonBoolean:0,exceptions:0,saturated:0};':''}}\nexport function phase47EndMemoRequest(){const result=${counted?'$p47Stats':'null'};$p47Memo=null;$p47Entries=0;${counted?'$p47Stats=null;':''}return result;}\n$j_pure_type$=function(book,ty){\n  if($p47Memo===null)return $p47OriginalPureType(book,ty);\n  ${counted?'$p47Stats.calls++;':''}\n  if(book===null||ty===null||typeof book!=='object'||typeof ty!=='object'){${counted?'$p47Stats.nonObject++;':''}return $p47OriginalPureType(book,ty);}\n  let types=$p47Memo.get(book);\n  if(types&&types.has(ty)){${counted?'$p47Stats.hits++;':''}return types.get(ty);}\n  ${counted?'$p47Stats.misses++;':''}\n  let result;${counted?'try{result=$p47OriginalPureType(book,ty);}catch(error){$p47Stats.exceptions++;throw error;}':'result=$p47OriginalPureType(book,ty);'}\n  // No run_loop/force here: pending messages, objects and exceptions never enter the cache.\n  if(typeof result==='boolean'&&$p47Entries<40000){if(!types){types=new WeakMap();$p47Memo.set(book,types);}types.set(ty,result);$p47Entries++;${counted?'$p47Stats.stored++;':''}}\n  ${counted?"else if(typeof result!=='boolean')$p47Stats.nonBoolean++;else $p47Stats.saturated++;":''}\n  return result;\n};\n`;
}
fs.writeFileSync(variants.memo,original+overlay(false),{flag:'wx'});
fs.writeFileSync(variants['memo-count'],original+overlay(true),{flag:'wx'});
const data={kind:'phase47-compiler-memo-derivation',complete:true,diagnosticOnly:true,
  attempt:attemptPath,node:attempt.node,pins,input:source,sourceFiles,foreignFiles:[...foreignFiles],inputs,
  variants:Object.fromEntries(Object.entries(variants).map(([k,f])=>[k,identity(f)])),
  protocol:{query:'j_pure_type raw book/type; fixed active Nil and fuel 512',result:'completed JS Boolean only',
    scope:'reset for each inspect call; immutable compiler-owned raw objects only',limit:40000,
    cleanVariant:'memo contains no hit/miss/stat counters; capacity accounting remains',
    unsupported:'public raw graphs, structural equality, inner fuel/active queries, persistence, target execution'},
  sourceInventory:'Earlier successful observation.files supplies discovery; current hashes and fresh result.files close the request. All pinned Base foreign paths frozen; non-Base quoted imports conservatively refused.'};

const runner=`import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [variant,mode,report,compareFile]=process.argv.slice(2);
assert(['baseline','memo','memo-count'].includes(variant));
assert(['parse','check','library','prime'].includes(mode));
assert(report&&!fs.existsSync(report),'fresh report required');
const data=JSON.parse(fs.readFileSync(new URL('./derive.json',import.meta.url),'utf8'));
const hash=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex');
function verify(){
  assert.equal(process.execPath,data.node.file);assert.equal(process.version,data.node.version);
  assert.equal(hash(data.node.file),data.node.sha256);
  for(const row of data.inputs){assert.equal(hash(row.file),row.sha256);assert.equal(hash(row.snapshot.file),row.snapshot.sha256);}
  for(const row of Object.values(data.variants))assert.equal(hash(row.file),row.sha256);
  assert.equal(hash(import.meta.filename),data.runner.sha256);
}
verify();
process.env.BEND_TYPED_API=data.variants[variant].file;
process.env.BEND_TYPED_RUNTIME=${JSON.stringify(attempt.runtime.file)};
process.env.BEND_BASE=${JSON.stringify(attempt.base.file)};
let start=performance.now();
const namespace=await import(pathToFileURL(data.variants[variant].file));
const apiImportMs=performance.now()-start;
start=performance.now();
const {inspect,loadApi,prepareBase}=await import(pathToFileURL(${JSON.stringify(driver)}));
const driverImportMs=performance.now()-start;
start=performance.now();const api=await loadApi();const apiAdapterMs=performance.now()-start;
const stages=Object.create(null);
const wrapped=new Proxy(api,{get(target,key){
  const value=target[key];if(typeof value!=='function')return value;
  return(...args)=>{const begin=performance.now();try{return value(...args);}finally{
    const row=stages[key]??={calls:0,publicCallMs:0};row.calls++;
    row.publicCallMs+=performance.now()-begin;
  }};
}});
let result,exception=null,stats=null,requestMs;
if(variant!=='baseline')namespace.phase47BeginMemoRequest();
start=performance.now();
try{
  if(mode==='prime'){await prepareBase(wrapped);result={status:'ok',phase:'prime',checked:true};}
  else result=await inspect(data.input,{mode,api:wrapped});
}catch(error){exception={name:error.name,message:error.message,stack:error.stack};}
finally{requestMs=performance.now()-start;if(variant!=='baseline')stats=namespace.phase47EndMemoRequest();}
const observation=result?{...result}:null;
const code=observation?.code;if(observation)delete observation.code;
const outputSha256=code===undefined?null:createHash('sha256').update(code).digest('hex');
let stableInputs=true,inputError=null;
try{verify();if(mode!=='prime'&&result?.status==='ok')assert.deepEqual(result.files.map(f=>fs.realpathSync(f)),data.sourceFiles);}
catch(error){stableInputs=false;inputError=error.message;}
const sameKeys=r=>({observation:r.observation,outputSha256:r.outputSha256,outputBytes:r.outputBytes});
const r={kind:'phase47-compiler-memo-request',complete:!exception&&stableInputs&&result?.status==='ok',
  diagnosticOnly:true,variant,mode,input:data.input,attempt:data.attempt,selectedApiSha256:data.pins.api,
  derivedApi:data.variants[variant],derivationSha256:hash(new URL('./derive.json',import.meta.url)),
  inputs:data.inputs,node:data.node,observation,outputSha256,outputBytes:code===undefined?null:Buffer.byteLength(code),
  requestMs,apiImportMs,driverImportMs,apiAdapterMs,publicStages:stages,memoStats:stats,
  maxRssKiB:process.resourceUsage().maxRSS,stableInputs,inputError,exception,
  cachePolicy:'Each API variant has its own driver Base-cache identity. Prime each variant separately; fresh-process requests reset memo state. Imports excluded from requestMs. No target execution.',comparison:null};
if(compareFile){
  try{
    const b=JSON.parse(fs.readFileSync(compareFile,'utf8'));
    assert.equal(b.variant,'baseline');assert.equal(b.complete,true);assert.equal(b.mode,mode);
    assert.equal(b.selectedApiSha256,r.selectedApiSha256);assert.equal(b.input,r.input);
    assert.deepEqual(b.inputs,r.inputs);assert.equal(b.derivationSha256,r.derivationSha256);
    const exact=JSON.stringify(sameKeys(b))===JSON.stringify(sameKeys(r));
    r.comparison={baseline:compareFile,baselineSha256:hash(compareFile),exact};r.complete&&=exact;
  }catch(error){r.comparison={baseline:compareFile,exact:false,error:error.message};r.complete=false;}
}
fs.writeFileSync(report,JSON.stringify(r,null,2)+'\\n',{flag:'wx'});
console.log(JSON.stringify({complete:r.complete,variant,mode,requestMs,outputSha256,memoStats:stats,comparison:r.comparison}));
if(!r.complete)process.exitCode=1;
`;
const runnerFile=path.join(out,'run-memo.mjs');fs.writeFileSync(runnerFile,runner,{flag:'wx'});
data.runner=identity(runnerFile);
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(data,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,diagnosticOnly:true,out,runner:runnerFile,variants}));
