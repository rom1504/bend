// Complete values; native digests and worker admission do not replace this gate.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';
const opts={};for(let i=2;i<process.argv.length;i+=2)opts[process.argv[i].slice(2)]=process.argv[i+1];
need(opts.baseline&&opts.candidate&&opts.out,'baseline, candidate and fresh out required');
const out=path.resolve(opts.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');fs.mkdirSync(out,{recursive:true});
const report={kind:'phase177-material-single-complete-values',complete:false,inputs:[pin(import.meta.filename),pin(process.execPath)],rows:[],scope:'Finite complete public values, literal ordering and beta discard expectations, unchanged public helpers. No compiler equivalence proof.'};
function exact(a,b){
  const todo=[[a,b]],seen=new WeakMap();let count=0;
  while(todo.length){need(++count<4000000,'finite comparison bound');const[x,y]=todo.pop();if(Object.is(x,y))continue;
    need(x!==null&&y!==null&&typeof x==='object'&&typeof y==='object','different scalar '+String(x)+' / '+String(y));
    let set=seen.get(x);if(set?.has(y))continue;if(!set){set=new WeakSet();seen.set(x,set);}set.add(y);
    const k=Object.keys(x).sort(),l=Object.keys(y).sort();need(JSON.stringify(k)===JSON.stringify(l),'different keys');for(const key of k)todo.push([x[key],y[key]]);
  }return count;
}
function array(xs){const a=[];for(;xs.$==='Con';xs=xs.tail)a.push(xs.head);need(xs.$==='Nil','list tail');return a;}
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
const apis={};
try{
  for(const role of ['baseline','candidate']){const file=opts[role],r=JSON.parse(fs.readFileSync(file));need(r.complete&&r.checked&&r.kind==='bend-checked-hosted-api','checked API');report.inputs.push(pin(file),r.api,r.source,...r.inputs);report.inputs.forEach(verify);apis[role]=(await import(pathToFileURL(r.api.file))).default;}
  for(const name of ['p177cc_cases','p177cc_priority_actual','p177cc_priority_expected','p173cmw_result','p177msc_cases','p177msc_actual','p177msc_expected'])report.rows.push({name,pairs:exact(apis.baseline[name](),apis.candidate[name]()),exact:true});
  for(const role of ['baseline','candidate'])for(const prefix of ['p177cc_priority','p177msc'])report.rows.push({name:role+'-'+prefix+'-literal',pairs:exact(apis[role][prefix+'_actual'](),apis[role][prefix+'_expected']()),exact:true});
  const cases=[...array(apis.baseline.p177cc_cases()),...array(apis.baseline.p177msc_cases())];
  need(cases.length===32,'case inventory');
  for(const [i,term]of cases.entries())for(const name of ['f_context_higher','f_context_lower','f_context_materialize']){
    const saved=structuredClone(term);
    report.rows.push({name:`${name}-${i}`,pairs:exact(apis.baseline[name](term),apis.candidate[name](term))+exact(term,saved),exact:true});
  }
  // The public child loop is unchanged, including arbitrary partial states.
  const children=[nil,list([cases[0]]),list([cases[4],cases[3]])],built=[nil,list([cases[0]]),list([cases[3],cases[0]])];
  for(const i of [1,4,5,8,9,11,18,19,20,23])for(const [j,rest]of children.entries())for(const [k,done]of built.entries())for(const lower of [false,true]){
    const owner=cases[i],saved=structuredClone([owner,rest,done]);
    report.rows.push({name:`children-${i}-${j}-${k}-${lower}`,pairs:exact(apis.baseline.f_context_material_children(owner,rest,done,lower),apis.candidate.f_context_material_children(owner,rest,done,lower))+exact([owner,rest,done],saved),exact:true});
  }
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
