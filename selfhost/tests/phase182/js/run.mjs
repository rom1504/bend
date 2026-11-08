// Root runs this finite paired gate inside the Phase182 resource guard.
// No upstream book edits, export filtering, compiler patches, or API bootstrap.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawnSync,execFileSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
const own=fileURLToPath(import.meta.url),here=path.dirname(own);
const project=path.resolve(here,'../../..');
const revision='9a4223d577ba56a0cb53d1fd952d2b481c38930f';
const digest=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return {file,bytes:bytes.length,sha256:digest(bytes)}};
const save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n');
const opts={};
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i];
  if(!/^--[a-z-]+$/.test(key)||process.argv[i+1]===undefined||Object.hasOwn(opts,key.slice(2)))throw Error('expected unique --name value options');
  opts[key.slice(2)]=process.argv[i+1];
}

async function worker(){
  const report={kind:'phase182-js-compilation',version:1,compiler:opts.worker,mode:opts.mode,complete:false,typeAccepted:false,kernelChecked:false};
  let B;
  const start=performance.now();
  try{
    const source=path.resolve(opts.source),upstream=path.resolve(opts.upstream);
    let code,inputs;
    if(opts.worker==='upstream'){
      B=await import(pathToFileURL(path.join(upstream,'bend2/bend.ts')));
      const C=await import(pathToFileURL(path.join(upstream,'bend2/comp.ts')));
      const book=B.book_nil(),seen=new Map();
      await B.book_load(book,source,'',seen);
      B.book_valid(book);
      assert.equal(book.hols,0,'upstream checked book still contains holes');
      report.typeAccepted=true;
      code=opts.mode==='library'?C.js_lib(book,true):C.js_book(book);
      if(opts.mode!=='library')code='import {createRequire} from "node:module";\nconst require=createRequire(import.meta.url);\n'+code;
      inputs=[...seen.keys(),...Object.values(book.tlds).flatMap(d=>d.i??[])];
    }else if(opts.worker==='selfhost'){
      process.env.BEND_TYPED_API=path.resolve(opts.api);
      process.env.BEND_BASE=path.join(upstream,'bend2/base.bend');
      process.env.BEND_UPSTREAM=upstream;
      process.env.BEND_TYPED_BASE_CACHE='off';
      const driver=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs')));
      const result=await driver.inspect(source,{mode:opts.mode,backend:'direct',useBaseCache:false});
      const {code:emitted,...observation}=result;
      report.observation=observation;
      report.typeAccepted=result.typeAccepted===true;
      assert.equal(result.status,'ok',result.diagnostic??'selfhost compilation failed');
      assert.equal(typeof emitted,'string','selfhost emitted no source');
      code=emitted;inputs=result.files??[];
    }else throw Error('unknown worker '+opts.worker);
    fs.writeFileSync(opts.target,code,{flag:'wx'});
    report.artifact=pin(opts.target);
    report.inputs=[...new Set(inputs.map(f=>fs.realpathSync(f)))].map(pin);
    report.status='pass';
  }catch(error){
    report.status='fail';
    report.error=error?.$==='Err'&&B?B.err_show(error):String(error?.stack??error);
    process.exitCode=1;
  }finally{
    report.seconds=(performance.now()-start)/1000;report.complete=true;
    save(opts.meta,report);
  }
}

