// Offline, lossless P88 data transport. No compiler or lowering is executed.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {decodeGraph} from './graph.mjs';

const args={};for(let i=2;i<process.argv.length;i+=2)args[process.argv[i].slice(2)]=process.argv[i+1];
for(const key of ['capture','schema','out'])assert(args[key]);
const root=path.resolve(import.meta.dirname,'../../..'),out=path.resolve(args.out);
assert(out.startsWith(root+'/selfhost/build/phase154/')&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const read=p=>JSON.parse(fs.readFileSync(p)),pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>{const now=pin(p.file);assert.equal(now.bytes,p.bytes);assert.equal(now.sha256,p.sha256)};
const spec=[
 ['Nil',[],[]],['Con',['head','tail'],[13,14]],
 ['KTerm',['tag','name','id','quant','kids','removed','originBegin','originEnd'],[3,3,1,1,6,8,1,1]],
 ['KLambda',['name','id','quant','kids','removed','originBegin','originEnd','quantityPresent'],[3,1,1,6,8,1,1,2]],
 ['KLiteral',['kind','number','text','originBegin','originEnd'],[3,1,3,1,1]],
 ['KDef',['name','kind','arity','templates','typ','value','ctors','native','unsafe'],[3,3,1,1,4,4,7,2,2]],
 ['KIndexLeaf',['hash','bucket'],[1,7]],['KIndexNode',['hash','mask','left','right'],[1,1,5,5]],
];
const tags=new Map(spec.map(([tag],i)=>[tag,i]));
const schema={True:[],False:[]};
const source=fs.readFileSync(args.schema,'utf8');
for(const block of source.matchAll(/^type [^\n]+:\n((?:[ \t].*\n|\n)*)/gm))for(const m of block[1].matchAll(/^  ([\w.]+)\{([^\n]*)\}/gm))schema[m[1]]=[...m[2].matchAll(/(?:^|,)\s*\+?([A-Za-z_][A-Za-z0-9_]*)\s*:/g)].map(x=>x[1]);
for(const[tag,keys]of spec.slice(2))assert.deepEqual(schema[tag],keys,'Checked source schema '+tag);
const report={kind:'phase154-lossless-book-fixtures',version:1,complete:false,targetsRun:false,
 inputs:[pin(import.meta.filename),pin(path.join(import.meta.dirname,'graph.mjs')),pin(args.capture),pin(args.schema),pin(root+'/selfhost/src/host/prepared-base.bend')],
 bounds:{nodes:262144,strings:8192,textBytes:16*1024**2,headerBytes:200000},rows:[],
 scope:'Exact entire captured NR_Request.book, including all caches/indices. Identity-deduplicated postorder P88 records; no source, owner, term or metadata pruning. Host transport roundtrip is separate from forthcoming checked Bend decoder validation.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
function word(n){assert(Number.isInteger(n)&&n>=0&&n<=4294967295,'U32 range');return n;}
function sameGraph(a,b){const seen=new Map(),back=new Map(),todo=[[a,b]];let objects=0;while(todo.length){const[x,y]=todo.pop();if(x===null||typeof x!=='object'){assert.equal(y,x);continue;}assert(y&&typeof y==='object');if(seen.has(x)){assert.equal(seen.get(x),y,'Lost sharing');continue;}assert(!back.has(y),'Merged distinct objects');seen.set(x,y);back.set(y,x);objects++;assert.deepEqual(Object.keys(x).sort(),Object.keys(y).sort());for(const k of Object.keys(x))todo.push([x[k],y[k]]);}return objects;}
function serialize(book){const ids=new Map(),active=new Set(),strings=[],stringIds=new Map(),records=[];
 const string=s=>{assert.equal(typeof s,'string');for(const ch of s){const c=ch.codePointAt(0);assert(c<55296||c>57343,'Invalid Unicode scalar');}if(!stringIds.has(s)){assert(strings.length<8192);stringIds.set(s,strings.length);strings.push(s);}return stringIds.get(s);};
 function node(v){assert(v&&typeof v==='object'&&!Array.isArray(v));if(ids.has(v))return ids.get(v);assert(!active.has(v),'Cyclic book is not admitted by postorder P88');active.add(v);
  const tag=tags.get(v.$);assert(tag!==undefined,'Unexpected constructor '+v.$);const[,keys,roles]=spec[tag];assert.deepEqual(Object.keys(v).sort(),['$',...keys].sort());
  const fields=keys.map((key,i)=>{const x=v[key],r=roles[i];if(r===1)return word(x);if(r===2){assert.equal(typeof x,'boolean');return x?1:0;}if(r===3)return string(x);if(r===13&&typeof x==='string')return 2147483648+string(x);return node(x);});
  assert(records.length<262144);const id=records.length;records.push([tag,fields]);ids.set(v,id);active.delete(v);return id;
 }
 const bookRoot=node(book),pieces=[records.length+'\n',strings.length+'\n'];for(const s of strings)pieces.push([...s].length+'\n',s,'\n');for(const[tag,fields]of records)pieces.push(tag+'\n',fields.length+'\n',...fields.map(n=>n+'\n'));pieces.push(bookRoot+'\n');
 const text=pieces.join('');assert(Buffer.byteLength(text)<=16*1024**2);return{text,nodeCount:records.length,stringCount:strings.length,root:bookRoot};
}
function deserialize(text){let at=0;const number=()=>{const end=text.indexOf('\n',at);assert(end>=at);const raw=text.slice(at,end);assert(/^(0|[1-9][0-9]*)$/.test(raw));at=end+1;return word(Number(raw));};
 const n=number(),sn=number();assert(n>=1&&n<=262144&&sn<=8192);const strings=[];
 for(let i=0;i<sn;i++){const size=number();assert(size<=1048576);const begin=at;for(let j=0;j<size;j++){assert(at<text.length);at+=text.codePointAt(at)>65535?2:1;}strings.push(text.slice(begin,at));assert.equal(text[at++],'\n');}
 const nodes=[];for(let i=0;i<n;i++){const tag=number(),width=number();assert(tag<8);const[name,keys,roles]=spec[tag];assert.equal(width,keys.length);const obj={$:name};keys.forEach((key,j)=>{const v=number(),role=roles[j];if(role===1)obj[key]=v;else if(role===2){assert(v<=1);obj[key]=Boolean(v);}else if(role===3||(role===13&&v>=2147483648)){const id=role===3?v:v-2147483648;assert(id<sn);obj[key]=strings[id];}else{assert(v<i,'Forward node reference');obj[key]=nodes[v];}});nodes.push(obj);}
 const id=number();assert(id<n&&at===text.length,'Trailing data or root range');return nodes[id];
}
function literal(value){if(typeof value==='boolean')return value?'True{}':'False{}';if(typeof value==='number')return String(word(value));if(typeof value==='string'){const s=JSON.stringify(value);assert(!s.includes('\\u'),'Unsupported Bend literal escape');return s;}if(Array.isArray(value))return'['+value.map(literal).join(',')+']';if(value.$==='Nil')return'[]';if(value.$==='Con'){const xs=[];let p=value;while(p.$==='Con'){xs.push(p.head);p=p.tail;}assert.equal(p.$,'Nil');return literal(xs);}const keys=schema[value.$];assert(keys,'Unknown header constructor '+value.$);assert.deepEqual(Object.keys(value).sort(),['$',...keys].sort());return value.$+'{'+keys.map(k=>literal(value[k])).join(',')+'}';}
try{
 const capture=read(args.capture);assert(capture.complete);
 for(const family of capture.rows){verify(family.graph);verify(family.headers);report.inputs.push(family.graph,family.headers);const captured=decodeGraph(read(family.graph.file)),book=captured.request.book;
  const encoded=serialize(book),file=out+'/'+family.name+'.book.txt';fs.writeFileSync(file,encoded.text,{flag:'wx'});const decoded=deserialize(fs.readFileSync(file,'utf8'));
  const objectCount=sameGraph(book,decoded),headers=read(family.headers.file),defs=[['headers','List<&2,N111Segment>',headers.segments],['constructors','List<&2,N_Constructor>',headers.constructors],['direct_headers','List<&2,P113DFunction>',headers.directHeaders]];
  const fixture=defs.map(([name,type,data])=>'def p154h_'+name+'() -> '+type+':\n  '+literal(data)+'\n').join('\n');assert(Buffer.byteLength(fixture)<=200000,'Headers exceed explicit literal budget');const headerFile=out+'/'+family.name+'.headers.bend';fs.writeFileSync(headerFile,fixture,{flag:'wx'});
  report.rows.push({family:family.name,inputGraph:family.graph,book:pin(file),headers:pin(headerFile),nodes:encoded.nodeCount,strings:encoded.stringCount,root:encoded.root,hostRoundTrip:{complete:true,allFieldsExact:true,objectCount,sharingPreserved:true,noExtraMerging:true},bendDecoderValidation:'pending'});save();
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}finally{save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.map(r=>({family:r.family,nodes:r.nodes,strings:r.strings,bytes:r.book.bytes,headers:r.headers.bytes})),error:report.error}));}
