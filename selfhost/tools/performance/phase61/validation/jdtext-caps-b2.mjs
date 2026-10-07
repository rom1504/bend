// Five actual production-size scanner boundaries, through genuine qualified B2 images.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {setup} from '../../../../build/phase61/methods01/bootstrap/setup.mjs';
import {identity,verify,hash,list,array} from '../../phase54/bootstrap/adapter.mjs';

const [baselinePins,candidatePins,outArg]=process.argv.slice(2);
assert(baselinePins&&candidatePins&&outArg,'BASELINE_IMAGE_PINS CANDIDATE_IMAGE_PINS FRESH_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..'),raw=path.join(root,'selfhost/build/phase61'),out=path.resolve(outArg);
assert(out.startsWith(fs.realpathSync(raw)+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=new Map(),pin=(f,want)=>{const r=identity(f);if(want)assert.equal(r.sha256,want.sha256);assert(!inputs.has(r.file)||inputs.get(r.file).sha256===r.sha256);inputs.set(r.file,r);return r;};
const report={kind:'phase61-genuine-b2-jdtext-cap-controls',complete:false,pass:false,roles:{},bounds:[],progress:[],
 scope:'Five full 2097152-codepoint boundaries on actual genuine B2 private helpers. Both images require authentic checked-source emission and eight-driver admission through frozen setup. Independent expected results plus actual old scanner differential. Append-only lexical diagnostics; no checked B2 sidecar, frontend/whole-source qualification, speed claim or surrogate-half composition claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');
const begin=performance.now(),mark=(stage,extra={})=>{report.progress.push({stage,elapsedSeconds:(performance.now()-begin)/1000,...extra});save();};
const term=(tag,name='')=>({$:'KTerm',tag,name,id:0,quant:0,kids:list([]),removed:list([]),originBegin:0,originEnd:0});
const def=name=>({$:'KDef',name,kind:'Def',arity:0,templates:0,typ:term('Typ'),value:term('Typ'),ctors:list([]),native:false,unsafe:false});
const symbol=name=>'$jd$'+Array.from(name,c=>/[a-zA-Z0-9]/.test(c)?c:'_'+c.codePointAt(0)+'_').join('');
const decode=x=>{assert(['None','Some'].includes(x.$));return x.$==='None'?null:array(x.value);};
save();
try {
 for(const f of [import.meta.filename,process.execPath,new URL('../../../../build/phase61/methods01/bootstrap/setup.mjs',import.meta.url),new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url)])pin(f);
 pin(new URL('./jdtext-controls.mjs',import.meta.url),{sha256:'e3d2b614ad2526880e5e271025226ab2d73bdb9e794039f36c2fd4cf82d4b5b5'});
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
 new Function('module','exports',parserSource)(parser,parser.exports);assert.equal(typeof parser.exports.parse,'function');
 const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),states={},apis={};
 for(const [role,pins]of [['baseline',baselinePins],['candidate',candidatePins]]) {
  mark('stage-image',{role});pin(pins);
  const state=await setup(pins,path.join(out,role+'-private'),{role:'direct'});states[role]=state;
  for(const r of state.inputs)pin(r.file,r);
  const original=fs.readFileSync(state.emission.module.file,'utf8'),ast=parse(original);
  const required=['book_cached','jd_reach_names','jd_reach_refs',...(role==='candidate'?['jd_text_raw','jd_text_cat','jd_text_render','jd_text_refs','jd_text_size']:[])];
  for(const name of required)assert.equal(ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===symbol(name)).length,1,'Required actual retained helper '+name);
  assert(!original.includes('phase61Cap'));
  let suffix=`\nexport const phase61CapNames=defs=>${symbol('book_cached')}(${symbol('jd_reach_names')}(defs),0);
export const phase61CapOld=(names,text)=>${symbol('jd_reach_refs')}(names,text,false,2097152,{$:'Nil'});\n`;
  if(role==='candidate')suffix+=`export const phase61Cap={raw:text=>${symbol('jd_text_raw')}(text),
cat:(a,b)=>${symbol('jd_text_cat')}(a,b),render:text=>${symbol('jd_text_render')}(text),
refs:(names,text)=>${symbol('jd_text_refs')}(names,text),size:text=>${symbol('jd_text_size')}(text)};\n`;
  parse(original+suffix);const file=path.join(out,role+'-diagnostic.mjs');fs.writeFileSync(file,original+suffix,{flag:'wx'});
  assert(fs.readFileSync(file).subarray(0,Buffer.byteLength(original)).equals(fs.readFileSync(state.emission.module.file)));
  apis[role]=await import(pathToFileURL(file));
  report.roles[role]={imagePins:pin(pins),image:state.image,parent:pin(state.emission.module.file),derivative:pin(file),suffixSha256:hash(suffix),requiredPrivateHelpers:required,copies:state.copies,productionAbiChanged:false};
 }
 const tables=Object.fromEntries(Object.entries(apis).map(([role,a])=>[role,a.phase61CapNames(list([def('a')]))]));
 const cap=2097152,ending='\n/*JD_REF:'+symbol('a')+'*/',t=apis.candidate.phase61Cap;
 for(const [name,n,marker,expected]of [
  ['raw-below',cap-1,'',[]],['raw-exact',cap,'',[]],['raw-above',cap+1,'',null],
  ['marker-ending-exact',cap,ending,['a']],['marker-crossing-cap',cap+1,ending,null],
 ]) {
  const text='x'.repeat(n-marker.length)+marker;mark('baseline-old-scan',{name,codepoints:n});
  const baseline=decode(apis.baseline.phase61CapOld(tables.baseline,text));assert.deepEqual(baseline,expected,name+': original scanner');
  mark('candidate-raw',{name});const tree=t.raw(text);assert.equal(t.size(tree),Math.min(n,cap+1));
  mark('candidate-render',{name});assert.equal(t.render(tree),text);
  mark('candidate-refs',{name});const actual=decode(t.refs(tables.candidate,tree));assert.deepEqual(actual,expected,name+': transport refs');
  if(n===cap&&!marker){const joined=t.cat(tree,t.raw('x'));assert.equal(t.size(joined),cap+1);assert.deepEqual(decode(t.refs(tables.candidate,joined)),null);}
  report.bounds.push({name,codepoints:n,textSha256:hash(text),expected,baseline,actual,pass:true});mark('case-complete',{name});
 }
 for(const [role,s]of Object.entries(states)){mark('verify-image',{role});report.roles[role].finalVerification=await s.verifyFinal();}
 for(const r of inputs.values())verify(r);
 report.counts={rawCapCases:5,concatenationExcessCases:1};report.complete=report.pass=report.inputsUnchanged=true;mark('complete');
} catch(error) {report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error?.message}));
