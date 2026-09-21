// Semantic acceptance/output comparison with the existing uncached typed driver.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {runNativeBundle} from './native-bundle-run.mjs';
const tool=fileURLToPath(import.meta.url),root=path.resolve(import.meta.dirname,'../../..');
const sha=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n');
if(process.argv[2]==='--host') {
  const request=JSON.parse(fs.readFileSync(process.argv[3],'utf8'));
  process.env.BEND_TYPED_API=request.api;process.env.BEND_TYPED_RUNTIME=request.runtime;process.env.BEND_BASE=request.base;
  const D=await import('../../typed-driver.mjs'),api={...await D.loadApi()};
  for(const name of ['check_from_exact_prefix','exact_prefix','f_load_graph_seed','check_book_diagnostic','diagnostic_render','f_load_origins_for','diagnostic_result_locate'])delete api[name];
  const start=performance.now();
  const result=await D.inspect(request.input,{mode:request.mode==='library'?'library':'compile',api});
  const report={...result,wallMs:performance.now()-start};delete report.code;
  if(result.status==='ok'){fs.writeFileSync(request.output,result.code);report.outputSha256=sha(request.output);report.outputBytes=Buffer.byteLength(result.code)}
  save(request.result,report);
} else if(process.argv[1]&&path.resolve(process.argv[1])===tool) {
  const [configFile,outputDirectory]=process.argv.slice(2);
  if(!configFile||!outputDirectory)throw Error('usage: node native-bundle-validate.mjs CONFIG.json NEW_OUTPUT_DIRECTORY');
  const config=JSON.parse(fs.readFileSync(configFile,'utf8')),relative=file=>fs.realpathSync(path.resolve(path.dirname(path.resolve(configFile)),file));
  const binary=relative(config.binary),api=relative(config.api),base=relative(config.base),runtime=relative(config.runtime),output=path.resolve(outputDirectory);
  if(fs.existsSync(output))throw Error('Use a fresh output directory');fs.mkdirSync(output,{recursive:true});
  const cpu=config.cpu,timeout=config.timeoutMs??120000;
  if(!Number.isSafeInteger(cpu)||cpu<0)throw Error('An explicit CPU is required');
  const manifest=JSON.parse(fs.readFileSync(new URL('./native-bundle-fixtures/cases.json',import.meta.url),'utf8'));
  const cases=config.cases?manifest.cases.filter(x=>config.cases.includes(x.name)):manifest.cases;
  const files={binary,api,base,runtime},hashes=Object.fromEntries(Object.entries(files).map(([k,v])=>[k,sha(v)]));
  const report={kind:'native-closed-bundle-semantic-validation',started:new Date().toISOString(),cpu,files,hashes,complete:false,rows:[]};
  const reportFile=path.join(output,'validation.json'),flush=()=>save(reportFile,report);
  const child=(args)=>spawnSync('taskset',['-c',String(cpu),process.execPath,...args],{encoding:'utf8',timeout,maxBuffer:16*1024*1024});
  const execute=(file,test)=>{
    if(test.mode==='library'){
      const script=`const m=await import(${JSON.stringify(pathToFileURL(file).href)});const value=m.default[${JSON.stringify(test.export)}]();console.log(JSON.stringify(value));`;
      return child(['--input-type=module','-e',script]);
    }
    return child([file]);
  };
  flush();
  for(const test of cases){
    console.error('[native validation] '+test.name);
    const directory=path.join(output,test.name);fs.mkdirSync(directory);
    const input=fs.realpathSync(path.join(root,test.file)),nativeOutput=path.join(directory,'native.mjs'),hostOutput=path.join(directory,'host.mjs');
    const row={name:test.name,input,inputSha256:sha(input),expected:test,passed:false};report.rows.push(row);flush();
    try{
      row.native=runNativeBundle({binary,input,base,runtime,output:nativeOutput,mode:test.mode,cpu,timeoutMs:timeout});
      const marker=/phase=(\w+) checked=(True|False):/.exec(row.native.stderr);
      row.native.phase=marker?.[1]??(row.native.published?'compile':null);row.native.checked=marker?marker[2]==='True':row.native.published;
      const request={api,base,runtime,input,output:hostOutput,result:path.join(directory,'host.json'),mode:test.mode};
      const requestFile=path.join(directory,'request.json');save(requestFile,request);
      const hostChild=child([tool,'--host',requestFile]);
      if(hostChild.status!==0||hostChild.error)throw Error('Host worker failed: '+(hostChild.error?.message??hostChild.stderr));
      row.host=JSON.parse(fs.readFileSync(request.result,'utf8'));
      const nativeAccepted=row.native.published,hostAccepted=row.host.status==='ok';
      if(nativeAccepted!==test.accepted)throw Error('Native acceptance differs from fixture expectation');
      if(hostAccepted!==(test.hostAccepted??test.accepted))throw Error('Host acceptance differs from fixture expectation');
      if(!nativeAccepted){
        if(row.native.phase!==test.phase||row.native.checked!==test.checked)throw Error('Native error phase/checked differs');
        if(!test.scopeDifference&&(row.host.phase!==row.native.phase||row.host.checked!==row.native.checked))throw Error('Host/native error phase differs');
      }else{
        row.equalOutput=row.native.outputSha256===row.host.outputSha256;
        if(!row.equalOutput)throw Error('Host/native emitted bytes differ');
        const nativeExecution=execute(nativeOutput,test),hostExecution=execute(hostOutput,test);
        row.execution={native:{status:nativeExecution.status,stdout:nativeExecution.stdout,stderr:nativeExecution.stderr},host:{status:hostExecution.status,stdout:hostExecution.stdout,stderr:hostExecution.stderr}};
        if(nativeExecution.status!==0||hostExecution.status!==0)throw Error('Emitted program execution failed');
        if(nativeExecution.stdout!==hostExecution.stdout||nativeExecution.stderr!==hostExecution.stderr)throw Error('Emitted program execution differs');
        const expected=test.mode==='library'?JSON.stringify(test.value)+'\n':test.stdout;
        if(expected!==undefined&&nativeExecution.stdout!==expected)throw Error('Emitted program output differs from expectation');
      }
      if(sha(input)!==row.inputSha256)throw Error('Fixture changed during validation');
      row.passed=true;
    }catch(error){row.error=error.message;}
    flush();
  }
  report.inputsUnchanged=Object.entries(files).every(([k,v])=>sha(v)===hashes[k]);
  report.complete=report.inputsUnchanged&&report.rows.length>0&&report.rows.every(x=>x.passed);report.finished=new Date().toISOString();flush();
  console.log(JSON.stringify({report:reportFile,passed:report.rows.filter(x=>x.passed).length,total:report.rows.length,complete:report.complete}));
  if(!report.complete)process.exitCode=1;
}
