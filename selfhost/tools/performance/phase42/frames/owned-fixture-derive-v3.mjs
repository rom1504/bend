// Actual unary fixture emission: adapters/counters only, no replacement helpers.
import {verifyAttempt} from '../../../development/workflow.mjs';
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
const[baseArg,candidateArg,outArg]=process.argv.slice(2);assert(baseArg&&candidateArg&&outArg,'usage: owned-fixture-derive-v3.mjs CHECKED02_FIXTURE SELECTED_FIXTURE NEW_OUT');
const sha=x=>createHash('sha256').update(x).digest('hex'),id=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const pm={exports:{}};new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(pm,pm.exports);
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,fn));else if(v&&typeof v==='object')walk(v,fn);}}
const encoded=s=>'$R'+[...s].map(c=>'_'+c.codePointAt(0)).join('')+'$tree';
const guards=['bench','owned.make','owned.copy','owned.count'];
const adapter=`
const $ownedGuards=${JSON.stringify(guards)};
export function ownedCounts(){return {worker:$ownedWorker,globalWorker:$ownedGlobalWorker,lexicalWorker:$ownedLexicalWorker,direct:$ownedDirect,tags:{...$ownedTags}};}
export function ownedProof(){return regionProof!==null;}
export function ownedCopy(depth,seed){if(!Number.isInteger(depth)||depth<0||depth>30000)throw Error('diagnostic depth');let t=ctor('ODone',[seed]);for(let i=depth-1;i>=0;i--)t=ctor('OLink',[(seed+i+1)>>>0,t]);
if(!regionHostGuard()||!localGuard($ownedGuards))throw Error('diagnostic guard');const previous=regionProofOpen($ownedGuards);try{const r=${encoded('owned.copy')}(t);return {original:t,result:r};}finally{regionProofClose(previous);}}
`;
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);const modules=[],staticSites={},roleProvenance={};let baseline;
for(const[role,arg]of[['original',baseArg],['candidate',candidateArg]]){
 const source=fs.readFileSync(arg,'utf8'),receipt=JSON.parse(fs.readFileSync(arg+'.json'));
 assert.equal(receipt.output.sha256,sha(source));assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);assert.equal(receipt.observation.status,'ok');
 for(const row of[receipt.input,receipt.producer,receipt.attempt,receipt.compiler.api,receipt.compiler.runtime,receipt.compiler.base,receipt.compiler.driver,...receipt.verifiers])assert.equal(id(row.canonicalPath??row.file).sha256,row.sha256);
 assert.equal(receipt.input.sha256,id('selfhost/tools/performance/phase42/frames/owned-fixture.bend').sha256);
 if(!baseline)baseline=receipt;else{assert.equal(receipt.input.sha256,baseline.input.sha256);assert.equal(receipt.compiler.base.sha256,baseline.compiler.base.sha256);}
 const ownAttempt=await verifyAttempt(path.dirname(receipt.attempt.canonicalPath??receipt.attempt.file));assert.equal(ownAttempt.checked,true);for(const key of['api','runtime','base'])assert.equal(receipt.compiler[key].sha256,ownAttempt[key].sha256,role+' own checked '+key);assert.equal(receipt.compiler.driver.sha256,id(path.join(ownAttempt.snapshot.root,'tools/typed-driver.mjs')).sha256,role+' own driver');roleProvenance[role]={attempt:receipt.attempt,api:receipt.compiler.api,runtime:receipt.compiler.runtime,base:receipt.compiler.base,driver:receipt.compiler.driver};
 const ast=parse(source),workers=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name.endsWith('$tree'));const copy=workers.find(n=>n.id.name===encoded('owned.copy'));assert(copy,'actual unary worker required');assert(source.slice(copy.start,copy.end).includes('$frame.phase===2'),'actual unary reconstruction frame required');
 const allCopy=[],flatBlocks=[];walk(ast,n=>{if(n.type==='FunctionDeclaration'&&n.id.name===encoded('owned.copy'))allCopy.push(n);if(n.type==='BlockStatement'&&source.slice(n.start,n.start+60).startsWith('{/* private flat closed graph */'))flatBlocks.push(n);});
 const lexicalCopy=allCopy.filter(n=>n!==copy);assert.equal(allCopy.length,role==='candidate'?2:1,'exact global/lexical unary worker inventory');assert.equal(lexicalCopy.length,role==='candidate'?1:0);assert.equal(flatBlocks.length,role==='candidate'?1:0);
 for(const fn of lexicalCopy){assert(fn.start>flatBlocks[0].start&&fn.end<flatBlocks[0].end,'lexical unary inside admitted flat root');assert(source.slice(fn.start,fn.end).includes('$frame.phase===2'),'lexical unary reconstruction frame required');}
 const helperBodies=[];walk(ast,n=>{if(n.type==='ArrowFunctionExpression'&&n.body.type==='BlockStatement'&&source.slice(n.body.start,n.body.start+60).startsWith('{/* private acyclic helper */'))helperBodies.push(n.body);});
 const scopes=[...workers.map(n=>n.body),...helperBodies],tagged=[];
 walk(ast,n=>{if(n.type==='ObjectExpression'&&scopes.some(b=>n.start>=b.start&&n.end<=b.end)){const tag=n.properties.find(p=>p.key?.name==='$'),args=n.properties.find(p=>p.key?.name==='a');if(tag?.value?.type==='Literal'&&args?.value?.type==='ArrayExpression')tagged.push(n);}});
 if(role==='original')assert.equal(tagged.length,0);else assert(tagged.length>0);
 const tags=[...new Set(tagged.map(n=>n.properties.find(p=>p.key?.name==='$').value.value))];assert(tags.every(t=>['ODone','OLink'].includes(t)),'native constructors must remain native');
 staticSites[role]={workers:workers.map(n=>n.id.name),direct:tagged.length,tags,copyScopes:{global:1,lexical:lexicalCopy.length,flatBlocks:flatBlocks.length}};
 const edits=[{at:copy.body.start+1,text:'++$ownedWorker;++$ownedGlobalWorker;'},...lexicalCopy.map(fn=>({at:fn.body.start+1,text:'++$ownedWorker;++$ownedLexicalWorker;'})),...tagged.flatMap(n=>{const t=JSON.stringify(n.properties.find(p=>p.key?.name==='$').value.value);return[{at:n.start,text:'($ownedDirect++,($ownedTags['+t+']=($ownedTags['+t+']||0)+1),'},{at:n.end,text:')'}];})];
 let diagnostic=source;for(const e of edits.sort((a,b)=>b.at-a.at))diagnostic=diagnostic.slice(0,e.at)+e.text+diagnostic.slice(e.at);
 diagnostic+='\nlet $ownedWorker=0,$ownedGlobalWorker=0,$ownedLexicalWorker=0,$ownedDirect=0;const $ownedTags=Object.create(null);\n'+adapter;parse(diagnostic);
 for(const[diag,text]of[[false,source],[true,diagnostic]]){const p=path.join(out,role+(diag?'.mjs':'.clean.mjs'));fs.writeFileSync(p,text,{flag:'wx'});modules.push({role,diagnostic:diag,...id(p)});}
}
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify({kind:'phase42-owned-unary-actual',complete:true,checked:true,producer:id(import.meta.filename),inputs:[baseArg,candidateArg].flatMap(p=>[id(p),id(p+'.json')]),fixture:id('selfhost/tools/performance/phase42/frames/owned-fixture.bend'),modules,staticSites,roleProvenance},null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({out,staticSites}));
