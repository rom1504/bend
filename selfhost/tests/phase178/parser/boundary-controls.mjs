import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';
const opts={};for(let i=2;i<process.argv.length;i+=2)opts[process.argv[i].slice(2)]=process.argv[i+1];
need(opts.baseline&&opts.candidate&&opts.out,'baseline, candidate and fresh out required');
const out=path.resolve(opts.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');fs.mkdirSync(out,{recursive:true});
const report={kind:'phase178-parser-continuation-complete-values',complete:false,inputs:[pin(import.meta.filename),pin(process.execPath)],rows:[],scope:'Six original public continuation APIs, including independent old values and incoherent book/scope pairs. Complete values and retained input aliases; no proof or runtime claim.'};
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
  for(const name of ['p177dc_books','p177dc_scopes','p178pc_nodes','p178pc_olds','p178pc_alias_scope'])report.rows.push({name,pairs:exact(apis.baseline[name](),apis.candidate[name]()),exact:true});
  const books=array(apis.baseline.p177dc_books()),scopes=array(apis.baseline.p177dc_scopes()),nodes=array(apis.baseline.p178pc_nodes()),olds=array(apis.baseline.p178pc_olds());
  const contexts=[[0,0],[1,1],[2,2],[3,4],[4,3],[5,1]].map(([b,s])=>[books[b],scopes[s]]);
  contexts.push([books[0],apis.baseline.p178pc_alias_scope()]);
  const headers=['f(x):\n  x\n','f(+x: Type) -> Type:\n  x\n','f(\n','f() -> Type:\n  Type\n','A.f(x):\n  x\n','f(x):\n  x\ndef next() -> Type:\n  Type\n'];
  const cases=[...headers.flatMap(source=>[[0,source,0],[1,source,0]]),
    ...[0,1,2,3].flatMap(n=>[[2,':\n  x\n',n],[2,'-> Type:\n  x\n',n],[3,':\n  x\n',n],[3,'-> Type:\n  x\n',n]]),
    ...[3,4,5,6,7].flatMap(n=>[[4,':\n  Type\n',n],[4,':\n  import "foreign.c"\n',n]]),
    ...[3,4,5,7].map(n=>[5,'\ndef next() -> Type:\n  Type\n',n])];
  for(const [ci,[book,scope]]of contexts.entries())for(const [ki,[entry,source,ni]]of cases.entries())for(const [oi,old]of (entry<3?olds:[olds[0]]).entries())for(const stop of [0,1]){
    const args=[entry,source,nodes[ni],book,scope,old,stop],saved=structuredClone(args);
    report.rows.push({name:`context-${ci}-case-${ki}-old-${oi}-stop-${stop}`,pairs:exact(apis.baseline.p178pc_boundary(...args),apis.candidate.p178pc_boundary(...args))+exact(args,saved),exact:true});
  }
  for(const x of report.inputs)verify(x);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
