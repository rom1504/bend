// Data-only cache admission and closed-file audit; imports no compiler or driver.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import vm from 'node:vm';
import assert from 'node:assert/strict';

const root=path.resolve(import.meta.dirname,'../../../..');
const raw=path.join(root,'selfhost/build/phase54');
const out=path.join(root,'selfhost/build/phase55');
const cacheOut=path.join(out,'closed-baseline-cache-admission.json');
const inventoryOut=path.join(out,'closed-phase54-inventory-before-native.json');
assert(!fs.existsSync(cacheOut)&&!fs.existsSync(inventoryOut));
const digest=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const identity=file=>({file:fs.realpathSync(file),bytes:fs.statSync(file).size,sha256:digest(fs.readFileSync(file))});
const inputs=[];
const pin=(file,expected)=>{const row=identity(file);if(expected)assert.equal(row.sha256,expected);inputs.push(row);return row;};
const save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n',{flag:'wx'});
const producer=pin(import.meta.filename);
const attemptFile=path.join(raw,'checked-graph02/attempt.json');
const attemptPin=pin(attemptFile,'594381ea67444070290efeb516458997c528829f9cd4b65385109afc2d0d4a76');
const attempt=JSON.parse(fs.readFileSync(attemptFile));assert(attempt.checked);
const snapshot=attempt.snapshot.root;
const driverFile=path.join(snapshot,'tools/typed-driver.mjs');
const driver=fs.readFileSync(driverFile,'utf8');
const frozen=attempt.snapshot.sources.find(row=>row.frozen.file===driverFile).frozen;
const driverPin=pin(driverFile,frozen.sha256);
const apiPin=pin(attempt.api.file,attempt.api.sha256),basePin=pin(attempt.base.file,attempt.base.sha256);
const apiText=fs.readFileSync(apiPin.file,'utf8');
// These are static constant-function and public-export checks, not API calls.
for(const [name,value]of [['compiler_term_abi',1],['compiler_span_abi',3]]){
 const declaration=`function $${name}$() {\n  return ${value};\n}`;
 assert.equal(apiText.split(declaration).length-1,1);
 assert(apiText.includes(`"${name}": run_lib(() => { const r = (run_loop($${name}$()));  return r; }, 0)`));
}
const first=driver.indexOf('const SPAN_ABI=3,SPAN_CACHE=4,TERM_CACHE=6,U32_MAX=0xffffffff;');
const end=driver.indexOf('\nexport function discoverSources',first);
assert(first>=0&&end>first);
const spans=driver.slice(first,end).replaceAll('export function ','function ');
const infoStart=driver.indexOf('function baseCacheInfo(api) {');
const infoEnd=driver.indexOf('\n// Only persistent inspectors',infoStart);
const readStart=driver.indexOf('function readBaseCache(info,memo=null) {');
const readEnd=driver.indexOf('\nexport async function prepareBase(api)',readStart);
assert(infoStart>=0&&infoEnd>infoStart&&readStart>=0&&readEnd>readStart);
const infoCode=driver.slice(infoStart,infoEnd),readCode=driver.slice(readStart,readEnd);
// Only read-only filesystem methods are available to the exact extracted host
// functions. The compiler module and full driver are never imported/evaluated.
const readOnlyFs={readFileSync:fs.readFileSync,realpathSync:fs.realpathSync};
const context=vm.createContext({fs:readOnlyFs,path,crypto,apiPath:apiPin.file,
 basePath:basePin.file,project:snapshot,hash:file=>digest(fs.readFileSync(file))});
const code=spans+'\n'+infoCode+'\n'+readCode+
 '\nconst info=baseCacheInfo({compiler_term_abi:()=>1,compiler_span_abi:()=>3});'+
 '\nconst hit=readBaseCache(info);'+
 '\nglobalThis.result={info,hit:hit!==null,bookSha256:hit?.bookSha256,validatedBy:hit?.validatedBy,sourceBegin:hit?.sourceBegin,sourceEnd:hit?.sourceEnd,termAbi:hit?.termAbi,spanAbi:hit?.spanAbi};';
