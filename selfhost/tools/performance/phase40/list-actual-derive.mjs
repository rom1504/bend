// Instrument actual checked emissions; no optimizer rewrite and clean bytes stay identical.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [baselineArg,candidateArg,outArg]=process.argv.slice(2);assert(baselineArg&&candidateArg&&outArg);
const out=path.resolve(outArg);assert(!fs.existsSync(out));
const id=p=>({path:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex'),bytes:fs.statSync(p).size});
const inputs=new Map();function track(p,expected){const r=id(p);if(expected){assert.equal(r.sha256,expected.sha256);if(expected.bytes!==undefined)assert.equal(r.bytes,expected.bytes);}inputs.set(r.path,r);return r;}
const pointer=r=>track(r.canonicalPath??r.file??r.path,r);
function read(p){const module=track(p),receipt=track(p+'.json'),e=JSON.parse(fs.readFileSync(receipt.path));assert.equal(e.complete,true);assert.equal(e.observation.checked,true);assert.equal(e.observation.status,'ok');assert.equal(pointer(e.output).sha256,module.sha256);pointer(e.input);pointer(e.producer);pointer(e.catalog);e.verifiers.forEach(pointer);for(const k of ['api','runtime','base','driver'])pointer(e.compiler[k]);if(e.attempt)pointer(e.attempt);return{module,receipt,e,text:fs.readFileSync(module.path,'utf8')};}
const original=read(baselineArg),component=read(candidateArg);assert.equal(original.e.input.sha256,component.e.input.sha256);
const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};new Function('module','exports',parserText)(parser,parser.exports);
const parse=text=>parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
const encoded=name=>'$R'+Array.from(name,c=>'_'+c.codePointAt(0)).join('')+'$tree';
const operations=['make','select','twice','add'],countNames=['producer','filter','map','fold'];
const names=['bench','ground_bench','chain_bench',...['ground','chain'].flatMap(prefix=>[...operations,'choose'].map(op=>prefix+'.'+op))];
const refusals=['refuse.bool','refuse.nat','refuse.same','refuse.affine','refuse.nested','refuse.primitive'];
const presentRefusals=refusals.filter(name=>component.text.includes('G['+JSON.stringify(name)+']='));
for(const name of ['refuse.bool','refuse.nat','refuse.same'])assert(presentRefusals.includes(name),'missing refusal definition '+name);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));track(path.join(out,'consumed-derive.mjs'));
const report={kind:'phase40-list-actual',complete:false,checked:true,certified:false,dependencies:names,refusals:presentRefusals,modules:[],inputs:[],scope:'Actual checked compiler output; clean modules unchanged. Diagnostic complete stages call actual global workers only under host/dependency guard and fresh private inputs; ordinary bench counters establish root admission.'};
for(const [variant,parent]of[['original',original],['component',component]]){
 let text=parent.text;const ast=parse(text),workers=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id?.name.endsWith('$tree'));
 const edits=[];for(const prefix of ['ground','chain'])for(let i=0;i<operations.length;i++){const name=prefix+'.'+operations[i],worker=workers.find(n=>n.id.name===encoded(name));assert.equal(Boolean(worker),variant==='component','worker '+name);if(worker)edits.push({at:worker.body.start+1,text:'++$p40Counts.'+countNames[i]+';++$p40WorkerCounts['+JSON.stringify(name)+'];'});}
 for(const name of presentRefusals)assert(!workers.some(n=>n.id.name===encoded(name)),'refused worker '+name);
 for(const edit of edits.sort((a,b)=>b.at-a.at))text=text.slice(0,edit.at)+edit.text+text.slice(edit.at);
 text=text.replaceAll('const $previousProof=regionProofOpen($guards);try{','const $previousProof=regionProofOpen($guards);try{++$p40Counts.root;');
 const direct=variant==='component';
 const stage=prefix=>`const produced=${direct?encoded(prefix+'.make')+'(BigInt(n),s)':"call(G['"+prefix+".make'],[BigInt(n),s])"};const filtered=${direct?encoded(prefix+'.select')+'(produced)':"call(G['"+prefix+".select'],[produced])"};const mapped=${direct?encoded(prefix+'.twice')+'(filtered)':"call(G['"+prefix+".twice'],[filtered])"};return {produced,filtered,mapped,sum:${direct?encoded(prefix+'.add')+'(mapped,0)':"call(G['"+prefix+".add'],[mapped,0])"}};`;
 text+=`\nconst $p40Counts={root:0,producer:0,filter:0,map:0,fold:0};const $p40WorkerCounts=${JSON.stringify(Object.fromEntries(['ground','chain'].flatMap(prefix=>operations.map(op=>[prefix+'.'+op,0]))))};const $p40Names=${JSON.stringify(names)};
 export function privateListCounts(){return {...$p40Counts};}export function privateWorkerCounts(){return {...$p40WorkerCounts};}export function privateProofActive(){return regionProof!==null;}
 function $p40Domain(n,s){if(!Number.isInteger(n)||n<0||n>30000||!Number.isInteger(s)||s<0||s>4294967295)throw Error('diagnostic domain');}
 export function privateListStages(n,s){$p40Domain(n,s);if(${direct}&&regionProof===null&&regionHostGuard()&&localGuard($p40Names)){const p=regionProofOpen($p40Names);try{${stage('ground')}}finally{regionProofClose(p);}}
 const produced=call(G['ground.make'],[BigInt(n),s]),filtered=call(G['ground.select'],[produced]),mapped=call(G['ground.twice'],[filtered]);return{produced,filtered,mapped,sum:call(G['ground.add'],[mapped,0])};}
 export function privateChainStages(n,s){$p40Domain(n,s);if(${direct}&&regionProof===null&&regionHostGuard()&&localGuard($p40Names)){const p=regionProofOpen($p40Names);try{${stage('chain')}}finally{regionProofClose(p);}}
 const produced=call(G['chain.make'],[BigInt(n),s]),filtered=call(G['chain.select'],[produced]),mapped=call(G['chain.twice'],[filtered]);return{produced,filtered,mapped,sum:call(G['chain.add'],[mapped,0])};}
 export function privateListProducer(n,s){$p40Domain(n,s);if(${direct}&&regionProof===null&&regionHostGuard()&&localGuard($p40Names)){const p=regionProofOpen($p40Names);try{return ${direct?encoded('ground.make')+'(BigInt(n),s)':"call(G['ground.make'],[BigInt(n),s])"};}finally{regionProofClose(p);}}return call(G['ground.make'],[BigInt(n),s]);}
 export function privateListAlias(){const tail={$:'Nil',a:[]},source={$:'Con',a:[0,{$:'Con',a:[7,tail]}]};let filtered;
 if(${direct}&&regionProof===null&&regionHostGuard()&&localGuard($p40Names)){const p=regionProofOpen($p40Names);try{filtered=${direct?encoded('ground.select')+'(source)':"call(G['ground.select'],[source])"};}finally{regionProofClose(p);}}else filtered=call(G['ground.select'],[source]);return{value:filtered,sourceUnchanged:source.a[1].a[1]===tail,emptyFresh:filtered.a[1]!==tail};}
 `;
 parse(text);for(const counters of [false,true]){const file=path.join(out,variant+(counters?'.mjs':'.clean.mjs'));fs.writeFileSync(file,counters?text:parent.text,{flag:'wx'});report.modules.push({variant,counters,parent:parent.module,receipt:parent.receipt,workers:workers.map(n=>n.id.name),...id(file)});if(!counters)assert.equal(id(file).sha256,parent.module.sha256);}
}
for(const row of inputs.values())assert.deepEqual(id(row.path),row);report.inputs=[...inputs.values()];report.complete=true;fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:true,modules:report.modules.length}));
