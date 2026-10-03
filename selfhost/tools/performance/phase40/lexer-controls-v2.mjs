// Independent BigInt arithmetic/token oracle; no timing or compiler claim.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [baseArg,outArg]=process.argv.slice(2);assert(baseArg&&outArg);const base=path.resolve(baseArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=p=>({path:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const manifestFile=path.join(base,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));assert.equal(manifest.kind,'phase40-manual-lexer');assert.equal(manifest.complete,true);
const variants=['original','guard','class','step','complete'],modules=[];for(const variant of variants){const row=manifest.modules.find(m=>m.variant===variant&&m.counters);assert.deepEqual(identity(row.path),{path:row.path,sha256:row.sha256});modules.push(await import(pathToFileURL(row.path)));}
fs.mkdirSync(out,{recursive:false});fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const report={kind:'phase40-manual-lexer-controls-v2',complete:false,pass:false,inputs:[import.meta.filename,manifestFile,...manifest.modules.filter(m=>variants.includes(m.variant)&&m.counters).map(m=>m.path)].map(identity),variants,oracle:[],boundaries:[],admission:[]};
const u=x=>Number(BigInt.asUintN(32,BigInt(x))),mul=(a,b)=>u(BigInt(a)*BigInt(b)),xor=(a,b)=>u(BigInt(a)^BigInt(b));
const mix=(a,k,x)=>xor(mul(a,2654435761),u(BigInt(k)*40503n+BigInt(x))),fnv=(h,c)=>mul(xor(h,c),16777619);
function state(mode,payload,c,acc){let kind=c>=97&&c<=122?'letter':c>=48&&c<=57?'digit':c===32?'space':'punct',next,out=acc;
 if(mode==='InId'&&kind==='letter')return {mode:'InId',payload:fnv(payload,c),acc};
 if(mode==='InNm'&&kind==='digit')return {mode:'InNm',payload:u(BigInt(payload)*10n+BigInt(c)-48n),acc};
 if(mode!=='Gap')out=mix(acc,mode==='InId'?1:2,payload);
 if(kind==='letter')next=['InId',fnv(2166136261,c)];else if(kind==='digit')next=['InNm',u(BigInt(c)-48n)];else {next=['Gap',null];if(kind==='punct')out=mix(out,3,c);}
 return {mode:next[0],payload:next[1],acc:out};}
function canon(r){assert(Array.isArray(r));assert.equal(r.length,2);const m=r[0];assert(['Gap','InId','InNm'].includes(m.$));assert.equal(m.a.length,m.$==='Gap'?0:1);return {mode:m.$,payload:m.$==='Gap'?null:m.a[0],acc:r[1]};}
function traceModel(s){let current={mode:'Gap',payload:null,acc:0};const trace=[];for(const ch of s){const c=ch.codePointAt(0);current=state(current.mode,current.payload,c,current.acc);trace.push({c,mode:{$:current.mode,a:current.mode==='Gap'?[]:[current.payload]},acc:current.acc,tuple:true});}
 return {trace,value:current.mode==='Gap'?current.acc:mix(current.acc,current.mode==='InId'?1:2,current.payload)};}
function tokenModel(s){const cps=Array.from(s,ch=>ch.codePointAt(0));let acc=0;for(let i=0;i<cps.length;){const c=cps[i];if(c===32){i++;continue;}
 if(c>=97&&c<=122){let h=2166136261;do{h=fnv(h,cps[i++]);}while(i<cps.length&&cps[i]>=97&&cps[i]<=122);acc=mix(acc,1,h);}
 else if(c>=48&&c<=57){let n=0;do{n=u(BigInt(n)*10n+BigInt(cps[i++])-48n);}while(i<cps.length&&cps[i]>=48&&cps[i]<=57);acc=mix(acc,2,n);}
 else {acc=mix(acc,3,c);i++;}}return acc;}
