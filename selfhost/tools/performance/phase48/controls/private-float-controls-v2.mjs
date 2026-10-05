// Root-only untimed production-source controls. Exact modules supply semantics;
// a separate counter derivative supplies executed finite-literal witnesses.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,destination]=process.argv.slice(2);assert(destination);
const out=path.resolve(destination);fs.mkdirSync(out);
const report={kind:'phase48-private-finite-f32-controls',complete:false,passed:false,inputs:[],oracles:[],boundaries:[],activation:[]};
const apply=Reflect.apply,define=Object.defineProperty,descriptor=Object.getOwnPropertyDescriptor;
const OriginalNumber=Number,OriginalMath=Math,OriginalError=Error,OriginalDataView=DataView;
const dvProto=DataView.prototype,set32=dvProto.setUint32,get32=dvProto.getUint32,setF=dvProto.setFloat32,getF=dvProto.getFloat32;
const round=OriginalMath.fround,isNaN=OriginalNumber.isNaN;
const oracleView=new OriginalDataView(new ArrayBuffer(4));
const bits=x=>{apply(setF,oracleView,[0,x,true]);return apply(get32,oracleView,[0,true]);};
const fromBits=x=>{apply(set32,oracleView,[0,x,true]);return apply(getF,oracleView,[0,true]);};
const tiny=fromBits(1),max=fromBits(0x7f7fffff);
const encode=x=>({kind:isNaN(x)?'NaN':Object.is(x,-0)?'-0':x===Infinity?'+Infinity':x===-Infinity?'-Infinity':'finite',value:OriginalNumber.isFinite(x)?x:null,bits:bits(x)});
const pins=new Map(),hash=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
function pin(file,want){file=fs.realpathSync(file);const id={path:file,sha256:hash(file)};if(want)assert.equal(id.sha256,want);if(pins.has(file))assert.equal(pins.get(file),id.sha256);else{pins.set(file,id.sha256);report.inputs.push(id);}return id;}
function audit(v){if(!v||typeof v!=='object')return;const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v.sha256);Object.values(v).forEach(audit);}
let serial=0;
const load=(file,label)=>import(pathToFileURL(fs.realpathSync(file)).href+'?control='+encodeURIComponent(label)+'-'+serial++);
function expected(root,n,x,v=1){for(let i=0;i<n;i++){
 if(root==='walk')x=round(round(x*1.25)+0.125);
 else if(root==='tiny')x=round(x+tiny);
 else if(root==='huge')x=round(x*max);
 else if(root==='negative_zero')x=-0;
 else if(root==='nonfinite')x=round(v/0);
 else throw Error(root);
}return x;}
const marker='/* private finite F32 */';
const error=e=>({name:e?.name??null,message:e?.message??String(e)});
function retain(m){let view;const old=descriptor(dvProto,'getFloat32');
 define(dvProto,'getFloat32',{...old,value:function(...args){view=this;return apply(getF,this,args);}});
 try{assert.equal(m.default.public_literal(),0.25);}finally{define(dvProto,'getFloat32',old);}
 assert(view instanceof OriginalDataView);return view;}
