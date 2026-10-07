// Root owns the bounded job. Probe genuine checked B1 functions, not a rewritten compiler.
import assert from 'node:assert/strict';import fs from 'node:fs';import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {identity,verify,hash,list} from '../../phase54/bootstrap/adapter.mjs';
const [baselineArg,candidateArg,outArg]=process.argv.slice(2);assert(baselineArg&&candidateArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase61')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const pins=new Map();function pin(value){const p=typeof value==='string'?identity(value):identity(value.file);
 if(typeof value==='object')assert.equal(p.sha256,value.sha256);if(pins.has(p.file))assert.deepEqual(pins.get(p.file),p);pins.set(p.file,p);return p;}
const clone=x=>JSON.parse(JSON.stringify(x)),T=(tag,name='',id=0,quant=0,kids=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
const V=id=>T('Var','v'+id,id),R=n=>T('Ref',n),Q=q=>T('Qua','',0,q),Typ=()=>T('Typ','',0,0,[Q(1)]),All=(id,a,b,q=1)=>T('All','v'+id,id,q,[a,b]);
const App=(f,x)=>T('App','',0,0,[f,x]),Lam=(id,b)=>({$:'KLambda',name:'v'+id,id,quant:1,kids:list([b]),removed:list([]),originBegin:0,originEnd:0,quantityPresent:false});
const Def=(name,value,kind='Def',typ=Typ(),ctors=[],native=false)=>({$:'KDef',name,kind,arity:0,templates:0,typ,value,ctors:list(ctors),native,unsafe:false});
const span=(t,b,e)=>({...t,originBegin:b,originEnd:e});
function chain(n){let t=V(100);for(let i=n-1;i>=0;i--)t=All(100+i,Typ(),t,i%3);return t;}
const specs=[];function row(id,tel,args,expected,book=[],cursor=true){specs.push({id,tel,args,expected,book,cursor});}
row('empty',span(All(1,Typ(),V(1)),3,8),[],span(All(1,Typ(),V(1)),3,8),[],false);
row('single',All(1,Typ(),V(1)),[Q(2)],Q(2),[],false);
row('dependent-fields',All(1,Typ(),All(2,V(1),T('Ctr','Pair',0,1,[V(1),V(2)]))),[Q(1),Q(2)],T('Ctr','Pair',0,1,[Q(1),Q(2)]));
row('earlier-replacement-later-binding',All(1,Typ(),All(2,Typ(),V(1))),[V(2),Q(2)],Q(2));
row('later-replacement-raw',All(1,Typ(),All(2,Typ(),V(2))),[Q(2),V(1)],V(1));
row('duplicate-binders',All(1,Typ(),All(1,Typ(),V(1))),[Q(1),Q(2)],Q(1));
row('partial-result',All(1,Typ(),All(2,Typ(),All(3,V(1),V(2),0))),[Q(1),Q(2)],All(3,Q(1),Q(2),0));
row('too-many-absent-not-error',All(1,Typ(),Q(0)),[Q(1),Q(2),Q(0)],T('Absent'));
row('invalid-head-absent',Q(0),[Q(1),Q(2)],T('Absent'));
row('alias-head',R('Alias'),[Q(1),Q(2)],Q(1),[Def('Alias',chain(2))]);
row('alias-tail',All(1,Typ(),R('Alias')),[Q(1),Q(2)],Q(2),[Def('Alias',All(2,Typ(),V(2)))]);
row('annotation',T('Ann','',0,0,[chain(2),Typ()]),[Q(1),Q(2)],Q(1));
row('beta-tail-fallback',All(1,Typ(),All(2,Typ(),App(Lam(3,V(3)),V(1)))),[Q(1),Q(2)],Q(1),[],false);
row('beta-domain-fallback',All(1,Typ(),All(2,App(Lam(3,V(3)),Typ()),V(1))),[Q(1),Q(2)],Q(1),[],false);
row('function-binding-fallback',All(1,Typ(),All(2,Typ(),App(V(1),V(2)))),[Lam(3,V(3)),Q(2)],Q(2),[],false);
row('unsafe-argument-flush',All(1,Typ(),All(2,Typ(),V(1))),[App(Lam(3,V(3)),Q(1)),Q(2)],Q(1));
row('noncanonical-app-fallback',All(1,Typ(),All(2,Typ(),T('App','metadata',5,2,[R('opaque'),V(1)]))),[Q(1),Q(2)],App(R('opaque'),Q(1)),[],false);
row('span-and-lambda-presence',span(All(1,Typ(),All(2,Typ(),span(Lam(7,V(1)),12,19),0),2),3,21),[span(Q(1),30,34),Q(2)],span(Lam(7,span(Q(1),30,34)),12,19));
for(const n of [2,8,63,64,65,129])row('bound-'+n,chain(n),Array.from({length:n},(_,i)=>Q(i%3)),Q(0));
const report={kind:'phase61-backend-telescope-controls',complete:false,pass:false,roles:{},rows:[],bridges:[],
 scope:'Genuine checked B1 differential specialization and one ordinary direct-constructor bridge. Complete values/spans/quantities and input retention. No arbitrary getter/cyclic host ABI or fresh source frontend/performance claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...pins.values()]},null,2)+'\n');save();
try {
 for(const f of [import.meta.filename,process.execPath,new URL('../../../development/workflow.mjs',import.meta.url).pathname,new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url).pathname])pin(f);
 const source=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],P={exports:{}};new Function('module','exports',source)(P,P.exports);
 report.parser={version:P.exports.version,sha256:hash(source)};const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
 const roles={};
 for(const [role,arg] of [['baseline',baselineArg],['candidate',candidateArg]]) {
  const directory=fs.realpathSync(arg),m=await verifyAttempt(directory),attempt=pin(path.join(directory,'attempt.json'));assert(m.checked);
  for(const key of ['api','runtime','base','node','bootstrapReport'])pin(m[key]);assert.equal(identity(process.execPath).sha256,m.node.sha256);
  const validation=pin(path.join(directory,'validation-001/report.json')),v=JSON.parse(fs.readFileSync(validation.file));
  assert(v.complete&&v.pass&&v.selected.selectedComplete);assert.equal(v.selected.exactDifferences,0);assert.equal(v.selected.discrepancies,0);
  assert.equal(v.attempt.sha256,attempt.sha256);assert.equal(v.api.sha256,m.api.sha256);
  const original=fs.readFileSync(m.api.file,'utf8'),ast=parse(original),edits=[];
  const names=['run_loop','$j_specialize$','$jd_ctor_checked$'];
  const counters=role==='candidate'?['jd_specialize','jd_specialize_cursor','jd_specialize_fallback']:[];
  for(const name of [...names,...counters.map(x=>'$'+x+'$')]) {
   const ds=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id?.name===name);assert.equal(ds.length,1,name);
   if(counters.includes(name.slice(1,-1)))edits.push({at:ds[0].body.start+1,text:'$p61BackendCounts.'+name.slice(1,-1)+'++;'});
  }
  let text=original;for(const e of [...edits].sort((a,b)=>b.at-a.at))text=text.slice(0,e.at)+e.text+text.slice(e.at);
  const suffix=`\nexport const phase61Backend={counts:{jd_specialize:0,jd_specialize_cursor:0,jd_specialize_fallback:0},specialize:(b,t,a)=>run_loop(${role==='candidate'?'$jd_specialize$':'$j_specialize$'}(b,t,a)),legacy:(b,t,a)=>run_loop($j_specialize$(b,t,a)),ctor:(b,t,ty,c)=>run_loop($jd_ctor_checked$(b,{ $:'Nil'},t,ty,c))};\nconst $p61BackendCounts=phase61Backend.counts;\n`;
  parse(text+suffix);let recovered=text;for(const e of [...edits].sort((a,b)=>a.at-b.at)){assert.equal(recovered.slice(e.at,e.at+e.text.length),e.text);recovered=recovered.slice(0,e.at)+recovered.slice(e.at+e.text.length);}assert.equal(recovered,original);
  const file=path.join(out,role+'-probe.mjs');fs.writeFileSync(file,text+suffix,{flag:'wx'});roles[role]=(await import(pathToFileURL(file))).phase61Backend;
  report.roles[role]={attempt,api:m.api,validation,strictExact:m.config.strictExact,derivative:pin(file),edits,suffixSha256:hash(suffix),queries:pin(path.join(m.snapshot.root,'src/back/common/queries.bend'))};
  if(role==='candidate')report.roles[role].module=pin(path.join(m.snapshot.root,'src/back/js/direct/telescope.bend'));save();
 }
 for(const spec of specs) {
  const b=clone({book:list(spec.book),tel:spec.tel,args:list(spec.args)}),c=clone(b),before=JSON.stringify(c),beforeB=JSON.stringify(b),counts={...roles.candidate.counts};
  const want=roles.baseline.specialize(b.book,b.tel,b.args),actual=roles.candidate.specialize(c.book,c.tel,c.args);
  assert.deepEqual(actual,want,spec.id);assert.deepEqual(actual,spec.expected,spec.id+' independent expected');
  assert.deepEqual(actual,roles.candidate.legacy(c.book,c.tel,c.args),spec.id+' retained fallback');assert.equal(JSON.stringify(c),before);assert.equal(JSON.stringify(b),beforeB);
  if(spec.args.length===0){assert.equal(actual,c.tel);assert.equal(want,b.tel);}
  const delta=Object.fromEntries(Object.keys(counts).map(k=>[k,roles.candidate.counts[k]-counts[k]]));
  assert(delta.jd_specialize>0);assert.equal(delta.jd_specialize_cursor>0,spec.cursor,spec.id+' admission');
  report.rows.push({id:spec.id,pass:true,counterDelta:delta,resultSha256:hash(JSON.stringify(actual))});save();
 }
 const u=T('ADT','U32'),ctorType=All(1,Typ(),All(2,Typ(),All(3,V(1),All(4,V(2),T('ADT','P61Pair',0,0,[V(1),V(2)]))),0),0);
 const ctor=Def('P61Pair.make',T('Absent'),'Ctr',ctorType),owner=Def('P61Pair',T('Absent'),'ADT',Typ(),[ctor]);
 const book=list([owner,Def('U32',T('Absent'),'ADT',Typ(),[],true)]),value=T('Ctr','P61Pair.make',0,0,[{$:'KLiteral',kind:'U32',number:7,text:'',originBegin:0,originEnd:0},{$:'KLiteral',kind:'U32',number:9,text:'',originBegin:0,originEnd:0}]),ty=T('ADT','P61Pair',0,0,[u,u]);
 const counts={...roles.candidate.counts},before=JSON.stringify({book,value,ty,ctor});
 const want=roles.baseline.ctor(book,value,ty,ctor),actual=roles.candidate.ctor(book,value,ty,ctor);
 assert.equal(actual,want);assert.deepEqual(new Function('return '+actual)(),{$:'P61Pair.make',v3:7,v4:9});
 assert(roles.candidate.counts.jd_specialize>counts.jd_specialize);assert(roles.candidate.counts.jd_specialize_cursor>counts.jd_specialize_cursor);
 assert.equal(JSON.stringify({book,value,ty,ctor}),before);report.bridges.push({id:'ordinary-parametric-direct-constructor',pass:true,outputSha256:hash(actual)});
 for(const p of pins.values())verify(p);report.complete=report.pass=true;save();console.log(JSON.stringify({pass:true,rows:report.rows.length,bridges:report.bridges.length}));
} catch(error){report.error=String(error?.stack??error);save();throw error;}
