// Root-supervised checks of actual checked text-transport helpers; no production ABI edits.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {identity,verify,hash,list,array} from '../../phase54/bootstrap/adapter.mjs';

const [baselineArg,candidateArg,outArg]=process.argv.slice(2);
assert(baselineArg&&candidateArg&&outArg,'BASELINE_ATTEMPT CANDIDATE_ATTEMPT FRESH_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..'),raw=path.join(root,'selfhost/build/phase61');
const out=path.resolve(outArg);assert(out.startsWith(fs.realpathSync(raw)+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=new Map(),pin=(f,want)=>{const r=identity(f);if(want)assert.equal(r.sha256,want.sha256);assert(!inputs.has(r.file)||inputs.get(r.file).sha256===r.sha256);inputs.set(r.file,r);return r;};
const report={kind:'phase61-checked-jdtext-controls',complete:false,pass:false,roles:{},cases:[],bounds:[],
 scope:'Actual checked helpers exposed by append-only diagnostic exports. Independent exact text/USE goldens and original checked reach scanner comparisons over arbitrary code-point splits, malformed/unknown markers, duplicate refs and tree skew. Splits never divide a UTF-16 surrogate pair; arbitrary malformed UTF-16 fragment composition is not qualified. This is not frontend, whole emitted-program, public ABI, performance or B2 qualification.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const term=(tag,name='')=>({$:'KTerm',tag,name,id:0,quant:0,kids:list([]),removed:list([]),originBegin:0,originEnd:0});
const def=name=>({$:'KDef',name,kind:'Def',arity:0,templates:0,typ:term('Typ'),value:term('Typ'),ctors:list([]),native:false,unsafe:false});
const encoded=name=>'$jd$'+Array.from(name,c=>/[a-zA-Z0-9]/.test(c)?c:'_'+c.codePointAt(0)+'_').join('');
const ref=name=>'\n/*JD_REF:'+encoded(name)+'*/',use=id=>'\n/*JD_USE:'+id+'*/';
const ids=[0,1,12,4294967295],names=['a','b','λ','s.dot'];
const rows=[
 ['empty','',[]],['ordinary','return 37;',[]],['unicode','🧭λ\nreturn 37;',[]],
 ['one-ref',ref('a'),['a']],['two-ref-order',ref('a')+ref('b'),['b','a']],
 ['duplicate-ref',ref('a')+ref('b')+ref('a'),['b','a']],['unicode-name',ref('λ')+ref('s.dot'),['s.dot','λ']],
 ['use-zero',use(0),[]],['use-all',ids.map(use).join(''),[]],
 ['mixed-metadata',use(12)+ref('b')+use(1)+ref('a')+ref('b'),['a','b']],
 ['start-ref',ref('a').slice(1),[]],['start-use',use(1).slice(1),[]],
 ['inline-ref','x'+ref('a').slice(1),[]],['indented-ref','\n '+ref('a').slice(1),[]],
 ['escaped-newline','const s="\\n/*JD_REF:'+encoded('a')+'*/";',[]],
 ['partial-ref','\n/*JD_REF:',null],['partial-use','\n/*JD_USE:',[]],
 ['unterminated-ref','\n/*JD_REF:'+encoded('a'),null],
 ['bad-close-ref',ref('a').slice(0,-1)+'x',null],
 ['unknown-ref',ref('missing'),null],['duplicate-then-unknown',ref('a').repeat(3)+ref('missing'),null],
 ['duplicate-then-malformed',ref('a').repeat(3)+'\n/*JD_REF:'+encoded('b')+'*x',null],
 ['use-leading-zero','\n/*JD_USE:01*/',[]],['use-nondigit','\n/*JD_USE:x*/',[]],
 ['use-prefix-similarity',use(12)+use(0),[]],['mixed-quoted-use','const s="'+use(1)+'";',[]],
 ['partial-after-newline','x\n/*JD_R',[]],['newline-boundary','x\n'+ref('a').slice(1),['a']],
];
const decode=x=>{assert(['None','Some'].includes(x.$));return x.$==='None'?null:array(x.value);};

try {
 for(const f of [import.meta.filename,process.execPath,new URL('../../../development/workflow.mjs',import.meta.url),new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url)])pin(f);
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
 new Function('module','exports',parserSource)(parser,parser.exports);assert.equal(typeof parser.exports.parse,'function');
 const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
 const apis={};
 for(const [role,dir]of [['baseline',baselineArg],['candidate',candidateArg]]) {
  const directory=path.resolve(dir),a=await verifyAttempt(directory);assert(a.checked&&a.config.strictExact);
  const attempt=pin(path.join(directory,'attempt.json'));
  for(const k of ['api','runtime','base','node','bootstrapReport'])pin(a[k].file,a[k]);
  assert.equal(identity(process.execPath).sha256,a.node.sha256);
  const validation=pin(path.join(directory,'validation-001/report.json')),v=JSON.parse(fs.readFileSync(validation.file));
  assert(v.complete&&v.pass&&v.strictExact&&v.selected.exactDifferences===0);assert.equal(v.attempt.sha256,attempt.sha256);assert.equal(v.api.sha256,a.api.sha256);
  const original=fs.readFileSync(a.api.file,'utf8'),ast=parse(original);
  const common=['run_loop','$book_cached$','$jd_reach_names$','$jd_reach_refs$','$jd_use$'];
  const added=['$jd_text_raw$','$jd_text_cat$','$jd_text_render$','$jd_text_used$','$jd_text_refs$','$jd_text_size$','$jd_text_safe$'];
  for(const name of [...common,...(role==='candidate'?added:[])])assert.equal(ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===name).length,1,name);
  assert(!original.includes('phase61Text'));
  let suffix=`\nexport const phase61TextNames=defs=>run_loop($book_cached$(run_loop($jd_reach_names$(defs)),0));
export const phase61TextOld=(names,text)=>run_loop($jd_reach_refs$(names,text,false,2097152,{$:'Nil'}));
export const phase61TextUse=id=>run_loop($jd_use$(id));\n`;
  if(role==='candidate')suffix+=`export const phase61Text={
raw:text=>run_loop($jd_text_raw$(text)),cat:(a,b)=>run_loop($jd_text_cat$(a,b)),
render:text=>run_loop($jd_text_render$(text)),used:(text,id)=>run_loop($jd_text_used$(text,id)),
refs:(names,text)=>run_loop($jd_text_refs$(names,text)),size:text=>run_loop($jd_text_size$(text)),safe:text=>run_loop($jd_text_safe$(text))};\n`;
  parse(original+suffix);const file=path.join(out,role+'-diagnostic.mjs');fs.writeFileSync(file,original+suffix,{flag:'wx'});
  assert(fs.readFileSync(file).subarray(0,Buffer.byteLength(original)).equals(fs.readFileSync(a.api.file)));
  apis[role]=await import(pathToFileURL(file));
  report.roles[role]={attempt,validation,api:a.api,derivative:pin(file),suffixSha256:hash(suffix),productionAbiChanged:false};
 }
 const tables=Object.fromEntries(Object.entries(apis).map(([r,a])=>[r,a.phase61TextNames(list(names.map(def)))]));
 const t=apis.candidate.phase61Text;
 for(const id of ids)for(const a of Object.values(apis))assert.equal(a.phase61TextUse(id),use(id));
 let variants=0;
 for(const [name,text,expectedRefs]of rows) {
  const points=Array.from(text),baseline=decode(apis.baseline.phase61TextOld(tables.baseline,text));
  assert.deepEqual(baseline,expectedRefs,name+': independent old-scanner golden');
  assert.deepEqual(decode(apis.candidate.phase61TextOld(tables.candidate,text)),expectedRefs,name+': candidate old scanner');
  const splits=[['whole',[text]]];
  for(let i=0;i<=points.length;i++)splits.push(['split-'+i,[points.slice(0,i).join(''),points.slice(i).join('')]]);
  for(const i of [...new Set([0,1,Math.floor(points.length/2),points.length])])
   for(const j of [...new Set([i,Math.floor((i+points.length)/2),points.length])])
    splits.push(['triple-'+i+'-'+j,[points.slice(0,i).join(''),points.slice(i,j).join(''),points.slice(j).join('')]]);
  for(const [shape,parts]of splits) {
   const leaf=parts.map(s=>t.raw(s)),tree=leaf.reduce((a,b)=>t.cat(a,b),t.raw(''));
   assert.equal(t.render(tree),text,name+': '+shape+': render');
   assert.equal(t.size(tree),points.length,name+': '+shape+': code-point size');
   assert.deepEqual(decode(t.refs(tables.candidate,tree)),expectedRefs,name+': '+shape+': refs');
   for(const id of ids)assert.equal(t.used(tree,id),text.includes(use(id)),name+': '+shape+': USE '+id);
   variants++;
  }
  report.cases.push({name,textSha256:hash(text),codepoints:points.length,splitVariants:splits.length,expectedRefs,expectedUsed:ids.map(id=>({id,value:text.includes(use(id))}))});save();
 }
 // Shared children and opposite skew must keep order, not mutate or drop leaves.
 const leaf=t.raw(ref('a')+use(12)),before=t.render(leaf),count=4096;
 let left=t.raw(''),right=t.raw('');
 for(let i=0;i<count;i++){const x=t.raw(i%2?'x':'y');left=t.cat(left,x);right=t.cat(x,right);}
 for(const [name,tree,text]of [['left',left,'yx'.repeat(count/2)],['right',right,'xy'.repeat(count/2)],['shared',t.cat(leaf,leaf),before+before]]) {
  assert.equal(t.render(tree),text);assert.deepEqual(decode(t.refs(tables.candidate,tree)),decode(apis.baseline.phase61TextOld(tables.baseline,text)));
  for(const id of ids)assert.equal(t.used(tree,id),text.includes(use(id)));
  report.bounds.push({name,codepoints:Array.from(text).length,renderSha256:hash(text),pass:true});
 }
 assert.equal(t.render(leaf),before);
 // Exercise actual raw scanning saturation and marker cutoff once each. These
 // five bounded large witnesses replace redundant multi-million-node DAG walks.
 const cap=2097152,ending=ref('a');
 for(const [name,n,marker,expected]of [
  ['raw-below',cap-1,'',[]],['raw-exact',cap,'',[]],['raw-above',cap+1,'',null],
  ['marker-ending-exact',cap,ending,['a']],['marker-crossing-cap',cap+1,ending,null],
 ]) {
  const text='x'.repeat(n-marker.length)+marker,tree=t.raw(text);
  assert.equal(t.render(tree),text);assert.equal(t.size(tree),Math.min(n,cap+1));
  const baseline=decode(apis.baseline.phase61TextOld(tables.baseline,text));assert.deepEqual(baseline,expected,name+': old scanner');
  assert.deepEqual(decode(t.refs(tables.candidate,tree)),expected,name+': raw refs');
  // Concatenation saturates too; empty children cannot hide a one-character excess.
  if(n===cap&&!marker){const joined=t.cat(tree,t.raw('x'));assert.equal(t.size(joined),cap+1);assert.deepEqual(decode(t.refs(tables.candidate,joined)),null);}
  report.bounds.push({name,codepoints:n,textSha256:hash(text),expectedRefs:expected,pass:true});save();
 }
 for(const dir of [baselineArg,candidateArg])await verifyAttempt(path.resolve(dir));
 for(const r of inputs.values())verify(r);
 report.complete=report.pass=report.inputsUnchanged=true;
 report.counts={textGoldens:rows.length,splitVariants:variants,useIds:ids.length,skewAndBounds:report.bounds.length};
} catch(error) {report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error?.message}));
