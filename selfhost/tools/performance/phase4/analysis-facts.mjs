// Disposable, phase-scoped attribution/ablation of the checked B1 implementation.
// No compiler source or production runtime is altered.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const [configFile,outArg]=process.argv.slice(2);if(!outArg)throw Error('usage: analysis-facts.mjs CONFIG.json NEW_DIRECTORY');
const config=JSON.parse(fs.readFileSync(configFile)),resolve=f=>fs.realpathSync(path.resolve(path.dirname(path.resolve(configFile)),f)),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const files=Object.fromEntries(['api','host','runtime','base'].map(k=>[k,resolve(config[k])])),sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex'),digest=s=>crypto.createHash('sha256').update(s).digest('hex');
process.env.BEND_TYPED_API=files.api;process.env.BEND_TYPED_RUNTIME=files.runtime;process.env.BEND_BASE=files.base;
const source=fs.readFileSync(files.api,'utf8');assert.ok(source.includes('function $wnf$('));assert.ok(source.includes('function $subst_node$('));
const variants=config.variants??['plain','counts'];
const additions=(variant)=> variant==='plain'?'':`
let __scope=null,__depth=0,__contexts=[];
export function beginAnalysis(){__scope={counts:{},tags:{},facts:new WeakMap()};__depth=0;__contexts=[];}
export function endAnalysis(){const r={counts:__scope.counts,tags:__scope.tags};__scope=null;return r;}
function __fact(t){let f=__scope.facts.get(t);if(f)return f;let closed=t.tag!=='Var'&&t.tag!=='App',size=1;for(let xs=t.kids;xs.$==='Con';xs=xs.tail){const child=__fact(xs.head);closed=closed&&child.closed;size+=child.size;}f={closed,size};__scope.facts.set(t,f);return f;}
const __oldSubst=$subst$;$subst$=function(t,id,v){if(!__scope)return __oldSubst(t,id,v);const c=__scope.counts;c.substVisited=(c.substVisited||0)+1;if(__depth===0){const f=__fact(t),context=__contexts.at(-1)||'other',r=__scope.tags[context]??={roots:0,closedRoots:0,closedNodes:0,largestClosed:0};r.roots++;if(f.closed){r.closedRoots++;r.closedNodes+=f.size;r.largestClosed=Math.max(r.largestClosed,f.size);}}__depth++;try{return run_loop(__oldSubst(t,id,v));}finally{__depth--;}};
${['ka_lam','tele_check_head','tele_fill_head','ka_args_head','ka_spine_step','infer_app_type','ka_type_app','check_lam_q','ka_let_head','j_lambda_bind','j_l_lam'].map(name=>`{const old=$${name}$;$${name}$=function(...a){if(!__scope)return old(...a);__contexts.push(${JSON.stringify(name)});try{return run_loop(old(...a));}finally{__contexts.pop();}};}`).join('\n')}
`;
const modules={};for(const variant of variants){const file=path.join(out,variant+'.mjs');fs.writeFileSync(file,source+(variant==='plain'?'':additions(variant)));modules[variant]=await import(pathToFileURL(file));}
const D=await import(pathToFileURL(files.host)),inputs=Object.fromEntries([...Object.values(files),import.meta.filename,configFile,...config.inputs.map(i=>resolve(i.file))].map(f=>[fs.realpathSync(f),sha(f)]));
const report={kind:'phase4-real-closed-substitution-facts',started:new Date().toISOString(),node:process.version,nodeArgs:process.execArgv,cpu:2,files,inputs,variants:Object.fromEntries(variants.map(v=>[v,{file:path.join(out,v+'.mjs'),sha256:sha(path.join(out,v+'.mjs'))}])),scope:'Counts only, no optimization. Completed substitution roots classified by immediate selected caller and exact syntactic no-Var/no-App property. Counts on instrumented checked B1 perturb runtime; no timing claim. closedNodes includes shared occurrences as baseline substitution traverses them; exact emitted bytes are required.',rows:[],complete:false};
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
