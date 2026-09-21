// Measurement adapter only: no compiler sources or generated artifacts are rewritten.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {performance} from 'node:perf_hooks';
const [implementation,input,output,upstream,mode]=process.argv.slice(2);
const project=path.resolve(import.meta.dirname,'../..');
const phases={};
const timed=(name,fn)=>{const start=performance.now();try{return fn();}finally{phases[name]=(phases[name]||0)+performance.now()-start;}};
const start=performance.now();
let compile;
if(implementation==='upstream') {
  const B=await import(pathToFileURL(path.join(upstream,'bend2/bend.ts')));
  const C=await import(pathToFileURL(path.join(upstream,'bend2/comp.ts')));
  compile=async()=>{
    const book=B.book_nil(),loadStart=performance.now();
    await B.book_load(book,input,'',new Map());
    phases.load=performance.now()-loadStart;
    timed('check',()=>{B.book_valid(book);C.book_owned(book,C.SYNTH);if(book.hols+book.open)throw Error('Unresolved holes or laws');});
    return mode==='compile'?timed('emit',()=>C.js_book(book)):'checked';
  };
} else {
  process.env.BEND_TYPED_API=path.join(project,implementation==='selfhost'?'dist/selfhost/seed-verification/seed.mjs':'dist/typed-api.mjs');
  process.env.BEND_TYPED_RUNTIME=path.join(project,'src/runtime.mjs');
  process.env.BEND_BASE=path.join(upstream,'bend2/base.bend');
  delete process.env.BEND_TYPED_TRACE;
  const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs')));
  const original=await D.loadApi(),api={};
  for(const [name,fn] of Object.entries(original)) api[name]=typeof fn==='function'?(...args)=>timed(name,()=>fn(...args)):fn;
  // Exercise the existing uncached path: always parse and check the entire Base.
  // No cached graph or successful-check prefix may enter any measured sample.
  api.f_load_graph_seed=undefined;
  api.check_from_exact_prefix=undefined;
  // Checking benchmarks omit presentation-only declaration reports on both sides.
  api.driver_report=undefined;
  api.f_main_names=undefined;
  compile=async()=>{
    const result=await D.inspect(input,{api,mode});
    if(result.status!=='ok'||!result.checked)throw Error(JSON.stringify(result));
    return mode==='compile'?result.code:'checked';
  };
}
const importMs=performance.now()-start;
const cpuStart=process.cpuUsage(),compileStart=performance.now();
const code=await compile();
const compileMs=performance.now()-compileStart,cpu=process.cpuUsage(cpuStart),usage=process.resourceUsage();
const result={implementation,input,importMs,compileMs,importAndCompileMs:importMs+compileMs,cpuMs:(cpu.user+cpu.system)/1000,maxRssKiB:usage.maxRSS,phases,outputBytes:Buffer.byteLength(code)};
// Output persistence, hashing and program execution are outside compiler timings.
fs.writeFileSync(output,code);
console.log(JSON.stringify(result));
