// Genuine checked source controls; root owns execution. No timing.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [moduleArg,outArg]=process.argv.slice(2);
assert(moduleArg&&outArg,'primitive-capabilities-controls-v1.mjs CHECKED_MODULE NEW_OUT');
const file=fs.realpathSync(moduleArg),out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);
const identity=p=>{p=fs.realpathSync(p);const b=fs.readFileSync(p);return{file:p,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
const report={kind:'phase45-exact-primitive-capabilities-controls',complete:false,pass:false,inputs:[],observations:[],guards:{}};
function pin(p){const r=identity(p);report.inputs.push(r);return r;}
function audit(x){if(!x||typeof x!=='object')return;if(x.canonicalPath&&x.sha256)assert.equal(pin(x.canonicalPath).sha256,x.sha256);for(const v of Object.values(x))audit(v);}
const used=['U32.add','U32.mul','U32.sub','U32.xor','U32.is_zero'];
const unused=['U32.div','U32.from_nat','F32.sin','F32.sqrt'];
try{
 pin(import.meta.filename);pin(process.execPath);const module=pin(file),receipt=pin(file+'.json');
 const r=JSON.parse(fs.readFileSync(receipt.file));assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);
 assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');assert.equal(r.output.sha256,module.sha256);
 assert.equal(r.compiler.kind,'checked-development-attempt');audit(r);
 const catalogFile=path.join(import.meta.dirname,'primitive-capabilities-catalog-v1.json');const catalogId=pin(catalogFile),catalog=JSON.parse(fs.readFileSync(catalogFile));
 const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path));assert.equal(source.sha256,r.input.sha256);assert.equal(r.catalog.sha256,catalogId.sha256);
 let text=fs.readFileSync(file,'utf8');assert(!text.includes('$p45CapEntries'));
 for(const root of ['verdant','ochre']){
  const line=text.split('\n').find(l=>l.startsWith('G['+JSON.stringify(root)+']=scalarCapture'));assert(line,'missing renamed root '+root);
  const marker='/* private contextual instances */';assert.equal(line.split(marker).length-1,1);
  assert(line.includes('regionHostGuard()&&stringHostGuard()'),'host guards changed');
  const match=line.match(/const \$guards=(\[[^\]]*\]);/);assert(match);
  const guards=JSON.parse(match[1].replace(/,\]$/,']'));report.guards[root]=guards;
  for(const name of used)assert(guards.includes(name),'missing used primitive '+name);
  for(const name of unused)assert(!guards.includes(name),'unused primitive still fenced '+name);
  text=text.replace(line,line.replace(marker,marker+'++$p45CapEntries;'));
 }
 text+='\nlet $p45CapEntries=0;export function primitiveCapabilityEntries(){return $p45CapEntries;}\n';
 const counted=path.join(out,'counted.mjs');fs.writeFileSync(counted,text,{flag:'wx'});pin(counted);
 const m=await import(pathToFileURL(counted));
 function run(root,name,kind,expectActivation){
  const events=[],f=name?m.G[name]:null,old=name?Object.getOwnPropertyDescriptor(f,'code'):null;
  if(name)Object.defineProperty(f,'code',kind==='getter'?{enumerable:old.enumerable,configurable:old.configurable,get(){events.push(name);return old.value;}}:{...old,value:function(a){events.push(name);return Reflect.apply(old.value,this,[a]);}});
  const before=m.primitiveCapabilityEntries();let value;
  try{value=m.default[root]();}finally{if(name)Object.defineProperty(f,'code',old);}
  const activation=m.primitiveCapabilityEntries()-before;assert.equal(value,root==='verdant'?38272:73);
  assert.equal(activation,expectActivation?1:0);assert.deepEqual(events,[]);
  report.observations.push({root,name,kind,value,activation,events});
 }
 for(const root of ['verdant','ochre']){
  run(root,null,'ordinary',true);
  for(const name of used)for(const kind of ['getter','replacement'])run(root,name,kind,false);
  for(const name of unused)for(const kind of ['getter','replacement'])run(root,name,kind,true);
  run(root,null,'restored',true);
 }
 report.complete=true;report.pass=true;
}catch(e){report.error={name:e.name,message:e.message,stack:e.stack};throw e;}
finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');}
console.log(JSON.stringify({complete:true,pass:true,observations:report.observations.length}));
