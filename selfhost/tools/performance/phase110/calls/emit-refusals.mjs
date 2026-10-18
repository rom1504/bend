// Negative source probes use actual reachable checked facts, never fabricated KDefs.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
const script=fileURLToPath(import.meta.url),root=path.resolve(path.dirname(script),'../../../../..');
const [apiArg,preparedArg,captureArg,outArg,policy='specialized']=process.argv.slice(2);
if(!apiArg||!preparedArg||!captureArg||!outArg)throw Error('usage: emit-refusals.mjs API PREPARED_SOURCE CAPTURE FRESH_OUT POLICY');
const pin=file=>{const data=fs.readFileSync(file);return {file:path.resolve(file),bytes:data.length,sha256:crypto.createHash('sha256').update(data).digest('hex')};};
const verify=row=>{const found=pin(path.resolve(root,row.file));if(found.bytes!==row.bytes||found.sha256!==row.sha256)throw Error('changed '+row.file);return found;};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const array=value=>{const out=[];while(value?.$==='Con'){out.push(value.head);value=value.tail;}if(value?.$!=='Nil')throw Error('bad Bend list');return out;};
const list=items=>items.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const apiFile=path.resolve(apiArg),preparedFile=path.resolve(preparedArg,'manifest.json'),captureFile=path.resolve(captureArg,'report.json'),out=path.resolve(outArg);
if(!out.startsWith(path.join(root,'selfhost/build/phase110')+path.sep))throw Error('fresh Phase110 output required');
const prepared=read(preparedFile),captured=read(captureFile);
if(prepared.kind!=='phase110-reachable-call-refusal-source'||!prepared.complete||!prepared.exactPreservedDeclarations)throw Error('invalid prepared refusal source');
const source=verify(prepared.source);
if(captured.kind!=='phase109-checked-native-facts'||!captured.complete||captured.result?.checked!==true||captured.result?.exitCode!==0)throw Error('incomplete checked capture');
for(const row of [...prepared.inputs,...captured.inputs,...captured.products,...captured.sourceFiles])verify(row);
if(!captured.sourceFiles.some(row=>path.resolve(row.file)===source.file&&row.sha256===source.sha256))throw Error('capture differs from reachable negative source');
const factsFile=path.resolve(captureArg,'native-facts.json');
if(!captured.products.some(row=>path.resolve(row.file)===factsFile))throw Error('facts are not capture product');
const facts=array(read(factsFile)),api=(await import(pathToFileURL(apiFile))).default;
const privateIR=['runtime-ir-single','runtime-ir-atomic'].includes(policy);
if(!privateIR&&!['raw','trusted','fused','tagged','specialized'].includes(policy))throw Error('unsupported refusal lowering policy');
const ctors=list([['Nil',0,0],['Con',1,2],['SNil',2,0],['SCon',3,2]].map(([name,cid,arity])=>({$:'NxoCtor',name,cid,arity})));
const exact=name=>{const rows=facts.filter(fact=>fact.name===name&&fact.kind==='NativeErasedBody');if(rows.length!==1)throw Error('missing exact reachable checked fact '+name);return rows[0];};
const dependencies=[['nt_reverse','shape_reverse'],['nt_append','shape_append'],['p110_call_identity','call_identity']].map(([name,symbol])=>({$:'NxcSource',fact:exact(name),symbol}));
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase110-actual-checked-call-refusals',complete:false,policy,inputs:[pin(script),pin(apiFile),pin(preparedFile),pin(captureFile),source,...prepared.inputs,...captured.inputs,...captured.products,...captured.sourceFiles],rows:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
  for(const name of prepared.entries){
    const fact=exact(name),symbol='refusal_'+name,sources=[...dependencies,{$:'NxcSource',fact,symbol}];
    fs.writeFileSync(path.join(out,name+'.fact.json'),JSON.stringify(fact,null,2)+'\n');
    const result=privateIR?api.nx110rt_lower_library(list(sources),ctors,list([symbol]),policy.slice('runtime-ir-'.length)):api.nxc_lower_library(list(sources),ctors,list([symbol]),policy);
    report.rows.push({name,liveArity:fact.arity,error:result.error,refused:!!result.error});save();
    if(!result.error)throw Error('unsupported source admitted '+name);
  }
  for(const row of report.inputs)verify(row);
  report.complete=true;report.outputs=prepared.entries.map(name=>pin(path.join(out,name+'.fact.json')));save();console.log(JSON.stringify({complete:true,policy,refusals:report.rows.length}));
}catch(error){report.error=String(error);save();throw error;}
