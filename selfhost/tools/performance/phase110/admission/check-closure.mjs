// Authenticated real checked source transport. Bend discovers/certifies closure.
// The host supplies requested roots, compares independent expectations and emits.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
const script=fileURLToPath(import.meta.url),root=path.resolve(path.dirname(script),'../../../../..');
const [apiArg,captureArg,outArg,policy='runtime-ir-single']=process.argv.slice(2);
if(!apiArg||!captureArg||!outArg)throw Error('usage: check-closure.mjs API CHECKED_CAPTURE FRESH_OUT POLICY');
const pin=file=>{const bytes=fs.readFileSync(file);return {file:path.resolve(file),bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};};
const verify=row=>{const found=pin(path.resolve(root,row.file));if(found.bytes!==row.bytes||found.sha256!==row.sha256)throw Error('changed '+row.file);return found;};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const list=items=>items.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=value=>{const items=[];while(value?.$==='Con'){items.push(value.head);value=value.tail;}if(value?.$!=='Nil')throw Error('bad Bend list');return items;};
const clone=value=>JSON.parse(JSON.stringify(value));
const same=(a,b)=>JSON.stringify(a)===JSON.stringify(b);
const setSame=(a,b)=>same([...a].sort(),[...b].sort());
const role=value=>({NxeString:'String',NxeListString:'List<String>',NxeUnknown:'unknown'}[value?.$]??'invalid');
const rootDecl=test=>({$:'NxeRoot',source:test.name,symbol:test.symbol});
const apiFile=path.resolve(apiArg),captureFile=path.resolve(captureArg,'report.json'),out=path.resolve(outArg);
if(!out.startsWith(path.join(root,'selfhost/build/phase110')+path.sep))throw Error('fresh Phase110 output required');
const manifestFile=path.join(root,'selfhost/tools/performance/phase110/controls/admission/closure-manifest.json');
const manifest=read(manifestFile),oracleFile=path.resolve(root,manifest.oracle.file),oracle=read(oracleFile),captured=read(captureFile);
const source=verify(manifest.source);verify(manifest.oracle);verify(manifest.baseSource);
const trustedBase=pin(path.join(root,'selfhost/dist/base.bend'));
if(trustedBase.sha256!==manifest.baseSource.sha256||trustedBase.bytes!==manifest.baseSource.bytes)throw Error('driver Base differs');
if(!captured.complete||captured.result?.checked!==true||captured.result?.typeAccepted!==true||captured.result?.exitCode!==0)throw Error('incomplete checked capture');
for(const row of [...captured.inputs,...captured.products,...captured.sourceFiles])verify(row);
if(!captured.sourceFiles.some(row=>path.resolve(row.file)===source.file&&row.sha256===source.sha256)||
 !captured.sourceFiles.some(row=>path.resolve(row.file)===trustedBase.file&&row.sha256===trustedBase.sha256)||
 !captured.inputs.some(row=>path.resolve(row.file)===trustedBase.file&&row.sha256===trustedBase.sha256))throw Error('capture source/Base binding differs');
