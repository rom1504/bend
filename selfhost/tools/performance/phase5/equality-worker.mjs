// Fresh-process compiler measurement. Compiler algorithms remain in the supplied
// checked/derived Bend API or the pinned TypeScript compiler.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [requestFile,resultFile]=process.argv.slice(2);
if(!resultFile)throw Error('Usage: equality-worker.mjs REQUEST RESULT');
const req=JSON.parse(fs.readFileSync(requestFile));
const identity=file=>({file:path.resolve(file),canonicalPath:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const verify=()=>{for(const before of req.inputs)assert.deepEqual(identity(before.file),before,'Changed measurement input');};
verify();
for(const key of Object.keys(process.env))if(key.startsWith('BEND_')||key==='NODE_OPTIONS')delete process.env[key];
Object.assign(process.env,{BEND_UPSTREAM:req.upstream,BEND_BASE:req.base,BEND_TYPED_RUNTIME:req.runtime,...req.api?{BEND_TYPED_API:req.api}:{}});
const phases={},calls={},timed=(name,fn)=>{const start=performance.now();try{return fn();}finally{phases[name]=(phases[name]??0)+performance.now()-start;calls[name]=(calls[name]??0)+1;}};
let D,api,B,C;
const importStart=performance.now();
if(req.variant==='typescript'){
 B=await import(pathToFileURL(path.join(req.upstream,'bend2/bend.ts')));C=await import(pathToFileURL(path.join(req.upstream,'bend2/comp.ts')));
}else{
 D=await import(pathToFileURL(req.host));const raw=await D.loadApi();api={};
 for(const [name,value] of Object.entries(raw))api[name]=typeof value==='function'?(...args)=>timed(name,()=>value(...args)):value;
}
const importMs=performance.now()-importStart;
let result,cache,dependencies,emitted;
const cpuStart=process.cpuUsage(),start=performance.now();
if(req.prime){
 assert.ok(D,'TypeScript has no persistent Base cache');const prepared=await D.prepareBase(api);
 cache={validatedBy:prepared.validatedBy,compilerSha256:prepared.compilerSha256,baseSha256:prepared.baseSha256,bookSha256:prepared.bookSha256,sourcePath:prepared.sourcePath};
 result={status:'primed'};
}else if(D){result=await D.inspect(req.input,{api,mode:req.mode});}
else{
 assert.equal(req.mode,'compile','TS library roots are deliberately outside this comparison');
 let phase='parse',checked=false;
 try{
  const book=B.book_nil(),loadStart=performance.now();await B.book_load(book,req.input,'',new Map());phases.load=performance.now()-loadStart;calls.load=1;
  phase='check';checked=true;timed('check',()=>B.book_valid(book));
  phase='compile';timed('ownership',()=>C.book_owned(book,C.SYNTH));
  phase='check';const holes=book.hols+book.open;if(holes)throw `Error: ${holes} TODO${holes===1?'':'s'} found.\nThe code is incomplete, and not a valid proof yet.`;
  phase='compile';const code=timed('emit',()=>C.js_book(book));result={status:'ok',phase,checked,exitCode:0,code};
 }catch(error){result={status:'error',phase,checked,exitCode:1,diagnostic:error?.$==='Err'?B.err_show(error):String(error)};}
}
const requestMs=performance.now()-start,cpuUsed=process.cpuUsage(cpuStart);
if(req.prime){const prepared=await D.prepareBase(api);dependencies=[...new Set(req.workloads.flatMap(w=>D.discoverSources(api,w.input,{seed:prepared}).files))];}
if(result.code!==undefined){fs.writeFileSync(req.output,result.code,{flag:'wx'});emitted={...identity(req.output),bytes:Buffer.byteLength(result.code)};delete result.code;}
verify();
fs.writeFileSync(resultFile,JSON.stringify({variant:req.variant,result,cache,dependencies,emitted,importMs,requestMs,cpuMs:(cpuUsed.user+cpuUsed.system)/1000,phases,calls,maxRssKiB:process.resourceUsage().maxRSS,node:{path:process.execPath,version:process.version,args:process.execArgv},affinity:fs.readFileSync('/proc/self/status','utf8').split('\n').find(line=>line.startsWith('Cpus_allowed_list:')),inputsVerified:true},null,2)+'\n',{flag:'wx'});
