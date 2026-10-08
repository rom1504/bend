// Root-only actual checked-B1 differential controls. No timing claim.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
const [proposalArg, baselineArg, candidateArg, outArg] = process.argv.slice(2);
const out = path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const inputs = new Map();
const pin = x => {
  const expected = typeof x === 'string' ? null : x;
  const file = fs.realpathSync(expected?.file ?? x), bytes = fs.readFileSync(file);
  const p = {file,sha256:createHash('sha256').update(bytes).digest('hex'),bytes:bytes.length};
  if(expected){assert.equal(p.sha256,expected.sha256);if(expected.bytes!==undefined)assert.equal(p.bytes,expected.bytes);}
  inputs.set(file,p);return p;
};
const read = x => JSON.parse(fs.readFileSync(pin(x).file,'utf8'));
const report = {kind:'phase68-occurrence-summary-controls',complete:false,pass:false,images:[],rows:[]};
const save = () => fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const nil = () => ({$:'Nil'});
const list = xs => xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil());
const array = xs => {const a=[];while(xs.$==='Con'){a.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return a;};
const term = (tag,id=0,kids=[]) => ({$:'KTerm',tag,name:'metadata',id,quant:2,kids:list(kids),removed:list(['metadata']),originBegin:0,originEnd:0});
const variable = (id,kids=[]) => term('Var',id,kids);
const binding = (id,word) => ({$:'NC_Binding',id,word});
const occurrences = t => {
  const ids=new Set(),todo=[t];
  while(todo.length){const x=todo.pop();if(x.$==='KTerm'&&x.tag==='Var'){ids.add(x.id);continue;}
    if(x.$==='KLiteral')continue;assert(['KTerm','KLambda'].includes(x.$));todo.push(...array(x.kids));}
  return ids;
};
try {
  report.method=pin(import.meta.filename);report.proposal=pin(proposalArg);
  const proposal=read(proposalArg);pin(proposal.producer);pin(proposal.patch);
  const api={};
  for(const [role,file] of [['baseline',baselineArg],['candidate',candidateArg]]){
    const attemptPin=pin(file),attempt=read(file);
    assert(attempt.checked&&attempt.config.strictExact&&attempt.artifactKind==='derived-b1');
    for(const row of attempt.snapshot.sources)pin(row.frozen);
    for(const name of ['base','runtime','node'])pin(attempt[name]);
    const bridge=attempt.snapshot.sources.find(x=>x.frozen.file.endsWith('/src/back/native/bridge.bend'));
    assert(bridge);assert.equal(pin(bridge.frozen).sha256,pin(proposal[role==='baseline'?'before':'after']).sha256);
    for(const name of ['checkedApi','derivationReport','bootstrapReport'])pin(attempt[name]);
    const original=pin(attempt.api),source=fs.readFileSync(original.file,'utf8');
    const functions={occurs:['nc_occurs',2],live:['nc_live_env',2],drop:['nc_drop_dead',2],share:['nc_share_env',3]};
    if(role==='candidate')Object.assign(functions,{uses:['nc_uses',1],has:['nc_uses_has',2],partition:['nc_prepare_env',2]});
    const wrappers=Object.entries(functions).map(([key,[name,n]])=>{
      assert.equal(source.split('\n').filter(line=>line.startsWith('function $'+name+'$(')).length,1);
      const args=Array.from({length:n},(_,i)=>'a'+i).join(',');
      return JSON.stringify(key)+':run_lib(('+args+')=>run_loop($'+name+'$('+args+')),'+n+')';
    });
    const append='\n// P68-009 append-only internal diagnostic exports.\nexport const p68={'+wrappers.join(',')+'};\n';
    const derived=path.join(out,role+'-observed.mjs');fs.writeFileSync(derived,source+append,{flag:'wx'});
    assert.equal(fs.readFileSync(derived,'utf8').slice(0,source.length),source);
    const module=await import(pathToFileURL(derived));assert.equal(module.G,undefined);api[role]=module.p68;
    report.images.push({role,attempt:attemptPin,api:original,bridge:pin(bridge.frozen),derived:pin(derived),append});
  }
  const ids=[...new Set([0,1,2,3,2147483647,2147483648,4294967294,4294967295,
    ...Array.from({length:32},(_,i)=>2**i),...Array.from({length:32},(_,i)=>(4294967295^(2**i))>>>0)])];
  const terms=[term('Absent'),variable(0),variable(4294967295),variable(1,[variable(2)]),
    term('Lam',3,[variable(4),variable(3)]),term('Ann',0,[variable(1),variable(2147483648)]),
    term('Unknown',99,[term('Qnt',99,[variable(2)]),variable(4294967295)]),
    {$:'KLiteral',kind:'U32',number:4294967295,text:'ignored',originBegin:0,originEnd:0},
    {$:'KLambda',name:'x',id:9,quant:2,kids:list([variable(9),variable(1)]),removed:nil(),originBegin:0,originEnd:0,quantityPresent:true},
    term('Many',0,ids.flatMap(id=>[variable(id),variable(id)]))];
  let deep=variable(17);for(let i=0;i<128;i++)deep=term('Wrap',i,[deep]);terms.push(deep);
  let seed=0x681009;const random=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed;};
  const generate=depth=>{const id=ids[random()%ids.length];if(!depth||random()%4===0)return variable(id);
    return term(['App','Ann','Lam','Qnt','Unknown'][random()%5],id,Array.from({length:random()%4},()=>generate(depth-1)));};
  for(let i=0;i<24;i++)terms.push(generate(5));
  const envs=[[],[binding(0,'zero')],[binding(4294967295,'last')],
    [binding(1,'same'),binding(2,'same'),binding(1,'other'),binding(1,'same')],
    [binding(9,'a\nb'),binding(2147483648,'high'),binding(0,'zero'),binding(4294967295,'last')],
    ids.map((id,i)=>binding(id,'word_'+i))];
  let queries=0,partitions=0,shares=0;
  for(let index=0;index<terms.length;index++){
    const t=terms[index],other=terms[(index+7)%terms.length],want=occurrences(t),otherIds=occurrences(other);
    const before=JSON.stringify(t),uses=api.candidate.uses(t),usesBefore=JSON.stringify(uses);
    for(const id of ids){assert.equal(api.baseline.occurs(t,id),want.has(id));assert.equal(api.candidate.occurs(t,id),want.has(id));assert.equal(api.candidate.has(uses,id),want.has(id));queries++;}
    for(const rows of envs){
      const env=list(rows),live=list(rows.filter(x=>want.has(x.id)));
      const drop=rows.filter(x=>!want.has(x.id)).map(x=>'term_sink(e, '+x.word+');\n').join('');
      const share=rows.filter(x=>want.has(x.id)&&otherIds.has(x.id)).map(x=>x.word+' = term_keep(e, '+x.word+');\n').join('');
      for(const p of Object.values(api)){assert.deepEqual(p.live(env,t),live);assert.equal(p.drop(env,t),drop);assert.equal(p.share(env,t,other),share);}
      assert.deepEqual(api.candidate.partition(env,t),{$:'NC_EnvPartition',live,drop});partitions++;shares++;
    }
    assert.equal(JSON.stringify(t),before);assert.equal(JSON.stringify(uses),usesBefore);
    report.rows.push({index,queries:ids.length,environments:envs.length,pass:true});
  }
  const poison={$:'KTerm',get tag(){throw Error('Empty environment touched term');},get kids(){throw Error('Empty environment touched children');}};
  for(const p of Object.values(api)){assert.deepEqual(p.live(nil(),poison),nil());assert.equal(p.drop(nil(),poison),'');assert.equal(p.share(nil(),poison,poison),'');}
  assert.deepEqual(api.candidate.partition(nil(),poison),{$:'NC_EnvPartition',live:nil(),drop:''});
  assert.equal(api.candidate.share(list([binding(123456789,'unused')]),variable(1),poison),'');
  for(const value of [...inputs.values()])pin(value);
  report.summary={terms:terms.length,ids:ids.length,queries,partitions,shares,emptyEnvNonDemand:true,unusedSecondShareNonDemand:true};
  report.complete=true;report.pass=true;report.inputsUnchanged=true;
} catch(error){report.error=error.stack??String(error);process.exitCode=1;}
report.inputs=[...inputs.values()];save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,summary:report.summary,error:report.error}));
