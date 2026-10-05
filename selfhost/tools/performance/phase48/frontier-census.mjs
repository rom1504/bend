// Data-only inspection: parse pinned generated programs, never import them.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {gunzipSync} from 'node:zlib';
const [output]=process.argv.slice(2);
assert(output,'frontier-census.mjs NEW_OUTPUT_JSON');
assert(!fs.existsSync(output),'Preserve consumed census outputs');
const hash=b=>createHash('sha256').update(b).digest('hex');
const identity=p=>{const b=fs.readFileSync(p);return {path:p,sha256:hash(b),bytes:b.length};};
function archiveMembers(file){const b=gunzipSync(fs.readFileSync(file),{maxOutputLength:64*1024*1024}),members=new Map();
  for(let at=0;at+512<=b.length;){const h=b.subarray(at,at+512);if(h.every(x=>x===0))break;
    const field=(a,z)=>h.subarray(a,z).toString().replace(/\0.*$/s,'');
    const size=parseInt(field(124,136).trim()||'0',8),prefix=field(345,500),name=(prefix?prefix+'/':'')+field(0,100);
    assert(Number.isSafeInteger(size)&&size>=0&&at+512+size<=b.length);if(h[156]===48||h[156]===0)members.set(name,b.subarray(at+512,at+512+size));
    at+=512+Math.ceil(size/512)*512;}return members;}
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const parser={exports:{}};new Function('module','exports',parserSource)(parser,parser.exports);
function nodes(root){const out=[],todo=[root];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||!n.type)continue;
  out.push(n);for(const v of Object.values(n))if(Array.isArray(v))todo.push(...v);else if(v&&typeof v==='object')todo.push(v);}return out;}
const ids=['test-morning-program','test-evening-program','test-rle-roundtrip','test-map-set-ops','scalar-region-0',
  'complete-generic-row32','coverage-expression-32','coverage-numeric-recurrence-256','coverage-unicode-text-16'];
const markers=['private contextual instances','private scalar root','private Nat loop','private scalar tree','private unary producer',
  'private first-order native component','private first-order continuation component','private tail-only component','private raw array root','private raw array tree'];
function measure(text,n){const ns=nodes(n),calls={},globals={},guards=[];
  for(const x of ns){if(x.type==='CallExpression'){
    const name=x.callee.type==='Identifier'?x.callee.name:x.callee.type==='MemberExpression'&&!x.callee.computed&&x.callee.object.type==='Identifier'?x.callee.object.name+'.'+x.callee.property.name:null;
    if(name)calls[name]=(calls[name]??0)+1;
    if(name==='get'&&x.arguments[0]?.name==='G'&&typeof x.arguments[1]?.value==='string')globals[x.arguments[1].value]=(globals[x.arguments[1].value]??0)+1;
  }if(x.type==='VariableDeclarator'&&x.id.name==='$guards'&&x.init?.type==='ArrayExpression')guards.push(x.init.elements.map(v=>v.value));}
  const code=text.slice(n.start,n.end);return {start:n.start,end:n.end,line:n.loc.start.line,characters:code.length,sha256:hash(code),
    markers:Object.fromEntries(markers.map(m=>[m,code.split('/* '+m+' */').length-1]).filter(([,n])=>n)),
    calls,globals,guards,arrayLiterals:ns.filter(x=>x.type==='ArrayExpression').length,
    objectLiterals:ns.filter(x=>x.type==='ObjectExpression').length,
    functions:ns.filter(x=>['FunctionDeclaration','FunctionExpression','ArrowFunctionExpression'].includes(x.type)).length};}
const report={kind:'phase48-static-frontier-census',complete:false,scope:'Static syntax only; includes fallback and unused declarations. No activation, dynamic allocation, causal performance, or target execution claim.',
  inputs:[identity(import.meta.filename),identity(process.execPath)],parserSha256:hash(parserSource),modules:[]};
for(const role of ['candidate','baseline','typescript']){
  const mf='selfhost/tools/performance/phase47/'+(role==='candidate'?'current':'baseline')+'/manifest.json';
  const m=JSON.parse(fs.readFileSync(mf)),archive=path.join(path.dirname(mf),m.archive.path);
  const ai=identity(archive);assert.equal(ai.sha256,m.archive.sha256);assert.equal(ai.bytes,m.archive.bytes);report.inputs.push(identity(mf),ai);
  assert.equal(m.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
  const members=archiveMembers(archive);
  for(const c of m.cases.filter(c=>ids.includes(c.id))){const info=c.modules[role];
    const b=members.get(info.path);assert(b,'Missing archive member');assert.equal(hash(b),info.sha256);assert.equal(b.length,info.bytes);
    const text=b.toString('utf8'),ast=parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module',locations:true});
    const defs=ast.body.filter(x=>x.type==='ExpressionStatement'&&x.expression.type==='AssignmentExpression'&&x.expression.left.type==='MemberExpression'
      &&x.expression.left.object.name==='G'&&typeof x.expression.left.property.value==='string');
    const functions=ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name.startsWith('$'));
    report.modules.push({id:c.id,role,module:info,archive:ai,point:c.point,sourceSha256:c.sourceSha256,compiler:m.roles[role].compiler,
      definitions:defs.map(x=>({name:x.expression.left.property.value,...measure(text,x.expression)})),
      sourceFunctions:functions.map(x=>({name:x.id.name,...measure(text,x)}))});
  }
}
assert.equal(report.modules.length,27);
report.definitionComparisons=ids.map(id=>{const [a,b]=['baseline','candidate'].map(role=>report.modules.find(m=>m.id===id&&m.role===role));
  const names=new Set([...a.definitions,...b.definitions].map(d=>d.name));return {id,changedDefinitions:[...names].filter(name=>a.definitions.find(d=>d.name===name)?.sha256!==b.definitions.find(d=>d.name===name)?.sha256)};});
const sumPath='implementation/phase47/evidence/runtime-summary.json',s=JSON.parse(fs.readFileSync(sumPath));report.inputs.push(identity(sumPath));
const ratio=c=>c.ratios['candidate/typescript'],gm=a=>Math.exp(a.reduce((s,v)=>s+Math.log(v),0)/a.length);
const severe=c=>c.id.startsWith('test-')||['scalar-region-0','complete-generic-row32'].includes(c.id);
const middle=c=>['expression','numeric-recurrence','unicode-text'].includes(c.family);
report.metrics={current:gm(s.cases.map(ratio)),groups:[]};
for(const [name,accept]of [['six-severe',severe],['expression-numeric-unicode',middle],['combined-twelve',c=>severe(c)||middle(c)],['map-records',c=>['map-churn','record-aggregation'].includes(c.family)]]){
  const rows=s.cases.filter(accept),log=rows.reduce((a,c)=>a+Math.log(ratio(c)),0),all=s.cases.reduce((a,c)=>a+Math.log(ratio(c)),0);
  report.metrics.groups.push({name,ids:rows.map(c=>c.id),shareOfLogSlowdown:log/all,ratioGeomean:gm(rows.map(ratio)),
    parityCounterfactual:gm(s.cases.map(c=>accept(c)?1:ratio(c))),threeTimesCounterfactual:gm(s.cases.map(c=>accept(c)?3:ratio(c)))});}
report.complete=true;fs.mkdirSync(path.dirname(output),{recursive:true});fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:true,modules:report.modules.length,comparisons:report.definitionComparisons,metrics:report.metrics}));
