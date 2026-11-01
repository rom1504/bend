#!/usr/bin/env node
// Root-supervised control: actual driver requests, with every synchronous cache
// filesystem entry guarded. A blocked read is a failure even if the driver catches it.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify,requireThat,workspace,driverInputs} from '../../../tools/build/hosted.mjs';
const args={};for(let i=2;i<process.argv.length;i+=2){requireThat(process.argv[i].startsWith('--')&&process.argv[i+1],'Expected --option value');args[process.argv[i].slice(2)]=process.argv[i+1];}
for(const key of ['image','base','source','expected','out'])requireThat(args[key],'Missing --'+key);
const inputs=[pin(import.meta.filename),pin(process.execPath),...driverInputs(),...['image','base','source','expected'].map(k=>pin(args[k]))];
const out=path.resolve(args.out);requireThat(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh build output required');fs.mkdirSync(out,{recursive:true});
const caches=['cache','base-products'].map(name=>path.join(workspace,'selfhost/build/typed',name)),blocked=[],saved={};
const report={kind:'bend-live-base-cache-control',version:1,complete:false,inputs,blocked,rows:[],scope:'Two live compilation requests and a non-Boolean-option rejection. No filesystem access to the shared Base cache is permitted; complete emitted bytes must match the independent retained product.'};
for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
process.env.BEND_TYPED_API=fs.realpathSync(args.image);process.env.BEND_BASE=fs.realpathSync(args.base);
const isCache=value=>{if(value instanceof URL)value=fileURLToPath(value);if(Buffer.isBuffer(value))value=value.toString();if(typeof value!=='string')return false;const file=path.resolve(value);return caches.some(cache=>file===cache||file.startsWith(cache+'/'));};
try{
  for(const name of ['realpathSync','existsSync','readdirSync','readFileSync','openSync','statSync','lstatSync','accessSync','mkdirSync','writeFileSync','appendFileSync','renameSync','unlinkSync','rmSync']){
    saved[name]=fs[name];fs[name]=function(...xs){if(xs.some(isCache)){blocked.push({name,paths:xs.filter(x=>typeof x==='string')});throw Error('Forbidden shared Base cache access: '+name);}return Reflect.apply(saved[name],fs,xs);};
  }
  const driver=await import(pathToFileURL(path.join(workspace,'selfhost/tools/typed-driver.mjs')));
  for(let i=0;i<2;i++){
    const got=await driver.inspect(args.source,{mode:args.mode??'compile',backend:args.backend??'direct',useBaseCache:false});
    requireThat(got.status==='ok'&&got.checked&&typeof got.code==='string',got.diagnostic??'Live compilation failed');
    requireThat(Buffer.from(got.code).equals(fs.readFileSync(args.expected)),'Live product differs from retained complete oracle');
    fs.writeFileSync(path.join(out,'product-'+i),got.code,{flag:'wx'});report.rows.push({index:i,product:pin(path.join(out,'product-'+i)),exact:true});
  }
  const negative=await driver.inspect(args.source,{mode:'compile',useBaseCache:'off'});
  report.invalidOption=negative;
  requireThat(negative.status==='error'&&negative.phase==='load'&&negative.diagnostic==='SOME PROOFS FAIL\nError: useBaseCache must be boolean','Invalid option did not refuse explicitly');
  requireThat(blocked.length===0,'A cache access was attempted');report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{for(const [name,fn] of Object.entries(saved))fs[name]=fn;}
for(const row of inputs)verify(row);
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,blocked:blocked.length,report:path.join(out,'report.json'),error:report.error}));
