// Root-only helper refusals and checked C emission. No child processes.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import * as D from '../../../typed-driver.mjs';
const [mode,planFile,outArg]=process.argv.slice(2),plan=JSON.parse(fs.readFileSync(planFile,'utf8'));
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};};
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=xs=>{const a=[];for(;xs.$==='Con';xs=xs.tail)a.push(xs.head);assert.equal(xs.$,'Nil');return a;};
const apiPath=mode.startsWith('old-')?plan.apis.baseline:plan.apis.candidate;
const api=(await import(pathToFileURL(apiPath))).default;
const term=(tag,id=0,kids=[])=>api.kt(tag,'',id,0,list(kids));
const arg0=term('OArg',0),arg1=term('OArg',1),field=t=>term('OField',1,[t,term('Ref')]);
if(mode==='old-positive'){
  assert.equal(api.noa_below(arg0,arg0),true);process.stdout.write('true\n');
}else if(mode==='old-mismatch'){
  // Parent-owned3s guard bounds the known pre-fix divergent/refusal path.
  // Any thrown stack failure or timeout is recorded, never semantic success.
  const result=api.noa_below(arg0,arg1);process.stdout.write(JSON.stringify({returned:result})+'\n');
}else{
  assert.equal(mode,'candidate');const out=path.resolve(outArg);assert(out.startsWith(path.resolve(import.meta.dirname,'../../../../..')+'/selfhost/build/phase98/'));fs.mkdirSync(out);
  const inputs=new Map(),report={kind:'phase98-observer-origin-controls',complete:false,rows:[],inputs:[]};
  const bind=file=>{const p=pin(file);if(inputs.has(p.file))assert.deepEqual(p,inputs.get(p.file));inputs.set(p.file,p);return p;};
  function verify(x){if(Array.isArray(x))x.forEach(verify);else if(x&&typeof x==='object'){if(['file','bytes','sha256'].every(k=>k in x))assert.deepEqual(bind(x.file),x);else Object.values(x).forEach(verify);}}
  const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');};
  try{
    verify(plan);bind(apiPath);bind(import.meta.filename);bind(planFile);bind(D.driverPath);bind(D.apiPath);bind(D.basePath);
    const cases=[['same-root',arg0,arg0,true],['different-root',arg0,arg1,false],['absent-root',term('Absent'),arg0,false],
      ['child',field(arg0),arg0,true],['grandchild',field(field(arg0)),arg0,true],['other-child',field(arg1),arg0,false],
      ['other-grandchild',field(field(arg1)),arg0,false],['not-field',term('Other',0,[arg0]),arg0,false],
      ['root-not-child',arg0,field(arg0),false],['empty-field',term('OField'),arg0,false],['same-absent',term('Absent'),term('Absent'),true]];
    for(const [id,origin,want,expected]of cases){const input=JSON.stringify({origin,want});const actual=api.noa_below(origin,want);assert.equal(actual,expected,id);assert.equal(JSON.stringify({origin,want}),input);report.rows.push({id,kind:'exact-origin-helper',origin,want,expected,actual,passed:true});}
    save();
    const audit=JSON.parse(fs.readFileSync(plan.audit.file,'utf8'));verify(audit);
    const runtime=fs.readFileSync(audit.runtime.file,'utf8'),installed=await D.loadApi();
    const permitted=new Map(audit.providers.map(x=>[path.basename(x.admitted.file),x]));
    function authority(book){
      const active=bind(D.basePath);assert.equal(active.sha256,audit.base.sha256);assert.equal(active.bytes,audit.base.bytes);
      const checks=[];
      for(const file of array(api.nc_foreign_paths(book))){
        const origin=path.resolve(file),name=path.basename(file),provider=permitted.get(name);
        assert(provider&&path.dirname(origin)===path.join(path.dirname(D.basePath),'effs'));
        const actual=bind(path.join(D.project,'src/runtime/native/effs',name));assert.equal(actual.file,provider.maintained.file);assert.equal(actual.sha256,provider.admitted.sha256);assert.equal(actual.bytes,provider.admitted.bytes);checks.push({origin,actual});
      }return checks;
    }
    for(const control of plan.controls){
      let called=false;
      const intercepted={...installed,nc_compile_checked:(book,rt,requests,driverPermission)=>{
        assert.equal(rt,runtime);const providers=authority(book);const result=api.nc_compile_checked(book,rt,requests,true);
        assert.equal(result.error,'');const file=out+'/'+control.id+'.c';fs.writeFileSync(file,result.source,{flag:'wx'});
        if(control.expectedC){assert.equal(result.source,fs.readFileSync(control.expectedC.file,'utf8'),'unchanged complete C '+control.id);}
        if(control.declinedOwner){const name='NF_FID_'+Array.from('$observer.'+control.declinedOwner,c=>c.codePointAt(0)+'_').join('');assert(!result.source.includes(name),'swapping root observer must decline');assert(result.source.includes('#define NATIVE_READONLY_OBSERVERS 1'));}
        report.rows.push({id:control.id,kind:control.expectedC?'exact-parent-C':'valid-owning-declined-observer',c:pin(file),diagnostic:result.error,providers,normalJsDriverPermission:driverPermission,passed:true});called=true;save();return result;
      }};
      const result=await D.inspect(control.source.file,{mode:'native',api:intercepted});assert.equal(result.status,'ok',JSON.stringify(result));assert(called);for(const f of result.files??[])bind(f);
    }
    for(const row of inputs.values())assert.deepEqual(pin(row.file),row);
    report.complete=true;report.inputsUnchanged=true;
  }catch(error){report.error=error.stack??String(error);console.error(report.error);process.exitCode=1;}finally{save();}
}
