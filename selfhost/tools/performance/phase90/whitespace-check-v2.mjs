// Four ordinary checked-B1 C requests; default-CPU preprocessing equality only.
// Root runs this once under an external process-tree resource guard.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../..');
const args=process.argv.slice(2),checkOnly=args.includes('--check-only');
const option=name=>{const i=args.indexOf(name);return i<0?null:args[i+1];};
const attemptFile=path.resolve(args[0]??''),out=path.resolve(args[1]??'');
assert(args[0]&&args[1]);
const guardDirectory=option('--guard-dir')&&path.resolve(option('--guard-dir'));
assert(checkOnly||guardDirectory,'An actual run requires --guard-dir for its outer guard receipt');
const clang=path.resolve(option('--clang')??'/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang');
const clangInclude=path.resolve(path.dirname(clang),'../include/clang');
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
const inputs=new Map();
function bind(p){const actual=pin(typeof p==='string'?p:p.file??p.path);if(typeof p!=='string'){assert.equal(actual.sha256,p.sha256,actual.file);if(p.bytes!==undefined)assert.equal(actual.bytes,p.bytes,actual.file);}const old=inputs.get(actual.file);if(old)assert.deepEqual(old,actual);else inputs.set(actual.file,actual);return actual;}
const read=p=>JSON.parse(fs.readFileSync(typeof p==='string'?p:p.file,'utf8'));
function unchanged(){for(const p of inputs.values())assert.deepEqual(pin(p.file),p,'Input changed: '+p.file);}
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase90-checked-b1-cpu-preprocessed-c-equality',complete:false,pass:false,checkOnly,executionPerformed:false,rows:[],inputs:[],scope:'Four source-level programs, current checked B1 versus retained independent B2 C. Default CPU preprocessing equality; no compiled execution, benchmark, device or arbitrary raw-segment C claim.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
try{
  report.method=bind(import.meta.filename);report.node=bind(process.execPath);
  report.attempt=bind(attemptFile);const attempt=read(report.attempt);
  assert.equal(attempt.kind,'bend-development-attempt');assert(attempt.checked);assert.equal(attempt.artifactKind,'derived-b1');
  assert.equal(attempt.config.profile,'equality');assert(attempt.config.strictExact);
  report.selectedApi=bind(attempt.api);report.rawApi=bind(attempt.checkedApi);
  report.bootstrap=bind(attempt.bootstrapReport);report.derivation=bind(attempt.derivationReport);
  report.base=bind(attempt.base);assert.equal(bind(attempt.node).sha256,report.node.sha256);
  const build=read(bind(path.join(path.dirname(attemptFile),'build.json')));
  const validation=read(bind(path.join(path.dirname(attemptFile),'validation-001/report.json')));
  assert(build.complete&&validation.complete&&validation.pass&&validation.strictExact);
  assert.equal(build.api.sha256,report.selectedApi.sha256);assert.equal(validation.api.sha256,report.selectedApi.sha256);
  const bootstrap=read(report.bootstrap),derivation=read(report.derivation);
  assert.equal(bootstrap.stage,'upstream-bootstrap');assert.equal(bootstrap.revision,'059266225b77c8ca256ac6b25ee5c21449bab151');
  assert(bootstrap.provenance.verifiedAfterBuild);assert.equal(bootstrap.apiSha256,report.rawApi.sha256);assert.equal(bootstrap.baseSha256,report.base.sha256);
  for(const p of bootstrap.provenance.inputs)bind(p);
  assert.equal(derivation.kind,'bend-derived-b1-equality');assert(derivation.complete);
  assert.equal(derivation.original.api.sha256,report.rawApi.sha256);assert.equal(derivation.original.bootstrapReport.sha256,report.bootstrap.sha256);assert.equal(derivation.output.sha256,report.selectedApi.sha256);
  for(const p of derivation.original.inputs)bind(p);bind(derivation.original.source);
  const project=fs.realpathSync(attempt.snapshot.root),snapshot=new Map();
  for(const p of attempt.snapshot.sources){const frozen=bind(p.frozen);snapshot.set(path.relative(project,frozen.file),frozen);}
  report.project=project;report.driver=snapshot.get('tools/typed-driver.mjs');report.runtime=snapshot.get('src/runtime.mjs');assert(report.driver&&report.runtime);
  report.nativeInputs=[...snapshot].filter(([n])=>n.startsWith('src/runtime/native/')).map(([,p])=>p);
  report.clang=bind(clang);assert(fs.statSync(clangInclude).isDirectory());
  const commonArgs=['-isystem',clangInclude,'-x','c','-E','-P','-fminimize-whitespace','-H'];
  report.macros={scope:'default host CPU',definitions:[],sameStdinFilename:'<stdin>',cwd:root,args:[...commonArgs,'-'],includeDirectories:[clangInclude]};
  report.executionGuard=guardDirectory?{directory:guardDirectory,processFile:path.join(guardDirectory,'process.json'),cwd:root,expectedCommand:[process.execPath,...process.execArgv,...process.argv.slice(1)]}:null;
  report.oracleGates=bind(path.join(root,'selfhost/build/phase90/native-gates01/gates.json'));
  const gates=read(report.oracleGates);assert(gates.complete&&gates.passed&&gates.executionPerformed&&!gates.checkOnly);
  assert.equal(gates.kind,'phase90-combined-native-b1-gates');assert.equal(gates.nativeB1.base.sha256,report.base.sha256);
  const cases=[];
  for(const name of ['small','map_closed','unicode','file-io']){
    const item=gates.oracleCases.find(c=>c.name===name);assert(item);
    const source=bind(item.source),oracleReceipt=bind(item.oracleReceipt),receipt=read(oracleReceipt);
    if(name==='file-io'){
      assert.equal(receipt.kind,'phase89-b2-control-emission');assert(receipt.complete);assert.equal(receipt.observation.status,'ok');assert(receipt.policy&&Object.values(receipt.policy).every(x=>x===0));assert.equal(receipt.output.sha256,item.oracle.sha256);
    }else{
      assert(receipt.complete&&receipt.allJobsSucceeded);
      const prior=receipt.rows.find(r=>r.role==='b2'&&r.case===name);assert(prior&&prior.guard.complete&&prior.guard.returncode===0);
      assert.equal(prior.outputs[0].sha256,item.oracle.sha256);assert.equal(prior.outputs[0].bytes,item.oracle.bytes);assert.equal(receipt.cases[name],source.file);
    }
    const recorded=path.resolve(item.oracle.file??item.oracle.path);
    let baseline,transport;
    if(fs.existsSync(recorded)){baseline=bind(item.oracle);transport='retained-independent-B2-output';}
    else{
      const copy=gates.rows.find(r=>r.name==='live-'+name);assert(copy&&copy.passed&&copy.exactC&&copy.process.complete&&copy.process.returncode===0&&copy.inputBindingsUnchanged);
      assert.equal(copy.source.sha256,source.sha256);assert.equal(copy.oracle.sha256,item.oracle.sha256);
      baseline=bind(copy.output);assert.equal(baseline.sha256,item.oracle.sha256);assert.equal(baseline.bytes,item.oracle.bytes);
      bind(path.join(copy.guard,'process.json'));transport='retained-native-copy-with-full-independent-B2-digest';
    }
    cases.push({name,source,oracleReceipt,baseline,baselineOrigin:{recorded:item.oracle,transport}});
  }
  report.nineEffectManifest=bind(path.join(root,'selfhost/tools/performance/phase89/native-b2/nine-effects.json'));
  const assets=read(report.nineEffectManifest),effectNames=['args.c','print.c','now.c','print_err.c','file_open.c','file_read.c','file_size.c','file_write.c','file_close.c'];
  assert.equal(assets.kind,'phase89-private-native-entry-effect-assets');assert.deepEqual(assets.admittedEffects.map(x=>x.name),effectNames);
  assert.equal(bind(assets.base).sha256,report.base.sha256);
  report.nativeRuntime=bind(assets.runtime);report.nativeRuntimeTemplate=bind(assets.runtimeTemplate);
  assert.equal(report.nativeRuntimeTemplate.sha256,snapshot.get('src/runtime/native/runtime-template.json').sha256);
  report.nineEffects=assets.admittedEffects.map(r=>{const b=bind(r);assert.equal(b.sha256,snapshot.get('src/runtime/native/effs/'+r.name).sha256);return {name:r.name,...b};});
  report.cases=cases;unchanged();save();
  if(checkOnly){report.inputBindingsUnchanged=true;report.complete=true;report.pass=true;save();}
  else{
    process.env.BEND_TYPED_API=report.selectedApi.file;process.env.BEND_TYPED_RUNTIME=report.runtime.file;process.env.BEND_BASE=report.base.file;
    report.executionPerformed=true;save();
    const D=await import(pathToFileURL(report.driver.file)),api=await D.loadApi();assert.equal(await D.loadApi(),api);
    const prepared=await D.prepareBase(api,{backendProducts:false,nativeProducts:false});assert.equal(prepared?.preparedWorld?.state?.ready,true);
    report.preparedBase={ready:true,cacheDirectory:path.join(project,'build/typed/cache')};
    const cacheFiles=()=>fs.readdirSync(report.preparedBase.cacheDirectory).sort().map(n=>pin(path.join(report.preparedBase.cacheDirectory,n)));
    report.preparedBase.cache=cacheFiles();report.preparedBase.cache.forEach(bind);
    function preprocess(name,role,input){
      unchanged();const output=path.join(out,name+'.'+role+'.i'),stderr=path.join(out,name+'.'+role+'.stderr');
      const command=[clang,...commonArgs,'-'];
      const record={command,cwd:root,stdin:input,passed:false};
      const stdoutFd=fs.openSync(output,'wx'),stderrFd=fs.openSync(stderr,'wx');let result;
      try{result=spawnSync(command[0],command.slice(1),{cwd:root,input:fs.readFileSync(input.file),stdio:['pipe',stdoutFd,stderrFd],timeout:30000});}
      finally{fs.closeSync(stdoutFd);fs.closeSync(stderrFd);}
      Object.assign(record,{returncode:result.status,signal:result.signal,error:result.error?.message??null,stdout:pin(output),stderr:pin(stderr)});
      record.headers=[...new Set([...fs.readFileSync(stderr,'utf8').matchAll(/^\.+ (.+)$/gm)].map(m=>m[1]))].map(x=>bind(path.resolve(root,x)));
      record.passed=!result.error&&result.status===0&&record.stdout.bytes>0;
      return record;
    }
    for(const item of cases){
      unchanged();const row={...item,passed:false,exactPreprocessed:false,preprocess:{}};report.rows.push(row);save();
      const observation=await D.inspect(item.source.file,{mode:'native',withReport:true});
      assert.equal(observation.status,'ok');assert.equal(observation.checked,true);assert.equal(typeof observation.code,'string');
      const target=path.join(out,item.name+'.current.c');fs.writeFileSync(target,observation.code,{flag:'wx'});row.current=pin(target);assert(row.current.bytes>0);
      row.observation={...observation};delete row.observation.code;
      row.requestInputs=(observation.files??[]).map(p=>{const actual=pin(p),frozen=inputs.get(actual.file);assert(frozen,'Unfrozen request input: '+p);assert.deepEqual(actual,frozen);return actual;});
      row.rawEqual=fs.readFileSync(row.baseline.file).equals(fs.readFileSync(row.current.file));save();
      row.preprocess.baseline=preprocess(item.name,'baseline',row.baseline);save();assert(row.preprocess.baseline.passed,'Baseline preprocessing failed');
      row.preprocess.current=preprocess(item.name,'current',row.current);save();assert(row.preprocess.current.passed,'Current preprocessing failed');
      row.exactPreprocessed=fs.readFileSync(row.preprocess.baseline.stdout.file).equals(fs.readFileSync(row.preprocess.current.stdout.file));save();
      assert(row.exactPreprocessed,'Complete minimized preprocessing differs: '+item.name);
      assert.deepEqual(row.preprocess.baseline.command,row.preprocess.current.command);assert.deepEqual(row.preprocess.baseline.headers,row.preprocess.current.headers);
      assert.deepEqual(cacheFiles(),report.preparedBase.cache,'Prepared cache changed during request');unchanged();row.passed=true;save();
    }
    unchanged();report.inputBindingsUnchanged=true;report.complete=true;report.pass=true;report.rawCChanged=report.rows.filter(r=>!r.rawEqual).map(r=>r.name);save();
  }
}catch(error){report.error=error.stack??String(error);save();process.exitCode=1;}
console.log(JSON.stringify({complete:report.complete,pass:report.pass,checkOnly,executionPerformed:report.executionPerformed,rows:report.rows.map(r=>({name:r.name,rawEqual:r.rawEqual,exactPreprocessed:r.exactPreprocessed})),error:report.error}));
