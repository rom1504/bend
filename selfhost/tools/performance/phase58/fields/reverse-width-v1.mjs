// Data-only saved-image diagnostic; never imports a compiler or generated target.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [parentArg,runtimeArg,outArg]=process.argv.slice(2);
assert(parentArg&&runtimeArg&&outArg&&process.argv.length===5);
const parent=fs.realpathSync(parentArg),runtime=fs.realpathSync(runtimeArg),out=path.resolve(outArg);
const phaseRoot=fs.realpathSync(path.resolve(import.meta.dirname,'../../../../build/phase58'));
assert(out.startsWith(phaseRoot+path.sep));assert.equal(path.dirname(out),fs.realpathSync(path.dirname(out)));
fs.mkdirSync(out,{recursive:false});
const hash=s=>createHash('sha256').update(s).digest('hex');
const identity=p=>({file:p,sha256:hash(fs.readFileSync(p)),bytes:fs.statSync(p).size});
const parentId=identity(parent),runtimeId=identity(runtime);
const text=fs.readFileSync(parent,'utf8'),prefix=fs.readFileSync(runtime,'utf8')+'\n';
assert(text.startsWith(prefix),'Exact selected direct runtime prefix required');
const native=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};
new Function('module','exports',native)(pm,pm.exports);
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const edits=[];let protoKept=0,skippedQuotedKeys=0,constructorFields=0,marshalFields=0,wideLiteralKeysRetained=0,unknownMarshalKeysRetained=0;
const widthRows=new Map();
function walk(n){
 if(!n||typeof n!=='object')return;
 if(n.type==='ObjectExpression'&&n.start>=prefix.length){
  const first=n.properties[0],tagged=first?.type==='Property'&&!first.computed&&first.key.type==='Identifier'&&first.key.name==='$'&&first.value.type==='Literal'&&typeof first.value.value==='string';
  const marshal=first?.type==='SpreadElement'&&first.argument.type==='Identifier'&&first.argument.name==='v';
  const fields=tagged?n.properties.slice(1):[],width=fields.length;
  if(tagged){
   assert(fields.every(p=>p.type==='Property'&&p.kind==='init'&&!p.method&&!p.shorthand&&p.key.type==='Literal'&&typeof p.key.value==='string'),'Complete ordinary-field width must be known');
   const tag=first.value.value,key=JSON.stringify([tag,width]);
   if(!widthRows.has(key))widthRows.set(key,{tag,width,objectSites:0,ordinaryFieldSites:0,literalFieldSites:0,computedFieldSites:0,policy:width<=4?'computed':'literal'});
   const row=widthRows.get(key);row.objectSites++;row.ordinaryFieldSites+=width;row.literalFieldSites+=fields.filter(p=>!p.computed).length;row.computedFieldSites+=fields.filter(p=>p.computed).length;
  }
  for(const p of n.properties){
   if(p.type!=='Property'||p.kind!=='init'||p.method||p.shorthand||p.key.type!=='Literal'||typeof p.key.value!=='string')continue;
   if(p.key.value==='__proto__'){protoKept++;continue;}
   if(p.computed)continue;
   if(!tagged&&!marshal){skippedQuotedKeys++;continue;}
   if(!(tagged&&width<=4)){if(tagged)wideLiteralKeysRetained++;else unknownMarshalKeysRetained++;continue;}
   assert.equal(p.start,p.key.start);const raw=text.slice(p.key.start,p.key.end);assert(raw.startsWith('"')||raw.startsWith("'"));
   assert(/^\s*:/.test(text.slice(p.key.end,p.value.start)));
   edits.push({start:p.key.start,end:p.key.end,key:p.key.value,before:raw,after:'['+raw+']',route:'constructor',width});
   if(tagged)constructorFields++;else marshalFields++;p.computed=true;
  }
 }
 for(const [k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v);}
}
const expected=parse(text);walk(expected);assert(edits.length>0);
edits.sort((a,b)=>a.start-b.start);for(let i=1;i<edits.length;i++)assert(edits[i-1].end<=edits[i].start);
let derived=text;for(const e of [...edits].reverse())derived=derived.slice(0,e.start)+e.after+derived.slice(e.end);
const scrub=n=>{if(Array.isArray(n))return n.map(scrub);if(!n||typeof n!=='object')return n;return Object.fromEntries(Object.entries(n).filter(([k])=>!['start','end','raw'].includes(k)).map(([k,v])=>[k,scrub(v)]));};
assert.deepEqual(scrub(parse(derived)),scrub(expected),'Only admitted key syntax/AST computed flag may change');
let restored=derived,delta=0;const inverse=[];for(const e of edits){const start=e.start+delta;inverse.push({start,end:start+e.after.length,after:e.before});delta+=e.after.length-(e.end-e.start);}for(const e of inverse.reverse())restored=restored.slice(0,e.start)+e.after+restored.slice(e.end);assert.equal(restored,text);
const output=path.join(out,'api.mjs');fs.writeFileSync(output,derived,{flag:'wx'});
const producer=identity(import.meta.filename),node=identity(fs.realpathSync(process.execPath));
const report={kind:'phase58-data-only-b2-narrow-computed-field-diagnostic',complete:true,pass:true,diagnosticOnly:true,productionQualified:false,changesRuntime:false,parent:parentId,runtime:runtimeId,producer,node,parser:{source:'pinned Node internal Acorn',sha256:hash(native)},output:identity(output),scope:'Diagnostic width hypothesis only: reverse post-runtime quoted own fields in tagged constructor objects with at most four ordinary fields (tag excluded; all computed/proto fields included in width). Constructors of width five or more and marshal spreads of unknown complete width stay unchanged. Export-map keys, tag identifiers, __proto__, preexisting computed fields, MemberExpressions, values, order, representations and runtime stay unchanged. Same compiler source diagnostic, not production policy or a compiled source rollback.',editCount:edits.length,constructorFields,marshalFields,skippedQuotedKeys,protoKept,wideLiteralKeysRetained,unknownMarshalKeysRetained,staticConstructorInventory:[...widthRows.values()].sort((a,b)=>a.width-b.width||(a.tag<b.tag?-1:a.tag>b.tag?1:0)),inventoryScope:'Static constructor-expression and key sites, including cold paths and cloned/inlined bodies; not allocation execution frequency or physical heap allocation.',edits,exactInverse:true,normalizedAstEquality:true};
for(const row of [report.parent,report.runtime,producer,node])assert.equal(identity(row.file).sha256,row.sha256);
fs.writeFileSync(path.join(out,'derivation.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,parent:report.parent.sha256,output:report.output.sha256,editCount:edits.length,protoKept}));
