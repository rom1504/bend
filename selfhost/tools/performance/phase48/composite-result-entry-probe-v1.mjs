// Produce counter-only entry witnesses using complete checked G assignment ASTs.
// Usage: node composite-result-entry-probe-v1.mjs MODULE NEW_OUT ENTRY [ENTRY...]
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
const [moduleArgument,outArgument,...entries]=process.argv.slice(2);assert(entries.length);
const inputs=new Map(),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
function pin(file,want){file=fs.realpathSync(file);const b=fs.readFileSync(file),id={path:file,sha256:sha(b),bytes:b.length};if(want)assert.equal(id.sha256,want);inputs.set(file,id);return id;}
function audit(v){if(!v||typeof v!=='object')return;const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v.sha256);Object.values(v).forEach(audit);}
const module=pin(moduleArgument),receiptFile=pin(module.path+'.json');pin(import.meta.filename);pin(process.execPath);
const receipt=JSON.parse(fs.readFileSync(receiptFile.path,'utf8'));
assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');assert.equal(receipt.output.sha256,module.sha256);audit(receipt);
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};
new Function('module','exports',parserSource)(pm,pm.exports);assert.equal(pm.exports.version,'8.16.0');
const text=fs.readFileSync(module.path,'utf8'),ast=pm.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'}),edits=[];
assert(!text.includes('$p48CompositeEntryCounters'));
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const [key,value]of Object.entries(n))if(!['start','end'].includes(key)){if(Array.isArray(value))value.forEach(x=>walk(x,fn));else if(value&&typeof value==='object')walk(value,fn);}}
const marker='/* private composite array result */';
for(const name of entries){
  const nodes=ast.body.filter(n=>n.type==='ExpressionStatement'&&n.expression.type==='AssignmentExpression'&&n.expression.left.type==='MemberExpression'&&n.expression.left.object.name==='G'&&n.expression.left.property.value===name);assert.equal(nodes.length,1);
  const node=nodes[0],fragment=text.slice(node.start,node.end),key=JSON.stringify(name);assert.equal(fragment.split(marker).length,2,name+' must select adapter');
  edits.push({at:node.start+fragment.indexOf(marker)+marker.length,text:`++$p48CompositeEntryCounters[${key}].fast;`});
  const branches=[];walk(node,n=>{if(n.type==='IfStatement'&&n.consequent.type==='BlockStatement'&&n.consequent.body.some(x=>x.type==='ReturnStatement'&&x.argument?.callee?.name==='ctor'&&x.argument.arguments[1]?.name==='$arrayResult'))branches.push(n);});assert.equal(branches.length,1);
  edits.push({at:branches[0].end,text:`++$p48CompositeEntryCounters[${key}].fallback;`});
}
let derived=text;for(const edit of edits.sort((a,b)=>b.at-a.at))derived=derived.slice(0,edit.at)+edit.text+derived.slice(edit.at);
derived='let $p48CompositeEntryCounters='+JSON.stringify(Object.fromEntries(entries.map(n=>[n,{fast:0,fallback:0}])))+';\n'+derived;
derived+='\nexport const phase48CompositeEntries=()=>JSON.parse(JSON.stringify($p48CompositeEntryCounters));\n';
const out=path.resolve(outArgument);fs.mkdirSync(out);const target=path.join(out,'instrumented.mjs');fs.writeFileSync(target,derived,{flag:'wx'});
const runner=path.join(out,'runner.mjs');fs.writeFileSync(runner,`// Counter module only: never time it.
import fs from 'node:fs';import assert from 'node:assert/strict';
import program,{phase48CompositeEntries} from './instrumented.mjs';
const [pointFile,reportFile]=process.argv.slice(2),point=JSON.parse(fs.readFileSync(pointFile,'utf8'));
const before=phase48CompositeEntries(),value=program[point.exportName??'bench'](...point.args),after=phase48CompositeEntries();
assert.deepEqual(value,point.expected);
for(const name of point.requiredFastEntries??Object.keys(after)){assert.equal(after[name].fast-before[name].fast,1,name+' fast');assert.equal(after[name].fallback-before[name].fallback,0,name+' fallback');}
fs.writeFileSync(reportFile,JSON.stringify({complete:true,passed:true,diagnosticOnly:true,timingEligible:false,value,before,after},null,2)+'\\n',{flag:'wx'});
`,{flag:'wx'});
for(const id of inputs.values())assert.equal(sha(fs.readFileSync(id.path)),id.sha256);
fs.writeFileSync(path.join(out,'manifest.json'),JSON.stringify({complete:true,diagnosticOnly:true,productionSafe:false,timingEligible:false,entries,inputs:[...inputs.values()],parser:{version:pm.exports.version,sha256:sha(parserSource)},module:pin(target),runner:pin(runner)},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,executed:false,output:out}));
