// Root-run current-release emitter identity. Never times or executes user programs.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';

const [planArg,role,outArg,scope='both']=process.argv.slice(2);
assert(['b1','b2'].includes(role)&&['js','c','both'].includes(scope));
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,sha256:hash(b),bytes:b.length};};
const verify=p=>{const q=pin(p.file);assert.equal(q.sha256,p.sha256,p.file);if(p.bytes!==undefined)assert.equal(q.bytes,p.bytes,p.file);return q;};
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const plan=read(planArg),known=new Map(plan.inputs.map(p=>[p.file,p])),host=plan.host;
const report={kind:'phase91-current-release-js23-c12-continuity-result',complete:false,pass:false,
  programExecution:false,benchmarkTiming:false,role,scope,plan:pin(planArg),method:pin(import.meta.filename),
  sourceRole:plan.roles[role],release:plan.release,rows:[],inputs:plan.inputs,
  statement:'Historical speed transfers only on the declared complete output/runtime identity boundary. No new speed, binary identity, GPU or universal-conformance claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
const requestFiles=result=>{
  const rows=(result.files??[]).map(pin);
  for(const p of rows){assert(known.has(p.file),'Unbound request input '+p.file);verify(known.get(p.file));}
  return rows;
};
const env={...process.env};
for(const key of Object.keys(env))if(key.startsWith('BEND_')||['NODE_OPTIONS','NODE_PATH','CPATH','C_INCLUDE_PATH','CPLUS_INCLUDE_PATH','OBJC_INCLUDE_PATH','DEPENDENCIES_OUTPUT','SUNPRO_DEPENDENCIES'].includes(key))delete env[key];
env.SOURCE_DATE_EPOCH='0';
const cpp=(name,tag,input)=>{
  const output=path.join(out,`${name}.${tag}.i`),stderr=path.join(out,`${name}.${tag}.stderr`);
  plan.headers.forEach(verify);
  const files=[fs.openSync(input,'r'),fs.openSync(output,'wx'),fs.openSync(stderr,'wx')];
  let child;
  try{child=spawnSync(plan.clang.file,[...plan.clangArgs,'-x','c','-E','-P','-fminimize-whitespace','-H','-'],
    {cwd:plan.cwd,env,stdio:files,timeout:20000,killSignal:'SIGKILL'});}
  finally{files.forEach(fd=>fs.closeSync(fd));}
  assert.equal(child.status,0,`${name}/${tag}: ${child.error??fs.readFileSync(stderr,'utf8').slice(-2000)}`);
  const headers=[...new Set([...fs.readFileSync(stderr,'utf8').matchAll(/^\.+ (.+)$/gm)].map(x=>x[1]))].sort();
  const admitted=new Map(plan.headers.map(p=>[p.file,p]));
  assert(headers.length>0);for(const file of headers){assert(admitted.has(file),'Unbound header '+file);verify(admitted.get(file));}
  const result={input:pin(input),output:pin(output),stderr:pin(stderr),headers};
  assert(result.output.bytes<16*1024**2,'Preprocessor output exceeds bound');
  return result;
};
try{
  assert.equal(plan.kind,'phase91-current-release-js23-c12-continuity');
  verify(plan.method);assert.equal(pin(import.meta.filename).sha256,plan.method.sha256);
  assert.equal(fs.realpathSync(process.execPath),plan.node.file);plan.inputs.forEach(verify);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_')||['NODE_OPTIONS','NODE_PATH'].includes(key))delete process.env[key];
  process.env.BEND_TYPED_API=plan.roles[role].file;process.env.BEND_TYPED_RUNTIME=host.runtime.file;process.env.BEND_BASE=host.base.file;
  const D=await import(pathToFileURL(host.driver.file));const api=await D.loadApi();
  assert.equal(D.apiPath,plan.roles[role].file);assert.equal(D.project,host.project);
  assert.equal(D.runtimePath,host.runtime.file);assert.equal(D.basePath,host.base.file);
  await D.prepareBase(api);
  report.preparedBase=true;save();
  if(scope!=='c')for(const item of plan.jsCases){
    verify(item.source);verify(item.oracle);
    const result=await D.inspect(item.source.file,{mode:'library',backend:'direct'});
    const {code,...observation}=result;
    assert.equal(result.status,'ok',result.diagnostic);assert(result.checked&&result.typeAccepted);
    assert.equal(result.backend,'direct');assert.equal(result.exitCode,0);assert.equal(typeof code,'string');
    const file=path.join(out,item.name+'.mjs');fs.writeFileSync(file,code,{flag:'wx'});
    const row={kind:'js',name:item.name,source:item.source,oracle:item.oracle,output:pin(file),observation,
      requestInputs:requestFiles(result),exact:Buffer.from(code).equals(fs.readFileSync(item.oracle.file))};
    report.rows.push(row);save();console.log(JSON.stringify({role,kind:row.kind,name:row.name,exact:row.exact}));
  }
  if(scope!=='js')for(const item of plan.cCases){
    verify(item.source);verify(item.oracle);
    const result=await D.inspect(item.source.file,{mode:'native',withReport:true});
    const {code,...observation}=result;assert.equal(result.status,'ok',result.diagnostic);assert(result.checked);assert.equal(typeof code,'string');
    const file=path.join(out,item.name+'.c');fs.writeFileSync(file,code,{flag:'wx'});
    const fids=[...code.matchAll(/^#define FID_ENTER (\d+)$/gm)];assert.equal(fids.length,1);assert(Number(fids[0][1])<4096);
    const row={kind:'c',name:item.name,source:item.source,oracle:item.oracle,output:pin(file),observation,
      requestInputs:requestFiles(result),fidEnter:Number(fids[0][1]),rawExact:Buffer.from(code).equals(fs.readFileSync(item.oracle.file))};
    row.old=cpp(item.name,'old',item.oracle.file);row.current=cpp(item.name,'current',file);
    assert.deepEqual(row.old.headers,row.current.headers);
    row.exact=fs.readFileSync(row.old.output.file).equals(fs.readFileSync(row.current.output.file));
    if(row.exact){fs.unlinkSync(row.old.output.file);fs.unlinkSync(row.current.output.file);row.cppRemovedAfterFullByteComparison=true;}
    report.rows.push(row);save();console.log(JSON.stringify({role,kind:row.kind,name:row.name,exact:row.exact}));
  }
  plan.inputs.forEach(verify);verify(report.plan);
  const expected=(scope==='c'?0:23)+(scope==='js'?0:12);assert.equal(report.rows.length,expected);
  report.inputsUnchanged=true;report.complete=true;report.pass=report.rows.every(r=>r.exact);
  report.counts={js:report.rows.filter(r=>r.kind==='js').length,c:report.rows.filter(r=>r.kind==='c').length,
    exact:report.rows.filter(r=>r.exact).length};
  if(!report.pass)process.exitCode=1;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,role,counts:report.counts,error:report.error}));}
