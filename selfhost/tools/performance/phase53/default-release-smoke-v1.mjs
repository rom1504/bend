// Run only after release installation, under the existing bounded job supervisor.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
const [projectArg,outArg,expectedApi,expectedSource,expectedRuntime]=process.argv.slice(2);
assert.ok(projectArg&&outArg,'Usage: default-release-smoke-v1.mjs SELFHOST NEW_OUT API_SHA SOURCE_SHA DIRECT_RUNTIME_SHA');
for(const pin of [expectedApi,expectedSource,expectedRuntime])assert.match(pin??'',/^[0-9a-f]{64}$/);
const project=fs.realpathSync(projectArg),out=path.resolve(outArg),relocated=path.join(out,'relocated');
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controller.mjs'));
const hash=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(file),bytes:fs.statSync(file).size});
const manifestFile=path.join(project,'dist/release.json'),release=JSON.parse(fs.readFileSync(manifestFile));
const env={...process.env},removed=Object.keys(env).filter(k=>k.startsWith('BEND_')||['NODE_OPTIONS','NODE_PATH'].includes(k));
for(const key of removed)delete env[key];
const report={kind:'phase53-installed-relocated-default-direct-smoke',complete:false,pass:false,
  expectedApi,expectedSource,expectedRuntime,node:{...identity(process.execPath),version:process.version},
  controller:identity(import.meta.filename),release:identity(manifestFile),actualCpu:fs.readFileSync('/proc/self/status','utf8').match(/^Cpus_allowed_list:\s*(.+)$/m)?.[1]??null,environment:{removed,remainingBendKeys:Object.keys(env).filter(k=>k.startsWith('BEND_'))},
  relocation:{root:relocated,noUpstreamCheckout:true,note:'No upstream checkout copied or supplied; this is relocation evidence, not filesystem isolation.'},steps:[],outputs:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const extras=['dist/release.json','tools/development/release.mjs','tools/development/workflow.mjs','tools/development/equality.mjs','tools/development/process.mjs','tools/conformance/inventory.mjs'];
const files=[...new Set([...release.files,...release.checkout].map(x=>x.path).concat(extras))].sort();
const run=(name,cwd,args,expected='',nonzero=false)=>{
  const child=spawnSync(process.execPath,['--stack-size=4096','--max-old-space-size=1024',...args],{cwd,env,timeout:180000,maxBuffer:1024*1024,encoding:'utf8'});
  const at=String(report.steps.length).padStart(2,'0'),stdout=path.join(out,at+'.stdout'),stderr=path.join(out,at+'.stderr');
  fs.writeFileSync(stdout,child.stdout??'');fs.writeFileSync(stderr,child.stderr??'');
  const row={name,cwd,command:[process.execPath,'--stack-size=4096','--max-old-space-size=1024',...args],exitCode:child.status,signal:child.signal,error:child.error?.message??null,
    stdout:identity(stdout),stderr:identity(stderr),expectedNonzero:nonzero,pass:false};
  try{assert.equal(child.signal,null);assert.equal(child.error,undefined);assert.ok(Number.isInteger(child.status));
    if(nonzero)assert.notEqual(child.status,0);else assert.equal(child.status,0);
    if(typeof expected==='function')expected(child.stdout,child.stderr);else assert.equal(child.stdout,expected);row.pass=true;
  }catch(error){row.assertion=String(error.stack??error);}
  report.steps.push(row);save();assert.ok(row.pass,name+': '+(row.assertion??row.error));return row;
};
const verify=(name,root)=>run(name,root,['tools/development/release.mjs','--verify'],stdout=>{
  const v=JSON.parse(stdout);assert.equal(v.complete,true);assert.equal(v.newBootstrap,false);
  assert.equal(v.api.sha256,expectedApi);assert.equal(v.sourceSha256,expectedSource);
});
try{
  assert.equal(release.sourceSha256,expectedSource);assert.equal(release.directRuntimeSha256,expectedRuntime);
  assert.equal(release.files.find(x=>x.path==='dist/typed-api.mjs')?.sha256,expectedApi);
  assert.equal(release.checkout.find(x=>x.path==='src/runtime/js/direct.mjs')?.sha256,expectedRuntime);
  report.inventory=files.map(relative=>{
    assert.ok(!path.isAbsolute(relative)&&!relative.split('/').includes('..'));
    return {relative,...identity(path.join(project,relative))};
  });
  fs.mkdirSync(relocated);
  for(const item of report.inventory){const dest=path.join(relocated,item.relative);fs.mkdirSync(path.dirname(dest),{recursive:true});fs.copyFileSync(item.file,dest);assert.equal(hash(dest),item.sha256);}
  report.relocation.copied=report.inventory.map(x=>({relative:x.relative,...identity(path.join(relocated,x.relative))}));save();
  for(const [mode,root]of [['ordinary',project],['relocated',relocated]]){
    for(const forbidden of ['.bootstrap','bend2'])if(mode==='relocated')assert.equal(fs.existsSync(path.join(root,forbidden)),false);
    verify(mode+' integrity before',root);
    const dir=path.join(out,'outputs-'+mode);fs.mkdirSync(dir);
    const pure=path.join(dir,'pure.bend'),lib=path.join(dir,'library.bend'),io=path.join(dir,'io.bend');
    fs.writeFileSync(pure,'import Base\n\ndef main() -> U32:\n  U32.add(20, 22)\n');
    fs.writeFileSync(lib,'import Base\n\ndef release.add(+a: U32, +b: U32) -> U32:\n  U32.add(a, b)\n');
    fs.writeFileSync(io,'import Base\n\ndef main() -> IO(Unit):\n  IO.print("direct-release")\n');
    report.outputs.push(...[pure,lib,io].map(identity));
    run(mode+' direct run',root,['cli.mjs',pure,'--run'],'42\n');
    const emitted=path.join(dir,'pure.mjs');run(mode+' direct emit',root,['cli.mjs',pure,'-o',emitted]);
    run(mode+' emitted ESM',root,[emitted],'42\n');report.outputs.push(identity(emitted));
    const library=path.join(dir,'library.mjs');run(mode+' direct library emit',root,['cli.mjs',lib,'--library','-o',library]);
    const probe=path.join(dir,'library-probe.mjs');fs.writeFileSync(probe,
      `import assert from 'node:assert/strict';import * as m from ${JSON.stringify(pathToFileURL(library).href)};\n`+
      `assert.equal(m.backend.kind,'direct-js');assert.equal(m.backend.foreign,'upstream-cps');assert.equal('G' in m,false);assert.equal('G' in m.default,false);const f=m.default['release.add'];assert.equal(typeof f,'function');`+
      `assert.equal(f(20,22),42);assert.equal(f(20)(22),42);assert.equal(f()(20,22),42);console.log('42');\n`);
    run(mode+' callable partial library without G',root,[probe],'42\n');report.outputs.push(identity(library),identity(probe));
    run(mode+' direct IO print FFI',root,['cli.mjs',io,'--run'],'direct-release\n');
    run(mode+' explicit legacy run',root,['cli.mjs',pure,'--legacy-js','--run'],'42\n');
    const legacy=path.join(dir,'legacy-library.mjs');run(mode+' legacy library emit',root,['cli.mjs',lib,'--legacy-js','--library','-o',legacy]);
    const legacyProbe=path.join(dir,'legacy-probe.mjs');fs.writeFileSync(legacyProbe,
      `import assert from 'node:assert/strict';import * as m from ${JSON.stringify(pathToFileURL(legacy).href)};\n`+
      `assert.equal(typeof m.G,'object');assert.equal(typeof m.G['release.add'],'object');assert.equal(m.default['release.add'](20,22),42);console.log('42');\n`);
    run(mode+' explicit legacy descriptor library',root,[legacyProbe],'42\n');report.outputs.push(identity(legacy),identity(legacyProbe));
    verify(mode+' integrity after',root);
  }
  const runtime=path.join(relocated,'src/runtime/js/direct.mjs'),bytes=fs.readFileSync(runtime);
  try{fs.appendFileSync(runtime,'\n// deliberate release-smoke tamper\n');
    run('relocated runtime tamper rejected',relocated,['tools/development/release.mjs','--verify'],(_out,err)=>assert.match(err,/Changed release input: src\/runtime\/js\/direct\.mjs/),true);
  }finally{fs.writeFileSync(runtime,bytes);}
  assert.equal(hash(runtime),expectedRuntime);verify('relocated restored integrity',relocated);
  for(const item of [...report.inventory,...report.relocation.copied,report.controller,report.release,report.node,...report.outputs])assert.equal(hash(item.file),item.sha256);
  assert.equal(report.steps.length,24);assert.ok(report.steps.every(s=>s.pass));report.complete=true;report.pass=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,steps:report.steps.length,error:report.error}));
