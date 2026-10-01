// Controls for actual checked source emission; root alone executes this tool.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseArg,candidateArg,tsArg,outArg]=process.argv.slice(2);
assert(baseArg&&candidateArg&&tsArg&&outArg,'usage: finite-controls.mjs BASELINE.mjs CANDIDATE.mjs TYPESCRIPT.mjs NEW_OUT');
const files=[baseArg,candidateArg,tsArg].map(p=>fs.realpathSync(p)),out=path.resolve(outArg);
assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:false});
const identity=p=>({path:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const report={kind:'phase37-actual-finite-controls',complete:false,pass:false,node:process.version,
 inputs:[import.meta.filename,...files].map(identity),oracle:[],admission:[],boundaries:[]};
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const parserModule={exports:{}};
new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(parserModule,parserModule.exports);
assert.equal(parserModule.exports.version,'8.16.0');
const parse=s=>parserModule.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const u=x=>x>>>0;
function visit(n,f){if(!n||typeof n!=='object')return;f(n);for(const [key,value]of Object.entries(n)){
 if(key==='start'||key==='end')continue;if(Array.isArray(value)){for(const child of value)visit(child,f);}else if(value&&typeof value.type==='string')visit(value,f);}}
function assignments(ast){return ast.body.filter(s=>s.type==='ExpressionStatement'&&s.expression.type==='AssignmentExpression'&&s.expression.left.type==='MemberExpression'&&s.expression.left.object.name==='G'&&typeof s.expression.left.property.value==='string');}
function canonical(t){assert(t&&typeof t==='object');if(t.$==='BoxLeaf')return [Array.isArray(t.a)?t.a[0]:t.value];
 assert.equal(t.$,'BoxNode');return Array.isArray(t.a)?[canonical(t.a[0]),canonical(t.a[1])]:[canonical(t.left),canonical(t.right)];}
function norm(x,seen=new Set()){if(typeof x==='bigint')return x+'n';if(typeof x==='function')return '[Function]';if(x===undefined)return '[Undefined]';
 if(typeof x==='number'&&!Number.isFinite(x))return String(x);if(x===null||typeof x!=='object')return x;if(seen.has(x))return '[Cycle]';seen.add(x);
 const value=Array.isArray(x)?x.map(v=>norm(v,seen)):Object.fromEntries(Object.keys(x).sort().map(k=>[k,norm(x[k],seen)]));seen.delete(x);return value;}
function snapshot(m){const gd=Object.getOwnPropertyDescriptors(m.G),objects=[];
 for(const d of Object.values(gd)){const f=d.value;if(f&&typeof f==='object')for(const value of [f,f.code,f.bound])if(value&&(typeof value==='object'||typeof value==='function'))objects.push([value,Object.getOwnPropertyDescriptors(value)]);}
 return()=>{for(const [object,descs]of objects){for(const k of Reflect.ownKeys(object))if(!Object.hasOwn(descs,k))delete object[k];Object.defineProperties(object,descs);}
 for(const k of Reflect.ownKeys(m.G))if(!Object.hasOwn(gd,k))delete m.G[k];Object.defineProperties(m.G,gd);};}
function hook(object,key,descriptor,action){const old=Object.getOwnPropertyDescriptor(object,key);try{Object.defineProperty(object,key,{configurable:true,...descriptor});return action();}
 finally{if(old)Object.defineProperty(object,key,old);else delete object[key];}}
function changed(m,events,name,kind='wrap'){const f=m.G[name],code=f.code;
 if(kind==='binding')Object.defineProperty(m.G,name,{configurable:true,get(){events.push('G:'+name);return f;}});
 else if(kind==='getter')Object.defineProperty(f,'code',{configurable:true,get(){events.push('code:'+name);return code;}});
 else f.code=function(a){events.push('invoke:'+name);return Reflect.apply(code,this,[a]);};}
try{
 const source=fs.readFileSync(files[1],'utf8'),ast=parse(source),stmts=assignments(ast),insertions=[],sites=[];
 visit(ast,n=>{if(n.type!=='ConditionalExpression'||n.test.type!=='LogicalExpression'||n.test.operator!=='&&')return;
  const cover=n.test.right,yes=n.consequent;
  if(cover.type!=='CallExpression'||cover.callee.name!=='regionProofCovers'||cover.arguments.length!==1)return;
  const array=cover.arguments[0];if(array.type!=='ArrayExpression'||array.elements.length!==1||typeof array.elements[0].value!=='string')return;
  if(yes.type!=='CallExpression'||yes.callee.type!=='ArrowFunctionExpression'||!source.slice(yes.callee.body.start,yes.callee.body.end).includes('/* private finite selector */'))return;
  const name=array.elements[0].value;sites.push({name,start:yes.start,end:yes.end});
  insertions.push({at:yes.start,text:'$finiteWitness('+JSON.stringify(name)+',('},{at:yes.end,text:'))'});
 });
 const admitted=new Set(sites.map(s=>s.name));
 for(const name of ['finite.choose','finite.change','finite.score','finite.zip','finite.leaf'])assert(admitted.has(name),'actual direct selector '+name);
 for(const name of ['finite.opaque','finite.native','finite.closure','finite.sum'])assert(!admitted.has(name),'selector must refuse '+name);
 const roots=[];let at=0;const marker='/* private finite root */';
 while((at=source.indexOf(marker,at))>=0){const statement=stmts.find(s=>s.start<=at&&at<s.end);assert(statement,'root marker inside G assignment');
  const name=statement.expression.left.property.value;roots.push(name);insertions.push({at:at+marker.length,text:'$finiteRootCounts['+JSON.stringify(name)+']=($finiteRootCounts['+JSON.stringify(name)+']||0)+1;'});at+=marker.length;}
 for(const name of ['choice_check','alias_check','leaf_check','argument_check','finite.cycle.root','finite.mutual.root'])assert(roots.includes(name),'actual scoped root '+name);
 for(const name of ['array_check','closure_check'])assert(!roots.includes(name),'root must refuse '+name);
 let diagnostic=source;for(const edit of insertions.sort((a,b)=>b.at-a.at))diagnostic=diagnostic.slice(0,edit.at)+edit.text+diagnostic.slice(edit.at);
 diagnostic+='\nconst $finiteCounts=Object.create(null),$finiteValues=Object.create(null),$finiteRootCounts=Object.create(null);\n'+
  'function $finiteWitness(name,value){$finiteCounts[name]=($finiteCounts[name]||0)+1;$finiteValues[name]=value;return value;}\n'+
  'export function finiteState(){return {active:regionProof!==null,counts:{...$finiteCounts},roots:{...$finiteRootCounts}};}\n'+
  'export function finiteValue(name){return $finiteValues[name];}\n';
 parse(diagnostic);const diagnosticFile=path.join(out,'candidate-diagnostic.mjs');fs.writeFileSync(diagnosticFile,diagnostic,{flag:'wx'});
 const baselineDiagnostic=path.join(out,'baseline-diagnostic.mjs');fs.writeFileSync(baselineDiagnostic,fs.readFileSync(files[0],'utf8')+'\nexport function finiteState(){return {active:false,counts:{},roots:{}};}\n',{flag:'wx'});
 report.diagnostic={parent:identity(files[1]),output:identity(diagnosticFile),baseline:identity(baselineDiagnostic),sites,roots,insertions,
  scope:'Only insert counters and capture the returned value of each actual emitted selector; no alternate computation or direct-entry bypass. Diagnostics are not timed.'};
 report.admission.push({kind:'actual-emission',sites:sites.length,admitted:[...admitted].sort(),roots});
 const baseline=await import(pathToFileURL(baselineDiagnostic)),candidate=await import(pathToFileURL(diagnosticFile)),typescript=await import(pathToFileURL(files[2]));
 const mods=[baseline,candidate,typescript],bends=[baseline,candidate];
 const call=(m,name,args)=>{const values=m===typescript?args.map(x=>typeof x==='bigint'?Number(x):x):args;return m.default?m.default[name](...values):m[name](...values);};
 const observe=(m,action)=>{const restore=snapshot(m),events=[];let value,error;try{value=action(m,events);}catch(e){error={name:e.name,message:e.message};}finally{restore();}
  assert.equal(m.finiteState().active,false,'private proof leaked');return {value:norm(value),error,events:norm(events)};};
 const boundary=(name,action)=>{const observations=bends.map(m=>observe(m,action));report.current={kind:name,observations};assert.deepEqual(observations[1],observations[0],name);report.boundaries.push(report.current);delete report.current;return observations;};
 const oracle=(name,args,expected)=>{const values=mods.map(m=>call(m,name,args));report.current={name,args:norm(args),expected,values:norm(values)};for(const value of values)assert.equal(value,expected,name);report.oracle.push(report.current);delete report.current;};
 for(const x of [0,1,17,2147483648,4294967295])for(const y of [0,1,31,4294967295]){
  oracle('choice_check',[x,y],x<y?0:u(x+y));oracle('leaf_check',[x,y],u(x+y));oracle('opaque_check',[x,y],u((x<y?x:u(x+y))+1));
  for(const flag of [false,true])oracle('closure_check',[flag,x,y],flag?u(x+y):u(x^y));
 }
 for(const x of [0,1,17,2147483648,4294967295]){
  oracle('empty_check',[x],17);oracle('alias_check',[x],u(x*4));oracle('array_check',[x],u((x===0?x:u(x^7))+x));
  const tree=candidate.finiteValue('finite.zip');assert.deepEqual(canonical(tree),[[[x],[x]],[[x],[x]]]);
  const children=[tree.a[0].a[0],tree.a[0].a[1],tree.a[1].a[0],tree.a[1].a[1]];for(const child of children)assert.equal(child,children[0],'arbitrary subtree aliases survive');
  report.admission.push({kind:'complete-tree-alias',x,tree:canonical(tree),sameReferences:true});
 }
 for(const x of [0n,1n,17n,1000n])for(const flag of [false,true])oracle('native_check',[flag,x],Number(flag?x+1n:x));
 for(const n of [0n,1n,17n])for(const m of [0n,1n,31n])oracle('argument_check',[n,m],u(Number(n+1n)^Number(m+1n)));
 for(const name of ['finite.cycle.root','finite.mutual.root']){
  const before=candidate.finiteState();oracle(name,[30000n,17],u(30017^7));const after=candidate.finiteState();
  assert.equal((after.roots[name]||0)-(before.roots[name]||0),1,'one outer force owner for deep tail cycle');
  assert((after.counts['finite.choose']||0)>(before.counts['finite.choose']||0),'terminal selector visibly entered');
  assert.equal(after.active,false);report.admission.push({kind:'deep-tail-cycle',name,steps:30000,before,after});
 }
 for(const name of ['finite.choose','finite.change','finite.score','finite.zip','finite.leaf'])assert(candidate.finiteState().counts[name]>0,'nonvacuous direct entry '+name);
 for(const [name,root,args]of [['finite.choose','choice_check',[17,31]],['finite.change','choice_check',[17,31]],['finite.score','choice_check',[17,31]],['finite.zip','alias_check',[17]],['finite.leaf','leaf_check',[17,31]],['Bool.xor','leaf_check',[17,31]]])for(const kind of ['wrap','getter','binding']){
  const before=candidate.finiteState();const rows=boundary('dependency:'+name+':'+kind,(m,e)=>{changed(m,e,name,kind);return call(m,root,args);});
  for(const row of rows)assert(row.events.length>0,'live dependency hook '+name);assert.deepEqual(candidate.finiteState(),before,'mutation must refuse private root');
 }
 for(const count of [0,1,2])boundary('prefix:'+count,m=>{const prefix=m.call(m.G.choice_check,[17,31].slice(0,count));return count===2?prefix:m.call(prefix,[17,31].slice(count));});
 const force=(m,x)=>m.call({arity:0,code:()=>x,env:null,bound:[]},[]);
 for(const kind of ['raw','forged','new','own-call','oversaturated','slot0','slot1','slot-mutation','slot-reentry','slot-throw'])boundary('entry:'+kind,(m,e)=>{
  const f=m.G.choice_check,code=f.code,a={length:2,0:17,1:31},index=kind==='slot1'?'1':'0';
  Object.defineProperty(a,index,{get(){e.push('slot:'+index);if(kind==='slot-mutation')changed(m,e,'finite.change');if(kind==='slot-reentry')e.push(['nested',m.default.choice_check(7,13)]);if(kind==='slot-throw')throw Error('slot sentinel');return index==='0'?17:31;}});
  if(kind==='raw'||kind==='forged')return force(m,Reflect.apply(code,null,[a,kind==='forged']));
  if(kind==='new')return force(m,Reflect.construct(code,[a]));if(kind==='own-call'){code.call=function(env,args){e.push('own-call');return Reflect.apply(code,env,[args]);};return m.default.choice_check(17,31);}
  if(kind==='oversaturated')return m.call(f,[17,31,99]);return m.call(f,{slice(){e.push('slice');return a;}});
 });
 const leaf=x=>({$:'BoxLeaf',a:[x]}),node=(a,b)=>({$:'BoxNode',a:[a,b]});
 for(const leftNode of [false,true])for(const rightNode of [false,true])for(const shared of [false,true])boundary('public-zip:'+leftNode+':'+rightNode+':'+shared,m=>{
  const l=leaf(7),r=shared?l:leaf(13),a=leftNode?node(l,r):l,b=rightNode?node(r,l):r;
  const before=m.finiteState(),value=m.default['finite.zip'](a,b);assert.deepEqual(m.finiteState(),before,'public tree does not gain a proof');
  assert.deepEqual(canonical(value),leftNode&&rightNode?[[[7],[shared?7:13]],[[shared?7:13],[7]]]:[0]);return canonical(value);
 });
 for(const kind of ['tag','field','left-error','right-error']){
  const rows=boundary('public-zip-hook:'+kind,(m,e)=>{const l=leaf(7),a=node(l,l),b=node(l,l);
   if(kind==='tag')Object.defineProperty(a,'$',{get(){e.push('tag');return 'BoxNode';}});
   else Object.defineProperty((kind==='right-error'?b:a).a,'0',{get(){e.push(kind);if(kind.endsWith('error'))throw Error(kind+' sentinel');return l;}});
   return m.default['finite.zip'](a,b);});for(const row of rows)assert(row.events.length>0,'public hook executes');
 }
 const limit=281474976710655n;
 for(const [label,n,m]of [['left',limit,0n],['right',0n,limit],['both',limit,limit]])for(const mode of ['plain','Error-reentry','Error-throw']){
  const rows=boundary('argument-error:'+label+':'+mode,(module,events)=>{const NativeError=Error;let caught;
   function replacement(message){events.push(['Error',message,'active',module.finiteState().active]);assert.equal(module.finiteState().active,false,'error callback cannot inherit proof');
    module.G['finite.score'].code=function(){events.push('changed-score');return 123;};const nested=module.default.choice_check(1,2);events.push(['nested',nested]);assert.equal(nested,123);
    if(mode==='Error-throw')throw new NativeError('Error callback sentinel');return new NativeError(message);}
   try{if(mode!=='plain')globalThis.Error=replacement;return module.default.argument_check(n,m);}catch(error){caught=error;throw error;}finally{globalThis.Error=NativeError;assert(caught,'actual argument must overflow');}});
  for(const row of rows){assert(row.error,'overflow must be observed');if(mode!=='plain')assert(row.events.some(e=>Array.isArray(e)&&e[0]==='nested'),'actual Error callback reentry');}
 }
 for(const key of ['push','pop','concat','slice'])boundary('Array:'+key,(m,e)=>{const original=Array.prototype[key];let calls=0;
  const value=hook(Array.prototype,key,{value:function(...a){calls++;return Reflect.apply(original,this,a);}},()=>m.default.alias_check(17));e.push(['calls',calls]);return value;});
 for(const [label,p]of [['Object',Object.prototype],['Array',Array.prototype],['Number',Number.prototype],['Boolean',Boolean.prototype],['BigInt',BigInt.prototype]])for(const key of ['request','bounce','build','code'])boundary('marker:'+label+':'+key,(m,e)=>{
  let calls=0;const value=hook(p,key,{get(){calls++;return undefined;}},()=>m.default.choice_check(17,31));e.push(['calls',calls]);return value;});
 for(const row of report.inputs)assert.deepEqual(identity(row.path),row);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracle:report.oracle.length,admission:report.admission.length,boundaries:report.boundaries.length,error:report.error}));
