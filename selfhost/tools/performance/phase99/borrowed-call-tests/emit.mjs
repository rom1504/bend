// Root-run finite admission and tiny native emission; no child processes here.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import * as D from '../../../typed-driver.mjs';

const root=path.resolve(import.meta.dirname,'../../../../..');
const [planArg,outArg]=process.argv.slice(2),out=path.resolve(outArg);
assert(out.startsWith(root+'/selfhost/build/phase99/'));fs.mkdirSync(out,{recursive:false});
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const plan=read(planArg),audit=read(plan.audit.file),inputs=new Map();
function bind(file){const p=pin(file);if(inputs.has(p.file))assert.deepEqual(p,inputs.get(p.file));inputs.set(p.file,p);return p;}
function verifyTree(x){if(Array.isArray(x))x.forEach(verifyTree);else if(x&&typeof x==='object'){if(['file','bytes','sha256'].every(k=>k in x))assert.deepEqual(bind(x.file),x);else Object.values(x).forEach(verifyTree);}}
verifyTree(plan);verifyTree(audit);bind(import.meta.filename);bind(planArg);bind(D.driverPath);bind(D.apiPath);bind(D.basePath);
const report={kind:'phase99-borrowed-calls-small-emission',complete:false,executionPerformed:true,inputs:[],cases:[],programs:[],scope:plan.scope};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');};
const list=xs=>xs.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
const array=xs=>{const a=[];for(;xs.$==='Con';xs=xs.tail)a.push(xs.head);assert.equal(xs.$,'Nil');return a;};
const word=(name,observer=false)=>'NF_FID_'+Array.from((observer?'$observer.':'')+name,c=>c.codePointAt(0)+'_').join('');
const flagNames=['READONLY_OBSERVERS','TYPED_SCALARS','SCALAR_ARRAYS','UNSHARED_ARRAYS','COLD_USER_CTORS','COLD_CTORS'];
const flags=code=>Object.fromEntries(flagNames.map(name=>{const m=code.match(new RegExp('^#define NATIVE_'+name+' ([01])$','m'));return [name,m?Number(m[1]):0];}));
function body(code,name){
  const re=new RegExp('\\b'+name+'\\(Env e, bool seq, Term\\* nf_out[^;{}]*\\)\\s*\\{','g'),matches=[...code.matchAll(re)];
  assert.equal(matches.length,1,name+' definition');const begin=matches[0].index+matches[0][0].length-1;
  let depth=0;for(const m of code.slice(begin).matchAll(/\/\*[\s\S]*?\*\/|\/\/[^\n]*|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[{}]/g)){
    if(m[0]==='{')depth++;else if(m[0]==='}'&&--depth===0)return code.slice(begin,begin+m.index+1);
  }throw Error('unterminated worker '+name);
}
function observer(code,owner){
  const name=word(owner,true),text=body(code,name);
  for(const forbidden of ['term_keep(','term_sink(','ctr_take(','spare_free(','heap_alloc(','native_word(','term_word('])assert(!text.includes(forbidden),owner+' '+forbidden);
  const adapter=word('$observer.adapter.'+owner),adapterBody=body(code,adapter);
  assert(adapterBody.includes(name+'(e, seq, no_observed'));
  const ordinary=word(owner),ordinaryMatches=code.includes(ordinary+'(')?body(code,ordinary):'';
  const sharedRedirect=ordinaryMatches.includes(adapter+'(')&&ordinaryMatches.includes('RFC_CNT');
  const schedulerHook=code.includes('if (!'+adapter+'(e, seq, no_public_result');
  assert(sharedRedirect||schedulerHook,'observer is emitted but no eligible route is present');
  return {owner,borrowedReads:(text.match(/term_peek\(/g)||[]).length,sharedRedirect,schedulerHook,staticOnly:true};
}
try{
  const apis={};for(const [role,file]of Object.entries(plan.apis)){bind(file);apis[role]=(await import(pathToFileURL(file))).default;}
  for(const row of plan.cases){const actual=apis.candidate[row.exportName]();assert.equal(actual,row.expected,row.id);report.cases.push({id:row.id,kind:'finite-certificate',actual,expected:row.expected,passed:true});save();}
  const old=await D.loadApi();
  const permitted=new Map(audit.providers.map(x=>[path.basename(x.admitted.file),x]));
  function authority(book,override=null){
    assert.deepEqual(pin(audit.base.file),audit.base);assert.deepEqual(pin(audit.runtime.file),audit.runtime);
    const activeBase=bind(D.basePath);assert.equal(activeBase.sha256,audit.base.sha256);assert.equal(activeBase.bytes,audit.base.bytes);
    const paths=array(apis.candidate.nc_foreign_paths(book)),checks=[];let safe=true;
    for(const file of paths){
      const name=path.basename(file),provider=permitted.get(name),want=provider?.admitted;
      // Mirror typed-driver's exact Base-origin rewrite, then authenticate the
      // maintained bytes that driver actually marshals. A basename alone grants nothing.
      const original=path.resolve(file),baseDir=path.join(path.dirname(D.basePath),'effs');
      const recognized=path.dirname(original)===baseDir&&!!provider;
      const resolved=recognized?path.join(D.project,'src/runtime/native/effs',name):original;
      const actual=recognized?pin(override?.[name]??resolved):null;
      const canonicalProvider=recognized&&fs.realpathSync(resolved)===provider.maintained.file;
      const accepted=canonicalProvider&&actual.bytes===want.bytes&&actual.sha256===want.sha256;
      safe&&=accepted;checks.push({original,resolved,activeBase,expected:want??null,actual,recognized,canonicalProvider,accepted});
    }return {safe,checks};
  }
  const runtime=fs.readFileSync(audit.runtime.file,'utf8');
  for(const control of plan.controls){
    let captured=null;
    const api={...old,nc_compile_checked:(book,rt,requests,driverPermission)=>{
      assert.equal(rt,runtime);const permission=authority(book);report.lastAuthority={control:control.id,permission};save();assert(permission.safe,JSON.stringify(permission));
      const outputs={};for(const role of ['baseline','candidate']){
        const start=performance.now();const result=apis[role].nc_compile_checked(book,rt,requests,permission.safe);
        assert.equal(result.error,'');outputs[role]={result,emitterMs:performance.now()-start};
      }
      const prepared=apis.candidate.nr_compile_prepared(apis.candidate.nr_prepare(book),{$:'NE_Text',text:rt},requests,permission.safe);
      assert.equal(prepared.error,'');assert.equal(prepared.source,outputs.candidate.result.source,'both checked entry paths');
      const denied=apis.candidate.nc_compile_checked(book,rt,requests,false);
      const deniedPrepared=apis.candidate.nr_compile_prepared(apis.candidate.nr_prepare(book),{$:'NE_Text',text:rt},requests,false);
      assert.equal(denied.error,'');assert.equal(denied.source,deniedPrepared.source);
      const raw=apis.candidate.nc_compile(book,rt,requests);assert.equal(raw.error,'');
      for(const [kind,r]of [['explicit-false',denied],['raw',raw]]){
        const policy=flags(r.source);assert.equal(policy.READONLY_OBSERVERS,0);assert.equal(policy.TYPED_SCALARS,0);assert.equal(policy.SCALAR_ARRAYS,0);
        fs.writeFileSync(out+'/'+control.id+'-'+kind+'.c',r.source,{flag:'wx'});
      }
      const badDir=out+'/'+control.id+'-modified-provider';fs.mkdirSync(badDir);
      const first=permission.checks[0];let changedProviderRejected=null;
      if(first){const file=badDir+'/'+path.basename(first.expected.file);fs.writeFileSync(file,fs.readFileSync(first.expected.file,'utf8')+'\n/* separate rejected fixture */\n');
        changedProviderRejected=!authority(book,{[path.basename(file)]:file}).safe;assert(changedProviderRejected);}
      captured={outputs,permission,driverPermission,checkedEntriesExact:true,falseEntriesExact:true,rawPermissionOff:true,changedProviderRejected};
      return outputs.candidate.result;
    }};
    const result=await D.inspect(control.source.file,{mode:'native',api});assert.equal(result.status,'ok',JSON.stringify(result));assert(captured);
    for(const file of result.files??[])bind(file);
    const policies={};for(const role of ['baseline','candidate']){
      const code=captured.outputs[role].result.source;policies[role]=flags(code);
      const file=out+'/'+control.id+'-'+role+'.c';fs.writeFileSync(file,code,{flag:'wx'});
      report.programs.push({id:control.id+'-'+role,c:pin(file),stdout:control.stdout,stderr:control.stderr});
    }
    for(const name of flagNames)assert.equal(policies.candidate[name],policies.baseline[name],control.id+' '+name);
    assert.equal(policies.candidate.READONLY_OBSERVERS,1);assert.equal(policies.baseline.TYPED_SCALARS,control.scalar);assert.equal(policies.candidate.TYPED_SCALARS,control.scalar);assert.equal(policies.candidate.SCALAR_ARRAYS,control.scalar);
    const code=captured.outputs.candidate.result.source;
    const shape=control.observerOwner?observer(code,control.observerOwner):null;
    for(const name of control.forbiddenOwners??[])assert(!code.includes(word(name,true)),name+' must decline');
    report.cases.push({id:control.id,kind:'actual-emission',policies,shape,authority:captured.permission,
      normalJsDriverPermission:captured.driverPermission,checkedEntriesExact:true,falseEntriesExact:true,rawPermissionOff:true,
      changedProviderRejected:captured.changedProviderRejected,emitterMs:Object.fromEntries(Object.entries(captured.outputs).map(([r,v])=>[r,v.emitterMs])),
      timingScope:'One unbalanced API emission per role; diagnostic overhead only, not a speed estimate.',passed:true});save();
  }
  let unknown=null;
  const deniedApi={...old,nc_compile_checked:(book,rt,requests,driverPermission)=>{
    const permission=authority(book);assert(!permission.safe);assert.equal(driverPermission,false);
    const result=apis.candidate.nc_compile_checked(book,rt,requests,permission.safe);assert.equal(result.error,'');assert.equal(flags(result.source).READONLY_OBSERVERS,0);assert.equal(flags(result.source).TYPED_SCALARS,0);
    unknown={permission,driverPermission,flags:flags(result.source)};return result;
  }};
  const unknownResult=await D.inspect(plan.unknownProvider.file,{mode:'native',api:deniedApi});assert.equal(unknownResult.status,'ok',JSON.stringify(unknownResult));assert(unknown);
  for(const file of unknownResult.files??[])bind(file);
  report.cases.push({id:'unknown-provider',kind:'authority-refusal',...unknown,passed:true});
  const rawModule=await import(pathToFileURL(plan.rawCases.file));
  function origins(value){if(Array.isArray(value))return value.map(origins);if(!value||typeof value!=='object')return value;
    const result=Object.fromEntries(Object.entries(value).map(([k,v])=>[k,origins(v)]));
    if(result.$==='KTerm'||result.$==='KLiteral'){result.originBegin??=0;result.originEnd??=0;}return result;}
  for(const row of rawModule.rawCases){
    const book=list(row.book.map(origins)),baseline=apis.baseline.nc_compile(book,runtime,''),candidate=apis.candidate.nc_compile(book,runtime,'');
    assert.equal(candidate.error,baseline.error);assert.equal(candidate.source,baseline.source);
    if(row.expectedCompileRejection)assert(candidate.error&&candidate.source==='');
    else{assert.equal(candidate.error,'');assert.equal(flags(candidate.source).READONLY_OBSERVERS,0);const file=out+'/'+row.name+'.c';fs.writeFileSync(file,candidate.source,{flag:'wx'});report.programs.push({id:row.name,c:pin(file),stdout:row.expectedOutput+'\n',stderr:''});}
    report.cases.push({id:row.name,kind:'raw-boundary',diagnostic:candidate.error,exactBaseline:true,passed:true});
  }
  for(const p of inputs.values())assert.deepEqual(pin(p.file),p);
  report.complete=true;report.inputsUnchanged=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;console.error(report.error);}finally{save();}
