// Saved-JS causal ablation on checked03. Root executes; no compiler admission claim.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [inputArg,typescriptArg,outArg]=process.argv.slice(2);
assert(inputArg&&typescriptArg&&outArg,'usage: component-expression-derive.mjs CHECKED03_EXPR TYPESCRIPT_EXPR NEW_OUT');
const input=fs.realpathSync(inputArg),typescript=fs.realpathSync(typescriptArg),out=path.resolve(outArg);
assert(!fs.existsSync(out),'output must be new');
const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({path:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const observed=[];
function verify(row){const p=row.canonicalPath??row.file??row.path;assert(p&&row.sha256);const actual=identity(p);assert.equal(actual.sha256,row.sha256,p);observed.push(actual);return actual;}
function receipt(file,kind){const receiptFile=file+'.json',r=JSON.parse(fs.readFileSync(receiptFile));observed.push(identity(receiptFile));
 assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.compiler.kind,kind);
 assert.equal(r.observation.status,'ok');assert.equal(r.observation.checked,true);assert.equal(r.compiler.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
 assert.equal(verify(r.output).sha256,identity(file).sha256);verify(r.input);verify(r.producer);verify(r.catalog);r.verifiers.forEach(verify);
 if(kind==='checked-development-attempt'){
  assert.equal(r.observation.typeAccepted,true);assert.equal(r.compiler.api.sha256,'ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1');
  assert.equal(r.attempt.sha256,'7ae878dda1b75dce1655c62d8e7238e184319da1fa04a8a12a189f37badc8f85');verify(r.attempt);
  for(const key of ['api','runtime','base','driver'])verify(r.compiler[key]);
 }else r.compiler.sources.forEach(verify);
 return r;
}
const receiptB=receipt(input,'checked-development-attempt'),receiptT=receipt(typescript,'checked-pinned-typescript');
assert.equal(receiptB.input.sha256,receiptT.input.sha256);
const source=fs.readFileSync(input,'utf8');
assert.equal(hash(source),'9d5c1e383f3da6eb5f25d900328fff79c6867565b9556b1ddb147a718a69484c');
assert.equal(identity(typescript).sha256,'3ccc019bb4179db2b0c69dcf57282d95863e62db08ca4c91754b979b9613497e');
const names=['bench','p37.expr','p37.expr.pick','eval'];
const original='return $R_101_118_97_108(callOwned(callOwned(get(G,"p37.expr"),[(/* primitive */BigInt((x3448)))]),[x3449]),);';
assert.equal(source.split(original).length,2);
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const parserModule={exports:{}};new Function('module','exports',parserSource)(parserModule,parserModule.exports);assert.equal(parserModule.exports.version,'8.16.0');
const parse=s=>parserModule.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function additions(variant,counters){const direct=variant!=='original',pick=variant==='component';return `
// Explicit constructor descent/reconstruction; tags and existing eval stay intact.
const $p39Names=${JSON.stringify(names)};
${counters?'const $p39Counts={root:0,producer:0,pick:0};':''}
function $p39Pick(op,e,s){${counters?'++$p39Counts.pick;':''}
 if(op===0n)return {$:'Add',a:[e,{$:'Mul',a:[{$:'Lit',a:[s]},{$:'Lit',a:[3]}]}]};
 if(op===1n)return {$:'Mul',a:[e,{$:'Add',a:[{$:'Lit',a:[s%5]},{$:'Lit',a:[1]}]}]};
 return {$:'Sub',a:[e,{$:'Add',a:[{$:'Lit',a:[s]},{$:'Lit',a:[7]}]}]};}
function $p39Expr(n,s){${counters?'++$p39Counts.producer;':''}
 const frames=[];let top=0;
 // The source computes op before evaluating the recursive child. Keep BigInt
 // countdown/choice conversion here; Number-counter changes are a separate probe.
 while(n!==0n){const op=BigInt(s%3);frames[top++]={op,seed:s};--n;s=(s+1)>>>0;}
 let value={$:'Lit',a:[s]};
 while(top){const frame=frames[--top];value=${pick?'$p39Pick(frame.op,value,frame.seed)':"callOwned(get(G,'p37.expr.pick'),[frame.op,value,frame.seed])"};}
 return value;}
${counters?`
function $p39Guard(){return regionProof===null&&regionHostGuard()&&localGuard($p39Names);}
function $p39Domain(n,s){return Number.isInteger(n)&&n>=0&&n<=30000&&Number.isInteger(s)&&s>=0&&s<=4294967295;}
export function privateExprPoint(n,s){if(!$p39Domain(n,s))throw Error('diagnostic expression domain');
 if(${direct}&&$p39Guard())return $p39Expr(BigInt(n),s);return call(get(G,'p37.expr'),[BigInt(n),s]);}
export function privatePickPoint(op,s){if(![0,1,2].includes(op)||!$p39Domain(0,s))throw Error('diagnostic picker domain');
 const leaf=Object.freeze({$:'Lit',a:Object.freeze([s])}),shared=Object.freeze({$:'Add',a:Object.freeze([leaf,leaf])});
 const value=${pick}&&$p39Guard()?$p39Pick(BigInt(op),shared,s):call(get(G,'p37.expr.pick'),[BigInt(op),shared,s]);
 return {value,aliases:[value.a[0]===shared,value.a[0].a[0]===leaf,value.a[0].a[1]===leaf]};}
export function privateComponentCounts(){return {...$p39Counts};}
export function privateProofActive(){return regionProof!==null;}
`:''}
`;}
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase39-private-expression-prototype',complete:false,checked:false,certified:false,node:process.version,
 producer:identity(import.meta.filename),parent:identity(input),typescript:identity(typescript),receipts:[identity(input+'.json'),identity(typescript+'.json')],verifiedInputs:observed,
 parserSha256:hash(parserSource),dependencies:names,modules:[],scope:'Only the producer call inside the existing checked03 private scalar root changes; existing eval worker and entire generic branch are untouched. Saved JS, not compiler admission.'};
for(const counters of [true,false])for(const variant of ['original','producer','component']){
 let text=source;
 const body=variant==='original'?original:'return $R_101_118_97_108($p39Expr(BigInt(x3448),x3449));';
 text=text.replace(original,(counters?'++$p39Counts.root;':'')+body);
 if(counters||variant!=='original')text+=additions(variant,counters);
 parse(text);const file=path.join(out,variant+(counters?'.mjs':'.clean.mjs'));fs.writeFileSync(file,text,{flag:'wx'});
 if(!counters&&variant==='original')assert.equal(hash(text),hash(source));if(!counters)assert(!text.includes('$p39Counts'));
 report.modules.push({variant,counters,...identity(file),bytes:Buffer.byteLength(text)});
}
for(const row of observed)assert.deepEqual(identity(row.path),row);report.complete=true;
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const modules=Object.fromEntries([...['original','producer','component'].map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',typescript]]);
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify({inputs:[path.join(out,'derive.json'),input,typescript],cases:[
 {id:'coverage-expression-32',point:{exportName:'bench',args:[32,17],expected:2928000},modules},
 {id:'coverage-expression-128',point:{exportName:'bench',args:[128,123],expected:3393903617},modules}]},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,certified:false,out,modules:report.modules.length}));
