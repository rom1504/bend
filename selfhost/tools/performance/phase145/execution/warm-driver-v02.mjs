// Deliberate engine-warm diagnostic: API module/JIT survives, Bend requests do not.
import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
const config=JSON.parse(fs.readFileSync(process.argv[2],'utf8'));
const rows=[];
for(let i=0;i<4;i++){
 process.argv[2]=config.iterations[i];
 const start=performance.now(),cpu=process.cpuUsage();
 await import(pathToFileURL(config.observers[i]).href);
 const used=process.cpuUsage(cpu);
 rows.push({iteration:i,warmup:i===0,seconds:(performance.now()-start)/1000,userSeconds:used.user/1e6,systemSeconds:used.system/1e6});
 if(process.exitCode)break;
}
fs.writeFileSync(config.output,JSON.stringify({kind:'phase145-engine-warm-observation',complete:rows.length===4&&!process.exitCode,rows,scope:'One warmup plus three observations; exact API module and engine/JIT retained, but fresh Base decoding, source reads, checking, optimization and complete output each iteration. Natural GC; no semantic request cache. Not a cold-process speed comparison.'},null,2)+'\n');
