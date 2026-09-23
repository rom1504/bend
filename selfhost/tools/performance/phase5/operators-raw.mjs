// Check the complete accepted loader result after moving the operator guard.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,baseFile,selectionFile,output]=process.argv.slice(2);
assert.ok(output&&!fs.existsSync(output));
const sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const inputs=new Map(), read=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);inputs.set(file,{file,sha256:sha(bytes)});return bytes;};
for(const file of [baseline,candidate,baseFile,selectionFile,import.meta.filename])read(file);
const list=items=>items.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const basePath=fs.realpathSync(baseFile),baseText=fs.readFileSync(basePath,'utf8');
const base={$:'FSource',name:'Base',path:basePath,text:baseText};
const apis=await Promise.all([baseline,candidate].map(async file=>(await import(pathToFileURL(fs.realpathSync(file)))).default));
const prefixes=apis.map(api=>api.f_load_graph('Base',list([base])));
for(const prefix of prefixes)assert.equal(prefix.error,'');
assert.deepEqual(prefixes[1],prefixes[0]);
const rows=[];
for(const item of JSON.parse(fs.readFileSync(selectionFile,'utf8'))) {
  const file=fs.realpathSync(path.resolve(path.dirname(selectionFile),item.file)),text=read(file).toString('utf8');
  const sources=list([{$:'FSource',name:file,path:file,text},base]);
  const results=apis.map((api,index)=>api.f_load_graph_seed(file,sources,basePath,baseText,prefixes[index].book));
  assert.equal(results[0].error,'',item.id);assert.deepEqual(results[1],results[0],item.id);
  const serialized=JSON.stringify(results[0]);rows.push({id:item.id,equal:true,bytes:Buffer.byteLength(serialized),sha256:sha(serialized)});
}
for(const row of inputs.values())assert.equal(sha(fs.readFileSync(row.file)),row.sha256);
fs.writeFileSync(output,JSON.stringify({kind:'phase5-operator-accepted-raw-equivalence',complete:true,compilerExecuted:true,inputs:[...inputs.values()],rows,scope:'Full loader data, field/order/removal metadata and errors; not a new execution-lane run.'},null,2)+'\n');
console.log(JSON.stringify({complete:true,programs:rows.length}));
