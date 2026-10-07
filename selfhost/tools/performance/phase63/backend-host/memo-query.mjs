// Diagnostic ceiling experiment. Compiler algorithms remain in the original B2;
// JS identity caches below are not a production implementation or promotion.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [attemptArg,imageArg,sourceArg,variant,outArg,oracleArg]=process.argv.slice(2);
assert(attemptArg&&imageArg&&sourceArg&&variant&&outArg,'memo-query.mjs CHECKED_GENERATOR B2_API SOURCE baseline|arity|wnf|both NEW_OUT [BASELINE_MODULE]');
assert(['baseline','arity','wnf','both'].includes(variant));assert(variant==='baseline'||oracleArg,'Memo variant requires a complete baseline module');
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase63')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex'),identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const inputs=new Map(),pin=(file,want)=>{const x=identity(file);if(want)assert.equal(x.sha256,want.sha256);if(inputs.has(x.file))assert.deepEqual(inputs.get(x.file),x);inputs.set(x.file,x);return x;};
const report={kind:'phase63-identity-query-memo-diagnostic',complete:false,pass:false,variant,diagnosticOnly:true,productionQualified:false,scope:'Fresh worker, append-only genuine B2 derivative, identical hooks in every variant; one library compilation with supplied API in every variant. This deliberately uses the same public supplied-API loader lane, not the ordinary owned-API performance lane. Exact book/node WeakMap keys only; no structural interning, compiler rewrite or checked derivative claim. Request counters and full output equality qualify this input only.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));report.attempt=pin(path.join(attemptArg,'attempt.json'));const raw=read(report.attempt.file);
 report.image=pin(imageArg);report.source=pin(sourceArg);pin(import.meta.filename);report.node=pin(process.execPath);
 const emissionFile=path.join(path.dirname(imageArg),'report.json');report.emission=pin(emissionFile);const emission=read(emissionFile);assert(emission.complete&&emission.pass);assert.equal(emission.module.sha256,report.image.sha256);
 for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
 process.env.BEND_TYPED_API=report.image.file;process.env.BEND_TYPED_RUNTIME=raw.runtime.file;process.env.BEND_BASE=raw.base.file;
 const workflowFile=path.resolve(import.meta.dirname,'../../../development/workflow.mjs');pin(workflowFile);
 const {verifyAttempt}=await import(pathToFileURL(workflowFile));const attempt=await verifyAttempt(attemptArg);assert(attempt.checked&&attempt.config.strictExact);
 for(const k of ['api','runtime','base','node','bootstrapReport'])pin(attempt[k].file,attempt[k]);
 assert.equal(emission.generator.api.sha256,attempt.api.sha256,'B2 checked generator mismatch');
 const driverFile=path.join(attempt.snapshot.root,'tools/typed-driver.mjs');report.driver=pin(driverFile);
 const original=fs.readFileSync(imageArg,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};new Function('module','exports',parserSource)(parser,parser.exports);
 const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original);
 for(const name of ['$jd$wnf','$jd$jd_95_arity'])assert.equal(ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===name).length,1,name);
 assert(!original.includes('phase63QueryMemo'));
 const suffix=`
export const phase63QueryMemo=(()=>{
 let enabled=new Set(),state;
 const reset=()=>{state={arity:{calls:0,hits:0,misses:0,stored:0,bypasses:0,capMisses:0,reentrant:0,uncacheable:0,books:0},wnf:{calls:0,hits:0,misses:0,stored:0,bypasses:0,capMisses:0,reentrant:0,uncacheable:0,books:0}};};reset();
 const object=x=>x!==null&&typeof x==='object';
 function install(name,prior,valid){let books=new WeakMap();return {reset(){books=new WeakMap();},call(book,node){const s=state[name];s.calls++;
  if(!enabled.has(name)||!object(book)||!object(node)){s.bypasses++;return prior(book,node);}
  let b=books.get(book);if(!b){b={nodes:new WeakMap(),count:0};books.set(book,b);s.books++;}
  const found=b.nodes.get(node);if(found?.done){s.hits++;return found.value;}if(found){s.reentrant++;return prior(book,node);}
  s.misses++;if(b.count>=4096||s.stored>=65536){s.capMisses++;return prior(book,node);}
  b.nodes.set(node,{done:false});try{const value=prior(book,node);if(valid(value)){b.nodes.set(node,{done:true,value});b.count++;s.stored++;}else{b.nodes.delete(node);s.uncacheable++;}return value;}catch(error){b.nodes.delete(node);throw error;}
 }};}
 const arity=install('arity',$jd$jd_95_arity,x=>typeof x==='number'&&Number.isInteger(x)&&x>=0&&x<=4294967295);
 const wnf=install('wnf',$jd$wnf,x=>object(x)&&['KTerm','KLambda','KLiteral'].includes(x.$));
 $jd$jd_95_arity=(book,node)=>arity.call(book,node);$jd$wnf=(book,node)=>wnf.call(book,node);
 return {configure(variant){enabled=new Set(variant==='both'?['arity','wnf']:variant==='baseline'?[]:[variant]);reset();arity.reset();wnf.reset();},stats(){return JSON.parse(JSON.stringify(state));}};
})();
`;
 parse(original+suffix);const derivative=path.join(out,'api.mjs');fs.writeFileSync(derivative,original+suffix,{flag:'wx'});report.derivative={parent:report.image,output:pin(derivative),appendOnly:true,suffixSha256:hash(suffix),parserSha256:hash(parserSource)};
 const beginImport=performance.now(),module=await import(pathToFileURL(derivative));assert.equal(module.backend?.kind,'direct-js');assert(!module.G&&!module.ctor);const D=await import(pathToFileURL(driverFile));report.importMs=performance.now()-beginImport;assert.equal(D.apiPath,report.image.file);pin(D.directRuntimePath);
 module.phase63QueryMemo.configure(variant);
 const begin=performance.now(),result=await D.inspect(report.source.file,{mode:'library',backend:'direct',api:module.default});report.requestMs=performance.now()-begin;report.importAndRequestMs=report.importMs+report.requestMs;
 report.counters=module.phase63QueryMemo.stats();report.observation={status:result.status,phase:result.phase,checked:result.checked,diagnostic:result.diagnostic};
 assert.equal(result.status,'ok',result.diagnostic);assert.equal(result.checked,true);assert.equal(result.backend,'direct');
 const output=path.join(out,'program.mjs');fs.writeFileSync(output,result.code,{flag:'wx'});report.output=pin(output);
 if(oracleArg){report.oracle=pin(oracleArg);assert.equal(Buffer.compare(fs.readFileSync(oracleArg),Buffer.from(result.code)),0,'Complete module differs from baseline');report.rawOutputEqual=true;}
 for(const f of result.files)pin(f);await verifyAttempt(attemptArg);for(const x of inputs.values())assert.deepEqual(identity(x.file),x);
 report.peakRssKiB=process.resourceUsage().maxRSS;report.complete=report.pass=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,variant,requestMs:report.requestMs,counters:report.counters,error:report.error}));
