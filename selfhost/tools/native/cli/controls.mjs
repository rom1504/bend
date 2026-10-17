#!/usr/bin/env node
// Serial public CLI controls. The caller supplies the external resource guard.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';

const [packageArg,outArg,mode='compiler',...extra]=process.argv.slice(2);
assert(packageArg&&outArg&&!extra.length&&['harness','compiler'].includes(mode),
  'Usage: controls.mjs PACKAGE_DIR OUT_DIR [harness|compiler]');
const pkg=fs.realpathSync(packageArg),out=path.resolve(outArg),name=mode==='harness'?'harness':'bend';
assert(!fs.existsSync(out),'Use a fresh OUT_DIR');
assert(out!==pkg&&!out.startsWith(pkg+path.sep),'OUT_DIR must be outside the package');
const sha=b=>createHash('sha256').update(b).digest('hex');
const pin=p=>{const b=fs.readFileSync(p);return {file:path.resolve(p),bytes:b.length,sha256:sha(b),mode:fs.statSync(p).mode&0o777};};
function inventory(dir){return fs.readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name)).flatMap(e=>{
  const p=path.join(dir,e.name);assert(!e.isSymbolicLink(),'Package assets must not depend on symlinks: '+p);
  return e.isDirectory()?inventory(p):[pin(p)];
});}
fs.mkdirSync(out,{recursive:true});
const relocated=path.join(out,'relocated package'),work=path.join(out,'caller café'),bin=path.join(out,'bin');
const report={kind:'phase103-native-cli-controls',version:1,complete:false,passed:false,mode,
  method:pin(import.meta.filename),package:pkg,rows:[],scope:'Finite serial CLI controls; no admission, fixed-point, compiler-equivalence or performance claim.',
  timingScope:'Whole process: runtime startup, asset authentication, Base preparation, compile/copy, and output publication. No kernel-time isolation or balanced performance comparison.',
  supervision:'15-second per-process timeout; external caller owns runner RSS/deadline/process-tree supervision.',
  skipped:['concurrent publication: deferred for explicit root review']};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const exists=p=>{try{fs.lstatSync(p);return true;}catch(e){if(e.code==='ENOENT')return false;throw e;}};
