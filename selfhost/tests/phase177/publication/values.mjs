// All transformations run in independently checked Bend. Host comparison visits
// every constructor/scalar field and checks retained argument aliases unchanged.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';
const opts={};for(let i=2;i<process.argv.length;i+=2)opts[process.argv[i].slice(2)]=process.argv[i+1];
need(opts.baseline&&opts.candidate&&opts.out,'baseline, candidate and fresh out required');
const out=path.resolve(opts.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');fs.mkdirSync(out,{recursive:true});
const report={kind:'phase177-index-remove-complete-values',complete:false,inputs:[pin(import.meta.filename),pin(process.execPath)],rows:[],scope:'Complete finite values, unchanged independently checked Bend oracle, literal ID/scope expectation, and retained aliases. No mathematical proof or deep native stack claim.'};
function exact(a,b){
  const todo=[[a,b]],seen=new WeakMap();let count=0;
  while(todo.length){need(++count<2000000,'finite comparison bound');const[x,y]=todo.pop();if(Object.is(x,y))continue;
    need(x!==null&&y!==null&&typeof x==='object'&&typeof y==='object','different scalar '+String(x)+' / '+String(y));
    let set=seen.get(x);if(set?.has(y))continue;if(!set){set=new WeakSet();seen.set(x,set);}set.add(y);
    const k=Object.keys(x).sort(),l=Object.keys(y).sort();need(JSON.stringify(k)===JSON.stringify(l),'different keys');for(const key of k)todo.push([x[key],y[key]]);
  }return count;
}
function array(xs){const a=[];for(;xs.$==='Con';xs=xs.tail)a.push(xs.head);need(xs.$==='Nil','list tail');return a;}
const apis={};
try{
  for(const role of ['baseline','candidate']){const f=opts[role],r=JSON.parse(fs.readFileSync(f));need(r.complete&&r.checked&&r.kind==='bend-checked-hosted-api','checked API');report.inputs.push(pin(f),r.api,r.source,...r.inputs);for(const x of report.inputs)verify(x);apis[role]=(await import(pathToFileURL(r.api.file))).default;}
  const rows=apis.baseline.p177iv_rows();
  report.rows.push({name:'fixture',pairs:exact(rows,apis.candidate.p177iv_rows()),exact:true});
  const word=s=>[...s].reduceRight((tail,c)=>({$:"SCon",head:c,tail}),{$:"SNil"});
  for(const input of [{$:'Nil'},rows,{$:'Con',head:rows.head,tail:rows}])for(const text of ['', 'a','b','absent','costarring','liquid','商']){
    const name=text,saved=structuredClone(input),savedName=structuredClone(name);
    report.rows.push({name:text,pairs:exact(apis.baseline.index_remove(input,name),apis.candidate.index_remove(input,name))+exact(input,saved)+exact(name,savedName),exact:true});
  }
  for(const x of report.inputs)verify(x);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
