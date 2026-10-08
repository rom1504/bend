// Diagnostic only: the root controller supplies the sole process/time guard.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
const [configFile,indexText,out] = process.argv.slice(2);
const config=JSON.parse(fs.readFileSync(configFile,'utf8')),item=config.cases[Number(indexText)];
fs.mkdirSync(out,{recursive:true});
const hash=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
for(const row of config.inputs)assert.equal(hash(row.file),row.sha256,row.file);
process.env.BEND_TYPED_API=config.api.file;
process.env.BEND_BASE=config.base.file;
process.env.BEND_TYPED_RUNTIME=config.runtime.file;
process.env.BEND_TYPED_TRACE='1';
process.env.BEND_PHASE66_API_TRACE=path.join(out,'api.jsonl');
const event=(name,extra={})=>fs.appendFileSync(path.join(out,'progress.jsonl'),JSON.stringify({name,ms:performance.now(),...extra})+'\n');
const started=performance.now();event('driver-import-start');
const D=await import(pathToFileURL(config.driver.file));event('driver-import-end');
event('compile-start');const begin=performance.now();
const result=await D.inspect(item.source.file,{mode:'compile',backend:'direct'});
const {code,...observation}=result;
event('compile-end',{msInPhase:performance.now()-begin,status:result.status});
const report={kind:'phase66-shared-layout-diagnostic-worker',complete:true,diagnosticOnly:true,productionQualified:false,
  source:item.source,observation,compileMs:performance.now()-begin,codeEmitted:typeof code==='string',pass:false};
if(code!==undefined){
  const file=path.join(out,'program.mjs');fs.writeFileSync(file,code);report.output={file,sha256:hash(file),bytes:Buffer.byteLength(code)};
  event('runtime-start');const runBegin=performance.now();
  const child=spawnSync(process.execPath,['--stack-size=4096','--max-old-space-size=1024',file],{
    encoding:'utf8',timeout:Math.max(1,Math.min(10000,58000-(performance.now()-started))),maxBuffer:2**20});
  report.execution={status:child.status,signal:child.signal,error:child.error?.message,stdout:child.stdout,stderr:child.stderr,ms:performance.now()-runBegin};
  report.pass=result.status==='ok'&&result.checked===true&&child.status===0&&child.stdout.trimEnd()===item.expected;
  event('runtime-end',{msInPhase:report.execution.ms,pass:report.pass});
}
for(const row of config.inputs)assert.equal(hash(row.file),row.sha256,row.file);
report.inputsUnchanged=true;report.wallMs=performance.now()-started;
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
process.exitCode=report.pass?0:1;