const typedFile=path.resolve(captureArg,'checked-graph.json'),erasedFile=path.resolve(captureArg,'native-facts.json');
for(const file of [typedFile,erasedFile])if(!captured.products.some(row=>path.resolve(row.file)===file))throw Error('unauthenticated capture product');
const typed=read(typedFile),erased=read(erasedFile),definitions=array(typed),facts=array(erased);
const exact=(items,name)=>{const found=items.filter(row=>row.name===name);if(found.length!==1)throw Error('expected one definition '+name);return found[0];};
const privateIR=['runtime-ir-single','runtime-ir-atomic'].includes(policy),paired=['pair','pair-take'].includes(policy);
if(!privateIR&&!paired&&!['raw','trusted','fused','tagged','specialized'].includes(policy))throw Error('invalid policy');
const api=(await import(pathToFileURL(apiFile))).default;
for(const name of ['nxe_entry','nxe_close',privateIR?'nxe_lower_runtime_library':'nxe_lower_library'])if(typeof api[name]!=='function')throw Error('API missing '+name);
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase110-checked-closed-entry-probes',complete:false,policy,trustedBase,
 inputs:[pin(script),pin(apiFile),pin(manifestFile),pin(oracleFile),pin(captureFile),source,trustedBase,...captured.inputs,...captured.products,...captured.sourceFiles],
 rows:[],mutations:[],limits:['Source-role and complete callee closure admission plus emitted workers; this script does not execute native workers.',
 'Raw API books/certificates are not provenance. This transport authenticates one actual checked capture.',
 'Corruption controls are explicitly mutated data, not checked source cases.']};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 for(const test of oracle.roots){
  const entry=api.nxe_entry(typed,erased,test.name),entryAccepted=entry.certificate?.$==='Some'&&!entry.error;
  if(entryAccepted!==test.entryCertificateAccepted)throw Error('entry mismatch '+test.name);
  if(entryAccepted&&!same(array(entry.certificate.value.params).map(role),test.parameterRoles))throw Error('entry role mismatch');
  if(entryAccepted&&role(entry.certificate.value.result)!==test.resultRole)throw Error('entry result mismatch');
  const closure=api.nxe_close(typed,erased,list([rootDecl(test)])),accepted=!closure.error;
  report.rows.push({name:test.name,entryAccepted,accepted,error:closure.error});save();
  if(accepted!==test.closedLibraryAccepted)throw Error('closure mismatch '+test.name);
  if(accepted&&!setSame(array(closure.sources).map(item=>item.fact.name),test.requiredClosureNames))throw Error('closure names differ '+test.name);
  if(!accepted&&test.refusedDependency&&!closure.error.includes(test.refusedDependency))throw Error('wrong dependency refusal '+test.name);
 }
 const roots=oracle.roots.filter(test=>test.closedLibraryAccepted).map(rootDecl);
 const closure=api.nxe_close(typed,erased,list(roots));
 if(closure.error)throw Error(closure.error);
 const sources=array(closure.sources),certificates=array(closure.certificates),names=sources.map(item=>item.fact.name);
 if(!setSame(names,oracle.positiveCombinedClosureNames)||!same(array(closure.exports),oracle.positiveCombinedExports))throw Error('combined closure differs');
 if(oracle.outsideRequestedClosure.some(name=>names.includes(name)))throw Error('unrequested IO observer entered closure');
 if(new Set(sources.map(item=>item.symbol)).size!==sources.length)throw Error('symbol collision');
 for(const item of sources)if(!same(item.fact,exact(facts,item.fact.name)))throw Error('changed erased fact');
 if(certificates.length!==sources.length)throw Error('certificate count differs');
 for(const c of certificates)if(!same(c.source,exact(definitions,c.source.name))||!same(c.erased,exact(facts,c.erased.name)))throw Error('changed certificate source');
 fs.writeFileSync(path.join(out,'closure.json'),JSON.stringify(closure,null,2)+'\n');
 const chain=roots.find(item=>item.source==='p110_close_chain');
 const mutate=(name,change)=>{
  const ds=clone(definitions),es=clone(facts),rs=[clone(chain)];change(ds,es,rs);
  const result=api.nxe_close(list(ds),list(es),list(rs)),refused=!!result.error;
  report.mutations.push({name,refused,error:result.error});save();if(!refused)throw Error('mutation admitted '+name);
 };
 mutate('missing-private-fact',(ds,es)=>es.splice(es.findIndex(d=>d.name==='p110_close_mid'),1));
 mutate('duplicate-private-fact',(ds,es)=>es.push(clone(exact(es,'p110_close_leaf'))));
 mutate('duplicate-private-typed-definition',(ds,es)=>ds.push(clone(exact(ds,'p110_close_leaf'))));
 mutate('duplicate-export-symbol',(ds,es,rs)=>rs.push({...roots[1],symbol:rs[0].symbol}));
 mutate('duplicate-root-identity',(ds,es,rs)=>rs.push({...rs[0],symbol:'another'}));
 mutate('generated-private-symbol-collision',(ds,es,rs)=>{rs[0].symbol='nxe_private_'+[...'p110_close_leaf'].map(c=>c.codePointAt(0)+'_').join('');});
 mutate('runtime-symbol-collision',(ds,es,rs)=>{rs[0].symbol='rt_fast_keep';});
 mutate('root-budget',(ds,es,rs)=>{for(let i=0;i<33;i++)rs.push({$:'NxeRoot',source:'extra_'+i,symbol:'extra_'+i});});
 mutate('body-node-budget',(ds,es)=>{const fact=exact(es,'p110_close_chain');fact.value.kids=list(Array.from({length:8200},()=>({$:'KTerm',tag:'Absent',name:'',id:0,quant:0,kids:{$:'Nil'},removed:{$:'Nil'},originBegin:0,originEnd:0})));});
 const start=performance.now();
 const result=privateIR?api.nxe_lower_runtime_library(typed,erased,list(roots),policy.slice('runtime-ir-'.length)):
  api.nxe_lower_library(typed,erased,list(roots),paired?'specialized':policy);
 if(result.error)throw Error(result.error);
 let library=result.library,prefix=privateIR?'nx110rt_':'nxlib_';
 const workers=privateIR?array(library.workers):array(library.functions);
 const ownership=privateIR?new Map(workers.map(w=>[w.name,w.ownership])):new Map(array(result.ownership).map(w=>[w.symbol,w.ops]));
 const functions=new Map(workers.map(w=>privateIR?[w.name,w.function]:[w.name,w]));
 for(const item of sources){
  fs.writeFileSync(path.join(out,item.symbol+'.owned.json'),JSON.stringify(ownership.get(item.symbol),null,2)+'\n');
  fs.writeFileSync(path.join(out,item.symbol+'.nx.json'),api.nx_json_function(functions.get(item.symbol))+'\n');
 }
 if(paired){library=policy==='pair-take'?api.nx110_take_pair_library(library):api.nx110_pair_library(library);prefix='nx110_';}
 if(!api[prefix+'verify'](library))throw Error('emitted library failed verification');
 fs.writeFileSync(path.join(out,'library.json'),JSON.stringify(library,null,2)+'\n');
 fs.writeFileSync(path.join(out,'program.ssa'),api[prefix+'qbe'](library));
 fs.writeFileSync(path.join(out,'program.c'),api[prefix+'c'](library));
 report.exports=array(closure.exports);report.definitions=sources.map(({fact,symbol})=>({source:fact.name,symbol,arity:fact.arity}));
 report.lowerAndEmitSeconds=(performance.now()-start)/1000;
 for(const row of report.inputs)verify(row);
 report.outputs=fs.readdirSync(out).filter(name=>name!=='report.json').map(name=>pin(path.join(out,name)));
 report.complete=true;save();console.log(JSON.stringify({complete:true,roots:report.rows.length,dataMutations:report.mutations.length,definitions:sources.length,exports:report.exports.length}));
}catch(error){report.error=String(error);save();throw error;}
