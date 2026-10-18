// Transport checked erased facts through Bend-written owned lowering and Nx.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {pathToFileURL} from 'node:url';
const [apiArg,captureArg,outArg,variant='reverse',policy='raw']=process.argv.slice(2),apiFile=path.resolve(apiArg),capture=path.resolve(captureArg),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const pin=file=>({file:path.resolve(file),bytes:fs.statSync(file).size,sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const verify=p=>{if(JSON.stringify(pin(p.file))!==JSON.stringify(p))throw Error('changed '+p.file);};
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'}),array=x=>{const xs=[];while(x.$==='Con'){xs.push(x.head);x=x.tail;}if(x.$!=='Nil')throw Error('bad list');return xs;};
const record=JSON.parse(fs.readFileSync(path.join(capture,'report.json')));if(!record.complete)throw Error('capture incomplete');for(const p of record.products)verify(p);
const api=(await import(pathToFileURL(apiFile))).default;
const control=api.nxlib_control_report();fs.writeFileSync(path.join(out,'nx-controls.txt'),control);if(control.includes('FAIL'))throw Error('Nx structural control failed');
const ownedControls=api.nxo_ownership_report();fs.writeFileSync(path.join(out,'ownership-controls.txt'),ownedControls);if(ownedControls.includes('FAIL'))throw Error('ownership mutation control failed');
const policyControls=api.nxo_policy_report();fs.writeFileSync(path.join(out,'policy-controls.txt'),policyControls);if(policyControls.includes('FAIL'))throw Error('policy control failed');
const facts=array(JSON.parse(fs.readFileSync(path.join(capture,'native-facts.json'))));
const ctors=list([['Nil',0,0],['Con',1,2],['SNil',2,0],['SCon',3,2]].map(([name,cid,arity])=>({$:'NxoCtor',name,cid,arity})));
const report={kind:'phase109-owned-library-emission',complete:false,inputs:[pin(apiFile),pin(import.meta.filename),pin(path.join(capture,'report.json')),...record.products],rows:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 const functions=[],symbols=[];let start=performance.now();
 const entries=variant==='reverse'?[['nt_reverse','list_reverse'],['String.reverse.go','string_reverse']]:['discard','duplicate'].includes(variant)?[['p109_list_'+variant,'list_reverse'],['p109_string_'+variant,'string_reverse']]:null;
 if(!entries)throw Error('unknown variant '+variant);
 report.variant=variant;report.policy=policy;
 for(const [name,symbol] of entries){
  const fact=facts.find(d=>d.name===name);if(!fact)throw Error('missing actual source '+name);
  const t=performance.now(),result=api.nxo_lower_policy(fact,ctors,symbol,policy);if(result.error)throw Error(name+': '+result.error);
  functions.push(result.function);symbols.push(symbol);report.rows.push({name,symbol,lowerSeconds:(performance.now()-t)/1000});
  fs.writeFileSync(path.join(out,symbol+'.owned.json'),JSON.stringify(result.ownership,null,2)+'\n');
  fs.writeFileSync(path.join(out,symbol+'.nx.json'),api.nx_json_function(result.function)+'\n');
 }
 const library={$:'NxLibrary',imports:api.nxlib_runtime_imports_policy(policy),functions:list(functions),exports:list(symbols)};
 if(!api.nxlib_verify(library))throw Error('library refused');
 fs.writeFileSync(path.join(out,'library.json'),JSON.stringify(library,null,2)+'\n');
 for(const [format,fn] of [['ssa','nxlib_qbe'],['c','nxlib_c']])fs.writeFileSync(path.join(out,'program.'+format),api[fn](library));
 report.seconds=(performance.now()-start)/1000;report.complete=true;report.outputs=['library.json','program.ssa','program.c','list_reverse.owned.json','string_reverse.owned.json'].map(n=>pin(path.join(out,n)));
 for(const p of report.inputs)verify(p);save();console.log(JSON.stringify({complete:true,seconds:report.seconds,functions:report.rows}));
}catch(e){report.error=String(e);save();throw e;}