async function main(){
  for(const key of ['out','api','upstream'])if(!opts[key])throw Error('usage: node run.mjs --out FRESH --api API.mjs --upstream PINNED_CHECKOUT [--timeout-ms 120000]');
  const out=path.resolve(opts.out),api=path.resolve(opts.api),upstream=path.resolve(opts.upstream);
  const timeout=Number(opts['timeout-ms']??120000);
  assert.ok(Number.isSafeInteger(timeout)&&timeout>0,'positive timeout required');
  fs.mkdirSync(path.dirname(out),{recursive:true});fs.mkdirSync(out);
  const report={kind:'phase182-js-paired',version:1,complete:false,status:'running',started:new Date().toISOString(),upstream:{file:upstream,revision},stages:[],inputs:[]};
  const reportFile=path.join(out,'report.json');
  const write=()=>save(reportFile,report);write();
  const run=(name,args)=>{
    const stdout=path.join(out,name+'.stdout'),stderr=path.join(out,name+'.stderr');
    const a=fs.openSync(stdout,'wx'),b=fs.openSync(stderr,'wx'),start=performance.now();
    let child;
    try{child=spawnSync(process.execPath,[...process.execArgv,...args],{cwd:out,timeout,stdio:['ignore',a,b],env:{...process.env,BEND_TYPED_BASE_CACHE:'off'}})}finally{fs.closeSync(a);fs.closeSync(b)}
    const row={name,command:[process.execPath,...process.execArgv,...args],seconds:(performance.now()-start)/1000,exitCode:child.status,signal:child.signal??null,error:child.error?String(child.error):null,stdout:pin(stdout),stderr:pin(stderr)};
    row.status=child.status===0&&!child.error?'pass':'fail';report.stages.push(row);write();return row;
  };
  try{
    const actual=execFileSync('git',['-C',upstream,'rev-parse','HEAD'],{encoding:'utf8'}).trim();
    assert.equal(actual,revision,'upstream checkout is not the migration pin');
    execFileSync('git',['-C',upstream,'diff','--quiet','HEAD','--','bend2']);
    report.upstream.trackedSourcesClean=true;
    const tools=['typed-driver.mjs','compiler-abi.mjs','bootstrap-config.mjs','js-effect-provider.mjs','runtime-arguments.mjs'];
    const inputs=[own,api,process.execPath,...['bend.ts','comp.ts','base.bend'].map(n=>path.join(upstream,'bend2',n)),
      ...tools.map(n=>path.join(project,'tools',n)),path.join(project,'src/compiler.json'),path.join(project,'src/runtime/js/direct.mjs'),path.join(project,'src/runtime/js/effs/manifest.json'),
      ...fs.readdirSync(here).filter(n=>/\.(bend|js|mjs)$/.test(n)).map(n=>path.join(here,n)),
      ...fs.readdirSync(path.join(project,'src/runtime/js/effs')).filter(n=>n.endsWith('.js')).map(n=>path.join(project,'src/runtime/js/effs',n))];
    const acquisition=path.join(path.dirname(api),'report.json');if(fs.existsSync(acquisition))inputs.push(acquisition);
    report.inputs=[...new Set(inputs.map(f=>fs.realpathSync(f)))].map(pin);
    report.engine={file:process.execPath,node:process.version,bun:globalThis.Bun?.version??null,execArgv:process.execArgv};write();
    for(const fixture of ['library','foreign'])for(const compiler of ['upstream','selfhost']){
      const name=compiler+'-'+fixture,meta=path.join(out,name+'.json');
      const row=run(name,[own,'--worker',compiler,'--source',path.join(here,fixture+'.bend'),'--mode',fixture==='library'?'library':'compile',
        '--target',path.join(out,name+'.mjs'),'--meta',meta,'--upstream',upstream,'--api',api]);
      if(fs.existsSync(meta)){row.compilation=JSON.parse(fs.readFileSync(meta,'utf8'));report.inputs.push(...(row.compilation.inputs??[]));}
      write();
    }
    if(report.stages.filter(s=>s.name.endsWith('-library')).every(s=>s.status==='pass'))run('library-compare',[path.join(here,'compare.mjs'),path.join(out,'upstream-library.mjs'),path.join(out,'selfhost-library.mjs')]);
    const expected=fs.readFileSync(path.join(here,'foreign.bend'),'utf8').split('\n').filter(s=>s.startsWith('#|')).map(s=>s.slice(2)).join('\n')+'\n';
    for(const compiler of ['upstream','selfhost'])if(report.stages.find(s=>s.name===compiler+'-foreign')?.status==='pass'){
      const row=run(compiler+'-foreign-run',[path.join(out,compiler+'-foreign.mjs')]);
      row.expectedStdout=expected;row.outputMatches=fs.readFileSync(row.stdout.file,'utf8')===expected&&fs.readFileSync(row.stderr.file,'utf8')==='';
      if(!row.outputMatches)row.status='fail';write();
    }
    for(const input of report.inputs)assert.equal(pin(input.file).sha256,input.sha256,'input changed during paired gate: '+input.file);
    report.inputsStable=true;
    report.status=report.stages.length===7&&report.stages.every(s=>s.status==='pass')?'pass':'fail';
    if(report.status!=='pass')report.error=report.stages.filter(s=>s.status!=='pass').map(s=>s.name+': '+(s.compilation?.error??s.error??fs.readFileSync(s.stderr.file,'utf8')??'failed')).join('\n');
  }catch(error){report.status='fail';report.error=String(error?.stack??error)}
  finally{report.complete=true;report.finished=new Date().toISOString();write();console.log(JSON.stringify({report:reportFile,status:report.status}));if(report.status!=='pass')process.exitCode=1}
}

if(opts.worker)await worker();else await main();
