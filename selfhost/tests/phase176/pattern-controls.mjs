// Independent complete-value comparisons. All transformations execute in checked Bend.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';
const opts={};for(let i=2;i<process.argv.length;i+=2)opts[process.argv[i].slice(2)]=process.argv[i+1];
need(opts.baseline&&opts.candidate&&opts.out,'baseline, candidate and fresh out required');
const out=path.resolve(opts.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');fs.mkdirSync(out,{recursive:true});
const report={kind:'phase176-pattern-complete-values',complete:false,inputs:[pin(import.meta.filename),pin(process.execPath)],rows:[],scope:'Finite complete values, independent literal expectation and unchanged checked Bend oracle. No proof or deep native stack-safety claim.'};
function exact(a,b){
  const todo=[[a,b]],seen=new WeakMap();let count=0;
  while(todo.length){need(++count<2000000,'finite comparison bound');const[x,y]=todo.pop();if(Object.is(x,y))continue;
    need(x!==null&&y!==null&&typeof x==='object'&&typeof y==='object','different scalar '+String(x)+' / '+String(y));
    let set=seen.get(x);if(set?.has(y))continue;if(!set){set=new WeakSet();seen.set(x,set);}set.add(y);
    const k=Object.keys(x).sort(),l=Object.keys(y).sort();need(JSON.stringify(k)===JSON.stringify(l),'different keys');for(const key of k)todo.push([x[key],y[key]]);
  }return count;
}
const apis={};
try{
  for(const role of ['baseline','candidate']){const f=opts[role],r=JSON.parse(fs.readFileSync(f));need(r.complete&&r.checked&&r.kind==='bend-checked-hosted-api','checked API');report.inputs.push(pin(f),r.api,r.source,...r.inputs);for(const x of report.inputs)verify(x);apis[role]=(await import(pathToFileURL(r.api.file))).default;}
  for(const name of ['p173bfp_small','p173bfc_result','p175fv_actual','p175fv_expected'])report.rows.push({name,pairs:exact(apis.baseline[name](),apis.candidate[name]()),exact:true});
  for(const role of ['baseline','candidate'])report.rows.push({name:role+'-literal-expectation',pairs:exact(apis[role].p175fv_actual(),apis[role].p175fv_expected()),exact:true});
  // Reuse real terms constructed by independently checked Bend, preserving their
  // aliases. Vary hit/miss ID and both span conditions without host AST lowering.
  const values=apis.baseline.p175fv_actual(),terms=[values.located,values.substituted,values.retained];
  for(const [i,term]of terms.entries())for(const id of [0,7,8,4294967295])for(const replacement of terms){
    const saved=structuredClone(term),replacementSaved=structuredClone(replacement);
    const left=apis.baseline.f_pattern_sub(term,id,replacement),right=apis.candidate.f_pattern_sub(term,id,replacement);
    report.rows.push({name:`sub-${i}-${id}-${terms.indexOf(replacement)}`,pairs:exact(left,right)+exact(term,saved)+exact(replacement,replacementSaved),exact:true});
  }
  for(const [i,term]of terms.entries())for(const [begin,end]of [[0,0],[0,99],[1,2],[23,17],[4294967295,0]])report.rows.push({name:`span-${i}-${begin}-${end}`,pairs:exact(apis.baseline.f_pattern_value(term,begin,end),apis.candidate.f_pattern_value(term,begin,end)),exact:true});
  for(const x of report.inputs)verify(x);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
