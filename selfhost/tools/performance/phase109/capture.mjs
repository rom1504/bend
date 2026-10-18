// Host transport of checked Bend-owned erasure; no source-language transformation.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import {inspect,apiPath,basePath,driverPath} from '../../typed-driver.mjs';
const [sourceArg,outArg]=process.argv.slice(2),source=path.resolve(sourceArg),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const pin=file=>({file:path.resolve(file),bytes:fs.statSync(file).size,sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const inputs=[source,apiPath,basePath,driverPath,import.meta.filename].map(pin),start=performance.now();
const {nativeFacts,checkedGraph,...result}=await inspect(source,{mode:'native',captureCheckedGraph:true,captureNativeFacts:true});
const report={kind:'phase109-checked-native-facts',complete:false,inputs,result,seconds:(performance.now()-start)/1000};
if(result.status==='ok'&&result.checked&&result.exitCode===0&&nativeFacts?.$==='Con'){
 for(const [name,value] of [['native-facts',nativeFacts],['checked-graph',checkedGraph]])fs.writeFileSync(path.join(out,name+'.json'),JSON.stringify(value,null,2)+'\n');
 report.products=['native-facts.json','checked-graph.json'].map(f=>pin(path.join(out,f)));
 report.sourceFiles=(result.files||[]).filter(fs.existsSync).map(pin);report.complete=true;
}
for(const p of inputs)if(JSON.stringify(pin(p.file))!==JSON.stringify(p))throw Error('input changed '+p.file);
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,seconds:report.seconds,result}));
if(!report.complete)process.exitCode=1;
