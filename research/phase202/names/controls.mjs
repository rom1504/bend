import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';
const args=Object.fromEntries(process.argv.slice(2).reduce((p,x,i,a)=>i%2?p:[...p,[x,a[i+1]]],[]));
if(!/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8')))throw Error('guarded CPU3 required');
const r=JSON.parse(fs.readFileSync(args['--api']));
if(!r.complete||!r.checked||r.error)throw Error('checked API required');
verify(r.api);verify(r.source);
const api=(await import(pathToFileURL(r.api.file))).default;
const words=['','a','b','ab','aa','ba','abc','abd','a\0b','é','é','λ','中','🦊','λx','λy','x'.repeat(128),'x'.repeat(127)+'y'];
let count=0;
for(const a of words)for(const b of words)for(const state of [false,true]){
 const expected=state&&a===b?'True':'False';
 for(const name of ['p88_string_eq_go','p202n_original']){
  const value=api[name](a,b,{$:state?'True':'False'});
  if(value.$!==expected)throw Error(JSON.stringify({name,a,b,state,expected,value}));count++;
 }
 if(state){const value=api.p202n_eq(a,b);if(value.$!==expected)throw Error('neutral mismatch');count++;}
}
const out=path.resolve(args['--out']);fs.mkdirSync(out);
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:true,api:r.api,source:r.source,driver:pin(fileURLToPath(import.meta.url)),words:words.length,observations:count,oracle:'independent JavaScript exact Unicode string equality; false state always false'},null,2)+'\n');
