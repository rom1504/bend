// Run the checked, typed compiler pipeline against selected upstream JS cases.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {execute,loadApi,apiPath} from '../../../tools/typed-driver.mjs';
const project=path.resolve(import.meta.dirname,'../../..');
const upstream=process.env.BEND_UPSTREAM||path.resolve(project,'../upstream-bend');
const api=await loadApi();
const apiSha256=crypto.createHash('sha256').update(fs.readFileSync(apiPath)).digest('hex');
const backendPath=process.env.BEND_JS_BACKEND_API;
const backendSha256=backendPath?crypto.createHash('sha256').update(fs.readFileSync(backendPath)).digest('hex'):null;
if(backendPath)Object.assign(api,(await import(pathToFileURL(backendPath))).default);
const tests=process.argv.slice(2);
if(!tests.length)tests.push('compile/float_roundtrip.bend','base/map_ops.bend','io/chan_rendezvous.bend','io/tcp_loopback.bend','io/marshal_native_forms.bend','show/literal_readback.bend','compile/erased_eta_body.bend','run/nat_overflow.bend','comptime/hand.bend','comptime/tmpl.bend','io/marshal_deep_value.bend');
const rows=[];fs.mkdirSync(path.join(project,'build/js-actual'),{recursive:true});
for(const test of tests){
 const file=path.join(upstream,'tests',test),source=fs.readFileSync(file,'utf8');
 const expected=source.split('\n').filter(l=>l.startsWith('#|')).map(l=>l.slice(2)).join('\n');
 const start=Date.now();const result=await execute(file,{api,timeoutMs:5000});
 const actual=(result.stdout||'')+(result.stderr||'')+(result.exitCode?'exit '+result.exitCode+'\n':'');
 const row={test,expected,actual,apiPath,apiSha256,backendPath,backendSha256,...result,milliseconds:Date.now()-start};delete row.code;
 row.matches=result.phase==='runtime'&&actual.trim()===expected.trim();rows.push(row);
 console.log(test,row.matches?'PASS':result.phase+': '+(result.diagnostic||result.reason||actual.trim()),row.milliseconds+'ms');
 fs.writeFileSync(process.env.BEND_JS_REPORT||path.join(project,'build/js-actual/report.json'),JSON.stringify(rows,null,2)+'\n');
}
console.log(rows.filter(r=>r.matches).length+'/'+rows.length+' typed JS cases passed');
