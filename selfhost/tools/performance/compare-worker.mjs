// Explicit-artifact worker. Compiler computation remains in the selected API.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {performance} from 'node:perf_hooks';
const [requestFile,resultFile]=process.argv.slice(2);
const {variant,input,output,mode='compile',cache='off',upstream}=JSON.parse(fs.readFileSync(requestFile,'utf8'));
const start=performance.now(),phases={},calls={};
const timed=(name,fn)=>{const t=performance.now();try{return fn();}finally{phases[name]=(phases[name]||0)+performance.now()-t;calls[name]=(calls[name]||0)+1;}};
let compile,prepare;
if(variant.kind==='upstream') {
  const B=await import(pathToFileURL(path.join(upstream,'bend2/bend.ts'))),C=await import(pathToFileURL(path.join(upstream,'bend2/comp.ts')));
  compile=async()=>{
    const book=B.book_nil(),t=performance.now();await B.book_load(book,input,'',new Map());phases.load=performance.now()-t;calls.load=1;
    if(mode==='parse')return 'parsed';
    timed('check',()=>{B.book_valid(book);C.book_owned(book,C.SYNTH);if(book.hols+book.open)throw Error('Unresolved holes/laws');});
    if(mode==='check')return 'checked';
    return timed('emit',()=>mode==='library'?C.js_lib(book,variant.exports||['main'],variant.exports||['main']):C.js_book(book));
  };
} else {
  process.env.BEND_TYPED_API=variant.api;
  process.env.BEND_TYPED_RUNTIME=variant.runtime;
  process.env.BEND_BASE=path.join(upstream,'bend2/base.bend');
  delete process.env.BEND_TYPED_TRACE;
  const D=await import(pathToFileURL(variant.driver)),original=await D.loadApi(),api={};
  for(const [name,fn] of Object.entries(original))api[name]=typeof fn==='function'?(...args)=>timed(name,()=>fn(...args)):fn;
  if(cache==='off'){api.f_load_graph_seed=undefined;api.check_from_exact_prefix=undefined;}
  if(!variant.reportDeclarations){api.driver_report=undefined;api.f_main_names=undefined;api.f_parsed_main_names=undefined;}
  prepare=()=>D.prepareBase(api);
  compile=async()=>{
    const r=await D.inspect(input,{api,mode});
    if(r.status!=='ok'||(mode!=='parse'&&!r.checked))throw Error(JSON.stringify(r));
    return r.code||(mode==='parse'?'parsed':'checked');
  };
}
const importMs=performance.now()-start;
// Priming is a separate invocation, never a hidden warmup of the timed sample.
if(mode==='prime') {
  if(!prepare)throw Error('No upstream persistent Base cache');
  await prepare();fs.writeFileSync(resultFile,JSON.stringify({primed:true,phases,calls}));
} else {
  const cpu=process.cpuUsage(),t=performance.now();
  const code=await compile(),compileMs=performance.now()-t,used=process.cpuUsage(cpu);
  const result={importMs,compileMs,cpuMs:(used.user+used.system)/1000,maxRssKiB:process.resourceUsage().maxRSS,phases,calls,outputBytes:Buffer.byteLength(code)};
  fs.writeFileSync(output,code);fs.writeFileSync(resultFile,JSON.stringify(result,null,2)+'\n');
}
