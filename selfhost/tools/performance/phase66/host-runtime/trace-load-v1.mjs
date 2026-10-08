// Root-only bounded diagnostic. Clone the failed control's private project;
// wrap public API boundaries only to preserve the original thrown stack.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [priorArg,outArg]=process.argv.slice(2),root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg??'.');
assert(priorArg&&out.startsWith(path.join(root,'selfhost/build/phase66')+path.sep)&&!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex'),inputs=new Map();
function pin(file,want){file=fs.realpathSync(file);const bytes=fs.readFileSync(file),p={file,sha256:hash(bytes),bytes:bytes.length};if(want?.sha256)assert.equal(p.sha256,want.sha256,file);if(inputs.has(file))assert.deepEqual(p,inputs.get(file));inputs.set(file,p);return p;}
const report={kind:'phase66-source-load-boundary-trace',complete:false,pass:false,diagnosticOnly:true,events:[],throws:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
  pin(import.meta.filename);pin(process.execPath);report.parent=pin(priorArg);
  const prior=JSON.parse(fs.readFileSync(priorArg,'utf8'));
  assert.equal(prior.kind,'phase66-host-runtime-controls');assert.equal(prior.pass,false);
  for(const p of prior.inputs)pin(p.file,p);
  const failed=prior.cases.find(c=>c.id==='source-marshal_array_depth');
  assert.equal(failed.compilation.phase,'load');assert.equal(failed.compilation.checked,false);
  const attempt=JSON.parse(fs.readFileSync(prior.attempt.file,'utf8'));
  assert.equal(pin(process.execPath).sha256,attempt.node.sha256);
  const oldProject=prior.preparation.privateClone,project=path.join(out,'project');
  function copyTree(from,to){fs.mkdirSync(to,{recursive:true});for(const e of fs.readdirSync(from,{withFileTypes:true})){const src=path.join(from,e.name),dst=path.join(to,e.name);if(e.isDirectory())copyTree(src,dst);else{assert(e.isFile());const p=pin(src);fs.copyFileSync(src,dst);pin(dst,p);}}}
  copyTree(oldProject,project);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_')||key==='NODE_OPTIONS')delete process.env[key];
  Object.assign(process.env,{BEND_UPSTREAM:attempt.config.upstream,BEND_TYPED_API:prior.image.api.file,BEND_BASE:prior.image.base.file,BEND_TYPED_RUNTIME:path.join(project,'src/runtime.mjs')});
  const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs'))),mod=await import(pathToFileURL(prior.image.api.file)),api=await D.loadApi();
  assert.equal(api,mod.default);assert.equal(D.project,project);
  const originals=new Map(Object.entries(api).filter(([,f])=>typeof f==='function'));
  const oldLimit=Error.stackTraceLimit;Error.stackTraceLimit=80;
  let sequence=0;
  const event=(name,kind)=>{report.events.push({sequence:sequence++,name,kind});if(report.events.length>64)report.events.shift();};
  for(const [name,f] of originals)api[name]=function(...args){event(name,'enter');try{const value=Reflect.apply(f,this,args);event(name,'return');return value;}catch(error){event(name,'throw');report.throws.push({name,errorName:error?.name,message:String(error?.message??error),stack:error?.stack});throw error;}};
  try{report.observation=await D.inspect(failed.source.file,{mode:'parse',backend:'direct'});}
  finally{for(const [name,f] of originals)api[name]=f;Error.stackTraceLimit=oldLimit;}
  report.scope='Same failed raw compiler image and byte-identical cloned host/cache; ordinary owned parse mode. Forwarding API wrappers collect the first original stack, adding a diagnostic boundary frame. No checker/backend/runtime execution and no successful-language qualification inferred.';
  for(const p of inputs.values())pin(p.file,p);
  report.inputsUnchanged=true;report.complete=true;
  report.pass=report.throws.length>0&&report.observation.status==='error';
}catch(error){report.error={name:error?.name,message:String(error?.message??error),stack:error?.stack};process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,throws:report.throws,observation:report.observation,error:report.error}));
