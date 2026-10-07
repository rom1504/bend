// Root-supervised real compiler control. All writes stay in a fresh private clone.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';

const [attemptArg,frameArg,sourceArg,outArg]=process.argv.slice(2);
assert(attemptArg&&frameArg&&sourceArg&&outArg,'Usage: cache-prepare-migration-v1.mjs CHECKED_ATTEMPT FRAME4 SOURCE NEW_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase64')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex'),inputs=new Map(),copies=[];
const identity=file=>{const bytes=fs.readFileSync(file);return {file:fs.realpathSync(file),sha256:hash(bytes),bytes:bytes.length};};
function pin(file,want){const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(Object.hasOwn(want,'canonicalPath'))assert.equal(x.file,want.canonicalPath);if(Object.hasOwn(want,'bytes'))assert.equal(x.bytes,want.bytes);}if(inputs.has(x.file))assert.deepEqual(x,inputs.get(x.file));inputs.set(x.file,x);return x;}
const report={kind:'phase64-real-prepare-frame-migration',complete:false,pass:false,steps:[],inputs:[],copies,
 scope:'Actual owned driver preparation and compilation in a fresh private project. Start with only a valid same-API frame3; retain it unchanged while actual prepareBase creates frame4. Compare complete generated modules and exact decoded roots. Forwarding API counters observe actual private entry coupling; this is diagnostic, not latency data.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
const copied=[];let restore=()=>{};
try{
 pin(import.meta.filename);pin(process.execPath);pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);
 const m=await verifyAttempt(attemptArg);assert(m.checked&&m.config.strictExact);report.attempt=pin(path.join(attemptArg,'attempt.json'));
 for(const k of ['api','runtime','base','node'])pin(m[k].file,m[k]);assert.equal(pin(process.execPath).sha256,m.node.sha256);
 const frame=pin(frameArg),source=pin(sourceArg),project=path.join(out,'project');
 const copy=(file,relative)=>{const before=pin(file),target=path.join(project,relative);fs.mkdirSync(path.dirname(target),{recursive:true});fs.copyFileSync(before.file,target,fs.constants.COPYFILE_EXCL);const after=identity(target);assert.equal(after.sha256,before.sha256);copies.push({before,after});copied.push(after);return after;};
 const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name)).flatMap(e=>e.isDirectory()?walk(path.join(dir,e.name)):[path.join(dir,e.name)]);
 for(const name of ['typed-driver','assemble','compiler-abi','node-resource-args','native-build','base-cache-graph'])copy(path.join(m.snapshot.root,'tools',name+'.mjs'),'tools/'+name+'.mjs');
 copy(path.join(m.snapshot.root,'src/compiler.json'),'src/compiler.json');const runtime=copy(m.runtime.file,'src/runtime.mjs');
 for(const f of walk(path.join(m.snapshot.root,'src/runtime')))copy(f,path.relative(m.snapshot.root,f));
 const image=copy(m.api.file,'dist/api.mjs');assert(!fs.existsSync(image.file+'.bootstrap.json'));
 for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
 process.env.BEND_TYPED_API=image.file;process.env.BEND_TYPED_RUNTIME=runtime.file;process.env.BEND_BASE=m.base.file;
 const driver=path.join(project,'tools/typed-driver.mjs'),D=await import(pathToFileURL(driver)),api=await D.loadApi(),mod=await import(pathToFileURL(image.file));
 assert.equal(mod.G,undefined,'This diagnostic requires the actual named-layout compiler');assert.equal(api,mod.default);assert.equal(D.apiPath,image.file);assert.equal(D.basePath,m.base.file);
 const driverText=fs.readFileSync(driver,'utf8'),suffix='\nexport {baseCacheInfo,encodeBaseCacheFrame};\n',exportsFile=path.join(project,'tools/migration-exports.mjs');
 for(const name of ['baseCacheInfo','encodeBaseCacheFrame'])assert.equal((driverText.match(new RegExp('function '+name+'\\(' ,'g'))??[]).length,1,name);
 fs.writeFileSync(exportsFile,driverText+suffix,{flag:'wx'});report.driverDerivative={parent:identity(driver),output:pin(exportsFile),appendOnly:true,suffixSha256:hash(suffix)};
 const E=await import(pathToFileURL(exportsFile)),info=E.baseCacheInfo(api);assert(info.file.endsWith('-frame4.json'));assert(info.file.startsWith(project+path.sep));
 const canonicalBytes=fs.readFileSync(frame.file),cut=canonicalBytes.indexOf(10),header=JSON.parse(canonicalBytes.subarray(0,cut));
 assert.equal(header.format,'bend-base-cache-frame-4');assert.equal(header.preparedWorldVersion,3);assert.equal(header.compilerSha256,image.sha256);assert.equal(header.baseSha256,m.base.sha256);assert.equal(header.sourcePath,fs.realpathSync(m.base.file));
 const canonical=D.decodeBaseCacheFrame(canonicalBytes);for(const key of ['book','checkedPrefixState','freshPrefixState','preparedWorld','frontendReadyState'])assert(canonical[key],key);
 assert.equal(canonical.preparedWorld.prefix,canonical.book);assert.equal(canonical.preparedWorld.state,canonical.checkedPrefixState);
 const legacy=E.encodeBaseCacheFrame(canonical),legacyFile=info.file.replace(/-frame4\.json$/,'-frame3.json');assert.equal(JSON.parse(legacy.subarray(0,legacy.indexOf(10))).format,'bend-base-cache-frame-3');
 fs.mkdirSync(info.directory,{recursive:true});fs.writeFileSync(legacyFile,legacy,{flag:'wx'});const legacyIdentity=identity(legacyFile);assert.deepEqual(fs.readdirSync(info.directory),[path.basename(legacyFile)]);
 const counts={world:0,context:0,prepareWorld:0,prepareState:0,checkBase:0},originals=new Map();let lastWorld=null;
 function wrap(name,fn){assert.equal(typeof api[name],'function',name);const old=api[name];originals.set(name,old);api[name]=(...args)=>fn(old,args);}
 restore=()=>{for(const [name,old]of originals)api[name]=old;};
 wrap('check_program_diagnostic_world',(old,args)=>{counts.world++;const [load,,prepared]=args;assert.equal(load.ready,true);assert.equal(prepared.state.ready,true);const result=old(...args);lastWorld={load,prepared,result};return result;});
 wrap('book_context_world',(old,args)=>{counts.context++;assert(lastWorld);assert.equal(lastWorld.result.error,'');assert.equal(args[0],lastWorld.result.book);assert.equal(args[1],lastWorld.load);assert.equal(args[2],lastWorld.prepared);const actual=old(...args);assert.deepEqual(actual,api.book_context(args[0]),'complete owned context');return actual;});
 wrap('base_prefix_world_prepare',(old,args)=>{counts.prepareWorld++;return old(...args);});
 wrap('base_prefix_prepare',(old,args)=>{counts.prepareState++;return old(...args);});
 wrap('check_book',(old,args)=>{counts.checkBase++;return old(...args);});
 const snapshot=()=>({...counts}),delta=(a,b)=>Object.fromEntries(Object.keys(a).map(k=>[k,b[k]-a[k]]));
 const compile=async(label)=>{const before=snapshot(),r=await D.inspect(source.file,{mode:'library',backend:'direct'});assert.equal(r.status,'ok',r.diagnostic);assert.equal(r.checked,true);assert.equal(r.typeAccepted,true);const queries=delta(before,snapshot());assert.equal(queries.world,1,label+' actual owned world entry');assert.equal(queries.context,1,label+' same-result owned context');assert.equal(queries.prepareWorld,0,label+' no hidden preparation');for(const f of r.files)pin(f);report.steps.push({label,pass:true,queries,outputSha256:hash(r.code),outputBytes:Buffer.byteLength(r.code)});save();return r;};
 const before=await compile('compile-legacy-frame3');assert(!fs.existsSync(info.file));assert.deepEqual(identity(legacyFile),legacyIdentity);assert.deepEqual(fs.readdirSync(info.directory),[path.basename(legacyFile)]);
 let prior=snapshot();const prepared=await D.prepareBase();const preparation=delta(prior,snapshot());assert.equal(preparation.prepareWorld,1);assert.equal(preparation.prepareState,0,'Prior checked state is reused');assert.equal(preparation.checkBase,0,'Prior validated Base remains checked');assert.equal(preparation.world,0);assert.equal(preparation.context,0);
 assert(fs.existsSync(info.file),'Explicit preparation must create selected frame4');assert.deepEqual(identity(legacyFile),legacyIdentity,'Migration keeps frame3 bytes');
 const generatedBytes=fs.readFileSync(info.file),generatedHeader=JSON.parse(generatedBytes.subarray(0,generatedBytes.indexOf(10)));assert.equal(generatedHeader.format,'bend-base-cache-frame-4');
 const generated=D.decodeBaseCacheFrame(generatedBytes);for(const key of ['book','checkedPrefixState','freshPrefixState','preparedWorld','frontendReadyState']){assert.deepEqual(generated[key],canonical[key],key+' re-preparation is exact');assert.deepEqual(prepared[key],generated[key],key+' returned prepared roots');}
 assert.equal(generated.preparedWorld.prefix,generated.book);assert.equal(generated.preparedWorld.state,generated.checkedPrefixState);const generatedIdentity=identity(info.file);
 report.steps.push({label:'explicit-prepare-upgrades',pass:true,queries:preparation,frame3:legacyIdentity,frame4:generatedIdentity});save();
 const after=await compile('compile-arena-frame4');assert.equal(after.code,before.code,'Complete Numeric module unchanged after migration');
 fs.writeFileSync(path.join(out,'program.mjs'),after.code,{flag:'wx'});report.program=pin(path.join(out,'program.mjs'));
 prior=snapshot();const reused=await D.prepareBase(),reuse=delta(prior,snapshot());assert.deepEqual(reuse,{world:0,context:0,prepareWorld:0,prepareState:0,checkBase:0});assert.deepEqual(reused.book,generated.book);assert.deepEqual(identity(info.file),generatedIdentity);assert.deepEqual(identity(legacyFile),legacyIdentity);
 assert.deepEqual(fs.readdirSync(info.directory).sort(),[path.basename(legacyFile),path.basename(info.file)].sort());report.steps.push({label:'selected-frame4-idempotent-prepare',pass:true,queries:reuse});
 restore();restore=()=>{};await verifyAttempt(attemptArg);for(const x of copied)assert.deepEqual(identity(x.file),x);for(const x of inputs.values())assert.deepEqual(identity(x.file),x);report.complete=true;report.pass=true;save();
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};save();throw error;}finally{restore();}
console.log(JSON.stringify({complete:report.complete,pass:report.pass,steps:report.steps.length}));
