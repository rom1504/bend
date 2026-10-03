// Post-calls derivative of phase42/frames/derive.mjs; parent stays unchanged.
// Saved-output mechanism ablation, not compiler output or production admission.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [input,tsArg,outArg]=process.argv.slice(2);assert(input&&tsArg&&outArg,'usage: post-calls-frames.mjs CHECKED_TREE_MODULE TS_TREE NEW_OUT');
const sha=x=>createHash('sha256').update(x).digest('hex');
const source=fs.readFileSync(input,'utf8'),receipt=JSON.parse(fs.readFileSync(input+'.json'));
assert.equal(receipt.output.sha256,sha(source));assert.equal(receipt.observation.checked,true);assert.equal(receipt.complete,true);assert.equal(receipt.observation.status,'ok');
assert(source.includes('/* private acyclic helper */'),'post-calls checked image required');
for(const row of [receipt.input,receipt.producer,receipt.attempt,receipt.compiler.api,receipt.compiler.runtime,receipt.compiler.base,receipt.compiler.driver,...receipt.verifiers])assert.equal(sha(fs.readFileSync(row.canonicalPath??row.file)),row.sha256,'consumed identity');
assert.equal(receipt.compiler.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
const pm={exports:{}};new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(pm,pm.exports);
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const slice=n=>source.slice(n.start,n.end);
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,fn));else if(v&&typeof v==='object')walk(v,fn);}}
function leaves(n){const found=[];walk(n,b=>{if(b.type==='BlockStatement'&&b.body.some(x=>x.type==='ContinueStatement'&&x.label.name==='$visit'))found.push(b);});return found;}
function ids(s,remap=null){
 const prefix='function f(){$visit:for(;;){',ast=parse(prefix+s+'}}'),where=new WeakMap(),parents=new WeakMap(),free=new Set(),references=[];
 const make=(parent,kind)=>({parent,kind,names:new Set()});
 function bind(n,scope){if(!n)return;if(n.type==='Identifier')scope.names.add(n.name);else if(n.type==='RestElement')bind(n.argument,scope);else if(n.type==='AssignmentPattern')bind(n.left,scope);else if(n.type==='ArrayPattern')n.elements.forEach(x=>bind(x,scope));else if(n.type==='ObjectPattern')n.properties.forEach(x=>bind(x.value??x.argument,scope));}
 function scan(n,scope,parent=null,key=''){
  if(!n||typeof n!=='object')return;if(n.type==='FunctionDeclaration'&&n.id)bind(n.id,scope);
  let own=scope;
  if(n.type==='Program')own=make(null,'function');
  else if(['FunctionDeclaration','FunctionExpression','ArrowFunctionExpression'].includes(n.type)){own=make(scope,'function');if(n.id)bind(n.id,own);n.params.forEach(x=>bind(x,own));}
  else if(n.type==='BlockStatement'||n.type==='CatchClause'){own=make(scope,'block');if(n.param)bind(n.param,own);}
  where.set(n,own);parents.set(n,{parent,key});
  if(n.type==='VariableDeclaration'){let target=own;if(n.kind==='var')while(target.parent&&target.kind!=='function')target=target.parent;n.declarations.forEach(d=>bind(d.id,target));}
  for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>scan(x,own,n,k));else if(v&&typeof v.type==='string')scan(v,own,n,k);}
 }
 scan(ast,make(null,'function'));
 walk(ast,n=>{if(n.type!=='Identifier'||!/^x\d+$/.test(n.name))return;const{parent,key}=parents.get(n);
  if((parent.type==='VariableDeclarator'&&key==='id')||(['FunctionDeclaration','FunctionExpression','ArrowFunctionExpression'].includes(parent.type)&&['id','params'].includes(key)))return;
  if((parent.type==='MemberExpression'&&key==='property'&&!parent.computed)||(parent.type==='Property'&&key==='key'&&!parent.computed&&parent.value!==n)||(['LabeledStatement','ContinueStatement','BreakStatement'].includes(parent.type)&&key==='label'))return;
  let scope=where.get(n);while(scope&&!scope.names.has(n.name))scope=scope.parent;if(!scope){free.add(n.name);references.push(n);}
 });
 if(remap){let result=s;const seen=new Set();for(const n of references.sort((a,b)=>b.start-a.start)){const i=remap.indexOf(n.name),key=n.start+':'+n.end;if(i>=0&&!seen.has(key)){seen.add(key);result=result.slice(0,n.start-prefix.length)+'$frame.f'+i+result.slice(n.end-prefix.length);}}return result;}
 return [...free].sort();
}
// Nested helper binders must not hide a caller's same-spelled free reference.
assert.deepEqual(ids('const z=((x17)=>x17)(x17);'),['x17']);
assert.deepEqual(ids('const x17=1;const z=((x17)=>x17)(x17);'),[]);
assert.deepEqual(ids('const z=(()=>{const x17=1;return x17})();const q=x17;'),['x17']);
assert.equal(ids('const z=((x17)=>x17)(x17);',['x17']),'const z=((x17)=>x17)($frame.f0);');
const edits=[],directEdits=[],counts=[];
for(const fn of parse(source).body.filter(n=>n.type==='FunctionDeclaration'&&slice(n).includes('/* private structural component */')&&slice(n).includes('const $frames=[];'))){
 const loop=fn.body.body.find(n=>n.type==='LabeledStatement'&&n.label.name==='$visit');assert(loop);
 const first=loop.body.body.body.find(n=>n.type==='LabeledStatement'&&n.label.name==='$step');
 const unwind=loop.body.body.body.find(n=>n.type==='WhileStatement');
 const phase=unwind.body.body.find(n=>n.type==='IfStatement');assert.equal(slice(phase.test),'$frame.phase===2');
 const second=phase.alternate;assert.equal(slice(second.test),'$frame.phase===0');
 const l0=leaves(first.body),l1=leaves(second.consequent);
 const l2=[];walk(second.alternate,n=>{if(n.type==='BlockStatement'&&n.body.some(x=>x.type==='VariableDeclaration'&&x.declarations.some(d=>d.init?.type==='MemberExpression'&&slice(d.init)==='$frame.left')))l2.push(n);});
 assert.equal(l0.length,l1.length);assert.equal(l0.length,l2.length);assert(l0.length>0);
 let initial=slice(first),directInitial=slice(first),arms1=[],arms2=[],sites=[];
 for(let i=l0.length-1;i>=0;i--){
  const a=l0[i],b=l1[i],c=l2[i],aText=slice(a);
  const next=a.body.find(n=>n.type==='VariableDeclaration'&&n.declarations[0].id.name==='$next');assert(next);
  const before=source.slice(a.start+1,next.start);
  const next1=b.body.find(n=>n.type==='VariableDeclaration'&&n.declarations[0].id.name==='$next');assert(next1);
  const right=source.slice(next1.start,b.end-1);const joinStart=c.body.find(n=>n.type==='VariableDeclaration'&&n.declarations.some(d=>d.init?.type==='MemberExpression'&&slice(d.init)==='$frame.left'));const join=source.slice(joinStart.start,c.end-1);
  const live=ids(right+join);assert(live.every(x=>new RegExp('const '+x+'=').test(source.slice(first.start,a.end))));
  const remap=s=>ids(s,live);
  const save='let $saved=$top<$frames.length?$frames[$top]:null;if(!$saved)$saved=$frames[$top]={};'+live.map((x,j)=>'$saved.f'+j+'='+x+';').join('')+'$saved.site='+i+';$saved.left=null;$saved.phase=0;++$top;';
  const transfer=source.slice(a.body.find(n=>n.type==='ExpressionStatement'&&slice(n).startsWith('$s0=$next')).start,a.end-1);
  const replacement='{'+before+slice(next)+save+transfer+'}';
  initial=initial.slice(0,a.start-first.start)+replacement+initial.slice(a.end-first.start);
  arms1.push('case '+i+':{'+remap(right)+'}');arms2.push('case '+i+':{'+remap(join)+'break;}');
  const args0=slice(next.declarations[0].init).slice(1,-1),args1=slice(next1.declarations[0].init).slice(1,-1);
  const direct='{'+before+'const $left='+fn.id.name+'('+args0+');$value='+fn.id.name+'('+args1+');'+join.replaceAll('$frame.left','$left')+'break $step;}';
  directInitial=directInitial.slice(0,a.start-first.start)+direct+directInitial.slice(a.end-first.start);
  sites.push({site:i,live,oldSavedArguments:fn.params.length});
 }
 const begin=source.slice(fn.start,loop.start),end='return $value;}';
 const candidate=begin+'$visit:for(;;){'+initial+'while($top){const $frame=$frames[$top-1];if($frame.phase===0){$frame.left=$value;$frame.phase=1;switch($frame.site){'+arms1.reverse().join('')+"default:return bad('private continuation site');}}else{switch($frame.site){"+arms2.reverse().join('')+"default:return bad('private continuation site');}--$top;}}return $value;}}";
 const direct=begin.replace('const $frames=[];let $top=0,$value;','let $value;')+directInitial+end;
 parse(candidate);parse(direct);edits.push({start:fn.start,end:fn.end,text:candidate});directEdits.push({start:fn.start,end:fn.end,text:direct});counts.push({worker:fn.id.name,sites:sites.reverse(),oldBytes:fn.end-fn.start,newBytes:candidate.length});
}
assert.equal(counts.length,4);
function apply(es){let s=source;for(const e of es.sort((a,b)=>b.start-a.start))s=s.slice(0,e.start)+e.text+s.slice(e.end);parse(s);return s;}
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);
const modules=[];for(const [role,text]of[['original',source],['noise',source],['live',apply(edits)],['recursive-ceiling',apply(directEdits)]]){const p=path.join(out,role+'.clean.mjs');fs.writeFileSync(p,text,{flag:'wx'});modules.push({role,path:p,sha256:sha(text)});}
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify({kind:'phase42-post-calls-frame-continuations',complete:true,checked:false,input:{path:fs.realpathSync(input),sha256:sha(source)},receiptSha256:sha(fs.readFileSync(input+'.json')),producerSha256:sha(fs.readFileSync(import.meta.filename)),parent:{path:path.resolve('selfhost/tools/performance/phase42/frames/derive.mjs'),sha256:sha(fs.readFileSync('selfhost/tools/performance/phase42/frames/derive.mjs'))},domain:{nativeRecursionCeiling:'diagnostic scalar tree points depth<=12 only; deep-stack refusal retained'},counts,modules},null,2)+'\n');
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-post-calls-frames.mjs'));
const catalog=JSON.parse(fs.readFileSync('selfhost/tools/performance/phase37/catalog.json')),cases=catalog.cases.filter(c=>['variation-tree-bitonic-6-17','tree-bitonic','variation-tree-bitonic-9-123'].includes(c.id)).map(c=>({id:c.id,point:c.point,modules:Object.fromEntries([...['original','noise','live','recursive-ceiling'].map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',fs.realpathSync(tsArg)]])}));assert.equal(cases.length,3);
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify({inputs:[path.join(out,'derive.json'),input,tsArg],cases},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({out,counts}));
