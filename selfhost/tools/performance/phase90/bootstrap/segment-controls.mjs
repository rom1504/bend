// ROOT-RUN CORRECTNESS TARGET: OLD_FULL_API NEW_FULL_API NEW_REPORT_JSON.
// Real exported compiler functions only; no generated-code rewriting or builds.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

Error.stackTraceLimit=100;
const [oldArg,newArg,outArg]=process.argv.slice(2);
assert.equal(process.argv.length,5,'OLD_FULL_API NEW_FULL_API NEW_REPORT_JSON');
const oldFile=fs.realpathSync(oldArg),newFile=fs.realpathSync(newArg),out=path.resolve(outArg);
assert(!fs.existsSync(out));
const sha=bytes=>createHash('sha256').update(bytes).digest('hex');
const pin=file=>({file:fs.realpathSync(file),sha256:sha(fs.readFileSync(file)),bytes:fs.statSync(file).size});
const report={kind:'phase90-segment-traversal-controls',complete:false,pass:false,
  inputs:[pin(oldFile),pin(newFile),pin(import.meta.filename),pin(process.execPath)],rows:[],
  scope:'Complete exported API products and retained input; small historical differential plus bounded large-candidate correctness. Not full-language conformance, generated-C execution or a performance comparison.'};
const save=()=>fs.writeFileSync(out,JSON.stringify(report,null,2)+'\n');
const nil=()=>({$:'Nil'});
const list=xs=>{let tail=nil();for(let i=xs.length-1;i>=0;i--)tail={$:'Con',head:xs[i],tail};return tail;};
const array=xs=>{const out=[];for(;xs.$==='Con';xs=xs.tail){assert(out.length<=65536);out.push(xs.head);}assert.equal(xs.$,'Nil');return out;};
const term=(tag='Absent',name='',id=0)=>({$:'KTerm',tag,name,id,quant:0,kids:nil(),removed:nil(),originBegin:0,originEnd:0});
const def=(name,kind,arity,typ=term(),value=term())=>({$:'KDef',name,kind,arity,templates:0,typ,value,ctors:nil(),native:false,unsafe:false});
const param=(name,i)=>({$:'N_Param',name,kind:{$:['N_W32','N_W64','N_Box'][i%3]}});
const templates=[
  {name:'$direct.wrap',arity:2},
  {name:'plain:zero',arity:0},
  {name:'$direct.single',arity:1},
  {name:'$direct.bang',arity:1,bang:true},
  {name:'$direct.frame',arity:1,framed:true},
  {name:'$direct.toomany',arity:5},
  {name:'$direct.four',arity:4},
  {name:'$direct.notready',arity:1},
  {name:'$direct.scalar',arity:1},
  {name:'$direct.badarity',arity:1},
  {name:'$direct.mismatch',arity:1},
  {name:'$direct.product',arity:1},
  {name:'$direct.wrongkind',arity:1},
  {name:'raw:λ🙂',arity:1},
];
const sentinel='/*PHASE90_ORIGINAL_BODY*/\n';
function segment(i,body=`/* original ${i}: λ🙂 */\nreturn 17;\n`){
  const t=templates[i%templates.length];
  return {$:'N_Segment',name:t.name,params:list(Array.from({length:t.arity},(_,j)=>param('p'+j,j))),
    result:i%3,frame:t.framed?{$:'N_Frame',pop:3,slots:list(['2','1'])}:{$:'N_Direct'},body,
    refs:list(['ref:'+i,'shared']),host:i%2===0,spin:i%3===1,fork:i%5===2,bang:!!t.bang};
}
const flatDefs=[def('$direct.wrap','NFWorker',2,term(),term('NFName','wrap')),
  def('$direct.product','NFWorker',1,term('NQShape','$ctor.Pair',2),term('NFName','product')),
  def('$direct.badarity','NFWorker',2,term(),term('NFName','badarity')),
  def('$direct.wrongkind','Ordinary',1,term(),term('NFName','wrongkind'))];
const observerDefs=[...['wrap','single','frame','notready'].map(name=>def('$direct.'+name,'NOObserverEntry',name==='wrap'?2:1,term(),term('NOOwner',name))),
  def('$direct.badarity','NOObserverEntry',2,term(),term('NOOwner','badarity')),
  def('$direct.mismatch','NOObserverEntry',1,term(),term('NOOwner','another-owner')),
  def('$direct.scalar','NOScalarObserver',1,term(),term('NOOwner','scalar'))];
