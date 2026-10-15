// Diagnose the retained legacy smoke's Clang launch failure; no compiler changes.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawnSync} from 'node:child_process';
const [rootArg,outArg]=process.argv.slice(2),root=fs.realpathSync(rootArg),out=path.resolve(outArg);
fs.mkdirSync(out);
const project=path.join(root,'selfhost'),clangRoot=path.join(project,'build/phase1/clang/root');
const cc=path.join(clangRoot,'usr/bin/clang-16');
const source=path.join(project,'build/phase90/release07/legacy42/checks/ordinary/base-u32/program.c');
const pin=file=>({file:fs.realpathSync(file),sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex'),bytes:fs.statSync(file).size});
const env={...process.env,CC:cc,CPATH:path.join(clangRoot,'usr/include'),LIBRARY_PATH:path.join(clangRoot,'usr/lib/x86_64-linux-gnu'),LD_LIBRARY_PATH:path.join(clangRoot,'usr/lib/x86_64-linux-gnu')};
const report={kind:'phase90-clang-spawn-transport-diagnostic',inputs:[pin(import.meta.filename),pin(process.execPath),pin(cc),pin(source)],rows:[],complete:false};
for(const mode of ['pipes','files']) {
 const binary=path.join(out,mode+'.bin'),args=['-std=c11','-O3',source,'-lpthread','-lm','-o',binary];
 const stdout=path.join(out,mode+'.stdout'),stderr=path.join(out,mode+'.stderr');
 let result;
 if(mode==='pipes') {
  result=spawnSync(cc,args,{cwd:project,env,encoding:'utf8',timeout:10000,maxBuffer:2**20});
  fs.writeFileSync(stdout,result.stdout??'');fs.writeFileSync(stderr,result.stderr??'');
 } else {
  const a=fs.openSync(stdout,'wx'),b=fs.openSync(stderr,'wx');
  try{result=spawnSync(cc,args,{cwd:project,env,timeout:10000,stdio:['ignore',a,b]});}finally{fs.closeSync(a);fs.closeSync(b);}
 }
 report.rows.push({mode,command:[cc,...args],status:result.status,signal:result.signal,error:result.error?{message:result.error.message,code:result.error.code,errno:result.error.errno}:null,stdout:pin(stdout),stderr:pin(stderr),binary:fs.existsSync(binary)?pin(binary):null});
 fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
}
report.complete=true;fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report));
