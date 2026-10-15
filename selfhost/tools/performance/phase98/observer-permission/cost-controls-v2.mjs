// Root-run only. Reuses the qualified permission method's authenticated driver.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import * as D from '../../../typed-driver.mjs';

const root=path.resolve(import.meta.dirname,'../../../../..');
const [planFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
assert(out.startsWith(root+'/selfhost/build/phase98/'));fs.mkdirSync(out);
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};};
const plan=read(planFile),audit=read(plan.audit.file),inputs=new Map();
const bind=file=>{const p=pin(file);if(inputs.has(p.file))assert.deepEqual(p,inputs.get(p.file));inputs.set(p.file,p);return p;};
function verify(x){if(Array.isArray(x))x.forEach(verify);else if(x&&typeof x==='object'){if(['file','bytes','sha256'].every(k=>k in x))assert.deepEqual(bind(x.file),x);else Object.values(x).forEach(verify);}}
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=xs=>{const a=[];for(;xs.$==='Con';xs=xs.tail)a.push(xs.head);assert.equal(xs.$,'Nil');return a;};
const report={kind:'phase98-observer-cost-full-values',complete:false,rows:[],inputs:[],scope:plan.scope};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');};
const write=(name,value)=>{const f=out+'/'+name+'.json';fs.writeFileSync(f,JSON.stringify(value,null,2)+'\n',{flag:'wx'});return pin(f);};
try{
  verify(plan);verify(audit);for(const f of [import.meta.filename,planFile,D.driverPath,D.apiPath,D.basePath])bind(f);
  const apis={};for(const [role,file]of Object.entries(plan.apis)){bind(file);apis[role]=(await import(pathToFileURL(file))).default;}
  const a=apis.baseline,b=apis.candidate;
  const shape=a.kt('FixtureShape','nonempty λ',17,2,list([a.kt('FixtureChild','🙂',3,4,list([]))]));
  const renderText=t=>{assert(t&&typeof t==='object');if(t.$==='NC_Empty')return '';if(t.$==='NC_Leaf'){assert.equal(typeof t.text,'string');return t.text;}assert.equal(t.$,'NC_Join');return renderText(t.left)+renderText(t.right);};
  const worker=(name,n)=>({$:'NF_Worker',name,params:list(Array.from({length:n%5},(_,i)=>({$:'N_Param',name:'arg_'+i,kind:{$:['N_W32','N_W64','N_Box'][i%3]}}))),
    code:{$:'NC_Code',body:n%3===0?{$:'NC_Empty'}:n%3===1?{$:'NC_Leaf',text:'body-'+n+'\n'}:{$:'NC_Join',left:{$:'NC_Leaf',text:'left-'+n},right:{$:'NC_Leaf',text:'right-'+n+'\n'}},segments:list([{$:'N_Segment',name:'segment-'+n,params:list([]),result:n+7,
      frame:{$:'N_Frame',pop:n+2,slots:list(['slot-'+n])},body:'segment body',refs:list(['ref']),host:true,spin:false,fork:true,bang:false}]),
      fresh:n+101,error:'sentinel-error-'+n,calls:list(['call-'+n,'λ'])},deps:list(['dep-'+n,'dep-'+n]),shape});
  const fixtures=[[],[worker('miss',1)],[worker('owner',0)],[worker('owner',4)],
    [worker('before',2),worker('owner',3),worker('after',4)],
    [worker('owner',1),worker('other',2),worker('owner',4)],
    [worker('',3),worker('λ🙂',4),worker('$observer.owner',2)]];
  let workerCount=0;
  for(const [fi,workers]of fixtures.entries())for(const owner of ['owner','λ🙂',''])for(const roots of [[],[0],[1],[0,1],[3]]){
    const source=list(workers),before=JSON.stringify(source),old=a.no_scalar_redirect(source,owner,list(roots)),next=b.no_scalar_redirect(source,owner,list(roots));
    assert.deepEqual(next,old);assert.equal(JSON.stringify(source),before,'shared input survives');
    const result=array(next);assert.equal(result.length,workers.length);
    for(let i=0;i<result.length;i++){
      const actual=result[i],original=workers[i];
      if(original.name!==owner)assert.deepEqual(actual,original);
      else{
        for(const key of ['name','params','shape'])assert.deepEqual(actual[key],original[key]);
        for(const key of ['segments','fresh','error','calls'])assert.deepEqual(actual.code[key],original.code[key]);
        assert(renderText(actual.code.body).endsWith(renderText(original.code.body)));
        assert(renderText(actual.code.body).startsWith('if ('));
        if(original.code.body.$==='NC_Empty')assert.equal(actual.code.body.$,'NC_Leaf');
        else{assert.equal(actual.code.body.$,'NC_Join');assert.deepEqual(actual.code.body.right,original.code.body);}
        assert.deepEqual(array(actual.deps),['$observer.adapter.'+owner,...array(original.deps)]);
      }
    }
    const id='worker-'+String(workerCount++).padStart(3,'0');
    report.rows.push({id,kind:'full-worker-list',fixture:fi,owner,roots,result:write(id,{input:source,baseline:old,candidate:next}),passed:true});
  }
  report.workerCases=workerCount;save();
  const installed=await D.loadApi(),runtime=fs.readFileSync(audit.runtime.file,'utf8');
  const permitted=new Map(audit.providers.map(x=>[path.basename(x.admitted.file),x]));
  function authority(book){
    const active=bind(D.basePath);assert.equal(active.sha256,audit.base.sha256);assert.equal(active.bytes,audit.base.bytes);
    const paths=array(installed.nc_foreign_paths(book));const checks=[];
    for(const file of paths){
      const name=path.basename(file),provider=permitted.get(name),origin=path.resolve(file);
      assert(provider&&path.dirname(origin)===path.join(path.dirname(D.basePath),'effs'),'provider origin');
      const actual=bind(path.join(D.project,'src/runtime/native/effs',name));
      assert.equal(actual.file,provider.maintained.file);assert.equal(actual.sha256,provider.admitted.sha256);assert.equal(actual.bytes,provider.admitted.bytes);
      checks.push({origin,actual});
    }return checks;
  }
  let schemas=0;
  for(const control of plan.controls){
    let captured=false;
    const api={...installed,nc_compile_checked:(book,rt,requests,driverPermission)=>{
      assert.equal(rt,runtime);const providers=authority(book),scalars=b.nol_scalar_specs(book,book);
      assert.deepEqual(scalars,a.nol_scalar_specs(book,book));
      for(const name of [...control.schemaNames,'String','__p98_absent_schema__'])for(const fresh of [0,1,2147483600]){
        const d=a.lookup(book,name);if(control.schemaNames.includes(name))assert.notEqual(a.dk(d),'Absent',name);
        const old=a.no_schema(book,d,fresh),next=b.no_schema_cached(book,d,fresh,scalars);
        assert.deepEqual(next,old,name+' full schema');
        const id='schema-'+String(schemas++).padStart(3,'0');
        report.rows.push({id,kind:'full-schema',control:control.id,name,fresh,result:write(id,{baseline:old,candidate:next}),passed:true});
      }
      const old=a.nc_compile_checked(book,rt,requests,true),next=b.nc_compile_checked(book,rt,requests,true);
      assert.deepEqual(next,old,control.id+' complete result/C');assert.equal(next.error,'');
      const file=out+'/'+control.id+'.c';fs.writeFileSync(file,next.source,{flag:'wx'});
      report.rows.push({id:control.id,kind:'complete-C-and-diagnostic',c:pin(file),diagnostic:next.error,providers,normalJsDriverPermission:driverPermission,passed:true});
      captured=true;save();return next;
    }};
    const result=await D.inspect(control.source.file,{mode:'native',api});assert.equal(result.status,'ok',JSON.stringify(result));assert(captured);
    for(const file of result.files??[])bind(file);
  }
  report.schemaCases=schemas;
  for(const row of inputs.values())assert.deepEqual(pin(row.file),row);
  report.complete=true;report.inputsUnchanged=true;
}catch(error){report.error=error.stack??String(error);console.error(report.error);process.exitCode=1;}finally{save();}
