// Independent modular oracle and untimed exhausted-budget component witness.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,typescript,output]=process.argv.slice(2);
assert(output,'exhausted-tail-controls.mjs BASELINE_MODULE CANDIDATE_MODULE TS_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase45-exhausted-tail-controls',complete:false,pass:false,inputs:[],modules:[],oracles:[],activation:[],
  scope:'Clean checked predecessor/selected/TypeScript values; separate untimed derivative proves a tail-only component enters at budget zero under pending non-tail frames. No timing claim.'};
const identity=p=>{const file=fs.realpathSync(p),bytes=fs.readFileSync(file);return {path:file,sha256:createHash('sha256').update(bytes).digest('hex'),bytes:bytes.length};};
const pinned=new Map();
function pin(file,expected){const got=identity(file);if(expected){assert.equal(got.sha256,expected.sha256);if(expected.bytes!==undefined)assert.equal(got.bytes,expected.bytes);}
  if(pinned.has(got.path))assert.deepEqual(got,pinned.get(got.path));else{pinned.set(got.path,got);report.inputs.push(got);}return got;}
function audit(x){if(Array.isArray(x))x.forEach(audit);else if(x&&typeof x==='object'){const file=x.file??x.path??x.canonicalPath;if(file&&x.sha256)pin(file,x);Object.values(x).forEach(audit);}}
function oracle(depth,tail,seed){const mask=0xffffffffn;let s=BigInt(seed),pending=0n;
  for(let n=0;n<depth;n++){pending+=s^85n;s=(s+3n)&mask;}return Number((s+7n*BigInt(tail)+pending)&mask);}
function nodes(root){const out=[],pending=[root];while(pending.length){const node=pending.pop();if(!node||typeof node!=='object'||typeof node.type!=='string')continue;out.push(node);
  for(const value of Object.values(node))if(Array.isArray(value))pending.push(...value);else if(value&&typeof value==='object')pending.push(value);}return out;}
