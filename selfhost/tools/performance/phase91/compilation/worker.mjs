// Fresh ordinary compiler requests; measured call shapes preserve Phase66/82.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [planFile,target,role,action,name,outArg]=process.argv.slice(2);
const out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const hash=x=>createHash('sha256').update(x).digest('hex');
const pin=file=>{const b=fs.readFileSync(file);return {file:fs.realpathSync(file),sha256:hash(b),bytes:b.length};};
const verify=p=>{const a=pin(p.file);assert.equal(a.sha256,p.sha256,p.file);assert.equal(a.bytes,p.bytes,p.file);return a;};
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const plan=read(planFile),host=plan.targets[target],image=host?.images[role],isTS=role==='typescript';
const report={kind:'phase91-current-compiler-latency-job',complete:false,pass:false,target,role,action,name,
  plan:pin(planFile),method:pin(import.meta.filename),timings:{},outputs:[],node:process.version,
  v8:process.versions.v8,execArgv:process.execArgv};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const cacheFiles=()=>['cache','base-products'].flatMap(s=>{
  const directory=path.join(host.project,'build/typed',s);
  return fs.existsSync(directory)?fs.readdirSync(directory).sort().filter(n=>n.includes(image.api.sha256)&&n.includes(image.base.sha256)).map(n=>pin(path.join(directory,n))):[];
});
try{
  assert.equal(plan.kind,'phase91-current-compiler-latency-plan');assert(['js','c'].includes(target));
  assert(plan.roles.includes(role));assert(['prepare','sample'].includes(action));
  assert.equal(fs.realpathSync(process.execPath),plan.node.file);assert.deepEqual(process.execArgv,plan.execArgv);
  assert.equal(fs.readFileSync('/proc/self/status','utf8').split('\n').find(x=>x.startsWith('Cpus_allowed_list:')).split(':')[1].trim(),String(plan.cpu));
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_')||['NODE_OPTIONS','NODE_PATH'].includes(key))delete process.env[key];
  const selected=isTS?Object.values(plan.typescript):[...host.selectedInputs,image.api,image.base];selected.forEach(verify);
  let prepared;
  if(action==='sample'){
    prepared=read(path.join(path.dirname(planFile),'runs',`prepare-${target}-${role}`,'report.json'));
    assert(prepared.complete&&prepared.pass&&prepared.inputsUnchanged);assert.deepEqual(prepared.plan,report.plan);
    if(!isTS){prepared.cache.forEach(verify);assert.deepEqual(cacheFiles(),prepared.cache);}
  }
  let D,B,C;
  const imported=performance.now();
  if(isTS){B=await import(pathToFileURL(plan.typescript.bend.file));C=await import(pathToFileURL(plan.typescript.compiler.file));}
  else{
    process.env.BEND_TYPED_API=image.api.file;process.env.BEND_TYPED_RUNTIME=image.runtime.file;process.env.BEND_BASE=image.base.file;
    D=await import(pathToFileURL(image.driver.file));assert.equal(D.apiPath,image.api.file);
    assert.equal(D.project,host.project);assert.equal(D.basePath,image.base.file);
  }
  report.timings.hostImportMs=performance.now()-imported;
  const apiStart=performance.now();const api=isTS?null:await D.loadApi();
  report.timings.apiLoadMs=isTS?0:performance.now()-apiStart;
  if(action==='prepare'&&!isTS){
    assert.equal(cacheFiles().length,0,'A fresh API-specific cache is required');
    const start=performance.now();await D.prepareBase(api,{backendProducts:target==='js'});
    report.timings.basePreparationMs=performance.now()-start;report.cache=cacheFiles();
    assert.equal(report.cache.filter(x=>x.file.includes('/cache/')).length,1);
    assert.equal(report.cache.filter(x=>x.file.includes('/base-products/')).length,target==='js'?1:0);
  }
  const names=action==='prepare'?Object.keys(plan.cases[target]):[name];
  for(const caseName of names){
    const source=plan.cases[target][caseName];verify(source.source);verify(source.tsOracle);
    if(target==='js')verify(source.historicalBendOracle);
    const start=performance.now();let result,code;
    if(isTS){
      const book=B.book_nil();await B.book_load(book,source.source.file,'',new Map());B.book_valid(book);assert.equal(book.hols,0);
      code=target==='js'?C.js_lib(book,true):C.compile_book(book);result={checked:true,status:'ok'};
    }else{
      result=await D.inspect(source.source.file,target==='js'?{mode:'library',backend:'direct'}:{mode:'native',withReport:true});
      code=result.code;
    }
    const firstRequestMs=performance.now()-start;assert.equal(result.status,'ok');assert.equal(result.checked,true);
    if(!isTS&&target==='js'){assert.equal(result.backend,'direct');assert.equal(result.interface,'upstream-callable');}
    assert.equal(typeof code,'string');const bytes=Buffer.from(code),output={sha256:hash(bytes),bytes:bytes.length};
    if(action==='prepare'){
      const file=path.join(out,caseName+(target==='js'?'.mjs':'.c'));fs.writeFileSync(file,bytes,{flag:'wx'});Object.assign(output,pin(file));
      if(isTS||target==='js')assert(bytes.equals(fs.readFileSync((isTS?source.tsOracle:source.historicalBendOracle).file)),
        'Historical complete output changed; preserve output and investigate before timing');
    }else{
      const oracle=prepared.outputs.find(x=>x.case===caseName).output;verify(oracle);
      if(!bytes.equals(fs.readFileSync(oracle.file))){fs.writeFileSync(path.join(out,'mismatch'+(target==='js'?'.mjs':'.c')),bytes);throw Error('Complete output mismatch');}
      report.timings.firstRequestMs=firstRequestMs;
      report.timings.importApiAndFirstMs=report.timings.hostImportMs+report.timings.apiLoadMs+firstRequestMs;
    }
    const {code:ignored,...observation}=result;
    for(const file of observation.files??[])assert(plan.inputs.some(x=>x.file===fs.realpathSync(file)),'Unfrozen request input: '+file);
    report.outputs.push({case:caseName,output,observation,exactOutput:true});
  }
  if(!isTS){const expected=action==='prepare'?report.cache:prepared.cache;expected.forEach(verify);assert.deepEqual(cacheFiles(),expected);}
  selected.forEach(verify);report.inputsUnchanged=true;report.complete=report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,target,role,action,name,timings:report.timings,error:report.error}));
