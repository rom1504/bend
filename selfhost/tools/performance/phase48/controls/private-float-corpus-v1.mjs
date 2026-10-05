// Root-only, untimed activation probe of the exact completed runtime screen.
// Original modules supply full catalog observations; derivatives only count
// specialized writes. No compiler selectors or throughput measurements here.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [catalogArg,screenArg,outArg]=process.argv.slice(2);assert(outArg,'private-float-corpus-v1.mjs CATALOG SCREEN_REPORT NEW_OUT');
const out=path.resolve(outArg);fs.mkdirSync(out);
const report={kind:'phase48-private-finite-f32-corpus-activation',complete:false,pass:false,inputs:[],modules:[],cases:[],timingEligible:false};
const hash=b=>createHash('sha256').update(b).digest('hex'),pins=new Map();
function pin(file,want){file=fs.realpathSync(file);const b=fs.readFileSync(file),row={file,sha256:hash(b),bytes:b.length};
 if(want)assert.equal(row.sha256,want);if(pins.has(file))assert.deepEqual(row,pins.get(file));else{pins.set(file,row);report.inputs.push(row);}return row;}
const read=file=>{pin(file);return JSON.parse(fs.readFileSync(file,'utf8'));};
let serial=0;const load=file=>import(pathToFileURL(fs.realpathSync(file)).href+'?finite-corpus='+serial++);
const marker='/* private finite F32 */';
try{
 pin(import.meta.filename);pin(process.execPath);
 const catalogFile=pin(catalogArg),screenFile=pin(screenArg),catalog=read(catalogArg),screen=read(screenArg);
 assert(screen.complete&&screen.pass&&screen.status==='measured');assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
 assert(screen.inputs.some(x=>x.path===catalogFile.file&&x.sha256===catalogFile.sha256),'Exact consumed catalog required');
 assert.equal(fs.realpathSync(screen.plan.node),fs.realpathSync(process.execPath));
 for(const x of screen.inputs)pin(x.path,x.sha256);
 assert.deepEqual(screen.cases.map(x=>x.id),screen.plan.selectedIds);assert.equal(new Set(screen.plan.selectedIds).size,screen.cases.length);
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
 new Function('module','exports',parserSource)(parser,parser.exports);assert.equal(parser.exports.version,'8.16.0');
 report.parser={version:parser.exports.version,sha256:hash(parserSource)};
 const parse=text=>{const comments=[];return {ast:parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module',onComment:comments}),comments};};
 function nodes(root){const found=[],todo=[root];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||!n.type)continue;found.push(n);
  for(const x of Object.values(n))if(Array.isArray(x))todo.push(...x);else if(x&&typeof x==='object')todo.push(x);}return found;}
 const derivatives=new Map();
 function instrument(file){
  const id=pin(file);if(derivatives.has(id.sha256))return derivatives.get(id.sha256);
  const text=fs.readFileSync(file,'utf8');assert(!text.includes('$p48CorpusWrites')&&!text.includes('phase48CorpusWrites'));
  const {ast,comments}=parse(text),all=nodes(ast),assignments=all.filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.name==='G'&&typeof n.left.property.value==='string');
  const sites=[],edits=[];
  for(const c of comments.filter(c=>text.slice(c.start,c.end)===marker)){
   const owners=assignments.filter(a=>a.start<c.start&&c.end<a.end);assert.equal(owners.length,1,'Selected write has one complete G assignment');
   const calls=all.filter(n=>n.type==='CallExpression'&&n.start>=c.end&&text.slice(c.end,n.start).trim()===''&&n.callee.type==='MemberExpression'&&n.callee.object.name==='floatView'&&n.callee.property.name==='setUint32');
   assert.equal(calls.length,1);const args=calls[0].arguments;assert.equal(args.length,3);assert.equal(args[0].value,0);assert.equal(args[2].value,true);
   const bits=args[1].value;assert(Number.isInteger(bits)&&bits>=0&&bits<=0xffffffff);assert.notEqual((bits>>>23)&255,255);
   edits.push({at:c.end,text:`++$p48CorpusWrites[${sites.length}],`});sites.push({root:owners[0].left.property.value,bits,offset:c.start});
  }
  let derived=text;for(const e of edits.sort((a,b)=>b.at-a.at))derived=derived.slice(0,e.at)+e.text+derived.slice(e.at);
  derived='const $p48CorpusWrites='+JSON.stringify(sites.map(()=>0))+';\n'+derived+'\nexport const phase48CorpusWrites=()=>[...$p48CorpusWrites];\n';parse(derived);
  const target=path.join(out,'activation-'+id.sha256+'.mjs');fs.writeFileSync(target,derived,{flag:'wx'});
  const row={parent:id,derivative:pin(target),sites,timingEligible:false};report.modules.push(row);derivatives.set(id.sha256,row);return row;
 }
 for(const c of screen.cases){
  const entries=catalog.cases.filter(x=>x.id===c.id);assert.equal(entries.length,1);const item=entries[0];assert.deepEqual(c.point,item.point);
  pin(path.resolve(path.dirname(catalogFile.file),item.source.path),item.source.sha256);
  const observations=[],originals={};assert.equal(c.samples.length,c.rounds*3);
  for(const role of ['baseline','candidate','typescript']){
   const rows=c.samples.filter(s=>s.role===role);assert.equal(rows.length,c.rounds);assert.equal(new Set(rows.map(x=>x.round)).size,c.rounds);
   for(const s of rows){assert(s.complete&&s.result.complete&&s.result.pass&&s.process.complete&&s.process.returncode===0);assert.deepEqual(s.result.config.args,c.point.args);assert.equal(s.result.config.exportName,c.point.exportName);assert.deepEqual(s.result.config.expected,c.point.expected);}
   const first=rows[0].result.module;assert(rows.every(x=>x.result.module.sha256===first.sha256));const id=pin(first.file,first.sha256);originals[role]=id;
   const m=await load(id.file),value=m.default[c.point.exportName](...c.point.args);assert.deepEqual(value,c.point.expected,c.id+'/'+role);observations.push({role,value});
  }
  const derivative=instrument(originals.candidate.file),m=await load(derivative.derivative.file),before=m.phase48CorpusWrites();
  const value=m.default[c.point.exportName](...c.point.args),after=m.phase48CorpusWrites();assert.deepEqual(value,c.point.expected,c.id+'/counter-only');assert(before.every(x=>x===0));
  const total=after.reduce((a,b)=>a+b,0);if(derivative.sites.length)assert(total>0,c.id+' requires an executed selected write');else assert.equal(total,0);
  const roots={};for(let i=0;i<after.length;i++){const root=derivative.sites[i].root;roots[root]=(roots[root]??0)+after[i];}
  report.cases.push({id:c.id,point:c.point,observations,baselineEqualsCandidate:originals.baseline.sha256===originals.candidate.sha256,modules:originals,
   derivative:derivative.derivative,staticSites:derivative.sites.length,siteCounts:after,rootCounts:roots,totalWrites:total,counterValue:value});
 }
 for(const row of pins.values())assert.deepEqual(pin(row.file),row);report.complete=report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,error:report.error}));
