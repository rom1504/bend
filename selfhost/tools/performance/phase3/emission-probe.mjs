#!/usr/bin/env node
// Disposable B1 attribution. Instrumented counts are not timing measurements.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {performance} from 'node:perf_hooks';
import {pathToFileURL,fileURLToPath} from 'node:url';
const [apiInput,outputInput]=process.argv.slice(2);
if(!apiInput||!outputInput)throw Error('Usage: emission-probe.mjs FROZEN_B1.mjs NEW_OUTPUT_DIRECTORY');
const apiFile=fs.realpathSync(apiInput),out=path.resolve(outputInput);fs.mkdirSync(out,{recursive:false});
const sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const source=fs.readFileSync(apiFile,'utf8');
const rawNames=['j_library_context','j_defs','j_def'];
const expose=`\nexport const emissionProbe={${rawNames.map(name=>`${name}:(...args)=>run_loop($${name}$(...args))`).join(',')}};\n`;
const workers=[...source.matchAll(/^function \$([^ (]+)\$\(/gm)];
const countedNames=workers.map(match=>match[1]).filter(name=>name.startsWith('j_')||['wnf','subst','subst_terms','lookup','index_lookup','core_beta'].includes(name));
const token='(?:[A-Za-z_$][\\w$]*|"(?:\\\\.|[^"\\\\])*")';
const plus=new RegExp('(^[ \\t]*(?:const [A-Za-z_$][\\w$]* =|return) )\\(('+token+') \\+ ('+token+')\\);$','gm');
let counted='',cursor=0,appendSites=0;
for(let i=0;i<workers.length;i++){
  const start=workers[i].index,end=workers[i+1]?.index??source.length;
  counted+=source.slice(cursor,start);let block=source.slice(start,end);
  if(workers[i][1].startsWith('j_'))block=block.replace(plus,(_,prefix,left,right)=>{appendSites++;return `${prefix}__append(${JSON.stringify(workers[i][1])},${left},${right});`;});
  counted+=block;cursor=end;
}
counted+=source.slice(cursor);
assert(appendSites>100,'Unexpected generated emitter shape');
const counters=`\nconst __counts=Object.create(null),__strings=Object.create(null);\nfunction __append(site,a,b){if(typeof a==='string'&&typeof b==='string'){const s=__strings[site]??={calls:0,leftChars:0,rightChars:0,maxLeft:0,maxRight:0};s.calls++;s.leftChars+=a.length;s.rightChars+=b.length;s.maxLeft=Math.max(s.maxLeft,a.length);s.maxRight=Math.max(s.maxRight,b.length);}return a+b;}\n`+countedNames.map(name=>`{const original=$${name}$;$${name}$=function(...args){__counts[${JSON.stringify(name)}]=(__counts[${JSON.stringify(name)}]||0)+1;return original.apply(this,args);};}`).join('\n')+`\nexport const counts={reset(){for(const key of Object.keys(__counts))delete __counts[key];for(const key of Object.keys(__strings))delete __strings[key]},read(){return {calls:{...__counts},strings:structuredClone(__strings)}}};\n`;
const intervention=`\n// Experimental JS-only iterative definition concatenation, not a Bend source change.\n$j_defs$=function(book,defs){const fragments=[];while(defs.$==='Con'){fragments.push(run_loop($j_def$(book,defs.head)));defs=defs.tail;}return fragments.join('');};\n`;
for(const [name,text] of [['plain',source+expose],['counted',counted+counters+expose],['joined',source+intervention+expose]])fs.writeFileSync(path.join(out,name+'.mjs'),text);
const {default:B,emissionProbe:P}=await import(pathToFileURL(path.join(out,'plain.mjs')));
const {emissionProbe:C,counts}=await import(pathToFileURL(path.join(out,'counted.mjs')));
const {emissionProbe:J}=await import(pathToFileURL(path.join(out,'joined.mjs')));
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
const t=(tag,name='',id=0,quant=0,kids=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:nil});
const type=t('Typ','',0,0,[t('Qua','',0,2)]),boolType=t('ADT','Bool'),truth=t('Ctr','True');
const def=(name,typ,value=t('Absent'),kind='Def',ctors=[],arity=0)=>({$:'KDef',name,kind,arity,templates:0,typ,value,ctors:list(ctors),native:false,unsafe:false});
const bool=def('Bool',type,t('Absent'),'ADT',[def('True',boolType,t('Absent'),'Ctr'),def('False',boolType,t('Absent'),'Ctr')]);
const all=(id,a,b)=>t('All','x'+id,id,1,[a,b]);
function input(kind,n){
 if(kind==='definition-count')return [bool,...Array.from({length:n},(_,i)=>def('v'+i,boolType,truth))];
 if(kind==='name-output-size')return [bool,def('value_'+('x'.repeat(n)),boolType,truth)];
 if(kind==='constructor-depth'){
  const treeType=t('ADT','Tree');const tree=def('Tree',type,t('Absent'),'ADT',[def('Leaf',treeType,t('Absent'),'Ctr'),def('Node',all(9000,treeType,treeType),t('Absent'),'Ctr',[],1)]);
  let body=t('Ctr','Leaf');for(let i=0;i<n;i++)body=t('Ctr','Node',0,0,[body]);return [tree,def('value',treeType,body)];
 }
 if(kind==='lambda-depth'){
  let typ=boolType,body=truth;for(let i=n-1;i>=0;i--){typ=all(100+i,boolType,typ);body=t('Lam','x'+(100+i),100+i,1,[body]);}return [bool,def('value',typ,body,'Def',[],n)];
 }
 throw Error('Unknown fixture');
}
const median=values=>[...values].sort((a,b)=>a-b)[Math.floor(values.length/2)];
const rows=[];
for(const [kind,sizes] of [['definition-count',[16,64,256,1024]],['name-output-size',[16,64,256,1024]],['constructor-depth',[8,32,128,512]],['lambda-depth',[8,16,32,64,128]]])for(const size of sizes){
 const defs=input(kind,size),raw=list(defs);assert.equal(B.check_book(raw),'',kind+' synthetic book must check');
 const annotated=B.annotate_book(raw),book=B.book_context(annotated);
 const fixture=path.join(out,kind+'-'+size+'.json');fs.writeFileSync(fixture,JSON.stringify({book:raw,annotated}));
 const expected=P.j_library_context(book,annotated),expectedSha256=sha(expected);
 counts.reset();assert.equal(C.j_library_context(book,annotated),expected);const operations=counts.read();
 assert.equal(J.j_library_context(book,annotated),expected);
 const samples=[];
 for(let round=0;round<5;round++)for(const variant of round%2?['joined','plain']:['plain','joined']){
  const api=variant==='plain'?P:J;const start=performance.now(),output=api.j_library_context(book,annotated),emitted=performance.now();
  assert.equal(sha(output),expectedSha256);const consumed=performance.now();
  samples.push({round,variant,emitMs:emitted-start,consumeMs:consumed-emitted,totalMs:consumed-start});
 }
 const row={kind,size,inputSha256:sha(fs.readFileSync(fixture)),outputBytes:Buffer.byteLength(expected),outputSha256:expectedSha256,operations,samples,medians:Object.fromEntries(['plain','joined'].map(variant=>{const s=samples.filter(row=>row.variant===variant);return [variant,{emitMs:median(s.map(row=>row.emitMs)),consumeMs:median(s.map(row=>row.consumeMs)),totalMs:median(s.map(row=>row.totalMs))}];})),allExact:true};
 rows.push(row);fs.writeFileSync(path.join(out,'progress.json'),JSON.stringify(rows,null,2)+'\n');console.log(JSON.stringify({kind,size,bytes:row.outputBytes,plain:row.medians.plain,joined:row.medians.joined,subst:operations.calls.subst??0}));
}
const report={schemaVersion:1,api:{file:apiFile,sha256:sha(source)},probe:{file:fileURLToPath(import.meta.url),sha256:sha(fs.readFileSync(fileURLToPath(import.meta.url)))},variants:Object.fromEntries(['plain','counted','joined'].map(name=>[name,{file:path.join(out,name+'.mjs'),sha256:sha(fs.readFileSync(path.join(out,name+'.mjs')))}])),node:process.version,nodeArgs:process.execArgv,cpu:0,appendSites,allChecked:true,allExact:true,unchangedApi:sha(fs.readFileSync(apiFile))===sha(source),rows,limitations:['Synthetic checked/annotated books; not full compiler throughput.','Operation wrappers and append operand lengths are an untimed attribution run; operand lengths do not measure copying inside V8.','Plain/joined timings use one warmed process with five alternating samples per size; sub-millisecond cases are noisy.','Fully consumed output is SHA256 over UTF-8 bytes after each emission; output equality is exact before timings as well.','Joined variant changes only disposable generated B1 j_defs; no production Bend source change.']};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
