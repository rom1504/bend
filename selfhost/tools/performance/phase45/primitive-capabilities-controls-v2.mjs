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
function pin(p,want){const r=identity(p);if(want){assert.equal(r.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(r.bytes,want.bytes);}report.inputs.push(r);return r;}
function audit(x){if(!x||typeof x!=='object')return;const p=x.file??x.path??x.canonicalPath;if(typeof p==='string'&&x.sha256)pin(p,x);for(const v of Object.values(x))audit(v);}
const used=['U32.add','U32.mul','U32.sub','U32.xor','U32.is_zero'];
const unused=['U32.div','U32.from_nat','F32.sin','F32.sqrt'];
try{
 pin(import.meta.filename);pin(process.execPath);const module=pin(file),receipt=pin(file+'.json');
 const r=JSON.parse(fs.readFileSync(receipt.file));assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);
 assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');assert.equal(r.output.sha256,module.sha256);
 assert.equal(r.compiler.kind,'checked-development-attempt');audit(r);
 const catalogFile=path.join(import.meta.dirname,'primitive-capabilities-catalog-v1.json');const catalogId=pin(catalogFile),catalog=JSON.parse(fs.readFileSync(catalogFile));
 const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path));assert.equal(source.sha256,r.input.sha256);assert.equal(source.sha256,catalog.cases[0].source.sha256);assert.equal(source.bytes,catalog.cases[0].source.bytes);assert.equal(r.catalog.sha256,catalogId.sha256);assert.equal(r.compiler.upstreamCommit,catalog.upstreamCommit);assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
 let text=fs.readFileSync(file,'utf8');assert(!text.includes('$p45CapEntries'));
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
 new Function('module','exports',parserSource)(parserModule,parserModule.exports);
 const parse=s=>parserModule.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
 const assignments=[];function walk(n){if(!n||typeof n!=='object')return;if(n.type==='AssignmentExpression'&&n.operator==='='&&n.left.type==='MemberExpression'&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.computed&&n.left.property.type==='Literal')assignments.push(n);for(const v of Object.values(n))if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v);}
 walk(parse(text));const edits=[];report.parser={version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')};
 for(const root of ['verdant','ochre']){
  const matches=assignments.filter(n=>n.left.property.value===root);assert.equal(matches.length,1,'unique renamed root '+root);const assignment=matches[0],line=text.slice(assignment.start,assignment.end);assert(line.includes('scalarCapture'),'missing root capture '+root);
  const marker='/* private contextual instances */';assert.equal(line.split(marker).length-1,1);
  assert(line.includes('regionHostGuard()&&stringHostGuard()'),'host guards changed');
  const match=line.match(/const \$guards=(\[[^\]]*\]);/);assert(match);
  const guards=JSON.parse(match[1].replace(/,\]$/,']'));report.guards[root]=guards;
  for(const name of used)assert(guards.includes(name),'missing used primitive '+name);
  for(const name of unused)assert(!guards.includes(name),'unused primitive still fenced '+name);
  edits.push({start:assignment.start,end:assignment.end,body:line.replace(marker,marker+'++$p45CapEntries;')});
 }
 for(const e of edits.sort((a,b)=>b.start-a.start))text=text.slice(0,e.start)+e.body+text.slice(e.end);
 text+='\nlet $p45CapEntries=0;export function primitiveCapabilityEntries(){return $p45CapEntries;}\n';
 parse(text);const counted=path.join(out,'counted.mjs');fs.writeFileSync(counted,text,{flag:'wx'});pin(counted);
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
 for(const row of report.inputs)assert.deepEqual(identity(row.file),row,'changed consumed input');
 report.complete=true;report.pass=true;
}catch(e){report.error={name:e.name,message:e.message,stack:e.stack};throw e;}
finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');}
console.log(JSON.stringify({complete:true,pass:true,observations:report.observations.length}));
