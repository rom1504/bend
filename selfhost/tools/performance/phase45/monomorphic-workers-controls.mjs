// Untimed alias-only worker admission, values and supported-domain mutations.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,typescript,output]=process.argv.slice(2);
assert(output,'monomorphic-workers-controls.mjs BASELINE11 CANDIDATE13 TYPESCRIPT NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase45-monomorphic-worker-controls',complete:false,pass:false,inputs:[],modules:[],oracles:[],activation:[],boundaries:[],
  scope:'Independent monomorphic positive-arity graph; clean small three-role values, candidate deep50k, and observable post-import public helper mutation. No timing, arbitrary hostile-preimport, termination-proof or universal conformance claim.'};
const identity=p=>{const file=fs.realpathSync(p),bytes=fs.readFileSync(file);return {path:file,bytes:bytes.length,sha256:createHash('sha256').update(bytes).digest('hex')};};
const pinned=new Map();
function pin(file,want){const row=identity(file);if(want){assert.equal(row.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(row.bytes,want.bytes);}
  if(pinned.has(row.path))assert.deepEqual(row,pinned.get(row.path));else{pinned.set(row.path,row);report.inputs.push(row);}return row;}
function audit(v){if(Array.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){const file=v.path??v.file;if(file&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
const mask=0xffffffffn;
function oracle(name,n,seed){let value=BigInt(seed);
  if(name==='tail_check')return Number((value+8n*BigInt(Math.floor(n/2))+(n%2?15n:0n))&mask);
  const saved=[];for(let i=0;i<n;i++){saved.push(value);value=(value+BigInt(i%2?7:3))&mask;}
  if(n%2)value=(value+11n)&mask;
  for(let i=n-1;i>=0;i--)value=(i%2?value+saved[i]*9n:value*5n-saved[i])&mask;
  return Number(value);}
function observe(m,mode){const f=m.G.cedar,code=f.code,events=[],objects=[m.G,f,code];
  const saved=objects.map(o=>[o,Object.getOwnPropertyDescriptors(o)]);let value,error;
  try{
    if(mode==='global-getter')Object.defineProperty(m.G,'cedar',{configurable:true,get(){events.push('G');return f;}});
    for(const key of ['code','env','bound','arity'])if(mode===key+'-getter'){const old=f[key];Object.defineProperty(f,key,{configurable:true,get(){events.push(key);return old;}});}
    if(mode==='env-value')f.env={tag:'alias-env'};
    if(mode==='code-value')f.code=function(a){events.push('code');return Reflect.apply(code,this,[a]);};
    if(mode==='global-value')m.G.cedar={...f,code:function(a){events.push('replacement');return Reflect.apply(code,this,[a]);}};
    const call=function(receiver,a){events.push('call');return Reflect.apply(code,receiver,[a]);};
    if(mode==='own-call')Object.defineProperty(code,'call',{configurable:true,value:call});
    if(mode==='call-getter')Object.defineProperty(code,'call',{configurable:true,get(){events.push('get-call');return call;}});
    value=m.default.bench(3,7);
  }catch(e){error={name:e.name,message:e.message};}finally{
    for(const [o,descriptors]of saved){for(const key of Reflect.ownKeys(o))if(!Object.hasOwn(descriptors,key))delete o[key];Object.defineProperties(o,descriptors);}
  }return {value,error,events};}
try{
  pin(import.meta.filename);pin(process.execPath);
  const catalogFile=path.join(import.meta.dirname,'monomorphic-workers-catalog.json'),catalogId=pin(catalogFile),catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[],texts=[];
  for(const [i,file]of [baseline,candidate,typescript].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);assert.equal(emission.observation.checked,true);assert.equal(emission.observation.status,'ok');
    assert.equal(emission.input.sha256,source.sha256);assert.equal(emission.output.sha256,module.sha256);assert.equal(emission.catalog.sha256,catalogId.sha256);
    assert.equal(emission.compiler.kind,i===2?'checked-pinned-typescript':'checked-development-attempt');assert.equal(emission.compiler.upstreamCommit,catalog.upstreamCommit);audit(emission);
    report.modules.push({role:['baseline11','candidate13','typescript'][i],module,receipt,compiler:emission.compiler});
    texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  for(const row of catalog.cases){const p=row.point;for(const m of modules)assert.equal(m.default[p.exportName](...p.args),p.expected,row.id);}
  for(const name of ['bench','tail_check'])for(const n of [0,1,2,3,8,31,32,33,64])for(const seed of [0,7,4294967295]){
    const expected=oracle(name,n,seed),values=modules.map(m=>m.default[name](n,seed));for(const value of values)assert.equal(value,expected);
    report.oracles.push({name,n,seed,expected,values});}
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  function nodes(root){const pending=[root],result=[];while(pending.length){const n=pending.pop();if(!n||typeof n!=='object'||typeof n.type!=='string')continue;
    result.push(n);for(const v of Object.values(n))if(Array.isArray(v))pending.push(...v);else if(v&&typeof v==='object')pending.push(v);}return result;}
  function assignments(text,name){return nodes(parse(text)).filter(n=>n.type==='AssignmentExpression'&&n.operator==='='&&n.left.type==='MemberExpression'&&n.left.computed&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.property.type==='Literal'&&n.left.property.value===name);}
  const marker='/* private contextual instances */',edits=[];
  for(const name of ['bench','tail_check'])for(const i of [0,1]){const found=assignments(texts[i],name);assert.equal(found.length,1,name+' definition');
    const item=found[0],body=texts[i].slice(item.start,item.end),count=body.split(marker).length-1;assert.equal(count,i,name+' alias-only admission');
    if(i===1)edits.push({name,offset:item.start+body.indexOf(marker)+marker.length});}
  for(const name of ['plain_literal','U32.add']){const found=assignments(texts[1],name);assert(found.length>0,name+' definition');
    for(const item of found)assert(!texts[1].slice(item.start,item.end).includes(marker),name+' leaf remains excluded');}
  assert(!texts[1].includes('$p45Mono'),'Reserved diagnostic identifier');let derived=texts[1];
  for(const e of [...edits].sort((a,b)=>b.offset-a.offset))derived=derived.slice(0,e.offset)+'++$p45Mono['+JSON.stringify(e.name)+'];'+derived.slice(e.offset);
  derived='const $p45Mono={bench:0,tail_check:0};\n'+derived+'\nexport const p45MonoCounts=()=>({...$p45Mono});\n';parse(derived);
  const derivativeFile=path.join(out,'candidate-counter.mjs');fs.writeFileSync(derivativeFile,derived,{flag:'wx'});
  report.derivative={source:report.modules[1].module,module:identity(derivativeFile),edits,performanceEvidence:false,parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')}};
  const witness=await import(pathToFileURL(derivativeFile));assert.deepEqual(witness.p45MonoCounts(),{bench:0,tail_check:0});
  for(const name of ['bench','tail_check'])for(const n of [3,50000,3]){
    const expected=oracle(name,n,7),before=witness.p45MonoCounts(),value=modules[1].default[name](n,7),observed=witness.default[name](n,7),after=witness.p45MonoCounts();
    assert.equal(value,expected);assert.equal(observed,expected);assert.equal(after[name]-before[name],1);
    report.activation.push({name,n,expected,value,entries:1});}
  for(const mode of ['global-getter','code-getter','env-getter','bound-getter','arity-getter','env-value','code-value','global-value','own-call','call-getter']){
    const values=modules.slice(0,2).map(m=>observe(m,mode));report.current={mode,values};assert.deepEqual(values[1],values[0],mode);assert.equal(values[0].error,undefined,mode);
    assert.equal(values[0].value,oracle('bench',3,7));if(mode!=='env-value')assert(values[0].events.length,mode+' live hook');
    const before=witness.p45MonoCounts(),observed=observe(witness,mode),after=witness.p45MonoCounts();assert.deepEqual(observed,values[1],mode+' derivative');assert.deepEqual(after,before,mode+' contextual refusal');
    report.boundaries.push({...report.current,countsBefore:before,countsAfter:after});delete report.current;
  }
  for(const row of pinned.values())assert.deepEqual(identity(row.path),row,'Changed input');assert.deepEqual(identity(derivativeFile),report.derivative.module);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,activation:report.activation.length,boundaries:report.boundaries.length,error:report.error}));
