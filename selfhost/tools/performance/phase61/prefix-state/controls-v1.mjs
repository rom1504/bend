// Root owns the only resource guard. Diagnostic checkpoint, not public ABI.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [attemptArg,sourceArg,outArg]=process.argv.slice(2);assert(attemptArg&&sourceArg&&outArg);
const raw=path.resolve(import.meta.dirname,'../../../../build/phase61'),out=path.resolve(outArg);
assert(out.startsWith(raw+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex'),inputs=new Map();
function pin(f,want){const b=fs.readFileSync(f),r={file:fs.realpathSync(f),sha256:hash(b),bytes:b.length};if(want)assert.equal(r.sha256,want.sha256);if(inputs.has(r.file))assert.deepEqual(r,inputs.get(r.file));inputs.set(r.file,r);return r;}
const stringify=x=>JSON.stringify(x,(_,v)=>typeof v==='bigint'?{$bigint:String(v)}:v),digest=x=>hash(stringify(x));
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=xs=>{const a=[];while(xs?.$==='Con'){assert(a.length<20000);a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;};
const report={kind:'phase61-request-context-prefix-controls',complete:false,pass:false,scope:'Actual checked compiler private checkpoint; exact whole declaration context and fresh floor. No cold gain, Base-only resume, persistent checked state, public snapshot ABI or promotion claim.',roles:{},rows:[],inputs:[]};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
try{
 pin(import.meta.filename);pin(process.execPath);pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);
 const directory=fs.realpathSync(attemptArg),attempt=pin(path.join(directory,'attempt.json')),m=await verifyAttempt(directory);assert(m.checked&&m.config.strictExact);
 for(const k of ['api','runtime','base','node'])pin(m[k].file,m[k]);assert.equal(pin(process.execPath).sha256,m.node.sha256);
 const prefixSource=pin(path.join(m.snapshot.root,'src/check/prefix-state.bend'));
 const driverFile=pin(path.join(m.snapshot.root,'tools/typed-driver.mjs')),sourceFile=pin(sourceArg);
 for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
 process.env.BEND_TYPED_API=m.api.file;process.env.BEND_TYPED_RUNTIME=m.runtime.file;process.env.BEND_BASE=m.base.file;
 const D=await import(pathToFileURL(driverFile.file)),api=await D.loadApi();assert.equal(D.apiPath,m.api.file);
 const graph=D.discoverSources(api,sourceFile.file);for(const f of graph.files)pin(f);assert.equal(graph.loadTrace.result.error,'');
 const original=fs.readFileSync(m.api.file,'utf8'),P={exports:{}};const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];new Function('module','exports',parserText)(P,P.exports);
 const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original),names=['run_loop','$prefix_state_prepare$','$prefix_state_resume$','$prefix_state_admitted$','$prefix_state_exact_defs$','$dg_check_world$','$prefix_state_resume_saved$','$check_definition_world$'];
 const edits=[];for(const name of names){const hits=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id?.name===name);assert.equal(hits.length,1,name);if(['$dg_check_world$','$prefix_state_resume_saved$','$check_definition_world$'].includes(name))edits.push({at:hits[0].body.start+1,text:'$p61PrefixCounts['+JSON.stringify(name)+']++;'});}
 let text=original;for(const e of [...edits].sort((a,b)=>b.at-a.at))text=text.slice(0,e.at)+e.text+text.slice(e.at);
 const suffix='\nconst $p61PrefixCounts={"$dg_check_world$":0,"$prefix_state_resume_saved$":0,"$check_definition_world$":0};\nexport const phase61Prefix={counts:$p61PrefixCounts,prepare:(p,s)=>run_loop($prefix_state_prepare$(p,s)),resume:(c,p,s)=>run_loop($prefix_state_resume$(c,p,s)),admitted:(c,p,s)=>run_loop($prefix_state_admitted$(c,p,s)),exact:(a,b)=>run_loop($prefix_state_exact_defs$(a,b)),full:b=>run_loop($dg_check_world$(b))};\n';
 text+=suffix;parse(text);const derivative=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(derivative,text,{flag:'wx'});pin(derivative);
 let recovered=text.slice(0,-suffix.length);for(const e of [...edits].sort((a,b)=>a.at-b.at)){assert.equal(recovered.slice(e.at,e.at+e.text.length),e.text);recovered=recovered.slice(0,e.at)+recovered.slice(e.at+e.text.length);}assert.equal(recovered,original);
 const mod=await import(pathToFileURL(derivative));assert.equal(mod.G,undefined);const Q=mod.phase61Prefix;
 // Same Base interval and ordinary loader as prepareBase, without writing cache.
 const rawBase={$:'FSource',name:'Base',path:m.base.file,text:fs.readFileSync(m.base.file,'utf8')};
 const located=api.f_source_located(rawBase,1,rawBase.text.length+2),base=api.f_load_graph('Base',list([located]));assert.equal(base.error,'');
 const all=array(graph.loadTrace.result.book),baseDefs=array(base.book);assert(baseDefs.length>0&&all.length>baseDefs.length);const prefix=all.slice(0,baseDefs.length),tail=all.slice(baseDefs.length);assert(Q.exact(list(prefix),base.book),'Loaded graph is not exact Base prefix');
 report.roles.candidate={attempt,api:m.api,runtime:m.runtime,base:m.base,node:m.node,driver:driverFile,prefixSource,source:sourceFile,derivative:pin(derivative),suffixSha256:hash(suffix),edits,loadedBookSha256:digest(all),prefixCount:prefix.length,suffixCount:tail.length};save();
 const counts=()=>({...Q.counts}),delta=(a,b)=>Object.fromEntries(Object.keys(a).map(k=>[k,b[k]-a[k]]));
 let before=counts();const state=Q.prepare(list(prefix),list(tail)),prepareCounts=delta(before,counts()),stateHash=digest(state);assert.equal(state.result.result.error,'');
 function row(id,p,s,expected,checkpoint=state){const beforeInput=digest({checkpoint,p,s}),admitted=Q.admitted(checkpoint,list(p),list(s));if(expected!==null)assert.equal(admitted,expected,id);let c=counts();const full=Q.full(list([...p,...s])),fullCounts=delta(c,counts());c=counts();const resumed=Q.resume(checkpoint,list(p),list(s)),resumeCounts=delta(c,counts());assert.deepEqual(resumed,full,id+' whole world/diagnostic');assert.equal(digest({checkpoint,p,s}),beforeInput,id+' immutable input');assert.equal(resumeCounts['$prefix_state_resume_saved$'],admitted?1:0);if(admitted)assert.equal(resumeCounts['$dg_check_world$'],0);else assert.equal(resumeCounts['$dg_check_world$'],1);report.rows.push({id,admitted,pass:true,outcome:digest(full),error:full.result.error,fullCounts,resumeCounts});save();return {fullCounts,resumeCounts};}
 const ordinary=row('ordinary-repeat',prefix,tail,true);assert(ordinary.fullCounts['$check_definition_world$']>ordinary.resumeCounts['$check_definition_world$']);assert.equal(ordinary.fullCounts['$check_definition_world$'],prepareCounts['$check_definition_world$']+ordinary.resumeCounts['$check_definition_world$']);row('repeat-again',prefix,tail,true);assert.equal(digest(state),stateHash);
 const t=prefix[0].typ,changedPrefix=[{...prefix[0],typ:{...t,originBegin:t.originBegin===0?1:t.originBegin+1}},...prefix.slice(1)];row('changed-prefix-span',changedPrefix,tail,false);
 const changedHeader=[{...tail[0],unsafe:!tail[0].unsafe},...tail.slice(1)];row('changed-declaration',prefix,changedHeader,false);
 const fill=[prefix[0],...tail];row('cross-prefix-fill',prefix,fill,false);
 const empty=Q.prepare(list([]),list(all));row('empty-prefix',[],all,true,empty);
 report.prepareCounts=prepareCounts;report.checkpointSha256=stateHash;report.counts={rows:report.rows.length,admitted:report.rows.filter(r=>r.admitted).length,fallback:report.rows.filter(r=>!r.admitted).length};
 for(const r of inputs.values())pin(r.file,r);report.complete=true;report.pass=true;save();
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};save();throw error;}
