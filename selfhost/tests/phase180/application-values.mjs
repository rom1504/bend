// Finite complete-value observations. Algorithms run only in checked Bend APIs.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';
import {expand,compact,clone,exact,fingerprint} from './representation-oracle.mjs';

const opts={};
for(let i=2;i<process.argv.length;i+=2){
  need(['--baseline','--candidate','--out'].includes(process.argv[i])&&process.argv[i+1],'expected --baseline/--candidate/--out values');
  const key=process.argv[i].slice(2);need(!Object.hasOwn(opts,key),'duplicate option');opts[key]=process.argv[i+1];
}
need(opts.baseline&&opts.candidate&&opts.out,'baseline, candidate and fresh out required');
const out=path.resolve(opts.out),build=path.join(workspace,'selfhost/build');
need(out.startsWith(build+path.sep)&&!fs.existsSync(out),'fresh output under selfhost/build required');
fs.mkdirSync(out,{recursive:true});
const report={kind:'phase180-application-complete-values',complete:false,
  inputs:[pin(fileURLToPath(import.meta.url)),pin(fileURLToPath(new URL('./representation-oracle.mjs',import.meta.url))),pin(process.execPath),pin(path.join(workspace,'selfhost/tools/build/hosted.mjs'))],
  rows:[],bounds:{rows:2000,objectsPerWalk:2000000,edgesPerWalk:8000000,oldCases:20},
  scope:'Finite complete values, literal expectations, raw and compact inputs, retained aliases. Structural expansion only; no host implementation of compiler semantics or unrestricted correctness claim.'};
const apis={};
const nil=()=>({$:'Nil'}),con=(head,tail)=>({$:'Con',head,tail});
const list=xs=>xs.reduceRight((tail,head)=>con(head,tail),nil());
const term=(tag,name='',id=0,quant=0,kids=[],removed=[],originBegin=0,originEnd=0)=>
  ({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list(removed),originBegin,originEnd});
const variable=(id,begin=0,end=0)=>term('Var','v'+id,id,0,[],[],begin,end);
const reference=(name,begin=0,end=0)=>term('Ref',name,0,0,[],[],begin,end);
const application=(fn,arg,begin=0,end=0)=>term('App','',0,0,[fn,arg],[],begin,end);
const lambda=(id,body,present=false)=>({$:'KLambda',name:'b'+id,id,quant:1,kids:list([body]),removed:nil(),originBegin:3,originEnd:9,quantityPresent:present});
const literal=(number=99,begin=901,end=902)=>({$:'KLiteral',kind:'U32',number,text:'payload',originBegin:begin,originEnd:end});
const absent=()=>term('Absent');
function row(value){need(report.rows.length<report.bounds.rows,'finite row bound');report.rows.push(value);}
function rejects(action,message){let failed=false;try{action();}catch{failed=true;}need(failed,message);}
function call(name,method,args,expected){
  for(const mode of ['raw','compact']){
    const left=clone(args),right=mode==='compact'?compact(args):clone(args);
    const leftHash=fingerprint(left),rightHash=fingerprint(right);
    const a=apis.baseline[method](...left),b=apis.candidate[method](...right);
    need(fingerprint(left)===leftHash,'baseline mutated retained inputs: '+name);
    need(fingerprint(right)===rightHash,'candidate mutated retained inputs: '+name);
    const projectedA=expand(a),projectedB=expand(b);
    let pairs=exact(projectedA,projectedB);
    if(expected!==undefined)pairs+=exact(projectedA,expected)+exact(projectedB,expected);
    row({name:name+'-'+mode,method,inputSha256:leftHash,candidateInputSha256:rightHash,
      outputSha256:fingerprint(projectedB),pairs,literal:expected!==undefined,exact:true});
  }
}
function oracleControls(){
  const shared=literal(),input={left:{$:'KApply',function:shared,argument:shared,originBegin:17,originEnd:23}};
  input.right=input.left;
  input.lambda=lambda(19,shared,true);
  input.metadata={enabled:false,zero:0,negativeZero:-0,missing:undefined,empty:null};
  const saved=fingerprint(input),value=expand(input);
  need(value.left===value.right&&value.left.kids.head===value.left.kids.tail.head,'projection lost aliases');
  exact(value.left,application(shared,shared,17,23));need(fingerprint(input)===saved,'projection mutated input');
  const pending=[{value,path:[]}],seen=new WeakSet();let objects=0,mutations=0;
  while(pending.length){
    const item=pending.pop();if(item.value===null||typeof item.value!=='object'||seen.has(item.value))continue;
    seen.add(item.value);need(++objects<1000,'finite mutation inventory');
    for(const key of Object.keys(item.value)){
      const copy=clone(value);let owner=copy;for(const step of item.path)owner=owner[step];
      delete owner[key];rejects(()=>exact(value,copy),'comparator ignored removed key');mutations++;
      const child=item.value[key];
      if(child!==null&&typeof child==='object')pending.push({value:child,path:[...item.path,key]});
      else{
        const changed=clone(value);let at=changed;for(const step of item.path)at=at[step];
        at[key]=typeof child==='number'?child+1:typeof child==='boolean'?!child:String(child)+'!';
        rejects(()=>exact(value,changed),'comparator ignored changed scalar');mutations++;
      }
    }
  }
  rejects(()=>exact(value,{...value,unexpected:0}),'comparator ignored added key');mutations++;
  for(const key of Object.keys(input.left)){
    const bad=clone(input.left);delete bad[key];
    // Removing the discriminant makes this an ordinary record; exact still
    // rejects it. All other missing KApply fields must fail projection itself.
    if(key==='$')rejects(()=>exact(expand(input.left),expand(bad)),'lost discriminant accepted');
    else rejects(()=>expand(bad),'missing compact field accepted');
  }
  rejects(()=>expand({...input.left,extra:0}),'extra compact key ignored');
  rejects(()=>expand({...input.left,originBegin:-1}),'invalid compact span accepted');
  row({name:'independent-oracle-key-scalar-alias-controls',objects,mutations,exact:true,inputSha256:saved});
}

