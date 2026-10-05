// Root-only authentic literal planning and emitted-expression bit controls.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [attemptArg,outArg]=process.argv.slice(2);assert(outArg,'private-float-ir-v1.mjs CHECKED_ATTEMPT NEW_OUT');
const root=fs.realpathSync(attemptArg),out=path.resolve(outArg);fs.mkdirSync(out);
const report={kind:'phase48-private-finite-f32-ir-controls',complete:false,pass:false,inputs:[],patterns:[],refusals:[],
 scope:'Actual checked literal constructor/planner/emitter, including source-unexpressible bit payloads. Independent DataView numeric oracle, shared-view bits and detached-write failure. Does not qualify source admission or public host guards; separate source controls cover those.'};
const hash=b=>createHash('sha256').update(b).digest('hex');
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,sha256:hash(b),bytes:b.length};};
function pin(file,want){const row=identity(file);if(want)assert.equal(row.sha256,want.sha256);report.inputs.push(row);return row;}
const patterns=[
 [0x00000000,true,'positive-zero'],[0x80000000,true,'negative-zero'],
 [0x00000001,true,'positive-min-subnormal'],[0x80000001,true,'negative-min-subnormal'],
 [0x007fffff,true,'positive-max-subnormal'],[0x807fffff,true,'negative-max-subnormal'],
 [0x00800000,true,'positive-min-normal'],[0x80800000,true,'negative-min-normal'],
 [0x3f7fffff,true,'below-one'],[0x3f800000,true,'one'],[0xbf800000,true,'negative-one'],
 [0x3f800001,true,'above-one'],[0x7f7fffff,true,'positive-max-finite'],[0xff7fffff,true,'negative-max-finite'],
 [0x7f800000,false,'positive-infinity'],[0xff800000,false,'negative-infinity'],
 [0x7f800001,false,'positive-signaling-NaN'],[0xff800001,false,'negative-signaling-NaN'],
 [0x7fc00000,false,'positive-quiet-NaN'],[0xffc00000,false,'negative-quiet-NaN'],
 [0x7fffffff,false,'positive-max-NaN-payload'],[0xffffffff,false,'negative-max-NaN-payload']];
const encode=value=>Number.isNaN(value)?'NaN':Object.is(value,-0)?'-0':value===Infinity?'+Infinity':value===-Infinity?'-Infinity':value;
try{
 pin(import.meta.filename);pin(process.execPath);
 const attemptFile=pin(path.join(root,'attempt.json')),attempt=JSON.parse(fs.readFileSync(attemptFile.file));
 assert(attempt.checked&&attempt.config.strictExact);
 for(const key of ['api','runtime','base','node'])pin(attempt[key].file,attempt[key]);
 assert.equal(identity(process.execPath).sha256,attempt.node.sha256);
 const gateFile=pin(path.join(root,'validation-001/report.json')),gate=JSON.parse(fs.readFileSync(gateFile.file));
 assert(gate.complete&&gate.pass&&gate.strictExact);assert.equal(gate.attempt.sha256,attemptFile.sha256);assert.equal(gate.api.sha256,attempt.api.sha256);
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
 new Function('module','exports',parserSource)(parser,parser.exports);
 const parse=text=>parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
 report.parser={version:parser.exports.version,sha256:hash(parserSource)};
 const original=fs.readFileSync(attempt.api.file,'utf8'),ast=parse(original);
 for(const name of ['$j_private_float_plan$','$j_private_float_finite$','$j_private_float_code$','$kl_make$','$kt$','$tg$','$nm$','$ix$','run_loop'])
  assert.equal(ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===name).length,1,name);
 assert(!original.includes('phase48FloatBits'));
 const extra=`
export const phase48FloatBits={
 literal:(kind,bits)=>run_loop($kl_make$(kind,bits,'')),
 reference:()=>run_loop($kt$('Ref','F32',0,0,{$:'Nil'})),
 plan:t=>run_loop($j_private_float_plan$(t)),finite:b=>run_loop($j_private_float_finite$(b)),
 code:b=>run_loop($j_private_float_code$(b)),
 shape:t=>[run_loop($tg$(t)),run_loop($nm$(t)),run_loop($ix$(t))]};
`;
 const derivative=original+extra;parse(derivative);const file=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(file,derivative,{flag:'wx'});pin(file);
 fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
 report.derivation={parent:identity(attempt.api.file),api:identity(file),change:'One appended diagnostic object; original API byte prefix retained.'};
 const api=(await import(pathToFileURL(file))).phase48FloatBits;
 for(const [bits,finite,label]of patterns){
  const literal=api.literal('F32',bits),before=structuredClone(literal),plan=api.plan(literal),code=api.code(bits);
  assert.deepEqual(literal,before,'Original literal changed');assert.equal(api.finite(bits),finite,label);
  if(finite){assert.deepEqual(api.shape(plan),['JF32','F32',bits]);assert(code.includes('/* private finite F32 */'));}
  else{assert.deepEqual(plan,literal,'Nonfinite literal must retain its representation');assert.equal(code,'bitsFloat('+bits+')');}
  parse('const value=('+code+');');
  const oracleView=new DataView(new ArrayBuffer(4));oracleView.setUint32(0,bits,true);const wanted=oracleView.getFloat32(0,true);
  const view=new DataView(new ArrayBuffer(4));view.setUint32(0,0x12345678,true);const reads=[];
  const bitsFloat=value=>{reads.push(value);view.setUint32(0,value,true);return view.getFloat32(0,true);};
  const evaluate=new Function('floatView','bitsFloat','return ('+code+');'),got=evaluate(view,bitsFloat);
  assert(Object.is(got,wanted),label+' numeric/signed-zero oracle');assert.equal(view.getUint32(0,true),bits,label+' retained exact view payload');
  assert.deepEqual(reads,finite?[]:[bits]);
  const detached=new DataView(new ArrayBuffer(4));structuredClone(detached.buffer,{transfer:[detached.buffer]});let error;
  try{evaluate(detached,value=>{detached.setUint32(0,value,true);return detached.getFloat32(0,true);});}catch(e){error=e;}
  assert(error instanceof TypeError,label+' retains detached-buffer write failure');
  report.patterns.push({bits,label,finite,shape:api.shape(plan),code,value:encode(got),retainedBits:view.getUint32(0,true),fallbackReads:reads,detachedError:error.name});
 }
 for(const kind of ['U32','Nat','String']){const term=api.literal(kind,7);assert.deepEqual(api.plan(term),term);report.refusals.push({kind,unchanged:true});}
 const reference=api.reference();assert.deepEqual(api.plan(reference),reference);report.refusals.push({kind:'nonliteral-F32-reference',unchanged:true});
 for(const row of report.inputs)assert.deepEqual(identity(row.file),row);
 report.complete=report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,patterns:report.patterns.length,refusals:report.refusals.length,error:report.error}));
