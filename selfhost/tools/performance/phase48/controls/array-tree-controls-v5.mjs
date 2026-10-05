// Independent untimed controls for raw arrays embedded in a private Nat tree.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,output]=process.argv.slice(2);
assert(output,'array-tree-controls-v5.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase48-independent-array-tree-controls-v5',complete:false,pass:false,inputs:[],modules:[],oracles:[],boundaries:[],
  scope:'Checked source observations and separately instrumented composed array/tree entry. Only Number-getter uses both ungranted ordinary roots as oracle; historical public baseline must retain exactly two extra leading getter reads. No timing, promotion or replacement of other array controls.'};
const pinned=new Map(),apply=Reflect.apply,define=Object.defineProperty,descriptor=Object.getOwnPropertyDescriptor;
const OriginalNumber=Number,OriginalArray=Array,OriginalError=Error;
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {path:file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
function pin(file,want){const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(x.bytes,want.bytes);}
  if(pinned.has(x.path))assert.deepEqual(x,pinned.get(x.path));else{pinned.set(x.path,x);report.inputs.push(x);}return x;}
function audit(v){if(Array.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){
  const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
const wrap=x=>x>>>0;
function leaf(turns,seed,flag){let arrays=[Array(4).fill(seed),Array(4).fill(wrap(seed+1))],total=0;
  for(let i=0;i<turns;i++){
    const x=arrays[0][i%4],y=arrays[1][(i+1)%4];total=wrap(total+x+y+1);
    arrays[0][i%4]=wrap(total^i);arrays[1][(i+1)%4]=total;if(flag)arrays=[arrays[1],arrays[0]];
  }return total;}
function tree(depth,turns,seed,flag){if(depth===0)return leaf(turns,seed,flag);
  const left=tree(depth-1,turns,seed,flag),right=tree(depth-1,turns,wrap(seed+2**(depth-1)),flag);
  return wrap(left*3+(right^85));}
const thrown=e=>({type:typeof e,name:e?.name??null,message:e?.message??String(e)});
function scenario(m,name,ordinary=false){assert(!ordinary||name==='Number-getter','Ordinary oracle is limited to the documented historical guard bug');const events=[],restores=[],backings=[],sentinel=new OriginalError('array/tree boundary sentinel');let value,error,sameError=false;
  const log=x=>events.push(x),patch=(owner,key,desc)=>{const old=descriptor(owner,key);restores.push(()=>old?define(owner,key,old):delete owner[key]);define(owner,key,{configurable:true,...desc});};
  const number=(resize,throws)=>{let count=0;const f=function(v){log(['Number',typeof v,String(v)]);
    if(throws&&typeof v==='number'&&v===0)throw sentinel;if(resize){count++;resize.length=count%2===0?2:4;}return OriginalNumber(v);};
    Object.setPrototypeOf(f,OriginalNumber);return f;};
  try{
    if(name==='Number-wrapper'||name==='Number-throws')patch(globalThis,'Number',{writable:true,value:number(null,name==='Number-throws')});
    else if(name==='Number-getter')patch(globalThis,'Number',{get(){log('Number:get');return OriginalNumber;}});
    else if(name.startsWith('fill-')){const fill=OriginalArray.prototype.fill;let busy=false,late=false;
      patch(OriginalArray.prototype,'fill',{writable:true,value:function(...args){log(['fill',args[0]]);if(name==='fill-throws')throw sentinel;
        const result=apply(fill,this,args);backings.push(result);
        if(name==='fill-late-Number-resize'&&!late){late=true;patch(globalThis,'Number',{writable:true,value:number(result,false)});}
        if(name==='fill-reentry'&&!busy){busy=true;try{log(['nested',m.default.canopy(0n,0,11,false)]);}finally{busy=false;}}
        return result;}});
    }else if(name==='source-leaf'||name==='native-get'||name==='native-set'){
      const key=name==='source-leaf'?'leaf':name==='native-get'?'Array.get':'Array.set',f=m.G[key];assert(f,'Missing dependency '+key);const code=f.code;
      patch(f,'code',{writable:true,value:function(args){log(key);return apply(code,this,[args]);}});
    }else throw new OriginalError('Unknown scenario '+name);
    value=ordinary?m.call(m.G.canopy.code.call(m.G.canopy.env,[2n,3,7,true]),[]):m.default.canopy(2n,3,7,true);
  }catch(e){error=thrown(e);sameError=e===sentinel;}
  finally{for(let i=restores.length-1;i>=0;i--)restores[i]();}
  assert(events.length,name+' did not witness the intended boundary');
  if(name==='Number-throws'||name==='fill-throws'){assert(sameError,'Original sentinel identity');assert(error);}
  else{assert.equal(error,undefined);if(name!=='fill-late-Number-resize')assert.equal(value,tree(2,3,7,true));}
  if(name==='fill-wrapper')assert.equal(backings.length,8,'Two fresh arrays per leaf');
  if(name==='fill-reentry')assert(events.some(x=>Array.isArray(x)&&x[0]==='nested'&&x[1]===0));
  if(name==='fill-late-Number-resize')assert(events.filter(x=>Array.isArray(x)&&x[0]==='Number').length>2,'Mutation must continue after the first conversion');
  return {value,error,sameError,events,backings:backings.map(a=>a.slice())};
}
function publicTransport(m){let demands=0;const storage={get array(){demands++;throw new OriginalError('Public storage must not be read');}};
  const result=m.default.exposed(2n,3,7,false,storage);assert.equal(result[0],storage);assert.equal(result[1],tree(2,3,7,false));assert.equal(demands,0);
  return {value:result[1],sameStorage:true,demands};}
try{
  pin(import.meta.filename);pin(process.execPath);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  const historical=path.resolve(import.meta.dirname,'../../phase47/controls');
  report.parent=pin(path.join(historical,'array-tree-controls-v4.mjs'),{sha256:'947359682c329d44791c431e795f6030967e52bfa71422f878d778ee6d324c48'});
  const catalogId=pin(path.join(historical,'array-tree-catalog-v4.json')),catalog=JSON.parse(fs.readFileSync(catalogId.path,'utf8'));
  assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
  const source=pin(path.join(historical,catalog.cases[0].source.path),catalog.cases[0].source),modules=[],texts=[];
  for(const [i,file]of [baseline,candidate].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');
    assert.equal(r.output.sha256,module.sha256);assert.equal(r.input.sha256,source.sha256);assert.equal(r.catalog.sha256,catalogId.sha256);
    assert.equal(r.compiler.upstreamCommit,catalog.upstreamCommit);assert(['checked-development-attempt','installed-checked-release'].includes(r.compiler.kind));audit(r);
    report.modules.push({role:i?'candidate':'baseline',module,receipt,compiler:r.compiler});texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  assert.equal(tree(3,5,7,true),catalog.cases[0].point.expected,'Independent catalog anchor');
  for(const depth of [0,1,2,3,4])for(const turns of [0,1,5,9])for(const seed of [0,7,4294967295])for(const flag of [false,true]){
    const expected=tree(depth,turns,seed,flag),values=modules.map(m=>m.default.canopy(BigInt(depth),turns,seed,flag));
    for(const value of values)assert.equal(value,expected);report.oracles.push({root:'canopy',depth,turns,seed,flag,expected,values});}
  for(const turns of [0,1,5,9])for(const seed of [0,7,4294967295])for(const flag of [false,true]){
    const expected=leaf(turns,seed,flag),values=modules.map(m=>m.default.leaf(turns,seed,flag));
    for(const value of values)assert.equal(value,expected);report.oracles.push({root:'leaf',turns,seed,flag,expected,values});}
  for(const depth of [0,1,2,3,4])for(const seed of [0,7,4294967295]){
    const expected=tree(depth,5,seed,true),values=modules.map(m=>m.default.bench(depth,seed));
    for(const value of values)assert.equal(value,expected);report.oracles.push({root:'bench',depth,seed,expected,values});}
  const cases=['Number-wrapper','Number-getter','Number-throws','fill-wrapper','fill-throws','fill-reentry','fill-late-Number-resize','source-leaf','native-get','native-set'];
  for(const name of cases){const observations=modules.map(m=>scenario(m,name));
    if(name==='Number-getter'){
      const ordinary=modules.map(m=>scenario(m,name,true));
      assert.deepEqual(ordinary[1],ordinary[0],name+' ordinary roots and nested calls agree');
      assert.deepEqual(observations[1],ordinary[0],name+' candidate public must match ordinary source');
      assert.equal(ordinary[0].value,tree(2,3,7,true));assert.equal(ordinary[0].error,undefined);
      assert(ordinary[0].events.length>0);assert(ordinary[0].events.every(e=>e==='Number:get'));
      assert.deepEqual(observations[0],{...ordinary[0],events:['Number:get','Number:get',...ordinary[0].events]},name+' historical public guard adds exactly two leading reads');
      report.boundaries.push({name,observations,ordinary,oracle:'Equal baseline/candidate ungranted canopy execution including nested calls; candidate public agrees. Historical baseline public has exactly two additional leading Number:get observations.'});
    }else{assert.deepEqual(observations[1],observations[0],name);report.boundaries.push({name,observations});}}
  const observations=modules.map(publicTransport);assert.deepEqual(observations[1],observations[0]);report.boundaries.push({name:'public-storage-transport',observations});
  report.correctnessPass=true;
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  function nodes(root){const todo=[root],found=[];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||typeof n.type!=='string')continue;found.push(n);
    for(const x of Object.values(n))if(Array.isArray(x))todo.push(...x);else if(x&&typeof x==='object')todo.push(x);}return found;}
  const roots=(text,name)=>nodes(parse(text)).filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.computed&&n.left.property.type==='Literal'&&n.left.property.value===name);
  const oldMarker='/* private scalar tree */',marker='/* private raw array tree */',old=roots(texts[0],'canopy');
  report.activation={status:'pending',entries:[],hookRefusals:[],publicRootRefused:false};
  assert(old.some(n=>texts[0].slice(n.right.start,n.right.end).includes(oldMarker)),'Baseline did not exercise the existing private scalar-tree emitter');
  assert(old.every(n=>!texts[0].slice(n.right.start,n.right.end).includes(marker)),'Baseline must precede array/tree composition');
  const selected=roots(texts[1],'canopy').filter(n=>texts[1].slice(n.right.start,n.right.end).includes(marker));
  if(selected.length!==1)report.activation.status='refused';assert.equal(selected.length,1,'The private tree, not merely its public leaf, must select raw arrays');
  const row=selected[0],body=texts[1].slice(row.right.start,row.right.end);assert.equal(body.split(marker).length-1,1);
  const exposed=roots(texts[1],'exposed');assert(exposed.length);assert(exposed.every(n=>!texts[1].slice(n.right.start,n.right.end).includes(marker)&&!texts[1].slice(n.right.start,n.right.end).includes('/* private raw array root */')));
  report.activation.publicRootRefused=true;
  const rawBodies=nodes(row.right).filter(n=>n.type==='VariableDeclarator'&&n.id.type==='Identifier'&&n.id.name==='$arrayViewTreeBody');
  assert.equal(rawBodies.length,1,'Unique lexical raw tree body');
  const leaves=nodes(rawBodies[0].init).filter(n=>n.type==='FunctionDeclaration'&&n.id?.name==='$R_108_101_97_102');
  assert.equal(leaves.length,1,'Unique renamed leaf helper inside the raw tree closure');
  assert(!texts[1].includes('$p47ArrayTreeEntries')&&!texts[1].includes('$p47ArrayTreeLeaves'));
  const at=row.right.start+body.indexOf(marker)+marker.length,leafAt=leaves[0].body.start+1;
  const insertions=[{at,text:'$p47ArrayTreeEntries++;'},{at:leafAt,text:'$p47ArrayTreeLeaves++;'}];let derived=texts[1];
  for(const x of [...insertions].sort((a,b)=>b.at-a.at))derived=derived.slice(0,x.at)+x.text+derived.slice(x.at);
  derived='let $p47ArrayTreeEntries=0,$p47ArrayTreeLeaves=0;\n'+derived+'\nexport const phase47ArrayTreeEntries=()=>$p47ArrayTreeEntries;\nexport const phase47ArrayTreeLeaves=()=>$p47ArrayTreeLeaves;\n';parse(derived);
  const file=path.join(out,'candidate-tree-counter.mjs');fs.writeFileSync(file,derived,{flag:'wx'});
  report.derivative={module:identity(file),parent:report.modules[1].module,root:'canopy',insertions,leafCounterScope:'Only the private leaf inside $arrayViewTreeBody; old zero/fallback paths are excluded',
    parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')},performanceEvidence:false};
  const witness=await import(pathToFileURL(file));
  for(const depth of [0,1,2,3,4])for(const turns of [0,1,5])for(const flag of [false,true]){
    const before=witness.phase47ArrayTreeEntries(),beforeLeaves=witness.phase47ArrayTreeLeaves(),value=witness.default.canopy(BigInt(depth),turns,7,flag),entries=witness.phase47ArrayTreeEntries()-before,leaves=witness.phase47ArrayTreeLeaves()-beforeLeaves;
    assert.equal(value,tree(depth,turns,7,flag));assert.equal(entries,depth===0?0:1,'Zero arm stays old; positive tree enters once');
    assert.equal(leaves,depth===0?0:2**depth,'Every positive-tree leaf executes once inside the raw closure');report.activation.entries.push({depth,turns,flag,entries,leaves});}
  for(const name of cases){const before=witness.phase47ArrayTreeEntries(),beforeLeaves=witness.phase47ArrayTreeLeaves(),observation=scenario(witness,name),entries=witness.phase47ArrayTreeEntries()-before,leaves=witness.phase47ArrayTreeLeaves()-beforeLeaves;
    assert.deepEqual(observation,report.boundaries.find(x=>x.name===name).observations[1]);assert.equal(entries,0,name+' must refuse new tree entry');assert.equal(leaves,0);report.activation.hookRefusals.push({name,entries,leaves});}
  // The public wrapper cannot itself own raw storage. Its scalar canopy child
  // may legitimately enter once; public storage must still remain undemanded.
  assert.deepEqual(publicTransport(witness),report.boundaries.find(x=>x.name==='public-storage-transport').observations[1]);
  assert.deepEqual(identity(file),report.derivative.module);report.activation.status='pass';
  for(const x of pinned.values())assert.deepEqual(identity(x.path),x);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,activation:report.activation?.status,error:report.error}));
