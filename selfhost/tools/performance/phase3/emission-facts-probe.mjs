#!/usr/bin/env node
// Causal ablation only: per-emission facts for unchanged, closed, App-free terms.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {performance} from 'node:perf_hooks';
import {pathToFileURL,fileURLToPath} from 'node:url';
const [apiInput,fixturesInput,outInput]=process.argv.slice(2);
if(!outInput)throw Error('Usage: emission-facts-probe.mjs FROZEN_B1.mjs SCALING_FIXTURES NEW_OUTPUT_DIRECTORY');
const apiFile=fs.realpathSync(apiInput),fixtures=fs.realpathSync(fixturesInput),out=path.resolve(outInput);fs.mkdirSync(out,{recursive:false});
const source=fs.readFileSync(apiFile,'utf8'),sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const raw=`\nexport const rawEmission=(book,defs)=>run_loop($j_library_context$(book,defs));export const rawSubst=(...args)=>run_loop($subst$(...args));\n`;
const factCode=`
let __facts=null,__last=null;
function __closedAppFree(term){
 if(__facts.has(term))return __facts.get(term);
 __last.factVisits++;
 let safe=term.tag!=='Var'&&term.tag!=='App';
 for(let kids=term.kids;safe&&kids.$==='Con';kids=kids.tail)safe=__closedAppFree(kids.head);
 __facts.set(term,safe);return safe;
}
const __oldSubst=$subst$;
$subst$=function(term,id,value){
 if(__facts){__last.substCalls++;if(__closedAppFree(term)){__last.skipped++;return term;}__last.fallback++;}
 return __oldSubst(term,id,value);
};
function __scope(fn){__facts=new WeakMap();__last={factVisits:0,substCalls:0,skipped:0,fallback:0};try{return fn();}finally{__facts=null;}}
export const factEmission=(book,defs)=>__scope(()=>run_loop($j_library_context$(book,defs)));
export const factSubst=(...args)=>__scope(()=>run_loop($subst$(...args)));
export const factStats=()=>({...__last});
`;
const attribution=`
let __site='other';const __calls=Object.create(null);
for(const [name,get,set] of [['j_lambda_bind',()=>$j_lambda_bind$,v=>$j_lambda_bind$=v],['j_l_lam',()=>$j_l_lam$,v=>$j_l_lam$=v]]){const old=get();set(function(...args){const previous=__site;__site=name;try{return old(...args);}finally{__site=previous;}});}
const __oldSubst=$subst$;$subst$=function(...args){__calls[__site]=(__calls[__site]||0)+1;return __oldSubst(...args);};
export const siteCounts={reset(){for(const key of Object.keys(__calls))delete __calls[key]},read(){return {...__calls}}};
`;
for(const [name,extra] of [['plain',''],['facts',factCode],['attribution',attribution]])fs.writeFileSync(path.join(out,name+'.mjs'),source+extra+raw);
const B=await import(pathToFileURL(path.join(out,'plain.mjs'))),F=await import(pathToFileURL(path.join(out,'facts.mjs'))),A=await import(pathToFileURL(path.join(out,'attribution.mjs')));
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
const t=(tag,name='',id=0,quant=0,kids=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:nil});
const typ=t('Typ','',0,0,[t('Qua','',0,2)]),boolType=t('ADT','Bool'),truth=t('Ctr','True');
const def=(name,type,value=t('Absent'),kind='Def',ctors=[])=>({$:'KDef',name,kind,arity:0,templates:0,typ:type,value,ctors:list(ctors),native:false,unsafe:false});
const bool=def('Bool',typ,t('Absent'),'ADT',[def('True',boolType,t('Absent'),'Ctr'),def('False',boolType,t('Absent'),'Ctr')]);
const all=(name,id,a,b,q=1)=>t('All',name,id,q,[a,b]),lam=(name,id,b,q=1)=>t('Lam',name,id,q,[b]);
const variable=t('Var','A',1000),x=t('Var','x',1001);
const dependent=list([bool,def('dependent',all('A',1000,typ,all('x',1001,variable,variable),0),lam('A',1000,lam('x',1001,x),0))]);
const betaType=t('App','',0,0,[lam('T',1100,boolType,0),typ]);
const beta=list([bool,def('beta',betaType,truth)]);
const controls=[];
for(const [name,book] of [['dependent-identity',dependent],['beta-result-type',beta]]){
 assert.equal(B.default.check_book(book),'',name+' must check');const annotated=B.default.annotate_book(book);
 fs.writeFileSync(path.join(out,name+'.json'),JSON.stringify({book,annotated}));controls.push({name,book,annotated});
}
const substitutionControls=[
 {name:'absent-binder-still-reduces-beta',term:betaType,id:9999,value:truth},
 {name:'dependent-variable-is-substituted',term:all('x',1001,variable,variable),id:1000,value:boolType},
 {name:'variable-with-same-id-and-changed-name',term:variable,id:1000,value:t('Var','renamed',1000)},
 {name:'closed-app-free-tail',term:all('x',1001,boolType,boolType),id:1000,value:truth},
];
for(const item of substitutionControls){const expected=B.rawSubst(item.term,item.id,item.value),observed=F.factSubst(item.term,item.id,item.value);assert.deepEqual(observed,expected);item.expected=expected;item.stats=F.factStats();}
assert.equal(substitutionControls[0].expected.tag,'ADT');
const manifest=JSON.parse(fs.readFileSync(path.join(fixtures,'report.json'),'utf8'));
const cases=manifest.rows.map(row=>({name:row.kind+'-'+row.size,...JSON.parse(fs.readFileSync(path.join(fixtures,row.kind+'-'+row.size+'.json'),'utf8'))})).concat(controls);
const median=xs=>[...xs].sort((a,b)=>a-b)[Math.floor(xs.length/2)],rows=[];
for(const item of cases){
 assert.equal(B.default.check_book(item.book),'',item.name+' input checks again');
 const book=B.default.book_context(item.annotated),expected=B.rawEmission(book,item.annotated),expectedHash=sha(expected);
 assert.equal(F.factEmission(book,item.annotated),expected);const facts=F.factStats();
 A.siteCounts.reset();assert.equal(A.rawEmission(book,item.annotated),expected);const attribution=A.siteCounts.read();
 const samples=[];
 for(let round=0;round<5;round++)for(const variant of round%2?['facts','plain']:['plain','facts']){
  const start=performance.now(),output=(variant==='plain'?B.rawEmission:F.factEmission)(book,item.annotated),emitted=performance.now();
  assert.equal(sha(output),expectedHash);samples.push({round,variant,emitMs:emitted-start,totalMs:performance.now()-start});
 }
 const row={name:item.name,outputBytes:Buffer.byteLength(expected),outputSha256:expectedHash,inputSha256:sha(JSON.stringify({book:item.book,annotated:item.annotated})),facts,attribution,samples,medians:Object.fromEntries(['plain','facts'].map(variant=>{const s=samples.filter(row=>row.variant===variant);return [variant,{emitMs:median(s.map(row=>row.emitMs)),totalMs:median(s.map(row=>row.totalMs))}];})),allExact:true};
 rows.push(row);console.log(JSON.stringify({name:row.name,facts,attribution,medians:row.medians}));
}
const report={schemaVersion:1,api:{file:apiFile,sha256:sha(source)},probe:{file:fileURLToPath(import.meta.url),sha256:sha(fs.readFileSync(fileURLToPath(import.meta.url)))},variants:Object.fromEntries(['plain','facts','attribution'].map(name=>[name,{file:path.join(out,name+'.mjs'),sha256:sha(fs.readFileSync(path.join(out,name+'.mjs')))}])),scalingReport:{file:path.join(fixtures,'report.json'),sha256:sha(fs.readFileSync(path.join(fixtures,'report.json')))},node:process.version,nodeArgs:process.execArgv,cpu:0,allChecked:true,allExact:true,substitutionControls,rows,limitations:['Disposable JS WeakMap metadata scoped to one emission; no shared-kernel/Bend production change.','Only terms without Var and App anywhere can skip substitution; all other terms use the original implementation.','Rebuilding App beta-reduces even when the target variable is absent; that behavior remains mandatory.','Facts are recomputed in each timed emission; checking and annotation are outside emission timing.','Synthetic microbenchmarks, five alternating samples in one process, shared-host observations; no whole-compiler speedup claim.']};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
