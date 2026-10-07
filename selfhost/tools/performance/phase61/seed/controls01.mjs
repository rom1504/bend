// Private checked-image probes; root supplies external CPU/RSS/deadline guard.
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
const hash=b=>createHash('sha256').update(b).digest('hex'),inputs=new Map();
function pin(f,want){f=fs.realpathSync(f);const b=fs.readFileSync(f),r={file:f,sha256:hash(b),bytes:b.length};if(want){assert.equal(r.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(r.bytes,want.bytes);}if(inputs.has(f))assert.deepEqual(r,inputs.get(f));inputs.set(f,r);return r;}
const source=JSON.parse(fs.readFileSync(pin(path.join(import.meta.dirname,'source01.json')).file));
const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],P={exports:{}};new Function('module','exports',parserText)(P,P.exports);
const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const report={kind:'phase61-seed-equality-controls',complete:false,pass:false,roles:{},equality:[],binding:[],inputs:[],scope:'Exact full primitive String transport supplied to the compiler loader, including long text and surrogate units. Raw boxed/proxy text and global String method-hook trace equivalence are not asserted. No timing oracle, cache bypass or checked derivative receipt.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
try{
 pin(import.meta.filename);pin(process.execPath);pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);
 for(const [role,arg]of [['baseline',baseArg],['candidate',candArg]]){
  const dir=fs.realpathSync(arg),attempt=pin(path.join(dir,'attempt.json')),m=await verifyAttempt(dir);assert.equal(m.checked,true);
  for(const k of ['api','runtime','base','node'])pin(m[k].file,m[k]);
  const seed=pin(path.join(m.snapshot.root,'src/load/seed.bend'));
  assert.equal(seed.sha256,source[role].sha256);
  const text=fs.readFileSync(m.api.file,'utf8'),ast=parse(text),names=['run_loop','$f_seed_text_equal$','$f_seed_matches$','$String$eq$'];
  const declarations={};for(const name of names){const hits=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===name);assert.equal(hits.length,1,name);declarations[name]=hits[0];}
  const eqSource=text.slice(declarations['$String$eq$'].start,declarations['$String$eq$'].end);
  assert(eqSource.includes('==='),'No actual equality implementation');
  assert(!text.includes('$p61SeedProbe'));
  const suffix='\nexport const $p61SeedProbe={equal:(a,b)=>run_loop($f_seed_text_equal$(a,b)),matches:(s,p,t)=>run_loop($f_seed_matches$(s,p,t)),native:(a,b)=>run_loop($String$eq$(a,b))};\n';
  const derived=path.join(out,role+'-seed-probe.mjs');parse(text+suffix);fs.writeFileSync(derived,text+suffix,{flag:'wx'});pin(derived);
  const mod=await import(pathToFileURL(derived));
  report.roles[role]={attempt,api:m.api,base:m.base,seed,strictExactFlag:m.config.strictExact,derivative:pin(derived),actualStringEqSource:eqSource,actualStringEqSha256:hash(eqSource),suffixSha256:hash(suffix),probe:mod.$p61SeedProbe};save();
 }
 const cases=[['empty','',''],['ascii-equal','pine','pine'],['ascii-different','pine','pint'],['unequal-length','pine','pine!'],['astral-equal','λ🙂𐀀','λ🙂𐀀'],['astral-different','λ🙂𐀀','λ🙃𐀀'],['high-surrogate','\ud800','\ud800'],['low-surrogate','\udc00','\udc00'],['surrogate-different','\ud800','\ud801'],['pair-versus-single','\ud800\udc00','\ud800'],['nul-equal','a\0b','a\0b'],['nul-different','a\0b','a\0c'],['combining-not-normalized','é','e\u0301']];
 for(const n of [60000,100000]){
  const a='s'.repeat(n);cases.push([`long-${n}-equal`,a,a],[`long-${n}-first`,a,'t'+a.slice(1)],[`long-${n}-middle`,a,a.slice(0,n/2)+'t'+a.slice(n/2+1)],[`long-${n}-last`,a,a.slice(0,-1)+'t'],[`long-${n}-length`,a,a+'s']);
 }
 const unicode='a🙂\ud800\0λ'.repeat(10000);cases.push(['long-unicode-equal',unicode,unicode],['long-unicode-last',unicode,unicode+'x']);
 const base=fs.readFileSync(report.roles.baseline.base.file,'utf8');assert(base.length<=200000); // exact pinned Base text
 cases.push(['actual-base-text-equal',base,base],['actual-base-text-last',base,base+'\0']);
 for(const [name,a,b]of cases){const expected=a===b,scalarExpected=JSON.stringify(Array.from(a))===JSON.stringify(Array.from(b));assert.equal(expected,scalarExpected);const row={name,aUnits:a.length,bUnits:b.length,aSha256:hash(Buffer.from(a,'utf16le')),bSha256:hash(Buffer.from(b,'utf16le')),expected,roles:{}};
  for(const [role,R]of Object.entries(report.roles)){assert.equal(R.probe.native(a,b),expected);const result=R.probe.equal(a,b);assert.equal(result,expected);row.roles[role]={result};}report.equality.push(row);save();
 }
 const text='type Base61 is Data:\n  Leaf61{}\n# 🙂\ud800\0',pathName='/private/source/Base.bend';
 const ordinary={$:'FSource',name:'Base',path:pathName,text};
 const completed={$:'FCompletedSource',name:'Base',path:pathName,text,parsed:{$:'FResult',book:{$:'Nil'},error:''}};
 const located={$:'FLocatedSource',source:ordinary,begin:3,end:7};
 const binding=[['exact',ordinary,pathName,text,true],['completed',completed,pathName,text,true],['located',located,pathName,text,true],['wrong-name',{...ordinary,name:'Base61'},pathName,text,false],['empty-path',ordinary,'',text,false],['other-path',ordinary,pathName+'.other',text,false],['same-tail-path',ordinary,'/other/source/Base.bend',text,false],['changed-text',ordinary,pathName,text+'x',false],['truncated-text',ordinary,pathName,text.slice(0,-1),false],['nul-path',{...ordinary,path:pathName+'\0'},pathName,text,false]];
 for(const [name,s,p,t,expected]of binding){const before=JSON.stringify(s),row={name,expected,roles:{}};for(const [role,R]of Object.entries(report.roles)){const result=R.probe.matches(s,p,t);assert.equal(result,expected);assert.equal(JSON.stringify(s),before);row.roles[role]={result};}report.binding.push(row);save();}
 for(const r of inputs.values())pin(r.file,r);
 for(const R of Object.values(report.roles))delete R.probe;
 report.complete=true;report.pass=true;save();
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};for(const R of Object.values(report.roles))delete R.probe;save();throw error;}
