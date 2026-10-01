// Adversarial host-state witness missing from native-cast-controls v1.
// Run first on the uncorrected derivation and preserve its expected failures.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [derivedArg,outArg]=process.argv.slice(2);
assert(derivedArg&&outArg,'Usage: native-cast-dataview-controls-v2.mjs DERIVED NEW_OUT');
const derived=fs.realpathSync(derivedArg),out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);
const identity=file=>({path:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex'),bytes:fs.statSync(file).size});
const manifestFile=path.join(derived,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
assert(manifest.complete);assert(['phase37-private-native-cast-prototype','phase37-private-native-cast-dataview-prototype'].includes(manifest.kind));
const variants=['original','direct'],modules=[];
const report={kind:'phase37-private-native-cast-dataview-controls-v2',complete:false,pass:false,
 inputs:[identity(import.meta.filename),identity(manifestFile)],observations:[],errors:[],
 scope:'Untimed public prototype and previously leaked private-instance hooks. Each hook must actually execute in generic reference.'};
for(const variant of variants){const row=manifest.modules.find(r=>r.variant===variant&&r.counters);assert(row);
 const actual=identity(row.path);assert.equal(actual.sha256,row.sha256);report.inputs.push(actual);modules.push(await import(pathToFileURL(row.path)));}
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
function snapshot(m){const f=m.G['F32.to_u32'],g=Object.getOwnPropertyDescriptor(m.G,'F32.to_u32'),d=Object.getOwnPropertyDescriptors(f);
 return()=>{for(const k of Reflect.ownKeys(f))if(!Object.hasOwn(d,k))delete f[k];Object.defineProperties(f,d);Object.defineProperty(m.G,'F32.to_u32',g);};}
function hook(object,key,descriptor,action){const old=Object.getOwnPropertyDescriptor(object,key);
 try{Object.defineProperty(object,key,{configurable:true,...descriptor});return action();}finally{if(old)Object.defineProperty(object,key,old);else delete object[key];}}
function observe(m,kind,key){const restore=snapshot(m),events=[];let value,error,view;let entered=false;
 const before=m.privateCastCounts();
 try{
  const original=DataView.prototype[key];
  const callback=function(...args){events.push(key);
   if(kind.endsWith('throw'))throw Error('DataView sentinel');
   if(kind.endsWith('mutation')&&!entered){entered=true;const f=m.G['F32.to_u32'],old=f.code;
    f.code=function(a){events.push('changed-native');return Reflect.apply(old,this,[a]);};}
   if(kind.endsWith('reentry')&&!entered){entered=true;events.push(['nested',m.default.bench(1,7)]);}
   return Reflect.apply(original,this,args);};
  if(kind.startsWith('instance-')){
   const capture=DataView.prototype.setUint32;
   hook(DataView.prototype,'setUint32',{value:function(...args){view=this;return Reflect.apply(capture,this,args);}},()=>m.default.bench(0,17));
   assert(view,'shared floatView must actually be captured through prior fallback');
   if(kind==='instance-prototype'){
    const old=Object.getPrototypeOf(view),replacement=Object.create(old);
    Object.defineProperty(replacement,key,{value:callback,configurable:true});
    Object.setPrototypeOf(view,replacement);try{value=m.default.bench(4,17);}finally{Object.setPrototypeOf(view,old);}
   }else value=hook(view,key,kind.endsWith('getter')?{get(){events.push('get:'+key);return original;}}:{value:callback},()=>m.default.bench(4,17));
  }else value=hook(DataView.prototype,key,kind.endsWith('getter')?{get(){events.push('get:'+key);return original;}}:{value:callback},()=>m.default.bench(4,17));
 }catch(e){error={name:e.name,message:e.message};}finally{restore();}
 return {value,error,events,privateCalls:m.privateCastCounts().calls-before.calls};
}
try{
 for(const key of ['setUint32','getFloat32'])for(const kind of ['prototype-wrap','prototype-getter','prototype-mutation','prototype-reentry','prototype-throw',
  'instance-wrap','instance-getter','instance-mutation','instance-reentry','instance-throw','instance-prototype']){
  const observations=modules.map(m=>observe(m,kind,key));const row={kind,key,observations,pass:false};report.observations.push(row);
  try{assert(observations[0].events.length>0,'vacuous DataView hook');
   if(kind.endsWith('mutation'))assert(observations[0].events.includes('changed-native'),'native mutation must execute');
   if(kind.endsWith('reentry'))assert(observations[0].events.some(e=>Array.isArray(e)&&e[0]==='nested'),'reentry must execute');
   const visible=x=>({value:x.value,error:x.error,events:x.events});assert.deepEqual(visible(observations[1]),visible(observations[0]));
   assert.equal(observations[1].privateCalls,0,'changed DataView must refuse private cast');row.pass=true;
  }catch(error){row.error=error.message;}
 }
 for(const item of report.inputs)assert.deepEqual(identity(item.path),item);
 report.complete=true;report.pass=report.observations.every(row=>row.pass);
}catch(error){report.errors.push(error.stack??String(error));}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
if(!report.complete||!report.pass)process.exitCode=1;
console.log(JSON.stringify({complete:report.complete,pass:report.pass,observations:report.observations.length,
 failed:report.observations.filter(row=>!row.pass).map(row=>row.kind+':'+row.key),errors:report.errors}));
