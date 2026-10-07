// Diagnostic copies only. Root provides the process-tree guard; no compiler build here.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [baseArg,candArg,outArg]=process.argv.slice(2);
assert(baseArg&&candArg&&outArg,'controls01.mjs BASELINE_ATTEMPT CANDIDATE_ATTEMPT NEW_OUT');
const root=fs.realpathSync(path.resolve(import.meta.dirname,'../../../../build/phase61'));
const out=path.resolve(outArg);assert(out.startsWith(root+path.sep));assert(!fs.existsSync(out));
let ancestor=path.dirname(out);while(!fs.existsSync(ancestor))ancestor=path.dirname(ancestor);
assert(fs.realpathSync(ancestor)===root||fs.realpathSync(ancestor).startsWith(root+path.sep));
fs.mkdirSync(out,{recursive:true});assert(fs.realpathSync(out).startsWith(root+path.sep));
const hash=b=>createHash('sha256').update(b).digest('hex');
const inputs=new Map();
function pin(f,want){f=fs.realpathSync(f);const b=fs.readFileSync(f),r={file:f,sha256:hash(b),bytes:b.length};if(want){assert.equal(r.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(r.bytes,want.bytes);}if(inputs.has(f))assert.deepEqual(r,inputs.get(f));inputs.set(f,r);return r;}
const source=JSON.parse(fs.readFileSync(pin(path.join(import.meta.dirname,'source01.json')).file));
const canonical=source.rowsExact.map(s=>JSON.parse('['+s.slice('JDPrimitive{'.length,-1)+']'));
assert.equal(canonical.length,90);assert.equal(new Set(canonical.map(x=>x[0])).size,90);
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=xs=>{const a=[];while(xs?.$==='Con'){assert(a.length<1000);a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;};
const term=(tag,name='',id=0,quant=0,kids=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
function def(name,n){let ty=term('Ref','U32');for(let i=n-1;i>=0;i--)ty=term('All','',100+i,1,[term('Ref','U32'),ty]);return {$:'KDef',name,kind:'Def',arity:n,templates:0,typ:ty,value:term('Lit','0'),ctors:list([]),native:true,unsafe:false};}
const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],P={exports:{}};new Function('module','exports',parserText)(P,P.exports);
const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const report={kind:'phase61-primitive-selection-controls',complete:false,pass:false,roles:{},rows:[],admission:[],inputs:[],scope:'Private checked-image differential metadata/admission probes. Synthetic KDefs test helper predicates, not acceptance of unchecked source. Full source compilation/conformance and latency remain separate gates.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
try{
 pin(import.meta.filename);pin(process.execPath);pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);
 for(const [role,arg]of [['baseline',baseArg],['candidate',candArg]]){
  const dir=fs.realpathSync(arg),attempt=pin(path.join(dir,'attempt.json')),m=await verifyAttempt(dir);assert.equal(m.checked,true);
  for(const k of ['api','runtime','base','node'])pin(m[k].file,m[k]);
  const primitive=pin(path.join(m.snapshot.root,'src/back/js/direct/primitive.bend'));
  assert.equal(primitive.sha256,role==='baseline'?source.source.sha256:source.candidate.sha256);
  const text=fs.readFileSync(m.api.file,'utf8'),ast=parse(text);
  const names=['run_loop','$jd_primitive_table$','$jd_primitive_find$','$jd_primitive_candidate_emit$','$jd_native_known$','$jd_intrinsic$'];
  if(role==='candidate')names.push('$jd_primitive_select$');
  for(const name of names)assert.equal(ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===name).length,1,name);
  assert(!text.includes('$p61PrimitiveProbe'));
  const suffix='\nexport const $p61PrimitiveProbe={rows:()=>run_loop($jd_primitive_table$()),select:n=>run_loop('+(role==='candidate'?'$jd_primitive_select$(n)':'$jd_primitive_find$(n,run_loop($jd_primitive_table$()))')+'),known:(b,d)=>run_loop($jd_native_known$(b,d)),emit:(b,d,a)=>run_loop($jd_primitive_candidate_emit$(b,d,a)),intrinsic:(b,n,a)=>run_loop($jd_intrinsic$(b,n,a))};\n';
  const derived=path.join(out,role+'-probe.mjs');parse(text+suffix);fs.writeFileSync(derived,text+suffix,{flag:'wx'});pin(derived);
  const mod=await import(pathToFileURL(derived));assert.equal(mod.G,undefined);
  report.roles[role]={attempt,api:m.api,primitive,strictExactFlag:m.config.strictExact,derivative:pin(derived),suffixSha256:hash(suffix),probe:mod.$p61PrimitiveProbe};save();
 }
 const normalized=p=>[p.name,p.arity,p.code];
 for(const R of Object.values(report.roles))assert.deepEqual(array(R.probe.rows()).map(normalized),canonical);
 const keys=[...canonical.map(x=>x[0]),'', 'U32','u32.add','U32.add.extra','String.eqx','Array.atomic','Unknown61','λ🙂','constructor','__proto__'];
 for(const name of keys){const expected=canonical.find(x=>x[0]===name)||['',0,''];for(const R of Object.values(report.roles))assert.deepEqual(normalized(R.probe.select(name)),expected);report.rows.push({name,expected});}
 for(const [name,n,code]of canonical){
  const d=def(name,n),args=list(Array.from({length:n},(_,i)=>'$arg'+i));
  const erased={...d,typ:term('All','',99,0,[term('Typ','',0,1),d.typ])};
  const tests=[['native',d,true],['erased-prefix',erased,true],['source-same-name',{...d,native:false},false],['foreign',{...d,value:term('Foreign')},false],['templates',{...d,templates:1},false],['wrong-kind',{...d,kind:'Ctr'},false],['wrong-arity',def(name,n+1),false]];
  for(const [caseName,x,expected]of tests){let emission;for(const R of Object.values(report.roles)){assert.equal(R.probe.known(list([]),x),expected);const e=R.probe.emit(list([]),x,args);if(emission===undefined)emission=e;else assert.equal(e,emission);assert.equal(e!== '',expected);}report.admission.push({name,caseName,expected});}
  for(const R of Object.values(report.roles))assert.equal(R.probe.emit(list([]),d,list([])),'');
 }
 for(const R of Object.values(report.roles))assert.equal(R.probe.intrinsic(list([def('String.eq',2)]),'String.eq',list(['a','b'])),'');
 for(const r of inputs.values())pin(r.file,r);
 for(const R of Object.values(report.roles))delete R.probe;
 report.complete=true;report.pass=true;save();
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};for(const R of Object.values(report.roles))delete R.probe;save();throw error;}
