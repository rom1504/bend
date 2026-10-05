// Saved-output ablation only. No generated program is imported or executed.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [input,output]=process.argv.slice(2);assert(input&&output,'numeric-constants-derive.mjs ARRAY06_MODULE NEW_OUT');
assert(!fs.existsSync(output),'Use a fresh output directory');
const hash=b=>createHash('sha256').update(b).digest('hex');
const id=p=>{const b=fs.readFileSync(p);return {path:path.resolve(p),sha256:hash(b),bytes:b.length};};
const manifestPath='selfhost/tools/performance/phase47/current/manifest.json',manifest=JSON.parse(fs.readFileSync(manifestPath));
const point=manifest.cases.find(c=>c.id==='coverage-numeric-recurrence-256'),original=fs.readFileSync(input,'utf8');
assert.equal(hash(original),point.modules.candidate.sha256);assert.equal(Buffer.byteLength(original),point.modules.candidate.bytes);
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
new Function('module','exports',parserSource)(parser,parser.exports);
const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function nodes(root){const out=[],todo=[root];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||!n.type)continue;out.push(n);
  for(const v of Object.values(n))if(Array.isArray(v))todo.push(...v);else if(v&&typeof v==='object')todo.push(v);}return out;}
const roots=nodes(parse(original)).filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.name==='G'&&n.left.property.value==='bench');
assert.equal(roots.length,1);const root=roots[0],rootText=original.slice(root.start,root.end);
assert(rootText.includes('/* private scalar root */')&&rootText.includes('$entered&&regionHostGuard()')&&rootText.includes('localGuard($guards)'));
const helpers=nodes(root.right).filter(n=>n.type==='FunctionDeclaration'&&n.id.name==='$R_112_51_55_46_110_117_109_101_114_105_99');
assert.equal(helpers.length,1);const helper=helpers[0],literalMap=new Map([[1081081856,'3.75'],[1065353216,'1'],[1232348160,'1000000']]);
const calls=nodes(helper).filter(n=>n.type==='CallExpression'&&n.callee.name==='bitsFloat');assert.equal(calls.length,3);
const edits=calls.map(n=>{assert.equal(n.arguments.length,1);const bits=n.arguments[0].value;assert(literalMap.has(bits));return {start:n.start,end:n.end,bits,replacement:literalMap.get(bits)};});
assert.equal(new Set(edits.map(x=>x.bits)).size,3);
const variants={original};
for(const mode of ['write-preserved','constants']){
  let candidate=original;for(const e of [...edits].sort((a,b)=>b.start-a.start)){
    const replacement=mode==='write-preserved'?`(floatView.setUint32(0,${e.bits},true),${e.replacement})`:e.replacement;
    candidate=candidate.slice(0,e.start)+replacement+candidate.slice(e.end);}
  parse(candidate);const delta=original.length-candidate.length;
  assert.equal(candidate.slice(0,helper.start),original.slice(0,helper.start));
  assert.equal(candidate.slice(helper.end-delta),original.slice(helper.end),'Public fallback, root guards, helpers and runtime unchanged');
  assert.equal((original.match(/Math\.fround\(/g)||[]).length,(candidate.match(/Math\.fround\(/g)||[]).length);variants[mode]=candidate;
}
function oracle(n,seed){let x=Math.fround(Math.fround(((seed%97)+1)>>>0)/100),h=seed;
  for(let i=0;i<n;i++){const y=Math.fround(Math.fround(3.75*x)*Math.fround(1-x));const z=Math.fround(y*1000000);
    h=((Math.imul(h,16777619)>>>0)^(!Number.isFinite(z)||z<0||z>=4294967296?0:Math.trunc(z)>>>0))>>>0;x=y;}return h;}
const controls=[];for(const n of [0,1,2,16,256,1024,8192])for(const seed of [0,1,17,123,4294967295])controls.push({args:[n,seed],expected:oracle(n,seed)});
fs.mkdirSync(output,{recursive:true});const modules={};for(const [name,text]of Object.entries(variants)){
  const file=path.join(output,name+'.mjs');fs.writeFileSync(file,text);modules[name]=id(file);}
const report={kind:'phase48-saved-numeric-constants-ablation',complete:true,scope:'Diagnostic only; no target execution, correctness or promotion. Removing shared DataView writes needs separate retained-view observability review.',
  inputs:[id(import.meta.filename),id(process.execPath),id(manifestPath),id(input)],compiler:manifest.roles.candidate.compiler,
  parserSha256:hash(parserSource),helper:{name:helper.id.name,start:helper.start,end:helper.end,sha256:hash(original.slice(helper.start,helper.end))},edits,
  invariants:{outsideHelperByteIdentical:true,rootGuardsByteIdentical:true,publicFallbackByteIdentical:true,allFroundCallsRetained:true},
  variants:{'write-preserved':'Retains each shared floatView.setUint32 in original order; eliminates only the canonical getFloat32 and tiny helper shell.',
    constants:'Upper bound only: omits shared-view writes and is not observationally qualified.'},modules,controls,
  proposedTiming:{points:[[256,123],[1024,123],[8192,123]],rounds:5,rotation:'rotate three roles each fresh-process round',warmupMs:1000,targetSampleMs:300,
    node:'v24.18.0',cpu:3,heapMiB:1024,rssMiB:2048,quiet:true,scope:'Root executes with existing guarded measurement tools; static producer has no timer.'}};
fs.writeFileSync(path.join(output,'manifest.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:true,edits:3,controls:controls.length,output}));