function prng(x){x=xor(x,u(BigInt(x)<<13n));x=xor(x,BigInt(x)>>17n);return xor(x,u(BigInt(x)<<5n));}
function lineModel(i){const seed=prng(mul(u(BigInt(i)+1n),2654435761)),tpl='i = ( n o i ) o ( n o i ) o ( n o i ) ;';let result='';
 for(let k=0;k<tpl.length;k++){const c=tpl[k],t=prng(xor(seed,mul(k,2654435761)));if(c==='i'||c==='n'){const length=c==='i'?1+(t&7):1+t%6;let v=t;for(let j=0;j<length;j++){v=prng(v);result+=String.fromCodePoint((c==='i'?97:48)+(v%(c==='i'?26:10)));}}
 else if(c==='o')result+='+-*/'[t&3];else result+=c;}return tokenModel(result);}
function benchModel(d,seed){let sum=0;for(let i=0;i<2**d;i++)sum=u(BigInt(sum)+BigInt(lineModel(u(BigInt(seed)+BigInt(i)))));return sum;}
function snapshot(m){const rows=manifest.dependencies.map(name=>{const gd=Object.getOwnPropertyDescriptor(m.G,name),f=gd.value;return {name,gd,f,d:Object.getOwnPropertyDescriptors(f),c:f.code,cd:Object.getOwnPropertyDescriptors(f.code),b:f.bound,bd:Object.getOwnPropertyDescriptors(f.bound)};});
 return()=>{for(const r of rows){for(const [o,d]of[[r.f,r.d],[r.c,r.cd],[r.b,r.bd]]){for(const k of Reflect.ownKeys(o))if(!Object.hasOwn(d,k))delete o[k];Object.defineProperties(o,d);}Object.defineProperty(m.G,r.name,r.gd);}};}
