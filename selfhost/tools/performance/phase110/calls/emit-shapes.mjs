// Exact checked-fact transport for the frozen six-export call-shape contract.
// All ownership lowering, closure verification and machine emission are Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath, pathToFileURL} from 'node:url';

const script=fileURLToPath(import.meta.url), root=path.resolve(path.dirname(script),'../../../../..');
const [apiArg,captureArg,outArg,policy='specialized']=process.argv.slice(2);
if(!apiArg||!captureArg||!outArg)throw Error('usage: emit-shapes.mjs API CAPTURE FRESH_OUT POLICY');
const apiFile=path.resolve(apiArg), capture=path.resolve(captureArg), out=path.resolve(outArg);
if(!out.startsWith(path.join(root,'selfhost/build/phase110')+path.sep))throw Error('fresh Phase110 output required');
const pin=file=>{const data=fs.readFileSync(file);return {file:path.resolve(file),bytes:data.length,sha256:crypto.createHash('sha256').update(data).digest('hex')};};
const verify=record=>{const actual=pin(path.resolve(root,record.file));if(actual.bytes!==record.bytes||actual.sha256!==record.sha256)throw Error('changed input '+record.file);return actual;};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const list=items=>items.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=value=>{const items=[];while(value?.$==='Con'){items.push(value.head);value=value.tail;}if(value?.$!=='Nil')throw Error('invalid Bend list');return items;};
const contractFile=path.join(root,'selfhost/tools/performance/phase110/controls/call-shapes/manifest.json');
const contract=read(contractFile), catalogueFile=path.resolve(root,contract.catalogue.file), catalogue=read(catalogueFile);
const sourcePin=verify(contract.source), cataloguePin=verify(contract.catalogue);
if(contract.kind!=='phase110-frozen-call-shape-execution'||catalogue.kind!=='phase110-source-contract-entry-map')throw Error('wrong frozen contract');
if(verify(catalogue.source).sha256!==sourcePin.sha256)throw Error('catalogue source differs');
const captureFile=path.join(capture,'report.json'), captured=read(captureFile);
if(captured.kind!=='phase109-checked-native-facts'||!captured.complete||captured.result?.checked!==true||captured.result?.typeAccepted!==true||captured.result?.exitCode!==0)throw Error('capture is not complete checked source evidence');
for(const row of [...captured.inputs,...captured.products,...captured.sourceFiles])verify(row);
if(!captured.sourceFiles.some(row=>path.resolve(row.file)===sourcePin.file&&row.sha256===sourcePin.sha256&&row.bytes===sourcePin.bytes))throw Error('capture does not bind the exact frozen call-shape source');
const factsFile=path.join(capture,'native-facts.json');
if(!captured.products.some(row=>path.resolve(row.file)===factsFile))throw Error('capture does not authenticate facts file');
const facts=array(read(factsFile)), names=new Set(), symbols=new Set();
const selected=catalogue.entries.map(entry=>{
  if(names.has(entry.name)||symbols.has(entry.symbol))throw Error('duplicate entry mapping');
  names.add(entry.name);symbols.add(entry.symbol);
  const matches=facts.filter(fact=>fact.name===entry.name);
  if(matches.length!==1||matches[0].kind!=='NativeErasedBody'||matches[0].arity!==entry.liveArity)throw Error('checked fact/arity mismatch '+entry.name);
  if(entry.parameterRoles.length!==entry.liveArity||!entry.parameterRoles.every(role=>['String','List<String>'].includes(role))||entry.resultRole!=='List<String>')throw Error('unsupported frozen entry role');
  return {entry,fact:matches[0]};
});
for(const {entry} of selected)for(const name of entry.dependencies)if(!names.has(name))throw Error('unclosed frozen entry catalogue');
if(JSON.stringify(catalogue.exports)!==JSON.stringify(catalogue.entries.filter(entry=>entry.export).map(entry=>entry.symbol)))throw Error('export map differs');
const privateIR=['runtime-ir-single','runtime-ir-atomic'].includes(policy), paired=['pair','pair-take'].includes(policy);
if(!privateIR&&!paired&&!['raw','trusted','fused','tagged','specialized'].includes(policy))throw Error('unsupported policy');
const basePolicy=paired?'specialized':policy, view=privateIR?policy.slice('runtime-ir-'.length):null;
const api=(await import(pathToFileURL(apiFile))).default;
for(const name of [privateIR?'nx110rt_lower_library':'nxc_lower_library','nx_json_function'])if(typeof api[name]!=='function')throw Error('API export missing '+name);
const ctors=list([['Nil',0,0],['Con',1,2],['SNil',2,0],['SCon',3,2]].map(([name,cid,arity])=>({$:'NxoCtor',name,cid,arity})));
const sources=selected.map(({entry,fact})=>({$:'NxcSource',fact,symbol:entry.symbol}));
const lower=(items,exports)=>privateIR?api.nx110rt_lower_library(list(items),ctors,list(exports),view):api.nxc_lower_library(list(items),ctors,list(exports),basePolicy);
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase110-checked-call-shape-emission',complete:false,policy,sourceContract:sourcePin,
  inputs:[pin(script),pin(apiFile),pin(contractFile),cataloguePin,pin(captureFile),...captured.inputs,...captured.products,...captured.sourceFiles],
  exports:catalogue.exports,selected:selected.map(({entry})=>entry),refusals:[],
  separateRefusalCoverage:catalogue.negativeEntries.map(entry=>({...entry,status:'not executed by positive transport; requires separate reachable checked-source capture'})),rows:[],
  scope:'Eight exact checked definitions, six exports. Host selects and serializes facts only; Bend owns all lowering and emission.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
  fs.writeFileSync(path.join(out,'selected-facts.json'),JSON.stringify(list(sources),null,2)+'\n');
  const start=performance.now(), result=lower(sources,catalogue.exports);
  if(result.error)throw Error(result.error);
  let library=result.library, prefix=privateIR?'nx110rt_':'nxlib_';
  const workers=privateIR?array(library.workers):array(library.functions);
  const ownership=privateIR?new Map(workers.map(worker=>[worker.name,worker.ownership])):new Map(array(result.ownership).map(body=>[body.symbol,body.ops]));
  const functions=privateIR?new Map(workers.map(worker=>[worker.name,worker.function])):new Map(workers.map(fn=>[fn.name,fn]));
  for(const {entry} of selected){
    const ops=ownership.get(entry.symbol), fn=functions.get(entry.symbol);
    if(!ops||!fn)throw Error('lowerer omitted selected definition '+entry.name);
    fs.writeFileSync(path.join(out,entry.symbol+'.owned.json'),JSON.stringify(ops,null,2)+'\n');
    fs.writeFileSync(path.join(out,entry.symbol+'.nx.json'),api.nx_json_function(fn)+'\n');
    report.rows.push({name:entry.name,symbol:entry.symbol,liveArity:entry.liveArity,export:entry.export});
  }
  if(paired){
    if(!api.nxlib_verify(library))throw Error('underlying scalar library refused');
    library=policy==='pair-take'?api.nx110_take_pair_library(library):api.nx110_pair_library(library);prefix='nx110_';
  }
  if(!api[prefix+'verify'](library))throw Error('final library refused');
  fs.writeFileSync(path.join(out,'library.json'),JSON.stringify(library,null,2)+'\n');
  fs.writeFileSync(path.join(out,'program.ssa'),api[prefix+'qbe'](library));
  fs.writeFileSync(path.join(out,'program.c'),api[prefix+'c'](library));
  report.lowerAndEmitSeconds=(performance.now()-start)/1000;
  for(const row of report.inputs)verify(row);
  report.outputs=['selected-facts.json','library.json','program.ssa','program.c',...selected.flatMap(({entry})=>[entry.symbol+'.owned.json',entry.symbol+'.nx.json'])].map(name=>pin(path.join(out,name)));
  report.complete=true;save();
  console.log(JSON.stringify({complete:true,policy,definitions:report.rows.length,exports:report.exports.length,refusals:report.refusals.length,lowerAndEmitSeconds:report.lowerAndEmitSeconds}));
}catch(error){report.error=String(error);save();throw error;}
