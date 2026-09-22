// Disposable attribution probe, never a production compiler. The host Map only
// tests the upper bound of replacing repeated raw suffix lookup; every checker
// rule and signature_fill_mode still executes in the frozen Bend-generated API.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [file,out]=process.argv.slice(2);if(!out)throw Error('usage: signature-suffix-probe.mjs FROZEN_B1_API NEW_OUTPUT_DIRECTORY');
const api=fs.realpathSync(file),directory=path.resolve(out);fs.mkdirSync(directory,{recursive:false});
const hash=x=>createHash('sha256').update(x).digest('hex'),source=fs.readFileSync(api,'utf8');
assert(source.includes('function $signature_mode$(d_0, later_0)'));
const baseline=(await import(pathToFileURL(api))).default;
const appended=`
let suffixTargets=new WeakMap();
const oldSignatureMode=$signature_mode$;
$signature_mode$=function(d,later){
 if(d.kind==='Def'&&d.value.tag==='Absent'&&!d.unsafe&&suffixTargets.has(later))return $signature_fill_mode$(d,suffixTargets.get(later));
 return oldSignatureMode(d,later);
};
export function checkWithSuffixIndex(book){
 suffixTargets=new WeakMap();
 const nodes=[];for(let xs=book;xs.$==='Con';xs=xs.tail)nodes.push(xs);
 const byName=new Map();
 for(let i=nodes.length-1;i>=0;i--){const node=nodes[i],d=node.head;
  if(d.kind==='Def'&&d.value.tag==='Absent'&&!d.unsafe&&byName.has(d.name))suffixTargets.set(node.tail,byName.get(d.name));
  byName.set(d.name,d);
 }
 return run_loop($check_book$(book));
}
`;
const candidateFile=path.join(directory,'candidate.mjs');fs.writeFileSync(candidateFile,source+appended);const candidate=(await import(pathToFileURL(candidateFile))).checkWithSuffixIndex;
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil),term=(tag,name='',kids=[],quant=0)=>({$:'KTerm',tag,name,id:0,quant,kids:list(kids),removed:nil});
const boolType=term('ADT','B'),truth=term('Ctr','Yes'),absent=term('Absent');
const def=(name,typ,value=absent,kind='Def',ctors=[])=>({$:'KDef',name,kind,arity:0,templates:0,typ,value,ctors:list(ctors),native:false,unsafe:false});
const b=def('B',term('Typ','',[term('Qua','',[],2)]),absent,'ADT',[def('Yes',boolType,absent,'Ctr')]);
const report={kind:'signature-suffix-host-map-ablation',scope:'Upper-bound attribution only; host Map is not proposed production compiler code. Each timed candidate includes index construction and full frozen checking; no skipped checks.',api:{file:api,sha256:hash(source)},toolSha256:hash(fs.readFileSync(import.meta.filename)),node:process.version,rows:[],negative:[],complete:false};
const save=()=>fs.writeFileSync(path.join(directory,'report.json'),JSON.stringify(report,null,2)+'\n');save();
for(const n of [64,128,256,512,1024]){
 const laws=Array.from({length:n},(_,i)=>def('f'+i,boolType)),fills=laws.map(d=>({...d,value:truth})),book=list([b,...laws,...fills]);
 assert.equal(baseline.check_book(book),'');assert.equal(candidate(book),'');
 const samples=[];
 for(let rep=0;rep<3;rep++)for(const [name,check] of rep%2?[['candidate',candidate],['baseline',baseline.check_book]]:[['baseline',baseline.check_book],['candidate',candidate]]){const started=performance.now(),result=check(book);const ms=performance.now()-started;assert.equal(result,'');samples.push({name,rep,ms});}
 report.rows.push({n,samples});save();
 for(const [name,events] of [['duplicate',[b,...laws,laws[0],...fills]],['missing',[b,...laws,...fills.slice(1)]],['unsafe-first-fill',[b,...laws,{...fills[0],unsafe:true},...fills.slice(1)]],['signature-mismatch',[b,...laws,{...fills[0],typ:term('Typ','',[term('Qua','',[],1)])},...fills.slice(1)]]]){const input=list(events),expected=baseline.check_book(input);assert.equal(candidate(input),expected);report.negative.push({n,name,error:expected});}
}
assert.equal(hash(fs.readFileSync(api)),report.api.sha256);report.complete=true;save();console.log(JSON.stringify(report));
