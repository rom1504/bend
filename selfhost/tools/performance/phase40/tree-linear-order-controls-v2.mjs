// Checked-emission phase witness; only AST counters/value capture, never optimizer substitutions.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [cohortArg,outArg]=process.argv.slice(2);assert(cohortArg&&outArg,'usage: tree-linear-order-controls.mjs COHORT_LINEAR NEW_OUT');
const cohort=path.resolve(cohortArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=p=>({path:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const report={kind:'phase40-linear-order-controls',complete:false,pass:false,inputs:[],structures:[],oracles:[],order:[],boundaries:[]};
function verify(r){const i=identity(r.path??r.file??r.canonicalPath);assert.equal(i.sha256,r.sha256);report.inputs.push(i);return i;}
const mf=path.join(cohort,'derive.json'),manifest=JSON.parse(fs.readFileSync(mf));report.inputs.push(identity(mf),identity(import.meta.filename));assert(manifest.complete);verify(manifest.source);
const files={},modules={};for(const role of ['baseline','candidate','typescript']){const f=verify(manifest.variants[role]),r=verify(manifest.emissions[role]),e=JSON.parse(fs.readFileSync(r.path));assert.equal(e.kind,'bend-program-checked-emission');assert(e.complete&&e.observation.checked&&e.observation.status==='ok');assert.equal(e.input.sha256,manifest.source.sha256);assert.equal(e.output.sha256,f.sha256);assert.deepEqual(e.compiler,manifest.compilers[role]);verify(e.input);verify(e.output);verify(e.producer);verify(e.catalog);e.verifiers.forEach(verify);if(role==='typescript')e.compiler.sources.forEach(verify);else{assert(e.observation.typeAccepted);verify(e.attempt);for(const key of ['api','runtime','base','driver'])verify(e.compiler[key]);}files[role]=f.path;}
const pm={exports:{}};new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(pm,pm.exports);assert.equal(pm.exports.version,'8.16.0');const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const source=fs.readFileSync(files.candidate,'utf8'),ast=parse(source),names=['order.first','order.middle','order.last','order.pass'],childIndex={'order.first':0,'order.middle':1,'order.last':2,'order.pass':0};
const encode=n=>'$R'+Array.from(n,c=>'_'+c.codePointAt(0)).join('')+'$tree';const inserts=[],audit=[];
function wrap(n,before,after=')'){inserts.push({at:n.start,text:before},{at:n.end,text:after});}
function walk(n,fn,phase=0){if(!n||typeof n!=='object')return;
 if(n.type==='IfStatement'&&source.slice(n.test.start,n.test.end)==='$frame.phase===2'){walk(n.consequent,fn,3);walk(n.alternate,fn,phase);return;}
 if(n.type==='IfStatement'&&source.slice(n.test.start,n.test.end)==='$frame.phase===0'){walk(n.consequent,fn,1);walk(n.alternate,fn,2);return;}
 fn(n,phase);for(const [k,v]of Object.entries(n)){if(['start','end'].includes(k))continue;if(Array.isArray(v))v.forEach(c=>walk(c,fn,phase));else if(v&&typeof v.type==='string')walk(v,fn,phase);}}
for(const name of names){const workers=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===encode(name));assert.equal(workers.length,1,'actual structural worker '+name);const w=workers[0];inserts.push({at:w.body.start+1,text:`$loMark(${JSON.stringify(name)},'entry');`});let leaf=0,resume=0,binary=0;
 walk(w.body,(n,phase)=>{
  if(n.type==='VariableDeclarator'&&/^\$u\d+$/.test(n.id?.name)&&n.init)wrap(n.init,`($loMark(${JSON.stringify(name)},'pre${n.id.name.slice(2)}'),(`,'))');
  if(n.type==='AssignmentExpression'&&n.left.name==='$value'){
   if(phase===0){leaf++;wrap(n.right,`($loMark(${JSON.stringify(name)},'leaf'),(`,'))');}
   if(phase===2){binary++;wrap(n.right,`($loMark(${JSON.stringify(name)},'binary'),(`,'))');}
   if(phase===3){resume++;const rhs=n.right;assert.equal(rhs.type,'CallExpression','resumed known combiner');let args;
    if(rhs.callee.name==='callOwned'){assert.equal(rhs.arguments[1].type,'ArrayExpression');args=rhs.arguments[1].elements;}else args=rhs.arguments;
    assert.equal(args.length,name==='order.pass'?2:3);const ci=childIndex[name];assert.equal(args[ci].name,'$value','actual child result argument');
    for(let i=ci+1;i<args.length;i++)wrap(args[i],`($loMark(${JSON.stringify(name)},'post${i}'),(`,'))');
    wrap(rhs,`$loResume(${JSON.stringify(name)},$value,(`,'))');
   }
  }
  if(n.type==='ReturnStatement'&&n.argument?.name==='$value')wrap(n.argument,`$loResult(${JSON.stringify(name)},`,')');
 });assert.equal(leaf,1);assert.equal(resume,1);assert.equal(binary,1);audit.push({name,leaf,resume,binary});
}
let diagnostic=source;for(const i of inserts.sort((a,b)=>b.at-a.at))diagnostic=diagnostic.slice(0,i.at)+i.text+diagnostic.slice(i.at);
diagnostic+=`
const $loEvents=[],$loValues=Object.create(null),$loAliases=[];
function $loMark(name,phase){$loEvents.push(name+':'+phase);}
function $loResume(name,child,result){$loMark(name,'resume');if(name==='order.pass')$loAliases.push({name,exact:result===child});else $loAliases.push({name,exact:result.$==='RPair'&&result.a[0].$==='RStamp'&&result.a[1].$==='RStamp'&&result.a[0].a[1]===child&&result.a[1].a[1]===child});return result;}
function $loResult(name,value){$loValues[name]=value;return value;}
export function linearState(){return {events:$loEvents.slice(),aliases:$loAliases.slice(),active:regionProof!==null};}
export function linearValue(name){return $loValues[name];}
`;
parse(diagnostic);fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));const diag=path.join(out,'candidate-diagnostic.mjs');fs.writeFileSync(diag,diagnostic,{flag:'wx'});report.diagnostic={parent:identity(files.candidate),output:identity(diag),audit,insertions:inserts};
modules.candidate=await import(pathToFileURL(diag));for(const r of ['baseline','typescript'])modules[r]=await import(pathToFileURL(files[r]));
const call=(m,n,a)=>m.default[n](...a),u=x=>Number(BigInt.asUintN(32,BigInt(x)));
function input(d,s){if(d===0)return ['L',s];return s%2===0?['U',input(d-1,u(BigInt(s)+1n))]:['B',input(d-1,u(BigInt(s)+1n)),['L',s]];}
function model(t,b,l,a,pass=false){if(t[0]==='L')return ['L',pass?t[1]:u(BigInt(t[1])+l+1n)];if(t[0]==='B')return ['P',model(t[1],b,l,a,pass),model(t[2],b,l,a,pass)];const child=model(t[1],b,l,a,pass);return pass?child:['P',['S',u(b+1n),child],['S',u(a+1n),child]];}
function canon(t){assert(Array.isArray(t.a));if(t.$==='RLeaf'){assert.equal(t.a.length,1);return ['L',t.a[0]];}if(t.$==='RStamp'){assert.equal(t.a.length,2);return ['S',t.a[0],canon(t.a[1])];}assert.equal(t.$,'RPair');assert.equal(t.a.length,2);return ['P',canon(t.a[0]),canon(t.a[1])];}
function score(t){return t[0]==='L'?t[1]:t[0]==='S'?u(BigInt(t[1])+BigInt(score(t[2]))):u(BigInt(score(t[1]))+1n+BigInt(score(t[2])));}
function normalize(x){if(typeof x==='bigint')return x+'n';if(x===undefined)return '[undefined]';if(!x||typeof x!=='object')return x;return Array.isArray(x)?x.map(normalize):Object.fromEntries(Object.entries(x).map(([k,v])=>[k,normalize(v)]));}
function observation(m,n,args){try{return {value:normalize(call(m,n,args))};}catch(e){return {error:{name:e.name,message:e.message}};}}
try{
 for(const d of [0,1,2,3,7])for(const seed of [0,17,18,4294967295])for(const [b,l,a]of [[0n,0n,0n],[7n,11n,19n]])for(const name of names){const root=name.split('.')[1]+'_check',pass=name==='order.pass',args=pass?[d,b,seed]:[d,b,l,a,seed],expected=model(input(d,seed),b,l,a,pass),value=score(expected),observed=Object.fromEntries(Object.entries(modules).map(([r,m])=>[r,observation(m,root,args)]));for(const o of Object.values(observed))assert.deepEqual(o,{value});assert.deepEqual(canon(modules.candidate.linearValue(name)),expected);report.oracles.push({d,seed,b:String(b),l:String(l),a:String(a),name,value,observed});}
 const aliases=modules.candidate.linearState().aliases;assert(aliases.length>0);assert(aliases.some(x=>x.name==='order.pass'));for(const a of aliases)assert(a.exact,a.name);report.structures.push({kind:'actual-resume-child-alias',observations:aliases.length,allExact:true});
 const MAX=281474976710655n;
 const tests=[['order.first','leaf',MAX,MAX,MAX,['entry','leaf']],['order.first','before',MAX,0n,MAX,['entry','leaf','post1']],['order.first','after',0n,0n,MAX,['entry','leaf','post1','post2']],['order.middle','before',MAX,MAX,MAX,['entry','pre0']],['order.middle','leaf',0n,MAX,MAX,['entry','pre0','leaf']],['order.middle','after',0n,0n,MAX,['entry','pre0','leaf','post2']],['order.last','before',MAX,MAX,MAX,['entry','pre0']],['order.last','after',0n,MAX,MAX,['entry','pre0','pre1']],['order.last','leaf',0n,MAX,0n,['entry','pre0','pre1','leaf']]];
 for(const [name,label,b,l,a,want]of tests){const before=modules.candidate.linearState().events.length,root=name.split('.')[1]+'_check',rows=[observation(modules.baseline,root,[1,b,l,a,18]),observation(modules.candidate,root,[1,b,l,a,18])];assert(rows[0].error);assert.deepEqual(rows[1],rows[0]);const actual=modules.candidate.linearState().events.slice(before).filter(x=>x.startsWith(name+':')).map(x=>x.slice(name.length+1));assert.deepEqual(actual,want);assert.equal(modules.candidate.linearState().active,false);report.order.push({name,label,actual,want,error:rows[0].error});}
 for(const name of names.slice(0,3)){const root=name.split('.')[1]+'_check',rows=[observation(modules.baseline,root,[0,MAX,MAX,MAX,18]),observation(modules.candidate,root,[0,MAX,MAX,MAX,18])];assert(rows[0].error);assert.deepEqual(rows[1],rows[0]);report.order.push({name,label:'depth0-no-sibling-demand',error:rows[0].error});}
 for(const name of [...names,'order.pick_first','order.pick_middle','order.pick_last','order.identity','order.bump','order.make','order.make_choose','order.score'])for(const kind of ['wrap','getter','binding']){
  const root=name.includes('pass')||name.includes('identity')?'pass_check':name.includes('first')?'first_check':name.includes('last')?'last_check':'middle_check',args=root==='pass_check'?[3,0n,18]:[3,0n,0n,0n,18],rows=[];
  for(const role of ['baseline','candidate']){const m=modules[role],gd=Object.getOwnPropertyDescriptor(m.G,name),f=gd.value,fd=Object.getOwnPropertyDescriptors(f),old=f.code,events=[],before=role==='candidate'?m.linearState().events.length:0;
   try{if(kind==='binding')Object.defineProperty(m.G,name,{configurable:true,get(){events.push('binding');return f;}});else if(kind==='getter')Object.defineProperty(f,'code',{configurable:true,get(){events.push('code');return old;}});else f.code=function(a){events.push('invoke');return Reflect.apply(old,this,[a]);};
    rows.push({observed:observation(m,root,args),events});if(role==='candidate'){assert.equal(m.linearState().events.length,before,'mutable graph must refuse actual workers');assert.equal(m.linearState().active,false);}
   }finally{Object.defineProperties(f,fd);Object.defineProperty(m.G,name,gd);}
  }assert(rows[0].events.length>0);assert.deepEqual(rows[1],rows[0]);report.boundaries.push({name,kind,rows});
 }
 const state=modules.candidate.linearState();for(const name of names){assert(state.events.includes(name+':binary'));assert(state.events.includes(name+':resume'));}assert.equal(state.active,false);report.structures.push({kind:'mixed-binary-unary-worker-phases',workers:names});
 for(const i of report.inputs)assert.deepEqual(identity(i.path),i);report.complete=true;report.pass=true;
}catch(e){report.error=e.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,order:report.order.length,error:report.error}));
