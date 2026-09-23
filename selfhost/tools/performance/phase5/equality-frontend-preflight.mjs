// Metadata-only check of the copied harness's actual discovery policy. No API
// is loaded and no compiler probe executes.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
import {identity,verifyIdentity} from '../../development/workflow.mjs';
const [snapshotArg,out]=process.argv.slice(2);if(!out||fs.existsSync(out))throw Error('Usage: equality-frontend-preflight.mjs SNAPSHOT NEW_REPORT');
const snapshotFile=fs.realpathSync(path.join(snapshotArg,'snapshot.json')),s=JSON.parse(fs.readFileSync(snapshotFile));s.inputs.forEach(verifyIdentity);
const report={kind:'phase5-equality-frontend-metadata-preflight',complete:false,compilerExecuted:false,inputs:[identity(snapshotFile),identity(import.meta.filename),s.historical]};
try{
 for(const key of Object.keys(process.env))if(key.startsWith('BEND_')||key==='NODE_OPTIONS')delete process.env[key];
 Object.assign(process.env,{BEND_UPSTREAM:s.upstream,BEND_BASE:s.base.file,BEND_TYPED_API:s.checked.file,BEND_TYPED_RUNTIME:s.runtime.file,BEND_TYPED_TRACE:''});
 const inv=await import(pathToFileURL(path.join(s.project,'tools/conformance/inventory.mjs'))),adapter=await import(pathToFileURL(path.join(s.project,'tools/conformance/adapters/typed.mjs')));
 const manifest=inv.inventory(s.upstream),expected=JSON.parse(fs.readFileSync(s.historical.file));
 const files=new Set([...manifest.tests.map(t=>t.file),...inv.walk(path.join(s.upstream,'tests')),...inv.walk(path.join(s.upstream,'bend2/effs')),...manifest.sources.map(source=>path.join(s.upstream,source.file))]);
 for(const file of typeof adapter.inputFiles==='function'?await adapter.inputFiles({tests:manifest.tests}):adapter.inputFiles||[])files.add(path.resolve(file));
 const hashes=Object.fromEntries([...files].map(file=>[file,fs.existsSync(file)?inv.sha256(fs.readFileSync(file)):null])),paths=Object.fromEntries([...files].map(file=>[file,fs.existsSync(file)?fs.realpathSync(file):null]));
 assert.deepEqual(hashes,expected.inputHashes);assert.deepEqual(paths,expected.inputPaths);assert.equal(manifest.total,1378);
 const fixtureRows=m=>m.tests.map(t=>[t.id,t.sha256]).sort((a,b)=>a[0].localeCompare(b[0]));assert.deepEqual(fixtureRows(manifest),fixtureRows(expected.inventory));
 report.artifacts=Object.entries(adapter.artifacts).map(([name,file])=>{const current=identity(file),old=expected.identity.artifacts[name];assert.ok(old);assert.equal(current.sha256,old.sha256,name);return {name,current,previous:old};});
 for(const name of ['run','worker','inventory','judge','selection','run-probe','replay','persistent-probe','persistent-worker']){const current=identity(path.join(s.project,'tools/conformance',name+'.mjs'));assert.equal(current.sha256,expected.identity.artifacts['harness/'+name+'.mjs'].sha256);}
 s.inputs.forEach(verifyIdentity);report.inputPaths=paths;report.inputHashes=hashes;report.inputCount=files.size;report.fixtureCount=manifest.total;report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(out,JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,inputCount:report.inputCount,compilerExecuted:false,error:report.error}));
