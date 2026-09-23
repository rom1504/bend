// P5-022 nested-error composition gate, including prior P5-011 controls.
import fs from'node:fs';import path from'node:path';import assert from'node:assert/strict';import{createHash}from'node:crypto';import{spawnSync}from'node:child_process';import{pathToFileURL}from'node:url';
const hash=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex'),identity=f=>({file:path.resolve(f),sha256:hash(f)}),save=(f,x)=>fs.writeFileSync(f,JSON.stringify(x,null,2)+'\n',{flag:'wx'}),verify=xs=>xs.forEach(x=>assert.equal(hash(x.file),x.sha256,'changed input '+x.file));
const semantic=r=>({status:r.status,phase:r.phase,checked:r.checked,exitCode:r.exitCode,diagnostic:r.diagnostic??''});
if(process.argv[2]==='--worker'){
 const request=JSON.parse(fs.readFileSync(process.argv[3]));verify(request.inputs);const rows=[];
 if(request.variant==='typescript'){
  const U=await import(pathToFileURL(path.join(request.upstream,'bend2/bend.ts')));
  for(const item of request.cases){let result;try{await U.book_load(U.book_nil(),item.file,'',new Map());result={status:'ok',phase:'parse',checked:false,exitCode:0};}catch(error){assert.equal(error.$,'Err',String(error));result={status:'error',phase:'parse',checked:false,exitCode:1,diagnostic:U.err_show(error)};}rows.push({id:item.id,result:semantic(result)});}
 }else{
  const D=await import(pathToFileURL(request.driver)),api=await D.loadApi();await D.prepareBase(api);
  for(const item of request.cases){const raw=api.f_parse(fs.readFileSync(item.file,'utf8'));assert.deepEqual(Object.keys(raw).sort(),['$','book','error','imports']);const rawFile=path.join(request.directory,item.id+'-raw.json');save(rawFile,raw);const result=await D.inspect(item.file,{mode:'parse',api});rows.push({id:item.id,result:semantic(result),raw:identity(rawFile),rawError:raw.error});}
 }
 verify(request.inputs);save(request.output,{complete:true,rows,maxRssKiB:process.resourceUsage().maxRSS});
}else{
 const[preparedArg,outArg]=process.argv.slice(2);assert.ok(outArg);const prepared=path.resolve(preparedArg),out=path.resolve(outArg);fs.mkdirSync(out);const prep=JSON.parse(fs.readFileSync(path.join(prepared,'preparation.json'))),project=path.join(prepared,'project'),candidate=path.join(project,'api.mjs'),upstream=fs.realpathSync(process.env.BEND_UPSTREAM),base=path.join(upstream,'bend2/base.bend');
 const report={kind:'phase5-structured-parser-falsifier',complete:false,started:new Date().toISOString(),scope:'Raw accepted book/import equality and unchanged-or-exact parse diagnostics; no timing claim.',inputs:[identity(import.meta.filename),identity(path.join(prepared,'preparation.json')),identity(base),identity(process.execPath)],executions:[]};
 const dir=path.join(out,'fixtures');fs.mkdirSync(dir);const head='import Base\ndef main() -> U32:\n  ';
 const specs=[
 ['upstream-statement-lam',fs.readFileSync(path.join(upstream,'tests/flatten/statement_lam_absorb.bend'),'utf8'),'error'],
 ['nested-local',head+'x = 0;\n  (1]\n','error'],
 ['nested-local-two',head+'x = 0;\n  y = 1;\n  (2]\n','error'],
 ['nested-value-first',head+'x = (0];\n  (1}\n','error'],
 ['nested-prior-binder',head+'0 = 1;\n  (2]\n','error'],
 ['nested-import','import Base\nimport ./Nested.bend as N\ndef main() -> U32:\n  0\n','error'],
 ['nested-empty-import','import Base\nimport ./Empty.bend as E\nimport ./Nested.bend as N\ndef main() -> U32:\n  0\n','error'],
 ['import-error-first','import Base\nimport ./Missing.bend as M\ndef main() -> U32:\n  x = 0;\n  (1]\n','error',true],
 ['accept-simple',head+'42\n','ok'],['accept-group',head+'(42 : U32)\n','ok'],['accept-unicode','import Base\ndef main() -> String:\n  "🙂λ"\n','ok'],
 ['accept-law','import Base\nlaw id:\n  for x: U32\n  U32\ndef id(x):\n  x\ndef main() -> U32:\n  id(42)\n','ok'],
 ['accept-type','import Base\ntype Local is Data:\n  NewOne{}\n  NewTwo{x: U32}\ndef main() -> U32:\n  42\n','ok'],
 ['close-paren',head+'(0]\n','error'],['known-gap-close-group-type',head+'(0 : U32]\n','error',true],['close-equation','import Base\nlaw example:\n  {0 == 0 : U32]\n','error'],
 ['close-index',head+'0[1}\n','error'],['duplicate-ctor','import Base\ntype One is Data:\n  UniqueCtor{}\ntype Two is Data:\n  UniqueCtor{}\ndef main() -> U32:\n  0\n','error'],
 ['duplicate-local-ctor','import Base\ntype One is Data:\n  UniqueCtor{}\n  UniqueCtor{}\ndef main() -> U32:\n  0\n','error'],
 ['duplicate-spaced-ctor','import Base\ntype One is Data:\n  UniqueCtor{}\ntype Two is Data:\n  UniqueCtor {}\ndef main() -> U32:\n  0\n','error',true],
 ['eof-no-newline',head+'(0','error',true],['eof-with-newline',head+'(0\n','error',true],
 ['comment-before-fault',head+'(0 # comment\n  ]\n','error'],['tab-before-fault','import Base\ndef main() -> U32:\n\t(0]\n','error'],
 ['nonbmp-prefix',head+'("🙂", 0]\n','error'],['nonbmp-prefix-direct',head+'("🙂"]\n','error'],['nonbmp-fault',head+'(0🙂)\n','error',true],
 ['two-errors',head+'(0]\ndef later() -> U32:\n  (1}\n','error'],['legacy-first',head+'?\ndef later() -> U32:\n  (1]\n','error',true],
 ['comment-cursor-fallback',head+'for x: U32 # comment\n  U32\n','error',true],
 ['legacy-undefined','import Base\ndef main() -> U32:\n  absent_name\n','ok'],
 ['import-valid','import Base\nimport ./Good.bend as G\ndef main() -> U32:\n  G.value\n','ok'],
 ['import-bad','import Base\nimport ./Bad.bend as B\ndef main() -> U32:\n  0\n','error']
 ];
 for(const[name,text]of[['Nested.bend','import Base\ndef value() -> U32:\n  x = 0;\n  (1]\n'],['Empty.bend','# empty module\n'],['Good.bend','import Base\ndef value() -> U32:\n  42\n'],['Bad.bend','import Base\ndef value() -> U32:\n  (0]\n']]){const f=path.join(dir,name);fs.writeFileSync(f,text);report.inputs.push(identity(f));}
 const cases=specs.map(([id,text,status,unchanged=false])=>{const file=path.join(dir,id+'.bend');fs.writeFileSync(file,text);report.inputs.push(identity(file));return{id,file,status,unchanged};});
 try{
  for(const p of[prep.baselineBootstrap,candidate+'.bootstrap.json']){const b=JSON.parse(fs.readFileSync(p));assert.equal(b.stage,'upstream-bootstrap');assert.equal(b.provenance.verifiedAfterBuild,true);assert.equal(hash(b.apiPath),b.apiSha256);assert.equal(hash(b.source),b.sourceSha256);report.inputs.push(identity(p),identity(b.apiPath),identity(b.source),...b.provenance.inputs);}
  const driver=path.join(project,'tools/typed-driver.mjs');for(const n of['typed-driver','compiler-abi','assemble','native-build','node-resource-args'])report.inputs.push(identity(path.join(project,'tools',n+'.mjs')));for(const n of['bend.ts','comp.ts'])report.inputs.push(identity(path.join(upstream,'bend2',n)));report.inputs.push(identity(path.join(project,'src/runtime.mjs')));
  const observed={};for(const[variant,api]of[['baseline',prep.baselineApi],['candidate',candidate],['typescript',null]]){
   const directory=path.join(out,variant);fs.mkdirSync(directory);const request={variant,upstream,driver,directory,cases,inputs:report.inputs,output:path.join(directory,'observations.json')};const f=path.join(directory,'request.json');save(f,request);const a=fs.openSync(path.join(directory,'stdout'),'wx'),b=fs.openSync(path.join(directory,'stderr'),'wx');let r;try{r=spawnSync(process.execPath,['--stack-size=4096','--max-old-space-size=4096',import.meta.filename,'--worker',f],{env:{...process.env,BEND_BASE:base,BEND_TYPED_API:api||prep.baselineApi,BEND_TYPED_RUNTIME:path.join(project,'src/runtime.mjs')},stdio:['ignore',a,b],timeout:180000});}finally{fs.closeSync(a);fs.closeSync(b);}report.executions.push({variant,status:r.status,signal:r.signal,error:r.error?.message});assert.equal(r.error,undefined);assert.equal(r.signal,null);assert.equal(r.status,0);observed[variant]=JSON.parse(fs.readFileSync(request.output));assert.ok(observed[variant].complete);
  }
  report.rows=cases.map((item,i)=>{const a=observed.baseline.rows[i],b=observed.candidate.rows[i],r=observed.typescript.rows[i];assert.equal(a.id,item.id);assert.equal(b.id,item.id);assert.equal(r.id,item.id);const same=JSON.stringify(a.result)===JSON.stringify(b.result),exact=JSON.stringify(b.result)===JSON.stringify(r.result);const rawA=JSON.parse(fs.readFileSync(a.raw.file)),rawB=JSON.parse(fs.readFileSync(b.raw.file));const rawSame=JSON.stringify(rawA.book)===JSON.stringify(rawB.book)&&JSON.stringify(rawA.imports)===JSON.stringify(rawB.imports);const samePhase=a.result.status===b.result.status&&a.result.phase===b.result.phase&&a.result.checked===b.result.checked;const accepted=a.result.status==='ok';return{id:item.id,expectedStatus:item.status,baselineStatus:a.result.status,unchanged:same,exact,samePhase,rawBookImportsSame:rawSame,pass:a.result.status===item.status&&samePhase&&(same||exact)&&(!item.unchanged||same)&&(!accepted||rawSame)};});
  report.repaired=report.rows.filter(x=>!x.unchanged&&x.exact).length;report.failures=report.rows.filter(x=>!x.pass);report.pass=report.failures.length===0&&report.repaired>0;verify(report.inputs);report.complete=true;
 }catch(error){report.error=String(error.stack);process.exitCode=1;}
 report.finished=new Date().toISOString();save(path.join(out,'report.json'),report);console.log(JSON.stringify({complete:report.complete,pass:report.pass,repaired:report.repaired,failures:report.failures,error:report.error}));if(!report.pass)process.exitCode=1;
}
