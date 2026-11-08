// Finite complete heap values and literal EQ/LE expectations from checked Bend.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';
const opts={};for(let i=2;i<process.argv.length;i+=2)opts[process.argv[i].slice(2)]=process.argv[i+1];
need(opts.candidate&&opts.out,'candidate and fresh out required');
const out=path.resolve(opts.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');fs.mkdirSync(out,{recursive:true});
const report={kind:'phase182-sharing-values',complete:false,inputs:[pin(import.meta.filename),pin(process.execPath)],rows:[],scope:'Finite complete values, preserved aliases and literal directional-comparison outcomes. Separate source/proof regressions remain required.'};
function exact(a,b){
  const todo=[[a,b]],seen=new WeakMap();let count=0;
  while(todo.length){need(++count<2000000,'finite comparison bound');const[x,y]=todo.pop();if(Object.is(x,y))continue;
    need(x!==null&&y!==null&&typeof x==='object'&&typeof y==='object','different scalar '+String(x)+' / '+String(y));
    let set=seen.get(x);if(set?.has(y))continue;if(!set){set=new WeakSet();seen.set(x,set);}set.add(y);
    const k=Object.keys(x).sort(),l=Object.keys(y).sort();need(JSON.stringify(k)===JSON.stringify(l),'different keys');for(const key of k)todo.push([x[key],y[key]]);
  }return count;
}
function array(xs){const a=[];for(;xs.$==='Con';xs=xs.tail)a.push(xs.head);need(xs.$==='Nil','list tail');return a;}
try{
  const r=JSON.parse(fs.readFileSync(opts.candidate));need(r.complete&&r.checked&&r.kind==='bend-checked-hosted-api','checked API');
  report.inputs.push(pin(opts.candidate),r.api,r.source,...r.inputs);report.inputs.forEach(verify);
  const api=(await import(pathToFileURL(r.api.file))).default;
  const checks=array(api.p182s_checks());need(checks.length===16&&checks.every(x=>x===true),'class/heap invariant checks');
  checks.forEach((value,i)=>report.rows.push({name:'class-invariant-'+i,value,exact:true}));
  const relations=api.p182s_relations();
  report.rows.push({name:'literal-relations',pairs:exact(relations,api.p182s_relations_expected()),exact:true});
  need(JSON.stringify(array(relations))===JSON.stringify([true,false,false,true]),'EQ/LE independent outcomes');
  const heaps=array(api.p182s_heap_observations());need(heaps.length===5,'heap observation count');
  for(const [a,b,name]of [[0,1,'join-moves-no-value'],[0,2,'cache-preserves-equivalent-value'],[3,4,'share-adds-only-new-cell']])report.rows.push({name,pairs:exact(heaps[a],heaps[b]),exact:true});
  const original=api.p182s_state(),saved=structuredClone(original),joined=api.g_class_join(original,1,2);
  report.rows.push({name:'retained-original',pairs:exact(original,saved)+exact(api.g_heap(original),api.g_heap(joined)),exact:true});
  need(api.g_class_same(original,1,2)===false&&api.g_class_same(joined,1,2)===true,'independent state facts');
  const all=api.p182s_joined();report.rows.push({name:'same-class-union-identity',pairs:exact(all,api.g_class_join(all,4,1)),exact:true});
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
