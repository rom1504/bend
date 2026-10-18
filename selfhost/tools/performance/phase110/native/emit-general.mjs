// Expected emission from exact unchanged captured facts, with all algorithms in Bend.
// Root builds API from prepared native bridge, then runs this under its serial guard.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
const script=fileURLToPath(import.meta.url),root=path.resolve(path.dirname(script),'../../../../..');
const [apiArg,sourceArg,qualifiedArg,outArg,policy='runtime-ir-single']=process.argv.slice(2);
if(!outArg)throw Error('usage: emit-general.mjs API NATIVE_SOURCE CLOSED_QUALIFICATION FRESH_OUT POLICY');
const pin=file=>{const d=fs.readFileSync(file);return {file:path.resolve(file),bytes:d.length,sha256:crypto.createHash('sha256').update(d).digest('hex')};};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const verify=row=>{const a=pin(path.resolve(root,row.file));if(a.bytes!==row.bytes||a.sha256!==row.sha256)throw Error('changed '+row.file);return a;};
const list=items=>items.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const sourceFile=path.resolve(sourceArg,'manifest.json'),source=read(sourceFile),qualifiedFile=path.resolve(qualifiedArg),qualified=read(qualifiedFile),out=path.resolve(outArg),apiFile=path.resolve(apiArg);
if(!source.complete||!source.generalEntry||!qualified.complete||qualified.kind!=='phase110-checked-closed-entry-probes')throw Error('qualification/source missing');
if(!out.startsWith(path.join(root,'selfhost/build/phase110')+path.sep))throw Error('fresh output required');
for(const row of [...source.inputs,source.source,source.bridge,...qualified.inputs,...qualified.outputs])verify(row);
const one=name=>{const rows=qualified.inputs.filter(row=>path.basename(row.file)===name);const unique=[...new Set(rows.map(row=>row.file))];if(unique.length!==1)throw Error('one input required '+name);return unique[0];};
const typed=read(one('checked-graph.json')),erased=read(one('native-facts.json')),oracle=read(one('closure-oracle.json'));
const apiReportFile=path.join(path.dirname(apiFile),'report.json'),apiReport=read(apiReportFile);
const samePin=(a,b)=>path.resolve(a.file)===path.resolve(b.file)&&a.bytes===b.bytes&&a.sha256===b.sha256;
if(!apiReport.complete||apiReport.kind!=='phase110-checked-api'||!samePin(apiReport.api,pin(apiFile))||!samePin(apiReport.source,source.bridge))throw Error('API is not bound to exact native bridge');
verify(apiReport.source);
const api=(await import(pathToFileURL(apiFile))).default;
const privateIR=['runtime-ir-single','runtime-ir-atomic'].includes(policy),paired=['pair','pair-take'].includes(policy);
if(!privateIR&&!paired&&!['raw','trusted','fused','tagged','specialized'].includes(policy))throw Error('unknown policy');
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase110-native-general-expected',complete:false,policy,inputs:[pin(script),pin(apiFile),pin(apiReportFile),pin(sourceFile),source.bridge,pin(qualifiedFile),...qualified.inputs,...qualified.outputs],rows:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 for(const test of oracle.roots.filter(row=>row.closedLibraryAccepted)){
  const roots=list([{$:'NxeRoot',source:test.name,symbol:'entry'}]);
  const result=privateIR?api.nxe_lower_runtime_library(typed,erased,roots,policy.slice('runtime-ir-'.length)):
    api.nxe_lower_library(typed,erased,roots,paired?'specialized':policy);
  if(result.error)throw Error(result.error);
  let library=result.library,prefix=privateIR?'nx110rt_':'nxlib_';
  if(paired){library=policy==='pair-take'?api.nx110_take_pair_library(library):api.nx110_pair_library(library);prefix='nx110_';}
  if(!api[prefix+'verify'](library))throw Error('expected worker verification failed');
  const qbe=path.join(out,test.name+'.ssa'),c=path.join(out,test.name+'.c');
  fs.writeFileSync(qbe,api[prefix+'qbe'](library));fs.writeFileSync(c,api[prefix+'c'](library));
  report.rows.push({name:test.name,expectedQbe:pin(qbe),expectedC:pin(c)});save();
 }
 for(const row of report.inputs)verify(row);
 report.complete=true;save();console.log(JSON.stringify({complete:true,roots:report.rows.length,policy}));
}catch(error){report.error=String(error);save();throw error;}
