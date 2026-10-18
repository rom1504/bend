// Host transport only: actual parsing/checking/annotation execute the Bend API.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {inspect,apiPath,basePath,driverPath} from '../../../typed-driver.mjs';
const [sourceArg,outArg]=process.argv.slice(2);
const source=path.resolve(sourceArg),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const pin=file=>({file,bytes:fs.statSync(file).size,sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const start=performance.now();
const captured=await inspect(source,{mode:'native',captureCheckedGraph:true});
const {checkedGraph:selected,...result}=captured;
const seconds=(performance.now()-start)/1000;
const report={kind:'phase107-checked-source-capture',complete:false,inputs:[pin(source),pin(apiPath),pin(basePath),pin(import.meta.filename),pin(driverPath)],frontendSeconds:seconds,result};
if(result.status==='ok'&&result.checked&&result.exitCode===0&&selected){
 fs.writeFileSync(path.join(out,'selected.json'),JSON.stringify(selected,null,2)+'\n');
 report.complete=true;report.files=(result.files||[]).filter(fs.existsSync).map(pin);
 report.products=['selected.json'].map(f=>pin(path.join(out,f)));
}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,seconds,result:report.complete?'captured':result}));
if(!report.complete)process.exitCode=1;
