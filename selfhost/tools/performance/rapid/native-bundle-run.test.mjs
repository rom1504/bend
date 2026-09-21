import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import assert from 'node:assert/strict';
import {runNativeBundle} from './native-bundle-run.mjs';
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'bend-native-run-test-'));
const file=(name,text=name)=>{const p=path.join(directory,name);fs.writeFileSync(p,text);return p};
const options={binary:file('binary'),input:file('input'),base:file('base'),runtime:file('runtime'),output:file('output','old'),mode:'program'};
let launches=0;
const fake=(command,args)=>{launches++;assert.equal(command,options.binary);assert.deepEqual(args.slice(0,5),['--threads','1','--gpu','off','--']);assert.notEqual(args[8],options.output);fs.writeFileSync(args[8],'new');return {status:0,stderr:'compile_ms=12\nconsumed_chars=3\n',stdout:''}};
try {
  for(const name of ['binary','input','base','runtime']) assert.throws(()=>runNativeBundle({...options,output:options[name]},{spawn:fake}),/aliases/);
  const symbolic=path.join(directory,'symbolic');fs.symlinkSync(options.input,symbolic);assert.throws(()=>runNativeBundle({...options,output:symbolic},{spawn:fake}),/aliases/);
  const hard=path.join(directory,'hard');fs.linkSync(options.base,hard);assert.throws(()=>runNativeBundle({...options,output:hard},{spawn:fake}),/aliases/);
  const dangling=path.join(directory,'dangling');fs.symlinkSync('absent',dangling);assert.throws(()=>runNativeBundle({...options,output:dangling},{spawn:fake}),/symbolic/);
  assert.equal(launches,0);
  const fail=runNativeBundle(options,{spawn:(cmd,args)=>{fs.writeFileSync(args[8],'partial');return {status:1,stderr:'phase=check checked=true: mismatch'}}});
  assert.equal(fail.published,false);assert.equal(fs.readFileSync(options.output,'utf8'),'old');
  const timeout=runNativeBundle(options,{spawn:()=>({status:null,signal:'SIGTERM',error:Error('timeout')})});assert.equal(timeout.published,false);assert.equal(fs.readFileSync(options.output,'utf8'),'old');
  const ok=runNativeBundle(options,{spawn:fake});assert.equal(ok.published,true);assert.equal(ok.compileMs,12);assert.equal(ok.consumedChars,3);assert.equal(fs.readFileSync(options.output,'utf8'),'new');
  for(const name of ['binary','input','base','runtime'])assert.equal(fs.readFileSync(options[name],'utf8'),name);
  assert.equal(fs.readdirSync(directory).filter(x=>x.startsWith('.bend-native-')).length,0);
  assert.throws(()=>runNativeBundle({...options,cpu:'1; x'},{spawn:fake}),/CPU/);
  assert.throws(()=>runNativeBundle({...options,mode:'other'},{spawn:fake}),/Mode/);
  console.log(JSON.stringify({passed:14,cases:['direct aliases','symlink alias','hardlink alias','dangling symlink','failed partial output','timeout preserves destination','atomic success','timing markers','inputs unchanged','temporary cleanup','CPU validation','mode validation']}));
} finally {fs.rmSync(directory,{recursive:true,force:true});}
