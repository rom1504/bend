// Exact-source singleton/composition closure ablation; no production admission.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
const [baseArg,tsArg,catalogArg,rootName,outArg]=process.argv.slice(2);assert(outArg,'closure-derive.mjs BASE TS CATALOG ROOT_EXPORT NEW_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out));
const hash=x=>createHash('sha256').update(x).digest('hex');const identity=p=>({path:fs.realpathSync(p),sha256:hash(fs.readFileSync(p))});
const baseline=identity(baseArg),typescript=identity(tsArg),catalogFile=identity(catalogArg),catalog=JSON.parse(fs.readFileSync(catalogArg));
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};new Function('module','exports',parserSource)(pm,pm.exports);
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),text=fs.readFileSync(baseArg,'utf8'),ast=parse(text),defs=new Map();
function walk(n,f){if(!n||typeof n!=='object')return;f(n);for(const[k,v]of Object.entries(n)){if(k==='start'||k==='end')continue;if(Array.isArray(v))v.forEach(x=>walk(x,f));else if(v?.type)walk(v,f);}}
for(const s of ast.body){const e=s.type==='ExpressionStatement'&&s.expression;if(e?.type==='AssignmentExpression'&&e.left.object?.name==='G'&&typeof e.left.property.value==='string')defs.set(e.left.property.value,s);}
const root=defs.get(rootName);assert(root);const rootDeps=[];walk(root,n=>{if(n.type==='CallExpression'&&n.callee.name==='get'&&n.arguments[0]?.name==='G')rootDeps.push(n.arguments[1].value);});assert.equal(rootDeps.length,1);
const chainName=rootDeps[0],chain=defs.get(chainName);assert(chain);const calls=[];walk(chain,n=>{if(n.type==='CallExpression'&&n.callee.name==='get'&&n.arguments[0]?.name==='G')calls.push(n);});
const composeNames=[...new Set(calls.map(n=>n.arguments[1].value).filter(n=>n!==chainName))];assert.equal(composeNames.length,1);const composeName=composeNames[0],compose=defs.get(composeName);assert(compose);
// Audit the fixed composition ABI: erased slots 0..2, f/g at 3/4, x at 5.
assert.match(text.slice(compose.start,compose.end),/fn\(6,function\(a\)/);assert.match(text.slice(compose.start,compose.end),/return jump\([^,]+,\[callOwned\([^,]+,\[[^\]]+\]\)\]\)/);
const scalarFns=[];walk(chain,n=>{if(n.type==='CallExpression'&&n.callee.name==='fn'&&n.arguments[0]?.value===1&&n.arguments[1]?.type==='FunctionExpression')scalarFns.push(n);});assert.equal(scalarFns.length,3);
const offsets=scalarFns.filter(n=>n.arguments[1].body.body[1]?.argument?.type==='BinaryExpression');assert.equal(offsets.length,1);const offset=offsets[0],body=offset.arguments[1].body;
assert.equal(body.body.length,2);const value=body.body[0].declarations[0].id.name,ret=body.body[1].argument;assert.equal(ret.operator,'>>>');assert.equal(ret.right.value,0);assert.equal(ret.left.operator,'+');assert.equal(ret.left.left.name,value);assert.equal(ret.left.right.type,'Identifier');const capture=ret.left.right.name;
const zero=scalarFns.find(n=>n!==offset&&n.arguments[1].body.body.length===2&&n.arguments[1].body.body[1]?.argument?.type==='Identifier');assert(zero);assert.equal(zero.arguments[1].body.body[0].declarations[0].id.name,zero.arguments[1].body.body[1].argument.name);
const names=[rootName,chainName,composeName];
function edit(s,edits){for(const e of edits.sort((a,b)=>b.start-a.start))s=s.slice(0,e.start)+e.text+s.slice(e.end);return s;}
function emit(variant,counters){let s=text;const direct=variant==='direct',scoped=variant!=='original';if(scoped){
 const e=[{start:chain.expression.left.start-chain.start,end:chain.expression.left.end-chain.start,text:'$p43Chain'}];
 for(const n of calls.filter(n=>n.arguments[1].value===chainName))e.push({start:n.start-chain.start,end:n.end-chain.start,text:'$p43Chain'});
 if(direct)e.push({start:offset.start-chain.start,end:offset.end-chain.start,text:'fn(2,a=>$p43KnownOffset(a[0],a[1]),null,['+capture+'])'});
 const clone=edit(text.slice(chain.start,chain.end),e);
 const marker='export default Object.fromEntries(Object.keys(G).map(k=>[k,(...args)=>call(get(G,k),args)]));';assert.equal(s.split(marker).length-1,1);
 s=s.replace(marker,'export default Object.fromEntries(Object.keys(G).map(k=>[k,(...args)=>k==='+JSON.stringify(rootName)+'&&args.length===2&&$p43Eligible(args)?$p43Run(args):call(get(G,k),args)]));');
 s+='\nconst $p43Names='+JSON.stringify(names)+';for(const name of $p43Names)scalarCapture(name,G[name]);\nlet $p43Chain;'+clone+'\nfunction $p43KnownOffset(amount,value){return (value+amount)>>>0;}\n'+
 'function $p43Eligible(a){return regionProof===null&&regionHostGuard()&&Number.isInteger(a[0])&&a[0]>=0&&a[0]<=4294967295&&Number.isInteger(a[1])&&a[1]>=0&&a[1]<=4294967295&&localGuard($p43Names);}\n'+
 'function $p43Run(a){'+(counters?'++$p43Count.roots;':'')+'const previous=regionProofOpen($p43Names);try{let f=call($p43Chain,[BigInt(a[0])]),value=a[1];'+
 (direct?'while(f.bound.length){'+(counters?'++$p43Count.direct;':'')+'const bindings=f.bound;value=$p43KnownOffset(bindings[3].bound[0],value);f=bindings[4];}return value;':'return call(f,[value]);')+
 '}finally{regionProofClose(previous);}}\n';
 }
 if(counters)s+='\nconst $p43Count={roots:0,direct:0};export const callbackState=()=>({...$p43Count,active:regionProof!==null});export const callbackReset=()=>{$p43Count.roots=0;$p43Count.direct=0;};\n'+(scoped?'export function callbackMaterialized(n){if(!$p43Eligible([n,0]))return call(get(G,'+JSON.stringify(chainName)+'),[BigInt(n)]);const previous=regionProofOpen($p43Names);try{return call($p43Chain,[BigInt(n)]);}finally{regionProofClose(previous);}}\n':'export const callbackMaterialized=n=>call(get(G,'+JSON.stringify(chainName)+'),[BigInt(n)]);\n');parse(s);return s;}
