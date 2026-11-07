// Generic value transport from an independently checked upstream API.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,workspace} from '../../tools/build/hosted.mjs';

const args={};
for(let i=2;i<process.argv.length;i+=2){
  assert(process.argv[i]?.startsWith('--')&&process.argv[i+1]);
  const key=process.argv[i].slice(2);assert(!Object.hasOwn(args,key));args[key]=process.argv[i+1];
}
assert.deepEqual(Object.keys(args).sort(),['out','receipt']);
const receipt=JSON.parse(fs.readFileSync(args.receipt,'utf8'));
assert.equal(receipt.kind,'bend-checked-hosted-api');
assert(receipt.complete&&receipt.checked&&receipt.status===0&&!receipt.error&&!receipt.signal);
assert.deepEqual(receipt.exports,['main']);
assert.equal(receipt.command[0],fs.realpathSync(process.execPath));
const inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath),pin(args.receipt),
  ...receipt.inputs,receipt.source,receipt.api];
inputs.forEach(verify);
const out=path.resolve(args.out);
assert(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out));
assert.equal(fs.realpathSync(path.dirname(out)),path.dirname(out));
fs.mkdirSync(out);
const report={kind:'phase173-independent-u32-oracle',complete:false,inputs,
  scope:'Pinned upstream checked main value; bounded numeric observation, not an equivalence proof.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
try{
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  assert.equal(typeof api.main,'function');
  const value=api.main();
  assert(Number.isInteger(value)&&value>=0&&value<=4294967295);
  fs.writeFileSync(path.join(out,'expected.txt'),String(value)+'\n',{flag:'wx'});
  inputs.forEach(verify);
  report.value=value;report.expected=pin(path.join(out,'expected.txt'));report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,value:report.value,error:report.error}));}
