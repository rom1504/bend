// ROOT ONLY. Independent saved-output dependency predicate and ordinary-entry
// controls; this is not compiler qualification or a timing artifact.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [directory,resultFile]=process.argv.slice(2),dir=path.resolve(directory);
const manifest=JSON.parse(fs.readFileSync(path.join(dir,'manifest.json')));
const hash=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
assert(manifest.complete&&manifest.diagnosticOnly&&!manifest.productionSafe);
for(const item of [...manifest.inputs,...Object.values(manifest.audit),manifest.auditController])assert.equal(hash(item.path),item.sha256);
const report={kind:'phase48-entry-allocation-free-audit',complete:false,pass:false,
  diagnosticOnly:true,sourceQualified:false,manifestSha256:hash(path.join(dir,'manifest.json')),
  ordinary:[],mutations:[],fallback:[]};
try{
  assert.equal(manifest.entryKind,'root','This bounded oracle uses an ordinary local-fold root');
  const modules={};
  for(const role of ['original','allocation-free'])modules[role]=await import(pathToFileURL(manifest.audit[role].path));
  for(const [role,module] of Object.entries(modules)){
    const a=module.$P48Audit;assert.deepEqual(a.names,manifest.guardNames);assert.equal(a.proof(),null);
    assert(a.host()&&a.original()&&a.candidate());
    for(const point of manifest.points){
      assert.equal(hash(point.config.path),point.config.sha256);
      const config=JSON.parse(fs.readFileSync(point.config.path));a.reset();
      const value=module.default[config.exportName](...config.args);
      assert.equal(value,config.expected);assert.equal(a.entries(),1);assert.equal(a.proof(),null);
      report.ordinary.push({role,args:config.args,value,entries:a.entries()});
    }
    // The changed function is used only behind a fresh host proof. Mutations
    // below keep that proof true and compare the full dependency predicates.
    for(const name of a.names){
      const f=a.G[name],code=f.code;
      const descriptor=(object,key,make)=>{
        const old=Object.getOwnPropertyDescriptor(object,key);
        Object.defineProperty(object,key,{configurable:true,...make(old)});
        return ()=>{if(old)Object.defineProperty(object,key,old);else delete object[key];};
      };
      const tests=[
        ['binding',()=>descriptor(a.G,name,()=>({value:{}}))],
        ['code',()=>descriptor(f,'code',()=>({value:()=>0}))],
        ['code-getter',()=>descriptor(f,'code',()=>({get(){getterCalls++;return code;}}))],
        ['arity',()=>descriptor(f,'arity',old=>({value:old.value+1}))],
        ['env',()=>descriptor(f,'env',()=>({value:{}}))],
        ['bound',()=>descriptor(f,'bound',()=>({value:[]}))],
        ['bound-length',()=>{const old=f.bound.length;f.bound.length=1;return ()=>{f.bound.length=old;};}],
        ['source-prototype',()=>{const old=Object.getPrototypeOf(f);Object.setPrototypeOf(f,{});return ()=>Object.setPrototypeOf(f,old);}],
        ['source-io-getter',()=>descriptor(f,'io',()=>({get(){getterCalls++;return false;}}))],
        ['source-type-getter',()=>descriptor(f,'typeName',()=>({get(){getterCalls++;return 'x';}}))],
        ['code-call-getter',()=>descriptor(code,'call',()=>({get(){getterCalls++;return Function.prototype.call;}}))],
        ['code-prototype',()=>{const old=Object.getPrototypeOf(code);Object.setPrototypeOf(code,{});return ()=>Object.setPrototypeOf(code,old);}]
      ];
      let getterCalls=0;
      for(const [kind,mutate] of tests){
        getterCalls=0;const restore=mutate();let host,original,candidate;
        try{host=a.host();original=a.original();candidate=a.candidate();}finally{restore();}
        assert.equal(host,true);assert.equal(original,false);assert.equal(candidate,original);assert.equal(getterCalls,0);
        assert.equal(a.proof(),null);assert(a.original()&&a.candidate());
        report.mutations.push({role,name,kind,host,original,candidate,getterCalls});
      }
    }
    // A native body mutation must leave raw admission and execute the old path.
    // Restore inside the hook, reenter the ordinary root, then throw outwards.
    const f=a.G['Array.new'];assert(f);
    for(const reentry of [false,true]){
      const old=Object.getOwnPropertyDescriptor(f,'code'),sentinel=new Error('p48-source-sentinel');
      let calls=0,nested=null;a.reset();
      Object.defineProperty(f,'code',{...old,value:function(){
        calls++;Object.defineProperty(f,'code',old);
        if(reentry)nested=module.default.bench(128,0);
        throw sentinel;
      }});
      try{assert.throws(()=>module.default.bench(128,17),error=>error===sentinel);}
      finally{Object.defineProperty(f,'code',old);}
      assert.equal(calls,1);assert.equal(nested,reentry?0:null);assert.equal(a.entries(),reentry?1:0);
      assert.equal(a.proof(),null);assert(a.original()&&a.candidate());
      report.fallback.push({role,reentry,calls,nested,rawEntries:a.entries(),originalError:true});
    }
  }
  assert.equal(report.ordinary.length,manifest.points.length*2);
  assert.equal(report.mutations.length,manifest.guardNames.length*12*2);
  assert.equal(report.fallback.length,4);
  report.complete=true;report.pass=true;
}catch(error){report.error=String(error?.stack??error);process.exitCode=1;}
fs.writeFileSync(resultFile,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,ordinary:report.ordinary.length,
  mutations:report.mutations.length,fallback:report.fallback.length,error:report.error}));
