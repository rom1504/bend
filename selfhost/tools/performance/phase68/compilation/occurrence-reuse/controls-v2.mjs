// Root-only Products10 checked-B1 controls. Preserve product target/call metadata; no algorithm rewrite.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [proposalArg,baselineArg,candidateArg,outArg]=process.argv.slice(2);
const out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const inputs=new Map();
const pin=x=>{const want=typeof x==='string'?null:x,file=fs.realpathSync(want?.file??x),b=fs.readFileSync(file),p={file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};if(want){assert.equal(p.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(p.bytes,want.bytes);}inputs.set(file,p);return p;};
const read=x=>JSON.parse(fs.readFileSync(pin(x).file,'utf8'));
const report={kind:'phase68-local-occurrence-reuse-controls-v2',complete:false,pass:false,images:[],rows:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const nil=()=>({$:'Nil'}),list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil());
const term=(tag,id=0,kids=[],name='')=>({$:'KTerm',tag,name,id,quant:2,kids:list(kids),removed:nil(),originBegin:0,originEnd:0});
const variable=(id,kids=[])=>term('Var',id,kids),word=()=>term('NWord',0,[],'7');
const binding=(id,word)=>({$:'NC_Binding',id,word});
try{
  report.method=pin(import.meta.filename);report.proposal=pin(proposalArg);
  const proposal=read(proposalArg);assert.equal(proposal.version,2);pin(proposal.patch);pin(proposal.parent);pin(proposal.producer);for(const p of proposal.inputs)pin(p);assert.deepEqual(pin(baselineArg),pin(proposal.baselineAttempt));const apis={},inventories={};
  for(const [role,file] of [['baseline',baselineArg],['candidate',candidateArg]]){
    const attemptPin=pin(file),attempt=read(file);assert(attempt.checked&&attempt.config.strictExact&&attempt.artifactKind==='derived-b1');
    for(const row of attempt.snapshot.sources)pin(row.frozen);
    const changed=new Set(proposal.files.map(f=>f.path.replace(/^selfhost\//,'')));
    inventories[role]=attempt.snapshot.sources.map(row=>({path:path.relative(attempt.snapshot.root,row.frozen.file),sha256:row.frozen.sha256})).filter(row=>!changed.has(row.path)).sort((a,b)=>a.path.localeCompare(b.path));
    for(const key of ['base','runtime','node','checkedApi','bootstrapReport','derivationReport'])pin(attempt[key]);
    for(const f of proposal.files){const row=attempt.snapshot.sources.find(x=>x.frozen.file.endsWith('/'+f.path.replace(/^selfhost\//,'')));assert(row);assert.equal(pin(row.frozen).sha256,pin(f[role==='baseline'?'before':'after']).sha256);}
    const original=pin(attempt.api),source=fs.readFileSync(original.file,'utf8');
    const fns={atom:['nc_let_atom',6],emitted:['nc_let_emitted',6],cut:['nc_let_cut',6],bind:['nf_bind_boxed',7],lower:['nc_lower_to',5],liveLower:['nc_lower_live_to',5],live:['nc_live_env',2],partition:['nc_partition_uses',2],uses:['nc_uses',1]};
    const wrappers=Object.entries(fns).map(([key,[name,n]])=>{assert.equal(source.split('\n').filter(x=>x.startsWith('function $'+name+'$(')).length,1);const args=Array.from({length:n},(_,i)=>'a'+i).join(',');return JSON.stringify(key)+':run_lib(('+args+')=>run_loop($'+name+'$('+args+')),'+n+')';});
    const append='\n// P68-012 exact original module prefix plus diagnostic exports.\n'+
      'const p68OriginalUses=$nc_uses$;let p68Body=null,p68Value=null,p68Counts={body:0,value:0,total:0};\n'+
      '$nc_uses$=function(t){p68Counts.total++;if(t===p68Body)p68Counts.body++;if(t===p68Value)p68Counts.value++;return p68OriginalUses(t);};\n'+
      'export const p68={'+wrappers.join(',')+',reset:(body,value)=>{p68Body=body;p68Value=value;p68Counts={body:0,value:0,total:0};},counts:()=>({...p68Counts})};\n';
    const derived=path.join(out,role+'-observed.mjs');fs.writeFileSync(derived,source+append,{flag:'wx'});assert.equal(fs.readFileSync(derived,'utf8').slice(0,source.length),source);
    const module=await import(pathToFileURL(derived));assert.equal(module.G,undefined);apis[role]=module.p68;
    report.images.push({role,attempt:attemptPin,api:original,derived:pin(derived),append});
  }
  assert.deepEqual(inventories.candidate,inventories.baseline,'Only the two declared source files may differ.');
  const envs=[[],[binding(0,'zero')],[binding(1,'one'),binding(2,'two'),binding(1,'duplicate'),binding(1,'one')],[binding(2147483648,'high'),binding(4294967295,'last')]];
  const ids=[0,1,2,2147483648,4294967295];
  const bodies=[word(),variable(1),variable(2),variable(4294967295),variable(1,[variable(2)]),term('Ann',0,[variable(1),variable(2)]),term('Unknown'),term('NSeqLet',0,[term('Bind',3,[variable(1)]),variable(3)])];
  const values=[word(),variable(1),variable(2),variable(4294967295),term('Unknown'),term('NSeqLet',0,[term('Bind',4,[variable(1)]),variable(4)])];
  const target={$:'NC_Destination',words:list(['result']),shape:term('Absent'),join:'done',owner:'owner',params:nil(),tail:false,signatures:nil()};
  const book=nil();let total=0,bodyReduced=0,valueReduced=0;
  for(const rows of envs)for(const id of ids)for(const body of bodies)for(const value of values){
    const env=list(rows),before=JSON.stringify({env,body,value});
    const kinds=['cut','bind','emitted',...(['Var','NWord'].includes(value.tag)?['atom']:[])];
    for(const kind of kinds){
      const args=kind==='bind'?[book,value,body,env,id,9,target]:kind==='emitted'?[book,value,body,env,id,{$:'N_Emitted',code:'/* value */\n',value:'7ull',fresh:9}]:[book,value,body,env,id,9];
      const observations={};for(const [role,api] of Object.entries(apis)){api.reset(body,value);observations[role]={result:api[kind](...args),counts:api.counts()};}
      assert.deepEqual(observations.candidate.result,observations.baseline.result,JSON.stringify({kind,id,body,value,rows}));
      const a=observations.baseline.counts,b=observations.candidate.counts;
      assert(b.body<=a.body&&b.value<=a.value);bodyReduced+=b.body<a.body?1:0;valueReduced+=b.value<a.value?1:0;total++;
      report.rows.push({kind,id,body:body.tag,value:value.tag,envRows:rows.length,baseline:a,candidate:b,pass:true});
    }
    assert.equal(JSON.stringify({env,body,value}),before);
    for(const api of Object.values(apis)){
      const live=api.live(env,value),uses=api.uses(value);
      assert.deepEqual(api.partition(live,uses),{$:'NC_EnvPartition',live,drop:''});
      assert.deepEqual(api.lower(book,value,live,9,target),api.liveLower(book,value,live,9,target));
    }
  }
  // Product-era metadata is part of whole-result equality, including nonempty call edges.
  const callee={$:'KDef',name:'callee',kind:'Def',arity:0,templates:0,typ:term('Typ'),value:word(),ctors:nil(),native:false,unsafe:false};
  const callBook=list([callee]),call=()=>term('NFCall',0,[],'callee');
  const productRows=[
    {name:'call-value',value:call(),body:variable(3),env:nil(),target},
    {name:'call-body',value:word(),body:call(),env:nil(),target},
    {name:'two-calls',value:call(),body:call(),env:nil(),target},
    {name:'bundle-result',value:word(),body:term('NQBundle',0,[variable(1),variable(2)],'Tuple'),env:list([binding(1,'one'),binding(2,'two')]),target:{...target,words:list(['pair0','pair1']),shape:term('NQShape',2,[],'Tuple')}}
  ];
  for(const row of productRows){
    const before=JSON.stringify(row),observations={};
    for(const [role,api] of Object.entries(apis))observations[role]=api.bind(callBook,row.value,row.body,row.env,3,9,row.target);
    assert.deepEqual(observations.candidate,observations.baseline,row.name);
    assert.equal(observations.candidate.error,'');
    if(row.name==='bundle-result'){
      assert(observations.candidate.body.includes('pair0 = one;')&&observations.candidate.body.includes('pair1 = two;'));
    }else{
      assert.equal(observations.candidate.calls.$,'Con');
      assert.equal(observations.candidate.calls.head,'callee');
    }
    assert.equal(JSON.stringify(row),before);
    report.rows.push({productCase:row.name,calls:observations.candidate.calls,pass:true});
  }
  assert(bodyReduced>0&&valueReduced>0);
  for(const p of [...inputs.values()])pin(p);
  report.summary={fullLoweringPairs:total,productPairs:productRows.length,bodyReduced,valueReduced,sourceFiles:2,newTypes:0,newFunctions:0};
  report.complete=true;report.pass=true;report.inputsUnchanged=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
report.inputs=[...inputs.values()];save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,summary:report.summary,error:report.error}));
