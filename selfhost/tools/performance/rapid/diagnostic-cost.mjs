// Causal diagnostic replay experiment. The authoritative checker is unchanged;
// presentation workers are omitted only from an in-memory copy of the API.
import fs from 'node:fs';import path from 'node:path';import {fileURLToPath} from 'node:url';import {spawnSync} from 'node:child_process';import {createHash} from 'node:crypto';
const tool=fileURLToPath(import.meta.url),hash=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex'),save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n');
const presentation=['check_book_diagnostic','diagnostic_render','f_load_origins_for','diagnostic_result_locate'];
if(['--warm','--worker'].includes(process.argv[2])){
  const request=JSON.parse(fs.readFileSync(process.argv[3],'utf8'));
  process.env.BEND_TYPED_API=request.api;process.env.BEND_TYPED_RUNTIME=request.runtime;process.env.BEND_BASE=request.base;
  const D=await import('../../typed-driver.mjs'),api={...await D.loadApi()};
  if(!api.check_from_exact_prefix||!api.f_load_graph_seed)throw Error('Experiment requires validated Base prefix and seeded graph loading');
  if(process.argv[2]==='--warm'){
    const location=createHash('sha256').update(fs.realpathSync(request.base)).digest('hex'),cacheFile=path.join(D.project,'build/typed/cache',`base-${hash(request.api)}-${hash(request.base)}-${location}.json`),existedBefore=fs.existsSync(cacheFile),start=performance.now(),cache=await D.prepareBase(api);
    const dependencies=[...new Set(request.workloads.flatMap(work=>D.discoverSources(api,work.input,{seed:cache}).files))];
    save(request.result,{cacheFile,cacheSha256:hash(cacheFile),existedBefore,milliseconds:performance.now()-start,validatedBy:cache.validatedBy,version:cache.version,compilerSha256:cache.compilerSha256,baseSha256:cache.baseSha256,bookSha256:cache.bookSha256,sourcePath:cache.sourcePath,generated:cache.generated,dependencies});
  }else{
    if(!['full','without-presentation-replay'].includes(request.variant))throw Error('Invalid diagnostic experiment variant');
    if(request.variant!=='full')for(const name of presentation)delete api[name];
    const calls={},authoritative=[];
    for(const [name,fn] of Object.entries(api))if(typeof fn==='function')api[name]=(...args)=>{
      const start=performance.now();try{const value=fn(...args);if(['check_book','check_from_exact_prefix'].includes(name))authoritative.push({name,error:value});return value;}
      finally{const profile=calls[name]??={count:0,milliseconds:0};profile.count++;profile.milliseconds+=performance.now()-start;}
    };
    const start=performance.now(),result=await D.inspect(request.input,{mode:'check',api});
    save(request.result,{variant:request.variant,checkMs:performance.now()-start,result,authoritative,calls});
  }
}else if(process.argv[1]&&path.resolve(process.argv[1])===tool){
  const [configuration,outputDirectory]=process.argv.slice(2);if(!configuration||!outputDirectory)throw Error('usage: diagnostic-cost.mjs CONFIG.json NEW_OUTPUT_DIRECTORY');
  const configFile=fs.realpathSync(configuration),config=JSON.parse(fs.readFileSync(configFile,'utf8')),resolve=file=>fs.realpathSync(path.resolve(path.dirname(configFile),file));
  const files={api:resolve(config.api),runtime:resolve(config.runtime),base:resolve(config.base)},cpu=config.cpu,timeoutMs=config.timeoutMs??30000;
  if(!Number.isSafeInteger(cpu)||cpu<0||!Number.isSafeInteger(timeoutMs)||timeoutMs<=0)throw Error('Explicit CPU and positive timeout required');
  const workloads=config.workloads.map(work=>({...work,input:resolve(work.input)}));
  if(!workloads.length||new Set(workloads.map(work=>work.id)).size!==workloads.length||workloads.some(work=>!/^[-a-z0-9_]+$/.test(work.id)||!['ok','error'].includes(work.expectedStatus)))throw Error('Unique workload ids and explicit expectedStatus required');
  const output=path.resolve(outputDirectory);fs.mkdirSync(output,{recursive:false});
  const buildFile=files.api+'.bootstrap.json',build=JSON.parse(fs.readFileSync(buildFile,'utf8'));
  if(build.apiSha256!==hash(files.api)||build.sourceSha256!==hash(build.source)||build.baseSha256!==hash(files.base))throw Error('Checked API/source/Base identity mismatch');
  const modules=build.modules.map(module=>{const file=path.join(path.dirname(build.source),module.file);if(hash(file)!==module.sha256)throw Error('Checked compiler module changed');return file;});
  const inputFiles=[configFile,tool,process.execPath,...Object.values(files),buildFile,build.source,...modules,...['typed-driver.mjs','compiler-abi.mjs','node-resource-args.mjs','assemble.mjs','native-build.mjs'].map(name=>fileURLToPath(new URL('../../'+name,import.meta.url))),...workloads.map(work=>work.input)];
  const identity=file=>({canonicalPath:fs.realpathSync(file),sha256:hash(file)}),identities=Object.fromEntries(inputFiles.map(file=>[file,identity(file)]));
  const nodeArgs=['--stack-size=4096','--max-old-space-size=4096'],report={kind:'diagnostic-replay-causal-experiment',started:new Date().toISOString(),complete:false,files,identities,cpu,timeoutMs,node:{file:process.execPath,version:process.version,args:nodeArgs},order:['full','without-presentation-replay','without-presentation-replay','full'],workloads,rows:[],scope:'Fresh processes with one explicitly warmed validated Base cache. No compiler source/API bytes change. This experiment isolates presentation replay and is not a conformance pass or a proposed diagnostics bypass.'},reportFile=path.join(output,'report.json'),flush=()=>save(reportFile,report);
  const child=args=>spawnSync('taskset',['-c',String(cpu),process.execPath,...nodeArgs,tool,...args],{encoding:'utf8',timeout:timeoutMs,maxBuffer:16*1024*1024});
  const warm={...files,workloads,result:path.join(output,'warm.json')};save(path.join(output,'warm-request.json'),warm);flush();
  const warmed=child(['--warm',path.join(output,'warm-request.json')]);if(warmed.status!==0||warmed.error)throw Error('Validated Base preparation failed: '+(warmed.error?.message||warmed.stderr));
  report.cachePreparation=JSON.parse(fs.readFileSync(warm.result,'utf8'));for(const file of [report.cachePreparation.cacheFile,...report.cachePreparation.dependencies])identities[file]=identity(file);flush();
  for(const work of workloads)for(const [index,variant] of report.order.entries()){
    const stem=work.id+'-'+index,request={...files,input:work.input,variant,result:path.join(output,stem+'.json')},requestFile=path.join(output,stem+'-request.json');save(requestFile,request);console.error('[diagnostic cost] '+stem+' '+variant);
    const start=performance.now(),result=child(['--worker',requestFile]);
    const row={workload:work.id,index,variant,processWallMs:performance.now()-start,status:result.status,error:result.error?.message??null,stderr:result.stderr,passed:false};report.rows.push(row);
    if(result.status===0&&!result.error&&fs.existsSync(request.result)){
      row.observation=JSON.parse(fs.readFileSync(request.result,'utf8'));const observation=row.observation;
      const verdict=value=>({status:value.result.status,phase:value.result.phase,checked:value.result.checked,exitCode:value.result.exitCode,stdout:value.result.stdout??null,authoritative:value.authoritative});
      const prior=report.rows.find(other=>other!==row&&other.workload===work.id&&other.passed);
      row.sameAuthoritativeVerdict=!prior||JSON.stringify(verdict(observation))===JSON.stringify(verdict(prior.observation));
      row.presentationDiffers=!!prior&&observation.result.diagnostic!==prior.observation.result.diagnostic;
      row.passed=row.sameAuthoritativeVerdict&&observation.result.status===work.expectedStatus&&observation.result.phase==='check'&&observation.result.checked===true&&observation.authoritative.length===1&&observation.authoritative[0].name==='check_from_exact_prefix';
    }flush();
  }
  const mean=values=>values.reduce((sum,value)=>sum+value,0)/values.length;
  report.means=Object.fromEntries(workloads.map(work=>[work.id,Object.fromEntries([...new Set(report.order)].map(variant=>{const rows=report.rows.filter(row=>row.workload===work.id&&row.variant===variant&&row.passed);return [variant,{samples:rows.length,checkMs:mean(rows.map(row=>row.observation.checkMs)),processWallMs:mean(rows.map(row=>row.processWallMs)),topCalls:Object.fromEntries([...new Set(rows.flatMap(row=>Object.keys(row.observation.calls)))].map(name=>[name,mean(rows.map(row=>row.observation.calls[name]?.milliseconds??0))]))}];}))]));
  report.changedInputs=Object.entries(identities).filter(([file,input])=>fs.realpathSync(file)!==input.canonicalPath||hash(file)!==input.sha256).map(([file])=>file);report.complete=report.changedInputs.length===0&&report.rows.every(row=>row.passed);report.finished=new Date().toISOString();flush();
  console.log(JSON.stringify({report:reportFile,complete:report.complete,means:report.means}));if(!report.complete)process.exitCode=1;
}
