// Root-only source candidate controls. Append diagnostic exports; no body edits.
// node leaf-controls-v1.mjs BASELINE_ATTEMPT CANDIDATE_ATTEMPT NEW_PHASE65_OUT [CANDIDATE_IMAGE]
// Optional image permits a separately bound B2 identity witness; this tool does
// not establish B2 lineage. Root must bind that image to its bootstrap receipt.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {makeObserver} from './observe.mjs';import {controls} from './controls-shapes-v2.mjs';
const [baselineArg,candidateArg,outArg,imageArg]=process.argv.slice(2);assert(baselineArg&&candidateArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase65')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex'),inputs=new Map();
function pin(file,want){const real=fs.realpathSync(file),bytes=fs.readFileSync(real),x={file:real,sha256:hash(bytes),bytes:bytes.length};if(want)assert.equal(x.sha256,want.sha256);if(inputs.has(real))assert.deepEqual(x,inputs.get(real));inputs.set(real,x);return x}
const report={kind:'phase65-leaf-substitution-exact-controls',complete:false,pass:false,diagnosticOnly:true,productionQualified:false,derivations:[],cases:[],scope:'Complete old/new substitution and beta values, input immutability, leaf-only eligibility, and actual generated object-reference preservation. The public subst_node source body is retained unchanged; no helper/ABI representation is added. New Lambda fixtures use authentic native boolean quantityPresent; inherited tagged payload fixtures remain supplemental raw preservation cases. Optional image observation does not by itself establish bootstrap lineage. No whole-program timing claim.'};
function save(){report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n')}save();
try{
  for(const name of ['leaf-controls-v1.mjs','shallow-controls-v1.mjs','observe.mjs','controls.mjs','controls-shapes-v2.mjs','observe-shapes-v2.mjs'])pin(path.join(import.meta.dirname,name));pin(process.execPath);pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);
  const baseline=await verifyAttempt(baselineArg),candidate=await verifyAttempt(candidateArg);
  for(const m of [baseline,candidate]){assert(m.checked&&m.config.strictExact);for(const k of ['api','runtime','base','node','bootstrapReport'])pin(m[k].file,m[k]);assert.equal(pin(process.execPath).sha256,m.node.sha256);pin(path.join(m.snapshot.root,'src/core/term.bend'))}
  report.baselineAttempt=pin(path.join(baselineArg,'attempt.json'));report.candidateAttempt=pin(path.join(candidateArg,'attempt.json'));
  const manifestFile=path.join(import.meta.dirname,'leaf-only-v1/manifest.json');pin(manifestFile);const manifest=JSON.parse(fs.readFileSync(manifestFile));
  assert.equal(pin(path.join(baseline.snapshot.root,'src/core/term.bend')).sha256,manifest.beforeSha256);
  assert.equal(pin(path.join(candidate.snapshot.root,'src/core/term.bend')).sha256,manifest.afterSha256);
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],P={exports:{}};new Function('module','exports',parserSource)(P,P.exports);
  const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
  async function expose(file,role){
    const parent=pin(file),source=fs.readFileSync(file,'utf8'),ast=parse(source),names=new Set(ast.body.filter(n=>n.type==='FunctionDeclaration').map(n=>n.id.name));
    const b2=names.has('$jd$subst'),name=s=>b2?'$jd$'+[...s].map(c=>/[A-Za-z0-9]/.test(c)?c:'_'+c.codePointAt(0)+'_').join(''):'$'+s+'$';
    const requested=['subst','subst_node','core_beta'];for(const s of requested)assert(names.has(name(s)),s);assert(names.has('run_loop'));assert(!source.includes('phase65TermQueries'));
    const suffix='\nexport const phase65TermQueries={'+requested.map(s=>JSON.stringify(s)+':(...xs)=>run_loop('+name(s)+'(...xs))').join(',')+'};\n';parse(source+suffix);
    const target=path.join(out,role+'-queries.mjs');fs.writeFileSync(target,source+suffix,{flag:'wx'});report.derivations.push({role,parent,output:pin(target),appendOnly:true,suffixSha256:hash(suffix),parserSha256:hash(parserSource),generatedConvention:b2?'self-emitted':'TypeScript-emitted'});
    const module=await import(pathToFileURL(target));assert.equal(module.G,undefined);return module.phase65TermQueries;
  }
  const old=await expose(baseline.api.file,'baseline'),fresh=await expose(imageArg??candidate.api.file,'candidate');
  report.inheritedControls={baseline:controls(old,makeObserver()),candidate:controls(fresh,makeObserver())};
  const nil=()=>({$:'Nil'}),list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil());
  const term=(tag,xs=[],extra={})=>({$:'KTerm',tag,name:'',id:0,quant:0,kids:list(xs),removed:nil(),originBegin:17,originEnd:29,...extra});
  const ref=term('Ref',[],{name:'f'}),v=id=>term('Var',[],{id}),lit={$:'KLiteral',kind:'String',number:0,text:'x\u0000😀',originBegin:3,originEnd:9};
  const lam=xs=>({$:'KLambda',name:'x',id:7,quant:1,kids:list(xs),removed:list(['r']),originBegin:5,originEnd:11,quantityPresent:false});
  const app=(f,x,extra={})=>term('App',[f,x],extra);
  const shapes=[['ref',ref],['literal',lit],['var',v(7)],['var-max',v(4294967295)],['var-payload',term('Var',[app(lam([v(7)]),lit)],{id:8})],
    ['typ',term('Typ',[v(7)])],['all',term('All',[v(7),ref],{id:7,quant:2})],['adt',term('ADT',[v(7),v(99)])],['annotation',term('Ann',[ref,v(99)])],
    ['lambda-empty',lam([])],['lambda-one',lam([v(7)])],['lambda-two',lam([ref,lit])],['lambda-three',lam([ref,lit,ref])],['lambda-present',{...lam([ref]),quantityPresent:true}],
    ['app',app(ref,v(7))],['beta-app',app(lam([v(7)]),lit)],['introduced-app',app(v(7),lit)],['app-name',app(ref,lit,{name:'stale'})],['app-id',app(ref,lit,{id:3})],
    ['app-quantity',app(ref,lit,{quant:2})],['app-removed',app(ref,lit,{removed:list(['gone'])})],['app-empty',term('App')],['app-one',term('App',[ref])],['app-three',term('App',[ref,lit,v(7)])],
    ['nested',term('All',[ref,term('All',[v(7),term('ADT',[ref,v(99)])])])]];
  const leafStable=(t,id)=>t.$==='KLiteral'||(t.$==='KTerm'&&t.tag==='Var'?t.id!==id:!(t.$==='KTerm'&&t.tag==='App')&&t.kids?.$==='Nil');
  let identities=0;
  for(const [shape,t]of shapes)for(const id of [7,99,4294967295])for(const [replacementName,replacement]of [['ref',ref],['var',v(99)],['lambda',lam([v(7)])]]){
    const before=structuredClone(t),beforeReplacement=structuredClone(replacement),expected=old.subst(t,id,replacement),actual=fresh.subst(t,id,replacement);
    assert.deepEqual(actual,expected,shape);assert.deepEqual(t,before);assert.deepEqual(replacement,beforeReplacement);
    const admitted=leafStable(t,id);
    if(admitted){assert.equal(actual,t,shape+' generated original reference');identities++}
    assert.deepEqual(fresh.subst_node(t,id,replacement),old.subst_node(t,id,replacement),shape+' public node fallback');
    assert.deepEqual(fresh.core_beta(t),old.core_beta(t),shape+' beta');
    report.cases.push({shape,id,replacement:replacementName,admitted,exact:true,originalReference:admitted});
  }
  const ordered=term('All',[v(7),v(99)]),oldOrdered=old.subst(old.subst(ordered,7,v(99)),99,lit),newOrdered=fresh.subst(fresh.subst(ordered,7,v(99)),99,lit);assert.deepEqual(newOrdered,oldOrdered);report.orderedReplacement=true;
  report.actualReferenceWitnesses=identities;assert(identities>0);await verifyAttempt(baselineArg);await verifyAttempt(candidateArg);for(const p of inputs.values())assert.deepEqual(pin(p.file),p);report.complete=report.pass=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1}finally{save()}
console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,actualReferenceWitnesses:report.actualReferenceWitnesses,error:report.error}));
