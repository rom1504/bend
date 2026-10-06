// Host-only controls: evaluate the maintained spawn expressions with an inert spy.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {tokenize} from '../../private-compiler/tokens.mjs';
const out=path.resolve(process.argv[2]??'');assert.ok(process.argv[2],'Usage: compiler-image-routing.mjs EXISTING_FRESH_ROUTING_DIRECTORY');
assert.ok(fs.statSync(out).isDirectory());const reportFile=path.join(out,'report.json');assert.ok(!fs.existsSync(reportFile));
const root=path.resolve(import.meta.dirname,'../../..'),hash=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const identity=f=>({file:fs.realpathSync(f),sha256:hash(f)}),report={kind:'phase54-compiler-image-routing-host-controls',complete:false,pass:false,
 scope:'Only actual maintained spawn expressions evaluated with an inert spy. No child process, compiler, Bend program, build or fixed-point test is run.',
 controller:identity(import.meta.filename),tokenizer:identity(new URL('../../private-compiler/tokens.mjs',import.meta.url)),node:process.version,
 cpu:fs.readFileSync('/proc/self/status','utf8').match(/^Cpus_allowed_list:\s*(.+)$/m)?.[1],checks:[],inputs:[]};
const save=()=>fs.writeFileSync(reportFile,JSON.stringify(report,null,2)+'\n');save();
try{
 assert.equal(report.cpu,'0');
 for(const name of ['selfhost.mjs','verify-seed.mjs']){
  const file=path.join(root,'tools/conformance',name),source=fs.readFileSync(file,'utf8');report.inputs.push(identity(file));
  const marker='spawn(process.execPath,';assert.equal(source.split(marker).length-1,1);
  const start=source.indexOf(marker),end=source.indexOf(');',start);assert.ok(end>start);
  const fragment=source.slice(start,end+1),tokens=tokenize(fragment);assert.equal(tokens[0].text,'spawn');assert.equal(tokens[1].text,'(');
  assert.equal(tokens[1].close,tokens.length-1);const expression=fragment.slice(0,tokens.at(-1).end);
  const vars={process:{execPath:'/node',platform:'linux',env:{UNCHANGED:'yes'}},nodeArgs:['--stack-size=4096','--max-old-space-size=1024'],
   driver:'/driver',source:'/compiler.bend',output:'/stage.mjs',project:'/project',log:123,report:{base:{canonicalPath:'/base'}},compiler:'/current-api',runtime:'/legacy-runtime',seed:'/seed-api',runtimePath:'/legacy-runtime',basePath:'/base'};
  const evaluate=text=>{let call;const spawn=(...args)=>{call=args;return {};};new Function('spawn',...Object.keys(vars),'return '+text)(spawn,...Object.values(vars));return call;};
  const check=call=>{
   assert.equal(call[0],'/node');assert.deepEqual(call[1],[...vars.nodeArgs,'/driver','/compiler.bend','--legacy-js','--library','-o','/stage.mjs']);
   assert.equal(call[2].cwd,'/project');assert.equal(call[2].detached,true);assert.deepEqual(call[2].stdio,['ignore',123,123]);
   assert.deepEqual(call[2].env,{UNCHANGED:'yes',BEND_BASE:'/base',BEND_TYPED_API:name==='selfhost.mjs'?'/current-api':'/seed-api',BEND_TYPED_RUNTIME:'/legacy-runtime',BEND_TYPED_TRACE:'1'});
  };
  check(evaluate(expression));assert.throws(()=>check(evaluate(expression.replace("'--legacy-js',",''))));
  assert.throws(()=>check(evaluate(expression.replace("'--legacy-js'","'--direct-js'"))));
  report.checks.push({name,exactLegacyArgv:true,identityAndRuntimeBindings:true,missingSelectorRejected:true,directSelectorRejected:true});save();
 }
 for(const name of ['worker.mjs','session.mjs','tests/control-worker.mjs','tests/reference-batch-worker.mjs']){
  const file=path.join(root,'tools/private-compiler',name),source=fs.readFileSync(file,'utf8');report.inputs.push(identity(file));
  const calls=source.match(/D\.inspect\(request\.input,\{[^}]+\}\)/g);assert.equal(calls?.length,1);assert.match(calls[0],/backend:'js'/);
  report.checks.push({name,explicitLegacyApi:true});
 }
 for(const item of [...report.inputs,report.controller,report.tokenizer])assert.equal(hash(item.file),item.sha256);
 report.complete=true;report.pass=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,checks:report.checks.length,error:report.error}));
