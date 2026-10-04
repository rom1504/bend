// Phase43 correction: one public scalar admission; captures passed to a known worker.
// Exact-source saved-output experiment, not production compiler admission.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [baselineArg,tsArg,catalogArg,outArg]=process.argv.slice(2);
assert(baselineArg&&tsArg&&catalogArg&&outArg,'callback-derive.mjs BASELINE.mjs TS.mjs CATALOG_V2 NEW_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out));
const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({path:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const inputs=new Map();
function keep(file,expected){const row=identity(file);if(expected)assert.equal(row.sha256,expected.sha256);if(inputs.has(row.path))assert.deepEqual(row,inputs.get(row.path));inputs.set(row.path,row);return row;}
const pointer=row=>keep(row.file??row.path,row);
const catalogFile=keep(catalogArg).path,catalog=JSON.parse(fs.readFileSync(catalogFile));
assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');assert.equal(catalog.cases.length,2);
const source=keep(path.join(path.dirname(catalogFile),catalog.cases[0].source.path),catalog.cases[0].source);
assert.equal(path.basename(source.path),'callback-fixture-v2.bend');
function checked(file,role){const module=keep(file),receipt=keep(file+'.json'),data=JSON.parse(fs.readFileSync(receipt.path));
 assert.equal(data.kind,'bend-program-checked-emission');assert.equal(data.complete,true);assert.equal(data.observation.checked,true);
 assert.equal(data.observation.status,'ok');assert.equal(data.input.sha256,source.sha256);pointer(data.input);pointer(data.output);
 assert.equal(data.output.sha256,module.sha256);assert.equal(data.catalog.sha256,identity(catalogFile).sha256);pointer(data.catalog);pointer(data.producer);data.verifiers.forEach(pointer);
 if(role==='baseline'){assert.equal(data.compiler.kind,'checked-development-attempt');assert.equal(data.observation.typeAccepted,true);
  pointer(data.attempt);for(const key of ['api','runtime','base','driver'])pointer(data.compiler[key]);}
 else{assert.equal(data.compiler.kind,'checked-pinned-typescript');data.compiler.sources.forEach(pointer);}
 return{module,receipt,compiler:data.compiler};}
const baseline=checked(baselineArg,'baseline'),typescript=checked(tsArg,'typescript');keep(import.meta.filename);
const text=fs.readFileSync(baseline.module.path,'utf8');
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
new Function('module','exports',parserSource)(parserModule,parserModule.exports);assert.equal(parserModule.exports.version,'8.16.0');
const parse=s=>parserModule.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function walk(n,f){if(!n||typeof n!=='object')return;f(n);for(const[k,v]of Object.entries(n)){if(k==='start'||k==='end')continue;if(Array.isArray(v))for(const x of v)walk(x,f);else if(v?.type)walk(v,f);}}
const ast=parse(text),defs=new Map();
for(const statement of ast.body){const e=statement.type==='ExpressionStatement'&&statement.expression;if(e?.type==='AssignmentExpression'&&e.left.object?.name==='G'&&typeof e.left.property.value==='string')defs.set(e.left.property.value,statement);}
const names=['bench','callback.result','callback.make','callback.values','callback.offset','callback.map','callback.sum'];
for(const name of names)assert(defs.has(name),name);
const namedFn=statement=>{const found=[];walk(statement,n=>{if(n.type==='CallExpression'&&n.callee.name==='fn'&&n.arguments[0]?.value===2&&n.arguments[1]?.type==='FunctionExpression')found.push(n.arguments[1]);});assert.equal(found.length,1);return found[0];};
const offset=namedFn(defs.get('callback.offset'));
assert.equal(offset.body.body.length,3);const [amount,value,result]=offset.body.body;
assert.equal(amount.declarations[0].init.property.value,0);assert.equal(value.declarations[0].init.property.value,1);
assert.equal(result.type,'ReturnStatement');assert.equal(result.argument.operator,'>>>');assert.equal(result.argument.right.value,0);
assert.equal(result.argument.left.operator,'+');assert.equal(result.argument.left.left.name,value.declarations[0].id.name);assert.equal(result.argument.left.right.name,amount.declarations[0].id.name);
const root=namedFn(defs.get('bench'));assert.equal(root.body.body.length,3);assert.equal(root.body.body[2].type,'ReturnStatement');
const arg0=root.body.body[0].declarations[0].id.name,arg1=root.body.body[1].declarations[0].id.name;
assert.equal(root.body.body[0].declarations[0].init.property.value,0);assert.equal(root.body.body[1].declarations[0].init.property.value,1);
const calls=[];walk(defs.get('callback.map'),n=>{if(n.type==='CallExpression'&&n.callee.name==='jump'&&n.arguments[0]?.type==='Identifier'&&n.arguments[1]?.type==='ArrayExpression')calls.push(n);});
assert.equal(calls.length,1);const callback=calls[0];assert.equal(callback.arguments[1].elements.length,1);assert.equal(callback.arguments[1].elements[0].type,'Identifier');
const f=callback.arguments[0].name,x=callback.arguments[1].elements[0].name;
// The source graph is fixed and scalar-rooted. This check catches unexpected
// named callee additions; it deliberately does not pretend to prove function fields.
const reached=new Set(),todo=['bench'];while(todo.length){const name=todo.pop();if(reached.has(name))continue;reached.add(name);assert(defs.has(name));walk(defs.get(name),n=>{
 if(n.type==='CallExpression'&&n.callee.name==='get'&&n.arguments[0]?.name==='G'){const dep=n.arguments[1]?.value;assert(names.includes(dep));todo.push(dep);}});}
assert.deepEqual([...reached].sort(),[...names].sort());
function replace(source,edits){for(const e of edits.sort((a,b)=>b.start-a.start))source=source.slice(0,e.start)+e.text+source.slice(e.end);return source;}
function output(variant,counters){
 const edits=[],scoped=variant!=='original',direct=variant==='direct';
 const ordinary=text.slice(callback.start,callback.end);
 if(direct||counters){
  const generic=counters?'(++$p39Callbacks.generic,'+ordinary+')':ordinary;
  const fast=(counters?'++$p39Callbacks.direct,':'')+'$p43KnownOffset('+f+'.bound[0],'+x+')';
  edits.push({start:callback.start,end:callback.end,text:direct?'($p43CallbackActive&&regionProof!==null&&regionProof===$p43CallbackProof?('+fast+'):'+generic+')':generic});
 }
 let result=replace(text,edits);
 const marker='export default Object.fromEntries(Object.keys(G).map(k=>[k,(...args)=>call(get(G,k),args)]));';
 assert.equal(result.split(marker).length-1,1);
 if(scoped){
  result=result.replace(marker,'export default Object.fromEntries(Object.keys(G).map(k=>[k,(...args)=>k===\"bench\"&&args.length===2&&$p43Eligible(args[0],args[1])?$p43Admit(()=>call(get(G,k),args),false):call(get(G,k),args)]));');
  result+='\nconst $p39CallbackNames='+JSON.stringify(names)+';\nfor(const name of $p39CallbackNames)scalarCapture(name,G[name]);\n'+
   'let $p43CallbackActive=false,$p43CallbackProof=null;\n'+
   'function $p43KnownOffset(amount,value){return (value+amount)>>>0;}\n'+
   'function $p43Eligible(n,seed){return regionProof===null&&regionHostGuard()&&Number.isInteger(n)&&n>=0&&n<=4294967295&&Number.isInteger(seed)&&seed>=0&&seed<=4294967295&&localGuard($p39CallbackNames); }\n'+
   'function $p43Admit(run,diagnostic){'+(counters?'if(diagnostic)++$p39Callbacks.resultRoots;else ++$p39Callbacks.roots;':'')+
   'const previous=regionProofOpen($p39CallbackNames),active=$p43CallbackActive,proof=$p43CallbackProof;$p43CallbackActive=true;$p43CallbackProof=regionProof;try{return run();}finally{$p43CallbackActive=active;$p43CallbackProof=proof;regionProofClose(previous);}}\n';
 }
 if(counters)result+='\nconst $p39Callbacks={roots:0,resultRoots:0,direct:0,generic:0};\nexport function callbackState(){return {...$p39Callbacks,active:regionProof!==null};}\n'+
  'export function callbackReset(){for(const key of Object.keys($p39Callbacks))$p39Callbacks[key]=0;}\n'+
  'export function callbackOwnedResult(n,seed){if(!Number.isInteger(n)||n<0||n>1024||!Number.isInteger(seed)||seed<0||seed>4294967295)throw Error(\"diagnostic scalar domain\");'+
  (scoped?'if($p43Eligible(n,seed))return $p43Admit(()=>call(get(G,\"callback.result\"),[n,seed]),true);':'')+
  'return call(get(G,\"callback.result\"),[n,seed]);}\n'+
  'export function callbackStages(n,seed){if(!Number.isInteger(n)||n<0||n>1024||!Number.isInteger(seed)||seed<0||seed>4294967295)throw Error(\"diagnostic scalar domain\");const run=()=>{const fs=call(get(G,\"callback.make\"),[BigInt(n),seed]),xs=call(get(G,\"callback.values\"),[BigInt(n),seed]);return {fs,xs,result:call(get(G,\"callback.map\"),[fs,xs])};};'+
  (scoped?'if($p43Eligible(n,seed))return $p43Admit(run,true);':'')+'return run();}\n';
 parse(result);if(!scoped&&!counters)assert.equal(hash(result),baseline.module.sha256);
 return result;
}
fs.mkdirSync(out);const report={kind:'phase43-known-callback-prototype',complete:false,checked:false,certified:false,node:process.version,
 producer:identity(import.meta.filename),catalog:identity(catalogFile),source,baseline,typescript,dependencies:names,
 parserSha256:hash(parserSource),modules:[],scope:'One default-export scalar admission with no new exactCode. Known offset worker gets dynamic captured amount and element as scalar arguments. Three materialized lists unchanged. No production JPure function admission.'};
for(const counters of [false,true])for(const variant of ['original','scoped','direct']){const file=path.join(out,variant+(counters?'.diagnostic.mjs':'.clean.mjs'));fs.writeFileSync(file,output(variant,counters),{flag:'wx'});report.modules.push({variant,counters,...identity(file)});}
for(const row of inputs.values())assert.deepEqual(identity(row.path),row);report.inputs=[...inputs.values()];report.complete=true;
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const config={inputs:[path.join(out,'derive.json'),catalogFile],cases:catalog.cases.map(c=>({id:c.id,point:c.point,
 modules:Object.fromEntries([...['original','scoped','direct'].map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',typescript.module.path]])}))};
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify(config,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:true,certified:false,out}));
