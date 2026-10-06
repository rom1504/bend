// Data-only census and exact-body sharing derivative; never imports the image.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [inputArg,outArg]=process.argv.slice(2);
assert(inputArg&&outArg&&process.argv.length===4);
const input=fs.realpathSync(inputArg),out=path.resolve(outArg);
const phaseRoot=fs.realpathSync(path.resolve(path.dirname(import.meta.filename),'../../../../build/phase58'));
assert(out.startsWith(phaseRoot+path.sep),'Output must be a fresh Phase58 raw directory');
assert.equal(path.dirname(out),fs.realpathSync(path.dirname(out)),'Output parent must be canonical');
fs.mkdirSync(out,{recursive:false});
const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({file,sha256:hash(fs.readFileSync(file)),bytes:fs.statSync(file).size});
const parent=identity(input),producer=identity(import.meta.filename),text=fs.readFileSync(input,'utf8');
const emissionFile=path.join(path.dirname(input),'report.json'),emission=JSON.parse(fs.readFileSync(emissionFile,'utf8'));
assert(emission.complete&&emission.pass);assert.equal(emission.module.sha256,parent.sha256);assert.equal(emission.module.bytes,parent.bytes);
const runtime=identity(emission.directRuntime.file);assert.equal(runtime.sha256,emission.directRuntime.sha256);
assert(text.startsWith(fs.readFileSync(runtime.file,'utf8')+'\n'));
const emissionIdentity=identity(emissionFile);
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};
new Function('module','exports',parserSource)(pm,pm.exports);
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const ast=parse(text),groups=new Map(),names=new Set();
for(const f of ast.body){
  if(f.type!=='FunctionDeclaration')continue;
  assert(!names.has(f.id.name));names.add(f.id.name);
  if(!f.id.name.startsWith('$jd$')||f.body.body.length!==2)continue;
  const [pc,loop]=f.body.body;
  if(pc.type!=='VariableDeclaration'||pc.kind!=='let'||pc.declarations.length!==1)continue;
  const d=pc.declarations[0];
  if(d.id.type!=='Identifier'||d.id.name!=='$pc'||d.init?.type!=='Literal'||!Number.isInteger(d.init.value))continue;
  if(loop.type!=='ForStatement'||loop.init||loop.test||loop.update||loop.body.type!=='SwitchStatement')continue;
  if(loop.body.discriminant.type!=='Identifier'||loop.body.discriminant.name!=='$pc')continue;
  assert(f.params.every((p,i)=>p.type==='Identifier'&&p.name===`$a${i}`));
  assert(loop.body.cases.length>1);
  loop.body.cases.forEach((c,i)=>assert(c.test?.type==='Literal'&&c.test.value===i));
  const body=text.slice(loop.start,loop.end),key=hash(body),row={name:f.id.name,pc:d.init.value,start:f.start,end:f.end,params:f.params.map(p=>p.name)};
  if(!groups.has(key))groups.set(key,{body,caseCount:loop.body.cases.length,rows:[]});
  assert.equal(groups.get(key).body,body);groups.get(key).rows.push(row);
}
const edits=[],result=[];
for(const [bodyHash,g]of groups){
  g.rows.sort((a,b)=>a.pc-b.pc);
  assert.equal(g.rows.length,g.caseCount,'All component entries must survive in this derivative');
  g.rows.forEach((r,i)=>{assert.equal(r.pc,i);assert.deepEqual(r.params,g.rows[0].params);});
  const leader=g.rows[0].name,dispatcher=leader+'$scc';assert(!names.has(dispatcher));names.add(dispatcher);
  const references=g.rows.map(r=>`\n/*JD_REF:${r.name}*/`).join('');
  const shared=`function ${dispatcher}(${['$pc',...g.rows[0].params].join(',')}){${references}${g.body}}\n`;
  let beforeBytes=0,afterBytes=0;
  for(const row of g.rows){
    const replacement=(row.pc===0?shared:'')+`function ${row.name}(${row.params.join(',')}){return (\n/*JD_REF:${leader}*/${dispatcher}(${[String(row.pc),...row.params].join(',')}));}`;
    edits.push({start:row.start,end:row.end,before:text.slice(row.start,row.end),after:replacement});
    beforeBytes+=Buffer.byteLength(text.slice(row.start,row.end));afterBytes+=Buffer.byteLength(replacement);
  }
  result.push({leader,dispatcher,bodyHash,members:g.rows.map(r=>({name:r.name,pc:r.pc,start:r.start,end:r.end})),caseCount:g.caseCount,parameterWidth:g.rows[0].params.length,bodyBytes:Buffer.byteLength(g.body),beforeBytes,afterBytes,savedBytes:beforeBytes-afterBytes});
}
edits.sort((a,b)=>a.start-b.start);for(let i=1;i<edits.length;i++)assert(edits[i-1].end<=edits[i].start);
let derived=text;for(const e of [...edits].reverse())derived=derived.slice(0,e.start)+e.after+derived.slice(e.end);
let restored=derived,offset=0;const inverse=[];
for(const e of edits){const start=e.start+offset;inverse.push({start,end:start+e.after.length,before:e.before});offset+=e.after.length-(e.end-e.start);}
for(const e of inverse.reverse())restored=restored.slice(0,e.start)+e.before+restored.slice(e.end);assert.equal(restored,text);
assert(derived.startsWith(fs.readFileSync(runtime.file,'utf8')+'\n'));
const next=parse(derived),byName=new Map(next.body.filter(f=>f.type==='FunctionDeclaration').map(f=>[f.id.name,f]));
assert.equal(byName.size,next.body.filter(f=>f.type==='FunctionDeclaration').length);
for(const g of result){const d=byName.get(g.dispatcher);assert.equal(d.body.body.length,1);assert.equal(hash(derived.slice(d.body.body[0].start,d.body.body[0].end)),g.bodyHash);}
const module=path.join(out,'compiler.mjs');fs.writeFileSync(module,derived,{flag:'wx'});
result.sort((a,b)=>b.savedBytes-a.savedBytes);
const report={kind:'phase58-data-only-shared-scc-census',complete:true,pass:true,diagnosticOnly:true,productionQualified:false,exactInverse:true,exactLoopBodyIdentity:true,emission:emissionIdentity,runtime,parent,producer,node:identity(fs.realpathSync(process.execPath)),parser:{source:'Node internal Acorn',sha256:hash(parserSource)},output:identity(module),groupCount:result.length,entryCount:result.reduce((n,g)=>n+g.caseCount,0),duplicatedLoopBytes:result.reduce((n,g)=>n+(g.caseCount-1)*g.bodyBytes,0),savedBytes:parent.bytes-fs.statSync(module).size,groups:result,scope:'Exact top-level mutual-component loop bodies only. One private dispatcher plus fixed-PC wrappers preserves original parameter widths. Every wrapper marks its canonical leader, which explicitly marks every member; all original loop bytes and JD_REF dependencies are retained once. Syntax and body-identity checks only; no target execution, throughput or semantic qualification.'};
for(const p of [parent,producer,report.node,runtime,emissionIdentity])assert.deepEqual(identity(p.file),p);
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({groups:report.groupCount,entries:report.entryCount,before:parent.bytes,after:report.output.bytes,saved:report.savedBytes,top:result.slice(0,8).map(({leader,caseCount,bodyBytes,savedBytes})=>({leader,caseCount,bodyBytes,savedBytes}))}));
