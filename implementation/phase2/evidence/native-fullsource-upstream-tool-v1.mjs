// Bounded checked library compilation by unchanged pinned TypeScript modules.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
const tool=fileURLToPath(import.meta.url),sha=p=>createHash('sha256').update(fs.readFileSync(p)).digest('hex'),save=(p,v)=>fs.writeFileSync(p,JSON.stringify(v,null,2)+'\n');
if(process.argv[2]==='--worker'){
 const request=JSON.parse(fs.readFileSync(process.argv[3],'utf8'));
 const B=await import(pathToFileURL(path.join(request.snapshot,'bend.ts'))),C=await import(pathToFileURL(path.join(request.snapshot,'comp.ts')));
 if(B.BASE_BEND!==request.base)throw Error('Canonical Base differs');
 const report={base:B.BASE_BEND,checked:false,phases:{},roots:[],complete:false};let phase='load';
 const timed=async(name,fn)=>{phase=name;const start=performance.now();try{return await fn();}finally{report.phases[name]=performance.now()-start;}};
 const start=performance.now();
 try{
  const book=B.book_nil();await timed('load',()=>B.book_load(book,request.input,'',new Map()));
  await timed('check-and-owned',()=>{B.book_valid(book);C.book_owned(book,C.SYNTH);if(book.hols+book.open)throw Error('Unresolved holes/laws');report.checked=true;});
  // Exact structural counterpart of j_library_roots: Def, no templates,
  // value present (including Foreign), and non-Base or Foreign.
  report.roots=[...new Set(book.order)].filter(k=>{const d=book.tlds[k];return d.$==='Def'&&d.x===0&&(d.v!==null||d.i!==undefined)&&(!d.b||d.i!==undefined);});
  report.baseForeignRoots=report.roots.filter(k=>book.tlds[k].b);
  const missing=report.roots.filter(k=>!request.nativeExports.includes(k));if(missing.length)throw Error('Library roots absent from native output: '+missing.join(','));
  report.rootsPresentInNative=true;
  const code=await timed('emit',()=>C.js_lib(book,report.roots,report.roots));
  report.outputBytes=Buffer.byteLength(code);report.compileMs=performance.now()-start;
  fs.writeFileSync(request.output,code);report.outputSha256=sha(request.output);report.complete=true;
 }catch(error){report.error=error?.$==='Err'?B.err_show(error):String(error);report.failedPhase=phase;report.compileMs=performance.now()-start;process.exitCode=1;}
 save(request.result,report);
}else{
 const [configFile,outArgument]=process.argv.slice(2);if(!configFile||!outArgument)throw Error('usage: native-fullsource-upstream.mjs CONFIG.json NEW_OUTPUT_DIRECTORY');
 const config=JSON.parse(fs.readFileSync(configFile,'utf8')),resolve=p=>fs.realpathSync(path.resolve(path.dirname(path.resolve(configFile)),p));
 const [upstream,input,base,nativeApi,nativeBuild]=['upstream','input','base','nativeApi','nativeBuild'].map(k=>resolve(config[k]));
 const cpu=config.cpu,repetitions=config.repetitions??1,timeoutMs=config.timeoutMs??60000;if(!Number.isSafeInteger(cpu)||!Number.isSafeInteger(repetitions)||repetitions<1||repetitions>3)throw Error('Explicit CPU and 1–3 repetitions required');
 const git=args=>{const p=spawnSync('git',['-C',upstream,...args],{encoding:'utf8'});if(p.status!==0)throw Error(p.stderr);return p.stdout.trim();};
 const pin=git(['rev-parse','HEAD']);if(pin!==JSON.parse(fs.readFileSync(nativeBuild,'utf8')).pin||git(['status','--porcelain','--untracked-files=no']))throw Error('Pinned upstream is modified or revision differs');
 const output=path.resolve(outArgument),snapshot=path.join(output,'upstream');fs.mkdirSync(output,{recursive:false});fs.mkdirSync(snapshot);
 if(fs.existsSync(path.join(output,'report.json')))throw Error('Output report already exists');
 for(const name of ['bend.ts','comp.ts']){fs.copyFileSync(path.join(upstream,'bend2',name),path.join(snapshot,name));if(sha(path.join(snapshot,name))!==sha(path.join(upstream,'bend2',name)))throw Error('Snapshot differs');}
 fs.symlinkSync(base,path.join(snapshot,'base.bend'));fs.symlinkSync(path.join(path.dirname(base),'effs'),path.join(snapshot,'effs'));
 const native=await import(pathToFileURL(nativeApi)),nativeExports=Object.keys(native.default);
 const inputs=[tool,process.execPath,input,base,nativeApi,nativeBuild,fs.realpathSync(configFile),...['bend.ts','comp.ts'].flatMap(name=>[path.join(upstream,'bend2',name),path.join(snapshot,name)]),...fs.readdirSync(path.join(path.dirname(base),'effs')).map(name=>path.join(path.dirname(base),'effs',name))];
 const hashes=Object.fromEntries(inputs.filter(p=>fs.statSync(p).isFile()).map(p=>[p,sha(p)]));
 const report={kind:'pinned-typescript-full-source-library',started:new Date().toISOString(),upstream,pin,trackedClean:true,snapshot,input,base,nativeApi,nativeBuild,cpu,repetitions,timeoutMs,node:process.version,nodeArgs:['--stack-size=4096','--max-old-space-size=12288'],hashes,scope:'Unmodified pinned bend.ts/comp.ts copied to a private directory; Base symlink resolves to exactly the native/JS proof Base path. Module location differs from the pinned checkout. Every fresh process performs load, full checking, ownership/TODO gates and library emission. Roots follow j_library_roots, including Base foreign definitions. No persistent Base cache. Subsequent CPU1 samples, not paired/interleaved with native CPU3 timing.',rows:[],complete:false};
 const reportFile=path.join(output,'report.json'),flush=()=>save(reportFile,report);
 const child=args=>spawnSync('taskset',['-c',String(cpu),process.execPath,...report.nodeArgs,...args],{encoding:'utf8',timeout:timeoutMs,maxBuffer:16*1024*1024});flush();
 for(let repetition=0;repetition<repetitions;repetition++){
  const request={snapshot,input,base,nativeExports,output:path.join(output,`library-${repetition}.mjs`),result:path.join(output,`sample-${repetition}.json`)},requestFile=path.join(output,`request-${repetition}.json`);save(requestFile,request);
  console.error('[upstream full source] sample '+repetition);const start=performance.now(),p=child([tool,'--worker',requestFile]);
  const row={repetition,processWallMs:performance.now()-start,status:p.status,error:p.error?.message,stderr:p.stderr,passed:false};report.rows.push(row);
  if(fs.existsSync(request.result))row.compilation=JSON.parse(fs.readFileSync(request.result,'utf8'));
  if(p.status===0&&!p.error&&row.compilation?.complete){
   const syntax=child(['--check',request.output]);row.syntax={status:syntax.status,stderr:syntax.stderr};
   const roots=row.compilation.roots;const oracle=`const api=(await import(${JSON.stringify(pathToFileURL(request.output).href)})).default;const roots=${JSON.stringify(roots)};if(JSON.stringify(Object.keys(api))!==JSON.stringify(roots))throw Error('Export roots differ');if(api.f_ascii_ident_code(65)!==true||api.f_ascii_ident_code(128512)!==false)throw Error('ASCII helper oracle differs');console.log(JSON.stringify({exports:roots.length,asciiOracle:true}));`;
   const execution=child(['--input-type=module','-e',oracle]);row.execution={status:execution.status,stdout:execution.stdout,stderr:execution.stderr};row.passed=syntax.status===0&&!syntax.error&&execution.status===0&&!execution.error;
  }
  flush();if(!row.passed)break;
 }
 report.inputsUnchanged=Object.entries(hashes).every(([p,h])=>sha(p)===h);report.trackedStillClean=git(['rev-parse','HEAD'])===pin&&!git(['status','--porcelain','--untracked-files=no']);report.complete=report.inputsUnchanged&&report.trackedStillClean&&report.rows.length===repetitions&&report.rows.every(r=>r.passed);report.finished=new Date().toISOString();flush();console.log(JSON.stringify({report:reportFile,complete:report.complete,rows:report.rows.map(r=>({passed:r.passed,processWallMs:r.processWallMs,compileMs:r.compilation?.compileMs,error:r.compilation?.error,syntax:r.syntax,execution:r.execution}))}));if(!report.complete)process.exitCode=1;
}
