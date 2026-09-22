// Build a checked isolated source overlay against the immutable phase3 baseline.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {spawn,spawnSync} from 'node:child_process';import {pathToFileURL} from 'node:url';
const [overlayFile,outputFile,mode]=process.argv.slice(2);if(!outputFile||(mode&&mode!=='--in-process'))throw Error('Usage: analysis-build.mjs OVERLAY_ROOT NEW_OUTPUT_ROOT [--in-process]');
const project=path.resolve(import.meta.dirname,'../../..'),baseline=path.join(project,'build/phase3/baseline'),overlay=path.resolve(overlayFile),out=path.resolve(outputFile),upstream=path.join(project,'.bootstrap/upstream');fs.mkdirSync(out,{recursive:false});
const sha=x=>crypto.createHash('sha256').update(x).digest('hex'),manifest=JSON.parse(fs.readFileSync(path.join(baseline,'src/compiler.json'),'utf8')),captured=[];
async function git(args,label){
  const output=path.join(out,label+'.stdout'),error=path.join(out,label+'.stderr'),a=fs.openSync(output,'wx'),b=fs.openSync(error,'wx');
  try{await new Promise((resolve,reject)=>{const child=spawn('git',['-C',upstream,...args],{stdio:['ignore',a,b]});const alarm=setTimeout(()=>{child.kill('SIGKILL');reject(Error('Git identity check timed out'));},30000);child.once('error',e=>{clearTimeout(alarm);reject(e);});child.once('close',code=>{clearTimeout(alarm);code===0?resolve():reject(Error('Git identity check failed: '+fs.readFileSync(error,'utf8')));});});}
  finally{fs.closeSync(a);fs.closeSync(b);}
  return fs.readFileSync(output,'utf8').trim();
}
if(await git(['rev-parse','HEAD'],'revision')!==manifest.upstream||await git(['status','--porcelain','--untracked-files=no'],'status'))throw Error('Expected a clean pinned upstream checkout');
const upstreamFiles=['bend.ts','comp.ts','base.bend'].map(name=>{const file=path.join(upstream,'bend2',name);return {file,canonicalPath:fs.realpathSync(file),sha256:sha(fs.readFileSync(file))};});
for(const file of manifest.modules){const replacement=path.join(overlay,file),from=fs.existsSync(replacement)?replacement:path.join(baseline,file),bytes=fs.readFileSync(from),to=path.join(out,'sources',file);fs.mkdirSync(path.dirname(to),{recursive:true});fs.writeFileSync(to,bytes);captured.push({file,from,sha256:sha(bytes),overridden:from===replacement});}
const assembler=path.join(baseline,'tools/assemble.mjs'),stage0=path.join(baseline,'tools/stage0-library.mjs'),{assemble}=await import(pathToFileURL(assembler));const source=path.join(out,'compiler.bend'),api=path.join(out,'api.mjs');assemble(manifest.modules,source,{root:path.join(out,'sources')});
const {default:B}=await import(pathToFileURL(path.join(baseline,'api/b1.mjs')));const roots=Object.keys(B),started=performance.now();
let child;
if(mode==='--in-process'){
  // Explicit checked build for hosts where synchronous child supervision fails.
  // The caller must provide its own process deadline and Node resource limits.
  const U=await import(pathToFileURL(path.join(upstream,'bend2/bend.ts'))),C=await import(pathToFileURL(path.join(upstream,'bend2/comp.ts')));
  try{const book=U.book_nil();await U.book_load(book,source,'',new Map());U.book_valid(book);C.book_owned(book,C.SYNTH);if(book.hols+book.open)throw Error('Unresolved laws/holes');fs.writeFileSync(api,C.js_lib(book,roots,roots));child={status:0,signal:null,stdout:'',stderr:'Checked '+roots.length+' API exports in process'};}
  catch(error){child={status:1,signal:null,stdout:'',stderr:error?.$==='Err'?U.err_show(error):String(error)};}
}else child=spawnSync(process.execPath,['--stack-size=4096','--max-old-space-size=4096',stage0,source,api,...roots],{cwd:project,env:{...process.env,BEND_UPSTREAM:upstream},encoding:'utf8',timeout:120000,maxBuffer:4*1024*1024});
const inputsUnchanged=upstreamFiles.every(input=>fs.realpathSync(input.file)===input.canonicalPath&&sha(fs.readFileSync(input.file))===input.sha256);
const report={upstreamFiles,inputsUnchanged,kind:'phase3-checked-isolated-overlay',source,sourceSha256:sha(fs.readFileSync(source)),api,apiSha256:fs.existsSync(api)?sha(fs.readFileSync(api)):null,modules:captured,roots,tools:[assembler,stage0].map(file=>({file,sha256:sha(fs.readFileSync(file))})),upstream:manifest.upstream,node:process.version,buildMode:mode||'child',elapsedMs:performance.now()-started,status:child.status,signal:child.signal,error:child.error?.message,stdout:child.stdout,stderr:child.stderr,complete:inputsUnchanged&&child.status===0&&!child.error};fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report,null,2));if(!report.complete)process.exitCode=1;