const readyNames=['wrap','single','frame','badarity','another-owner','scalar'].map(x=>'$observer.adapter.'+x);
const eligible=s=>s.frame.$==='N_Direct'&&!s.bang&&array(s.params).length>=1&&array(s.params).length<=4;
const expectedEntry=s=>def(s.name,'NOEligibleEntry',array(s.params).length);
const preserved=(after,before,body=before.body)=>assert.deepEqual(after,{...before,body});
function row(name,body){
  const r={name,pass:false};report.rows.push(r);save();const start=performance.now();
  const details=body();Object.assign(r,details,{pass:true,seconds:(performance.now()-start)/1000});save();
  process.stdout.write(JSON.stringify({kind:'P90_SEGMENT_CONTROL',...r})+'\n');
}
save();
try{
  const oldApi=(await import(pathToFileURL(oldFile))).default,newApi=(await import(pathToFileURL(newFile))).default;
  for(const api of [oldApi,newApi])for(const name of ['book_cached','nf_wrap_segments','no_entry_defs','no_wrap_routes','no_wrap_registered'])assert.equal(typeof api[name],'function',name);
  const contexts=api=>({flat:api.book_cached(list(flatDefs),0),observer:api.book_cached(list(observerDefs),0),entries:list(observerDefs),ready:list(readyNames)});
  const oldCtx=contexts(oldApi),newCtx=contexts(newApi);
  assert.deepEqual(newCtx,oldCtx);
  const contextsBefore=JSON.stringify(newCtx),oldContextsBefore=JSON.stringify(oldCtx);
  const apply=(api,ctx,mode,input)=>mode==='entries'?api.no_entry_defs(input):mode==='flat'?api.nf_wrap_segments(input,ctx.flat):
    mode==='observer'?api.no_wrap_routes(input,ctx.entries,ctx.ready):mode==='registered'?api.no_wrap_registered(input,ctx.observer,ctx.ready):
    mode==='empty-routes'?api.no_wrap_routes(input,nil(),ctx.ready):
    api.no_wrap_routes(api.nf_wrap_segments(input,ctx.flat),ctx.entries,ctx.ready);
  // This small old-image golden exercises successful wrappers, not just empty indexes.
  const goldInput=templates.map((_,i)=>segment(i,sentinel)),gold={};
  for(const mode of ['flat','observer','composed'])gold[mode]=array(apply(oldApi,oldCtx,mode,list(goldInput)));
  assert(gold.flat[0].body.startsWith('#if !DEVICE\n'));
  assert(gold.flat[11].body.includes('Term nq_result[2]'));
  assert(gold.observer[0].body.includes('NATIVE_READONLY_OBSERVERS'));
  assert(gold.observer[2].body.includes('NATIVE_READONLY_OBSERVERS'));
  for(const i of [4,7,8,9,10])assert.equal(gold.observer[i].body,sentinel,'Observer refusal '+i);
  for(const i of [9,12])assert.equal(gold.flat[i].body,sentinel,'Flat refusal '+i);
  const expectedBody=(mode,i,body)=>{
    const parts=gold[mode][i%templates.length].body.split(sentinel);
    assert.equal(parts.length,2,'Original body must survive exactly once');return parts[0]+body+parts[1];
  };
  for(const count of [0,1,templates.length,67])for(const mode of ['entries','flat','observer','registered','empty-routes','composed'])row('small-'+mode+'-'+count,()=>{
    const original=Array.from({length:count},(_,i)=>segment(i)),input=list(original),before=JSON.stringify(original);
    const expected=array(apply(oldApi,oldCtx,mode,input));
    const actual=array(apply(newApi,newCtx,mode,input));assert.deepEqual(actual,expected);
    if(mode==='entries')assert.deepEqual(actual,original.filter(eligible).map(expectedEntry));
    else for(let i=0;i<count;i++)preserved(actual[i],original[i],mode==='empty-routes'?original[i].body:expectedBody(mode==='registered'?'observer':mode,i,original[i].body));
    assert.equal(JSON.stringify(array(input)),before);assert.equal(JSON.stringify(original),before);
    assert.equal(JSON.stringify(oldCtx),oldContextsBefore);assert.equal(JSON.stringify(newCtx),contextsBefore);
    return {count,outputCount:actual.length,fullProductEquality:true,retainedInputs:true};
  });
  // Separate calls do not retain previous 65k outputs in the report. Large trees
  // are compared iteratively; JSON.stringify/deepEqual never walks the long spine.
  for(const mode of ['entries','flat','observer','composed'])row('large-'+mode+'-65536',()=>{
    const count=65536,original=Array.from({length:count},(_,i)=>segment(i)),input=list(original);
    const actual=array(apply(newApi,newCtx,mode,input));let outputIndex=0,wrapped=0;
    for(let i=0;i<count;i++){
      if(mode==='entries'){if(eligible(original[i]))assert.deepEqual(actual[outputIndex++],expectedEntry(original[i]));}
      else {const body=expectedBody(mode,i,original[i].body);preserved(actual[outputIndex++],original[i],body);if(body!==original[i].body)wrapped++;}
      assert.deepEqual(original[i],segment(i));
    }
    assert.equal(actual.length,outputIndex);
    const retained=array(input);assert.equal(retained.length,count);for(let i=0;i<count;i++)assert.deepEqual(retained[i],segment(i));
    assert.equal(JSON.stringify(newCtx),contextsBefore);
    if(mode!=='entries')assert(wrapped>0,'Large positive path must activate');
    return {count,outputCount:actual.length,wrapped,fullProductOracle:true,retainedInputs:true};
  });
  for(const p of report.inputs)assert.deepEqual(pin(p.file),p);
  report.complete=true;report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
report.maxRssKiB=process.resourceUsage().maxRSS;save();
console.log(JSON.stringify({complete:report.complete,pass:report.pass,checks:report.rows.length,error:report.error}));
