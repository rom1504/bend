// Codec-only discriminator: no compiler API calls and no production cache format.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {serialize,deserialize} from 'node:v8';
import {performance} from 'node:perf_hooks';
import {pathToFileURL} from 'node:url';
const [preparationArg,outArg]=process.argv.slice(2);
assert(preparationArg&&outArg,'binary-codec01.mjs PREPARATION_RESULT NEW_OUT');
const root=fs.realpathSync(path.resolve(import.meta.dirname,'../../../../build/phase61'));
const out=path.resolve(outArg);assert(out.startsWith(root+path.sep)&&!fs.existsSync(out));
let ancestor=path.dirname(out);while(!fs.existsSync(ancestor))ancestor=path.dirname(ancestor);
assert(fs.realpathSync(ancestor)===root||fs.realpathSync(ancestor).startsWith(root+path.sep));
const sha=b=>createHash('sha256').update(b).digest('hex'),inputs=new Map();
function pin(file,expected=null){file=fs.realpathSync(file);const b=fs.readFileSync(file),r={file,sha256:sha(b),bytes:b.length};if(expected){assert.equal(r.sha256,expected.sha256);if(expected.bytes!==undefined)assert.equal(r.bytes,expected.bytes);}if(inputs.has(file))assert.deepEqual(r,inputs.get(file));inputs.set(file,r);return r;}
const prepFile=pin(preparationArg);assert(prepFile.file.startsWith(root+path.sep));
const prep=JSON.parse(fs.readFileSync(prepFile.file));assert(prep.complete&&prep.pass&&prep.stage==='prepare'&&prep.role==='candidate'&&prep.image.kind==='direct');
assert(prep.verification.inputsUnchanged&&prep.verification.copiesUnchanged);
assert.equal(process.version,prep.node);const project=fs.realpathSync(prep.project);assert(project.startsWith(root+path.sep));
for(const name of ['api','base','driver','source','emission','checkedGenerator'])pin(prep.image[name].file,prep.image[name]);
const cacheName='base-'+prep.image.api.sha256+'-'+prep.image.base.sha256+'-'+sha(fs.realpathSync(prep.image.base.file))+'-frame2.json';
const cachePath=path.join(project,'build/typed/cache',cacheName),recordedCache=prep.verification.cacheFiles.find(p=>fs.realpathSync(p.file)===fs.realpathSync(cachePath));assert(recordedCache,'Cache absent from preparation receipt');
const cacheFile=pin(cachePath,recordedCache);const frame=fs.readFileSync(cacheFile.file);
fs.mkdirSync(out);const report={kind:'phase61-cache-codec-discriminator',version:1,complete:false,pass:false,scope:'One-process codec+validation only; no compiler calls, reader/first-request speedup or production format claim.',node:process.version,v8:process.versions.v8,execArgv:process.execArgv,preparation:prepFile,cache:cacheFile,rows:[],inputs:[],copies:[],validationPolicy:'Both paths use exact existing metadata/state admission. Binary additionally uses generic cycle-safe span traversal and existing canonical-state digest fallback, without JSON-tree privilege.',measurementPolicy:'Five alternating rounds, no clocked equality/stringification; input bytes resident. Preparation/import/serialization and full equality checked outside clock. Prior oracle decodes warm helpers; these are not cold first-request samples.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
try{
 pin(import.meta.filename);pin(process.execPath);
 const privateProject=path.join(out,'private-project'),tools=path.join(privateProject,'tools');fs.mkdirSync(tools,{recursive:true});fs.mkdirSync(path.join(privateProject,'src'));
 function copy(file,target){const p=pin(file);fs.copyFileSync(file,target,fs.constants.COPYFILE_EXCL);assert.equal(sha(fs.readFileSync(target)),p.sha256);report.copies.push({source:p,target});}
 for(const name of ['assemble','native-build','node-resource-args','compiler-abi'])copy(path.join(project,'tools',name+'.mjs'),path.join(tools,name+'.mjs'));
 copy(path.join(project,'src/compiler.json'),path.join(privateProject,'src/compiler.json'));
 const driver=fs.readFileSync(prep.image.driver.file,'utf8');assert.equal(sha(driver),prep.image.driver.sha256);
 const privateDriver=path.join(tools,'typed-driver.mjs');fs.writeFileSync(privateDriver,driver+'\nexport const p61Codec={validate:validateSpanCacheFrame,checked:admitCheckedPrefixState,fresh:admitFreshPrefixState};\n',{flag:'wx'});
 report.derivation={parent:prep.image.driver,derived:pin(privateDriver),scope:'Only exports lexical existing host validators; no compiler replacement or checked-image claim.'};
 const D=await import(pathToFileURL(privateDriver));
 const original=D.decodeBaseCacheFrame(frame),sourceText=fs.readFileSync(prep.image.base.file,'utf8');
 const info={compilerSha256:prep.image.api.sha256,baseSha256:prep.image.base.sha256,sourcePath:fs.realpathSync(prep.image.base.file),sourceText,termAbi:original.termAbi??0};
 function validate(c){assert.equal(D.p61Codec.validate(c,info),true);if(c.checkedPrefixState!==undefined)assert.equal(D.p61Codec.checked(c,info),true);if(c.freshPrefixState!==undefined)assert.equal(D.p61Codec.fresh(c),true);return c;}
 validate(original);const serializationStart=performance.now(),binary=serialize(original);report.serializationMs=performance.now()-serializationStart;
 report.byteSizes={frame2:frame.length,binary:binary.length};report.binarySha256=sha(binary);fs.writeFileSync(path.join(out,'binary-payload.bin'),binary,{flag:'wx'});
 const binaryHash=report.binarySha256;
 function decodeJSON(){return validate(D.decodeBaseCacheFrame(frame));}
 function decodeBinary(){assert.equal(sha(binary),binaryHash);return validate(deserialize(binary));}
 const oracle=JSON.stringify(original);const initial=decodeBinary();assert.deepEqual(initial,original);assert.equal(JSON.stringify(initial),oracle);
 // Metadata/value equivalence is outside timing. Both paths include raw-byte
 // integrity and every actual host admission; binary gets no private tree brand.
 for(let round=0;round<5;round++)for(const role of round%2?['binary','json']:['json','binary']){
  const started=performance.now();const value=role==='json'?decodeJSON():decodeBinary();const milliseconds=performance.now()-started;
  assert.equal(JSON.stringify(value),oracle);report.rows.push({round,role,milliseconds,fullValueMetadataAgreement:true});save();
 }
 const values=role=>report.rows.filter(r=>r.role===role).map(r=>r.milliseconds).sort((a,b)=>a-b);
 const json=values('json'),bin=values('binary');report.summary={jsonMedianMs:json[2],binaryMedianMs:bin[2],binaryOverJSON:bin[2]/json[2],differenceMs:bin[2]-json[2],samplesEach:5};
 for(const p of inputs.values())pin(p.file,p);assert.equal(sha(frame),cacheFile.sha256);assert.equal(sha(binary),binaryHash);report.complete=true;report.pass=true;save();
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};save();throw error;}