const id=(node,name)=>node?.type==='Identifier'&&node.name===name;
try{
  pin(import.meta.filename);pin(process.execPath);
  const catalogFile=path.join(import.meta.dirname,'exhausted-tail-catalog.json'),catalogId=pin(catalogFile),catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));
  assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7','Pinned upstream identity');
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[],texts=[];
  assert.equal(oracle(...catalog.cases[0].point.args),catalog.cases[0].point.expected);
  for(const [i,file] of [baseline,candidate,typescript].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);assert.equal(emission.observation.checked,true);assert.equal(emission.observation.status,'ok');
    assert.equal(emission.compiler.kind,i===2?'checked-pinned-typescript':'checked-development-attempt');assert.equal(emission.compiler.upstreamCommit,catalog.upstreamCommit);
    assert.equal(emission.input.sha256,source.sha256);assert.equal(emission.output.sha256,module.sha256);assert.equal(emission.catalog.sha256,catalogId.sha256);audit(emission);
    report.modules.push({role:['baseline','candidate','typescript'][i],module,receipt,compiler:emission.compiler});texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  const points=[];for(const depth of [0,3,31,32])for(const tail of [0,5])for(const seed of [7,4294967295])points.push([depth,tail,seed]);
  for(const depth of [80,81])for(const seed of [0,7,4294967295])points.push([depth,50000,seed]);
  for(const args of points){const expected=oracle(...args),values=modules.map(m=>m.default.bench(...args));for(const value of values)assert.equal(value,expected);report.oracles.push({args,expected,values});}
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'}),all=nodes(parse(texts[1]));
  const roots=all.filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&id(n.left.object,'G')&&n.left.property.type==='Literal'&&n.left.property.value==='bench');
  assert.equal(roots.length,1,'One complete bench assignment');const root=roots[0],rootNodes=nodes(root),rootText=texts[1].slice(root.start,root.end);
  const marker='/* private tail-only component */',offset=rootText.indexOf(marker);assert(offset>=0);assert.equal(rootText.indexOf(marker,offset+marker.length),-1,'Exactly one tail-only wrapper in bench');
  const markerAt=root.start+offset,functions=rootNodes.filter(n=>n.type==='FunctionDeclaration');
  const wrapper=functions.filter(n=>n.body.start<markerAt&&markerAt<n.body.end).sort((a,b)=>(a.end-a.start)-(b.end-b.start))[0];assert(wrapper);
  assert.equal(wrapper.body.body.length,1);const statement=wrapper.body.body[0],call=statement.type==='ReturnStatement'?statement.argument:null;
  assert(call?.type==='CallExpression'&&call.callee.type==='Identifier'&&/^\$native\d+$/.test(call.callee.name));
  assert(call.arguments[0]?.type==='Literal'&&Number.isInteger(call.arguments[0].value));assert.equal(call.arguments.length,wrapper.params.length+1);
  wrapper.params.forEach((p,i)=>assert(p.type==='Identifier'&&id(call.arguments[i+1],p.name),'Exact positional forwarding'));
  assert(!nodes(wrapper).some(n=>n.type==='Identifier'&&/^\$worker(?:Budget|\d*)$/.test(n.name)),'Unbudgeted wrapper');
  const scopes=rootNodes.filter(n=>n.type==='BlockStatement'&&n.body.includes(wrapper));assert.equal(scopes.length,1);
  const declarations=scopes[0].body.filter(n=>n.type==='FunctionDeclaration'),native=declarations.filter(n=>n.id.name===call.callee.name);assert.equal(native.length,1);
  assert(!declarations.some(n=>n.id.name===call.callee.name.replace('$native','$worker')),'No corresponding machine for tail-only component');
  assert(texts[1].slice(native[0].body.start,native[0].body.end).includes('/* private first-order native component */'));
  const transfers=[];for(const block of nodes(native[0].body).filter(n=>n.type==='BlockStatement')){
    const body=block.body,previous=body.at(-2),assignment=previous?.type==='ExpressionStatement'?previous.expression:null;
    if(body.at(-1)?.type!=='ContinueStatement'||assignment?.type!=='AssignmentExpression'||!id(assignment.left,'$pc'))continue;
    assert(assignment.right.type==='Literal'&&Number.isInteger(assignment.right.value));transfers.push(body.at(-1).start);
  }assert(transfers.length>0,'Native loop transfer sites');
  assert(!texts[1].includes('$p45Exhausted'),'Reserved diagnostic name collision');
  const edits=[...transfers.map(at=>({at,text:'++$p45Exhausted.tails;'})),
    {at:wrapper.body.start+1,text:'const $before={budget:$workerBudget,native:$p45Exhausted.native,restored:$p45Exhausted.restored,machines:$p45Exhausted.machines,tails:$p45Exhausted.tails};try{'},
    {at:wrapper.body.end-1,text:'}finally{$p45Exhausted.events.push({before:$before,after:{budget:$workerBudget,native:$p45Exhausted.native,restored:$p45Exhausted.restored,machines:$p45Exhausted.machines,tails:$p45Exhausted.tails}});}'}];
  let changed=rootText;for(const edit of edits.sort((a,b)=>b.at-a.at)){const at=edit.at-root.start;changed=changed.slice(0,at)+edit.text+changed.slice(at);}
  const patches=[['let $workerBudget=32;','let $workerBudget=32;$p45Exhausted.readers.push(()=>$workerBudget);'],
    ['/* private contextual instances */','/* private contextual instances */++$p45Exhausted.contextual;'],
    ['/* private first-order continuation component */','/* private first-order continuation component */++$p45Exhausted.machines;'],
    ['--$workerBudget;try{','--$workerBudget;try{++$p45Exhausted.native;'],
    ['}finally{++$workerBudget;}','}finally{++$workerBudget;++$p45Exhausted.restored;}']];
  const shapes=[];for(const [old,replacement] of patches){const count=changed.split(old).length-1;assert(count>0,'Required shape '+old);shapes.push({old,replacement,count});changed=changed.replaceAll(old,replacement);}
  assert.equal(shapes[0].count,1);assert.equal(shapes[3].count,shapes[4].count);
  const derived='const $p45Exhausted={native:0,restored:0,machines:0,tails:0,contextual:0,readers:[],events:[]};\n'+texts[1].slice(0,root.start)+changed+texts[1].slice(root.end)+
    '\nexport const p45Exhausted=()=>({native:$p45Exhausted.native,restored:$p45Exhausted.restored,machines:$p45Exhausted.machines,tails:$p45Exhausted.tails,contextual:$p45Exhausted.contextual,budgets:$p45Exhausted.readers.map(f=>f()),events:$p45Exhausted.events.slice()});\n';
  parse(derived);const derivedFile=path.join(out,'candidate-counter.mjs');fs.writeFileSync(derivedFile,derived,{flag:'wx'});
  report.derivative={module:identity(derivedFile),source:report.modules[1].module,wrapper:wrapper.id.name,native:call.callee.name,scopeStart:scopes[0].start,transfers,edits,shapes,
    parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')},performanceEvidence:false};
  const witness=await import(pathToFileURL(derivedFile));
  function state(){const s=witness.p45Exhausted();assert.deepEqual(s.budgets,[32],'Budget restored outside calls');return s;}
  function observed(args){const before=state(),value=witness.default.bench(...args),after=state(),expected=oracle(...args);assert.equal(value,expected);
    const events=after.events.slice(before.events.length);assert.equal(events.length,1,'One tail-only entry, including zero-step loop');const event=events[0];
    assert.equal(after.contextual-before.contextual,1);assert.equal(after.native-before.native,after.restored-before.restored);
    for(const field of ['budget','native','restored','machines'])assert.equal(event.before[field],event.after[field],'Tail path leaves '+field+' unchanged');
    assert.equal(event.after.tails-event.before.tails,args[1],'Exact native tail transfer count');
    if(args[0]>=80){assert.equal(event.before.budget,0,'Tail-only component entered at exhausted budget');assert(after.machines>before.machines,'Outer non-tail recursion used machine fallback');assert.equal(after.native-before.native,32);}
    report.activation.push({args,expected,value,before:{...before,events:undefined},event,after:{...after,events:undefined}});}
  for(const args of points){observed(args);if(args[0]>=80){const replay=[3,5,7];for(const m of modules)assert.equal(m.default.bench(...replay),oracle(...replay));observed(replay);}}
  for(const item of pinned.values())assert.deepEqual(identity(item.path),item,'Changed input');assert.deepEqual(identity(derivedFile),report.derivative.module);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,activation:report.activation.length,error:report.error}));
