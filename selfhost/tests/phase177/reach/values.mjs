// All reachability algorithms execute in independently checked Bend APIs.
// Compare every constructor/scalar field and preserve the caller's input aliases.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';

const opts={};
for(let i=2;i<process.argv.length;i+=2)opts[process.argv[i].slice(2)]=process.argv[i+1];
need(opts.baseline&&opts.candidate&&opts.out,'baseline, candidate and fresh out required');
const out=path.resolve(opts.out);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');
fs.mkdirSync(out,{recursive:true});
const report={kind:'phase177-reach-complete-values',complete:false,
  inputs:[pin(import.meta.filename),pin(process.execPath)],rows:[],
  scope:'Finite complete ordered KDef values, independent literal expectations, unchanged public kr_visit, and retained aliases. No proof or performance claim.'};
const values=[];

function exact(a,b){
  const todo=[[a,b]],seen=new WeakMap();let count=0;
  while(todo.length){
    need(++count<2000000,'finite comparison bound');
    const[x,y]=todo.pop();if(Object.is(x,y))continue;
    need(x!==null&&y!==null&&typeof x==='object'&&typeof y==='object',
      'different scalar '+String(x)+' / '+String(y));
    let set=seen.get(x);if(set?.has(y))continue;
    if(!set){set=new WeakSet();seen.set(x,set);}set.add(y);
    const k=Object.keys(x).sort(),l=Object.keys(y).sort();
    need(JSON.stringify(k)===JSON.stringify(l),'different constructor fields');
    for(const key of k)todo.push([x[key],y[key]]);
  }
  return count;
}

function array(xs){
  const result=[];
  for(;xs.$==='Con';xs=xs.tail){need(result.length<1000,'bounded fixture list');result.push(xs.head);}
  need(xs.$==='Nil','proper fixture list');return result;
}

const apis={};
try{
  for(const role of ['baseline','candidate']){
    const file=opts[role],r=JSON.parse(fs.readFileSync(file));
    need(r.complete&&r.checked&&r.kind==='bend-checked-hosted-api','independently checked API');
    report.inputs.push(pin(file),r.api,r.source,...r.inputs);
    report.inputs.forEach(verify);
    apis[role]=(await import(pathToFileURL(r.api.file))).default;
  }
  const baselineCases=apis.baseline.p177rv_cases(),candidateCases=apis.candidate.p177rv_cases();
  report.rows.push({name:'identical-literal-inputs-and-expectations',pairs:exact(baselineCases,candidateCases),exact:true});
  const cases=array(baselineCases);
  need(cases.length===32,'exact 32-case inventory');
  const names=new Set(cases.map(row=>row.name));need(names.size===32,'unique fixture names');
  for(const row of cases){
    const saved=structuredClone(row);
    const original=apis.baseline.reach_book(row.book,row.roots,row.stops);
    const candidate=apis.candidate.reach_book(row.book,row.roots,row.stops);
    const independent=apis.candidate.p177rv_original(row.book,row.roots,row.stops);
    const record={name:row.name,input:row,original,candidate,independent,publicVisits:[]};
    values.push(record);
    report.rows.push({name:row.name,pairs:exact(original,row.expected)+exact(candidate,row.expected)+
      exact(independent,row.expected)+exact(row,saved),exact:true});
    for(const [i,initial]of [cases[0].roots,row.roots,row.stops].entries()){
      const before=structuredClone(initial);
      const left=apis.baseline.kr_visit(row.book,row.roots,initial,row.stops);
      const right=apis.candidate.kr_visit(row.book,row.roots,initial,row.stops);
      record.publicVisits.push({initial,original:left,candidate:right});
      report.rows.push({name:row.name+'-public-visit-'+i,pairs:exact(left,right)+exact(initial,before)+exact(row,saved),exact:true});
    }
  }
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'values.json'),JSON.stringify(values)+'\n');
report.values=pin(path.join(out,'values.json'));
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
