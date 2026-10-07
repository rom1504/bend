// Root supplies the process guard. This imports diagnostic copies of genuine checked APIs.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {identity,verify,hash,list} from '../../phase54/bootstrap/adapter.mjs';

const [baselineArg,candidateArg,outArg]=process.argv.slice(2);
assert(baselineArg&&candidateArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase61')+path.sep)&&!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});
const inputs=new Map();
function pin(file,want){const row={...identity(file),bytes:fs.statSync(file).size};
  if(want){assert.equal(row.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(row.bytes,want.bytes);}
  if(inputs.has(row.file))assert.deepEqual(inputs.get(row.file),row);inputs.set(row.file,row);return row;}
const clone=x=>JSON.parse(JSON.stringify(x));
const term=(tag,name='',id=0,quant=0,kids=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
const variable=id=>term('Var','v'+id,id),ref=name=>term('Ref',name),qua=q=>term('Qua','',0,q);
const typ=()=>term('Typ','',0,0,[qua(1)]),qnt=()=>term('Qnt');
const all=(id,domain,tail,quant=1)=>term('All','v'+id,id,quant,[domain,tail]);
const app=(f,x)=>term('App','',0,0,[f,x]);
const lam=(id,body)=>({$:'KLambda',name:'v'+id,id,quant:1,kids:list([body]),removed:list([]),originBegin:0,originEnd:0,quantityPresent:false});
const def=(name,value)=>({$:'KDef',name,kind:'Def',arity:0,templates:0,typ:typ(),value,ctors:list([]),native:false,unsafe:false});
const span=(t,begin,end)=>({...t,originBegin:begin,originEnd:end});
function chain(n,domain=qnt(),tip=variable(100)){let out=tip;for(let i=n-1;i>=0;i--)out=all(100+i,clone(domain),out);return out;}
const fill=[];
function f(id,tel,args,{book=[],expected,safe}={}){fill.push({id,tel,args,book,expected,safe});}
f('empty-preserves-parent',span(all(1,typ(),variable(1)),4,9),[],{expected:span(all(1,typ(),variable(1)),4,9),safe:true});
f('single-dependent',all(1,typ(),variable(1)),[qnt()],{expected:qnt(),safe:true});
f('dependent-chain',all(1,typ(),all(2,variable(1),term('Ctr','Pair',0,1,[variable(1),variable(2)]))),[qnt(),qua(2)],{expected:term('Ctr','Pair',0,1,[qnt(),qua(2)]),safe:true});
f('earlier-value-contains-later-binder',all(1,typ(),all(2,typ(),variable(1))),[variable(2),qnt()],{expected:qnt(),safe:true});
f('later-value-remains-raw',all(1,typ(),all(2,typ(),variable(2))),[qnt(),variable(1)],{expected:variable(1),safe:true});
f('duplicate-binder-identities',all(1,typ(),all(1,typ(),variable(1))),[qnt(),typ()],{expected:qnt(),safe:true});
f('partial-flush',all(1,typ(),all(2,typ(),all(3,variable(1),variable(2)))),[qnt(),typ()],{expected:all(3,qnt(),typ()),safe:true});
f('too-many',all(1,typ(),qnt()),[typ(),typ()],{expected:term('Error'),safe:true});
f('invalid-head',qnt(),[typ(),typ()],{expected:term('Error'),safe:true});
f('alias-head',ref('Alias'),[qua(1),qua(2)],{book:[def('Alias',chain(2))],expected:qua(1),safe:true});
f('alias-tail',all(1,qnt(),ref('Alias')),[qua(2),qua(1)],{book:[def('Alias',all(2,qnt(),variable(2)))],expected:qua(1),safe:true});
f('annotated-head',term('Ann','',0,0,[chain(2),typ()]),[qua(1),qua(2)],{expected:qua(1),safe:true});
f('beta-tail-falls-back',all(1,typ(),all(2,typ(),app(lam(3,variable(3)),variable(1)))),[qnt(),typ()],{expected:qnt(),safe:false});
f('beta-domain-falls-back',all(1,typ(),all(2,app(lam(3,variable(3)),typ()),variable(1))),[qnt(),typ()],{expected:qnt(),safe:false});
f('function-variable-falls-back',all(1,typ(),all(2,typ(),app(variable(1),variable(2)))),[lam(9,variable(9)),qnt()],{expected:qnt(),safe:false});
f('unsafe-argument-flush',all(1,typ(),all(2,typ(),variable(1))),[app(lam(9,variable(9)),qnt()),typ()],{expected:qnt(),safe:true});
f('noncanonical-app-falls-back',all(1,typ(),all(2,typ(),term('App','metadata',5,2,[ref('opaque'),variable(1)]))),[qnt(),typ()],{expected:app(ref('opaque'),qnt()),safe:false});
f('spans-quantity-and-lambda-presence',span(all(1,typ(),all(2,qnt(),span(lam(7,variable(1)),12,19),0),2),3,21),[span(qnt(),30,34),qua(1)],{expected:span(lam(7,span(qnt(),30,34)),12,19),safe:true});
for(const n of [2,8,63,64,65,129])f('pending-boundary-'+n,chain(n),Array.from({length:n},(_,i)=>qua(i%3)),{expected:qua(0),safe:true});

const checks=[];
function c(id,tel,args,{book=[],context=[],dem=1,error=false}={}){checks.push({id,tel,args,book,context,dem,error});}
c('empty',all(1,typ(),variable(1)),[]);
c('dependent-success',all(1,typ(),all(2,variable(1),variable(1))),[qnt(),qua(1)]);
c('quantity-success',chain(3),[qua(0),qua(1),qua(2)]);
c('partial-success',chain(4),[qua(1),qua(2)]);
c('early-type-error',chain(3),[typ(),ref('later-missing'),qua(1)],{error:true});
c('later-type-error',chain(3),[qua(1),typ(),ref('last-missing')],{error:true});
c('too-many',chain(1),[qua(1),qua(2)],{error:true});
c('bad-head',qnt(),[qua(1),qua(2)],{error:true});
c('alias-head',ref('Alias'),[qua(1),qua(2)],{book:[def('Alias',chain(2))]});
c('alias-domain',chain(2,ref('KindAlias')),[qua(1),qua(2)],{book:[def('KindAlias',qnt())]});
c('annotated-head',term('Ann','',0,0,[chain(2),typ()]),[qua(1),qua(2)]);
c('beta-domain-fallback',all(1,app(lam(8,variable(8)),qnt()),all(2,qnt(),qnt())),[qua(1),qua(2)]);
c('beta-tail-fallback',all(1,qnt(),all(2,qnt(),app(lam(8,variable(8)),qnt()))),[qua(1),qua(2)]);
c('beta-argument-fallback',chain(2),[app(lam(8,variable(8)),qua(1)),qua(2)]);
c('context-use-and-world',chain(2),[variable(9),qua(1)],{context:[[9,1,'value',qnt()]]});
c('erased-demand',all(1,qnt(),all(2,qnt(),variable(1)),0),[variable(9),qua(2)],{context:[[9,1,'value',qnt()]],dem:0});
for(const n of [63,64,65,129])c('pending-boundary-'+n,chain(n),Array.from({length:n},(_,i)=>qua(i%3)));
const report={kind:'phase61-telescope-environment-controls',complete:false,pass:false,roles:{},fill:[],check:[],
  scope:'Actual checked baseline and candidate functions on bounded explicit first-order IR. Complete terms/worlds/uses/errors and caller inputs are compared. No public malformed-host ABI, source frontend or performance claim. Derivatives append diagnostic exports only; no operation is stubbed.'};
function save(){fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');}save();
try{
  for(const file of [import.meta.filename,process.execPath,new URL('../../../development/workflow.mjs',import.meta.url).pathname,new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url).pathname])pin(file);
  const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],P={exports:{}};
  new Function('module','exports',parserText)(P,P.exports);
  const parse=text=>P.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  report.parser={version:P.exports.version,sha256:hash(parserText)};
  const apis={};
  for(const [role,arg] of [['baseline',baselineArg],['candidate',candidateArg]]){
    const directory=fs.realpathSync(arg),m=await verifyAttempt(directory),attempt=pin(path.join(directory,'attempt.json'));
    assert(m.checked);assert.equal(identity(process.execPath).sha256,m.node.sha256);
    for(const key of ['api','runtime','base','node','bootstrapReport'])pin(m[key].file,m[key]);
    const validation=pin(path.join(directory,'validation-001/report.json')),v=JSON.parse(fs.readFileSync(validation.file,'utf8'));
    assert(v.complete&&v.pass&&v.selected.selectedComplete);assert.equal(v.selected.exactDifferences,0);assert.equal(v.selected.discrepancies,0);
    assert.equal(v.attempt.sha256,attempt.sha256);assert.equal(v.api.sha256,m.api.sha256);
    const kernel=pin(path.join(m.snapshot.root,'src/check/kernel.bend'));
    const original=fs.readFileSync(m.api.file,'utf8'),ast=parse(original);
    const names=['run_loop','$tele_fill$','$tele_check$','$tele_check_legacy$','$kw_initial$','$ctx_bind$'];
    if(role==='candidate')names.push('$env_tele_fill$','$env_tele_fill_eager$','$env_tele_check$','$env_tele_safe$');
    for(const name of names)assert.equal(ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id?.name===name).length,1,name);
    assert(!original.includes('phase61Telescope'));
    const suffix=`\nexport const phase61Telescope={
fill:(b,t,a)=>run_loop(${role==='candidate'?'$env_tele_fill$':'$tele_fill$'}(b,t,a)),
publicFill:(b,t,a)=>run_loop($tele_fill$(b,t,a)),
legacyFill:(b,t,a)=>run_loop(${role==='candidate'?'$env_tele_fill_eager$':'$tele_fill$'}(b,t,a)),
check:(e,c,t,a,d)=>run_loop(${role==='candidate'?'$env_tele_check$':'$tele_check_legacy$'}(e,c,t,a,d)),
publicCheck:(e,c,t,a,d)=>run_loop($tele_check$(e,c,t,a,d)),
legacyCheck:(e,c,t,a,d)=>run_loop($tele_check_legacy$(e,c,t,a,d)),
world:b=>run_loop($kw_initial$(b)),bind:(c,i,q,n,t)=>run_loop($ctx_bind$(c,i,q,n,t))${role==='candidate'?',safe:t=>run_loop($env_tele_safe$(t))':''}};\n`;
    parse(original+suffix);assert.equal((original+suffix).slice(0,-suffix.length),original);
    const file=path.join(out,role+'-diagnostic.mjs');fs.writeFileSync(file,original+suffix,{flag:'wx'});
    const derivative=pin(file);apis[role]=(await import(pathToFileURL(file))).phase61Telescope;
    report.roles[role]={attempt,validation,api:m.api,kernel,derivative,suffixSha256:hash(suffix),strictExact:m.config.strictExact};
    if(role==='candidate')report.roles[role].module=pin(path.join(m.snapshot.root,'src/check/env-telescope.bend'));
  }
  const results={baseline:{},candidate:{}};
  for(const [role,api] of Object.entries(apis)){
    for(const spec of fill){
      const input=clone({book:list(spec.book),tel:spec.tel,args:list(spec.args)}),before=JSON.stringify(input);
      const value=api.fill(input.book,input.tel,input.args),legacy=api.legacyFill(input.book,input.tel,input.args),publicValue=api.publicFill(input.book,input.tel,input.args);
      assert.deepEqual(value,legacy,role+': fill '+spec.id);assert.deepEqual(publicValue,legacy,role+': public fill '+spec.id);
      assert.deepEqual(value,spec.expected,role+': independent fill '+spec.id);assert.equal(JSON.stringify(input),before,role+': fill mutation '+spec.id);
      const safe=role==='candidate'?api.safe(input.tel):null;if(safe!==null)assert.equal(safe,spec.safe,'admission '+spec.id);
      results[role]['fill:'+spec.id]=clone(value);report.fill.push({role,id:spec.id,pass:true,admittedTelescope:safe,resultSha256:hash(JSON.stringify(value))});save();
    }
    for(const spec of checks){
      const book=list(clone(spec.book));let context=list([]);
      for(const [id,q,name,type] of spec.context)context=api.bind(context,id,q,name,clone(type));
      const env={$:'KEnv',world:api.world(book),name:'telescope.control',lhs:ref('telescope.control'),pending:0,quantities:list([]),unsafe:false,depth:0};
      const input=clone({env,context,tel:spec.tel,args:list(spec.args)}),before=JSON.stringify(input);
      const args=[input.env,input.context,input.tel,input.args,spec.dem];
      const value=api.check(...args),legacy=api.legacyCheck(...args),publicValue=api.publicCheck(...args);
      assert.deepEqual(value,legacy,role+': check '+spec.id);assert.deepEqual(publicValue,legacy,role+': public check '+spec.id);
      assert.equal(value.error.length>0,spec.error,role+': error oracle '+spec.id);assert.equal(JSON.stringify(input),before,role+': check mutation '+spec.id);
      results[role]['check:'+spec.id]=clone(value);report.check.push({role,id:spec.id,pass:true,error:value.error,resultSha256:hash(JSON.stringify(value))});save();
    }
  }
  assert.deepEqual(results.candidate,results.baseline,'complete baseline/candidate results');
  for(const arg of [baselineArg,candidateArg])await verifyAttempt(fs.realpathSync(arg));
  for(const row of inputs.values()){verify({file:row.file,sha256:row.sha256});assert.equal(fs.statSync(row.file).size,row.bytes);}
  report.counts={roles:2,fillPerRole:fill.length,checkPerRole:checks.length,completeDifferentialCases:fill.length+checks.length};
  report.inputsUnchanged=true;report.complete=report.pass=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error?.message}));
