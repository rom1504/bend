#!/usr/bin/env bun
// Experimental host shell. Bend owns checking, lowering, optimization and QBE IL.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {spawnSync} from 'node:child_process';import {pathToFileURL} from 'node:url';
import {inspect,apiPath as frontendApi,basePath,driverPath} from '../../typed-driver.mjs';
const root=path.resolve(import.meta.dirname,'../../../..');
const options={backend:'qbe',budget:4096,entry:'main',tail:true,fuse:true,units:true};
const argv=process.argv.slice(2);let source;
while(argv.length){const a=argv.shift();if(a==='--prune')options.prune=true;else if(a==='--no-tail')options.tail=false;else if(a==='--no-fuse')options.fuse=false;else if(a==='--whole-object')options.units=false;else if(a.startsWith('--')){if(!['--api','--out','--entry','--backend','--cache','--budget','--qbe','--abi-salt','--inline'].includes(a))throw Error('Unknown option '+a);if(!argv.length)throw Error('Missing '+a);options[a.slice(2)]=argv.shift();}else if(!source)source=path.resolve(a);else throw Error('Unexpected argument '+a);}
if(!source||!options.api||!options.out)throw Error('Usage: compile.mjs SOURCE --api API.mjs --out NEW_DIR [--entry main|bench] [--backend qbe|cranelift|clang|gcc] [--cache DIR] [--budget N] [--no-tail] [--no-fuse] [--whole-object] [--inline deep|entry] [--prune]');
options.budget=Number(options.budget);if(!Number.isSafeInteger(options.budget)||options.budget<0||options.budget>4096)throw Error('Budget must be 0..4096');
if(!['qbe','cranelift','clang','gcc'].includes(options.backend))throw Error('Unknown backend');
const out=path.resolve(options.out);fs.mkdirSync(out,{recursive:false});
const hash=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return {file,bytes:bytes.length,sha256:hash(bytes)};};
const qbe=path.resolve(options.qbe||path.join(root,'selfhost/build/phase107/toolchain/qbe-1.3/qbe'));
const cranelift=path.join(root,'selfhost/build/phase106/cargo-target/release/bend-native-ir-cranelift');
const clang='/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang';
const runner=path.join(root,'selfhost/tools/performance/phase106/cranelift/runner.c');
if(pin(basePath).sha256!=='99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf')throw Error('Experimental native primitive ABI requires the admitted Base digest');
fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={complete:false,started:new Date().toISOString(),options,source:pin(source),inputs:[pin(import.meta.filename),pin(options.api),pin(frontendApi),pin(basePath),pin(driverPath),pin(runner),pin('/usr/bin/gcc'),pin('/usr/bin/ld')],jobs:[],cache:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');const begin=performance.now();save();
const run=(label,cmd)=>{const start=performance.now(),r=spawnSync(cmd[0],cmd.slice(1),{encoding:'utf8',timeout:30000,maxBuffer:2**20});report.jobs.push({label,command:cmd,seconds:(performance.now()-start)/1000,status:r.status,signal:r.signal,stdout:r.stdout,stderr:r.stderr});save();if(r.error||r.status!==0)throw Error(label+': '+(r.error?.message||r.stderr));};
const cache=options.cache?path.resolve(options.cache):null;if(cache)fs.mkdirSync(cache,{recursive:true});
const toolpin=name=>pin('/usr/bin/'+name);
function objectUnit(name,text,identity,build){
 const key=hash(JSON.stringify({text,identity}));let object=path.join(out,hash(name)+'.o');
 if(cache){const dir=path.join(cache,key),meta=path.join(dir,'record.json');
  if(fs.existsSync(meta)){const r=JSON.parse(fs.readFileSync(meta));const candidate=path.join(dir,'object.o');
   if(r.key===key&&fs.existsSync(candidate)&&pin(candidate).sha256===r.sha256){report.cache.push({name,key,hit:true});return candidate;}
   report.cache.push({name,key,hit:false,corrupt:true});
  }else report.cache.push({name,key,hit:false});
  build(object,text);
  fs.mkdirSync(dir,{recursive:true});const temporary=path.join(dir,'object-'+process.pid+'.tmp');fs.copyFileSync(object,temporary);fs.renameSync(temporary,path.join(dir,'object.o'));
  const record={key,sha256:pin(object).sha256};const tmp=path.join(dir,'record-'+process.pid+'.tmp');fs.writeFileSync(tmp,JSON.stringify(record));fs.renameSync(tmp,meta);return object;
 }
 build(object,text);return object;
}
try{
 const loaded=performance.now(),api=(await import(pathToFileURL(path.resolve(options.api)))).default;report.apiLoadSeconds=(performance.now()-loaded)/1000;
 const check=performance.now(),front=await inspect(source,{mode:'native',captureCheckedGraph:true});report.frontendSeconds=(performance.now()-check)/1000;
 if(front.status!=='ok'||!front.checkedGraph)throw Error(front.diagnostic||'Checked graph unavailable');report.frontendFiles=front.files.filter(fs.existsSync).map(pin);
 const lowering=performance.now(),lowered=api.nxk_lower(front.checkedGraph,options.entry);report.lowerSeconds=(performance.now()-lowering)/1000;
 if(lowered.error)throw Error('Experimental backend refused: '+lowered.error);
 const opt=performance.now();let program=lowered.program;
 if(options.tail){if(!api.nx_tail_optimize)throw Error('API missing nx_tail_optimize');program=api.nx_tail_optimize(program);}
 const inline=options.inline||'deep';if(!['deep','entry'].includes(inline))throw Error('Unknown inline policy');
 program=api.nx_optimize(api[inline==='entry'?'nx_inline_entry':'nx_inline_deep'](program,options.budget));
 if(options.prune){if(!api.nx_reachable)throw Error('API missing nx_reachable');program=api.nx_reachable(program);}
 if(api.nx_verify(program)!==true)throw Error('IR verifier refused optimized output');report.optimizeSeconds=(performance.now()-opt)/1000;
 const json=api.nx_json_program(program);fs.writeFileSync(path.join(out,'program.json'),json);const parsed=JSON.parse(json);
 const signatures=parsed.functions.map(f=>({name:f.name,params:f.params.map(p=>p.type),result:f.result}));
 const abi={version:1,entry:'u32(const u64*)',signatures,salt:options['abi-salt']||'',target:'x86_64-linux-sysv'};
 const objects=[];const emission=performance.now();
 if(options.backend==='qbe'){
  const identity={abi,producer:report.inputs[1].sha256,qbe:pin(qbe),assembler:toolpin('as'),flags:['amd64_sysv']};report.inputs.push(identity.qbe,identity.assembler);
  let units;
  if(options.units){if(!api.nxq_units)throw Error('API missing nxq_units');const result=api.nxq_units(program,options.fuse);if(result.error)throw Error(result.error);units=[];for(let xs=result.units;xs.$==='Con';xs=xs.tail)units.push(xs.head);}
  else units=[{name:'program',text:options.fuse?api.nxq_program_fused(program):api.nxq_program(program)}];
  report.emitSeconds=(performance.now()-emission)/1000;
  for(const unit of units){if(!/^[a-zA-Z0-9_]+$/.test(unit.name))throw Error('Invalid unit name');const il=path.join(out,hash(unit.name)+'.ssa');fs.writeFileSync(il,unit.text);
   objects.push(objectUnit(unit.name,unit.text,identity,(obj,text)=>{const assembly=path.join(out,hash(unit.name)+'.s');run(unit.name+'-qbe',[qbe,'-t','amd64_sysv','-o',assembly,il]);run(unit.name+'-assemble',['/usr/bin/as','-o',obj,assembly]);}));
  }
 }else if(options.backend==='cranelift'){
  report.inputs.push(pin(cranelift));report.emitSeconds=(performance.now()-emission)/1000;
  objects.push(objectUnit('program',json,{abi,backend:pin(cranelift),profile:'speed_and_size'},obj=>run('cranelift',[cranelift,path.join(out,'program.json'),obj,'speed_and_size'])));
 }else{
  const text=api.nx_c_program(program),file=path.join(out,'program.c');fs.writeFileSync(file,text);report.emitSeconds=(performance.now()-emission)/1000;
  const cc=options.backend==='clang'?clang:'/usr/bin/gcc',args=options.backend==='clang'?['-isystem',path.resolve(path.dirname(clang),'../include/clang')]:[];
  report.inputs.push(pin(cc));objects.push(objectUnit('program',text,{abi,backend:pin(cc),args,profile:'O2'},obj=>run('c-object',[cc,'-O2',...args,'-c',file,'-o',obj])));
 }
 const runobj=objectUnit('runner',fs.readFileSync(runner,'utf8'),{gcc:toolpin('gcc'),profile:'O2',abi:1},obj=>run('runner',['/usr/bin/gcc','-O2','-c',runner,'-o',obj]));
 const binary=path.join(out,'program');run('link',['/usr/bin/gcc',runobj,...objects,'-o',binary]);report.binary=pin(binary);
 if(JSON.stringify(pin(source))!==JSON.stringify(report.source))throw Error('Source changed during compilation');
 for(const input of report.inputs)if(JSON.stringify(pin(input.file))!==JSON.stringify(input))throw Error('Input changed: '+input.file);
 report.complete=true;report.seconds=(performance.now()-begin)/1000;report.finished=new Date().toISOString();save();console.log(JSON.stringify({binary,seconds:report.seconds,cacheHits:report.cache.filter(r=>r.hit).length,cacheMisses:report.cache.filter(r=>!r.hit).length}));
}catch(e){report.error=String(e);report.seconds=(performance.now()-begin)/1000;save();throw e;}
