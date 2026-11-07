// All transformations execute in independently checked Bend APIs. The host only
// compares complete values and checks that retained aliases remain unchanged.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';
const opts={};for(let i=2;i<process.argv.length;i+=2)opts[process.argv[i].slice(2)]=process.argv[i+1];
need(opts.baseline&&opts.candidate&&opts.out,'baseline, candidate and fresh out required');
const out=path.resolve(opts.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');
fs.mkdirSync(out,{recursive:true});
const report={kind:'phase178-erased-product-complete-values',complete:false,inputs:[pin(import.meta.filename),pin(process.execPath)],rows:[],scope:'Finite complete bodies, reference order/duplicates, retained aliases, direct helpers, definition and closure products. No compiler proof or performance claim.'};
function exact(a,b){
  const todo=[[a,b]],seen=new WeakMap();let count=0;
  while(todo.length){
    need(++count<4000000,'finite comparison bound');const[x,y]=todo.pop();if(Object.is(x,y))continue;
    need(x!==null&&y!==null&&typeof x==='object'&&typeof y==='object','different scalar '+String(x)+' / '+String(y));
    let set=seen.get(x);if(set?.has(y))continue;if(!set){set=new WeakSet();seen.set(x,set);}set.add(y);
    const k=Object.keys(x).sort(),l=Object.keys(y).sort();need(JSON.stringify(k)===JSON.stringify(l),'different keys');
    for(const key of k)todo.push([x[key],y[key]]);
  }return count;
}
function array(xs){const out=[];for(;xs.$==='Con';xs=xs.tail){need(out.length<100,'finite list');out.push(xs.head);}need(xs.$==='Nil','list tail');return out;}
const apis={};
function compare(name,method,args){
  const saved=structuredClone(args);
  const before=apis.baseline[method](...args),after=apis.candidate[method](...args);
  report.rows.push({name,pairs:exact(before,after)+exact(args,saved),exact:true});
}
try{
  for(const role of ['baseline','candidate']){
    const file=opts[role],r=JSON.parse(fs.readFileSync(file));need(r.complete&&r.checked&&r.kind==='bend-checked-hosted-api','checked API');
    report.inputs.push(pin(file),r.api,r.source,...r.inputs);report.inputs.forEach(verify);
    apis[role]=(await import(pathToFileURL(r.api.file))).default;
  }
  for(const name of ['books','cases','telescopes','arguments','definitions','closure_book','string_lists','adt'])compare('inventory-'+name,'erasure_control_'+name,[]);
  for(const role of ['baseline','candidate'])report.rows.push({name:role+'-literal',pairs:exact(apis[role].erasure_control_actual(),apis[role].erasure_control_expected()),exact:true});
  const api=apis.baseline,cases=array(api.erasure_control_cases()),books=array(api.erasure_control_books());
  const tels=array(api.erasure_control_telescopes()),lists=array(api.erasure_control_arguments());
  const strings=array(api.erasure_control_string_lists()),defs=array(api.erasure_control_definitions());
  need(cases.length===20&&books.length===4&&tels.length===4&&lists.length===5&&strings.length===4&&defs.length===4,'control inventory');
  for(const [b,book]of books.entries())for(const [i,row]of cases.entries()){
    for(const s of [0,1,3])for(const t of [0,3])compare(`product-${b}-${i}-${s}-${t}`,'erasure_control_observe',[book,row.input,strings[s],strings[t]]);
    for(const s of [0,3])compare(`uncollected-${b}-${i}-${s}`,'erasure_control_uncollected',[book,row.input,strings[s]]);
    compare(`erase-${b}-${i}`,'nc_erase',[book,row.input]);
    // Exercise public helpers even on shapes their ordinary caller excludes.
    compare(`app-${b}-${i}`,'nc_erase_app',[book,row.input]);
    for(const [j,ty]of tels.entries())compare(`annotated-${b}-${i}-${j}`,'nc_erase_annotated',[book,row.input,ty]);
    compare(`mat-${b}-${i}`,'nc_erase_mat',[book,row.input,api.erasure_control_adt()]);
  }
  for(const [b,book]of books.entries())for(const [i,ts]of lists.entries()){
    compare(`list-${b}-${i}`,'nc_erase_list',[book,ts]);
    for(const [j,tel]of tels.entries())compare(`args-${b}-${i}-${j}`,'nc_erase_args',[book,tel,ts]);
  }
  for(const [b,book]of books.entries())for(const [i,d]of defs.entries())for(const n of [0,7,4294967295]){
    compare(`definition-${b}-${i}-${n}`,'nc_definition_plain',[book,d,n]);
    compare(`definition-product-${b}-${i}-${n}`,'erasure_control_definition',[book,d,n]);
  }
  const raw=api.erasure_control_closure_book();
  for(const [b,book]of [raw,api.book_cached(raw,0)].entries())for(const [i,roots]of strings.entries())for(const [j,done]of strings.entries()){
    compare(`closure-${b}-${i}-${j}`,'nr_walk',[book,roots,done,lists[0]]);
    compare(`visit-${b}-${i}-${j}`,'erasure_control_visit',[book,roots,done,lists[0]]);
  }
  for(const [b,book]of [raw,api.book_cached(raw,0)].entries())for(const mode of [0,1])compare(`incremental-${b}-${mode}`,'erasure_control_incremental',[book,mode]);
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