try{
  oracleControls();
  const required=['subst','subst_node','app','kid','ks','tg','nm','ix','qt','rm','kb','ke','k_with_span','k_with_children','k_rebuild','core_apply_span','core_subst_stable','f_pattern_value','f_span_created','env_subst_term','p177sv_cases','p177sv_value','p177sv_actual','p177sv_expected','p177sv_node_actual','p177sv_node_expected','p175fv_actual','p175fv_expected'];
  for(const role of ['baseline','candidate']){
    const file=path.resolve(opts[role]),receipt=JSON.parse(fs.readFileSync(file,'utf8'));
    need(receipt.complete&&receipt.checked&&receipt.kind==='bend-checked-hosted-api','checked API receipt required');
    need(Array.isArray(receipt.inputs)&&receipt.api&&receipt.source,'incomplete API provenance');
    report.inputs.push(pin(file),receipt.api,receipt.source,...receipt.inputs);report.inputs.forEach(verify);
    const url=pathToFileURL(receipt.api.file);url.searchParams.set('phase180sha',receipt.api.sha256);
    apis[role]=(await import(url)).default;
    for(const name of required)need(typeof apis[role]?.[name]==='function','missing '+role+' export '+name);
  }
  for(const role of ['baseline','candidate'])for(const [actual,expected] of [
    ['p177sv_actual','p177sv_expected'],['p177sv_node_actual','p177sv_node_expected'],['p175fv_actual','p175fv_expected']]){
    const a=expand(apis[role][actual]()),e=expand(apis.baseline[expected]());
    row({name:role+'-'+actual+'-literal',pairs:exact(a,e)+exact(expand(apis[role][expected]()),e),outputSha256:fingerprint(a),exact:true,literal:true});
  }
  const cases=[];let cursor=apis.baseline.p177sv_cases();
  while(cursor?.$==='Con'){need(cases.length<20,'bounded old case list');cases.push(cursor.head);cursor=cursor.tail;}
  need(cursor?.$==='Nil'&&cases.length===20,'literal case inventory');report.caseSha256=fingerprint(cases);
  for(const [i,c] of cases.entries()){
    call('old-literal-'+i,'subst',[c.input,c.id,c.value],c.expected);
    for(const id of [0,7,8,4294967295])for(const [j,value] of [c.value,c.input,apis.baseline.p177sv_value()].entries())
      call(`old-differential-${i}-${id}-${j}`,'subst',[c.input,id,value]);
    call('old-node-'+i,'subst_node',[c.input,c.id,c.value]);
  }

  const v=literal(),x=reference('x',43,44),f=reference('f',1,2),v7=variable(7,51,53),v8=variable(8,61,63);
  const targets=[
    ['neutral-span',application(f,v7,30,31),7,v,application(f,v,30,31)],
    ['replacement-function-beta',application(v7,x,30,31),7,lambda(8,v8),x],
    ['function-beta-restores',application(application(lambda(8,f),x,11,14),v7,10,20),7,v,application(f,v,10,20)],
    ['argument-beta-restores',term('Ctr','Pair',4,2,[application(lambda(8,v8),x,3,4),v7],['keep'],1,70),7,v,term('Ctr','Pair',4,2,[x,v],['keep'],1,70)],
    ['nested-beta-restores',application(application(lambda(8,v8),lambda(9,variable(9)),11,14),v7,10,20),7,v,v],
    ['replacement-opaque',v7,7,application(lambda(8,v8),x,99,100),application(lambda(8,v8),x,99,100)],
    ['nonmatching-var-opaque',term('Var','stored',8,2,[v7],['keep'],8,20),7,v,term('Var','stored',8,2,[v7],['keep'],8,20)],
  ];
  report.targetSha256=fingerprint(targets);
  for(const [name,input,id,value,expected] of targets)call(name,'subst',[input,id,value],expected);
  call('node-variable-stored-children','subst_node',[term('Var','stored',7,2,[v7],['keep'],8,20),7,v],term('Var','stored',7,2,[v],['keep'],8,20));
  const a=application(f,x,17,23);
  for(const [method,expected] of [['tg','App'],['nm',''],['ix',0],['qt',0],['ks',list([f,x])],['rm',nil()],['kb',17],['ke',23]])call('accessor-'+method,method,[a],expected);
  for(const [n,expected] of [[0,f],[1,x],[2,absent()],[4294967295,absent()]])call('kid-'+n,'kid',[a,n],expected);
  call('app-constructor','app',[f,x],application(f,x));
  call('span-replacement','k_with_span',[a,0xffffffff,0],application(f,x,0xffffffff,0));
  for(const kids of [[],[v],[x,v],[x,v,f]])call('children-'+kids.length,'k_with_children',[a,list(kids)],term('App','',0,0,kids,[],17,23));
  const rebuilds=[['',0,0,[x,v],[]],['named',0,0,[x,v],[]],['',37,0,[x,v],[]],['',0,1,[x,v],[]],['',0,2,[x,v],[]],['',0,0,[x,v],['keep']],['',0,0,[],[]],['',0,0,[x],[]],['',0,0,[x,v,f],[]]];
  for(const [i,[name,id,quant,kids,removed]] of rebuilds.entries())call('rebuild-'+i,'k_rebuild',[a,name,id,quant,list(kids),list(removed),31,47],term('App',name,id,quant,kids,removed,31,47));
  call('apply-neutral','core_apply_span',[f,x,33,39],application(f,x,33,39));
  call('apply-beta','core_apply_span',[lambda(8,v8),x,33,39],x);
  for(const [i,input,expected] of [[0,a,true],[1,application(f,v7),false],[2,application(lambda(8,v),x),false],[3,application(a,v),true]])call('stable-'+i,'core_subst_stable',[input],expected);

  const unlocated=application(reference('new'),x),located=application(reference('old'),x,10,12);
  call('span-created-boundary','f_span_created',[unlocated,20,30],application(reference('new',20,30),x,20,30));
  call('span-created-existing','f_span_created',[located,20,30],located);
  call('span-created-zero','f_span_created',[unlocated,0,30],unlocated);
  call('pattern-value-span','f_pattern_value',[unlocated,20,30],application(reference('new',20,30),reference('x',20,30),20,30));
  call('pattern-value-zero','f_pattern_value',[unlocated,0,30],unlocated);
  const binding=(id,value)=>({$:'KTelescopeBinding',id,value});
  call('env-substitution','env_subst_term',[application(f,v7,17,23),list([binding(7,v)])],application(f,v,17,23));
  call('env-substitution-chain','env_subst_term',[application(f,v7,17,23),list([binding(7,v8),binding(8,v)])],application(f,v,17,23));
  call('env-empty','env_subst_term',[application(f,v7,17,23),nil()],application(f,v7,17,23));
  const shared=application(f,v7,71,79),retained=term('Ctr','Shared',0,2,[shared,shared],['retained'],70,80);
  call('retained-aliases','subst',[retained,7,v],term('Ctr','Shared',0,2,[application(f,v,71,79),application(f,v,71,79)],['retained'],70,80));

  // Independent fixed-depth data; no evaluator in this construction loop.
  let deep=variable(7),deepExpected=v;
  for(let i=0;i<128;i++){deep=application(f,deep,i,i+1);deepExpected=application(f,deepExpected,i,i+1);}
  call('bounded-depth-128','subst',[deep,7,v],deepExpected);
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
