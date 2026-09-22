// Independent correctness-only review of the disposable private Boolean cache.
// Raw graph exports exist only in generated test artifacts, never the transport.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {spawn} from 'node:child_process';import {pathToFileURL} from 'node:url';
import {privateStableMemo} from './private-stable-memo.mjs';import {identity,verifyIdentity} from '../../private-compiler/common.mjs';
const [apiArg,manifestArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('Usage: private-stable-review.mjs H_API IMAGE_MANIFEST NEW_DIRECTORY');
const api=fs.realpathSync(apiArg),manifest=fs.realpathSync(manifestArg),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const inputs=[api,manifest,import.meta.filename,new URL('./private-stable-memo.mjs',import.meta.url),new URL('./analysis-order-audit.mjs',import.meta.url),new URL('../../compiler-abi.mjs',import.meta.url),process.execPath].map(identity);
const report={kind:'phase4-private-stability-independent-review',complete:false,started:new Date().toISOString(),affinity:fs.readFileSync('/proc/self/status','utf8').split('\n').find(s=>s.startsWith('Cpus_allowed_list:')),scope:'Correctness only; brief CPU1 overlap with broad frontend sweep. No timing/performance conclusion. Private internal test exports permit immutable data graph probes only.',inputs};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try {
 const transformed=privateStableMemo(fs.readFileSync(api,'utf8'),JSON.parse(fs.readFileSync(manifest)).exports);
 const candidate=path.join(out,'candidate.mjs');fs.writeFileSync(candidate,transformed.source+'\nexport {G as testGlobals,call as testCall,privateStableArgs as testStable};\n');inputs.push(identity(candidate));
 const bridge=path.join(out,'candidate-bridge.mjs');fs.writeFileSync(bridge,`import * as M from ${JSON.stringify(pathToFileURL(candidate).href)};export const G=M.testGlobals,call=M.testCall,ctor=M.ctor;\n`);inputs.push(identity(bridge));
 const audit=path.resolve(import.meta.dirname,'analysis-order-audit.mjs'),auditOut=path.join(out,'order'),a=fs.openSync(path.join(out,'order.stdout'),'wx'),b=fs.openSync(path.join(out,'order.stderr'),'wx');
 let result;
 try{result=await new Promise(resolve=>{const child=spawn(process.execPath,['--stack-size=4096','--max-old-space-size=3072',audit,api,bridge,auditOut],{stdio:['ignore',a,b]});const timer=setTimeout(()=>child.kill('SIGKILL'),20000);child.once('error',error=>{clearTimeout(timer);resolve({error:String(error)});});child.once('close',(status,signal)=>{clearTimeout(timer);resolve({status,signal});});});}finally{fs.closeSync(a);fs.closeSync(b);}
 assert.equal(result.error,undefined);assert.equal(result.status,0);assert.equal(result.signal,null);
 const order=JSON.parse(fs.readFileSync(path.join(auditOut,'report.json')));assert.equal(order.complete,true);assert.equal(order.typedShapeEqual,true);
 report.order={report:identity(path.join(auditOut,'report.json')),process:result,typedShapeEqual:order.typedShapeEqual,typedShapeCases:order.rows.filter(r=>!r.domain.startsWith('Invalid')).length,rawDifferences:order.rows.filter(r=>!r.equal).map(r=>({name:r.name,domain:r.domain,baseline:r.baseline,candidate:r.candidate}))};
 const B=await import(pathToFileURL(api)),M=await import(pathToFileURL(candidate));
 const nil=B.list([]),list=B.list,term=(tag,name='',id=0,quant=0,kids=[],removed=[])=>B.ctor('KTerm',[tag,name,id,quant,list(kids),list(removed)]),atom=tag=>term(tag),kind=term('Typ','',0,0,[term('Qua','',0,2)]),truth=term('Ctr','True'),bool=term('ADT','Bool'),other=term('ADT','Other');
 const def=(name,kind,typ,value=atom('Absent'),ctors=[])=>B.ctor('KDef',[name,kind,0,0,typ,value,list(ctors),false,false]);
 const base=[def('Bool','ADT',kind,atom('Absent'),[def('True','Ctr',bool)]),def('Other','ADT',kind,atom('Absent'),[def('No','Ctr',other)])];
 const bookA=list([def('A','Def',kind,bool),...base]),bookB=list([def('A','Def',kind,other),...base]);
 const env=book=>B.ctor('KEnv',[book,'review',atom('Absent'),0,nil,false]);
 const sharedTail=term('All','second',22,1,[bool,term('Ref','A')]),tel=term('All','first',21,1,[term('Ref','A'),sharedTail]),args=list([truth,truth]);
 const outcome=(module,book)=>{try{const value=(module.testCall??module.call)((module.testGlobals??module.G).tele_check,[env(book),nil,tel,args,1]);return {status:'returned',value:JSON.parse(JSON.stringify(value))};}catch(error){return {status:'threw',name:error.name,message:error.message};}};
 report.bookControls=[];
 for(const [name,book] of [['A',bookA],['B',bookB],['A-again',bookA],['B-again',bookB]]){
  const baseline=outcome(B,book),candidate=outcome(M,book);assert.deepEqual(candidate,baseline);assert.equal(baseline.status,'returned');const error=baseline.value.a[3];assert.equal(typeof error,'string');assert.equal(error==='',name.startsWith('A'));
  report.bookControls.push({name,baseline,candidate,exact:true});
 }
 // Retain the same raw immutable objects across repeated calls. These are
 // private graph controls, not additional public graph transport support.
 report.repeatedErrors=[];
 for(const tag of ['A\ud800','Ap\ud800','V\ud800','\ud800']) {
  const value=term(tag,'',0,0,[atom('Num')]);const observe=run=>{try{return {status:'returned',value:run()};}catch(error){return {status:'threw',name:error.name,message:error.message};}};
  for(let attempt=0;attempt<2;attempt++){const baseline=observe(()=>B.call(B.G.core_subst_stable,[value])),candidate=observe(()=>M.testStable([value]));assert.deepEqual(candidate,baseline);report.repeatedErrors.push({tag,attempt,baseline,candidate,exact:true});}
 }
 inputs.forEach(verifyIdentity);report.inputsVerified=true;report.complete=true;
}catch(error){report.error=error.stack||String(error);process.exitCode=1;}
report.finished=new Date().toISOString();save();console.log(JSON.stringify({complete:report.complete,order:report.order,bookControls:report.bookControls?.length,error:report.error}));
