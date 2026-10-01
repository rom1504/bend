// Saved-output ablation only. Root runs all target code under resource bounds.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [inputArg,tsArg,catalogArg,outArg]=process.argv.slice(2);
assert(inputArg&&tsArg&&catalogArg&&outArg,'usage: countdown-derive.mjs PHASE37_NUMERIC TS_NUMERIC CATALOG NEW_OUT');
const input=fs.realpathSync(inputArg),typescript=fs.realpathSync(tsArg),catalogFile=fs.realpathSync(catalogArg),out=path.resolve(outArg);
assert(!fs.existsSync(out));
const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({path:fs.realpathSync(file),sha256:hash(fs.readFileSync(file)),bytes:fs.statSync(file).size});
const source=fs.readFileSync(input,'utf8');
assert.equal(hash(source),'a2ffdcd6cc70e0f3159219eb4b75551646b1f20d3cea1d21042a1e08454ff540','require exact installed Phase37 numeric output');
const lines=source.split('\n'),publicIndex=lines.findIndex(x=>x.startsWith('G["p37.numeric"]=')),nestedIndex=lines.findIndex(x=>x.startsWith('G["bench"]='));
assert(publicIndex>=0&&nestedIndex>publicIndex);
const publicLine=lines[publicIndex],nestedLine=lines[nestedIndex];
const privateName='$R_112_51_55_46_110_117_109_101_114_105_99';
const publicMarker='/* private scalar region */for(;;){';
const nestedMarker='let $s0=$p0-1n;let $s1=$p1;let $s2=$p2;for(;;){';
const tail='if($n0===0n)',decrement='$s0=$n0-1n;';
function once(s,a,b){assert.equal(s.split(a).length,2,'exactly one site: '+a);return s.replace(a,b);}
assert.equal(publicLine.split(publicMarker).length,2);assert.equal(nestedLine.split(nestedMarker).length,2);
assert.equal(publicLine.split(tail).length,2);assert.equal(nestedLine.split(tail).length,2);
const fallback=publicLine.slice(publicLine.indexOf('const x3418=$s0;const x3419=$s1;const x3420=$s2;return'));
assert(fallback.includes('jump(callOwned(callOwned(get(G,"p37.numeric")'));
const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const parser={exports:{}};new Function('module','exports',parserText)(parser,parser.exports);
assert.equal(parser.exports.version,'8.16.0');
const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const catalog=JSON.parse(fs.readFileSync(catalogFile));
const cases=catalog.cases.filter(x=>x.id==='coverage-numeric-recurrence-256'||x.id==='coverage-numeric-recurrence-1024');
assert.equal(cases.length,2);
fs.mkdirSync(out);
const report={kind:'phase39-countdown-ablation',complete:false,checked:false,certified:false,
  scope:'Only private scalar countdown representation changes. Generic fallback and guards retained. Diagnostic helper exposure and trip caps are not production ABI or compiler admission evidence.',
  producer:identity(import.meta.filename),parent:identity(input),typescript:identity(typescript),catalog:identity(catalogFile),
  parserSha256:hash(parserText),dependencies:['bench','p37.numeric','F32.to_u32'],modules:[]};
const diagnosticHeader=`
const $p39Counts={public:0,nested:0,publicNumber:0,nestedNumber:0};
let $p39Nested=null,$p39Probe=null;
const $p39String=String;
function $p39Tick(entry,n){
 ++$p39Counts[entry];if(typeof n==='number')++$p39Counts[entry+'Number'];
 if($p39Probe===null)return false;
 $p39Probe.trace.push({entry,value:$p39String(n),kind:typeof n});
 return $p39Probe.trace.length>$p39Probe.limit;
}
`;
const diagnosticExports=`
export function countdownCounts(){return {...$p39Counts};}
export function countdownBounded(entry,n,limit=3){
 if(!['public','nested'].includes(entry)||!Number.isInteger(limit)||limit<0||limit>4)throw Error('invalid diagnostic trip cap');
 // Refusal does not run a huge generic countdown. Public input remains BigInt.
 if(typeof n!=='bigint'||n<0n||n>281474976710655n)return {admitted:false,trace:[]};
 if(!regionHostGuard()||!localGuard(['bench','p37.numeric','F32.to_u32']))return {admitted:false,trace:[]};
 if($p39Probe!==null)throw Error('nested diagnostic probe');
 const probe={trace:[],limit};$p39Probe=probe;
 try{
  const result=entry==='nested'?$p39Nested(n,0.25,17):call(get(G,'p37.numeric'),[n,0.25,17]);
  return {admitted:true,trace:probe.trace,result};
 }finally{$p39Probe=null;}
}
`;
for(const counters of [false,true])for(const variant of ['original','nested','both']){
 let p=publicLine,n=nestedLine;
 if(variant==='both'){
  p=once(p,publicMarker,'/* private scalar region */$s0=regionCounterNumber($s0);for(;;){');
  p=once(once(p,tail,'if($n0===0)'),decrement,'$s0=$n0-1;');
 }
 if(variant!=='original'){
  n=once(n,nestedMarker,'let $s0=regionCounterNumber($p0)-1;let $s1=$p1;let $s2=$p2;for(;;){');
  n=once(once(n,tail,'if($n0===0)'),decrement,'$s0=$n0-1;');
 }
 assert(p.endsWith(fallback),'public generic suffix changed');
 if(counters){
  p=once(p,'for(;;){',"for(;;){if($p39Tick('public',$s0))return {diagnosticStop:true};");
  n=once(n,'for(;;){',"for(;;){if($p39Tick('nested',$s0))return {diagnosticStop:true};");
  n=once(n,'const $guards=["bench"',`$p39Nested=${privateName};const $guards=["bench"`);
 }
 const next=lines.slice();next[publicIndex]=p;next[nestedIndex]=n;
 const text=(counters?diagnosticHeader:'')+next.join('\n')+(counters?diagnosticExports:'');
 parse(text);
 if(!counters&&variant==='original')assert.equal(text,source);
 const file=path.join(out,variant+(counters?'.diagnostic.mjs':'.clean.mjs'));
 fs.writeFileSync(file,text,{flag:'wx'});report.modules.push({variant,counters,...identity(file)});
}
for(const expected of [report.parent,report.typescript,report.catalog])assert.deepEqual(identity(expected.path),expected);
report.complete=true;
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify({inputs:[path.join(out,'derive.json'),input,typescript,catalogFile],cases:cases.map(row=>({id:row.id,point:row.point,modules:{original:path.join(out,'original.clean.mjs'),nested:path.join(out,'nested.clean.mjs'),both:path.join(out,'both.clean.mjs'),typescript}}))},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,out,modules:report.modules.length,cases:cases.length}));
