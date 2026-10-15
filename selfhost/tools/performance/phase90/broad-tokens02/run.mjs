// Checked-B1 broad catalog C requests; default-CPU preprocessing equality only.
// Root runs this once under an external process-tree resource guard.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const args=process.argv.slice(2),checkOnly=args.includes('--check-only');
const option=name=>{const i=args.indexOf(name);return i<0?null:args[i+1];};
const attemptFile=path.resolve(args[0]??''),out=path.resolve(args[1]??'');
assert(args[0]&&args[1]);
const seconds=Number(option('--seconds')??300);assert([20,60,300].includes(seconds));
const started=performance.now(),deadline=started+seconds*1000;
const oracleManifest=path.resolve(option('--oracles')??path.join(root,'selfhost/build/phase90/broad-token-oracles01/manifest.json'));
const python=path.resolve(option('--python')??'/usr/bin/python3');
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
const report={kind:'phase90-checked-b1-broad-cpu-preprocessed-c-equality',complete:false,pass:false,checkOnly,executionPerformed:false,rows:[],inputs:[],scope:'Selected tier of 45 previously executed source-level catalog points, current checked B1 versus sealed independent B2 C. Default CPU preprocessing equality; no new execution, benchmark, device, full-language or native-fixed-point claim.',seconds};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
try{
  report.method=bind(import.meta.filename);report.node=bind(process.execPath);
  report.previousBroadMethod=bind(path.join(root,'selfhost/tools/performance/phase90/broad-tokens01/run.mjs'));
  assert.equal(report.previousBroadMethod.sha256,'78a1cc3b74f044a85e1686b70c322960eea452f9ae974225886a63c43fd15195');
  report.previousBroadFailure=bind(path.join(root,'selfhost/build/phase90/broad-token16/report.json'));
  const failedBroad=read(report.previousBroadFailure);assert(!failedBroad.complete&&!failedBroad.pass);
  const failedExtraction=failedBroad.rows[0].extraction;assert.equal(failedExtraction.returncode,0);assert(failedExtraction.error.includes('EPERM'));assert.equal(failedExtraction.stderr,'');
  const extractedDespiteError=JSON.parse(failedExtraction.stdout);assert.equal(extractedDespiteError.sha256,failedBroad.rows[0].baselineOrigin.recorded.sha256);
  report.extractionRevision='v2: regular stdout/stderr file descriptors replace extraction capture pipes; every child error still fails.';
  report.previousMethod=bind(path.join(root,'selfhost/tools/performance/phase90/whitespace-check-v2.mjs'));report.previousFailure=bind(path.join(root,'selfhost/build/phase90/whitespace01/report.json'));
  const failure=read(report.previousFailure);assert(!failure.complete&&!failure.pass);assert.equal(failure.rows[0].preprocess.baseline.stdout.bytes,0);assert.equal(failure.rows[0].preprocess.baseline.stderr.bytes,0);assert(failure.rows[0].preprocess.baseline.error.includes('ETIMEDOUT'));
  report.parentMethod=bind(path.join(root,'selfhost/tools/performance/phase90/whitespace-check-v3.mjs'));assert.equal(report.parentMethod.sha256,'b916bef1c3daf337b4bc7d133407b5f02104209789abf8ea1393c56299c59f50');
  report.methodRevision='Broad v1: sealed 45-point independent oracle set, deterministic 20/60/300-second tiers, one temporary baseline at a time; same checked producer and regular-FD preprocessing.';
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
  report.oracleManifest=bind(oracleManifest);const catalog=read(report.oracleManifest);
  assert.equal(catalog.kind,'phase90-archived-independent-b2-c-oracles');assert(catalog.complete&&!catalog.executionPerformed);
  assert.equal(catalog.cases.length,45);for(const p of catalog.inputs)bind(p);
  report.oraclePreparation=bind(catalog.method);report.archive=bind(catalog.archive);
  assert.equal(report.archive.sha256,'3ee20c99ea41489e9e2d1b53cfd93ba87234b9e94b03e30777b8128cfb00e7c3');
  assert.equal(bind(catalog.sealedManifest).sha256,'a7420b151807b2606b0434287f5441da3566fd7c8b87d798fabdd505e7ab19e5');
  const seal=new Map(read(catalog.sealedManifest).map(x=>[x.file,x]));
  const qualified=read(bind(catalog.qualification)),fixtures=read(bind(catalog.manifest));
  assert(qualified.complete&&qualified.passed&&qualified.points===45);assert.equal(fixtures.cases.length,45);
  for(const p of [catalog.qualification,catalog.manifest]){const s=seal.get(path.relative(root,p.file));assert.equal(s.sha256,p.sha256);assert.equal(s.bytes,p.bytes);}
  report.python=bind(python);
  const quick=['local-pair','coverage-closures-64','coverage-unicode-text-16','coverage-map-churn-32'];
  const medium=[...quick,'mandelbrot','editdist','tree-bitonic','lexer','symreg','raytrace','complete-generic-row32','coverage-list-pipeline-128','coverage-bst-32','coverage-expression-32','coverage-numeric-recurrence-256','coverage-record-aggregation-64'];
  const selected=seconds===20?quick:seconds===60?medium:catalog.cases.map(c=>c.name);
  const cases=[];
  for(const item of catalog.cases){
    const source=bind(item.source),receiptPin=bind(item.oracleReceipt),receipt=read(receiptPin);
    const sealedReceipt=seal.get(path.relative(root,receiptPin.file));assert.equal(sealedReceipt.sha256,receiptPin.sha256);assert.equal(sealedReceipt.bytes,receiptPin.bytes);
    const fixture=fixtures.cases.find(x=>x.id===item.name),qualification=qualified.rows.find(x=>x.id===item.name),prior=receipt.cases.find(x=>x.id===item.name);
    assert(fixture&&qualification&&prior&&qualification.exactC&&qualification.exactStdout);
    assert.equal(fixture.source.sha256,source.sha256);assert.equal(qualification.sourceSha256,source.sha256);assert.equal(prior.source.sha256,source.sha256);
    assert.equal(qualification.family,fixture.family);assert.equal(item.family,fixture.family);
    assert(prior.pass_&&prior.exact&&prior.executionExact&&Object.values(prior.jobs).every(x=>x.pass_));
    assert.equal(prior.expected,fixture.expected);assert.equal(item.expectedStdout,fixture.expected);
    assert.deepEqual(item.baseline,prior.b2);assert.equal(prior.b2.sha256,prior.native.sha256);assert.equal(prior.b2.sha256,qualification.cSha256);
    assert.equal(item.baselineOrigin.member,path.relative(root,prior.b2.file));assert.deepEqual(item.baselineOrigin.archive,report.archive);
    const sealedC=seal.get(item.baselineOrigin.member);assert.equal(sealedC.sha256,prior.b2.sha256);assert.equal(sealedC.bytes,prior.b2.bytes);
    if(selected.includes(item.name))cases.push({...item,source,oracleReceipt:receiptPin,baseline:null});
  }
  cases.sort((a,b)=>selected.indexOf(a.name)-selected.indexOf(b.name));assert.equal(cases.length,selected.length);
  report.totalPoints=45;report.selectedIds=selected;report.unselectedIds=catalog.cases.map(x=>x.name).filter(x=>!selected.includes(x));
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
      const timeoutMs=Math.min(30000,Math.floor(deadline-performance.now()));assert(timeoutMs>0,'Tier budget exhausted before preprocessing');
      const record={command,cwd:root,stdin:input,stdinTransport:'read-only-file-descriptor',stdinStartOffset:0,timeoutMs,passed:false};
      const stdinFd=fs.openSync(input.file,'r'),stdoutFd=fs.openSync(output,'wx'),stderrFd=fs.openSync(stderr,'wx');let result;
      try{assert.equal(fs.fstatSync(stdinFd).size,input.bytes);result=spawnSync(command[0],command.slice(1),{cwd:root,stdio:[stdinFd,stdoutFd,stderrFd],timeout:timeoutMs});}
      finally{fs.closeSync(stdinFd);fs.closeSync(stdoutFd);fs.closeSync(stderrFd);}
      Object.assign(record,{returncode:result.status,signal:result.signal,error:result.error?.message??null,stdout:pin(output),stderr:pin(stderr)});
      record.headers=[...new Set([...fs.readFileSync(stderr,'utf8').matchAll(/^\.+ (.+)$/gm)].map(m=>m[1]))].map(x=>bind(path.resolve(root,x)));
      record.passed=!result.error&&result.status===0&&record.stdout.bytes>0;
      return record;
    }
    for(const item of cases){
      assert(performance.now()<deadline,'Tier budget exhausted before next request');
      unchanged();const row={...item,passed:false,exactPreprocessed:false,preprocess:{}};report.rows.push(row);save();
      const baselineFile=path.join(out,item.name+'.baseline.tmp.c');
      const extractCommand=[python,'-B',report.oraclePreparation.file,'extract',report.oracleManifest.file,item.name,baselineFile];
      const extractionStdout=path.join(out,item.name+'.extract.stdout'),extractionStderr=path.join(out,item.name+'.extract.stderr');
      const extractionOutFd=fs.openSync(extractionStdout,'wx'),extractionErrFd=fs.openSync(extractionStderr,'wx');let extracted;
      try{extracted=spawnSync(extractCommand[0],extractCommand.slice(1),{cwd:root,stdio:['ignore',extractionOutFd,extractionErrFd],timeout:Math.max(1,Math.min(10000,Math.floor(deadline-performance.now())))});}
      finally{fs.closeSync(extractionOutFd);fs.closeSync(extractionErrFd);}
      row.extraction={command:extractCommand,cwd:root,stdoutTransport:'regular-file-descriptor',stderrTransport:'regular-file-descriptor',returncode:extracted.status,signal:extracted.signal,error:extracted.error?.message??null,stdout:pin(extractionStdout),stderr:pin(extractionStderr)};save();
      assert(!extracted.error&&extracted.status===0,'Archived baseline extraction failed');
      row.baseline=pin(baselineFile);assert.deepEqual(row.baseline,JSON.parse(fs.readFileSync(extractionStdout,'utf8')));
      assert.equal(row.baseline.sha256,item.baselineOrigin.recorded.sha256);assert.equal(row.baseline.bytes,item.baselineOrigin.recorded.bytes);save();
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
      assert.deepEqual(cacheFiles(),report.preparedBase.cache,'Prepared cache changed during request');unchanged();row.passed=true;
      fs.unlinkSync(row.baseline.file);row.baselineRemovedAfterExactComparison=true;report.coveredPoints=report.rows.filter(r=>r.passed).length;save();
    }
    unchanged();report.inputBindingsUnchanged=true;report.complete=true;report.pass=true;report.all45=report.coveredPoints===45;report.elapsedMs=performance.now()-started;report.rawCChanged=report.rows.filter(r=>!r.rawEqual).map(r=>r.name);save();
  }
}catch(error){report.error=error.stack??String(error);save();process.exitCode=1;}
console.log(JSON.stringify({complete:report.complete,pass:report.pass,checkOnly,executionPerformed:report.executionPerformed,rows:report.rows.map(r=>({name:r.name,rawEqual:r.rawEqual,exactPreprocessed:r.exactPreprocessed})),error:report.error}));
