// P5-003 selected compiler observations. Correctness only, not a timing harness.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {spawnSync} from 'node:child_process';import {pathToFileURL} from 'node:url';
import {deriveEquality,verifyEqualityDerivation} from '../../development/equality.mjs';
const hash=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const identity=f=>({file:path.resolve(f),sha256:hash(f)});
const save=(f,x)=>fs.writeFileSync(f,JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const same=xs=>xs.forEach(x=>assert.equal(hash(x.file),x.sha256,'changed input '+x.file));
function captured(command,args,stem,options={}) {
  const a=fs.openSync(stem+'.stdout','wx'),b=fs.openSync(stem+'.stderr','wx');
  try {const result=spawnSync(command,args,{timeout:120000,...options,stdio:['ignore',a,b]});assert.equal(result.error,undefined,String(result.error));assert.equal(result.signal,null);assert.equal(result.status,0,fs.readFileSync(stem+'.stderr','utf8'));return {status:result.status,signal:result.signal};}
  finally {fs.closeSync(a);fs.closeSync(b);}
}
if(process.argv[2]==='--worker') {
  const request=JSON.parse(fs.readFileSync(process.argv[3],'utf8'));same(request.inputs);
  const D=await import(pathToFileURL(request.driver)),api=await D.loadApi();await D.prepareBase(api);
  const rows=[];
  for(const item of request.cases) {
    const result=await D.inspect(item.file,{mode:item.mode,api,withReport:true});
    assert.equal(result.status,item.status,item.id+': '+JSON.stringify(result));assert.equal(result.phase,item.phase,item.id);
    if(result.code) {
      const emitted=path.join(request.directory,item.id+'.mjs');fs.writeFileSync(emitted,result.code,{flag:'wx'});
      const stem=path.join(request.directory,item.id+'-run');captured(process.execPath,[emitted],stem);
      result.output=fs.readFileSync(stem+'.stdout','utf8');assert.equal(result.output.trim(),item.output,item.id+' output');
      result.codeSha256=hash(emitted);result.codeBytes=Buffer.byteLength(result.code);delete result.code;
    }
    rows.push({id:item.id,result});
  }
  same(request.inputs);save(path.join(request.directory,'observations.json'),{complete:true,rows});
}else{
  const [preparedArg,outArg]=process.argv.slice(2);assert.ok(preparedArg&&outArg,'usage: equality-probe.mjs PREPARED_TWO_PROJECTS FRESH_OUTPUT');
  const prepared=path.resolve(preparedArg),output=path.resolve(outArg);fs.mkdirSync(output);
  const report={kind:'phase5-equality-selected-compiler-gate',complete:false,started:new Date().toISOString(),measurement:'Correctness only; no benchmark claim',inputs:[identity(import.meta.filename),identity(new URL('../../development/equality.mjs',import.meta.url).pathname),identity(process.execPath)],rows:[]};
  const fixtures=path.join(output,'fixtures');fs.mkdirSync(fixtures);
  const content={
    'simple.bend':'import Base\ndef main() -> U32:\n  42\n',
    'unicode.bend':'import Base\ndef main() -> U32:\n  Bool.to_u32(String.eq("🙂λ", "🙂λ"))\n',
    'parse-negative.bend':'import Base\ndef main( -> U32:\n  42\n',
    'type-negative.bend':'import Base\ndef main() -> U32:\n  True{}\n',
    'Lib.bend':'import Base\ndef value() -> U32:\n  42\n',
    'import.bend':'import Base\nimport ./Lib.bend as Lib\ndef main() -> U32:\n  Lib.value\n',
    'Bad.bend':'import Base\ndef value() -> U32:\n  True{}\n',
    'import-negative.bend':'import Base\nimport ./Bad.bend as Bad\ndef main() -> U32:\n  Bad.value\n'
  };
  for(const [name,text]of Object.entries(content)){const file=path.join(fixtures,name);fs.writeFileSync(file,text);report.inputs.push(identity(file));}
  const cases=[['simple','compile','ok','compile','42'],['unicode','compile','ok','compile','1'],['parse-negative','check','error','parse'],['type-negative','check','error','check'],['import','compile','ok','compile','42'],['import-negative','check','error','check']].map(([name,mode,status,phase,expected])=>({id:name,file:path.join(fixtures,name+'.bend'),mode,status,phase,output:expected}));
  try {
    for(const build of ['a','b']) {
      const project=path.join(prepared,build),api=path.join(project,'api.mjs'),bootstrapReport=api+'.bootstrap.json';
      const derived=await deriveEquality({api,bootstrapReport,outputDirectory:path.join(output,build+'-derivation')});
      verifyEqualityDerivation(derived.report);
      const inputs=[api,bootstrapReport,derived.api,derived.report,...['typed-driver','compiler-abi','assemble','native-build','node-resource-args'].map(n=>path.join(project,'tools',n+'.mjs')),path.join(project,'src/runtime.mjs'),process.env.BEND_BASE].map(identity);
      report.inputs.push(...inputs);const observations=[];
      for(const [variant,selected]of [['original',api],['derived',derived.api]]) {
        const directory=path.join(output,build+'-'+variant);fs.mkdirSync(directory);
        const request={driver:path.join(project,'tools/typed-driver.mjs'),directory,cases,inputs:[...inputs,...report.inputs.filter(x=>x.file.startsWith(fixtures+path.sep))]};
        const file=path.join(directory,'request.json');save(file,request);
        captured(process.execPath,['--stack-size=4096','--max-old-space-size=4096',import.meta.filename,'--worker',file],path.join(directory,'worker'),{env:{...process.env,BEND_TYPED_API:selected,BEND_TYPED_RUNTIME:path.join(project,'src/runtime.mjs')}});
        const observed=JSON.parse(fs.readFileSync(path.join(directory,'observations.json'),'utf8'));assert.equal(observed.complete,true);observations.push(observed.rows);
        report.rows.push({build,variant,api:identity(selected),request:identity(file),observation:identity(path.join(directory,'observations.json'))});
      }
      assert.deepEqual(observations[1],observations[0],build+' full compiler observations');
      for(const item of cases.filter(x=>x.mode==='compile'))assert.ok(fs.readFileSync(path.join(output,build+'-original',item.id+'.mjs')).equals(fs.readFileSync(path.join(output,build+'-derived',item.id+'.mjs'))),'actual output bytes '+item.id);
    }
    const a=JSON.parse(fs.readFileSync(path.join(prepared,'a/api.mjs.bootstrap.json'),'utf8')),b=JSON.parse(fs.readFileSync(path.join(prepared,'b/api.mjs.bootstrap.json'),'utf8'));
    assert.notEqual(a.sourceSha256,b.sourceSha256);assert.notEqual(a.apiSha256,b.apiSha256);report.sources=[a,b].map(x=>({api:x.apiSha256,source:x.sourceSha256}));
    same(report.inputs);report.complete=true;report.observations=24;report.byteExactProgramPairs=6;
  }catch(error){report.error=String(error.stack);process.exitCode=1;}
  report.finished=new Date().toISOString();save(path.join(output,'report.json'),report);console.log(JSON.stringify(report));
}
