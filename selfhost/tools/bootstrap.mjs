import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
const root=path.resolve(import.meta.dirname,'..');
const pin='6018e28ecc67cf1fffc0c20c64b11023474c2df8';
const upstream=process.env.BEND_UPSTREAM||path.join(root,'.bootstrap/upstream');
function exec(bin,args,options={}){
  const p=spawnSync(bin,args,{cwd:root,encoding:'utf8',maxBuffer:64*1024*1024,timeout:120000,...options});
  if(p.error||p.status!==0)throw Error(`${bin} ${args.join(' ')}\n${p.error||p.stderr||p.stdout}`);
  return p.stdout;
}
try{
  fs.mkdirSync(path.join(root,'build'),{recursive:true});fs.mkdirSync(path.join(root,'dist'),{recursive:true});
  if(!fs.existsSync(path.join(upstream,'bend2/bend.ts'))){
    fs.mkdirSync(upstream,{recursive:true});
    exec('git',['init',upstream]);
    exec('git',['-C',upstream,'fetch','--depth','1','https://github.com/bendlang/bend.git',pin]);
    exec('git',['-C',upstream,'checkout','--detach','FETCH_HEAD']);
  }
  const actual=exec('git',['-C',upstream,'rev-parse','HEAD']).trim();
  if(actual!==pin)throw Error(`Upstream revision mismatch: ${actual}; expected ${pin}`);
  const bun=process.env.BUN||'bun';
  const started=performance.now();
  exec(process.execPath,['tools/stage0.mjs','src/compiler.bend','build/stage1.cjs'],{env:{...process.env,BEND_UPSTREAM:upstream}});
  console.log('1. Upstream checked the Bend source and built stage 1.');
  const stage2=exec(bun,['build/stage1.cjs','src/compiler.bend','src/runtime.mjs']);
  fs.writeFileSync(path.join(root,'build/stage2.mjs'),stage2);
  console.log('2. Stage 1 compiled the Bend source into stage 2.');
  const stage3=exec(process.execPath,['build/stage2.mjs','src/compiler.bend','src/runtime.mjs']);
  fs.writeFileSync(path.join(root,'build/stage3.mjs'),stage3);
  if(stage2!==stage3)throw Error('Bootstrap fixed point failed: stage 2 differs from stage 3');
  const stage4=exec(process.execPath,['build/stage3.mjs','src/compiler.bend','src/runtime.mjs']);
  if(stage3!==stage4)throw Error('Bootstrap fixed point failed: stage 3 differs from stage 4');
  fs.writeFileSync(path.join(root,'dist/bend2c.mjs'),stage3);
  const sha=createHash('sha256').update(stage3).digest('hex');
  const report={upstream:pin,node:process.version,bun:exec(bun,['--version']).trim(),source_sha256:createHash('sha256').update(fs.readFileSync(path.join(root,'src/compiler.bend'))).digest('hex'),runtime_sha256:createHash('sha256').update(fs.readFileSync(path.join(root,'src/runtime.mjs'))).digest('hex'),output_sha256:sha,stage2_equals_stage3:true,stage3_equals_stage4:true,seconds:(performance.now()-started)/1000};
  fs.writeFileSync(path.join(root,'dist/bootstrap-report.json'),JSON.stringify(report,null,2)+'\n');
  console.log('3. Stages 2, 3 and 4 are byte-for-byte identical.\nSHA256 '+sha);
}catch(e){console.error(e.message);process.exitCode=1}
