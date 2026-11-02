// Run only inside the parent's guarded target lane. No frontend capture/build.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {decodeGraph} from './graph.mjs';

const args={};for(let i=2;i<process.argv.length;i+=2)args[process.argv[i].slice(2)]=process.argv[i+1];
for(const key of ['api','books','out'])assert(args[key],'Missing --'+key);
const root=path.resolve(import.meta.dirname,'../../..'),out=path.resolve(args.out);
assert(out.startsWith(root+'/selfhost/build/phase154/')&&!fs.existsSync(out),'Fresh Phase154 output required');
fs.mkdirSync(out,{recursive:true});
const read=file=>JSON.parse(fs.readFileSync(file));
const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return{file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')}};
const verify=p=>{const actual=pin(p.file);assert.equal(actual.bytes,p.bytes,'Changed size '+p.file);assert.equal(actual.sha256,p.sha256,'Changed bytes '+p.file)};
const report={kind:'phase154-checked-book-inputs',version:1,complete:false,passed:false,
 inputs:[pin(import.meta.filename),pin(path.join(import.meta.dirname,'graph.mjs')),pin(args.api),pin(args.books),pin(process.execPath)],rows:[],
 scope:'Actual checked Bend p154r_read versus entire captured request.book. Iterative exact structural comparison includes every field and value. This does not claim physical object identity, native execution, producer parity or performance.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();

function equalStructure(expected,actual){
 const todo=[[expected,actual]],seen=new WeakMap();let objectPairs=0,primitiveValues=0,fields=0;
 while(todo.length){const [x,y]=todo.pop();
  if(x===null||typeof x!=='object'){assert.equal(y,x,'Primitive mismatch after '+fields+' fields');primitiveValues++;continue;}
  assert(y!==null&&typeof y==='object','Missing object '+String(x.$));assert.equal(Array.isArray(y),Array.isArray(x),'Array/object mismatch');
  let pairs=seen.get(x);if(pairs?.has(y))continue;if(!pairs){pairs=new WeakSet();seen.set(x,pairs);}pairs.add(y);objectPairs++;
  const keys=Object.keys(x).sort();assert.deepEqual(Object.keys(y).sort(),keys,'Field set mismatch for '+String(x.$));
  for(const key of keys){fields++;todo.push([x[key],y[key]]);}
 }
 return{objectPairs,primitiveValues,fields,allFieldsExact:true};
}

try{
 const receipt=read(args.api),books=read(args.books);
 assert.equal(receipt.kind,'bend-checked-hosted-api');assert(receipt.complete&&receipt.checked,'Completed checked API acquisition required');
 assert.equal(books.kind,'phase154-lossless-book-fixtures');assert(books.complete&&books.targetsRun===false,'Completed exact fixture transport required');
 assert.deepEqual(books.rows.map(r=>r.family),['compiler-verifier-slice','coverage-map-churn-128'],'Both fixed captured families required');
 report.api=receipt.api;report.source=receipt.source;
 report.inputs.push(receipt.api,receipt.source,...receipt.inputs,...books.inputs);
 for(const row of books.rows)report.inputs.push(row.book,row.inputGraph);
 report.inputs.forEach(verify);
 const api=(await import(pathToFileURL(receipt.api.file))).default;assert.equal(typeof api.p154r_read,'function','Missing checked decoder export');
 for(const fixture of books.rows){
  const row={family:fixture.family,book:fixture.book,inputGraph:fixture.inputGraph,complete:false,passed:false};report.rows.push(row);save();
  const text=fs.readFileSync(fixture.book.file,'utf8'),expected=decodeGraph(read(fixture.inputGraph.file)).request.book;
  const start=performance.now(),decoded=api.p154r_read(text);row.decoderSeconds=(performance.now()-start)/1000;
  row.resultTag=decoded?.$;assert.equal(row.resultTag,'P154RReady','Decoder refusal: '+String(decoded?.error));
  assert.deepEqual(Object.keys(decoded).sort(),['$','book']);row.comparison=equalStructure(expected,decoded.book);
  row.complete=row.passed=true;save();
 }
 report.inputs.forEach(verify);report.complete=report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{
 try{report.inputs.forEach(verify);report.finalInputsVerified=true;}catch(error){report.complete=report.passed=false;report.finalInputsVerified=false;report.finalInputError=String(error.stack??error);process.exitCode=1;}
 save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,rows:report.rows.map(r=>({family:r.family,passed:r.passed,decoderSeconds:r.decoderSeconds,comparison:r.comparison})),error:report.error,finalInputError:report.finalInputError}));
}
