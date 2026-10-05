#!/usr/bin/env node
// Static reconstruction only. Never import or execute a compiler or target module.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';

const [beforeArg,afterArg,profileArg,outArg]=process.argv.slice(2);
assert(outArg,'intrinsic-byte-proof-v1.mjs BASELINE_MANIFEST CANDIDATE_MANIFEST PROFILE FRESH_OUT');
const out=path.resolve(outArg);fs.mkdirSync(out);
const report={kind:'phase52-atomic-intrinsic-byte-proof',complete:false,pass:false,inputs:[],modules:[],
  scope:'Static whole-byte derivation of emitted modules, not semantic validation or dynamic activation. Only exact admitted atomic template expansion and unreferenced native wrapper removal are allowed.'};
const sha=b=>createHash('sha256').update(b).digest('hex');
const pins=new Map();
function pin(file,want){
  file=fs.realpathSync(file);let got=pins.get(file);
  if(!got){const b=fs.readFileSync(file);got={file,sha256:sha(b),bytes:b.length};pins.set(file,got);}
  if(want?.sha256)assert.equal(got.sha256,want.sha256,file);
  if(want?.bytes!==undefined)assert.equal(got.bytes,want.bytes,file);
  return got;
}
function record(v,base='.'){
  const file=v.canonicalPath||v.file||v.path;assert.equal(typeof file,'string');
  return pin(path.resolve(base,file),v);
}
function json(file,want){const id=pin(file,want);return JSON.parse(fs.readFileSync(id.file,'utf8'));}
function walk(node,visit){
  if(!node||typeof node!=='object')return; if(typeof node.type==='string')visit(node);
  for(const v of Object.values(node))if(Array.isArray(v)){for(const x of v)walk(x,visit);}else if(v&&typeof v==='object')walk(v,visit);
}
function apply(text,edits){
  edits.sort((a,b)=>a.start-b.start);let end=0;
  for(const e of edits){assert(e.start>=end,'overlapping edits');end=e.end;}
  for(const e of [...edits].reverse())text=text.slice(0,e.start)+e.text+text.slice(e.end);
  return text;
}
function firstDifference(a,b){let at=0;while(at<a.length&&at<b.length&&a[at]===b[at])at++;
  return{offset:at,expected:a.slice(Math.max(0,at-100),at+220),actual:b.slice(Math.max(0,at-100),at+220)};}
const name=n=>'$jd$'+[...n].map(c=>/[A-Za-z0-9]/.test(c)?c:'_'+c.codePointAt(0)+'_').join('');
function atom(s){return /^(?:\$a[0-9]+|\$eta[0-9]+|true|false|null|[0-9]+)$/.test(s)||/^\(\n\/\*JD_USE:([0-9]+)\*\/\$x\1\)$/.test(s);}
const substitute=(code,args)=>code.replace(/\$([0-3])/g,(_,i)=>{assert(+i<args.length);return args[+i];});

