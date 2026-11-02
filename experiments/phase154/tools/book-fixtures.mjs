// Offline data transport only: exact captured book, no compiler calls/pruning.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';
import {decodeGraph}from'./graph.mjs';
const root=path.resolve(import.meta.dirname,'../../..'),a={};for(let i=2;i<process.argv.length;i+=2)a[process.argv[i].slice(2)]=process.argv[i+1];
for(const k of ['capture','schema','out'])assert(a[k]);
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>{const x=pin(p.file);assert(x.bytes===p.bytes&&x.sha256===p.sha256,'Changed input '+p.file)};
const out=path.resolve(a.out);assert(out.startsWith(root+'/selfhost/build/phase154/')&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const schema={True:[],False:[]};for(const m of fs.readFileSync(a.schema,'utf8').matchAll(/^  (KDef|KIndexLeaf|KIndexNode|KTerm|KLambda|KLiteral)\{([^\n]*)\}/gm))if(!schema[m[1]])schema[m[1]]=[...m[2].matchAll(/(?:^|,)\s*\+?([A-Za-z_][A-Za-z0-9_]*)\s*:/g)].map(x=>x[1]);
for(const tag of ['KDef','KIndexLeaf','KIndexNode','KTerm','KLambda','KLiteral'])assert(schema[tag]);
const report={kind:'phase154-exact-book-fixture-estimate',version:1,complete:false,targetsRun:false,inputs:[pin(import.meta.filename),pin(path.join(import.meta.dirname,'graph.mjs')),pin(a.capture),pin(a.schema)],rows:[],scope:'Exact full request.book; no algorithmic or metadata pruning. JSON/literal expansion can duplicate graph sharing; original graph remains authoritative.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
try{
 const capture=JSON.parse(fs.readFileSync(a.capture));assert(capture.complete);
 for(const row of capture.rows){verify(row.graph);report.inputs.push(row.graph);const graph=JSON.parse(fs.readFileSync(row.graph.file)),captured=decodeGraph(graph),book=captured.request.book,memo=new WeakMap();
  function primitive(v){if(typeof v==='boolean')return v?'True{}':'False{}';if(typeof v==='number'){assert(Number.isInteger(v)&&v>=0&&v<=4294967295);return String(v)}assert.equal(typeof v,'string');return JSON.stringify(v)}
  function fields(v){const names=schema[v.$];assert(names,'Unknown constructor '+v.$);assert.deepEqual(Object.keys(v).sort(),['$',...names].sort());return names}
  function size(v){if(!v||typeof v!=='object')return Buffer.byteLength(primitive(v));if(memo.has(v))return memo.get(v);let n;
   if(v.$==='Nil')n=2;else if(v.$==='Con'){n=2;let p=v;while(p.$==='Con'){n+=size(p.head)+(p.tail.$==='Nil'?0:1);p=p.tail}assert.equal(p.$,'Nil');}
   else{const names=fields(v);n=Buffer.byteLength(v.$)+2+Math.max(0,names.length-1)+names.reduce((s,k)=>s+size(v[k]),0)}
   assert(Number.isSafeInteger(n));memo.set(v,n);return n;}
  const bytes=size(book),entry={family:row.name,graph:row.graph,literalBytes:bytes,withinLiteralBudget:bytes<=1_500_000};report.rows.push(entry);save();
  const ordinary=JSON.stringify(book)+'\n';assert(Buffer.byteLength(ordinary)<=256*1024**2,'Ordinary JSON bound exceeded');const jsonFile=out+'/'+row.name+'-book.json';fs.writeFileSync(jsonFile,ordinary);entry.json=pin(jsonFile);
  if(entry.withinLiteralBudget){const chunks=[];function emit(v){if(!v||typeof v!=='object'){chunks.push(primitive(v));return}if(v.$==='Nil'){chunks.push('[]');return}if(v.$==='Con'){chunks.push('[');let p=v;while(p.$==='Con'){emit(p.head);p=p.tail;if(p.$!=='Nil')chunks.push(',')}assert.equal(p.$,'Nil');chunks.push(']');return}const names=fields(v);chunks.push(v.$,'{');names.forEach((k,i)=>{if(i)chunks.push(',');emit(v[k])});chunks.push('}')}
   emit(book);const literal=chunks.join('');assert.equal(Buffer.byteLength(literal),bytes);const file=out+'/'+row.name+'-book.bend';fs.writeFileSync(file,'def p154_fixture_book() -> List<&2,KDef>:\n  '+literal+'\n');entry.bend=pin(file);
  }
  save();
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack??e);process.exitCode=1}finally{save();console.log(JSON.stringify(report.rows.map(r=>({family:r.family,literalBytes:r.literalBytes,jsonBytes:r.json?.bytes,bend:r.bend?.file}))))}
