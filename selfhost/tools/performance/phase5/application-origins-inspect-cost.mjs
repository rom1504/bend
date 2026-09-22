// One-case unpaired rejection cost observation. Other correctness jobs may overlap.
import fs from'node:fs';import path from'node:path';import assert from'node:assert/strict';import{spawnSync}from'node:child_process';import{createHash}from'node:crypto';import{pathToFileURL}from'node:url';
const hash=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex'),id=f=>({file:path.resolve(f),sha256:hash(f)}),save=(f,x)=>fs.writeFileSync(f,JSON.stringify(x,null,2)+'\n',{flag:'wx'});
if(process.argv[2]==='--worker') {
 const request=JSON.parse(fs.readFileSync(process.argv[3]));for(const x of request.inputs)assert.equal(hash(x.file),x.sha256);
 const D=await import(pathToFileURL(request.driver));const api=await D.loadApi();await D.prepareBase(api);const rows=[];
 for(const item of request.cases){const result=await D.inspect(item.file,{mode:'check',api,withReport:true});rows.push({id:item.id,result:{status:result.status,phase:result.phase,checked:result.checked,exitCode:result.exitCode,diagnostic:result.diagnostic??''}});}
 for(const x of request.inputs)assert.equal(hash(x.file),x.sha256);save(request.output,{complete:true,rows,maxRssKiB:process.resourceUsage().maxRSS});
}else{
const[priorArg,outArg]=process.argv.slice(2);assert.ok(outArg);const prior=path.resolve(priorArg),out=path.resolve(outArg);fs.mkdirSync(out);
const gate=JSON.parse(fs.readFileSync(path.join(prior,'report.json')));assert.ok(gate.complete&&gate.pass);
const report={kind:'phase5-application-origin-rejection-cost',scope:'One128-argument invalid call; original then candidate fresh processes, cached Base preparation included; ordinary inspect only (no second origin reconstruction). Unpaired wall observation during concurrent correctness jobs; not a benchmark.',started:new Date().toISOString(),inputs:[id(import.meta.filename),id(path.join(prior,'report.json'))],complete:false,rows:[]};
try{for(const variant of['baseline','candidate']){
 const requestFile=path.join(prior,variant+'-request.json'),request=JSON.parse(fs.readFileSync(requestFile));report.inputs.push(id(requestFile));request.cases=request.cases.filter(x=>x.id==='long-spine');assert.equal(request.cases.length,1);request.output=path.join(out,variant+'-observations.json');
 const prep=JSON.parse(fs.readFileSync(request.inputs.find(x=>x.file.endsWith('/preparation.json')).file));const candidate=request.inputs.filter(x=>x.file.endsWith('api.mjs.bootstrap.json')).map(x=>JSON.parse(fs.readFileSync(x.file))).find(x=>x.apiPath.includes('/application-origins/project/')).apiPath;
 const file=path.join(out,variant+'-request.json');save(file,request);const a=fs.openSync(path.join(out,variant+'.stdout'),'wx'),b=fs.openSync(path.join(out,variant+'.stderr'),'wx');const start=performance.now();let result;
 try{result=spawnSync(process.execPath,['--stack-size=4096','--max-old-space-size=4096',import.meta.filename,'--worker',file],{env:{...process.env,BEND_UPSTREAM:request.upstream,BEND_BASE:path.join(request.upstream,'bend2/base.bend'),BEND_TYPED_API:variant==='baseline'?prep.baselineApi:candidate,BEND_TYPED_RUNTIME:path.resolve(path.dirname(request.driver),'../src/runtime.mjs')},stdio:['ignore',a,b],timeout:90000});}finally{fs.closeSync(a);fs.closeSync(b);}
 const row={variant,wallMs:performance.now()-start,status:result.status,signal:result.signal,error:result.error?.message};report.rows.push(row);assert.equal(result.error,undefined);assert.equal(result.signal,null);assert.equal(result.status,0);
 const observed=JSON.parse(fs.readFileSync(request.output));assert.ok(observed.complete);row.maxRssKiB=observed.maxRssKiB;assert.deepEqual(observed.rows[0].result,JSON.parse(fs.readFileSync(path.join(prior,variant+'-observations.json'))).rows.find(x=>x.id==='long-spine').result);row.observations=id(request.output);
 }report.complete=true;}catch(error){report.error=String(error.stack);process.exitCode=1;}
report.finished=new Date().toISOString();save(path.join(out,'report.json'),report);console.log(JSON.stringify(report));

}
