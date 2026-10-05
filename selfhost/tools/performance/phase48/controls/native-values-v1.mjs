// ROOT ONLY: actual checked-source String.append value and fallback controls.
// Usage: native-values-v1.mjs BASELINE CANDIDATE NEW_OUT
import fs from 'node:fs';import path from 'node:path';
import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,directory]=process.argv.slice(2),out=path.resolve(directory);
const identity=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase48-actual-native-string-append-controls',complete:false,pass:false,
  valueRows:[],ordinaryRows:[],boundaries:[],inputs:[],derivatives:{},timingEligible:false};
const marker='(/* private String.append */';
const sourceSha='1f502b3037f98f72437f729baefed38a568dca9322ea87e5909e903ca07cf505';
let catalogSha;
try{
  const node=identity(process.execPath);
  assert.equal(node.sha256,'41a74efb34cbde5c7632cdac0cf8bd1a14d0b8d73dc1e82755014d9a9ce70f5c');
  report.node={...node,version:process.version};
  report.inputs.push(identity(import.meta.filename),node);
  for(const [role,file] of [['baseline',baseline],['candidate',candidate]]){
    const receiptFile=file+'.json',receipt=JSON.parse(fs.readFileSync(receiptFile));
    assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');
    assert.equal(receipt.input.sha256,sourceSha,'Exact independent source is required');
    if(role==='baseline'){
      assert.equal(receipt.compiler.api.sha256,'28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f');
      assert.equal(receipt.compiler.runtime.sha256,'880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b');
      catalogSha=receipt.catalog.sha256;
    }else assert.equal(receipt.catalog.sha256,catalogSha,'Both acquisitions use the same catalog');
    const item=identity(file);assert.equal(item.sha256,receipt.output.sha256);
    report.inputs.push(item,identity(receiptFile));
    const catalog=identity(receipt.catalog.file??receipt.catalog.canonicalPath);
    assert.equal(catalog.sha256,receipt.catalog.sha256);report.inputs.push(catalog);
    for(const entry of [receipt.attempt,receipt.compiler.api,receipt.compiler.runtime,receipt.compiler.base,receipt.input]){
      const original=identity(entry.file??entry.canonicalPath);assert.equal(original.sha256,entry.sha256);report.inputs.push(original);
    }
    const source=fs.readFileSync(file,'utf8'),sites=source.split(marker).length-1;
    assert.equal(source.includes('$p48AppendCount'),false);
    if(role==='candidate')assert(sites>0,'Actual selected source must emit native String.append lowering');
    else assert.equal(sites,0,'Baseline must be the retained pre-native-values compiler');
    const observed='let $p48AppendCount=0;\n'+source.replaceAll(marker,marker+'$p48AppendCount++,')+
      '\nexport const $P48Native={count:()=>$p48AppendCount,reset:()=>{$p48AppendCount=0;},proof:()=>regionProof};\n';
    const target=path.join(out,role+'-counted.mjs');fs.writeFileSync(target,observed,{flag:'wx'});
    report.derivatives[role]={...identity(target),staticNativeAppendSites:sites};
  }
  const modules={};
  for(const role of ['baseline','candidate'])modules[role]=await import(pathToFileURL(report.derivatives[role].file));
  const plain=value=>JSON.parse(JSON.stringify(value));
  const observe=f=>{try{return {value:plain(f())};}catch(error){return {error:String(error?.message??error).replace(/^bend: /,'')};}};
  const seedText=seed=>String(seed>>>0)+'é';
  for(const [n,seed] of [[0,0],[1,0],[2,17],[3,0xffffffff],[16,123],[64,17],[4096,7]]){
    const expected='α🙂'.repeat(n)+seedText(seed).repeat(n),rows={};
    for(const [role,m] of Object.entries(modules)){
      m.$P48Native.reset();const value=m.default.bench(n,seed);assert.equal(value,expected);
      assert.equal(m.$P48Native.proof(),null);const count=m.$P48Native.count();
      if(role==='candidate'&&n>0)assert(count>0,'Ordinary independent root executes private native concat');
      if(role==='baseline')assert.equal(count,0);
      rows[role]={valueSha256:createHash('sha256').update(value).digest('hex'),codeUnits:value.length,nativeAppendEntries:count};
    }
    report.ordinaryRows.push({n,seed,rows});
  }
  const strings=['','a','b','é','e\u0301','α🙂','中','\0','a\0b','\ud800','\udc00','\ud800x','x\udc00','🙂\udc00'];
  for(const a of strings)for(const b of strings)for(const name of ['append','reversed','fork','selected-true','selected-false','pair','record']){
    const args=name.startsWith('selected')?[name==='selected-true',a,b]:[a,b],method=name.startsWith('selected')?'selected':name;
    const rows={};for(const [role,m] of Object.entries(modules))rows[role]=observe(()=>m.default[method](...args));
    assert.deepEqual(rows.candidate,rows.baseline,{name,a,b});
    if(['append','reversed','fork','selected-true','selected-false'].includes(name)){
      const expected=name==='append'||name==='selected-true'?a+b:name==='fork'?a+b+b+a:b+a;
      assert.deepEqual(rows.candidate,{value:expected});
    }
    if(name==='pair'||name==='record')for(const [role,m] of Object.entries(modules)){
      const expected=name==='pair'?m.ctor('Tuple',[a+b,b+a]):m.ctor('LabelBox',[a,b,a+b]);
      assert.deepEqual(rows[role],{value:plain(expected)});
    }
    report.valueRows.push({name,a,b,rows});
  }
  const boundary=(name,run,{refuse=true,reentry=false}={})=>{
    const rows={};for(const [role,m] of Object.entries(modules)){
      const events=[];m.$P48Native.reset();const outcome=observe(()=>run(m,events));
      const count=m.$P48Native.count();assert.equal(m.$P48Native.proof(),null);
      if(role==='candidate'&&refuse&&!reentry)assert.equal(count,0,name+' must retain generic fallback');
      rows[role]={outcome,events,nativeAppendEntries:count};
    }
    assert.deepEqual(rows.candidate.outcome,rows.baseline.outcome,name);
    assert.deepEqual(rows.candidate.events,rows.baseline.events,name);
    report.boundaries.push({name,rows});
  };
  const hook=(object,key,descriptor,run)=>{
    const old=Object.getOwnPropertyDescriptor(object,key);
    try{Object.defineProperty(object,key,{configurable:true,...descriptor});return run();}
    finally{if(old)Object.defineProperty(object,key,old);else delete object[key];}
  };
  for(const mode of ['code','code-getter','binding','binding-getter','env','bound','arity','code-call-getter'])boundary('native:'+mode,(m,e)=>{
    const f=m.G['String.append'],code=f.code;assert.equal(typeof code,'function');
    const call=()=>m.default.bench(2,17);
    if(mode==='code')return hook(f,'code',{value:function(a){e.push('code');return Reflect.apply(code,this,[a]);}},call);
    if(mode==='code-getter')return hook(f,'code',{get(){e.push('code-getter');return code;}},call);
    if(mode==='binding')return hook(m.G,'String.append',{value:{...f,code:function(a){e.push('binding');return Reflect.apply(code,this,[a]);}}},call);
    if(mode==='binding-getter')return hook(m.G,'String.append',{get(){e.push('binding-getter');return f;}},call);
    if(mode==='env')return hook(f,'env',{value:{changed:true}},call);
    if(mode==='bound')return hook(f,'bound',{value:['changed']},call);
    if(mode==='arity')return hook(f,'arity',{value:f.arity+1},call);
    return hook(code,'call',{get(){e.push('code-call-getter');return Function.prototype.call;}},call);
  });
  for(const mode of ['String-global','String-prototype','String-prototype-getter','Object-marker'])boundary('host:'+mode,(m,e)=>{
    const call=()=>m.default.bench(2,17);
    if(mode==='String-global'){const old=String;return hook(globalThis,'String',{value:function(x){e.push('String');return old(x);}},call);}
    if(mode==='String-prototype')return hook(String.prototype,'toString',{value:function(){e.push('toString');return 'foreign';}},call);
    if(mode==='String-prototype-getter')return hook(String.prototype,Symbol.toPrimitive,{get(){e.push('toPrimitive');return undefined;}},call);
    let nested=false;return hook(Object.prototype,'bounce',{get(){e.push('bounce');if(!nested){nested=true;e.push(['nested',m.default.bench(0,0)]);}return undefined;}},call);
  });
  boundary('native-error',(m,e)=>hook(m.G['String.append'],'code',{value:()=>{e.push('throw');throw Error('native append sentinel');}},()=>m.default.bench(2,17)));
  boundary('native-error-reentry',(m,e)=>{
    const f=m.G['String.append'],old=Object.getOwnPropertyDescriptor(f,'code');
    return hook(f,'code',{value:()=>{
      assert.equal(m.$P48Native.count(),0,'Outer root refused before original code callback');
      Object.defineProperty(f,'code',old);const nested=m.default.bench(2,7);
      e.push(['nested',nested]);throw Error('native reentry sentinel');
    }},()=>m.default.bench(2,17));
  },{reentry:true});
  boundary('partial-complete',(m)=>m.call(m.call(m.G.append,['🙂']),['é']),{refuse:false});
  for(const flag of [false,true])boundary('raw-code:'+flag,(m)=>{
    const value=Reflect.apply(m.G.append.code,null,[['🙂','é'],flag]);
    return m.call({arity:0,bound:[],env:null,code:()=>value},[]);
  });
  boundary('public-coercion-order',(m,e)=>m.default.append({[Symbol.toPrimitive](){e.push('left');return '🙂';}},{[Symbol.toPrimitive](){e.push('right');return 'é';}}));
  assert.equal(report.ordinaryRows.length,7);assert.equal(report.valueRows.length,14*14*7);assert.equal(report.boundaries.length,18);
  for(const item of report.inputs)assert.deepEqual(identity(item.file),item);
  for(const item of Object.values(report.derivatives)){
    const {staticNativeAppendSites,...expected}=item;assert.deepEqual(identity(item.file),expected);
  }
  report.complete=true;report.pass=true;
}catch(error){report.error=String(error?.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,ordinary:report.ordinaryRows.length,
  values:report.valueRows.length,boundaries:report.boundaries.length,error:report.error}));
