// Deliberately concurrent publication control, not a performance sample.
// Run with pinned Bun under the external guard. Only these two small compiler
// requests overlap; the independent failure-injection control follows them.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';
import {createHash} from 'node:crypto';
const [binaryArg,outArg]=process.argv.slice(2),binary=fs.realpathSync(binaryArg),out=path.resolve(outArg);
assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const pin=p=>{const b=fs.readFileSync(p);return {file:path.resolve(p),bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};};
const source=out+'/input.bend',dest=out+'/shared.c';fs.writeFileSync(source,'import Base\ndef main() -> U32:\n  42\n');
const report={kind:'phase103-native-cli-publication',complete:false,passed:false,method:pin(import.meta.filename),binary:pin(binary),rows:[]};
function run(id,command,args){return new Promise((resolve,reject)=>{
  const row={id,command:[command,...args]},child=spawn(command,args,{cwd:out,stdio:['ignore','pipe','pipe']});
  const captured={stdout:[],stderr:[]};for(const k of ['stdout','stderr'])child[k].on('data',b=>captured[k].push(b));
  child.on('error',reject);child.on('close',(status,signal)=>{
    Object.assign(row,{status,signal});for(const k of ['stdout','stderr']){const f=out+'/'+id+'.'+k;fs.writeFileSync(f,Buffer.concat(captured[k]));row[k]=pin(f);}
    report.rows.push(row);resolve(row);
  });
});}
try{
  const pair=await Promise.all([run('race-a',binary,[source,'-o',dest]),run('race-b',binary,[source,'-o',dest])]);
  assert.deepEqual(pair.map(r=>r.status).sort(),[0,1]);assert(pair.every(r=>!r.signal));
  const fresh=out+'/reference.c';const reference=await run('reference',binary,[source,'-o',fresh]);assert.equal(reference.status,0);
  report.output=pin(dest);assert.equal(report.output.sha256,pin(fresh).sha256);
  assert(!fs.readdirSync(out).some(s=>s.startsWith('.bend-native-')));
  const failed=out+'/failed.c';
  const fault=await run('write-failure','/bin/bash',['-c','ulimit -f 1; exec "$@"','publication-control',binary,source,'-o',failed]);
  assert(fault.status!==0||fault.signal);assert(!fs.existsSync(failed));
  report.interruptedTemporaryFiles=fs.readdirSync(out).filter(s=>s.startsWith('.bend-native-')).map(s=>pin(out+'/'+s));
  assert.equal(pin(binary).sha256,report.binary.sha256);report.complete=true;report.passed=true;
}catch(e){report.error=e.stack??String(e);process.exitCode=1;}
fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,passed:report.passed,report:out+'/report.json'}));
