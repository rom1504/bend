// Root-supervised only. Inputs must be fresh checked library acquisitions.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [baselineArg,candidateArg,typescriptArg,outArg]=process.argv.slice(2);
assert(baselineArg&&candidateArg&&typescriptArg&&outArg&&process.argv.length===6);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase58')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const report={kind:'phase58-scalar-residual-controls-v1',complete:false,pass:false,inputs:[],roles:{},observations:[],syntax:{},scope:'Checked native U32 values; full residual recomposition, mutation/alias refusal, width31/32 and unchanged F32 residual paths. No arbitrary boxed scalar or builtin monkeypatch contract; diagnostic counters are not timing evidence.'};
const sha=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const r={file,sha256:sha(file),bytes:fs.statSync(file).size};report.inputs.push(r);return r;};
const pm={exports:{}};new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(pm,pm.exports);
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const source=pin(new URL('./scalar-v1.bend',import.meta.url)),catalog=pin(new URL('./catalog-v1.json',import.meta.url));
function audit(value){if(!value||typeof value!=="object")return;if(value.sha256&&(value.file||value.path||value.canonicalPath)){const actual=pin(value.file??value.path??value.canonicalPath);assert.equal(actual.sha256,value.sha256);}for(const child of Object.values(value))audit(child);}
const checkedDirectories=[];
async function read(file,role){
 const module=pin(file),receiptPin=pin(file+'.json'),receipt=JSON.parse(fs.readFileSync(receiptPin.file));
 assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');assert.equal(receipt.output.sha256,module.sha256);assert.equal(receipt.input.sha256,source.sha256);assert.equal(receipt.catalog.sha256,catalog.sha256);
 assert.equal(receipt.compiler.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');assert.equal(receipt.compiler.callingContract,'upstream-compatible-direct-v1');
 assert.equal(receipt.compiler.kind==='checked-pinned-typescript',role==='typescript');
 assert.equal(receipt.producer.sha256,'f730abcde7203c61339f4eafefa144bc5c01031d5a1936c88d493afd5fe2d4a1');assert.equal(receipt.node,process.version);
 if(role!=='typescript'){
  assert.equal(receipt.compiler.backend,'direct');assert(receipt.attempt?.sha256);const p=pin(receipt.attempt.file??receipt.attempt.path);assert.equal(p.sha256,receipt.attempt.sha256);
  const directory=path.dirname(p.file),attempt=await verifyAttempt(directory);checkedDirectories.push(directory);assert(attempt.checked);
  for(const key of ['api','runtime','base'])assert.equal(receipt.compiler[key].sha256,attempt[key].sha256);
  assert.equal(receipt.compiler.driver.sha256,sha(path.join(attempt.snapshot.root,'tools/typed-driver.mjs')));
  assert.equal(receipt.compiler.directRuntime.sha256,sha(path.join(attempt.snapshot.root,'src/runtime/js/direct.mjs')));
  const bootstrapPin=pin(attempt.bootstrapReport.file);assert.equal(bootstrapPin.sha256,attempt.bootstrapReport.sha256);const bootstrap=JSON.parse(fs.readFileSync(bootstrapPin.file));assert.equal(receipt.compiler.sourceSha256,bootstrap.sourceSha256);
  const needed=[receipt.input,receipt.compiler.base,receipt.compiler.directRuntime];for(const wanted of needed)assert(receipt.emissionInputs.some(x=>x.sha256===wanted.sha256&&fs.realpathSync(x.file??x.path)===fs.realpathSync(wanted.file??wanted.path)));
  assert.deepEqual(receipt.observation.files.map(x=>fs.realpathSync(x)).sort(),receipt.emissionInputs.map(x=>fs.realpathSync(x.file??x.path)).sort());
  assert(fs.readFileSync(module.file,'utf8').startsWith(fs.readFileSync(receipt.compiler.directRuntime.file,'utf8')+'\n'));
 }
 audit([receipt.producer,receipt.parentProducer,receipt.previousProducer,receipt.verifiers,receipt.emissionInputs,receipt.compiler]);
 for(const row of [receipt.input,receipt.catalog,...Object.values(receipt.compiler)])if(row&&typeof row==='object'&&row.sha256&&(row.file||row.path||row.canonicalPath)){const actual=pin(row.file??row.path??row.canonicalPath);assert.equal(actual.sha256,row.sha256);}
 report.roles[role]={module,receipt:receiptPin,compiler:receipt.compiler,attempt:receipt.attempt};return fs.readFileSync(module.file,'utf8');
}
const name=s=>'$jd$'+[...s].map(c=>/[A-Za-z0-9]/.test(c)?c:'_'+c.codePointAt(0)+'_').join('');
function functions(code){return new Map(parse(code).body.filter(n=>n.type==='FunctionDeclaration').map(n=>[n.id.name,code.slice(n.start,n.end)]));}
const inputValues=[...Array.from({length:260},(_,i)=>i),1023,1024,32767,32768,55295,55296,57343,57344,65535,65536,0x7fffffff,0x80000000,0x80000001,0xfffffffe,0xffffffff];
const escaped=new Map([[34,900],[92,901],[8,902],[9,903],[10,904],[12,905],[13,906]]);
const bitsOf=x=>{const b=new ArrayBuffer(4),v=new DataView(b);v.setFloat32(0,x,true);return v.getUint32(0,true);};
const fromBits=x=>{const b=new ArrayBuffer(4),v=new DataView(b);v.setUint32(0,x,true);return v.getFloat32(0,true);};
function word(w,n){let v=0n;for(let i=0;i<n;i++){assert.equal(w.$,'WCon');assert.equal(typeof w.head,'boolean');if(w.head)v|=1n<<BigInt(i);w=w.tail;}assert.deepEqual(w,{$:'WNil'});return Number(v);}
function observe(api){const f=api.default;assert(f&&!api.G);let count=0;
 for(const n of inputValues){const expected={residual:escaped.has(n)?escaped.get(n):(n+17)>>>0,prefix:(n&3)===1?((n&0xfffffffc)|2)>>>0:n,swapbits:(n&1)===0?((n&0xfffffffc)|((n>>>1)&1))>>>0:0,high:(n&0x7fffffff)===0?(n|0x7fffffff)>>>0:n,whole:n,ignore:7};for(const [fn,value]of Object.entries(expected)){assert.equal(f[fn](n),value,fn+' '+n);count++;}}
 for(const a of [0,1,2,3,0x80000000,0xffffffff])for(const b of [0,1,2,3,0x80000000,0xffffffff]){assert.equal(f.mixed(a,b),(a&1)===0&&(b&1)===0?((b&0xfffffffd)|(a&2))>>>0:0);count++;}
 for(const n of [0,1,6,0x80000000,0xffffffff]){const p=f.aliases(n);assert.equal(p.$,'ResidualPair');assert.equal(p.left,p.right);assert.equal(word(p.left,30),n>>>2);assert.notEqual(f.aliases(n).left,p.left);p.left.head=!p.left.head;assert.equal(p.left.head,p.right.head);count++;}
 for(const n of [0,1,6,37,0xffffffff]){let calls=0;assert.equal(f.touch(w=>{calls++;w.head=!w.head;return 0;},n),(n^4)>>>0);assert.equal(calls,1);count++;}
 const sentinel={sentinel:'callback'};assert.throws(()=>f.touch(()=>{throw sentinel;},10),e=>e===sentinel);count++;
 const p=f.touch(w=>{w.head=!w.head;return 0;});assert.equal(p(21),17);count++;
 const floats=[0,-0,1.5,-1.5,Infinity,-Infinity,NaN,fromBits(1),fromBits(0x7f800001),fromBits(0xffc00001)];
 const floatBits=[];for(const x of floats){const got=f.floated(x);assert(Object.is(got,x)||(Number.isNaN(got)&&Number.isNaN(x)));const u=f.converted(x);if(Number.isNaN(x)){assert.equal(u&0x7f800000,0x7f800000);assert.notEqual(u&0x007fffff,0);}else assert.equal(u,bitsOf(x));const rt=f.frombits(bitsOf(x));assert(Object.is(rt,x)||(Number.isNaN(rt)&&Number.isNaN(x)));floatBits.push([bitsOf(got),f.converted(x),bitsOf(rt)]);count+=3;}
 assert.equal(f.checksum(),127);return {count,floatBits};}
try{
 pin(import.meta.filename);pin(process.execPath);pin(new URL('../../../development/workflow.mjs',import.meta.url));const codes={},modules={};
 for(const [role,file]of [['baseline',baselineArg],['candidate',candidateArg],['typescript',typescriptArg]]){codes[role]=await read(path.resolve(file),role);modules[role]=await import(pathToFileURL(report.roles[role].module.file));const observation=observe(modules[role]);report.observations.push({role,...observation});}
 assert.deepEqual(report.observations[1].floatBits,report.observations[0].floatBits);assert.deepEqual(report.observations[1].floatBits,report.observations[2].floatBits);
 const bf=functions(codes.baseline),cf=functions(codes.candidate);assert(!codes.baseline.includes('/*JD_SCALAR_WORD*/'));
 for(const fn of ['residual','prefix','high']){const body=cf.get(name(fn));assert(body?.includes('/*JD_SCALAR_WORD*/'),fn+' activated');assert(!body.includes('u32_to_word(')&&!body.includes('word_to_u32('),fn+' avoids Word reconstruction');report.syntax[fn]={baselineBytes:Buffer.byteLength(bf.get(name(fn))),candidateBytes:Buffer.byteLength(body),scalarSites:body.split('/*JD_SCALAR_WORD*/').length-1};}
 for(const fn of ['aliases','touch','swapbits','mixed','floated','converted','frombits']){assert(bf.has(name(fn))&&cf.has(name(fn)),fn+' declarations present');assert.equal(cf.get(name(fn)),bf.get(name(fn)),fn+' refused/unchanged');}
 const derived=codes.candidate.replaceAll('/*JD_SCALAR_WORD*/','/*JD_SCALAR_WORD*/++$scalarEntries,')+'\nlet $scalarEntries=0;export const scalarEntries=()=>$scalarEntries;\n';parse(derived);
 const file=path.join(out,'candidate-counter.mjs');fs.writeFileSync(file,derived,{flag:'wx'});const derivative=pin(file),m=await import(pathToFileURL(file));assert.equal(m.scalarEntries(),0);assert.equal(m.default.prefix(9),10);assert.equal(m.default.residual(100),117);assert.equal(m.default.high(0),0x7fffffff);assert.equal(m.scalarEntries(),3);
 report.activation={derivative,original:report.roles.candidate.module,entries:3,scope:'Separate diagnostic derivative, no timing claim.'};
 for(const directory of checkedDirectories)await verifyAttempt(directory);for(const r of report.inputs)assert.equal(sha(r.file),r.sha256);report.complete=report.pass=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,observations:report.observations.map(({role,count})=>({role,count})),error:report.error?.message}));}
