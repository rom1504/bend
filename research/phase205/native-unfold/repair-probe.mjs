// Diagnostic only: recheck saved residuals in their original real source contexts.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
const [out,dir,saved,...files]=process.argv.slice(2);
if(!/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8')))throw Error('guarded CPU3 required');
fs.mkdirSync(out);
const read=p=>JSON.parse(fs.readFileSync(p)),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
function auth(pin){let b=fs.readFileSync(pin.file);if(b.length!==pin.bytes||hash(b)!==pin.sha256)throw Error(pin.file);return b.toString();}
const rc=read(dir+'/report.json');let source=auth(rc.api);
const rx=/function \$p205_ready\([^\n]*\) \{/;if(!rx.test(source))throw Error('ready hook');
source=source.replace(rx,'$&globalThis.realContext=_context_0;');
for(const name of ['check_definition_body','kw_initial','lookup'])if(!source.includes('function $'+name+'('))throw Error(name);
source+='\nglobalThis.repairAPI={check:(ctx,d)=>run_loop($check_definition_body(run_loop($kw_initial(ctx)),d,0)),lookup:(ctx,n)=>run_loop($lookup(ctx,n))};\n';
const api=(await import('data:text/javascript;base64,'+Buffer.from(source).toString('base64'))).default;
const binding=read('selfhost/build/phase197/shared-emission-plan01.json').producer.bindingValue;
const prep=api.p88_cache_prepare(binding.base.file,auth(binding.base),auth(binding.carrier),binding.stamp);
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
function kids(t){let x=t.kids??nil,a=[];while(x.$==='Con'){a.push(x.head);x=x.tail;}return a;}
const tag=t=>t.$==='KLambda'?'Lam':t.$==='KLiteral'?'Lit':t.tag;
const term=(tag_,name,k=[],id=0,quant=1)=>({$:'KTerm',tag:tag_,name,id,quant,kids:list(k),removed:nil,originBegin:0,originEnd:0});
const ref=n=>term('Ref',n);
function hydrate(x){if(!x||typeof x!=='object')return x;const y=Object.fromEntries(Object.entries(x).map(([k,v])=>[k,hydrate(v)]));if(['KTerm','KLambda'].includes(y.$)&&!y.removed)y.removed=nil;return y;}
const strip=t=>tag(t)==='Ann'?strip(kids(t)[0]):t;
function closed(t){return tag(t)!=='Var'&&kids(t).every(closed);}
function resultType(t){t=strip(t);while(tag(t)==='All')t=strip(kids(t)[1]);return closed(t)&&['Ref','ADT'].includes(tag(t))?t:null;}
function infer(ctx,t,env){t=strip(t);const k=kids(t);
 if(tag(t)==='Lit')return ref(t.kind??t.name);
 if(tag(t)==='Var')return env.get(t.id)??null;
 if(tag(t)==='Let'){const local=new Map(env);for(const b of k.slice(0,-1)){const ty=infer(ctx,kids(b)[0],local);if(ty)local.set(b.id,ty);}return infer(ctx,k.at(-1),local);}
 if(tag(t)==='App'){let h=t;while(tag(h)==='App')h=strip(kids(h)[0]);return tag(h)==='Ref'?resultType(repairAPI.lookup(ctx,h.name).typ):null;}
 if(tag(t)==='Ref'||tag(t)==='Ctr'){const d=repairAPI.lookup(ctx,t.name);return d.kind==='Absent'?null:resultType(d.typ);}
 return null;
}
function fix(ctx,t,env,expected,mode,stats){const k=kids(t);
 if(tag(t)==='Lam'){const ty=strip(expected??term('Absent',''));const e=new Map(env);if(tag(ty)==='All')e.set(t.id,kids(ty)[0]);return {...t,kids:list([fix(ctx,k[0],e,tag(ty)==='All'?kids(ty)[1]:null,mode,stats)])};}
 if(tag(t)==='Let'){const local=new Map(env),out=[];for(const b of k.slice(0,-1)){
   let value=fix(ctx,kids(b)[0],local,null,mode,stats);const ty=infer(ctx,value,local);
   if(mode.includes('typed')&&ty&&tag(value)!=='Ann'){value=term('Ann','',[value,ty],0,0);stats.annotations++;}
   const quant=mode.includes('q2')?2:b.quant;if(quant!==b.quant)stats.widened++;
   out.push({...b,quant,kids:list([value])});if(ty)local.set(b.id,ty);
  }out.push(fix(ctx,k.at(-1),local,expected,mode,stats));return {...t,kids:list(out)};}
 return {...t,...(t.kids?{kids:list(k.map(x=>fix(ctx,x,env,null,mode,stats)))}:{})};
}
const report={api:rc.api,status:'diagnostic actual Bend checker matrix; no bypass or qualification',rows:[]};
for(const file of files){globalThis.realContext=null;const input=fs.readFileSync(file);const plan=api.p86_plan(prep.seed,path.resolve(file),input.toString());if(!realContext||plan.$!=='P86PlanReady')throw Error('context '+file);
 const residualPath=path.join(saved,'last-'+path.basename(file)+'.json'),original=hydrate(read(residualPath));
 const row={file,inputSHA256:hash(input),residual:residualPath,residualSHA256:hash(fs.readFileSync(residualPath)),owner:original.name,variants:[]};report.rows.push(row);
 for(const mode of ['unchanged','q2','typed','typed-q2']){const stats={annotations:0,widened:0};const candidate=mode==='unchanged'?original:{...original,value:fix(realContext,original.value,new Map(),original.typ,mode,stats)};
  const result=repairAPI.check(realContext,candidate);row.variants.push({mode,...stats,error:result.error,passed:result.error==='' });
  if(result.error==='')fs.writeFileSync(path.join(out,path.basename(file)+'.'+mode+'.json'),JSON.stringify(candidate));
  fs.writeFileSync(path.join(out,'results.json'),JSON.stringify(report,null,2)+'\n');
 }
}
