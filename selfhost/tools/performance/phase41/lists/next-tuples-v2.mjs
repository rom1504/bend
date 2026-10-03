// Saved-output ablation. Removes only nonescaping next-argument array literals.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const parser={exports:{}};new Function('module','exports',parserText)(parser,parser.exports);
const parse=text=>parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
function walk(node,visit,parent=null){
 if(!node||typeof node!=='object')return;
 if(typeof node.type==='string')visit(node,parent);
 for(const [key,value] of Object.entries(node)){
  if(key==='start'||key==='end')continue;
  if(Array.isArray(value))for(const child of value)walk(child,visit,node);
  else if(value&&typeof value==='object')walk(value,visit,node);
 }
}

export function scalarizeNextTuples(text){
 const ast=parse(text),edits=[],sites=[],matchedBlocks=new Set();
 for(const worker of ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name.endsWith('$tree'))){
  walk(worker.body,(declaration,block)=>{
   if(declaration.type!=='VariableDeclaration'||declaration.kind!=='const'||declaration.declarations.length!==1)return;
   const binding=declaration.declarations[0];if(binding.id.type!=='Identifier'||binding.id.name!=='$next')return;
   assert.equal(block.type,'BlockStatement','tuple must have a lexical block');
   assert(!matchedBlocks.has(block),'multiple tuple declarations in one lexical block');matchedBlocks.add(block);
   assert.equal(binding.init.type,'ArrayExpression');
   const values=binding.init.elements;assert(values.length>0);
   assert(values.every(n=>n&&n.type!=='SpreadElement'),'no holes/spreads');
   // Fresh block locals preserve all RHS evaluation before state assignment.
   const temporary=index=>'$p41next'+index;
   for(let i=0;i<values.length;i++)walk(block,n=>assert(!(n.type==='Identifier'&&n.name===temporary(i)),'temporary collision'));
   const uses=[],slots=new Set();
   walk(block,(n,parent)=>{
    if(n.type!=='Identifier'||n.name!=='$next'||n===binding.id)return;
    assert(parent.type==='MemberExpression'&&parent.object===n&&parent.computed&&!parent.optional,'tuple escapes or aliases');
    assert(parent.property.type==='Literal'&&Number.isInteger(parent.property.value),'nonliteral tuple slot');
    const index=parent.property.value;assert(index>=0&&index<values.length);
    assert(parent.start>=declaration.end,'tuple used before declaration');
    uses.push({node:parent,index});slots.add(index);
   });
   assert.equal(uses.length,values.length,'each tuple slot must be read once');
   assert.equal(slots.size,values.length);
   // Restrict every use to the exact state assignment emitted by this worker.
   for(const use of uses){
    let assignment;
    walk(block,(n,parent)=>{if(n===use.node)assignment=parent;});
    assert.equal(assignment.type,'AssignmentExpression');assert.equal(assignment.operator,'=');
    assert.equal(assignment.right,use.node);assert.equal(assignment.left.type,'Identifier');
    assert.equal(assignment.left.name,'$s'+use.index);
    edits.push({start:use.node.start,end:use.node.end,text:temporary(use.index)});
   }
   edits.push({start:declaration.start,end:declaration.end,text:values.map((n,i)=>'const '+temporary(i)+'=('+text.slice(n.start,n.end)+');').join('')});
   sites.push({worker:worker.id.name,start:declaration.start,arity:values.length});
  });
 }
 assert(sites.length>0,'no next-argument tuple sites');
 edits.sort((a,b)=>b.start-a.start);
 for(let i=1;i<edits.length;i++)assert(edits[i].end<=edits[i-1].start,'overlapping edits');
 let output=text;for(const edit of edits)output=output.slice(0,edit.start)+edit.text+output.slice(edit.end);
 parse(output);return{output,sites};
}

const identity=p=>({path:fs.realpathSync(p),bytes:fs.statSync(p).size,sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
function verify(row){assert.deepEqual(identity(row.path),row);}
function write(file,text){fs.writeFileSync(file,text,{flag:'wx'});return identity(file);}

if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
 const [diagnosticArg,benchmarkArg,outArg]=process.argv.slice(2);
 assert(diagnosticArg&&benchmarkArg&&outArg,'usage: next-tuples.mjs PHASE40_LIST_ACTUAL_DERIVED CLEAN_PHASE40_BENCH NEW_OUT');
 const base=fs.realpathSync(diagnosticArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
 const parentFile=path.join(base,'derive.json'),parent=JSON.parse(fs.readFileSync(parentFile));
 assert.equal(parent.kind,'phase40-list-actual');assert.equal(parent.complete,true);
 parent.inputs.forEach(verify);
 const clean=parent.modules.find(r=>r.variant==='component'&&!r.counters);
 const diagnostic=parent.modules.find(r=>r.variant==='component'&&r.counters);
 for(const row of [clean,diagnostic])assert.equal(identity(row.path).sha256,row.sha256);
 assert.equal(clean.sha256,'8f4f3f62b6d7bd7c2c924b1c794d5fffc60b32eb946564714dc80caffcd879b0','selected checked06 fixture');
 const benchmark=identity(benchmarkArg);
 assert.equal(benchmark.sha256,'d623912da283c60a135535e25c724bc704582bde31fdf1241e55d5a6aa6556ad','selected checked06 benchmark');
 const benchmarkText=fs.readFileSync(benchmark.path,'utf8');
 assert(benchmarkText.includes('/* private structural component */'),'benchmark must be Phase40 direct unfused');
 const roles=[['fixture',clean.path],['diagnostic',diagnostic.path],['benchmark',benchmark.path]];
 const changes=roles.map(([role,file])=>({role,input:identity(file),...scalarizeNextTuples(fs.readFileSync(file,'utf8'))}));
 fs.mkdirSync(out);const consumed=write(path.join(out,'consumed-next-tuples-v2.mjs'),fs.readFileSync(import.meta.filename,'utf8'));
 const report={kind:'phase41-list-next-tuples',complete:false,checked:false,certified:false,
  scope:'Manual saved-JS next-argument tuple allocation ablation against Phase40 direct unfused; no fusion or compiler-source change.',
  dependencies:parent.dependencies,refusals:parent.refusals,
  inputs:[identity(parentFile),...parent.inputs,identity(clean.path),identity(diagnostic.path),benchmark,consumed],modules:[],changes:[]};
 for(const change of changes){
  const diagnostic=change.role==='diagnostic';
  const baselineName=diagnostic?'original.mjs':change.role==='fixture'?'original.clean.mjs':'benchmark.original.mjs';
  const candidateName=diagnostic?'component.mjs':change.role==='fixture'?'component.clean.mjs':'benchmark.component.mjs';
  for(const [variant,name,text]of [['original',baselineName,fs.readFileSync(change.input.path,'utf8')],['component',candidateName,change.output]]){
   report.modules.push({variant,counters:diagnostic,role:change.role,parent:change.input,...write(path.join(out,name),text)});
  }
  report.changes.push({role:change.role,input:change.input,sites:change.sites});
 }
 report.inputs.forEach(verify);report.complete=true;
 write(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n');
 console.log(JSON.stringify({complete:true,changes:report.changes.map(r=>({role:r.role,sites:r.sites.length}))}));
}
