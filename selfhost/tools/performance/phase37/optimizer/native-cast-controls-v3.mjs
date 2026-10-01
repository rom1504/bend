// Version3 accepts the corrected DataView derivation; all original checks remain.
// Untimed mechanism controls. Root supplies external CPU/memory/deadline bounds.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [derivedArg, pointsArg, outArg] = process.argv.slice(2);
assert(derivedArg && pointsArg && outArg, 'Usage: native-cast-controls.mjs DERIVED POINTS_V1 NEW_OUT');
const derived = fs.realpathSync(derivedArg), out = path.resolve(outArg);
assert(!fs.existsSync(out)); fs.mkdirSync(out);
const identity = file => ({path:fs.realpathSync(file), sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex'), bytes:fs.statSync(file).size});
const manifestFile = path.join(derived,'derive.json'), manifest = JSON.parse(fs.readFileSync(manifestFile));
assert(['phase37-private-native-cast-prototype','phase37-private-native-cast-dataview-prototype'].includes(manifest.kind)); assert.equal(manifest.complete,true);
const inputs = [identity(import.meta.filename),identity(manifestFile),identity(pointsArg)];
const variants = ['original','direct'], modules = [];
for (const variant of variants) {
  const row = manifest.modules.find(row => row.variant === variant && row.counters);
  assert(row); const actual = identity(row.path); assert.deepEqual(actual,{path:row.path,sha256:row.sha256,bytes:row.bytes});
  inputs.push(actual); modules.push(await import(pathToFileURL(row.path)));
}
const proposal = JSON.parse(fs.readFileSync(pointsArg));
assert.equal(proposal.kind,'phase37-application-point-proposal');
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const report = {kind:'phase37-private-native-cast-controls',complete:false,pass:false,inputs,
  scope:'Untimed exact outputs, boundary events and private-entry witnesses; no compiler admission claim.',oracles:[],boundaries:[],admission:[]};
function normalize(value) {
  if (value === undefined) return {undefined:true};
  if (typeof value === 'bigint') return {bigint:String(value)};
  if (typeof value === 'number' && (!Number.isFinite(value) || Object.is(value,-0))) return {number:String(value),negativeZero:Object.is(value,-0)};
  return value;
}
function snapshot(m) {
  const rows = manifest.dependencies.map(name => {
    const gd=Object.getOwnPropertyDescriptor(m.G,name),f=gd.value,c=f.code,b=f.bound;
    return {name,gd,objects:[[f,Object.getOwnPropertyDescriptors(f)],[c,Object.getOwnPropertyDescriptors(c)],[b,Object.getOwnPropertyDescriptors(b)]]};
  });
  return () => { for(const row of rows) { for(const [object,descriptors] of row.objects) {
    for(const key of Reflect.ownKeys(object)) if(!Object.hasOwn(descriptors,key)) delete object[key];
    Object.defineProperties(object,descriptors);
  } Object.defineProperty(m.G,row.name,row.gd); } };
}
function observe(m, action) {
  const restore=snapshot(m),events=[]; let value,error; const before=m.privateCastCounts();
  try { value=action(m,events); } catch(e) { error={name:e.name,message:e.message}; }
  finally { restore(); }
  const after=m.privateCastCounts();
  return {value:normalize(value),error,events,privateCalls:after.calls-before.calls,argumentReads:after.arguments-before.arguments};
}
function boundary(name,action,{live=false,refuse=true}={}) {
  const observations=modules.map(m=>observe(m,action));report.current={name,observations};
  const comparable = row => ({value:row.value,error:row.error,events:row.events});
  assert.deepEqual(comparable(observations[1]),comparable(observations[0]),name);
  if(live) assert(observations[0].events.length>0,'inactive witness: '+name);
  if(refuse) assert.equal(observations[1].privateCalls,0,'private call despite refusal: '+name);
  report.boundaries.push(report.current);delete report.current;
}
function hook(object,key,descriptor,run) {
  const previous=Object.getOwnPropertyDescriptor(object,key);
  try { Object.defineProperty(object,key,{configurable:true,...descriptor});return run(); }
  finally { if(previous)Object.defineProperty(object,key,previous);else delete object[key]; }
}
const ordinary = m => m.default.bench(4,17);
const force = (m,x) => m.call({arity:0,code:()=>x,env:null,bound:[]},[]);
const pointRows = [...proposal.validationPoints.filter(row=>row.family==='numeric-recurrence'),
  ...proposal.cases.filter(row=>row.family==='numeric-recurrence').map(row=>row.point)];
try {
  for(const row of pointRows) {
    const results=modules.map(m=>m.default.bench(...row.args));
    for(const value of results)assert.equal(value,row.expected);
    report.oracles.push({kind:'independent-recurrence',args:row.args,expected:row.expected,results});
  }
  // Literal table is independent of the generated native ternary. Include raw
  // noncanonical doubles to verify fallback as well as actual binary32 values.
  const castCases = [[NaN,0],[Infinity,0],[-Infinity,0],[0,0],[-0,0],[-1,0],[-0.5,0],
    [Number.MIN_VALUE,0],[Math.fround(2**-149),0],[0.5,0],[1,1],[Math.fround(1.9),1],[1.9,1],
    [255.75,255],[16777216,16777216],[4294967040,4294967040],[4294967295,4294967295],
    [4294967296,0],[Math.fround(4294967295),0],[4294967297,0],[Math.fround(2**64),0]];
  for(const [input,expected] of castCases) {
    const results=[];
    for(const m of modules) {const before=m.privateCastCounts();const value=m.privateCastPoint(input),after=m.privateCastCounts();
      assert.equal(value,expected);assert.equal(after.arguments-before.arguments,1,'cast expression must be evaluated once');results.push(value);}
    report.oracles.push({kind:'native-cast-boundary',input:normalize(input),expected,results});
  }
  for(const [n,seed] of [[0,0],[1,17],[7,123]]) {
    const m=modules[1],before=m.privateCastCounts();m.default.bench(n,seed);const after=m.privateCastCounts();
    assert.equal(after.calls-before.calls,n,'one private cast per real loop iteration');
    report.admission.push({kind:'real-loop-casts',n,seed,calls:after.calls-before.calls});
  }
  for(const mode of ['code','code-getter','binding-getter','arity','bound','env','own-call']) boundary('native:'+mode,(m,e)=>{
    const f=m.G['F32.to_u32'],code=f.code;
    if(mode==='code')f.code=function(a){e.push('native-code');return Reflect.apply(code,this,[a]);};
    if(mode==='code-getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push('native-code-getter');return code;}});
    if(mode==='binding-getter')Object.defineProperty(m.G,'F32.to_u32',{configurable:true,get(){e.push('native-binding');return f;}});
    if(mode==='arity'){f.arity=2;e.push('changed-arity');}
    if(mode==='bound'){f.bound.push(1.25);e.push('changed-bound');}
    if(mode==='env'){Object.defineProperty(f,'env',{configurable:true,get(){e.push('native-env');return null;}});}
    if(mode==='own-call'){code.call=function(env,a){e.push('native-own-call');return Reflect.apply(code,env,[a]);};}
    return ordinary(m);
  },{live:true});
  for(const [owner,key] of [[Math,'trunc'],[Math,'fround'],[Math,'imul'],[Number,'isFinite'],[Number,'isNaN'],[Number,'isInteger']])
    for(const mode of ['wrap','getter','throw','reentry','mutation']) boundary('host:'+key+':'+mode,(m,e)=>{
      const original=owner[key];let entered=false;
      const wrapped=function(...args){e.push(key);if(mode==='throw')throw Error('host '+key+' sentinel');
        if(mode==='reentry'&&!entered){entered=true;e.push(['nested',m.default.bench(1,7)]);}
        if(mode==='mutation'&&!entered){entered=true;const f=m.G['F32.to_u32'],code=f.code;
          f.code=function(a){e.push('mutated-native');return Reflect.apply(code,this,[a]);};}
        return Reflect.apply(original,this,args);};
      return hook(owner,key,mode==='getter'?{get(){e.push('get:'+key);return original;}}:{value:wrapped},()=>
        ['isNaN','isInteger'].includes(key)?m.privateCastPoint(key==='isNaN'?NaN:1.25):ordinary(m));
    },{live:!['isNaN','isInteger'].includes(key)});
  // Direct public native behavior is unchanged, including nonscalar values.
  for(const value of [null,undefined,'1',true,{},Object(3)]) boundary('public-native:'+String(value),m=>m.call(m.G['F32.to_u32'],[value]));
  for(const mode of ['raw','forged','new','partial','oversaturated','slot0','slot1','slot-mutation','slot-reentry','slot-throw']) boundary('root:'+mode,(m,e)=>{
    const f=m.G.bench,code=f.code;
    if(mode==='partial')return m.call(m.call(f,[4]),[17]);
    if(mode==='oversaturated')return m.call(f,[4,17,0]);
    const args={length:2,0:4,1:17}; const slot=mode==='slot1'?'1':'0';
    Object.defineProperty(args,slot,{get(){e.push('slot:'+slot);
      if(mode==='slot-throw')throw Error('slot sentinel');
      if(mode==='slot-mutation'){const native=m.G['F32.to_u32'],old=native.code;native.code=function(a){e.push('slot-native');return Reflect.apply(old,this,[a]);};}
      if(mode==='slot-reentry')e.push(['nested',force(m,Reflect.apply(code,null,[[1,7]]))]);
      return slot==='0'?4:17;}});
    if(mode==='raw'||mode==='forged')return force(m,Reflect.apply(code,null,[args,mode==='forged']));
    if(mode==='new')return force(m,Reflect.construct(code,[args]));
    return m.call(f,{slice(){e.push('slice');return args;}});
  },{refuse:false});
  for(const expected of inputs)assert.deepEqual(identity(expected.path),expected);
  report.complete=true;report.pass=true;
} catch(error) {report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,admission:report.admission.length,error:report.error}));
