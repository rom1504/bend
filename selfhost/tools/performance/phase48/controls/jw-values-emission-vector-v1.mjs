// Root-only execution of real checked JW emission, separate from public admission.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [attemptArg,outArg]=process.argv.slice(2);assert(outArg,'jw-values-emission-vector-v1.mjs CHECKED_ATTEMPT NEW_OUT');
const root=fs.realpathSync(attemptArg),out=path.resolve(outArg);fs.mkdirSync(out);
const report={kind:'phase48-private-vector-emission-controls',complete:false,pass:false,inputs:[],graphs:[],observations:[],
 scope:'Actual checked tuple pass and JW emitter on canonical synthetic graphs; independent scalar oracles, fresh flat-vector capture, native/machine frames, throw/reentry and budget restoration. No frontend, source admission, public ABI, timing or universal correctness claim.'};
const hash=b=>createHash('sha256').update(b).digest('hex');
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:hash(b)};};
function pin(file,want){const row=identity(file);if(want)assert.equal(row.sha256,want.sha256);report.inputs.push(row);return row;}
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function array(xs){const a=[];while(xs?.$==='Con'){assert(a.length<10000);a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;}
const s=slot=>({$:'JWSlot',slot}),n=x=>({$:'JWLiteral',code:String(x)}),g=name=>({$:'JWGlobal',name,layout:'u32'});
const op=(name,...args)=>({$:'JWPrimitive',name,args:list(args)});
const add=(x,y)=>op('U32.add',x,y),mul=(x,y)=>op('U32.mul',x,y);
const tuple=(a,b)=>({$:'JWConstruct',layout:'tuple',name:'Tuple',fields:list([a,b])});
const field=(input,index)=>({$:'JWProject',layout:'tuple',input,index});
const assign=(slot,value)=>({$:'JWAssign',slot,value}),ret=value=>({$:'JWReturn',value});
const call=(slot,target,...args)=>({$:'JWDirectCall',slot,target,args:list(args)});
const branch=(input,yes,no)=>({$:'JWCase',layout:'bool',name:'True',input,yes:list(yes),no:list(no)});
const fn=(name,arity,code)=>({$:'JWFunction',name,arity,code:list(code),valid:true});
const pairGraph=[fn('root',3,[call(3,1,s(0),s(1),s(2)),ret(add(field(s(3),0),mul(field(s(3),1),n(100))))]),
 fn('spiral',3,[branch(op('U32.is_eq',s(0),n(0)),
  [branch(s(2),[{$:'JWImpossible'}],[assign(3,tuple(n(0),g('hook'))),ret(s(3))])],
  [call(3,1,op('U32.sub',s(0),n(1)),s(1),s(2)),branch(s(1),
   [assign(4,tuple(add(field(s(3),0),s(0)),add(field(s(3),1),n(1)))),ret(s(4))],
   [assign(4,tuple(add(field(s(3),0),mul(s(0),n(3))),add(field(s(3),1),n(2)))),ret(s(4))])])])];
const leaf=(i,j)=>field(field(s(1),i),j);
const fourGraph=[fn('root',1,[call(1,1,s(0)),ret(add(add(mul(leaf(0,0),n(11)),mul(leaf(0,1),n(13))),add(mul(leaf(1,0),n(17)),mul(leaf(1,1),n(19)))))]),
 fn('fourfold',1,[branch(op('U32.is_eq',s(0),n(0)),
  [assign(1,tuple(n(1),n(2))),assign(2,tuple(n(3),n(4))),assign(3,tuple(s(1),s(2))),ret(s(3))],
  [call(1,1,op('U32.sub',s(0),n(1))),assign(2,tuple(add(leaf(0,0),s(0)),add(leaf(0,1),mul(s(0),n(3))))),
   assign(3,tuple(add(leaf(1,0),mul(s(0),n(5))),add(leaf(1,1),mul(s(0),n(7))))),assign(4,tuple(s(2),s(3))),ret(s(4))])])];
const word=x=>Number(BigInt.asUintN(32,x));
function expected(kind,depth,flag){const d=BigInt(depth),triangle=d*(d+1n)/2n;
 return kind==='four'?word(164n+268n*triangle):word((flag?1n:3n)*triangle+100n*(1n+(flag?1n:2n)*d));}
function nodes(tree){const xs=[];function visit(v){if(!v||typeof v!=='object')return;if(typeof v.type==='string')xs.push(v);for(const x of Object.values(v))if(Array.isArray(x))x.forEach(visit);else if(x&&typeof x==='object')visit(x);}visit(tree);return xs;}
const rootName='$R_114_111_111_116$tree';
try{
 pin(import.meta.filename);pin(process.execPath);pin(path.join(import.meta.dirname,'jw-values-controls-v1.mjs'));pin(path.join(import.meta.dirname,'jw-values-emission-v1.mjs'));
 const attemptFile=pin(path.join(root,'attempt.json')),attempt=JSON.parse(fs.readFileSync(attemptFile.file));
 assert(attempt.checked&&attempt.config.strictExact);
 for(const key of ['api','runtime','base','node'])pin(attempt[key].file,attempt[key]);
 assert.equal(identity(process.execPath).sha256,attempt.node.sha256);
 const gateFile=pin(path.join(root,'validation-001/report.json')),gate=JSON.parse(fs.readFileSync(gateFile.file));
 assert(gate.complete&&gate.pass&&gate.strictExact);assert.equal(gate.attempt.sha256,attemptFile.sha256);assert.equal(gate.api.sha256,attempt.api.sha256);
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
 new Function('module','exports',parserSource)(parser,parser.exports);
 const parse=text=>parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
 report.parser={version:parser.exports.version,sha256:hash(parserSource)};
 const original=fs.readFileSync(attempt.api.file,'utf8'),apiAst=parse(original);
 for(const name of ['$jw_values_functions$','$jw_emission_mode$','run_loop'])assert.equal(apiAst.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===name).length,1,name);
 assert(!original.includes('phase48ValuesEmission'));
 const diagnostic=original+'\nexport const phase48ValuesOptimize=(fs)=>run_loop($jw_values_functions$(fs,0));\nexport const phase48ValuesEmission=(fs,total)=>run_loop($jw_emission_mode$(fs,total,false));\n';
 parse(diagnostic);const diagnosticFile=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(diagnosticFile,diagnostic,{flag:'wx'});pin(diagnosticFile);
 fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
 report.derivation={parent:identity(attempt.api.file),api:identity(diagnosticFile),change:'Two appended diagnostic exports; original API byte prefix unchanged.'};
 const api=await import(pathToFileURL(diagnosticFile));
 for(const [kind,input] of [['pair',pairGraph],['four',fourGraph]]){
  const optimized=array(api.phase48ValuesOptimize(list(structuredClone(input))));
  let maxWidth=0;function inspect(v){if(!v||typeof v!=='object')return;if(v.$==='JWReturnValues')maxWidth=Math.max(maxWidth,array(v.values).length);Object.values(v).forEach(inspect);}optimized.forEach(inspect);
  assert.equal(maxWidth,kind==='four'?4:2,'Actual result-width transformation');
  const codes={};for(const [role,graph]of [['original',input],['selected',optimized]]){
   const emission=api.phase48ValuesEmission(list(graph),graph.length);assert.equal(emission.$,'JWEmission');assert(emission.recursive);assert.equal(emission.numberNat,false);
   assert.equal(parse(emission.code).body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===rootName).length,1);
   assert.equal(emission.code.split('let $workerBudget=32;').length,2);
   const file=path.join(out,kind+'-'+role+'.js');fs.writeFileSync(file,emission.code,{flag:'wx'});pin(file);codes[role]=emission.code;
  }
  assert(codes.selected.includes('/* private flat tuple transport */'));
  assert(!codes.selected.includes('$workerValue'),'Vector protocol must not retain shared scalar return registers');
  let counter=codes.selected;const edits=[],sites={native:0,restores:0,machine:0,pushes:0,nativeVectors:0,machineVectors:0,captures:0};
  for(const node of nodes(parse(counter))){
   if(node.type==='FunctionDeclaration'&&/^\$worker\d+$/.test(node.id.name)){edits.push([node.body.start+1,'$probe.machine++;']);sites.machine++;}
   if(node.type==='TryStatement'&&node.finalizer&&counter.slice(node.finalizer.start,node.finalizer.end).includes('++$workerBudget')){
    edits.push([node.block.start+1,'$probe.native++;'],[node.finalizer.start+1,'$probe.restores++;']);sites.native++;sites.restores++;}
   if(node.type==='ReturnStatement'&&node.argument?.type==='ArrayExpression'){
    assert.equal(node.argument.elements.length,maxWidth);assert(node.argument.elements.every(Boolean));
    edits.push([node.argument.start,'($probe.nativeVectors++,'],[node.argument.end,')']);sites.nativeVectors++;}
   if(node.type==='ExpressionStatement'&&node.expression.type==='AssignmentExpression'){
    const left=node.expression.left,right=node.expression.right;
    if(left.type==='MemberExpression'&&left.object.name==='$returns'){edits.push([node.start,'$probe.pushes++;']);sites.pushes++;}
    if(left.type==='Identifier'&&left.name==='$value'&&right.type==='ArrayExpression'){
     assert.equal(right.elements.length,maxWidth);assert(right.elements.every(Boolean));
     edits.push([node.end,'$probe.machineVectors++;']);sites.machineVectors++;}
   }
   if(node.type==='VariableDeclaration'&&node.declarations.some(d=>d.id.type==='Identifier'&&d.id.name==='$results')){
    assert.equal(node.kind,'const');assert.equal(node.declarations.length,1);
    const init=node.declarations[0].init;assert(init.type==='CallExpression'||init.type==='Identifier'&&init.name==='$value');
    edits.push([node.end,'$probe.capture($results);']);sites.captures++;}
  }
  for(const [name,count]of Object.entries(sites))assert(count>0,kind+' missing '+name);
  for(const [at,text]of edits.sort((a,b)=>b[0]-a[0]))counter=counter.slice(0,at)+text+counter.slice(at);
  parse(counter);const countedFile=path.join(out,kind+'-counter.js');fs.writeFileSync(countedFile,counter,{flag:'wx'});pin(countedFile);codes.counter=counter;
  report.graphs.push({kind,input,optimized,maxWidth,sites,original:identity(path.join(out,kind+'-original.js')),selected:identity(path.join(out,kind+'-selected.js')),counter:identity(countedFile)});
  const cases=[];for(const depth of [0,1,31,32,40,513])for(const flag of kind==='four'?[false]:[false,true])cases.push({depth,flag,mode:'normal',fail:false});
  if(kind==='pair')for(const depth of [40,513])for(const flag of [false,true])for(const mode of ['get-reentry','error','error-reentry'])cases.push({depth,flag,mode,fail:mode.startsWith('error')});
  for(const spec of cases){
   const observations={};for(const [role,code]of Object.entries(codes)){
    const probe={native:0,restores:0,machine:0,pushes:0,nativeVectors:0,machineVectors:0,captures:0},seen=new WeakSet(),events=[],sentinel=new Error('private worker impossible branch');let module,armed=spec.mode.includes('reentry');
    Object.defineProperty(probe,'capture',{value:vector=>{
     assert(Array.isArray(vector));assert.equal(vector.length,maxWidth);assert(!seen.has(vector),'Each captured private result must be fresh');
     for(let i=0;i<maxWidth;i++)assert(Object.hasOwn(vector,i),'Private vector field must be own');
     seen.add(vector);probe.captures++;
    }});
    const nested=()=>{const result=module.root(4,false,false);assert.equal(result,expected('pair',4,false));events.push(['nested',result,module.budget()]);};
    const get=(_book,name)=>{assert.equal(name,'hook');events.push(['hook',module.budget()]);if(armed&&spec.mode==='get-reentry'){armed=false;nested();}return 1;};
    const bad=message=>{assert.equal(message,sentinel.message);events.push(['error',module.budget()]);if(armed&&spec.mode==='error-reentry'){armed=false;nested();}throw sentinel;};
    module=new Function('bad','get','G','$probe',code+'\nreturn {root:'+rootName+',budget:()=>$workerBudget};')(bad,get,{},probe);
    assert.equal(module.budget(),32);let value,error;
    try{value=kind==='four'?module.root(spec.depth):module.root(spec.depth,spec.flag,spec.fail);}catch(e){assert.equal(e,sentinel);error={name:e.name,message:e.message};}
    if(spec.fail)assert.deepEqual(error,{name:'Error',message:sentinel.message});else{assert.equal(error,undefined);assert.equal(value,expected(kind,spec.depth,spec.flag));}
    assert.equal(module.budget(),32,'Budget restored after initial result/throw');
    const initial={...probe};
    if(role==='counter'){
     assert(initial.native>0);assert.equal(initial.native,initial.restores);
     if(spec.depth>=32)assert(initial.machine>0,'Actual deep machine fallback');else assert.equal(initial.machine,0);
     if(spec.depth>32)assert(initial.pushes>=spec.depth-32,'Actual suspended multi-result caller frames');
     assert.equal(initial.nativeVectors+initial.machineVectors,initial.captures,'Each actual returned vector is captured once');
     if(!spec.fail){assert(initial.captures>0,'Actual flat-vector transport');if(spec.depth>=32)assert(initial.machineVectors>0,'Machine returns actual vectors');}
     if(spec.mode.includes('reentry'))assert(events.some(e=>e[0]==='nested'&&e[2]===0),'Reentry while outer native budget exhausted');
    }
    const replay=kind==='four'?module.root(3):module.root(3,!spec.flag,false);assert.equal(replay,expected(kind,3,!spec.flag));assert.equal(module.budget(),32);
    if(role==='counter'){assert.equal(probe.native,probe.restores,'Replay leaves no charged native frame');assert.equal(probe.nativeVectors+probe.machineVectors,probe.captures);}
    observations[role]={value,error,events,replay,initial,afterReplay:{...probe}};
   }
   const semantics=r=>({value:r.value,error:r.error,events:r.events,replay:r.replay});
   assert.deepEqual(semantics(observations.selected),semantics(observations.original));assert.deepEqual(semantics(observations.counter),semantics(observations.selected));
   report.observations.push({kind,...spec,expected:spec.fail?null:expected(kind,spec.depth,spec.flag),roles:observations});
  }
 }
 for(const row of report.inputs)assert.deepEqual(identity(row.file),row);
 report.complete=report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,graphs:report.graphs.length,observations:report.observations.length,error:report.error}));
