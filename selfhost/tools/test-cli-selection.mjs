// Metadata-only shell controls. The fixture host never loads a compiler or runs a target.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawnSync} from 'node:child_process';

const root=fs.mkdtempSync(path.join(os.tmpdir(),'bend-cli-selection-'));
const project=path.join(root,'selfhost');
const write=(name,text)=>{const file=path.join(project,name);fs.mkdirSync(path.dirname(file),{recursive:true});fs.writeFileSync(file,text);return file;};
const pin=file=>{const bytes=fs.readFileSync(file);return {file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};};
try{
  const cli=write('cli.mjs',fs.readFileSync(path.join(import.meta.dirname,'../cli.mjs')));
  const api=pin(write('dist/typed-api.mjs','fixture API never imported'));
  api.file='selfhost/dist/typed-api.mjs';
  const template=write('runtime-template.json','{"version":1,"fixture":"declared"}');
  const current={kind:'bend-current-bindings',version:1,complete:true,gateStatus:{qualified:true},
    components:{js:{host:'js',stage:'B2',protocol:'hosted-api-v1',image:api}},files:{[api.file]:api},
    providers:{base:pin(write('dist/base.bend','fixture Base')),
      jsLegacyRuntime:pin(write('src/runtime.mjs','fixture legacy runtime')),
      jsDirectRuntime:pin(write('src/runtime/js/direct.mjs','fixture direct runtime')),
      cRuntimeTemplate:pin(template)}};
  write('manifests/current.json',JSON.stringify(current));
  write('tools/typed-driver.mjs','export async function main(args){process.stdout.write(JSON.stringify({template:process.env.BEND_TYPED_RUNTIME_TEMPLATE,args}));}\n');
  const env=Object.fromEntries(Object.entries(process.env).filter(([key])=>!key.startsWith('BEND_')));
  const run=(extra,args=['--fixture'])=>{
    const stdout=path.join(root,'stdout'),stderr=path.join(root,'stderr');
    const out=fs.openSync(stdout,'w'),err=fs.openSync(stderr,'w');
    let child;
    try{child=spawnSync(process.execPath,[cli,...args],{env:{...env,...extra},stdio:['ignore',out,err]});}
    finally{fs.closeSync(out);fs.closeSync(err);}
    return {...child,stdout:fs.readFileSync(stdout,'utf8'),stderr:fs.readFileSync(stderr,'utf8')};
  };
  let got=run({});
  assert.equal(got.status,0,got.stderr);
  assert.deepEqual(JSON.parse(got.stdout),{template,args:['--fixture']});
  const override=write('override-template.json','explicit caller template');
  got=run({BEND_TYPED_RUNTIME_TEMPLATE:override});
  assert.equal(got.status,0,got.stderr);
  assert.equal(JSON.parse(got.stdout).template,override);
  fs.appendFileSync(template,'changed');
  got=run({});
  assert.equal(got.status,1);
  assert.equal(got.stdout,'');
  assert.match(got.stderr,/Current file changed/);
  write('tools/build/public-native.py','import json, sys\nprint(json.dumps(sys.argv[1:]))\nsys.exit(23)\n');
  for(const args of [['--target','x86','input.bend','--run'],['input.bend','-o','program.s'],['--target=x86','input.bend','-o','program']]){
    got=run({},args);
    assert.equal(got.status,23,got.stderr);
    assert.deepEqual(JSON.parse(got.stdout),args);
  }
  const applicationArgs=['--fixture','--','--target','x86','-o','data.s'];
  got=run({BEND_TYPED_RUNTIME_TEMPLATE:override},applicationArgs);
  assert.equal(got.status,0,got.stderr);
  assert.deepEqual(JSON.parse(got.stdout).args,applicationArgs);
  console.log('CLI template selection metadata controls passed');
}finally{fs.rmSync(root,{recursive:true,force:true});}
