// Actual checked output adapter: only diagnostic call counters are added.
// No runtime helper, guard or compiler optimization is substituted here.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [baselineArg,candidateArg,typescriptArg,attemptArg,outArg]=process.argv.slice(2);
assert(baselineArg&&candidateArg&&typescriptArg&&attemptArg&&outArg,
 'Usage: native-cast-actual-derive-v4.mjs PHASE36_MODULE CANDIDATE_MODULE TYPESCRIPT_MODULE CANDIDATE_ATTEMPT NEW_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=file=>({path:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex'),bytes:fs.statSync(file).size});
const inputs=new Map();
function track(file,expected){const actual=identity(file);if(expected){assert.equal(actual.sha256,expected.sha256);if('bytes'in expected)assert.equal(actual.bytes,expected.bytes);}
 if(inputs.has(actual.path))assert.deepEqual(actual,inputs.get(actual.path));else inputs.set(actual.path,actual);return actual;}
function pointer(row){assert(row&&(row.file||row.path));return track(row.file??row.path,row);}
const sourceFile=path.join(import.meta.dirname,'native-cast-fixture-v1.bend');
const fixtureFile=path.join(import.meta.dirname,'native-cast-fixture-v1.json');
const fixture=JSON.parse(fs.readFileSync(track(fixtureFile).path));track(sourceFile,fixture.source);
const attemptFile=track(path.join(attemptArg,'attempt.json')).path,attempt=await verifyAttempt(path.dirname(attemptFile));
assert.equal(attempt.checked,true);pointer(attempt.api);pointer(attempt.runtime);pointer(attempt.base);
for(const source of attempt.snapshot.sources)pointer(source.frozen);
const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const parser={exports:{}};new Function('module','exports',parserText)(parser,parser.exports);assert.equal(parser.exports.version,'8.16.0');
const parse=text=>parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
function readChecked(file,label){const module=track(file),receipt=track(file+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path));
 assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);assert.equal(emission.observation.checked,true);assert.equal(emission.observation.status,'ok');
 assert.equal(emission.compiler.upstreamCommit,fixture.upstreamCommit);assert.equal(pointer(emission.input).path,fs.realpathSync(sourceFile));
 assert.equal(emission.input.sha256,fixture.source.sha256);assert.equal(pointer(emission.output).path,module.path);assert.equal(emission.output.sha256,module.sha256);
 pointer(emission.producer);pointer(emission.catalog);emission.verifiers.forEach(pointer);
 if(label==='typescript'){assert.equal(emission.compiler.kind,'checked-pinned-typescript');emission.compiler.sources.forEach(pointer);}
 else{assert.equal(emission.compiler.kind,'checked-development-attempt');pointer(emission.attempt);
  for(const key of ['api','runtime','base','driver'])pointer(emission.compiler[key]);
  if(label==='original')assert.equal(emission.compiler.api.sha256,'93e55ad7ee456eebb5fa3dd9606c2cf262ea386c6f66bfd891ffe187d8f50a75');
  else{assert.equal(emission.attempt.sha256,identity(attemptFile).sha256);for(const key of ['api','runtime','base'])assert.equal(emission.compiler[key].sha256,attempt[key].sha256);}}
 return{module,receipt,compiler:emission.compiler,text:fs.readFileSync(module.path,'utf8')};}
const baseline=readChecked(baselineArg,'original'),candidate=readChecked(candidateArg,'direct'),typescript=readChecked(typescriptArg,'typescript');
assert(candidate.text.includes("native('F32.to_u32',1,regionF32ToU32);"),'Actual candidate must share final native body');
assert(candidate.text.includes('regionGetPrototype(floatView)!==regionDataViewPrototype'));
assert(candidate.text.includes('regionGetDescriptor(floatView,regionDataViewKeys[i])'));
fs.mkdirSync(out);track(import.meta.filename);
const report={kind:'phase37-actual-private-native-cast',complete:false,checked:true,certified:false,
 producer:identity(import.meta.filename),attempt:identity(attemptFile),compiler:candidate.compiler,
 fixture:identity(fixtureFile),source:identity(sourceFile),typescript:typescript.module,
 dependencies:['bench','p37.numeric','cast.steps','cast.probe','cast.order','cast.once','cast.unused','cast.staged','F32.to_u32'],
 modules:[],inputs:[],scope:'Actual checked modules; clean copies are byte-identical, counters wrap only emitted private native call sites. No optimization/guard substitutions.'};
for(const [variant,parent]of[['original',baseline],['direct',candidate]]){
 const tree=parse(parent.text),calls=[];
 const walk=node=>{if(!node||typeof node!=='object')return;if(node.type==='CallExpression'&&node.callee.type==='Identifier'&&node.callee.name==='regionF32ToU32'){
  assert.equal(node.arguments.length,1);assert.notEqual(node.arguments[0].type,'SpreadElement');calls.push({start:node.callee.start,end:node.callee.end});}
  for(const [key,value]of Object.entries(node)){if(key==='start'||key==='end'||key==='loc')continue;if(Array.isArray(value))for(const child of value)walk(child);else if(value&&typeof value==='object')walk(value);}};
 walk(tree);if(variant==='original')assert.equal(calls.length,0);else assert(calls.length>=2,'Private calls must be present in actual source output');
 let text=parent.text;
 for(const call of [...calls].sort((a,b)=>b.start-a.start))text=text.slice(0,call.start)+'$p37ObservedCast'+text.slice(call.end);
 text+=`
const $p37CastCounts={calls:0,arguments:0};
${variant==='direct'?'function $p37ObservedCast(x){++$p37CastCounts.calls;return regionF32ToU32(x);}':''}
export function privateCastCounts(){return {...$p37CastCounts};}
export function privateCastPoint(x){++$p37CastCounts.arguments;return call(get(G,'cast.probe'),[x]);}
`;
 parse(text);
 for(const counters of[false,true]){const file=path.join(out,variant+(counters?'.mjs':'.clean.mjs'));
  fs.writeFileSync(file,counters?text:parent.text,{flag:'wx'});
  if(!counters)assert.equal(identity(file).sha256,parent.module.sha256);
  report.modules.push({variant,counters,parent:parent.module,emission:parent.receipt,privateCallSites:calls,...identity(file)});}
}
for(const expected of inputs.values())assert.deepEqual(identity(expected.path),expected);
report.inputs=[...inputs.values()];report.complete=true;
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,checked:true,api:report.compiler.api.sha256,modules:report.modules.length,
 privateCallSites:report.modules.find(row=>row.variant==='direct').privateCallSites.length}));
