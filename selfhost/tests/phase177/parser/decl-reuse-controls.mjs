import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';
const opts={};for(let i=2;i<process.argv.length;i+=2)opts[process.argv[i].slice(2)]=process.argv[i+1];
need(opts.baseline&&opts.candidate&&opts.out,'baseline, candidate and fresh out required');
const out=path.resolve(opts.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');fs.mkdirSync(out,{recursive:true});
const report={kind:'phase177-declaration-reuse-complete-values',complete:false,inputs:[pin(import.meta.filename),pin(process.execPath)],rows:[],scope:'Complete parsed books, diagnostics, imports, spans and parser-cut states. Includes deliberately incoherent public book/scope pairs; no trusted-index invariant.'};
function exact(a,b){
  const todo=[[a,b]],seen=new WeakMap();let count=0;
  while(todo.length){need(++count<4000000,'finite comparison bound');const[x,y]=todo.pop();if(Object.is(x,y))continue;
    need(x!==null&&y!==null&&typeof x==='object'&&typeof y==='object','different scalar '+String(x)+' / '+String(y));
    let set=seen.get(x);if(set?.has(y))continue;if(!set){set=new WeakSet();seen.set(x,set);}set.add(y);
    const k=Object.keys(x).sort(),l=Object.keys(y).sort();need(JSON.stringify(k)===JSON.stringify(l),'different keys');for(const key of k)todo.push([x[key],y[key]]);
  }return count;
}
function array(xs){const a=[];for(;xs.$==='Con';xs=xs.tail)a.push(xs.head);need(xs.$==='Nil','list tail');return a;}
const apis={};
try{
  for(const role of ['baseline','candidate']){const f=opts[role],r=JSON.parse(fs.readFileSync(f));need(r.complete&&r.checked&&r.kind==='bend-checked-hosted-api','checked API');report.inputs.push(pin(f),r.api,r.source,...r.inputs);for(const x of report.inputs)verify(x);apis[role]=(await import(pathToFileURL(r.api.file))).default;}
  for(const name of ['p177dc_sources','p177dc_imports','p177dc_books','p177dc_scopes','p177dc_headers'])report.rows.push({name,pairs:exact(apis.baseline[name](),apis.candidate[name]()),exact:true});
  for(const [i,source]of array(apis.baseline.p177dc_sources()).entries())report.rows.push({name:`load-${i}`,pairs:exact(apis.baseline.p177dc_load(source),apis.candidate.p177dc_load(source)),exact:true});
  const books=array(apis.baseline.p177dc_books()),scopes=array(apis.baseline.p177dc_scopes()),headers=array(apis.baseline.p177dc_headers());
  for(const [i,book]of books.entries())for(const [j,scope]of scopes.entries())for(const [k,source]of headers.entries())for(const stop of [0,1]){
    const saved=structuredClone([book,scope]);
    const left=apis.baseline.p177dc_direct(source,book,scope,stop),right=apis.candidate.p177dc_direct(source,book,scope,stop);
    report.rows.push({name:`header-book-${i}-scope-${j}-source-${k}-stop-${stop}`,pairs:exact(left,right)+exact([book,scope],saved),exact:true});
  }
  for(const x of report.inputs)verify(x);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
