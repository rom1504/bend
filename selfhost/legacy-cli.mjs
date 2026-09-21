#!/usr/bin/env node
// File/argument plumbing only. The compiler subprocess is generated from Bend.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
const root=import.meta.dirname,argv=process.argv.slice(2);
const usage='Usage: node legacy-cli.mjs INPUT.bend [-o OUTPUT.mjs | --run [-- ARGS...]]\nUnchecked, single-file JavaScript compiler. It does not check Bend proofs.';
if(!argv.length||argv[0]==='--help'){console.log(usage);process.exit(argv.length?0:2)}
if(argv.includes('--check')||argv.includes('--check-only')){console.error('The dependent-type/proof checker has not been ported. Use the pinned upstream checker.');process.exit(2)}
let tmp;
try{
  const input=path.resolve(argv.shift());let output,run=false,args=[];
  if(fs.statSync(input).size>16777216)throw Error('Source exceeds the current 16 MiB input limit');
  while(argv.length){const a=argv.shift();if(a==='-o'&&argv.length)output=path.resolve(argv.shift());else if(a==='--run')run=true;else if(a==='--'){args=argv;break}else throw Error('Unknown or incomplete option '+a)}
  if(run&&output)throw Error('Choose either --run or -o');
  if(output&&fs.existsSync(output)&&fs.realpathSync(input)===fs.realpathSync(output))throw Error('Refusing to overwrite the input source');
  const result=spawnSync(process.execPath,[path.join(root,'dist/bend2c.mjs'),input,path.join(root,'src/runtime.mjs')],{encoding:'utf8',maxBuffer:64*1024*1024,timeout:120000});
  if(result.error||result.status!==0)throw Error(result.error?.message||result.stderr.trim()||'Compilation failed');
  console.error('Unchecked Bend2 -> JavaScript: no type, affine-use or proof validation.');
  if(run){
    tmp=fs.mkdtempSync(path.join(os.tmpdir(),'bend2-selfhost-'));
    const file=path.join(tmp,'program.mjs');fs.writeFileSync(file,result.stdout);
    const r=spawnSync(process.execPath,[file,...args],{stdio:'inherit'});if(r.error)throw r.error;process.exitCode=r.status??1;
  }else if(output){
    const staged=output+'.tmp-'+process.pid;fs.writeFileSync(staged,result.stdout);fs.renameSync(staged,output);
  }else process.stdout.write(result.stdout);
}catch(e){console.error(e.message);process.exitCode=1}finally{if(tmp)fs.rmSync(tmp,{recursive:true,force:true})}
