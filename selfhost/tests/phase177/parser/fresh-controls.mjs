// All transformations run in independently checked Bend. Host comparison visits
// every constructor/scalar field and checks retained argument aliases unchanged.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';
const opts={};for(let i=2;i<process.argv.length;i+=2)opts[process.argv[i].slice(2)]=process.argv[i+1];
need(opts.baseline&&opts.candidate&&opts.out,'baseline, candidate and fresh out required');
const out=path.resolve(opts.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');fs.mkdirSync(out,{recursive:true});
const report={kind:'phase177-fresh-complete-values',complete:false,inputs:[pin(import.meta.filename),pin(process.execPath)],rows:[],scope:'Complete finite values, unchanged independently checked Bend oracle, literal ID/scope expectation, and retained aliases. No mathematical proof or deep native stack claim.'};
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
  for(const name of ['p177fc_cases','p177fc_envs','p177fc_book','p177fc_actual','p177fc_expected'])report.rows.push({name,pairs:exact(apis.baseline[name](),apis.candidate[name]()),exact:true});
  for(const role of ['baseline','candidate'])report.rows.push({name:role+'-literal-expectation',pairs:exact(apis[role].p177fc_actual(),apis[role].p177fc_expected()),exact:true});
  const cases=array(apis.baseline.p177fc_cases()),envs=array(apis.baseline.p177fc_envs());
  for(const [i,term]of cases.entries())for(const [j,env]of envs.entries())for(const next of [0,1,100,4294967295]){
    const saved=structuredClone(term),savedEnv=structuredClone(env);
    const left=apis.baseline.f_fresh_term(term,env,next),right=apis.candidate.f_fresh_term(term,env,next);
    report.rows.push({name:`term-${i}-env-${j}-next-${next}`,pairs:exact(left,right)+exact(term,saved)+exact(env,savedEnv),exact:true});
  }
  const book=apis.baseline.p177fc_book();
  for(const next of [0,1,100,4294967295]){const saved=structuredClone(book);report.rows.push({name:`book-${next}`,pairs:exact(apis.baseline.f_fresh_defs(book,next),apis.candidate.f_fresh_defs(book,next))+exact(book,saved),exact:true});}
  for(const x of report.inputs)verify(x);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
