// Root-run exact scoped driver capture; no source or fact transformation.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {pathToFileURL,fileURLToPath} from 'node:url';
const [preparedArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('usage: capture.mjs PREPARED_MANIFEST FRESH_OUT');
const preparedFile=path.resolve(preparedArg),prepared=JSON.parse(fs.readFileSync(preparedFile,'utf8')),out=path.resolve(outArg);
const pin=file=>{const bytes=fs.readFileSync(file);return{file:path.resolve(file),bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};};
const verify=row=>{const now=pin(row.file);if(now.bytes!==row.bytes||now.sha256!==row.sha256)throw Error('changed '+row.file);};
if(prepared.kind!=='phase110-checked-descriptor-capture-source'||!prepared.complete||prepared.roots.join('|')!=='main|List|String|Char')throw Error('exact descriptor capture preparation required');
if(fs.existsSync(out)||path.dirname(out)!==path.dirname(path.dirname(preparedFile)))throw Error('fresh sibling Phase110 capture output required');
const inputs=[pin(preparedFile),...prepared.inputs,prepared.driver,prepared.method,prepared.diff,pin(fileURLToPath(import.meta.url)),pin(process.execPath)];for(const row of inputs)verify(row);
const {inspect,apiPath,basePath,driverPath}=await import(pathToFileURL(prepared.driver.file));
if(driverPath!==prepared.driver.file||!inputs.some(row=>row.file===apiPath)||!inputs.some(row=>row.file===basePath))throw Error('scoped driver selected unpinned compiler or Base');
fs.mkdirSync(out);const report={kind:'phase109-checked-native-facts',complete:false,inputs,descriptorCapture:{preparation:pin(preparedFile),roots:prepared.roots,source:prepared.source}};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();const start=performance.now();
try{
 const {nativeFacts,checkedGraph,...result}=await inspect(prepared.source.file,{mode:'native',captureCheckedGraph:true,captureNativeFacts:true});report.result=result;report.seconds=(performance.now()-start)/1000;
 if(result.status!=='ok'||!result.checked||!result.typeAccepted||result.exitCode!==0||nativeFacts?.$!=='Con')throw Error('actual checked source capture failed');
 for(const [name,value] of [['native-facts',nativeFacts],['checked-graph',checkedGraph]])fs.writeFileSync(path.join(out,name+'.json'),JSON.stringify(value,null,2)+'\n');
 report.products=['native-facts.json','checked-graph.json'].map(name=>pin(path.join(out,name)));report.sourceFiles=result.files.filter(fs.existsSync).map(pin);
 for(const row of inputs)verify(row);report.complete=true;save();console.log(JSON.stringify({complete:true,seconds:report.seconds,result}));
}catch(error){report.error=String(error);report.seconds=(performance.now()-start)/1000;save();throw error;}