function normalize(x){if(typeof x==='bigint')return x+'n';if(x===undefined)return '[undefined]';if(x===null||typeof x!=='object')return x;return Array.isArray(x)?x.map(normalize):Object.fromEntries(Object.entries(x).map(([k,v])=>[k,normalize(v)]));}
function observe(m,action){const restore=snapshot(m),events=[];let value,error;try{value=action(m,events);}catch(e){error={name:e.name,message:e.message};}finally{restore();}return {value:normalize(value),error,events};}
function boundary(name,action){const observations=modules.map(m=>observe(m,action));report.current={name,observations};for(const o of observations.slice(1))assert.deepEqual(o,observations[0],name);report.boundaries.push(report.current);delete report.current;return observations;}
function mutate(m,e,name,kind){const f=m.G[name],old=f.code;if(kind==='binding')Object.defineProperty(m.G,name,{configurable:true,get(){e.push('binding:'+name);return f;}});else if(kind==='getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push('code:'+name);return old;}});else f.code=function(a){e.push('invoke:'+name);return Reflect.apply(old,this,[a]);};}
function hook(o,k,desc,action){const old=Object.getOwnPropertyDescriptor(o,k);try{Object.defineProperty(o,k,{configurable:true,...desc});return action();}finally{if(old)Object.defineProperty(o,k,old);else delete o[k];}}
try{
 for(const mode of ['Gap','InId','InNm'])for(const payload of [0,17,4294967295])for(const c of [0,32,47,48,57,58,96,97,122,123,65535,128512,4294967295])for(const acc of [0,17,4294967295]){
  const expected=state(mode,mode==='Gap'?null:payload,c,acc),results=modules.map(m=>canon(m.privateStep(mode,payload,c,acc)));for(const r of results)assert.deepEqual(r,expected);
  report.oracle.push({kind:'full-transition',mode,payload,c,acc,expected,results});}
 const strings=['',' ','abc','123','a1b2','abc + 123;','0 42949672959999999',' ABC\tZ\n','😃x9💩','\ud800a\udfff9','a'.repeat(300),'1234567890'.repeat(50)];
 for(const s of strings){const expected=traceModel(s);assert.equal(expected.value,tokenModel(s));const results=modules.map(m=>m.privateTrace(s));for(const r of results)assert.deepEqual(r,expected);const values=modules.map(m=>m.privateLex(s));for(const v of values)assert.equal(v,expected.value);report.oracle.push({kind:'complete-mode-tuple-trace',input:s,expected,results,values});}
 for(const d of [0,1,3,6])for(const seed of [0,17,4294967295]){const expected=benchModel(d,seed),results=modules.map(m=>m.privateBench(d,seed));for(const r of results)assert.equal(r,expected);report.oracle.push({kind:'independent-generated-lines',d,seed,expected,results});}
 for(let i=1;i<modules.length;i++){const m=modules[i],before=m.privateCounts();m.privateBench(1,17);const after=m.privateCounts();assert(after.root>before.root);if(variants[i]==='class')assert(after.cls>before.cls);if(['step','complete'].includes(variants[i]))assert(after.step>before.step);if(variants[i]==='complete')assert(after.lex>before.lex);report.admission.push({variant:variants[i],before,after});}
 for(const name of manifest.dependencies)for(const kind of ['wrap','getter','binding']){
  const observations=boundary(name+':'+kind,(m,e)=>{mutate(m,e,name,kind);const before=m.privateCounts(),value=m.privateBench(1,17),after=m.privateCounts();assert.deepEqual(after,before);return value;});
  // Require actual invocation/getter observation for the selected lexer path.
  // Other dependency mutations remain refusal observations, without a live-path claim.
  if(['gen','cls','step','lex','flush'].includes(name))for(const o of observations)assert(o.events.length>0,'inactive lexer dependency witness:'+name+':'+kind);
 }
 for(const name of ['gen','step','flush'])for(const kind of ['throw','reentry'])boundary(name+':'+kind,(m,e)=>{const f=m.G[name],old=f.code;let busy=false;f.code=function(a){e.push(name);if(kind==='throw')throw Error(name+' sentinel');if(!busy){busy=true;e.push(['nested',m.privateBench(0,7)]);}return Reflect.apply(old,this,[a]);};return m.privateBench(1,17);});
 for(const key of ['codePointAt','slice'])for(const kind of ['wrap','getter','throw'])boundary('String:'+key+':'+kind,(m,e)=>{const old=String.prototype[key];let n=0;const f=function(...a){n++;if(kind==='throw')throw Error(key+' sentinel');return Reflect.apply(old,this,a);};let value;try{value=hook(String.prototype,key,kind==='getter'?{get(){n++;return old;}}:{value:f},()=>m.privateBench(1,17));}finally{e.push(['calls',n]);}return value;});
 for(const key of ['request','bounce','build','code'])boundary('String:marker:'+key,(m,e)=>{let n=0;const value=hook(String.prototype,key,{get(){n++;return undefined;}},()=>m.privateBench(1,17));e.push(['calls',n]);return value;});
 for(const key of ['push','pop','slice','concat'])boundary('Array:'+key,(m,e)=>{const old=Array.prototype[key];let n=0;const value=hook(Array.prototype,key,{value:function(...a){n++;return Reflect.apply(old,this,a);}},()=>m.privateBench(1,17));e.push(['calls',n]);return value;});
 for(const key of ['request','bounce','build','code'])boundary('Object:marker:'+key,(m,e)=>{let n=0;const value=hook(Object.prototype,key,{get(){n++;return undefined;}},()=>m.privateBench(1,17));e.push(['calls',n]);return value;});
 for(const kind of ['deferred','mode-error','acc-error']){const observations=boundary('foreign-gen:'+kind,(m,e)=>{m.G.gen={arity:3,code(){e.push('gen');return 'a';},env:null,bound:[]};m.G.step.code=function(a){e.push('step');return {build:true,name:'Tuple',fields:[()=>{e.push('mode');if(kind==='mode-error')throw Error('mode sentinel');return {$:'Gap',a:[]};},()=>{e.push('acc');if(kind==='acc-error')throw Error('acc sentinel');return 17;}]};};return m.privateBench(0,7);});for(const o of observations){assert.deepEqual(o.events,kind==='mode-error'?['gen','step','mode']:['gen','step','mode','acc']);if(kind!=='deferred')assert.equal(o.error?.message,kind==='mode-error'?'mode sentinel':'acc sentinel');}}
 for(const m of modules)assert.equal(m.privateActive(),false);
 const m=modules.at(-1),input='a'.repeat(100000),expected=tokenModel(input),value=m.privateLex(input);assert.equal(value,expected);assert.equal(m.privateActive(),false);report.oracle.push({kind:'deep-line-stack',characters:input.length,expected,value});
 for(const row of report.inputs)assert.deepEqual(identity(row.path),row);report.complete=true;report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracle:report.oracle.length,boundaries:report.boundaries.length,error:report.error}));
