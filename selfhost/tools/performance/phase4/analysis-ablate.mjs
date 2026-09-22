// Disposable, phase-scoped attribution/ablation of the checked B1 implementation.
// No compiler source or production runtime is altered.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const [configFile,outArg]=process.argv.slice(2);if(!outArg)throw Error('usage: analysis-ablate.mjs CONFIG.json NEW_DIRECTORY');
const config=JSON.parse(fs.readFileSync(configFile)),resolve=f=>fs.realpathSync(path.resolve(path.dirname(path.resolve(configFile)),f)),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const files=Object.fromEntries(['api','host','runtime','base'].map(k=>[k,resolve(config[k])])),sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex'),digest=s=>crypto.createHash('sha256').update(s).digest('hex');
process.env.BEND_TYPED_API=files.api;process.env.BEND_TYPED_RUNTIME=files.runtime;process.env.BEND_BASE=files.base;
const source=fs.readFileSync(files.api,'utf8');assert.ok(source.includes('function $wnf$('));assert.ok(source.includes('function $subst_node$('));
const variants=config.variants??['plain','counts'];
const additions=(variant)=>{
const count=variant==='counts',memo=variant==='wnf-memo',substmemo=variant==='subst-memo',facts=variant==='closed-facts',leaf=variant==='leaf';
return `
let __scope=null;
export function beginAnalysis(){__scope={counts:Object.create(null),tags:Object.create(null),wnf:new WeakMap(),subst:new WeakMap(),facts:new WeakMap()};}
export function endAnalysis(){const result=__scope?{counts:__scope.counts,tags:__scope.tags}:null;__scope=null;return result;}
const __oldWnf=$wnf$;$wnf$=function(book,term){
 if(!__scope)return __oldWnf(book,term);
 ${count?`__scope.counts.wnf=(__scope.counts.wnf||0)+1;`:''}
 ${count||memo?`let cache=__scope.wnf.get(book);if(!cache){cache=new WeakMap();__scope.wnf.set(book,cache);${count?'__scope.counts.books=(__scope.counts.books||0)+1;':''}}
 const hit=cache.has(term);${count?`const tag=__scope.tags[term.tag]??={calls:0,hits:0};tag.calls++;if(hit){tag.hits++;__scope.counts.wnfRepeated=(__scope.counts.wnfRepeated||0)+1;}`:''}
 ${memo?'if(hit)return cache.get(term);':''}
 const result=run_loop(__oldWnf(book,term));cache.set(term,result);${count?'if(result===term)__scope.counts.wnfUnchanged=(__scope.counts.wnfUnchanged||0)+1;':''}return result;`:'return __oldWnf(book,term);'}
};
function __closedAppFree(term){
 if(__scope.facts.has(term))return __scope.facts.get(term);
 let closed=term.tag!=='Var'&&term.tag!=='App';
 for(let ks=term.kids;closed&&ks.$==='Con';ks=ks.tail)closed=__closedAppFree(ks.head);
 __scope.facts.set(term,closed);return closed;
}
const __oldSubst=$subst$;$subst$=function(term,id,value){
 ${facts?`if(__scope&&__closedAppFree(term))return term;`:''}
 ${substmemo?`if(__scope&&term.tag!=='Var'&&term.kids.$!=='Nil'){
 const prior=__scope.subst.get(term);if(prior&&prior.id===id&&prior.value===value)return prior.result;
 const result=run_loop(__oldSubst(term,id,value));__scope.subst.set(term,{id,value,result});return result;
 }`:''}
 ${count?`if(__scope){const c=__scope.counts;c.subst=(c.subst||0)+1;const prior=__scope.subst.get(term);if(prior&&prior.id===id&&prior.value===value)c.substRepeatedSameTriple=(c.substRepeatedSameTriple||0)+1;__scope.subst.set(term,{id,value});}`:''}
 return __oldSubst(term,id,value);
};
const __oldSubstNode=$subst_node$;$subst_node$=function(term,id,value){
 ${count?`if(__scope){const c=__scope.counts;c.substNode=(c.substNode||0)+1;if(term.kids.$==='Nil'&&term.tag!=='App')c.substLeaf=(c.substLeaf||0)+1;}`:''}
 ${leaf?`if(__scope&&term.kids.$==='Nil'&&term.tag!=='App')return term;`:''}
 return __oldSubstNode(term,id,value);
};
${count?['annotate','ka_type','core_beta','norm_eval','core_rebuild'].map(name=>`{const old=$${name}$;$${name}$=function(...args){if(__scope)__scope.counts.${name}=(__scope.counts.${name}||0)+1;return old(...args);};}`).join('\n'):''}
`;
};
const modules={};for(const variant of variants){const file=path.join(out,variant+'.mjs');fs.writeFileSync(file,source+(variant==='plain'?'':additions(variant))+'\nexport const rawSubst=(...args)=>run_loop($subst$(...args));export const rawWnf=(...args)=>run_loop($wnf$(...args));\n');modules[variant]=await import(pathToFileURL(file));}
// Direct differential controls retain beta rebuilding and bind cache keys to all inputs.
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil),term=(tag,name='',id=0,kids=[])=>({$:'KTerm',tag,name,id,quant:0,kids:list(kids),removed:nil});
const truth=term('Ctr','True'),falsehood=term('Ctr','False'),variable=term('Var','x',42),application=term('App','',0,[term('Lam','x',42,[variable]),truth]);
const controls=[{name:'absent-binder-beta',t:application,id:999,v:falsehood},{name:'different-replacement',t:application,id:42,v:falsehood},{name:'same-id-renamed-variable',t:variable,id:42,v:term('Var','renamed',42)},{name:'closed-App-free',t:term('All','a',10,[term('ADT','B'),term('ADT','B')]),id:999,v:truth}];
const def=value=>({$:'KDef',name:'alias',kind:'Def',arity:0,templates:0,typ:term('Typ'),value,ctors:nil,native:false,unsafe:false}),reference=term('Ref','alias'),books=[list([def(truth)]),list([def(falsehood)])];
const plain=modules.plain;assert.ok(plain,'Plain variant required for exact controls');
for(const [variant,M] of Object.entries(modules)){M.beginAnalysis?.();for(let repeat=0;repeat<2;repeat++)for(const c of controls)assert.deepEqual(M.rawSubst(c.t,c.id,c.v),plain.rawSubst(c.t,c.id,c.v),variant+' '+c.name);for(let repeat=0;repeat<2;repeat++)for(const book of books)assert.deepEqual(M.rawWnf(book,reference),plain.rawWnf(book,reference),variant+' book-scoped wnf');M.endAnalysis?.();}
const D=await import(pathToFileURL(files.host)),inputs=Object.fromEntries([...Object.values(files),import.meta.filename,configFile,...config.inputs.map(i=>resolve(i.file))].map(f=>[fs.realpathSync(f),sha(f)]));
const report={kind:'phase4-real-analysis',started:new Date().toISOString(),node:process.version,nodeArgs:process.execArgv,cpu:2,files,inputs,variants:Object.fromEntries(variants.map(v=>[v,{file:path.join(out,v+'.mjs'),sha256:sha(path.join(out,v+'.mjs'))}])),controls:controls.map(c=>c.name).concat(['book-scoped wnf']),scope:'Successful real programs; unchanged checked B1 workers. Counter copies perturb execution and their timing is not a baseline. Optional memo/leaf ablations are disposable generated-JS only, scoped to each public API call. Base cache prepared outside samples.',rows:[],complete:false};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const original=(await import(pathToFileURL(files.api))).default;const prepared=await D.prepareBase(original);report.baseCache={compilerSha256:prepared.compilerSha256,baseSha256:prepared.baseSha256,bookSha256:prepared.bookSha256};save();
try{
for(const item of config.inputs){const input=resolve(item.file);let expected=null;
for(let round=0;round<(config.rounds??1);round++)for(const variant of round%2?[...variants].reverse():variants){
 const M=modules[variant],phases=[];
 const api=Object.fromEntries(Object.entries(M.default).map(([name,method])=>[name,(...args)=>{M.beginAnalysis?.();const start=performance.now();try{return method(...args);}finally{phases.push({name,milliseconds:performance.now()-start,...(M.endAnalysis?.()??{})});}}]));
 const start=performance.now(),result=await D.inspect(input,{mode:item.mode??'compile',api});const wallMs=performance.now()-start;
 const row={input:item.id??input,round,variant,wallMs,phases,result:{...result}};delete row.result.code;
 assert.equal(result.status,'ok',JSON.stringify(result));assert.equal(result.checked,true);
 const outputSha256=digest(result.code);if(expected===null)expected=outputSha256;assert.equal(outputSha256,expected);row.outputSha256=outputSha256;row.outputBytes=Buffer.byteLength(result.code);row.exact=true;
 fs.writeFileSync(path.join(out,(item.id??path.basename(input))+'.'+round+'.'+variant+'.mjs'),result.code);report.rows.push(row);save();console.log(JSON.stringify({input:row.input,round,variant,wallMs,phases:phases.filter(p=>p.counts&&Object.keys(p.counts).length).map(p=>({name:p.name,counts:p.counts}))}));
}}
report.inputsUnchanged=Object.entries(inputs).every(([f,h])=>sha(f)===h);assert.equal(report.inputsUnchanged,true);report.complete=true;
}catch(error){report.error=error.stack;process.exitCode=1;}finally{report.finished=new Date().toISOString();save();}
