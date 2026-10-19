// Malformed private-buffer graphs remain ordinary-verifier accepted; the worker
// gate must refuse them before any target execution. No malformed graph is run.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('Usage: runtime-safe-controls.mjs API FRESH_OUT');
const api=(await import(pathToFileURL(path.resolve(apiFile)).href)).default;
fs.mkdirSync(outDir);
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const l={$:'N111U64'},w={$:'N111U32'},ptr={$:'N111Ptr'};
const local=name=>({$:'N111Local',name}),word=lo=>({$:'N111Const',lo,hi:0});
const arg=(typ,value)=>({$:'N111Arg',typ,value});
const state=()=>arg(ptr,local('state')),scratch=()=>arg(ptr,local('scratch'));
const call=(name,symbol,args)=>({$:'N111Call',name,typ:l,symbol,args:list(args)});
const ret=name=>({$:'N111Return',value:local(name)});
const store=(i,value)=>({$:'N111Store',typ:l,base:local('scratch'),offset:8*i,value});
const alloc={$:'N111Alloca',name:'scratch',bytes:2048,align:8};
const get=(name,i)=>call(name,'p111_rt_reg_get',[state(),arg(w,word(i))]);
const jump=(name,vs)=>[...vs.map((v,i)=>store(i,v)),call('reply','p111_rt_jump',[state(),arg(w,{$:'N111FuncId',name}),scratch(),arg(w,word(vs.length))]),ret('reply')];
const result=value=>[store(0,value),call('reply','p111_rt_return',[state(),scratch(),arg(w,word(1))]),ret('reply')];
const seg=(name,body)=>({$:'N111Segment',name,arity:2,result:1,incoming:0,flags:0,body:list([alloc,get('a',0),get('b',1),...body])});
const p=s=>({$:'P111Program',segments:list([{$:'N111Segment',name:'main',arity:0,result:1,incoming:0,flags:0,
  body:list([alloc,...jump(s.name,[word(1),word(2)])])},s]),
  constructors:list([{$:'N_Constructor',name:'Con',arity:2,hot:true}]),show:list([0]),show_names:list([]),effects:list([]),pure:true});
const cases=[
  ['primitive-input',buffer=>call('out','p111_rt_op',[state(),arg(w,word(1)),buffer,arg(w,word(2))])],
  ['constructor-input',buffer=>call('out','p111_rt_ctor',[state(),arg(w,{$:'N111CtorId',name:'Con'}),buffer,arg(w,word(2))])],
  ['constructor-take-output',buffer=>call('out','p111_rt_take',[state(),arg(l,local('a')),buffer,arg(w,word(2))])],
  ['special-take-output',buffer=>call('out','p111_rt_special_take',[state(),arg(w,word(4)),arg(l,local('a')),buffer,arg(w,word(1))])],
];
const controls=[],direct=typeof api.p112w_index==='function';
for(const [name,make] of cases){
  for(const safe of [false,true]){
    const op=make(safe?scratch():state()),init=[store(0,local('a')),store(1,local('b'))];
    const loop=seg('loop',[...init,op,...jump('loop',[local('a'),local('b')])]);
    const program=p(loop);assert.equal(api.p111_verify_program(program),'',name);
    assert.equal(api.p112t_admitted(api.p112t_plan(loop)),safe,name+': loop');
    const fail=[...init,op,call('reply','p111_rt_fail',[state(),arg(w,word(4))]),ret('reply')];
    const side=seg('side',[{$:'N111Bin',name:'condition',typ:l,op:'eq',left:local('a'),right:word(0)},
      {$:'N111If',condition:local('condition'),yes:list(jump('side',[local('a'),local('b')])),no:list(fail)}]);
    assert.equal(api.p111_verify_program(p(side)),'');
    assert.equal(api.p112t_admitted(api.p112t_plan(side)),safe,name+': side exit');
    if(direct){
      const leaf=seg('leaf',[...init,op,...result(local('a'))]),lp=p(leaf);
      assert.equal(api.p111_verify_program(lp),'');
      assert.equal(api.p112w_admitted(api.p112w_plan(leaf,api.p112w_index(lp.segments))),safe,name+': direct');
    }
    controls.push({name,buffer:safe?'scratch':'state',originalValid:true,loopAdmitted:safe,sideExitAdmitted:safe,
      directChecked:direct,directAdmitted:direct?safe:null,targetsExecuted:false});
  }
}
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-runtime-buffer-controls',complete:true,directChecked:direct,controls},null,2)+'\n');
console.log(JSON.stringify({complete:true,controls:controls.length,directChecked:direct}));
