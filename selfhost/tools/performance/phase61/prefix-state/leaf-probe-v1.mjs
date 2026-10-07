// Diagnostic old-compiler counters only. Root supplies the one process guard.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [attemptArg,...args]=process.argv.slice(2),outArg=args.pop();assert(attemptArg&&args.length&&outArg);
const out=path.resolve(outArg),raw=path.resolve(import.meta.dirname,'../../../../build/phase61');
assert(out.startsWith(raw+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex'),inputs=new Map();
function pin(f,want){const b=fs.readFileSync(f),r={file:fs.realpathSync(f),sha256:hash(b),bytes:b.length};if(want)assert.equal(r.sha256,want.sha256);if(inputs.has(r.file))assert.deepEqual(r,inputs.get(r.file));inputs.set(r.file,r);return r;}
const report={kind:'phase61-old-substitution-leaf-allocation-probe',complete:false,pass:false,compilerQualification:false,scope:'Actual unchanged old compiler plus bounded scalar counters. No speedup, candidate substitution or retained-heap claim.',rows:[],inputs:[]};
function save(){report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');}save();
try{
 pin(import.meta.filename);pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);pin(process.execPath);
 const dir=fs.realpathSync(attemptArg),attempt=pin(path.join(dir,'attempt.json')),m=await verifyAttempt(dir);assert(m.checked&&m.config.strictExact);for(const k of ['api','runtime','base','node'])pin(m[k].file,m[k]);assert.equal(pin(process.execPath).sha256,m.node.sha256);
 const project=path.join(out,'project');fs.cpSync(m.snapshot.root,project,{recursive:true});
 for(const f of ['tools/typed-driver.mjs','src/core/term.bend','src/check/env-substitution.bend','src/back/common/queries.bend'])pin(path.join(m.snapshot.root,f));
 const original=fs.readFileSync(m.api.file,'utf8'),P={exports:{}};new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(P,P.exports);
 const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original),edits=[];
 const fn=name=>{const hits=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id?.name===name);assert.equal(hits.length,1,name);return hits[0];};
 for(const [name,phase] of [['$base_prefix_resume_saved$','checking'],['$annotate_selected$','annotation'],['$jd_library_selected$','emission']])edits.push({at:fn(name).body.start+1,text:'$p61Leaf.phase='+JSON.stringify(phase)+';'});
 for(const [name,env] of [['$subst_node$',false],['$env_subst_term$',true]]){const f=fn(name);assert(f.params.every(p=>p.type==='Identifier'));const t=f.params[0].name,b=env?f.params[1].name:null;
  const condition=env?'('+b+'.$!=="Nil"&&'+t+'.$==="KTerm"&&'+t+'.tag!=="Var")':t+'.$==="KTerm"';
  edits.push({at:f.body.start+1,text:'if($p61Leaf.phase&&'+condition+'){const c=$p61Leaf.rows[$p61Leaf.phase]['+JSON.stringify(env?'env':'ordinary')+'];c.nodes++;if('+t+'.kids.$==="Nil"){if('+t+'.tag==="App")c.emptyApps++;else{c.safeLeaves++;if(c.tags['+t+'.tag]!==undefined)c.tags['+t+'.tag]++;else c.tags.other++;}}}'});
 }
 let text=original;for(const e of [...edits].sort((a,b)=>b.at-a.at))text=text.slice(0,e.at)+e.text+text.slice(e.at);
 const suffix='\nconst $p61Leaf={phase:null,rows:Object.fromEntries(["checking","annotation","emission"].map(p=>[p,Object.fromEntries(["ordinary","env"].map(k=>[k,{nodes:0,safeLeaves:0,emptyApps:0,tags:{Ref:0,Qua:0,Typ:0,ADT:0,Ctr:0,other:0}}]))]))};export const phase61Leaf=$p61Leaf;\n';text+=suffix;parse(text);
 let recovered=text.slice(0,-suffix.length);for(const e of [...edits].sort((a,b)=>a.at-b.at)){assert.equal(recovered.slice(e.at,e.at+e.text.length),e.text);recovered=recovered.slice(0,e.at)+recovered.slice(e.at+e.text.length);}assert.equal(recovered,original);
 const apiFile=path.join(project,'dist/api.mjs');fs.mkdirSync(path.dirname(apiFile),{recursive:true});fs.writeFileSync(apiFile,text);const derivative=pin(apiFile);
 for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];process.env.BEND_TYPED_API=apiFile;process.env.BEND_TYPED_RUNTIME=m.runtime.file;process.env.BEND_BASE=m.base.file;
 const driver=pin(path.join(project,'tools/typed-driver.mjs')),D=await import(pathToFileURL(driver.file)),mod=await import(pathToFileURL(apiFile));assert(mod.phase61Leaf&&mod.default);const counters=mod.phase61Leaf;
 report.binding={attempt,api:m.api,runtime:m.runtime,base:m.base,node:m.node,driver,derivative,edits,suffixSha256:hash(suffix),privateProject:project};save();
 for(const sourceArg of args){const source=pin(sourceArg);for(const row of Object.values(counters.rows))for(const c of Object.values(row)){c.nodes=0;c.safeLeaves=0;c.emptyApps=0;for(const k of Object.keys(c.tags))c.tags[k]=0;}counters.phase=null;
  const result=await D.inspect(source.file,{mode:'library',backend:'direct'});assert.equal(result.status,'ok',result.diagnostic);assert.equal(result.checked,true);assert.equal(typeof result.code,'string');
  for(const f of result.files??[])pin(f);const counts=JSON.parse(JSON.stringify(counters.rows));report.rows.push({source,outputSha256:hash(result.code),status:result.status,checked:result.checked,counts,
   lowerBoundRemovedKTermObjects:Object.values(counts).reduce((n,r)=>n+r.ordinary.safeLeaves+r.env.safeLeaves,0),extraFlagWrappers:0,extraTreeWalks:0});save();
 }
 for(const r of inputs.values())pin(r.file,r);report.complete=true;report.pass=true;save();
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};save();throw error;}