const source='import Base\ndef main() -> U32:\n  42\n';
const ioSource='import Base\ndef main() -> IO(Unit):\n  IO.print("cli control")\n';
const output=id=>path.join(work,id+'.c');
let executable,original,reference;
function invoke(id,args,expected,{cwd=work,command=executable,env=process.env,target=null,input=null,check=()=>{}}={}){
  assert(!report.rows.some(r=>r.id===id),'Duplicate case');
  const row={id,command:[command,...args],cwd,expectedStatus:expected,passed:false};
  if(input&&exists(path.resolve(cwd,input)))row.input=pin(path.resolve(cwd,input));
  if(env!==process.env)row.env={PATH:env.PATH};
  report.rows.push(row);save();
  const start=performance.now(),r=spawnSync(command,args,{cwd,env,timeout:15000,killSignal:'SIGKILL',maxBuffer:1024**2});
  row.wallSeconds=(performance.now()-start)/1000;
  row.status=r.status;row.signal=r.signal;row.error=r.error?.message??null;
  for(const stream of ['stdout','stderr']){
    const bytes=r[stream]??Buffer.alloc(0),p=path.join(out,id+'.'+stream);
    fs.writeFileSync(p,bytes);row[stream]={...pin(p),text:bytes.toString('utf8')};
  }
  try{
    assert(!r.error&&!r.signal,'Process failed or exceeded 15 seconds');assert.equal(r.status,expected);
    if(expected!==0){assert(row.stderr.bytes>0,'Failure needs a diagnostic');assert.equal(row.stdout.bytes,0);}
    if(target){
      if(expected===0){
        assert(fs.statSync(target).isFile());row.output=pin(target);assert(row.output.bytes>0);
        if(mode==='harness')assert.deepEqual(fs.readFileSync(target),fs.readFileSync(input));
        else assert(fs.readFileSync(target,'utf8').includes('#define MAIN_FID '),'Expected complete generated C');
        assert.equal(row.stdout.bytes,0);
      }else assert(!exists(target),'Failed request published output');
    }
    check(row);row.passed=true;
  }catch(e){row.failure=e.message;}
  // Keep identities and raw diagnostics; remove only successful fresh generated files.
  if(target&&expected===0&&exists(target)&&fs.lstatSync(target).isFile()){
    row.output??=pin(target);fs.unlinkSync(target);row.outputRemoved=true;
  }
  save();return row;
}
function compile(id,input=path.join(work,'input.bend'),flags=[],options={}){
  const target=output(id);return invoke(id,[input,'-o',target,...flags],0,{target,input,...options});
}
function rejected(id,input,flags=[],status=1){
  const target=output(id);return invoke(id,[input,'-o',target,...flags],status,{target,input});
}
save();
try{
  original=[pin(path.join(pkg,name)),...inventory(path.join(pkg,'assets'))];report.originalInputs=original;
  fs.mkdirSync(relocated);fs.copyFileSync(path.join(pkg,name),path.join(relocated,name));
  fs.chmodSync(path.join(relocated,name),original[0].mode);
  fs.cpSync(path.join(pkg,'assets'),path.join(relocated,'assets'),{recursive:true});
  executable=path.join(relocated,name);report.executable=pin(executable);
  fs.mkdirSync(work);fs.mkdirSync(bin);fs.writeFileSync(path.join(work,'input.bend'),source);
  fs.writeFileSync(path.join(work,'space λ.bend'),source);fs.writeFileSync(path.join(work,'-leading.bend'),source);
  fs.writeFileSync(path.join(work,'io.bend'),ioSource);fs.writeFileSync(path.join(work,'invalid-utf8.bend'),Buffer.from([0xc0,0xaf]));
  const usage=[['no-args',[]],['unknown-option',['--not-a-cli-option']],['duplicate-output',['input.bend','-o',output('unused-a'),'-o',output('unused-b')]],
    ['missing-output',['input.bend']],['missing-output-value',['input.bend','-o']],['duplicate-live',['input.bend','-o',output('unused-c'),'--live','--live']],
    ['extra-input',['input.bend','input.bend','-o',output('unused-a')]],['empty-output',['input.bend','-o','']]];
  for(const [id,args] of usage)invoke(id,args,2,{check:()=>{for(const n of ['unused-a','unused-b','unused-c'])assert(!exists(output(n)));}});
  invoke('help',['--help'],0,{check:r=>{assert.match(r.stdout.text,/Usage: bend/);assert.equal(r.stderr.bytes,0);}});
  invoke('version',['--version'],0,{check:r=>{assert.match(r.stdout.text,/bend-native phase103/);assert.equal(r.stderr.bytes,0);}});
  reference=compile('cached');compile('live',undefined,['--live'],{check:r=>assert.equal(r.output.sha256,reference.output?.sha256,'Same-input live/cache output differs')});
  const target=output('option-first');invoke('option-first',['--output',target,'input.bend'],0,{target,input:path.join(work,'input.bend')});
  const dashed=output('delimiter');invoke('delimiter',['-o',dashed,'--','-leading.bend'],0,{target:dashed,input:path.join(work,'-leading.bend')});
  compile('unicode-space','space λ.bend',[],{input:path.join(work,'space λ.bend')});
  fs.symlinkSync(executable,path.join(bin,'bend-test'));
  compile('path-symlink','input.bend',[],{command:'bend-test',env:{...process.env,PATH:bin},input:path.join(work,'input.bend')});
  compile('absolute-other-cwd',path.join(work,'input.bend'),[],{cwd:out});
  const kept=output('preserved');fs.writeFileSync(kept,'preserve me\n',{mode:0o640});const before=pin(kept);
  invoke('existing-file',['input.bend','-o',kept],1,{check:()=>assert.deepEqual(pin(kept),before)});
  const directory=output('directory');fs.mkdirSync(directory);
  invoke('existing-directory',['input.bend','-o',directory],1,{check:()=>assert(fs.lstatSync(directory).isDirectory())});
  const dangling=output('dangling');fs.symlinkSync('absent-target',dangling);
  invoke('dangling-symlink',['input.bend','-o',dangling],1,{check:()=>assert.equal(fs.readlinkSync(dangling),'absent-target')});
  rejected('missing-input','missing.bend');rejected('invalid-utf8','invalid-utf8.bend');
  const alias=pin(path.join(work,'input.bend'));
  invoke('source-output-alias',['input.bend','-o','input.bend'],1,{check:()=>assert.deepEqual(pin(alias.file),alias)});
  const huge=path.join(work,'oversized.bend');fs.writeFileSync(huge,'');fs.truncateSync(huge,16777217);
  try{rejected('oversized-input',huge);}finally{fs.unlinkSync(huge);}
  const absentParent=path.join(work,'absent-parent','output.c');
  invoke('missing-parent',['input.bend','-o',absentParent],1,{target:absentParent});
  const assets=path.join(relocated,'assets'),hidden=path.join(relocated,'assets.hidden');
  fs.renameSync(assets,hidden);
  try{rejected('relocated-no-assets','input.bend');invoke('help-no-assets',['--help'],0);invoke('version-no-assets',['--version'],0);}
  finally{fs.renameSync(hidden,assets);}
  if(mode==='compiler'){
    fs.writeFileSync(path.join(work,'parse-error.bend'),'import Base\ndef main(\n');
    fs.writeFileSync(path.join(work,'type-error.bend'),'import Base\ndef main() -> U32:\n  "wrong"\n');
    rejected('parse-rejection','parse-error.bend');rejected('type-rejection','type-error.bend');
    fs.writeFileSync(path.join(work,'module-import.bend'),'import Base\nimport ./input.bend as Input\ndef main() -> U32:\n  42\n');
    fs.writeFileSync(path.join(work,'foreign.bend'),'import Base\ndef foreign() -> IO(Unit):\n  import "./foreign.c"\ndef main() -> IO(Unit):\n  foreign()\n');
    fs.writeFileSync(path.join(work,'foreign.c'),'/* must never be admitted */\n');
    assert.match(rejected('module-import-refusal','module-import.bend').stderr.text,/rejects additional import/);
    assert.match(rejected('foreign-provider-refusal','foreign.bend').stderr.text,/rejects foreign path/);
    compile('effect','io.bend');
    for(const [label,relative] of [['base','base.bend'],['cache','base.p88'],['part','runtime.c.part0'],['effect','effs/print.c']]){
      const file=path.join(assets,relative),backup=file+'.control-backup';fs.renameSync(file,backup);
      try{
        rejected('missing-'+label,'io.bend');
        fs.writeFileSync(file,Buffer.concat([fs.readFileSync(backup),Buffer.from('\n# altered\n')]));
        rejected('corrupt-'+label,'io.bend');
      }finally{if(exists(file))fs.unlinkSync(file);fs.renameSync(backup,file);}
    }
  }
  for(const p of original)assert.deepEqual(pin(p.file),p,'Original package changed');
  report.originalPackageUnchanged=true;report.relocatedAssetsRestored=inventory(path.join(relocated,'assets')).every(p=>{
    const item=original.find(q=>path.relative(path.join(pkg,'assets'),q.file)===path.relative(path.join(relocated,'assets'),p.file));
    return item&&item.sha256===p.sha256&&item.bytes===p.bytes&&item.mode===p.mode;
  });assert(report.relocatedAssetsRestored);
  report.complete=true;report.passed=report.rows.every(r=>r.passed);
}catch(e){report.error=e.stack??String(e);}
finally{save();console.log(JSON.stringify({report:path.join(out,'report.json'),complete:report.complete,passed:report.passed,cases:report.rows.length}));if(!report.passed)process.exitCode=1;}
