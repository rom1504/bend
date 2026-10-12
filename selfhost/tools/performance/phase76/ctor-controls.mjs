// Differential controls for a private constructor index, never a timing image.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
const [apiFile,outDir]=process.argv.slice(2);fs.mkdirSync(outDir);
const pin=p=>({file:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const source=fs.readFileSync(apiFile,'utf8');
const helpers=['nc_find_ctor','nc_find_ctor_plain','ns_attach_book','book_cached'];
for(const h of helpers)assert(source.includes('function $'+h+'$('));
const derived=path.join(outDir,'probe.mjs');
fs.writeFileSync(derived,source+'\n'+helpers.map(h=>'export const '+h+' = (...args)=>run_loop($'+h+'$(...args));').join('\n')+'\n');
const A=await import(pathToFileURL(path.resolve(derived)));
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const atom=()=>({$:'KTerm',tag:'Absent',name:'',id:0,quant:0,kids:list([]),removed:list([]),originBegin:0,originEnd:0});
const def=(name,kind,arity,children=[])=>({$:'KDef',name,kind,arity,templates:0,typ:atom(),value:atom(),ctors:list(children),native:false,unsafe:false});
let seed=7512,count=0;const rnd=()=>seed=(Math.imul(seed,1664525)+1013904223)>>>0;
function check(ds){const original=A.book_cached(list(ds),0),prepared=A.ns_attach_book(original,list([]),0,list([]));for(let i=0;i<13;i++){const name='c'+i;assert.deepEqual(A.nc_find_ctor(prepared,name),A.nc_find_ctor_plain(original,name));count++;}}
check([]);check([def('c1','Def',1),def('D','ADT',0,[def('c1','Ctr',2)]),def('c1','Ctr',3)]);
for(let n=0;n<80;n++){let ds=[];for(let i=0;i<8;i++)ds.push(def('c'+rnd()%10,rnd()%3===0?'Ctr':'ADT',rnd()%8,Array.from({length:rnd()%4},()=>def('c'+rnd()%10,'Ctr',rnd()%8))));check(ds);}
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({complete:true,pass:true,count,inputs:[pin(apiFile),pin(import.meta.filename),pin(derived)],scope:'Exact KDef results against the retained depth-first fallback, including duplicates, nested constructors, missing names and cached source books. Derived helper exports are diagnostic only.'},null,2)+'\n');
console.log(JSON.stringify({pass:true,count}));
