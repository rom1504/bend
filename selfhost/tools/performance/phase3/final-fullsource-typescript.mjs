// Final checked library compilation by unchanged pinned TypeScript modules.
// Derived from the prior native full-source probe; this records a final H root
// classifier and checked integration provenance, not a paired whole-compile run.
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
  const missing=report.roots.filter(k=>!request.nativeExports.includes(k));if(missing.length)throw Error('Library roots absent from classifier API exports: '+missing.join(','));
  report.rootsPresentInNative=true;
  const code=await timed('emit',()=>C.js_lib(book,report.roots,report.roots));
  report.outputBytes=Buffer.byteLength(code);report.compileMs=performance.now()-start;
  // Metadata transport and the separate parent-side Bend classifier oracle are
  // outside compileMs. This projection contains every field read by j_library_roots.
  report.rootMetadata=[...new Set(book.order)].map(name=>{const d=book.tlds[name];return {name,kind:d.$,templates:d.x??0,base:!!d.b,valueTag:d.i!==undefined?'Foreign':d.v===null?'Absent':'Present'};});
  fs.writeFileSync(request.output,code);report.outputSha256=sha(request.output);report.complete=true;
 }catch(error){report.error=error?.$==='Err'?B.err_show(error):String(error);report.failedPhase=phase;report.compileMs=performance.now()-start;process.exitCode=1;}
 save(request.result,report);
}else{
 const [configFile,outArgument]=process.argv.slice(2);if(!configFile||!outArgument)throw Error('usage: final-fullsource-typescript.mjs CONFIG.json NEW_OUTPUT_DIRECTORY');
 const config=JSON.parse(fs.readFileSync(configFile,'utf8')),resolve=p=>fs.realpathSync(path.resolve(path.dirname(path.resolve(configFile)),p));
 const [upstream,input,base,nativeApi,nativeBuild,proofReport]=['upstream','input','base','classifierApi','integrationReport','proofReport'].map(k=>resolve(config[k]));
 const integration=JSON.parse(fs.readFileSync(nativeBuild)),proof=JSON.parse(fs.readFileSync(proofReport));
 if(integration.kind!=='phase3-checked-integration-api'||!integration.complete||!integration.provenance?.verifiedAfterBuild||sha(integration.api)!==integration.apiSha256||sha(integration.source)!==integration.sourceSha256||fs.realpathSync(integration.source)!==input)throw Error('Final checked integration provenance does not match input');
 for(const record of integration.provenance.inputs)if(fs.realpathSync(record.file)!==record.canonicalPath||sha(record.file)!==record.sha256)throw Error('Integration input changed: '+record.file);
 const stage=proof.stages.find(row=>row.outputSha256===sha(nativeApi));if(!stage||stage.code!==0||!stage.inputsVerified||sha(proof.source)!==proof.sourceSha256||fs.realpathSync(proof.source)!==input||sha(base)!==proof.base.sha256)throw Error('Checked self-emitted classifier/source/Base differs');
 const proofInputs=[proof.sourceIdentity,proof.base,proof.initialCompiler,proof.driver,...proof.hostHelpers];for(const record of proofInputs)if(fs.realpathSync(record.file)!==record.canonicalPath||sha(record.file)!==record.sha256)throw Error('Self-emission input changed: '+record.file);
 const cpu=config.cpu,repetitions=config.repetitions??1,timeoutMs=config.timeoutMs??60000;if(!Number.isSafeInteger(cpu)||cpu<0||!Number.isSafeInteger(timeoutMs)||timeoutMs<=0||!Number.isSafeInteger(repetitions)||repetitions<1||repetitions>3)throw Error('Explicit nonnegative CPU, positive integer timeout and 1–3 repetitions required');
 const git=args=>{const p=spawnSync('git',['-C',upstream,...args],{encoding:'utf8'});if(p.error||p.status!==0)throw Error(p.error?.message||p.stderr);return p.stdout.trim();};
 const pin=git(['rev-parse','HEAD']);if(pin!==integration.provenance.upstream.revision||git(['status','--porcelain','--untracked-files=no']))throw Error('Pinned upstream is modified or revision differs');
 const output=path.resolve(outArgument),snapshot=path.join(output,'upstream');fs.mkdirSync(output,{recursive:false});fs.mkdirSync(snapshot);const consumedTool=path.join(output,'consumed-tool.mjs');fs.copyFileSync(tool,consumedTool);fs.chmodSync(consumedTool,0o444);
 if(fs.existsSync(path.join(output,'report.json')))throw Error('Output report already exists');
 const frozenProof=path.join(output,'self-emission-provenance.json');fs.copyFileSync(proofReport,frozenProof);
 for(const name of ['bend.ts','comp.ts']){fs.copyFileSync(path.join(upstream,'bend2',name),path.join(snapshot,name));if(sha(path.join(snapshot,name))!==sha(path.join(upstream,'bend2',name)))throw Error('Snapshot differs');}
 fs.symlinkSync(base,path.join(snapshot,'base.bend'));fs.symlinkSync(path.join(path.dirname(base),'effs'),path.join(snapshot,'effs'));
 const native=await import(pathToFileURL(nativeApi)),nativeExports=Object.keys(native.default);
 const inputs=[tool,consumedTool,process.execPath,input,base,nativeApi,nativeBuild,frozenProof,...integration.provenance.inputs.map(r=>r.file),...proofInputs.map(r=>r.file),fs.realpathSync(configFile),...['bend.ts','comp.ts'].flatMap(name=>[path.join(upstream,'bend2',name),path.join(snapshot,name)]),...fs.readdirSync(path.join(path.dirname(base),'effs')).map(name=>path.join(path.dirname(base),'effs',name))];
 const hashes=Object.fromEntries(inputs.filter(p=>fs.statSync(p).isFile()).map(p=>[p,sha(p)]));
 const report={kind:'final-pinned-typescript-full-source-library',started:new Date().toISOString(),upstream,pin,trackedClean:true,snapshot,consumedTool,input,base,classifierApi:nativeApi,integrationReport:nativeBuild,selfEmissionProof:{original:proofReport,snapshot:frozenProof,completeAtStart:proof.complete,stageHash:stage.outputSha256},cpu,repetitions,timeoutMs,node:process.version,nodeArgs:['--stack-size=4096','--max-old-space-size=12288'],hashes,scope:'Unmodified pinned bend.ts/comp.ts copied to a private directory; Base symlink resolves to exactly the final self-emission Base path. Module location differs from the pinned checkout. Every fresh process performs load, full checking, ownership/TODO gates and library emission. Roots follow j_library_roots, including Base foreign definitions. No persistent Base cache. Subsequent samples on the explicitly recorded CPU, not paired/interleaved with the separately measured H or native compilation. Root metadata transport and the independent Bend classifier oracle are outside compileMs.',rows:[],complete:false};
 const reportFile=path.join(output,'report.json'),flush=()=>save(reportFile,report);
 const childEnv={...process.env};delete childEnv.NODE_OPTIONS;delete childEnv.BEND_TYPED_TRACE;report.childEnvironmentPolicy='Inherited environment with NODE_OPTIONS and BEND_TYPED_TRACE removed.';
 let childSerial=0;
 const child=args=>{const name='child-'+childSerial++,stdoutFile=path.join(output,name+'.stdout'),stderrFile=path.join(output,name+'.stderr'),stdout=fs.openSync(stdoutFile,'w'),stderr=fs.openSync(stderrFile,'w');let p;try{p=spawnSync('taskset',['-c',String(cpu),process.execPath,...report.nodeArgs,...args],{env:childEnv,timeout:timeoutMs,stdio:['ignore',stdout,stderr]});}finally{fs.closeSync(stdout);fs.closeSync(stderr);}const read=file=>{const size=fs.statSync(file).size;if(size>2**20)throw Error('Child output exceeded limit: '+file);return fs.readFileSync(file,'utf8');};return {...p,stdout:read(stdoutFile),stderr:read(stderrFile),stdoutFile,stderrFile};};flush();
 for(let repetition=0;repetition<repetitions;repetition++){
  const request={snapshot,input,base,nativeExports,output:path.join(output,`library-${repetition}.mjs`),result:path.join(output,`sample-${repetition}.json`)},requestFile=path.join(output,`request-${repetition}.json`);save(requestFile,request);
  console.error('[upstream full source] sample '+repetition);const start=performance.now(),p=child([consumedTool,'--worker',requestFile]);
  const row={repetition,processWallMs:performance.now()-start,status:p.status,error:p.error?.message,stderr:p.stderr,stdoutFile:p.stdoutFile,stderrFile:p.stderrFile,passed:false};report.rows.push(row);
  if(fs.existsSync(request.result))row.compilation=JSON.parse(fs.readFileSync(request.result,'utf8'));
  if(p.status===0&&!p.error&&row.compilation?.complete){
   const nil=native.list([]),atom=tag=>native.ctor('KTerm',[tag,'',0,0,nil,nil]);
   const metadata=row.compilation.rootMetadata;
   const defs=metadata.map(d=>native.ctor('KDef',[d.name,d.kind,0,d.templates,atom('Type'),atom(d.valueTag),nil,d.base,false]));
   let selected=native.default.j_library_roots(native.list(defs));const nativeRoots=[];
   while(selected.$==='Con'){nativeRoots.push(selected.a[0]);selected=selected.a[1];}
   if(selected.$!=='Nil')throw Error('Unexpected library-root list encoding');
   const tsSet=new Set(row.compilation.roots),nativeSet=new Set(nativeRoots);
   row.rootComparison={projectionSha256:createHash('sha256').update(JSON.stringify(metadata)).digest('hex'),projectionRecords:metadata.length,typescriptRoots:tsSet.size,selfEmittedSelectedRoots:nativeSet.size,missingNativeRoots:[...tsSet].filter(k=>!nativeSet.has(k)),extraNativeRoots:[...nativeSet].filter(k=>!tsSet.has(k)),selfEmittedDefaultExports:nativeExports.length,selfEmittedDefaultExportExtras:nativeExports.filter(k=>!tsSet.has(k)),note:'Actual checked self-emitted H j_library_roots applied to checked upstream metadata for the fields it reads. Self-emitted default exports include runtime globals/reachable helpers beyond library roots; exact default-export equality is not required.'};
   row.rootComparison.exactRootSet=row.rootComparison.missingNativeRoots.length===0&&row.rootComparison.extraNativeRoots.length===0;
   delete row.compilation.rootMetadata;
   const syntax=child(['--check',request.output]);row.syntax={status:syntax.status,stderr:syntax.stderr,stdoutFile:syntax.stdoutFile,stderrFile:syntax.stderrFile};
   const roots=row.compilation.roots;const oracle=`const api=(await import(${JSON.stringify(pathToFileURL(request.output).href)})).default;const roots=${JSON.stringify(roots)};if(JSON.stringify(Object.keys(api))!==JSON.stringify(roots))throw Error('Export roots differ');if(api.f_ascii_ident_code(65)!==true||api.f_ascii_ident_code(128512)!==false)throw Error('ASCII helper oracle differs');console.log(JSON.stringify({exports:roots.length,asciiOracle:true}));`;
   const execution=child(['--input-type=module','-e',oracle]);row.execution={status:execution.status,stdout:execution.stdout,stderr:execution.stderr,stdoutFile:execution.stdoutFile,stderrFile:execution.stderrFile};row.passed=row.rootComparison.exactRootSet&&syntax.status===0&&!syntax.error&&execution.status===0&&!execution.error;
  }
  flush();if(!row.passed)break;
 }
 report.inputsUnchanged=Object.entries(hashes).every(([p,h])=>sha(p)===h);report.trackedStillClean=git(['rev-parse','HEAD'])===pin&&!git(['status','--porcelain','--untracked-files=no']);report.complete=report.inputsUnchanged&&report.trackedStillClean&&report.rows.length===repetitions&&report.rows.every(r=>r.passed);report.finished=new Date().toISOString();flush();console.log(JSON.stringify({report:reportFile,complete:report.complete,rows:report.rows.map(r=>({passed:r.passed,processWallMs:r.processWallMs,compileMs:r.compilation?.compileMs,error:r.compilation?.error,syntax:r.syntax,execution:r.execution}))}));if(!report.complete)process.exitCode=1;
}
