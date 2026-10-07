// Separate diagnostic: actual candidate helper-entry counts, never clean timing.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {identity,verify,hash,list} from '../../phase54/bootstrap/adapter.mjs';
const [attemptArg,outArg]=process.argv.slice(2);assert(attemptArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase61')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=new Map(),pin=(file,want)=>{const r=identity(file);if(want)assert.equal(r.sha256,want.sha256);assert(!inputs.has(r.file)||inputs.get(r.file).sha256===r.sha256);inputs.set(r.file,r);return r;};
const report={kind:'phase61-fused-environment-helper-activation',complete:false,pass:false,rows:[],
 scope:'Actual candidate public/eager routes on identical synthetic dependent telescopes. Entry counters are diagnostic work counts; no physical-allocation, asymptotic proof, ordinary-source coverage or clean-speed claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const term=(tag,name='',id=0,quant=0,kids=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
const qnt=()=>term('Qnt'),qua=q=>term('Qua','',0,q),ref=n=>term('Ref',n);
function telescope(n){let t=term('Var','v100',100);for(let i=n-1;i>=0;i--)t=term('All','v'+(100+i),100+i,1,[qnt(),t]);return t;}
try{
 for(const f of [import.meta.filename,process.execPath,new URL('../../../development/workflow.mjs',import.meta.url).pathname,new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url).pathname])pin(f);
 const parent=pin(new URL('./activation-v1.mjs',import.meta.url).pathname);assert.equal(parent.sha256,'639ce341705953859a6d1c1b30007e433e6d5c61779128e6690fe4eb8032961c');report.parent=parent;
 const directory=fs.realpathSync(attemptArg),m=await verifyAttempt(directory);assert(m.checked);
 report.attempt=pin(path.join(directory,'attempt.json'));for(const k of ['api','runtime','base','node','bootstrapReport'])pin(m[k].file,m[k]);assert.equal(identity(process.execPath).sha256,m.node.sha256);
 const validation=pin(path.join(directory,'validation-001/report.json')),v=JSON.parse(fs.readFileSync(validation.file,'utf8'));
 assert(v.complete&&v.pass&&v.selected.selectedComplete);assert.equal(v.selected.exactDifferences,0);assert.equal(v.selected.discrepancies,0);assert.equal(v.attempt.sha256,report.attempt.sha256);assert.equal(v.api.sha256,m.api.sha256);report.validation=validation;
 const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],P={exports:{}};new Function('module','exports',parserText)(P,P.exports);const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
 const original=fs.readFileSync(m.api.file,'utf8'),ast=parse(original);assert(!original.includes('$p61TelCounts'));
 const probes=['env_tele_fill_loop','env_tele_check_loop','env_tele_fill_eager','tele_check_legacy','env_tele_apply_binding','subst','env_subst_term','env_subst_find'];
 const edits=[];for(const [index,name] of probes.entries()){
  const nodes=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name==='$'+name+'$');assert.equal(nodes.length,1,name);const node=nodes[0];
  // A future compiler may loop or dispatch inside a declaration; refuse that shape.
  function rejectLoops(n){if(!n||typeof n!=='object')return;if(['WhileStatement','DoWhileStatement','ForStatement','SwitchStatement'].includes(n.type))throw Error('Counter requires ordinary function '+name);for(const [k,v]of Object.entries(n))if(k!=='start'&&k!=='end')if(Array.isArray(v))v.forEach(rejectLoops);else rejectLoops(v);}
  rejectLoops(node.body);let text='$p61TelCounts['+index+']++;';
  if(index<2){const arg=node.params[index===0?4:6];assert.equal(arg.type,'Identifier');text+='if('+arg.name+'>$p61TelCounts[8])$p61TelCounts[8]='+arg.name+';';}
  edits.push({at:node.body.start+1,text,function:name,bodySha256:hash(original.slice(node.body.start,node.body.end))});
 }
 let derived=original;for(const e of [...edits].sort((a,b)=>b.at-a.at))derived=derived.slice(0,e.at)+e.text+derived.slice(e.at);
 const suffix=`\nconst $p61TelCounts=[0,0,0,0,0,0,0,0,0];
export const phase61TelescopeActivation={reset:()=>$p61TelCounts.fill(0),counts:()=>$p61TelCounts.slice(),
fill:(b,t,a)=>run_loop($tele_fill$(b,t,a)),eagerFill:(b,t,a)=>run_loop($env_tele_fill_eager$(b,t,a)),
check:(e,t,a)=>run_loop($tele_check$(e,{$:"Nil"},t,a,1)),eagerCheck:(e,t,a)=>run_loop($tele_check_legacy$(e,{$:"Nil"},t,a,1)),
world:b=>run_loop($kw_initial$(b))};\n`;
 derived+=suffix;parse(derived);let inverted=derived.slice(0,-suffix.length);
 for(const e of [...edits].sort((a,b)=>a.at-b.at)){assert.equal(inverted.slice(e.at,e.at+e.text.length),e.text);inverted=inverted.slice(0,e.at)+inverted.slice(e.at+e.text.length);}
 assert.equal(inverted,original);
 const file=path.join(out,'candidate-counter.mjs');fs.writeFileSync(file,derived,{flag:'wx'});report.derivative=pin(file);report.api=m.api;report.edits=edits;report.suffixSha256=hash(suffix);report.parser={version:P.exports.version,sha256:hash(parserText)};report.counterNames=[...probes,'maximumPendingBindings'];
 const api=(await import(pathToFileURL(file))).phase61TelescopeActivation;
 for(const n of [8,63,64,65,129]){
  const book=list([]),tel=telescope(n),args=list(Array.from({length:n},(_,i)=>qua(i%3))),env={$:'KEnv',world:api.world(book),name:'activation',lhs:ref('activation'),pending:0,quantities:list([]),unsafe:false,depth:0};
  for(const [kind,left,right]of [['fill',()=>api.fill(book,tel,args),()=>api.eagerFill(book,tel,args)],['check',()=>api.check(env,tel,args),()=>api.eagerCheck(env,tel,args)]]){
   const before=JSON.stringify({book,tel,args,env});api.reset();const selected=left(),selectedCounts=api.counts();api.reset();const eager=right(),eagerCounts=api.counts();
   assert.deepEqual(selected,eager);assert.equal(JSON.stringify({book,tel,args,env}),before);assert(selectedCounts[kind==='fill'?0:1]>0,'cursor must execute');assert(selectedCounts[8]>0&&selectedCounts[8]<=64);assert(selectedCounts[6]>0,'fused traversal must execute');assert(selectedCounts[5]<eagerCounts[5],'fewer actual subst entries on this synthetic telescope');
   assert.equal(eagerCounts[0]+eagerCounts[1],0);assert(eagerCounts[kind==='fill'?2:3]>0);
   assert.deepEqual(kind==='fill'?selected:selected.typ,qua(0));if(kind==='check')assert.equal(selected.error,'');
   report.rows.push({kind,arguments:n,selectedCounts,eagerCounts,resultSha256:hash(JSON.stringify(selected)),equal:true});save();
  }
 }
 await verifyAttempt(directory);for(const row of inputs.values())verify({file:row.file,sha256:row.sha256});report.inputsUnchanged=true;report.complete=report.pass=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.rows.length,error:report.error?.message}));
