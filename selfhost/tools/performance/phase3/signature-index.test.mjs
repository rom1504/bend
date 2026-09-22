// Exact law-signature mode and checker differential for a checked Bend overlay.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [file,candidateArg,out]=process.argv.slice(2);if(!out)throw Error('usage: signature-index.test.mjs BASELINE_API CHECKED_CANDIDATE_API NEW_OUTPUT_DIRECTORY');
const api=fs.realpathSync(file),directory=path.resolve(out);fs.mkdirSync(directory,{recursive:false});
const hash=x=>createHash('sha256').update(x).digest('hex'),source=fs.readFileSync(api,'utf8');
assert(source.includes('function $signature_mode$(d_0, later_0)'));
const baseline=(await import(pathToFileURL(api))).default;
const candidateFile=fs.realpathSync(candidateArg),candidateSource=fs.readFileSync(candidateFile,'utf8');
const candidate=(await import(pathToFileURL(candidateFile))).default.check_book;
const inspectFile=path.join(directory,'inspect.mjs');fs.writeFileSync(inspectFile,candidateSource+'\nexport const inspect={plan:run_lib($cs_plan$,1),mode:run_lib($signature_mode$,2)};\n');
const inspect=(await import(pathToFileURL(inspectFile))).inspect;
function checkModes(book){const plan=inspect.plan(book);let events=plan.events,todo=book;while(todo.$==='Con'){assert.equal(events.$,'Con');assert.deepEqual(events.head.original,todo.head);assert.deepEqual(events.head.mode,inspect.mode(todo.head,todo.tail));events=events.tail;todo=todo.tail;}assert.equal(events.$,'Nil');}
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil),term=(tag,name='',kids=[],quant=0)=>({$:'KTerm',tag,name,id:0,quant,kids:list(kids),removed:nil});
const boolType=term('ADT','B'),truth=term('Ctr','Yes'),absent=term('Absent');
const def=(name,typ,value=absent,kind='Def',ctors=[])=>({$:'KDef',name,kind,arity:0,templates:0,typ,value,ctors:list(ctors),native:false,unsafe:false});
const b=def('B',term('Typ','',[term('Qua','',[],2)]),absent,'ADT',[def('Yes',boolType,absent,'Ctr')]);
const report={kind:'bend-signature-index-differential',scope:'Checked Bend overlay against frozen B1. Exact event modes, positive/negative checker text; timings include planning plus all checker work on synthetic law/fill books.',api:{file:api,sha256:hash(source)},toolSha256:hash(fs.readFileSync(import.meta.filename)),candidate:{file:candidateFile,sha256:hash(candidateSource)},node:process.version,rows:[],negative:[],complete:false};
const save=()=>fs.writeFileSync(path.join(directory,'report.json'),JSON.stringify(report,null,2)+'\n');save();
for(const n of [64,128,256,512,1024]){
 const laws=Array.from({length:n},(_,i)=>def('f'+i,boolType)),fills=laws.map(d=>({...d,value:truth})),book=list([b,...laws,...fills]);
 checkModes(book);assert.equal(baseline.check_book(book),'');assert.equal(candidate(book),'');
 const samples=[];
 for(let rep=0;rep<3;rep++)for(const [name,check] of rep%2?[['candidate',candidate],['baseline',baseline.check_book]]:[['baseline',baseline.check_book],['candidate',candidate]]){const started=performance.now(),result=check(book);const ms=performance.now()-started;assert.equal(result,'');samples.push({name,rep,ms});}
 report.rows.push({n,samples});save();
 for(const [name,events] of [['duplicate',[b,...laws,laws[0],...fills]],['missing',[b,...laws,...fills.slice(1)]],['unsafe-first-fill',[b,...laws,{...fills[0],unsafe:true},...fills.slice(1)]],['signature-mismatch',[b,...laws,{...fills[0],typ:term('Typ','',[term('Qua','',[],1)])},...fills.slice(1)]]]){const input=list(events),expected=baseline.check_book(input);checkModes(input);assert.equal(candidate(input),expected);report.negative.push({n,name,error:expected});}
}

// Nearest-event semantics are observable even in rejected books. Keep original
// declarations, unsafe fills, duplicates and the first error in precisely order.
let seed=0x534947;const random=()=>seed=(Math.imul(seed,1664525)+1013904223)>>>0;
report.randomized=[];
for(let iteration=0;iteration<48;iteration++){
 const laws=Array.from({length:300},(_,i)=>def('q'+i,boolType));
 const fills=laws.map(d=>({...d,value:truth,unsafe:random()%3===0}));
 const events=[b,...laws,...fills];
 const at=1+random()%events.length;
 if(iteration%4===0)events.splice(at,0,{...laws[random()%laws.length]});
 if(iteration%4===1)events.splice(at,0,{...fills[random()%fills.length],typ:term('Typ','',[term('Qua','',[],1)])});
 if(iteration%4===2)events.splice(1+random()%laws.length,1);
 if(iteration%4===3)events[at]={...events[at],name:iteration%2?'':'λ'};
 const book=list(events),expected=baseline.check_book(book);checkModes(book);assert.equal(candidate(book),expected);
 report.randomized.push({iteration,error:expected,inputSha256:hash(JSON.stringify(book))});
}
const cache=baseline.book_cached(list([b,def('f',boolType,truth)]),0);
for(const book of [cache,list([def('before',boolType,truth),cache.head,def('after',boolType,truth)]),list([b,...Array.from({length:300},(_,i)=>def('law'+i,boolType)),cache.head])])assert.equal(candidate(book),baseline.check_book(book),'cache marker fallback');
report.cacheFallbackChecks=3;
assert.equal(hash(fs.readFileSync(api)),report.api.sha256);assert.equal(hash(fs.readFileSync(candidateFile)),report.candidate.sha256);report.complete=true;save();console.log(JSON.stringify(report));