function scenario(m,name){const view=retain(m),events=[],restores=[];let value,thrown,sameSentinel=false;const sentinel=new OriginalError('finite F32 sentinel');let busy=false;
 const patch=(owner,key,replacement)=>{const old=descriptor(owner,key);restores.push(()=>old?define(owner,key,old):delete owner[key]);define(owner,key,{configurable:true,...replacement});};
 const wrapGet=function(...args){events.push(['get',...args]);if(name==='own-get-throw'||name==='prototype-get-throw')throw sentinel;
   if(name==='get-reentry'&&!busy){busy=true;events.push(['inner',encode(m.default.walk(0,-0))]);busy=false;}return apply(getF,this,args);};
 const wrapSet=function(...args){events.push(['set',...args]);if(name==='own-set-throw')throw sentinel;
   if(name==='set-reentry'&&!busy){busy=true;events.push(['inner',encode(m.default.walk(1,2))]);busy=false;}return apply(set32,this,args);};
 try{
  if(name.startsWith('own-get'))patch(view,'getFloat32',{writable:true,value:wrapGet});
  else if(name.startsWith('prototype-get')||name==='get-reentry')patch(dvProto,'getFloat32',{writable:true,value:wrapGet});
  else if(name.startsWith('own-set')||name==='set-reentry')patch(view,'setUint32',{writable:true,value:wrapSet});
  else if(name==='view-getter')patch(view,'getFloat32',{get(){events.push('getFloat32:getter');return wrapGet;}});
  else if(name==='fround-throw')patch(OriginalMath,'fround',{writable:true,value:function(x){events.push(['fround',encode(x)]);throw sentinel;}});
  else if(name==='fround-reentry')patch(OriginalMath,'fround',{writable:true,value:function(x){events.push(['fround',encode(x)]);if(!busy){busy=true;events.push(['inner',encode(m.default.walk(0,1))]);busy=false;}return round(x);}});
  else if(name==='Math-getter')patch(globalThis,'Math',{get(){events.push('Math:getter');return OriginalMath;}});
  else if(name==='Number-getter')patch(globalThis,'Number',{get(){events.push('Number:getter');return OriginalNumber;}});
  else if(name==='DataView-global')patch(globalThis,'DataView',{writable:true,value:function(){events.push('DataView:new');throw sentinel;}});
  else if(name==='detached')structuredClone(view.buffer,{transfer:[view.buffer]});
  else if(name==='zero-demand')apply(set32,view,[0,0x80000000,true]);
  else if(name!=='retained')throw Error(name);
  const n=name==='zero-demand'?0:2;
  value=encode(m.default.walk(n,-0));
  if(name==='zero-demand'){assert.equal(apply(get32,view,[0,true]),0x80000000);assert.equal(value.kind,'-0');}
  if(name==='retained'){assert.equal(apply(get32,view,[0,true]),0x3e000000,'last demanded literal is0.125');}
 }catch(e){thrown=error(e);sameSentinel=e===sentinel;}finally{for(const restore of restores.reverse())restore();}
 if(!['detached','own-get-throw','prototype-get-throw','own-set-throw','fround-throw'].includes(name))assert.equal(thrown,undefined,name+' must complete successfully');
 if(name==='detached'){assert(thrown);assert.equal(thrown.name,'TypeError');}
 if(['own-get-throw','prototype-get-throw','own-set-throw','fround-throw'].includes(name)){assert(thrown);assert(sameSentinel);}
 if(['own-get','prototype-get','own-set','view-getter','get-reentry','set-reentry'].includes(name))assert(events.length,'observable hook must execute');
 return {value,error:thrown,sameSentinel,events,viewBits:name==='detached'?null:apply(get32,view,[0,true])};
}
try{
 pin(import.meta.filename);pin(process.execPath);
 const catalogFile=path.join(import.meta.dirname,'private-float-catalog-v1.json');pin(catalogFile);
 const catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
 const source=catalog.cases[0].source;pin(path.join(import.meta.dirname,source.path),source.sha256);
 const modules=[],texts=[];
 for(const [role,file]of [['baseline',baseline],['candidate',candidate]]){
  const moduleId=pin(file);pin(file+'.json');const receipt=JSON.parse(fs.readFileSync(file+'.json','utf8'));
  assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');assert.equal(receipt.input.sha256,source.sha256);assert.equal(receipt.compiler.upstreamCommit,catalog.upstreamCommit);
  assert.equal(moduleId.sha256,receipt.output.sha256);assert.equal(fs.realpathSync(file),fs.realpathSync(receipt.output.canonicalPath??receipt.output.file));audit(receipt);
  texts.push(fs.readFileSync(file,'utf8'));const m=await load(file,role+'-values');modules.push(m);
  for(const root of ['walk','tiny','huge','negative_zero'])for(const n of [0,1,2,9])for(const x of [0,-0,tiny,-tiny,1,-1,max,-max,1/3,NaN,Infinity,-Infinity]){
   const value=m.default[root](n,x),want=expected(root,n,x);assert(Object.is(value,want),`${role}/${root}/${n}/${String(x)}`);
   report.oracles.push({role,root,n,input:encode(x),value:encode(value)});
  }
  for(const n of [0,1,3])for(const v of [0,-0,1,-1]){const value=m.default.nonfinite(n,2,v),want=expected('nonfinite',n,2,v);assert(Object.is(value,want));report.oracles.push({role,root:'nonfinite',n,input:encode(v),value:encode(value)});}
 }
 const cases=['retained','zero-demand','own-get','prototype-get','own-set','view-getter','own-get-throw','prototype-get-throw','own-set-throw','get-reentry','set-reentry','fround-throw','fround-reentry','Math-getter','Number-getter','DataView-global','detached'];
 for(const name of cases){const observations=[];for(const [role,file]of [['baseline',baseline],['candidate',candidate]])observations.push(scenario(await load(file,role+'-'+name),name));assert.deepEqual(observations[1],observations[0],name);report.boundaries.push({name,observations});}
 // Parse exact assignment ranges and each selected finite write. The source
 // frontend itself forbids nonfinite compact literals; runtime Inf/NaN above
 // is separate from the lower-level compiler's exponent255 refusal obligation.
 const ps=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};new Function('module','exports',ps)(pm,pm.exports);assert.equal(pm.exports.version,'8.16.0');
 const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
 function nodes(root){const out=[],todo=[root];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||!n.type)continue;out.push(n);for(const x of Object.values(n))if(Array.isArray(x))todo.push(...x);else if(x&&typeof x==='object')todo.push(x);}return out;}
 const text=texts[1],ast=nodes(parse(text)),edits=[],writes=[];
 for(const root of ['walk','tiny','huge','negative_zero','nonfinite']){
  const assignments=ast.filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.name==='G'&&n.left.property.value===root);assert.equal(assignments.length,1);
  const assignment=assignments[0],fragment=text.slice(assignment.start,assignment.end);assert(fragment.includes(marker),root+' must select finite literal lowering');
  const offsets=[];let at=fragment.indexOf(marker);while(at>=0){offsets.push(assignment.start+at);at=fragment.indexOf(marker,at+marker.length);}
  for(const offset of offsets){const call=ast.find(n=>n.type==='CallExpression'&&n.start>=offset+marker.length&&text.slice(offset+marker.length,n.start).trim()===''&&n.callee.type==='MemberExpression'&&n.callee.object.name==='floatView'&&n.callee.property.name==='setUint32');assert(call);
   assert.equal(call.arguments[0].value,0);assert.equal(call.arguments[2].value,true);const word=call.arguments[1].value;assert(Number.isInteger(word)&&word>=0&&word<=0xffffffff);assert.notEqual((word>>>23)&255,255);
   writes.push({root,bits:word});edits.push({at:offset+marker.length,text:`++$p48FiniteWrites[${JSON.stringify(root)}],`});
  }
 }
 const keys=['walk','tiny','huge','negative_zero','nonfinite'];let derived=text;for(const e of edits.sort((a,b)=>b.at-a.at))derived=derived.slice(0,e.at)+e.text+derived.slice(e.at);
 derived='const $p48FiniteWrites='+JSON.stringify(Object.fromEntries(keys.map(k=>[k,0])))+';\n'+derived+'\nexport const phase48FiniteWrites=()=>({...$p48FiniteWrites});\n';parse(derived);
 const file=path.join(out,'activation-only.mjs');fs.writeFileSync(file,derived,{flag:'wx'});pin(file);
 report.derivative={path:file,sha256:hash(file),diagnosticOnly:true,timingEligible:false,parserSha256:crypto.createHash('sha256').update(ps).digest('hex'),writes};
 const witness=await load(file,'activation');
 for(const root of keys){const before=witness.phase48FiniteWrites();witness.default[root](0,-0,...(root==='nonfinite'?[1]:[]));assert.deepEqual(witness.phase48FiniteWrites(),before,'zero-trip must not write literals');
  const got=witness.default[root](1,root==='huge'?1:0,...(root==='nonfinite'?[1]:[]));assert(Object.is(got,expected(root,1,root==='huge'?1:0,1)));const after=witness.phase48FiniteWrites();assert(after[root]>before[root],root+' executed selected finite writes');report.activation.push({root,before,after});}
 for(const name of ['own-get','own-set','view-getter','own-set-throw']){const dm=await load(file,'refusal-'+name),observation=scenario(dm,name);assert.equal(dm.phase48FiniteWrites().walk,0,name+' must retain generic literal path');assert.deepEqual(observation,report.boundaries.find(x=>x.name===name).observations[1]);report.activation.push({name,writes:dm.phase48FiniteWrites()});}
 for(const [file,want]of pins)assert.equal(hash(file),want,'consumed input changed');report.complete=report.passed=true;
}catch(e){report.error=e.stack??String(e);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,passed:report.passed,oracles:report.oracles.length,boundaries:report.boundaries.length,error:report.error}));
