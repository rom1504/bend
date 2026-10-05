// Root-only bounded compiler-predicate controls. No recursive payload executes.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [beforeDir,afterDir,outDir]=process.argv.slice(2);
assert(outDir,'array-native-rejection-controls-v2.mjs EAGER_ATTEMPT LAZY_ATTEMPT NEW_OUT');
const out=path.resolve(outDir);fs.mkdirSync(out);
const report={kind:'phase48-array-native-rejection-controls-v2',complete:false,pass:false,inputs:[],roles:[],
  scope:'Internal typed-predicate regression. A diagnostic wnf sentinel stops before recursive source payload reduction. Checked source acquisition/runtime oracles are separate; no OOM or timing attribution.'};
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {path:file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
function pin(file,want){const x=identity(file);if(want)assert.equal(x.sha256,want.sha256);report.inputs.push(x);return x;}
const overlay=String.raw`
// Saved-API diagnostic: reject normalization of the one exact live AST object.
const $p48NativeOldWnf=$wnf$;
let $p48NativePayload=null,$p48NativeVisits=0;
const $p48NativeSentinel=new Error('live argument reached native element normalization');
$wnf$=function(book,t){if(t===$p48NativePayload){$p48NativeVisits++;throw $p48NativeSentinel;}return $p48NativeOldWnf(book,t);};
export function phase48NativeRejections(){
  const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
  const kt=(tag,name='',kids=[],id=0,quant=1)=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:nil,originBegin:0,originEnd:0});
  const lit=(kind,number)=>({$:'KLiteral',kind,number,text:'',originBegin:0,originEnd:0});
  const all=(type,body,id,quant=1)=>kt('All','',[type,body],id,quant),adt=(name,kids=[])=>kt('ADT',name,kids);
  const data=kt('Typ','',[kt('Qua','',[],0,2)]),type=kt('Typ','',[kt('Qua','',[],0,1)]);
  const def=(name,kind,arity,typ,value=kt('Absent'),native=true,ctors=[])=>({$:'KDef',name,kind,arity,templates:0,typ,value,ctors:list(ctors),native,unsafe:false});
  const owner=(name,names)=>def(name,'ADT',0,data,kt('Absent'),true,names.map((n,i)=>def(n,'Ctr',i,data)));
  const primitive=[owner('U32',['U32']),owner('F32',['F32']),owner('Bool',['False','True']),owner('Nat',['Zero','Succ']),
    owner('Word.Nil',['WNil']),owner('Word.Con',['WCon']),def('Word','Def',1,type),owner('Array',['ALeaf','ANode'])];
  const element=kt('Var','',[],500),newType=all(data,all(adt('Nat'),all(element,adt('Array',[element]),502),501),500,0);
  const nativeNew=def('Array.new','Def',3,newType),nativeGet=def('Array.get','Def',3,newType);
  const ordinary=def('ordinary.consume','Def',1,all(adt('U32'),adt('U32'),700),kt('Absent'),false);
  const userGet=def('Array.get','Def',3,all(adt('U32'),adt('U32'),700),kt('Absent'),false);
  const nativeLive=def('Array.new','Def',3,all(adt('U32'),adt('U32'),700));
  // This is the live fern.dp(12n, seed) AST in the companion source. Global
  // binder IDs are deliberately local to this direct predicate unit control.
  const payload=kt('App','',[kt('App','',[kt('Ref','fern.dp'),lit('Nat',12)]),kt('Var','',[],701)]);
  const call=(name,args)=>kt('Call',name,args),book=extra=>list([...extra,...primitive]);
  const trials=[
    ['ordinary-live-call',()=>run_loop($j_array_effect_native$(book([ordinary]),call('ordinary.consume',[payload])))],
    ['same-named-user-call',()=>run_loop($j_array_effect_native$(book([userGet]),call('Array.get',[payload,lit('U32',0),lit('U32',0)])))],
    ['wrong-call-arity',()=>run_loop($j_array_effect_native$(book([nativeNew]),call('Array.new',[payload])))],
    ['native-live-telescope',()=>run_loop($j_array_effect_native$(book([nativeLive]),call('Array.new',[payload,lit('U32',0),lit('U32',0)])))],
    ['unrelated-type-child',()=>run_loop($j_array_effect_array$(book([]),adt('Other',[payload])))],
    ['unrelated-array-of-child',()=>run_loop($j_array_effect_array_of$(book([]),adt('Other',[payload]),'U32'))]
  ],negative=[];
  for(const [name,run]of trials){$p48NativePayload=payload;$p48NativeVisits=0;let value,blocked=false;
    try{value=run();}catch(error){if(error!==$p48NativeSentinel)throw error;blocked=true;}
    finally{$p48NativePayload=null;}
    negative.push({name,value,blocked,normalizationVisits:$p48NativeVisits});}
  const positive=[];
  for(const elementName of ['U32','F32']){const b=book([nativeNew]),t=adt(elementName),a=adt('Array',[t]);
    positive.push({element:elementName,array:run_loop($j_array_effect_array$(b,a)),arrayOf:run_loop($j_array_effect_array_of$(b,a,elementName)),
      nativeNew:run_loop($j_array_effect_native$(b,call('Array.new',[t,lit('Nat',2),lit(elementName,0)])))});}
  return {negative,positive};
}
`;
try{
  pin(import.meta.filename);pin(process.execPath);
  const catalogFile=pin(path.join(import.meta.dirname,'array-native-rejection-catalog-v1.json'));
  const catalog=JSON.parse(fs.readFileSync(catalogFile.path,'utf8'));
  pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source);
  fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  for(const [i,dir]of [beforeDir,afterDir].entries()){
    const attemptId=pin(path.join(dir,'attempt.json')),attempt=JSON.parse(fs.readFileSync(attemptId.path,'utf8'));
    assert.equal(attempt.checked,true);assert.equal(attempt.artifactKind,'derived-b1');
    const api=pin(attempt.api.file??attempt.api.canonicalPath,attempt.api);
    const runtime=pin(attempt.runtime.file??attempt.runtime.canonicalPath,attempt.runtime);
    const base=pin(attempt.base.file??attempt.base.canonicalPath,attempt.base);
    const text=fs.readFileSync(api.path,'utf8');assert(!text.includes('$p48Native'));
    for(const name of ['wnf','j_array_effect_native','j_array_effect_array','j_array_effect_array_of'])
      assert.equal(text.split('function $'+name+'$(').length,2,'unique API function '+name);
    const derived=path.join(out,(i?'candidate':'historical')+'-predicate.mjs');
    fs.writeFileSync(derived,text+overlay,{flag:'wx'});const derivative=identity(derived);
    const module=await import(pathToFileURL(derived));const observations=module.phase48NativeRejections();
    for(const row of observations.positive)assert.deepEqual(row,{element:row.element,array:true,arrayOf:true,nativeNew:true});
    if(i){for(const row of observations.negative)assert.deepEqual(row,{name:row.name,value:false,blocked:false,normalizationVisits:0});}
    else{for(const row of observations.negative){assert.equal(row.blocked,true);assert.equal(row.normalizationVisits,1);}}
    report.roles.push({role:i?'candidate':'historical-eager',attempt:attemptId,api,runtime,base,derivative,observations});
  }
  assert.equal(report.roles[0].base.sha256,report.roles[1].base.sha256);
  for(const item of report.inputs)assert.deepEqual(identity(item.path),item);
  for(const role of report.roles)assert.deepEqual(identity(role.derivative.path),role.derivative);
  report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,roles:report.roles.length,error:report.error}));