try{
  report.producer=pin(fileURLToPath(import.meta.url));
  assert.equal(process.version,'v24.18.0');report.node=pin(process.execPath);
  const parserKey='internal/deps/acorn/acorn/dist/acorn',parserSource=process.binding('natives')[parserKey];
  assert.equal(typeof parserSource,'string');const holder={exports:{}};
  // Only Node's embedded parser source is evaluated; generated targets are data.
  new Function('exports','module',parserSource)(holder.exports,holder);
  const acorn=holder.exports;assert.equal(acorn.version,'8.16.0');
  report.parser={sourceName:parserKey,version:acorn.version,sha256:sha(parserSource)};
  const parse=text=>acorn.parse(text,{ecmaVersion:'latest',sourceType:'module',preserveParens:true});
  const before=json(beforeArg),after=json(afterArg),profile=json(profileArg);
  assert(before.complete&&after.complete);assert.equal(profile.cases.length,8);
  assert.equal(before.upstreamCommit,after.upstreamCommit);
  assert.equal(before.catalogSha256,after.catalogSha256);
  assert.equal(before.comparisonContract,'upstream-compatible-direct-v1');
  assert.equal(after.comparisonContract,before.comparisonContract);
  const beforeDir=path.dirname(path.resolve(beforeArg)),afterDir=path.dirname(path.resolve(afterArg));
  const profileDir=path.dirname(path.resolve(profileArg));
  record(profile.catalog,profileDir);
  const attempts=[];
  for(const [bundle,dir] of [[before,beforeDir],[after,afterDir]]){
    const compiler=bundle.roles.candidate.compiler;
    assert.equal(compiler.backend,'direct');
    for(const key of ['api','runtime','base','driver','directRuntime'])record(compiler[key]);
    const attemptFile=path.join(path.dirname(path.dirname(compiler.api.file)),'attempt.json');
    const attempt=json(attemptFile);assert.equal(attempt.checked,true);assert.equal(attempt.api.sha256,compiler.api.sha256);
    record(attempt.node);assert.equal(attempt.node.sha256,report.node.sha256);
    for(const source of attempt.snapshot.sources){
      assert.equal(source.original.sha256,source.frozen.sha256);
      record(source.frozen); // Original live paths are historical provenance only.
    }
    const prep=json(path.resolve(dir,bundle.preparation.path),bundle.preparation);assert(prep.complete);
    attempts.push({attempt,attemptFile,compiler,prep,dir});
  }
  assert.equal(attempts[0].compiler.directRuntime.sha256,attempts[1].compiler.directRuntime.sha256);
  assert.equal(attempts[0].compiler.base.sha256,attempts[1].compiler.base.sha256);
  const primitiveFiles=attempts.map(x=>path.join(x.attempt.snapshot.root,'src/back/js/direct/primitive.bend'));
  const primitiveSources=primitiveFiles.map(x=>{pin(x);return fs.readFileSync(x,'utf8');});
  assert.equal(primitiveSources[0],primitiveSources[1],'primitive templates changed');
  const table=new Map();
  const string='"(?:[^"\\\\]|\\\\.)*"';
  const rows=new RegExp('JDPrimitive\\{('+string+'),\\s*([0-9]+),\\s*('+string+')\\}','g');
  for(const m of primitiveSources[0].matchAll(rows)){
    const n=JSON.parse(m[1]);if(!n)continue;
    assert(!table.has(name(n)));table.set(name(n),{sourceName:n,arity:+m[2],code:JSON.parse(m[3])});
  }
  assert.equal(table.size,89);report.primitiveTemplates=table.size;
  const frozenChanges=[];
  const bSources=new Map(attempts[0].attempt.snapshot.sources.map(s=>[path.relative(attempts[0].attempt.snapshot.root,s.frozen.file),s.frozen]));
  for(const s of attempts[1].attempt.snapshot.sources){const rel=path.relative(attempts[1].attempt.snapshot.root,s.frozen.file),old=bSources.get(rel);
    if(!old||old.sha256!==s.frozen.sha256)frozenChanges.push({path:rel,before:old?.sha256??null,after:s.frozen.sha256});bSources.delete(rel);}
  for(const [rel,old]of bSources)frozenChanges.push({path:rel,before:old.sha256,after:null});
  report.frozenSnapshotChanges=frozenChanges;

  function wrappers(text,tree){
    const found=new Map();
    for(const node of tree.body){
      if(node.type!=='FunctionDeclaration'||!table.has(node.id?.name))continue;
      const p=table.get(node.id.name),args=Array.from({length:p.arity},(_,i)=>'$a'+i);
      const exact='function '+node.id.name+'('+args.join(',')+'){return '+substitute(p.code,args)+';}';
      assert.equal(text.slice(node.start,node.end),exact,'native wrapper differs from frozen template: '+node.id.name);
      found.set(node.id.name,{node,primitive:p});
    }
    return found;
  }
  for(const item of profile.cases){
    const old=before.cases.find(x=>x.id===item.id),now=after.cases.find(x=>x.id===item.id);
    assert(old&&now);assert.deepEqual(old.point,item.point);assert.deepEqual(now.point,item.point);
    assert.equal(old.sourceSha256,item.source.sha256);assert.equal(now.sourceSha256,item.source.sha256);
    const source=path.resolve(profileDir,'../phase37',item.source.path);pin(source,item.source);
    const ids=[],texts=[],receipts=[];
    for(const [row,state]of [[old,attempts[0]],[now,attempts[1]]]){
      const meta=row.modules.candidate,file=path.resolve(state.dir,meta.path);ids.push(pin(file,meta));texts.push(fs.readFileSync(file,'utf8'));
      const sourceRow=state.prep.sources.find(x=>x.source.sha256===item.source.sha256);assert(sourceRow);
      assert(sourceRow.process.complete);assert.equal(sourceRow.process.returncode,0);
      const receipt=json(path.resolve(state.dir,sourceRow.emission.path),sourceRow.emission);
      assert(receipt.complete);assert.equal(receipt.backend,'direct');assert.deepEqual(receipt.compiler,state.compiler);
      assert.equal(receipt.input.sha256,item.source.sha256);assert.equal(receipt.observation.checked,true);
      assert.equal(receipt.observation.status,'ok');assert.equal(receipt.observation.exitCode,0);
      record(receipt.attempt);assert.equal(fs.realpathSync(receipt.attempt.file),fs.realpathSync(state.attemptFile));
      record(receipt.output);assert.equal(receipt.output.sha256,ids.at(-1).sha256);record(receipt.input);record(receipt.producer);
      for(const input of receipt.emissionInputs)record(input);
      receipts.push(pin(path.resolve(state.dir,sourceRow.emission.path)));
    }
    const [original,candidate]=texts,tree=parse(original),known=wrappers(original,tree),edits=[];
    walk(tree,node=>{
      if(node.type!=='ParenthesizedExpression'||node.expression.type!=='CallExpression')return;
      const call=node.expression,target=call.callee;if(target.type!=='Identifier'||!known.has(target.name))return;
      const p=known.get(target.name).primitive,args=call.arguments.map(x=>original.slice(x.start,x.end));
      if(args.length!==p.arity||!args.every(atom))return;
      const exact='(\n/*JD_REF:'+target.name+'*/'+target.name+'('+args.join(',')+'))';
      if(original.slice(node.start,node.end)!==exact)return;
      edits.push({start:node.start,end:node.end,text:'('+substitute(p.code,args)+')',callee:target.name});
    });
    let expected=apply(original,edits);const pruned=[];
    const expandedTree=parse(expected),remaining=wrappers(expected,expandedTree);
    for(const [n,{node}]of remaining){let refs=0;
      walk(expandedTree,x=>{if(x.type==='Identifier'&&x.name===n&&(x.start<node.start||x.end>node.end))refs++;});
      if(refs===0){assert.equal(expected[node.end],'\n');pruned.push({start:node.start,end:node.end+1,text:'',name:n});}
    }
    expected=apply(expected,pruned);parse(expected);parse(candidate);
    const equal=expected===candidate;
    const counts={};for(const e of edits)counts[e.callee]=(counts[e.callee]||0)+1;
    const row={id:item.id,source:pin(source),before:ids[0],after:ids[1],emissionReceipts:receipts,
      expandedCalls:edits.length,expansionsByCallee:counts,prunedWrappers:pruned.map(x=>x.name),
      expectedSha256:sha(expected),expectedBytes:Buffer.byteLength(expected),exactByteEquality:equal};
    if(!equal){row.firstDifference=firstDifference(expected,candidate);const file=path.join(out,item.id+'.expected.mjs');
      fs.writeFileSync(file,expected,{flag:'wx'});row.diagnosticExpected={file,sha256:sha(expected),bytes:Buffer.byteLength(expected)};}
    report.modules.push(row);
  }
  report.complete=true;report.pass=report.modules.length===8&&report.modules.every(x=>x.exactByteEquality);
  report.meaning=report.pass?'Every candidate byte is reconstructed by the two declared transformations; packaging and other lowering changes contribute no additional emitted bytes in this profile.':'Reconstruction incomplete: unexplained differences retained; no exclusive causal attribution.';
}catch(e){report.error=String(e.stack||e);}
try{for(const row of pins.values()){const bytes=fs.readFileSync(row.file);assert.equal(sha(bytes),row.sha256,row.file);assert.equal(bytes.length,row.bytes);}report.inputsUnchanged=true;}
catch(e){report.pass=false;report.inputsUnchanged=false;report.finalRehashError=String(e.stack||e);}
report.inputs=[...pins.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,modules:report.modules.length}));
process.exitCode=report.pass?0:1;
