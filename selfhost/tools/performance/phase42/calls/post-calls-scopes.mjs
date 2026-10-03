// Hoist only exact compiler-emitted acyclic helper IIFEs; preserve workers/frames.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
const[input,tsArg,outArg]=process.argv.slice(2);assert(input&&tsArg&&outArg,'usage: post-calls-scopes.mjs CHECKED_TREE_MODULE TS_TREE NEW_OUT');
const sha=x=>createHash('sha256').update(x).digest('hex'),identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const source=fs.readFileSync(input,'utf8'),receipt=JSON.parse(fs.readFileSync(input+'.json'));assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);assert.equal(receipt.observation.status,'ok');assert.equal(receipt.output.sha256,sha(source));
for(const row of[receipt.input,receipt.producer,receipt.attempt,receipt.compiler.api,receipt.compiler.runtime,receipt.compiler.base,receipt.compiler.driver,...receipt.verifiers])assert.equal(identity(row.canonicalPath??row.file).sha256,row.sha256,'consumed identity');
assert.equal(receipt.compiler.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
const pm={exports:{}};new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(pm,pm.exports);assert.equal(pm.exports.version,'8.16.0');const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const declarations=[],dedup=new Map();let sites=0;
function children(n){const result=[],seen=new Set();for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){const values=Array.isArray(v)?v:[v];for(const child of values)if(child&&typeof child.type==='string'){const key=child.start+':'+child.end+':'+child.type;if(!seen.has(key)){seen.add(key);result.push(child);}}}return result.sort((a,b)=>a.start-b.start);}
function render(n){
 if(n.type==='CallExpression'&&n.callee.type==='ArrowFunctionExpression'&&n.callee.body.type==='BlockStatement'&&source.slice(n.callee.body.start,n.callee.body.start+60).startsWith('{/* private acyclic helper */')){
  const arrow=n.callee;assert(arrow.params.every(p=>p.type==='Identifier'));assert(!arrow.async);assert(!n.arguments.some(a=>a.type==='SpreadElement'));
  const body=render(arrow.body),params=arrow.params.map(p=>p.name).join(',');
  assert(!/\$frame|\$s\d+|regionProof|callOwned\(|get\(G,/.test(body),'helper may not capture worker/proof/generic context');
  const key=params+body;let name=dedup.get(key);if(!name){name='$p42Hoisted'+dedup.size;dedup.set(key,name);declarations.push('function '+name+'('+params+')'+body);}
  ++sites;return name+'('+n.arguments.map(render).join(',')+')';
 }
 let at=n.start,result='';for(const child of children(n)){assert(child.start>=at,'overlapping AST children');result+=source.slice(at,child.start)+render(child);at=child.end;}return result+source.slice(at,n.end);
}
let hoisted=render(parse(source));assert(sites>0);hoisted+='\n'+declarations.join('\n')+'\n';parse(hoisted);
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:false});const modules=[];
for(const[role,text]of[['original',source],['noise',source],['hoisted',hoisted]]){const p=path.join(out,role+'.clean.mjs');fs.writeFileSync(p,text,{flag:'wx'});modules.push({role,...identity(p)});if(role!=='hoisted')assert.equal(sha(text),sha(source));}
const report={kind:'phase42-post-calls-helper-scopes',complete:true,checked:false,producer:identity(import.meta.filename),parent:identity(input),receipt:identity(input+'.json'),typescript:identity(tsArg),sites,uniqueHelpers:dedup.size,modules};
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-post-calls-scopes.mjs'));fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const catalog=JSON.parse(fs.readFileSync('selfhost/tools/performance/phase37/catalog.json')),cases=catalog.cases.filter(c=>['variation-tree-bitonic-6-17','tree-bitonic','variation-tree-bitonic-9-123'].includes(c.id)).map(c=>({id:c.id,point:c.point,modules:Object.fromEntries([...['original','noise','hoisted'].map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',fs.realpathSync(tsArg)]])}));assert.equal(cases.length,3);
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify({inputs:[path.join(out,'derive.json'),input,tsArg],cases},null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:true,out,sites,uniqueHelpers:dedup.size}));