new vm.Script(code,{filename:'exact-frozen-cache-reader-data-only.js'}).runInContext(context,{timeout:10000});
const result=context.result;assert(result.hit);assert.equal(result.info.version,6);
assert.equal(result.info.compilerSha256,apiPin.sha256);assert.equal(result.info.baseSha256,basePin.sha256);
const cachePin=pin(result.info.file);
const archiveFile=path.join(root,'selfhost/tools/performance/phase54/artifacts/raw/archive.json');
const archivePin=pin(archiveFile,'9790d0d27948bdb80d2673216c85116297d0197944779d8778cdbbe4710b217e');
const archive=JSON.parse(fs.readFileSync(archiveFile));assert(archive.complete&&archive.reopenedVerified&&archive.inputStabilityVerified);
const cacheRelative=path.relative(raw,cachePin.file);assert(!cacheRelative.startsWith('..'));
assert.deepEqual({bytes:cachePin.bytes,sha256:cachePin.sha256},archive.files[cacheRelative]);
for(const row of inputs)assert.deepEqual(identity(row.file),row);
save(cacheOut,{kind:'phase55-closed-baseline-cache-admission',complete:true,pass:true,dataOnly:true,
 compilerExecuted:false,driverImported:false,producer,attempt:attemptPin,driver:driverPin,api:apiPin,base:basePin,cache:cachePin,
 archive:archivePin,extractedHostFunctions:{spansSha256:digest(spans),baseCacheInfoSha256:digest(infoCode),readBaseCacheSha256:digest(readCode)},
 result:{version:result.info.version,termAbi:result.termAbi,spanAbi:result.spanAbi,sourcePath:result.info.sourcePath,
 sourceBegin:result.sourceBegin,sourceEnd:result.sourceEnd,bookSha256:result.bookSha256,validatedBy:result.validatedBy,readBaseCacheHit:result.hit},
 inputs:[...inputs],inputsUnchanged:true,
 scope:'Exact frozen host cache reader and span/payload/hash validation accept the existing archived cache for statically verified ABI constants. Native inspect therefore has a non-null seed and does not enter prepareBase while these identities remain unchanged. This is data validation, not a compiler request or proof against concurrent mutation.'});

const names=[];
function walk(directory){for(const item of fs.readdirSync(directory,{withFileTypes:true})){const file=path.join(directory,item.name);assert(!item.isSymbolicLink(),file);if(item.isDirectory())walk(file);else{assert(item.isFile(),file);names.push(path.relative(raw,file));}}}
walk(raw);names.sort();assert.equal(names.length,4543);
assert.deepEqual(names,Object.keys(archive.files).sort());
let total=0;const changed=[];
for(const name of names){const row=identity(path.join(raw,name));total+=row.bytes;if(row.bytes!==archive.files[name].bytes||row.sha256!==archive.files[name].sha256)changed.push({path:name,actual:row,expected:archive.files[name]});}
const archiveBytes=identity(path.join(path.dirname(archiveFile),archive.archive.path));
assert.equal(archiveBytes.sha256,archive.archive.sha256);assert.equal(archiveBytes.bytes,archive.archive.bytes);
assert.equal(total,archive.uncompressedBytes);
for(const row of inputs)assert.deepEqual(identity(row.file),row);
save(inventoryOut,{kind:'phase55-closed-phase54-inventory-audit',complete:true,pass:changed.length===0,dataOnly:true,
 producer,archiveMetadata:archivePin,archive:archiveBytes,rawRoot:raw,filesChecked:names.length,bytesChecked:total,
 missing:[],unexpected:[],changed,cacheAdmission:identity(cacheOut),inputsUnchanged:true,
 scope:'Read-only full regular-file inventory and hashes compared with published closed archive metadata, plus exact archive byte hash. No archive extraction/recompression or compiler execution; only Phase55 receipts are written.'});
assert.equal(changed.length,0);
console.log(JSON.stringify({cache:identity(cacheOut),inventory:identity(inventoryOut),files:names.length,changed:changed.length}));
