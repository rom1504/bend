// Root-only finite probes of the actual selected product entry guard.
// CLI: CHECKED_ATTEMPT_JSON FRESH_OUT. No compiler emission or C execution.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [attemptArg,outArg]=process.argv.slice(2);
const out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const inputs=new Map();
const pin=value=>{
  const expected=typeof value==='string'?null:value;
  const file=fs.realpathSync(expected?.file??expected?.path??value),bytes=fs.readFileSync(file);
  const result={file,sha256:createHash('sha256').update(bytes).digest('hex'),bytes:bytes.length};
  if(expected){assert.equal(result.sha256,expected.sha256);if(expected.bytes!==undefined)assert.equal(result.bytes,expected.bytes);}
  inputs.set(file,result);return result;
};
const report={kind:'phase68-product-demand-controls-v1',complete:false,pass:false,rows:[],scope:'Finite actual compiled entry-guard decisions; not full product lowering or ownership qualification.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const nil=()=>({$:'Nil'}),list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil());
const term=(tag,name='',id=0,kids=[],quant=0)=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:nil(),originBegin:0,originEnd:0});
const v=id=>term('Var','',id),lam=(id,body)=>term('Lam','',id,[body],1),app=(f,x)=>term('App','',0,[f,x]);
const p=v(101),other=v(102),dead=term('Efq'),zero=term('NWord','0');
const mat=(name,hit,miss,count=0,missId=103)=>term('Mat',name,count+1,[hit,lam(missId,miss)]);
const primitivePair=(a,b,hitA=p,hitB=p)=>app(mat(a,hitA,app(mat(b,b==='Succ'?lam(104,hitB):hitB,dead,b==='Succ'?1:0,106),v(103)),a==='Succ'?1:0),other);
try {
  report.method=pin(import.meta.filename);report.attempt=pin(attemptArg);
  const attempt=JSON.parse(fs.readFileSync(report.attempt.file,'utf8'));
  assert(attempt.checked&&attempt.config.strictExact&&attempt.artifactKind==='derived-b1');
  assert.equal(String(attempt.config.cpu),'3');assert.equal(attempt.config.jobs,1);
  for(const row of attempt.snapshot.sources)pin(row.frozen);
  for(const key of ['base','runtime','node','checkedApi','bootstrapReport','derivationReport'])pin(attempt[key]);
  const row=attempt.snapshot.sources.find(x=>x.frozen.file.endsWith('/src/back/native/product.bend'));assert(row);
  report.productSource=pin(row.frozen);
  assert.equal(report.productSource.sha256,'0625f0b9df2011fe2953a2cc8c70c3845e7e5fecd2ded350d21e67b283482a29');
  report.api=pin(attempt.api);const source=fs.readFileSync(report.api.file,'utf8');
  assert.equal(source.split('\n').filter(line=>line.startsWith('function $nq_demand$(')).length,1);
  const append='\nexport const p68Demand=run_lib((a,b,c)=>run_loop($nq_demand$(a,b,c)),3);\n';
  const observed=path.join(out,'observed.mjs');fs.writeFileSync(observed,source+append,{flag:'wx'});
  assert.equal(fs.readFileSync(observed,'utf8').slice(0,source.length),source);
  report.observed=pin(observed);const demand=(await import(pathToFileURL(observed))).p68Demand;
  const direct=app(mat('$ctor.Product68',lam(104,lam(105,zero)),dead,2),p);
  const cases=[
    ['single-terminal',p,true],['dead-terminal',zero,false],
    ['duplicate-terminal',term('Ctr','Pair',0,[p,p]),false],
    ['beta-single',app(lam(104,v(104)),p),true],
    ['beta-dead',app(lam(104,zero),p),false],
    ['beta-duplicate',app(lam(104,term('Ctr','Pair',0,[v(104),v(104)])),p),false],
    ['direct-product-match',direct,true],['direct-product-repeated-residual',app(direct,p),false],
    ['unknown-branch-drop',app(mat('$ctor.Other',p,zero),other),false],
    ['unknown-branch-use',app(mat('$ctor.Other',p,p),other),true],
    ['zero-succ-complement',primitivePair('Zero','Succ'),true],
    ['false-true-complement',primitivePair('False','True'),true],
    ['false-true-dropped-first',primitivePair('False','True',zero,p),false],
    ['unknown-tags-not-exhaustive',primitivePair('$ctor.A','$ctor.B'),false],
    ...['U32','F32','Chr'].map(name=>['unconditional-'+name,app(mat(name,lam(104,p),dead,1),other),true]),
    ['exhausted-fuel',p,false,0],
  ];
  for(const [name,t,expected,fuel=64] of cases){
    const before=JSON.stringify(t),actual=demand(t,101,fuel);
    assert.equal(actual,expected,name);assert.equal(JSON.stringify(t),before,name);
    report.rows.push({name,expected,actual,pass:true});save();
  }
  for(const input of [...inputs.values()])pin(input);
  report.complete=true;report.pass=true;report.inputsUnchanged=true;
} catch(error){report.error=error.stack??String(error);process.exitCode=1;}
report.inputs=[...inputs.values()];save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.rows.length,error:report.error}));
