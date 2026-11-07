// Original checked f_sub is the differential reference; expected data is literal.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';
const opts={};for(let i=2;i<process.argv.length;i+=2)opts[process.argv[i].slice(2)]=process.argv[i+1];
need(opts.baseline&&opts.candidate&&opts.out,'baseline, candidate and fresh out required');
const out=path.resolve(opts.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');fs.mkdirSync(out,{recursive:true});
const report={kind:'phase177-frontend-substitution-complete-values',complete:false,inputs:[pin(import.meta.filename),pin(process.execPath)],rows:[],scope:'Finite complete values against original checked f_sub and independent literal expectations; retained aliases. No theorem or native performance claim.'};
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
  for(const role of ['baseline','candidate']){const file=opts[role],r=JSON.parse(fs.readFileSync(file));need(r.complete&&r.checked&&r.kind==='bend-checked-hosted-api','checked API');report.inputs.push(pin(file),r.api,r.source,...r.inputs);report.inputs.forEach(verify);apis[role]=(await import(pathToFileURL(r.api.file))).default;}
  for(const name of ['p177fsc_cases','p177fsc_actual','p177fsc_expected'])report.rows.push({name,pairs:exact(apis.baseline[name](),apis.candidate[name]()),exact:true});
  for(const role of ['baseline','candidate'])report.rows.push({name:role+'-literal',pairs:exact(apis[role].p177fsc_actual(),apis[role].p177fsc_expected()),exact:true});
  const cases=array(apis.baseline.p177fsc_cases());need(cases.length===20,'case inventory');
  for(const [i,row]of cases.entries())for(const id of [0,7,8,4294967295])for(const [j,value]of [row.value,row.input,apis.baseline.p177fsc_value(0,0)].entries()){
    const saved=structuredClone(row.input),replacementSaved=structuredClone(value);
    report.rows.push({name:`f_sub-${i}-${id}-${j}`,pairs:exact(apis.baseline.f_sub(row.input,id,value),apis.candidate.f_sub(row.input,id,value))+exact(row.input,saved)+exact(value,replacementSaved),exact:true});
  }
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