fs.mkdirSync(out);const report={kind:'phase43-composition-materialized',complete:false,certified:false,baseline,typescript,catalog:catalogFile,rootName,dependencies:names,modules:[],inputs:[identity(import.meta.filename),baseline,typescript,catalogFile],scope:'Known scalar captured closures plus composition; complete chain construction remains generic/trampolined and materialized. No closed-form substitution or fusion.'};
for(const counters of [false,true])for(const variant of ['original','scoped','direct']){const file=path.join(out,variant+(counters?'.diagnostic.mjs':'.clean.mjs'));fs.writeFileSync(file,emit(variant,counters),{flag:'wx'});report.modules.push({variant,counters,...identity(file)});}
const baselineReceipt=JSON.parse(fs.readFileSync(baseArg+'.json'));const cases=catalog.cases.filter(c=>c.point.exportName===rootName&&c.source.sha256===baselineReceipt.input.sha256);
assert(cases.length);for(const c of cases){const receipt=JSON.parse(fs.readFileSync(baseArg+'.json'));assert.equal(receipt.input.sha256,c.source.sha256);assert.equal(receipt.output.sha256,baseline.sha256);assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);}
report.complete=true;fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n');fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify({inputs:[path.join(out,'derive.json')],cases:cases.map(c=>({id:c.id,point:c.point,modules:Object.fromEntries([...['original','scoped','direct'].map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',typescript.path]])}))},null,2)+'\n');console.log(JSON.stringify({complete:true,out,certified:false}));
