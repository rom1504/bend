// Semantic oracle only; parent orchestrator serializes execution. No timing.
import {spawnSync} from 'node:child_process';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
const cases=['canonical','Error-reentry','binding-replacement','binding-getter','code-replacement','code-getter','arity-getter','env-getter','bound-getter','bound-length','code-own-call','wrapper-io','primitive-bounce','object-bounce','array-bounce','array-every','array-iterator','array-numeric-setter','host-descriptor-getter','host-descriptor-replacement','view-own-method'];
if(process.argv[2]==='--worker'){
 const m=await import(pathToFileURL(resolve(process.argv[3])));const t=m.__p43;const name=process.argv[4];
 const descriptor=Object.getOwnPropertyDescriptor,define=Object.defineProperty,apply=Reflect.apply,push=Array.prototype.push;
 const trace=[];const log=x=>apply(push,trace,[x]);const undo=[];
 function change(o,k,d){const old=descriptor(o,k);define(o,k,d);undo[undo.length]=()=>old?define(o,k,old):delete o[k];}
 const sample=m.G.bench,code=sample.code;const keys=Object.keys(t.scalarSnapshots);const dep=keys.find(k=>k==='p37.list')||keys.find(k=>k==='bench')||keys[0];const f=m.G[dep],depcode=f.code;
 const original=m.default.bench(8,17);t.stats.fusion=0;let observed,guardBefore,guardAfter,proof;
 try{
  if(name==='Error-reentry'){
   const Error0=globalThis.Error;let covers=null,reentry=null;
   change(globalThis,'Error',{configurable:true,writable:true,value:function(message){covers=t.regionProofCovers([dep]);reentry=m.default.bench(0,0);return Error0(message);}});
   const previous=t.regionProofOpen([dep]);let caught;
   try{m.call({},[1]);}catch(e){caught=e.message;}
   proof={covers,reentry,caught,restored:t.regionProofCovers([dep])};t.regionProofClose(previous);
  }else if(name!=='canonical'){
   const getter=(key,value)=>({configurable:true,get(){log(key);return value;}});
   if(name.startsWith('host-hook-')){const pair=t.regionNumericHooks[Number(name.slice(10))];change(pair[0],pair[1],getter(name,pair[2]));}
   else if(name.startsWith('protocol-')){const pair=t.regionProtocolPairs[Number(name.slice(9))],old=descriptor(pair[0],pair[1]);change(pair[0],pair[1],getter(name,old?.value));}
   else switch(name){
    case 'binding-replacement':change(m.G,dep,{configurable:true,writable:true,value:{...f}});break;
    case 'binding-getter':change(m.G,dep,getter('G',f));break;
    case 'code-replacement':change(f,'code',{configurable:true,writable:true,value:function(a){log('code');return apply(depcode,this,[a]);}});break;
    case 'code-getter':change(f,'code',getter('code',f.code));break;
    case 'arity-getter':change(f,'arity',getter('arity',f.arity));break;
    case 'env-getter':change(f,'env',getter('env',f.env));break;
    case 'bound-getter':change(f,'bound',getter('bound',f.bound));break;
    case 'bound-length':change(f.bound,'length',{value:1,writable:true});break;
    case 'code-own-call':change(f.code,'call',{configurable:true,writable:true,value:function(...args){log('call');return apply(Function.prototype.call,this,args);}});break;
    case 'wrapper-io':change(f,'io',{configurable:true,get(){log('io');return false;}});break;
    case 'primitive-bounce':change(Number.prototype,'bounce',getter('number.bounce',false));break;
    case 'object-bounce':change(Object.prototype,'bounce',getter('object.bounce',false));break;
    case 'array-bounce':change(Array.prototype,'bounce',getter('array.bounce',false));break;
    case 'array-every':{const old=Array.prototype.every;change(Array.prototype,'every',{configurable:true,writable:true,value:function(...a){log('every');return apply(old,this,a);}});break;}
    case 'array-iterator':{const old=Array.prototype[Symbol.iterator];change(Array.prototype,Symbol.iterator,{configurable:true,writable:true,value:function(...a){log('iterator');return apply(old,this,a);}});break;}
    case 'array-numeric-setter':change(Array.prototype,'100000',{configurable:true,set(){log('setter');}});break;
    case 'host-descriptor-getter':change(Math,'imul',getter('imul',Math.imul));break;
    case 'host-descriptor-replacement':{const old=Math.imul;change(Math,'imul',{configurable:true,writable:true,value:function(...a){log('imul');return apply(old,this,a);}});break;}
    case 'view-own-method':change(t.floatView,'getFloat32',getter('view',t.floatView.getFloat32));break;
   }
  }
  guardBefore=t.regionHostGuard();try{observed={value:m.default.bench(8,17)};}catch(e){observed={error:e.message};}guardAfter=t.regionHostGuard();
 }finally{for(let i=undo.length-1;i>=0;i--)undo[i]();}
 const activation=t.stats.fusion;t.stats.fusion=0;const restored=m.default.bench(8,17);
 process.stdout.write(JSON.stringify({name,activation,original,observed,restored,guardBefore,guardAfter,trace,proof,proofClean:!t.regionProofCovers([dep])}));
}else{
 const dir=resolve(process.argv[2]);const report=[];
 const inventory=(await import(pathToFileURL(dir+'/control.oracle.mjs'))).__p43;
 for(let i=0;i<inventory.regionNumericHooks.length;i++)cases.push('host-hook-'+i);
 for(let i=0;i<inventory.regionProtocolPairs.length;i++)cases.push('protocol-'+i);
 for(const name of cases){const results=[];for(const role of ['control','candidate']){
  const r=spawnSync(process.execPath,[import.meta.filename,'--worker',dir+'/'+role+'.oracle.mjs',name],{encoding:'utf8',timeout:15000,maxBuffer:16*1024*1024});
  if(r.error||r.status!==0||!r.stdout?.trim())throw Error(JSON.stringify({role,name,error:r.error?.message,status:r.status,signal:r.signal,stderr:r.stderr,stdout:r.stdout}));
  try{results.push(JSON.parse(r.stdout));}catch(e){throw Error(JSON.stringify({role,name,parse:e.message,stdout:r.stdout,stderr:r.stderr}));}
 }
 const activations=results.map(r=>r.activation);
 const omitted=name==='view-own-method'||(name.startsWith('host-hook-')&&(()=>{const p=inventory.regionNumericHooks[Number(name.slice(10))];return (p[0]===Math&&p[1]!=='imul')||(p[0]===Number&&['isNaN','isFinite'].includes(p[1]))||['setUint32','getFloat32','setFloat32','getUint32'].includes(p[1]);})());
 if(omitted){if(activations[0]!==0||activations[1]===0)throw Error('unused numeric hook domain failed '+name);results.forEach(r=>delete r.activation);}
 const equal=JSON.stringify(results[0])===JSON.stringify(results[1]);if(!equal)throw Error('guard mismatch '+name+' '+JSON.stringify(results));
 if(name==='canonical'&&(!results[0].guardBefore||results[0].activation===0))throw Error('canonical host guard inactive');
 if(name!=='canonical'&&name!=='Error-reentry'&&results[0].guardBefore&&name.startsWith('host-'))throw Error('host mutation not refused');
 if(!results[0].proofClean)throw Error('proof leaked');report.push({name,equal,activations,omittedNumericHook:omitted,observation:results[0]});
 }
 console.log(JSON.stringify({complete:true,cases:report},null,2));
}
