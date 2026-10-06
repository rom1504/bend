// Caller owns the sole resource guard. Actual checked/annotated compiler queries.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../development/workflow.mjs';
const [beforeArg,afterArg,outArg]=process.argv.slice(2);assert(beforeArg&&afterArg&&outArg);
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const identity=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const inputs=new Map(),pin=(file,want)=>{const row=identity(file);if(want)assert.equal(row.sha256,want.sha256);if(inputs.has(row.file))assert.deepEqual(row,inputs.get(row.file));inputs.set(row.file,row);return row;};
const digest=x=>{const s=JSON.stringify(x);return{bytes:Buffer.byteLength(s),sha256:createHash('sha256').update(s).digest('hex')};};
const report={kind:'phase55-checked-annotated-arity-controls',complete:false,pass:false,roles:{},copies:[],rows:[],rejections:[],inputs:[],scope:'Actual accepted source graphs and actual annotate_selected terms; private query derivatives only. Whole old/new arity equality, walk-derived residuals, genuine unannotated fallback and real duplicate/arity rejection. No arbitrary Ann records or production ABI modification.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
function copy(file,target){const before=pin(file);fs.mkdirSync(path.dirname(target),{recursive:true});fs.copyFileSync(file,target,fs.constants.COPYFILE_EXCL);const after=pin(target);assert.equal(after.sha256,before.sha256);report.copies.push({before,after});}
function files(dir){return fs.readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name)).flatMap(e=>e.isDirectory()?files(path.join(dir,e.name)):[path.join(dir,e.name)]);}
function setEnv(R){for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];process.env.BEND_TYPED_API=R.m.api.file;process.env.BEND_TYPED_RUNTIME=path.join(R.project,'src/runtime.mjs');process.env.BEND_BASE=R.m.base.file;}
const array=xs=>{const a=[];while(xs?.$==='Con'){assert(a.length<100000);a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;};
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
try{
 pin(import.meta.filename);pin(new URL('../../development/workflow.mjs',import.meta.url).pathname);pin(process.execPath);
 const corpusFile=path.join(import.meta.dirname,'semantic-arity-catalog-v1.json');pin(corpusFile);const corpus=JSON.parse(fs.readFileSync(corpusFile));
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};new Function('module','exports',parserSource)(parser,parser.exports);
 const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),roles={};
 for(const [role,directory] of [['baseline',beforeArg],['candidate',afterArg]]){
  const attemptFile=pin(path.join(directory,'attempt.json'),role==='baseline'?corpus.baselineAttempt:null);const m=await verifyAttempt(path.resolve(directory));assert(m.checked&&m.config.strictExact);if(role==='baseline')assert.equal(m.api.sha256,corpus.baselineAPI);
  for(const key of ['api','runtime','base','node'])pin(m[key].file,m[key]);
  const original=fs.readFileSync(m.api.file,'utf8'),ast=parse(original);for(const name of ['run_loop','$jd_raise$','$jd_arity$','$j_find_ctor$','$j_strip$','$tg$','$nm$','$kid$'])assert.equal(ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===name).length,1,name);
  assert(!original.includes('phase55ArityProbe'));
  const suffix='\nexport const phase55ArityProbe = {raise:(book,t,left)=>run_loop($jd_raise$(book,t,left)),arity:(book,d)=>run_loop($jd_arity$(book,d)),ctor:(book,name)=>run_loop($j_find_ctor$(book,name)),strip:t=>run_loop($j_strip$(t)),tag:t=>run_loop($tg$(t)),name:t=>run_loop($nm$(t)),kid:(t,i)=>run_loop($kid$(t,i))};\n';
  const derivative=path.join(out,role+'-diagnostic-api.mjs');parse(original+suffix);fs.writeFileSync(derivative,original+suffix,{flag:'wx'});pin(derivative);
  const mod=await import(pathToFileURL(derivative));assert(!mod.G,'This B1 diagnostic requires named-field transport, never an unreviewed positional conversion');
  const project=path.join(out,role+'-project');for(const name of ['typed-driver','assemble','compiler-abi','node-resource-args','native-build'])copy(path.join(m.snapshot.root,'tools',name+'.mjs'),path.join(project,'tools',name+'.mjs'));copy(path.join(m.snapshot.root,'src/compiler.json'),path.join(project,'src/compiler.json'));copy(m.runtime.file,path.join(project,'src/runtime.mjs'));for(const file of files(path.join(m.snapshot.root,'src/runtime')))copy(file,path.join(project,path.relative(m.snapshot.root,file)));
  setEnv({m,project});const driverFile=pin(path.join(project,'tools/typed-driver.mjs'));const D=await import(pathToFileURL(driverFile.file));const api=await D.loadApi();assert.equal(D.apiPath,m.api.file);assert.equal(D.project,project);
  roles[role]={m,project,D,api,probe:mod.phase55ArityProbe};report.roles[role]={attempt:attemptFile,api:m.api,runtime:m.runtime,base:m.base,driver:driverFile,privateProject:project,environment:{BEND_TYPED_API:m.api.file,BEND_TYPED_RUNTIME:path.join(project,'src/runtime.mjs'),BEND_BASE:m.base.file},derivative:identity(derivative),suffixSha256:createHash('sha256').update(suffix).digest('hex'),parserVersion:parser.exports.version,parserSourceSha256:createHash('sha256').update(parserSource).digest('hex'),productionAbiChanged:false};save();
 }
 assert.equal(pin(path.join(roles.baseline.m.snapshot.root,'src/back/common/queries.bend')).sha256,pin(path.join(roles.candidate.m.snapshot.root,'src/back/common/queries.bend')).sha256,'Common query contract changed outside experiment');
 function walk(probe,book,t,left,rows){
  const raw=probe.strip(t),tag=probe.tag(raw);if(tag==='Lam'){const childLeft=left>0&&left<2147483648?(left-1)>>>0:0;walk(probe,book,probe.kid(raw,0),childLeft,rows);}
  else if(tag==='Mat'){
   const fields=probe.ctor(book,probe.name(raw)).arity;const residual=(left-1+fields)>>>0;
   rows.push({term:t,left,tag,name:probe.name(raw),fields,residual,annotated:probe.tag(t)==='Ann',value:probe.raise(book,t,left)});
   walk(probe,book,probe.kid(raw,0),residual,rows);walk(probe,book,probe.kid(raw,1),left,rows);
  }
 }
 for(const [index,spec] of corpus.accepted.entries()){
  pin(spec.file,spec);const source=fs.readFileSync(spec.file,'utf8'),names=[...new Set([...source.matchAll(/^def\s+([\w.]+)/gm)].map(m=>m[1]))],row={source:spec,names,roles:{},pass:false};report.rows.push(row);if(index===0)for(const name of Object.keys(corpus.arityGoldens))assert(names.includes(name),'Missing golden source definition '+name);
  for(const [role,R] of Object.entries(roles)){
   setEnv(R);
   const graph=R.D.discoverSources(R.api,spec.file);for(const file of graph.files)pin(file);const loaded=graph.loadTrace.result;assert.equal(loaded.error,'');assert.equal(R.api.check_book(loaded.book),'','Source checker rejection '+spec.file);
   const book=R.api.book_context(loaded.book),selected=array(loaded.book).filter(d=>names.includes(d.name));assert.equal(selected.length,names.length,'Every source definition selected exactly once');
   const annotated=R.api.annotate_selected(book,list(selected),{$:'Nil'});const definitions=array(annotated);const before=digest({book,selected,annotated});const arities=[],rawWalk=[],annWalk=[];
   for(let i=0;i<selected.length;i++){
    const a=selected[i],b=definitions[i];assert.equal(a.name,b.name);const rawArity=R.probe.arity(book,a),annotatedArity=R.probe.arity(book,b);arities.push({name:a.name,raw:rawArity,annotated:annotatedArity});
    if(index===0&&Object.hasOwn(corpus.arityGoldens,a.name)){assert.equal(rawArity,corpus.arityGoldens[a.name]);assert.equal(annotatedArity,corpus.arityGoldens[a.name]);}
    walk(R.probe,book,a.value,a.arity,rawWalk);walk(R.probe,book,b.value,b.arity,annWalk);
   }
   const simplify=xs=>xs.map(({term,...r})=>({...r,term:digest(term)}));const after=digest({book,selected,annotated});assert.deepEqual(after,before,'Query input mutated');
   row.roles[role]={checkedBook:digest(loaded.book),annotatedBook:digest(annotated),arities,rawWalk:simplify(rawWalk),annotatedWalk:simplify(annWalk),inputUnchanged:true};save();
  }
  assert.deepEqual(row.roles.candidate,row.roles.baseline,'Old/new complete source arity evidence differs');row.pass=true;save();
 }
 for(const spec of corpus.rejected){pin(spec.file,spec);const row={source:spec,roles:{},pass:false};report.rejections.push(row);
  for(const [role,R] of Object.entries(roles)){setEnv(R);const result=await R.D.inspect(spec.file,{mode:'check',api:R.api});assert.equal(result.status,'error');assert.equal(result.exitCode,1);assert.equal(result.checked,false);assert(['parse','check'].includes(result.phase));assert(result.diagnostic.includes(spec.diagnosticContains));row.roles[role]={status:result.status,phase:result.phase,exitCode:result.exitCode,checked:result.checked,diagnostic:result.diagnostic};}
  assert.deepEqual(row.roles.candidate,row.roles.baseline);row.pass=true;save();
 }
 const all=report.rows.flatMap(row=>row.roles.candidate.annotatedWalk),raw=report.rows.flatMap(row=>row.roles.candidate.rawWalk);assert(all.some(r=>r.annotated),'No actual annotated matcher witness');assert(raw.some(r=>!r.annotated),'No genuine unannotated matcher fallback witness');assert(report.rows[2].roles.candidate.annotatedWalk.some(r=>r.name==='Mkb'&&r.fields===3&&r.annotated),'Missing actual three-field erased/dependent matcher');
 report.counts={acceptedSources:report.rows.length,rejectedSources:report.rejections.length,sourceDefinitions:report.rows.reduce((n,r)=>n+r.names.length,0),annotatedMatcherQueries:all.length,rawMatcherQueries:raw.length,annotatedWitnesses:all.filter(r=>r.annotated).length,unannotatedWitnesses:raw.filter(r=>!r.annotated).length,fixedArityGoldens:Object.keys(corpus.arityGoldens).length};assert.equal(report.counts.acceptedSources,6);assert.equal(report.counts.rejectedSources,2);
 for(const row of inputs.values())assert.deepEqual(identity(row.file),row);report.complete=true;report.pass=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error}));
