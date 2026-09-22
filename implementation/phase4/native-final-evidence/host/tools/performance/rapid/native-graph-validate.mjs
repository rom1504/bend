import fs from 'node:fs';import path from 'node:path';import {pathToFileURL,fileURLToPath} from 'node:url';
import {spawnFileCapture as spawnSync} from './native-file-capture.mjs';import {createHash} from 'node:crypto';
import {runNativeGraph} from './native-graph-run.mjs';import {makeNativeGraphFixtures} from './native-graph-fixtures.mjs';
const tool=fileURLToPath(import.meta.url),hash=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n');
if(process.argv[2]==='--host'){
  const request=JSON.parse(fs.readFileSync(process.argv[3],'utf8'));
  process.env.BEND_TYPED_API=request.api;process.env.BEND_TYPED_RUNTIME=request.runtime;process.env.BEND_BASE=request.base;
  for(const [file,expected] of Object.entries(request.toolHashes??{}))if(hash(file)!==expected)throw Error('Host tool changed before import: '+file);
  const D=await import('../../typed-driver.mjs'),api={...await D.loadApi()};
  for(const name of ['check_from_exact_prefix','exact_prefix','f_load_graph_seed','check_book_diagnostic','diagnostic_render','f_load_origins_for','diagnostic_result_locate'])delete api[name];
  const start=performance.now(),result=await D.inspect(request.input,{mode:request.mode==='library'?'library':'compile',api});
  const report={...result,wallMs:performance.now()-start};delete report.code;
  if(result.status==='ok'){fs.writeFileSync(request.output,result.code);report.outputSha256=hash(request.output);report.outputBytes=Buffer.byteLength(result.code);}
  report.toolsUnchanged=Object.entries(request.toolHashes??{}).every(([file,expected])=>hash(file)===expected);
  if(!report.toolsUnchanged)throw Error('Host tool changed during compilation');
  save(request.result,report);
}else if(process.argv[1]&&path.resolve(process.argv[1])===tool){
  const [configFile,outputDirectory]=process.argv.slice(2);if(!configFile||!outputDirectory)throw Error('usage: native-graph-validate.mjs CONFIG.json NEW_OUTPUT_DIRECTORY');
  const config=JSON.parse(fs.readFileSync(configFile,'utf8')),resolve=file=>fs.realpathSync(path.resolve(path.dirname(path.resolve(configFile)),file));
  const files=Object.fromEntries(['binary','api','base','runtime'].map(name=>[name,resolve(config[name])])),hashes=Object.fromEntries(Object.entries(files).map(([name,file])=>[name,hash(file)]));
  const exposureFile=path.join(path.dirname(files.api),'exposure.json'),exposure=JSON.parse(fs.readFileSync(exposureFile,'utf8'));
  if(exposure.api!==files.api||hash(files.api)!==exposure.apiSha256||hash(exposure.workers)!==exposure.workersSha256)throw Error('Exposed checked JS workers changed');
  const checked=JSON.parse(fs.readFileSync(exposure.buildReport,'utf8')),cBuildFile=files.binary+'.build.json',cBuild=JSON.parse(fs.readFileSync(cBuildFile,'utf8'));
  if(hash(checked.source)!==checked.sourceSha256||hash(checked.javascript.file)!==checked.javascript.sha256||hash(checked.c.file)!==checked.c.sha256)throw Error('Checked compiler source or emitted artifact changed');
  const contentAddressed=cBuild.kind==='native-content-addressed-build';
  if(contentAddressed&&(cBuild.version!==2||cBuild.record?.identity?.sourceSha256!==checked.c.sha256||cBuild.record?.binarySha256!==cBuild.binarySha256||createHash('sha256').update(JSON.stringify(cBuild.record.identity)).digest('hex')!==cBuild.key))throw Error('Invalid content-addressed C build identity');
  if(!checked.complete||!cBuild.complete||(!contentAddressed&&cBuild.exitCode!==0)||hash(files.binary)!==cBuild.binarySha256||checked.c.sha256!==(contentAddressed?cBuild.inputSha256:cBuild.sourceSha256)||checked.sourceSha256!==exposure.sourceSha256||checked.javascript.sha256!==exposure.checkedProgramSha256)throw Error('Native/JS checked build identity mismatch');
  const tools=[tool,fileURLToPath(new URL('./native-file-capture.mjs',import.meta.url)),...['native-graph-run.mjs','native-graph-fixtures.mjs','native-graph-api.mjs'].map(file=>fileURLToPath(new URL(file,import.meta.url))),...['typed-driver.mjs','compiler-abi.mjs','node-resource-args.mjs','assemble.mjs','native-build.mjs'].map(file=>fileURLToPath(new URL('../../'+file,import.meta.url))),exposureFile,exposure.workers,exposure.buildReport,cBuildFile,checked.source,checked.javascript.file,checked.c.file,process.execPath];
  const toolHashes=Object.fromEntries(tools.map(file=>[file,hash(file)]));
  const output=path.resolve(outputDirectory);fs.mkdirSync(output,{recursive:false});const cpu=config.cpu,timeout=config.timeoutMs??120000;
  if(!Number.isSafeInteger(cpu)||cpu<0)throw Error('Explicit CPU required');
  const all=makeNativeGraphFixtures(path.join(output,'fixtures'),files.base),cases=config.cases?all.filter(test=>config.cases.includes(test.name)):all;
  if(!cases.length)throw Error('No selected graph fixtures');
  const report={kind:'native-graph-semantic-validation',started:new Date().toISOString(),cpu,files,hashes,toolHashes,exposure,node:{version:process.version,executable:process.execPath,flags:['--stack-size=4096']},complete:false,rows:[]},reportFile=path.join(output,'validation.json'),flush=()=>save(reportFile,report);
  const child=args=>spawnSync('taskset',['-c',String(cpu),process.execPath,'--stack-size=4096',...args],{encoding:'utf8',timeout,maxBuffer:16*1024*1024});
  const execute=(file,test)=>test.mode==='library'?child(['--input-type=module','-e',`const m=await import(${JSON.stringify(pathToFileURL(file).href)});console.log(JSON.stringify(m.default[${JSON.stringify(test.export)}]()));`]):child([file]);
  flush();
  for(const test of cases){
    console.error('[native graph validation] '+test.name);const dir=path.join(output,'results',test.name);fs.mkdirSync(dir,{recursive:true});
    const row={name:test.name,input:test.input,manifest:test.manifest,expected:{accepted:test.accepted,phase:test.phase,checked:test.checked,scopeDifference:test.scopeDifference??false},passed:false};report.rows.push(row);flush();
    try{
      row.native=await runNativeGraph({binary:files.binary,manifest:test.manifest,runtime:files.runtime,output:path.join(dir,'native.mjs'),mode:test.mode,cpu,timeoutMs:timeout});
      const request={...files,toolHashes,input:test.input,mode:test.mode,output:path.join(dir,'host.mjs'),result:path.join(dir,'host.json')};save(path.join(dir,'request.json'),request);
      const host=await child([tool,'--host',path.join(dir,'request.json')]);if(host.status!==0||host.error)throw Error('Host worker failed: '+(host.error?.message??host.stderr));
      row.host=JSON.parse(fs.readFileSync(request.result,'utf8'));
      if(row.native.published!==test.accepted)throw Error('Native acceptance differs from fixture expectation');
      if((row.host.status==='ok')!==(test.hostAccepted??test.accepted))throw Error('JS host acceptance differs from fixture expectation');
      if(test.accepted){
        row.equalOutput=row.native.outputSha256===row.host.outputSha256;if(!row.equalOutput)throw Error('Native/JS host emitted bytes differ');
        const native=await execute(row.native.output,test),host=await execute(request.output,test);
        row.execution={native:{status:native.status,stdout:native.stdout,stderr:native.stderr},host:{status:host.status,stdout:host.stdout,stderr:host.stderr}};
        if(native.status!==0||host.status!==0||native.error||host.error)throw Error('Emitted program execution failed');
        const expected=test.mode==='library'?JSON.stringify(test.value)+'\n':test.stdout;
        if(native.stdout!==expected||host.stdout!==expected||native.stderr!==host.stderr)throw Error('Emitted execution differs from expected result');
        if(test.usedAssetIds&&JSON.stringify(row.native.usedAssetIds)!==JSON.stringify(test.usedAssetIds))throw Error('Selected asset identity differs');
      }else{
        if(row.native.phase!==test.phase||row.native.checked!==test.checked)throw Error('Native rejection phase/checked differs');
        if(!test.scopeDifference&&(row.host.phase!==(test.hostPhase??test.phase)||row.host.checked!==test.checked))throw Error('JS host rejection phase/checked differs');
        row.phaseDifference=row.native.phase!==row.host.phase;
      }
      row.passed=true;
    }catch(error){row.error=error.message;}
    flush();
  }
  report.inputsUnchanged=Object.entries(files).every(([name,file])=>hash(file)===hashes[name]);report.toolsUnchanged=Object.entries(toolHashes).every(([file,expected])=>hash(file)===expected);report.complete=report.inputsUnchanged&&report.toolsUnchanged&&report.rows.every(row=>row.passed);report.finished=new Date().toISOString();flush();
  console.log(JSON.stringify({report:reportFile,passed:report.rows.filter(row=>row.passed).length,total:report.rows.length,complete:report.complete}));if(!report.complete)process.exitCode=1;
}
