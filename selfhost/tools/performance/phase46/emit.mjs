// Checked executable emission for the bounded four-way experiment.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {execFileSync} from 'node:child_process';
import assert from 'node:assert/strict';
import {identity,verifyIdentity} from '../../development/workflow.mjs';
import {verifyRelease} from '../../development/release.mjs';

const [role,target,inputArg,outputArg]=process.argv.slice(2);
assert(['upstream','selfhost'].includes(role)&&['js','c'].includes(target));
const root=path.resolve(import.meta.dirname,'../../../..');
const project=path.join(root,'selfhost');
const upstream=path.join(project,'.bootstrap/upstream-phase23');
const input=fs.realpathSync(inputArg),output=path.resolve(outputArg);
const report={role,target,input:identity(input),producer:identity(import.meta.filename),
  node:process.version,complete:false,started:Date.now(),timings:{}};
const start=performance.now();
try {
  const catalog=path.join(import.meta.dirname,'cases.json');
  const cases=JSON.parse(fs.readFileSync(catalog,'utf8'));
  report.programInputs=[identity(catalog),...cases.map(c=>{
    const item=identity(path.join(root,c.source));assert.equal(item.sha256,c.sha256);return item;
  })];
  const effects=role==='upstream'?path.join(upstream,'bend2/effs'):
    target==='c'?path.join(project,'src/runtime/native/effs'):path.join(upstream,'bend2/effs');
  report.effectInputs=fs.readdirSync(effects).filter(n=>n.endsWith('.'+target)).map(n=>identity(path.join(effects,n)));
  let code;
  if(role==='upstream') {
    const git=(...args)=>execFileSync('git',['-C',upstream,...args],{encoding:'utf8'}).trim();
    assert.equal(git('rev-parse','HEAD'),'018751270e800bc222a93dad7f257083ee53a5f7');
    assert.equal(git('diff','--name-only','HEAD','--','bend2'),'');
    const names=['bend.ts','comp.ts','base.bend'];
    report.compiler=names.map(n=>identity(path.join(upstream,'bend2',n)));
    const B=await import(pathToFileURL(path.join(upstream,'bend2/bend.ts')));
    const C=await import(pathToFileURL(path.join(upstream,'bend2/comp.ts')));
    report.timings.initializeMs=performance.now()-start;
    const begin=performance.now(),book=B.book_nil();
    await B.book_load(book,input,'',new Map()); B.book_valid(book); assert.equal(book.hols,0);
    report.timings.loadCheckMs=performance.now()-begin;
    const emit=performance.now();
    code=target==='c'?C.compile_book(book):C.js_book(book);
    report.timings.emitMs=performance.now()-emit;
    report.compiler.forEach(verifyIdentity);
    report.observation={status:'ok',checked:true};
  } else {
    report.release=identity(path.join(project,'dist/release.json'));
    verifyRelease(project);
    report.compiler=['dist/typed-api.mjs','src/runtime.mjs','dist/base.bend',
      'src/runtime/native/runtime.c','tools/typed-driver.mjs'].map(n=>identity(path.join(project,n)));
    process.env.BEND_TYPED_API=path.join(project,'dist/typed-api.mjs');
    process.env.BEND_TYPED_RUNTIME=path.join(project,'src/runtime.mjs');
    process.env.BEND_BASE=path.join(project,'dist/base.bend');
    const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs')));
    report.timings.initializeMs=performance.now()-start;
    const begin=performance.now();
    const {code:emitted,...observation}=await D.inspect(input,{mode:target==='c'?'native':'compile',withReport:true});
    report.timings.loadCheckEmitMs=performance.now()-begin;
    report.observation=observation;
    assert.equal(observation.status,'ok',JSON.stringify(observation)); assert.equal(observation.checked,true);
    report.inputs=(observation.files??[]).map(identity);
    code=emitted; report.compiler.forEach(verifyIdentity); verifyIdentity(report.release);
  }
  assert.equal(typeof code,'string'); verifyIdentity(report.input);
  report.programInputs.forEach(verifyIdentity);report.effectInputs.forEach(verifyIdentity);
  fs.writeFileSync(output,code,{flag:'wx'});report.output=identity(output);report.complete=true;
} catch(error) {report.error=error.stack??String(error);process.exitCode=1;}
report.timings.totalMs=performance.now()-start;
fs.writeFileSync(output+'.json',JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({role,target,complete:report.complete,timings:report.timings,error:report.error}));
