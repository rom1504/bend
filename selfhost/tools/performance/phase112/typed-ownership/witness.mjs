// Root-run transport: both Bend lowerers consume the same actual checked request.
// Host code only authenticates inputs and counts already-verified IR statements.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [baselineArg, candidateArg, sourceArg, admissionArg, outArg, segmentName = '$direct.mit'] = process.argv.slice(2);
if (!outArg || process.argv.length > 8)
  throw Error('Usage: witness.mjs BASE_API CANDIDATE_API SOURCE TYPED_ADMISSION FRESH_OUT [SEGMENT]');
const root = path.resolve(import.meta.dirname, '../../../../..');
const out = path.resolve(outArg), source = path.resolve(sourceArg);
if (!out.startsWith(root + '/selfhost/build/phase112/') || fs.existsSync(out))
  throw Error('Fresh Phase112 output required');
function pin(file) {
  file = path.resolve(file);
  const data = fs.readFileSync(file);
  return {file, bytes:data.length, sha256:crypto.createHash('sha256').update(data).digest('hex')};
}
function verify(row) {
  const got = pin(row.file);
  if (got.bytes !== row.bytes || got.sha256 !== row.sha256) throw Error('Changed input: ' + row.file);
}
function record(file) { return JSON.parse(fs.readFileSync(file,'utf8')); }
function tag(value, name) {
  if (value?.$ !== name) throw Error('Expected ' + name + ', got ' + value?.$);
  return value;
}
function list(value) {
  const result=[];
  while(value?.$ === 'Con') { result.push(value.head); value=value.tail; }
  tag(value,'Nil');
  return result;
}
const required=['p88_cache_prepare','p86_plan','p111_runtime_admission','p112s_lower_request','p112s_verify'];
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(source)];
async function checkedApi(file) {
  file=path.resolve(file);
  const receipt=path.join(path.dirname(file),'report.json'), info=record(receipt);
  if (!info.complete || !info.checked || !required.every(name=>info.exports?.includes(name)))
    throw Error('Complete checked API and required exports needed');
  verify(info.api);
  if(path.resolve(info.api.file)!==file) throw Error('API receipt mismatch');
  inputs.push(pin(receipt),pin(file));
  const compilerSource=info.inputs?.find(row=>path.resolve(row.file)===path.resolve(info.command?.[2] ?? ''));
  if(!compilerSource || !compilerSource.file.endsWith('/compiler.bend'))
    throw Error('Checked API compiler source pin required');
  verify(compilerSource); inputs.push(compilerSource);
  const api=(await import(pathToFileURL(file))).default;
  if(!required.every(name=>typeof api[name]==='function')) throw Error('Missing API function');
  return {api,info,compilerSource};
}
const baseline=await checkedApi(baselineArg), candidate=await checkedApi(candidateArg);
const typed=record(admissionArg);
if(!typed.complete || typed.kind!=='phase112-typed-ownership-admission' || typed.immediate!==false)
  throw Error('Complete no-immediate typed admission required');
verify(typed.source);
if(candidate.compilerSource.sha256!==typed.source.sha256 || candidate.compilerSource.bytes!==typed.source.bytes)
  throw Error('Typed admission and candidate API source differ');
inputs.push(pin(admissionArg),typed.source);
const selectionFile=path.join(root,'selfhost/tools/native/selection.json');
const selection=record(selectionFile); verify(selection.admission);
const seedAdmission=record(selection.admission.file);
if(!seedAdmission.complete || !seedAdmission.qualified) throw Error('Qualified mature seed required');
const {base,cache}=seedAdmission.assets;
verify(base); verify(cache.carrier);
inputs.push(pin(selectionFile),selection.admission,base,cache.carrier);
const prepared=tag(baseline.api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),
  fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp),'P86PreparationReady');
const plan=tag(baseline.api.p86_plan(prepared.seed,source,fs.readFileSync(source,'utf8')),'P86PlanReady');
tag(plan.request,'NR_Request');

function counts(segment) {
  const result={name:segment.name,arity:segment.arity,incoming:segment.incoming,
    statements:0,frames:0,keeps:0,sinks:0,keepsAfterFrame:0,sinksAfterFrame:0,postFrameOwners:[]};
  const pending=[{body:segment.body,afterFrame:false}];
  while(pending.length) {
    let {body,afterFrame}=pending.pop();
    for(const statement of list(body)) {
      result.statements++;
      if(statement.$==='N111If') {
        pending.push({body:statement.yes,afterFrame},{body:statement.no,afterFrame});
      } else if(statement.$==='N111Call') {
        if(statement.symbol==='p111_rt_frame') { result.frames++; afterFrame=true; }
        for(const [symbol,key] of [['p111_rt_keep','keeps'],['p111_rt_sink','sinks']]) {
          if(statement.symbol!==symbol) continue;
          result[key]++;
          if(afterFrame) {
            result[key+'AfterFrame']++;
            result.postFrameOwners.push({symbol,name:statement.name,args:list(statement.args).map(arg=>arg.value)});
          }
        }
      }
    }
  }
  return result;
}
function lower(label,api) {
  const admitted=api.p111_runtime_admission(plan.request);
  if(admitted!=='') throw Error(label+' runtime admission: '+admitted);
  const lowered=tag(api.p112s_lower_request(plan.request),'P112SResult');
  if(lowered.error!=='') throw Error(label+' lowering: '+lowered.error);
  const verified=api.p112s_verify(lowered.bundle);
  if(verified!=='') throw Error(label+' IR verification: '+verified);
  const segments=list(tag(lowered.bundle,'P112StaticProgram').program.segments);
  const selected=segments.filter(segment=>segment.name===segmentName);
  if(selected.length!==1) throw Error(label+' requires one exact selected segment '+segmentName);
  const rows=segments.map(counts);
  const total={};
  for(const key of ['statements','frames','keeps','sinks','keepsAfterFrame','sinksAfterFrame'])
    total[key]=rows.reduce((sum,row)=>sum+row[key],0);
  return {selected:counts(selected[0]),total,segments:rows.length};
}
const before=lower('baseline',baseline.api), after=lower('candidate',candidate.api);
const witness=before.selected.keepsAfterFrame>after.selected.keepsAfterFrame;
for(const input of inputs) verify(input);
fs.mkdirSync(out,{recursive:true});
fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase112-typed-ownership-structural-witness',complete:true,
  sourceChecked:true,irVerified:true,sameCheckedRequest:true,segmentName,before,after,
  postFrameKeepReduction:witness,inputs,
  scope:'Counts on the original verified structured graph before worker planning. No host lowering, no native execution, and no claim that all continuations disappear.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
if(!witness) { process.exitCode=1; console.error('Expected post-frame keep reduction absent'); }
console.log(JSON.stringify({complete:true,postFrameKeepReduction:witness,before:before.selected,after:after.selected}));
