// Root-only transport/admission controls. No compiler image import.
// node base-annotations-host-v1.mjs STAGED_DRIVER FRAME4 BASE NEW_PHASE65_OUT
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [driverArg,frameArg,baseArg,outArg]=process.argv.slice(2);assert(driverArg&&frameArg&&baseArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase65')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex'),inputs=new Map(),pin=(file,want)=>{const real=fs.realpathSync(file),bytes=fs.readFileSync(real),x={file:real,sha256:hash(bytes),bytes:bytes.length};if(want)assert.equal(x.sha256,want.sha256,real);if(inputs.has(real))assert.deepEqual(x,inputs.get(real));inputs.set(real,x);return x;};
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const report={kind:'phase65-base-annotation-host-controls',complete:false,pass:false,controls:[],scope:'Actual private sidecar writer/reader with admitted frame4, bounded transport and deferred read-order controls. Stub producer supplies schema-valid existing Base definitions solely for transport tests; semantic annotation correctness and owned inspect/public-injected routing require separate real-image controls. No compiler image imported.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 pin(import.meta.filename);pin(path.join(import.meta.dirname,'base-annotations-host-v1.derivation.json'));pin(process.execPath);
 const manifestFile=path.resolve(import.meta.dirname,'../cache-contract/base-annotations-v2.json');report.candidate=pin(manifestFile);const manifest=JSON.parse(fs.readFileSync(manifestFile));pin(path.join(root,manifest.patch),{sha256:manifest.patchSha256});
 report.driver=pin(driverArg,{sha256:manifest.files['selfhost/tools/typed-driver.mjs'].afterSha256});report.frame=pin(frameArg);report.base=pin(baseArg);
 const helper=pin(path.join(path.dirname(report.driver.file),'base-cache-graph.mjs')),original=fs.readFileSync(report.driver.file,'utf8');
 const scratch=path.join(out,'scratch'),project=path.join(scratch,'project');fs.mkdirSync(project,{recursive:true});
 const compilerManifest=pin(path.resolve(path.dirname(report.driver.file),'../src/compiler.json')),copiedManifest=path.join(project,'src/compiler.json');fs.mkdirSync(path.dirname(copiedManifest),{recursive:true});fs.copyFileSync(compilerManifest.file,copiedManifest);report.compilerManifestCopy=pin(copiedManifest,compilerManifest);
 const line="export const project=path.resolve(import.meta.dirname,'..');";assert.equal(original.split(line).length,2);
 let code=original.replace(line,'export const project='+JSON.stringify(project)+';');
 const importEdits=[];code=code.replace(/from '(\.\/[^']+)'/g,(before,name)=>{const after="from '"+pathToFileURL(path.resolve(path.dirname(report.driver.file),name)).href+"'";importEdits.push({before,after});return after;});
 const exports=['readBaseCache','baseAnnotationFile','withBaseAnnotationFile','decodeBaseAnnotationProduct','readBaseAnnotations','prepareBaseAnnotations','encodeBaseCacheFrame'];
 const suffix='\nexport {'+exports.join(',')+'};\n';code+=suffix;
 let recovered=code.slice(0,-suffix.length);for(const e of importEdits)recovered=recovered.replace(e.after,e.before);recovered=recovered.replace('export const project='+JSON.stringify(project)+';',line);assert.equal(recovered,original);
 const derivative=path.join(scratch,'driver.mjs');fs.writeFileSync(derivative,code,{flag:'wx'});report.derivative={file:derivative,sha256:hash(code),exactInverse:true,project,importEdits,suffixSha256:hash(suffix)};
 const D=await import(pathToFileURL(derivative)),H=await import(pathToFileURL(helper.file));
 const frameBytes=fs.readFileSync(report.frame.file),cut=frameBytes.indexOf(10),header=JSON.parse(frameBytes.subarray(0,cut));assert.equal(header.format,'bend-base-cache-frame-4');
 const bookBytes=frameBytes.subarray(cut+1,cut+1+header.segments[0]);
 const info={version:header.version,termAbi:header.termAbi??0,compilerSha256:header.compilerSha256,baseSha256:header.baseSha256,sourcePath:report.base.file,sourceText:fs.readFileSync(report.base.file,'utf8'),file:path.join(scratch,'base-frame4.json'),directory:scratch};
 assert.equal(info.baseSha256,report.base.sha256);assert.equal(header.sourcePath,info.sourcePath);fs.writeFileSync(info.file,frameBytes,{flag:'wx'});
 const cached=D.readBaseCache(info,{entry:null});assert(cached?.preparedWorld&&cached.checkedPrefixState);assert.equal(cached.preparedWorld.prefix,cached.book);assert.equal(cached.preparedWorld.state,cached.checkedPrefixState);assert(Object.isFrozen(cached.preparedWorld));
 const fixture=cached.preparedWorld.checked.head;assert.equal(fixture.$,'KDef');assert(fixture.name);const product=list([fixture]),keys=list([fixture.name]),state={$:'KBaseAnnotationState',keys,book:product};
 const selected={fixture:'selected'},stops={fixture:'stops'},load={fixture:'load'};
 function apiFor({wanted=true,allowed=true,producer=state,throwAt=null}={}){const events=[];return {events,api:{
  base_annotation_prepare(world,minimum){events.push('prepare');assert.equal(world,cached.preparedWorld);assert.equal(minimum,64);if(throwAt==='prepare')throw Error('producer refusal');return producer;},
  base_annotation_wanted(s,t,k){events.push('wanted');assert.equal(s,selected);assert.equal(t,stops);assert.deepEqual(k,keys);if(throwAt==='wanted')throw Error('wanted refusal');return wanted;},
  base_annotation_allowed(l,world){events.push('allowed');assert.equal(l,load);assert.equal(world,cached.preparedWorld);if(throwAt==='allowed')throw Error('allowed refusal');return allowed;},
  annotate_selected_base(){throw Error('Transport test never annotates');}
 }};}
 const file=D.baseAnnotationFile(info);assert(file.startsWith(project+path.sep));const check=(name,fn)=>{const detail=fn()??{};report.controls.push({name,pass:true,...detail});save();};
 let valid,meta,body,bodyOffset;
 check('explicit writer builds optional sidecar from exact admitted frame',()=>{const x=apiFor();assert.equal(D.prepareBaseAnnotations(x.api,cached,info),true);assert.deepEqual(x.events,['prepare']);valid=fs.readFileSync(file);const n=valid.readUInt32LE(0);meta=JSON.parse(valid.subarray(4,4+n));body=valid.subarray(4+n);bodyOffset=4+n;assert.equal(meta.format,'bend-base-annotations-1');assert.equal(meta.minimumWork,64);assert.equal(meta.productBytes,body.length);assert.equal(meta.productSha256,hash(body));assert.equal(meta.bookGraphSha256,header.bookGraphSha256);assert.equal(meta.preparedGraphSha256,header.preparedGraphSha256);});
 const pack=(h=meta,b=body)=>{const text=Buffer.from(JSON.stringify(h)),length=Buffer.alloc(4);length.writeUInt32LE(text.length);return Buffer.concat([length,text,b]);};
 const put=bytes=>fs.writeFileSync(file,bytes);
 function read(options={},cache=cached,bytes=valid){put(bytes);const x=apiFor(options),reads=[],prior=fs.readSync;fs.readSync=(...args)=>{reads.push({length:args[3],position:args[4]});return prior(...args);};let value;try{value=D.readBaseAnnotations(x.api,info,cache,load,selected,stops);}finally{fs.readSync=prior;}return {...x,value,reads};}
 const headerOnly=(x,offset=bodyOffset)=>{assert(x.reads.length===2);assert(x.reads.every(r=>r.position<offset&&r.position+r.length<=offset));};
 const noProduct=x=>assert.equal(x.value,null);
 check('valid selected allowed product decodes exact values',()=>{const x=read();assert.deepEqual(x.events,['wanted','allowed']);assert.deepEqual(x.value,product);assert.equal(x.reads.length,3);assert.equal(x.reads[2].position,bodyOffset);return{reads:x.reads};});
 check('no wanted definition reads header only',()=>{const x=read({wanted:false});noProduct(x);assert.deepEqual(x.events,['wanted']);headerOnly(x);});
 check('refused current world reads header only',()=>{const x=read({allowed:false});noProduct(x);assert.deepEqual(x.events,['wanted','allowed']);headerOnly(x);});
 const corruptedBody=Buffer.from(body);corruptedBody[0]^=1;const corrupt=pack(meta,corruptedBody);
 check('unselected corrupted body remains unread',()=>{const x=read({wanted:false},cached,corrupt);noProduct(x);assert.deepEqual(x.events,['wanted']);headerOnly(x);});
 check('world-refused corrupted body remains unread',()=>{const x=read({allowed:false},cached,corrupt);noProduct(x);headerOnly(x);});
 check('selected corrupt body falls back after admission',()=>{const x=read({},cached,corrupt);noProduct(x);assert.deepEqual(x.events,['wanted','allowed']);assert.equal(x.reads.length,3);});
 for(const key of ['format','version','producer','minimumWork','compilerSha256','baseSha256','sourcePath','termAbi','spanAbi','sourceBegin','sourceEnd','bookGraphSha256','preparedGraphSha256'])check('reject mismatched '+key,()=>{const value=typeof meta[key]==='number'?meta[key]+1:'wrong';const x=read({},cached,pack({...meta,[key]:value}));noProduct(x);assert.deepEqual(x.events,[]);});
 for(const [key,value]of [['productBytes',-1],['productBytes',0.5],['productBytes',31],['productBytes',134217729],['productBytes',body.length+1],['productSha256','bad'],['keys',null],['keys','bad='],['keys',meta.keys+'\n'],['keysSha256','bad']])check('reject malformed '+key+' '+JSON.stringify(value),()=>{const x=read({},cached,pack({...meta,[key]:value}));noProduct(x);assert.deepEqual(x.events,[]);});
 const replaceKeys=bytes=>pack({...meta,keys:bytes.toString('base64'),keysSha256:hash(bytes)});
 check('reject malformed keys arena with correct digest',()=>{const bytes=Buffer.from(meta.keys,'base64');bytes.writeUInt32LE(0,0);const x=read({},cached,replaceKeys(bytes));noProduct(x);assert.deepEqual(x.events,[]);});
 check('reject wrong key root subtype with correct digest',()=>{const bytes=H.encodeBaseArena([fixture.typ]).bytes,x=read({},cached,replaceKeys(bytes));noProduct(x);assert.deepEqual(x.events,[]);});
 check('reject null key root with correct digest',()=>{const bytes=Buffer.from(meta.keys,'base64');bytes.writeUInt32LE(0xffffffff,32);const x=read({},cached,replaceKeys(bytes));noProduct(x);assert.deepEqual(x.events,[]);});
 const productMutation=fn=>{const b=Buffer.from(body);fn(b);return pack({...meta,productSha256:hash(b)},b);};
 check('reject malformed product arena with correct digest',()=>{const x=read({},cached,productMutation(b=>b.writeUInt32LE(0,0)));noProduct(x);assert.deepEqual(x.events,['wanted','allowed']);});
 check('reject null product root with correct digest',()=>noProduct(read({},cached,productMutation(b=>b.writeUInt32LE(0xffffffff,32)))));
 check('reject product forward root with correct digest',()=>noProduct(read({},cached,productMutation(b=>b.writeUInt32LE(b.readUInt32LE(4)+b.readUInt32LE(8),32)))));
 check('reject product wrong parent count with correct digest',()=>noProduct(read({},cached,productMutation(b=>b.writeUInt32LE(b.readUInt32LE(4)+1,4)))));
 check('reject product wrong root subtype with correct digest',()=>{const n=bookBytes.readUInt32LE(8),tags=32+bookBytes.readUInt32LE(28)*4;let id=0;while(id<n&&bookBytes[tags+id]!==2)id++;assert(id<n);noProduct(read({},cached,productMutation(b=>b.writeUInt32LE(id,32))));});
 check('reject oversized header before allocation',()=>{const b=Buffer.from(valid);b.writeUInt32LE(65537,0);const x=read({},cached,b);noProduct(x);assert.equal(x.reads.length,1);assert.deepEqual(x.events,[]);});
 check('reject truncated physical file',()=>{const x=read({},cached,valid.subarray(0,valid.length-1));noProduct(x);assert.deepEqual(x.events,[]);});
 check('reject trailing physical bytes',()=>{const x=read({},cached,Buffer.concat([valid,Buffer.from([0]) ]));noProduct(x);assert.deepEqual(x.events,[]);});
 check('reject malformed JSON header',()=>{const b=Buffer.from(valid);b[4]=0;const x=read({},cached,b);noProduct(x);assert.deepEqual(x.events,[]);});
 check('wanted exceptions decline optional capability',()=>{const x=read({throwAt:'wanted'});noProduct(x);assert.deepEqual(x.events,['wanted']);headerOnly(x);});
 check('allowed exceptions decline optional capability',()=>{const x=read({throwAt:'allowed'});noProduct(x);assert.deepEqual(x.events,['wanted','allowed']);headerOnly(x);});
 check('forged equal world lacks private graph binding',()=>{const x=read({}, {...cached,preparedWorld:structuredClone(cached.preparedWorld)});noProduct(x);assert.deepEqual(x.reads,[]);assert.deepEqual(x.events,[]);});
 check('absent world lacks private graph binding',()=>{const x=read({}, {...cached,preparedWorld:undefined});noProduct(x);assert.deepEqual(x.reads,[]);assert.deepEqual(x.events,[]);});
 check('frame3 world cannot supply frame4 reference numbering',()=>{const decoded=D.decodeBaseCacheFrame(D.encodeBaseCacheFrame(cached));assert(decoded.preparedWorld);const x=read({},decoded);noProduct(x);assert.deepEqual(x.reads,[]);assert.deepEqual(x.events,[]);});
 check('deleted sidecar declines without cached product reuse',()=>{put(valid);const x=apiFor();assert.deepEqual(D.readBaseAnnotations(x.api,info,cached,load,selected,stops),product);fs.unlinkSync(file);x.events.length=0;assert.equal(D.readBaseAnnotations(x.api,info,cached,load,selected,stops),null);assert.deepEqual(x.events,[]);});
 check('sidecar replacement is reread on same prepared world',()=>{assert.deepEqual(read().value,product);noProduct(read({},cached,corrupt));assert.deepEqual(read().value,product);});
 check('valid sidecar preparation reuses without producer',()=>{put(valid);const x=apiFor({throwAt:'prepare'});assert.equal(D.prepareBaseAnnotations(x.api,cached,info),true);assert.deepEqual(x.events,[]);});
 check('corrupt sidecar explicit preparation rebuilds',()=>{put(corrupt);const x=apiFor();assert.equal(D.prepareBaseAnnotations(x.api,cached,info),true);assert.deepEqual(x.events,['prepare']);assert.deepEqual(fs.readFileSync(file),valid);});
 check('producer refusal keeps optional fallback',()=>{put(corrupt);const x=apiFor({throwAt:'prepare'});assert.equal(D.prepareBaseAnnotations(x.api,cached,info),false);assert.deepEqual(x.events,['prepare']);assert.deepEqual(fs.readFileSync(file),corrupt);});
 check('wrong producer result refuses publication',()=>{fs.rmSync(file,{force:true});const x=apiFor({producer:{$:'Wrong'}});assert.equal(D.prepareBaseAnnotations(x.api,cached,info),false);assert.equal(fs.existsSync(file),false);});
 check('missing new APIs do not prepare products',()=>{const x=apiFor();delete x.api.base_annotation_wanted;assert.equal(D.prepareBaseAnnotations(x.api,cached,info),false);assert.deepEqual(x.events,[]);});
 check('writer declines unbound world',()=>{const x=apiFor();assert.equal(D.prepareBaseAnnotations(x.api,{...cached,preparedWorld:structuredClone(cached.preparedWorld)},info),false);assert.deepEqual(x.events,[]);});
 check('parent mandatory frame remains exact',()=>assert.deepEqual(fs.readFileSync(info.file),frameBytes));
 for(const x of inputs.values())pin(x.file,x);assert.equal(hash(fs.readFileSync(derivative)),report.derivative.sha256);report.count=report.controls.length;report.complete=report.pass=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,count:report.count,error:report.error}));
