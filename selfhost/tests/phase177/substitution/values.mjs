// Finite complete-value oracle. All transformed values execute in checked Bend.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';
const opts={};for(let i=2;i<process.argv.length;i+=2)opts[process.argv[i].slice(2)]=process.argv[i+1];
need(opts.baseline&&opts.candidate&&opts.out,'baseline, candidate and fresh out required');
const out=path.resolve(opts.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');
fs.mkdirSync(out,{recursive:true});
const report={kind:'phase177-substitution-complete-values',complete:false,inputs:[pin(import.meta.filename),pin(process.execPath)],rows:[],scope:'Finite complete values, independent literal expectations, retained aliases. No mathematical proof or unrestricted depth claim.'};
function exact(a,b){
  const todo=[[a,b]],seen=new WeakMap();let count=0;
  while(todo.length){
    need(++count<2000000,'finite comparison bound');const[x,y]=todo.pop();if(Object.is(x,y))continue;
    need(x!==null&&y!==null&&typeof x==='object'&&typeof y==='object','different scalar '+String(x)+' / '+String(y));
    let set=seen.get(x);if(set?.has(y))continue;if(!set){set=new WeakSet();seen.set(x,set);}set.add(y);
    const k=Object.keys(x).sort(),l=Object.keys(y).sort();need(JSON.stringify(k)===JSON.stringify(l),'different keys');
    for(const key of k)todo.push([x[key],y[key]]);
  }return count;
}
const apis={};
try{
  for(const role of ['baseline','candidate']){
    const file=opts[role],r=JSON.parse(fs.readFileSync(file));need(r.complete&&r.checked&&r.kind==='bend-checked-hosted-api','checked API');
    report.inputs.push(pin(file),r.api,r.source,...r.inputs);report.inputs.forEach(verify);
    apis[role]=(await import(pathToFileURL(r.api.file))).default;
  }
  for(const role of ['baseline','candidate'])for(const suffix of ['','node_']){
    report.rows.push({name:role+'-'+suffix+'literal',pairs:exact(apis[role]['p177sv_'+suffix+'actual'](),apis[role]['p177sv_'+suffix+'expected']()),exact:true});
  }
  const cases=[];let list=apis.baseline.p177sv_cases();
  while(Object.hasOwn(list,'head')){need(cases.length<100,'bounded case list');cases.push(list.head);list=list.tail;}
  need(cases.length===20,'literal case inventory');
  for(const [i,row]of cases.entries())for(const id of [0,7,8,4294967295])for(const value of [row.value,row.input,apis.baseline.p177sv_value()]){
    const saved=structuredClone(row.input),replacementSaved=structuredClone(value);
    report.rows.push({name:`subst-${i}-${id}-${report.rows.length}`,pairs:
      exact(apis.baseline.subst(row.input,id,value),apis.candidate.subst(row.input,id,value))+
      exact(row.input,saved)+exact(value,replacementSaved),exact:true});
  }
  for(const [i,row]of cases.entries()){
    const saved=structuredClone(row.input);
    report.rows.push({name:'node-'+i,pairs:exact(apis.baseline.subst_node(row.input,row.id,row.value),apis.candidate.subst_node(row.input,row.id,row.value))+exact(row.input,saved),exact:true});
  }
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
