// P5-005 correctness falsifier. No timing claims and no compiler source edits.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {spawnSync} from 'node:child_process';import {pathToFileURL} from 'node:url';
const hash=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const identity=f=>({file:path.resolve(f),sha256:hash(f)});
const verify=xs=>xs.forEach(x=>assert.equal(hash(x.file),x.sha256,'changed input '+x.file));
const save=(f,v)=>fs.writeFileSync(f,JSON.stringify(v,null,2)+'\n',{flag:'wx'});
const array=x=>{const out=[];while(x?.$==='Con'){out.push(x.head);x=x.tail;}assert.equal(x?.$,'Nil');return out;};
const semantic=r=>({status:r.status,phase:r.phase,checked:r.checked,exitCode:r.exitCode,diagnostic:r.diagnostic??''});
if(process.argv[2]==='--worker') {
  const request=JSON.parse(fs.readFileSync(process.argv[3],'utf8'));verify(request.inputs);const rows=[];
  if(request.variant==='typescript') {
    const U=await import(pathToFileURL(path.join(request.upstream,'bend2/bend.ts')));
    for(const item of request.cases) {
      let phase='parse',result;try{const book=U.book_nil();await U.book_load(book,item.file,'',new Map());phase='check';U.book_valid(book);result={status:'ok',phase,checked:true,exitCode:0};}
      catch(error){assert.equal(error.$,'Err',String(error));result={status:'error',phase,checked:phase==='check',exitCode:1,diagnostic:U.err_show(error)};}
      rows.push({id:item.id,result:semantic(result)});
    }
  }else{
    const D=await import(pathToFileURL(request.driver)),api=await D.loadApi(),seed=await D.prepareBase(api);
    for(const item of request.cases) {
      const result=await D.inspect(item.file,{mode:'check',api,withReport:true});
      const graph=D.discoverSources(api,item.file,{seed});
      const trace=api.f_load_graph_seed_trace(graph.main,graph.sources,seed.sourcePath,seed.sourceText,seed.book);
      let origins=[];
      if(!trace.result.error)origins=array(api.f_loaded_origins_for(trace,'main').origins).filter(x=>x.term.tag==='App').map(x=>({definition:x.definition,begin:x.begin,end:x.end,anchor:x.source.slice(x.begin,x.end),line:x.source.slice(0,x.begin).split('\n').length,path:array(x.path)}));
      rows.push({id:item.id,result:semantic(result),applicationOrigins:origins});
    }
  }
  verify(request.inputs);save(request.output,{complete:true,rows});
}else{
  const [preparedArg,outputArg]=process.argv.slice(2);assert.ok(preparedArg&&outputArg,'usage: application-origins-probe.mjs PREPARED_PROJECT FRESH_OUTPUT');
  const prepared=path.resolve(preparedArg),output=path.resolve(outputArg);fs.mkdirSync(output);const prep=JSON.parse(fs.readFileSync(path.join(prepared,'preparation.json'),'utf8'));
  const upstream=fs.realpathSync(process.env.BEND_UPSTREAM),base=path.join(upstream,'bend2/base.bend'),project=path.join(prepared,'project'),candidate=path.join(project,'api.mjs');
  const report={kind:'phase5-application-origin-falsifier',complete:false,started:new Date().toISOString(),scope:'Selected exact diagnostic correctness; no timing claim.',inputs:[identity(import.meta.filename),identity(path.join(prepared,'preparation.json')),identity(base),...['bend.ts','comp.ts'].map(n=>identity(path.join(upstream,'bend2',n))),identity(process.execPath)],rows:[]};
  const fixtures=path.join(output,'fixtures');fs.mkdirSync(fixtures);
  const prefix='import Base\n\ndef f(x: Bool) -> Bool:\n  x\n\ndef main() -> Bool:\n';
  const specs=[
    ['single-literal',prefix+'  f(0)\n'],
    ['unicode-literal',prefix+'  f("🙂λ")\n'],
    ['nested-call',prefix+'  f(f(0))\n'],
    ['repeated-call',prefix+'  Bool.and(f(True{}), f(0))\n'],
    ['multiline-literal',prefix+'  f(\n    0\n  )\n',true],
    ['bare-substituted-head',prefix+'  (x => x)(f)(0)\n',true],
    ['wrapped-call-head',prefix+'  (x => x)(\n    f(True{})\n  )(0)\n',true],
    ['substituted-argument',prefix+'  (x => f(x))(\n    0\n  )\n',true],
    ['substituted-argument-single-line',prefix+'  (x => f(x))(0)\n',true],
    ['substituted-source-ref',prefix+'  (x => f(x))(False{})\n',true],
    ['nonfunction-call','import Base\ndef main() -> U32:\n  U32.zero(0)\n'],
    ['multiple-arguments','import Base\ndef both(x: Bool, y: Bool) -> Bool:\n  Bool.and(x,y)\ndef main() -> Bool:\n  both(True{},0)\n'],
    ['valid',prefix+'  f(True{})\n'],
    ['undefined',prefix+'  missing\n',true],
    ['existing-ctor-origin',prefix+'  f(U32{WNil{}})\n'],
    ['import-alias','import Base\nimport ./Lib.bend as L\ndef main() -> Bool:\n  L.f(0)\n',true],
    ['imported-error','import Base\nimport ./Bad.bend as B\ndef main() -> U32:\n  42\n',true],
    ['unicode-before-call',prefix+'  # 🙂λ source offset\n  f(0)\n']
  ];
  for(const [name,text]of [['Lib.bend','import Base\ndef f(x: Bool) -> Bool:\n  x\n'],['Bad.bend','import Base\ndef f(x: Bool) -> Bool:\n  x\ndef wrong() -> Bool:\n  f(0)\n']]){const file=path.join(fixtures,name);fs.writeFileSync(file,text);report.inputs.push(identity(file));}
  const cases=specs.map(([id,source,refuse=false])=>{const file=path.join(fixtures,id+'.bend');fs.writeFileSync(file,source);report.inputs.push(identity(file));return {id,file,refuse};});
  try {
    const builds=[prep.baselineBootstrap,candidate+'.bootstrap.json'];
    for(const file of builds){const r=JSON.parse(fs.readFileSync(file));assert.equal(r.stage,'upstream-bootstrap');assert.equal(r.provenance.verifiedAfterBuild,true);assert.equal(hash(r.apiPath),r.apiSha256);assert.equal(hash(r.source),r.sourceSha256);for(const input of r.provenance.inputs){assert.equal(hash(input.file),input.sha256);report.inputs.push(identity(input.file));}report.inputs.push(identity(file),identity(r.apiPath));}
    const driver=path.join(project,'tools/typed-driver.mjs');for(const name of ['typed-driver','compiler-abi','assemble','native-build','node-resource-args'])report.inputs.push(identity(path.join(project,'tools',name+'.mjs')));
    report.inputs.push(identity(path.join(project,'src/runtime.mjs')));
    const observed={};
    for(const [variant,api]of [['baseline',prep.baselineApi],['candidate',candidate],['typescript',null]]) {
      const directory=path.join(output,variant);fs.mkdirSync(directory);const request={variant,driver,upstream,cases,inputs:report.inputs,output:path.join(directory,'observations.json')};
      const file=path.join(directory,'request.json');save(file,request);const a=fs.openSync(path.join(directory,'stdout'),'wx'),b=fs.openSync(path.join(directory,'stderr'),'wx');let result;
      try{result=spawnSync(process.execPath,['--stack-size=4096','--max-old-space-size=4096',import.meta.filename,'--worker',file],{env:{...process.env,BEND_BASE:base,...api?{BEND_TYPED_API:api}:{},BEND_TYPED_RUNTIME:path.join(project,'src/runtime.mjs')},stdio:['ignore',a,b],timeout:180000});}
      finally{fs.closeSync(a);fs.closeSync(b);}
      report.rows.push({variant,execution:{status:result.status,signal:result.signal,error:result.error?.message},request:identity(file)});save(path.join(directory,'execution.json'),report.rows.at(-1));
      assert.equal(result.error,undefined);assert.equal(result.signal,null);assert.equal(result.status,0,'worker failed: '+variant);observed[variant]=JSON.parse(fs.readFileSync(request.output));assert.equal(observed[variant].complete,true);
    }
    report.comparison=cases.map((item,i)=>{
      const old=observed.baseline.rows[i],next=observed.candidate.rows[i],reference=observed.typescript.rows[i];assert.equal(old.id,item.id);assert.equal(next.id,item.id);assert.equal(reference.id,item.id);
      const withoutDiagnostic=x=>({...x,diagnostic:undefined});
      const sameStatus=JSON.stringify(withoutDiagnostic(old.result))===JSON.stringify(withoutDiagnostic(next.result)),oldExact=JSON.stringify(old.result)===JSON.stringify(reference.result),newExact=JSON.stringify(next.result)===JSON.stringify(reference.result),unchanged=JSON.stringify(old.result)===JSON.stringify(next.result);
      return {id:item.id,sameStatus,oldExact,newExact,unchanged,refusalExpected:item.refuse,newApplicationOrigins:next.applicationOrigins,pass:sameStatus&&(unchanged||newExact)&&(!oldExact||newExact)&&(!item.refuse||(unchanged&&next.applicationOrigins.length===0))};
    });
    report.improved=report.comparison.filter(x=>!x.oldExact&&x.newExact).length;report.failures=report.comparison.filter(x=>!x.pass);report.pass=report.failures.length===0&&report.improved>0;verify(report.inputs);report.complete=true;
  }catch(error){report.error=String(error.stack);process.exitCode=1;}
  report.finished=new Date().toISOString();save(path.join(output,'report.json'),report);console.log(JSON.stringify({complete:report.complete,pass:report.pass,improved:report.improved,failures:report.failures,error:report.error}));if(!report.pass)process.exitCode=1;
}
