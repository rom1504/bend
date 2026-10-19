// Diagnostic transport for the checked Bend entry. No host semantic lowering.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const args = process.argv.slice(2);
const [apiArg, inputArg, outArg, mode = 'cache', pipeline = 'static'] = args;
if (args.length < 3 || args.length > 5 || !['cache', 'live'].includes(mode) || !['generic','static'].includes(pipeline))
  throw Error('Usage: diagnose.mjs CHECKED_API INPUT FRESH_OUT [cache|live] [generic|static]');
const root = path.resolve(import.meta.dirname, '../../../../..');
const apiFile = path.resolve(apiArg), source = path.resolve(inputArg), out = path.resolve(outArg);
if (!out.startsWith(root + '/selfhost/build/phase111/') || fs.existsSync(out))
  throw Error('Fresh Phase111 output required');

// Streaming pins avoid a second complete QBE/source buffer during accounting.
function pin(file) {
  file = path.resolve(file);
  const fd = fs.openSync(file, 'r'), hash = crypto.createHash('sha256');
  const buffer = Buffer.allocUnsafe(1024 * 1024);
  let bytes = 0;
  try {
    for (;;) {
      const count = fs.readSync(fd, buffer, 0, buffer.length, null);
      if (!count) break;
      bytes += count;
      hash.update(buffer.subarray(0, count));
    }
  } finally { fs.closeSync(fd); }
  return {file, bytes, sha256: hash.digest('hex')};
}
function verify(row) {
  const actual = pin(row.file);
  if (actual.bytes !== row.bytes || actual.sha256 !== row.sha256)
    throw Error('Changed input ' + row.file);
}
function memory() {
  const result = {};
  try {
    const status = fs.readFileSync('/proc/self/status', 'utf8');
    for (const [field, label] of [['VmRSS', 'rssBytes'], ['VmHWM', 'processLifetimeMaxRssBytes']]) {
      const match = status.match(new RegExp('^' + field + ':\\s+(\\d+) kB$', 'm'));
      if (match) result[label] = Number(match[1]) * 1024;
    }
  } catch {}
  try { result.heapUsedBytes = process.memoryUsage().heapUsed; } catch {}
  return result;
}
function tagged(value, tag, label) {
  if (value?.$ !== tag) throw Error('Unexpected ' + label + ' tag: ' + String(value?.$));
  return value;
}
function errorText(value, label) {
  if (typeof value !== 'string') throw Error('Non-string ' + label + ' diagnostic');
  return value;
}
function listCount(list, label, visit = () => {}) {
  let count = 0, cursor = list;
  while (cursor?.$ === 'Con') {
    visit(cursor.head);
    count++;
    cursor = cursor.tail;
  }
  if (cursor?.$ !== 'Nil') throw Error('Invalid ' + label + ' list tail');
  return count;
}
function u32(value, label) {
  if (!Number.isInteger(value) || value < 0 || value > 0xffffffff)
    throw Error('Invalid U32 diagnostic field ' + label);
  return value;
}
function programCounts(program) {
  tagged(program, 'P111Program', 'program');
  const counts = {segments: 0, maxArity: 0, maxIncoming: 0, maxResult: 0,
    constructors: 0, maxConstructorArity: 0};
  counts.segments = listCount(program.segments, 'segments', segment => {
    tagged(segment, 'N111Segment', 'segment');
    for (const [field, key] of [['arity', 'maxArity'], ['incoming', 'maxIncoming'], ['result', 'maxResult']]) {
      const value = u32(segment[field], field);
      if (value > counts[key]) { counts[key] = value; counts[key + 'Segment'] = segment.name; }
    }
  });
  counts.constructors = listCount(program.constructors, 'constructors', constructor => {
    tagged(constructor, 'N_Constructor', 'constructor');
    const arity = u32(constructor.arity, 'constructor arity');
    if (arity > counts.maxConstructorArity) {
      counts.maxConstructorArity = arity;
      counts.maxConstructorArityName = constructor.name;
    }
  });
  counts.showWords = listCount(program.show, 'show words');
  counts.showNames = listCount(program.show_names, 'show names');
  counts.effects = listCount(program.effects, 'effects');
  return counts;
}

const requiredExports = ['p88_cache_prepare', 'p86_prepare', 'p86_plan',
  'p111_runtime_admission', 'p112c_index','p112c_plan_index','p112c_plan','p112c_candidate','p112c_frame','p112c_try','p112f_index','p112f_cont','p112f_clean','p112f_safe','p112f_size','p112t_prelude','p112r_head_buffer','p112r_target','p112r_tail','p112r_result','p112r_scalar','p112r_failure','p112r_buffer', ...(pipeline === 'static' ? ['p112s_lower_request','p112s_verify','p112s_chunks'] : ['p111_lower_request','p111_verify_program','p111q_chunks'])];
const apiRecordFile = path.join(path.dirname(apiFile), 'report.json');
const apiRecord = JSON.parse(fs.readFileSync(apiRecordFile));
if (!apiRecord.complete || !apiRecord.checked ||
    !requiredExports.every(name => apiRecord.exports?.includes(name)))
  throw Error('Complete checked API with all staged exports required');
verify(apiRecord.api);
if (path.resolve(apiRecord.api.file) !== apiFile) throw Error('API differs from checked receipt');
const selectionFile = path.join(root, 'selfhost/tools/native/selection.json');
const selection = JSON.parse(fs.readFileSync(selectionFile));
verify(selection.admission);
const admission = JSON.parse(fs.readFileSync(selection.admission.file));
if (!admission.complete || !admission.qualified) throw Error('Native seed admission incomplete');
const {base, cache} = admission.assets;
verify(base);
if (mode === 'cache') verify(cache.carrier);
const inputs = [pin(import.meta.filename), pin(apiFile), pin(apiRecordFile), pin(source),
  pin(selectionFile), selection.admission, base, ...(mode === 'cache' ? [cache.carrier] : []),
  pin(process.execPath)];
fs.mkdirSync(out, {recursive: true});
fs.copyFileSync(import.meta.filename, path.join(out, 'diagnostic-method.mjs'));
const report = {kind: 'phase112-checked-region-admission-diagnosis', complete: false, mode, pipeline,
  inputs, requiredExports, startedUtc: new Date().toISOString(), stages: [], sourceChecked: false,
  runtimeAdmitted: false, irVerified: false, compilerHost: 'checked Bend source API acquired by pinned TypeScript',
  composition: 'prepare -> p86_plan -> runtime admission -> lower -> verify -> actual region registry/transform/planner -> read-only predicate diagnosis',
  timingScope: 'compilerSeconds sums only marked Bend API stages. List counting, import/read, output hashing and write are separate. totalSeconds starts after preflight authentication; outer guard includes process startup and preflight.',
  memoryScope: 'Host process RSS snapshots and Linux lifetime high-water RSS; not isolated per-stage peaks or full process-tree RSS. No forced GC.',
  scope: 'Read-only host walks report the actual typed IR and checked Bend planner predicates. No host semantic lowering, native execution, optimization change or self-host qualification. Final-ready hypothetical plans are distinguished from frozen admitted plans.'};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
const totalStart = performance.now();
let activeStage;
async function stage(name, action, compiler = false) {
  activeStage = name;
  const row = {name, status: 'running', compiler, startedUtc: new Date().toISOString(), before: memory()};
  report.stages.push(row);
  save();
  console.log(JSON.stringify({stage: name, status: 'running', memory: row.before}));
  const start = performance.now();
  try {
    const result = await action();
    row.status = 'complete';
    return result;
  } catch (error) {
    row.status = 'failed';
    row.error = String(error);
    throw error;
  } finally {
    row.seconds = (performance.now() - start) / 1000;
    row.after = memory();
    save();
    console.log(JSON.stringify({stage: name, status: row.status, seconds: row.seconds, memory: row.after}));
  }
}
function reject(diagnostic, prefix = '') {
  report.diagnostic = prefix + errorText(diagnostic, activeStage);
  throw Error(report.diagnostic);
}

save();
try {
  const api = await stage('api-import', async () => (await import(pathToFileURL(apiFile))).default);
  if (!requiredExports.every(name => typeof api[name] === 'function'))
    throw Error('Checked API does not expose required functions');
  let sourceText, baseText, carrierText;
  await stage('input-read', () => {
    sourceText = fs.readFileSync(source, 'utf8');
    baseText = fs.readFileSync(base.file, 'utf8');
    carrierText = mode === 'cache' ? fs.readFileSync(cache.carrier.file, 'utf8') : '';
  });
  let prepared = await stage('preparation', () => {
    const result = mode === 'cache'
      ? api.p88_cache_prepare(base.file, baseText, carrierText, cache.stamp)
      : api.p86_prepare(base.file, baseText);
    if (result?.$ === 'P86PreparationError') reject(result.error);
    return tagged(result, 'P86PreparationReady', 'preparation');
  }, true);
  baseText = carrierText = null;
  let plan = await stage('frontend', () => {
    const result = api.p86_plan(prepared.seed, source, sourceText);
    if (result?.$ === 'P86PlanError') reject(result.error);
    tagged(result, 'P86PlanReady', 'frontend plan');
    tagged(result.request, 'NR_Request', 'checked request');
    report.sourceChecked = true;
    report.verdict = errorText(result.verdict, 'frontend verdict');
    return result;
  }, true);
  prepared = sourceText = null;
  await stage('frontend-counts', () => {
    report.requestCounts = {};
    for (const field of ['source', 'book', 'names', 'paths', 'scope'])
      report.requestCounts[field] = listCount(plan.request[field], 'request ' + field);
  });
  await stage('runtime-admission', () => {
    const error = errorText(api.p111_runtime_admission(plan.request), 'runtime admission');
    if (error) reject(error, 'compile: ');
    report.runtimeAdmitted = true;
  }, true);
  let program = await stage('lowering', () => {
    const result = tagged(pipeline === 'static' ? api.p112s_lower_request(plan.request) : api.p111_lower_request(plan.request), pipeline === 'static' ? 'P112SResult' : 'P111Result', 'lowering result');
    const error = errorText(result.error, 'lowering');
    if (error) reject(error, 'native lowering: ');
    return pipeline === 'static' ? tagged(result.bundle,'P112StaticProgram','static program') : tagged(result.program, 'P111Program', 'lowered program');
  }, true);
  plan = null;
  await stage('program-counts', () => { report.counts = programCounts(pipeline === 'static' ? program.program : program); if(pipeline==='static')report.counts.staticNodes=listCount(program.nodes,'static nodes'); });
  await stage('ir-verification', () => {
    const error = errorText((pipeline === 'static' ? api.p112s_verify(program) : api.p111_verify_program(program)), 'IR verification');
    if (error) reject(error, 'structured IR: ');
    report.irVerified = true;
  }, true);
  const actual = pipeline === 'static' ? program.program : program;
  const unlist = xs => { const a=[]; let x=xs; while(x?.$==='Con'){a.push(x.head);x=x.tail;} if(x?.$!=='Nil')throw Error('Malformed diagnostic list');return a; };
  const nil = {$:'Nil'};
  const truth = x => { if(x===true||x?.$==='True')return true;if(x===false||x?.$==='False')return false;throw Error('Unexpected Bool'); };
  const segments=unlist(actual.segments), byName=new Map(segments.map(s=>[s.name,s]));
  const originalIndex=await stage('original-continuation-index',()=>api.p112f_index(actual.segments),true);
  const registry=await stage('actual-region-registry',()=>api.p112c_index(actual.segments),true);
  const frozen=unlist(registry.entries), ready=new Map(frozen.map(e=>[e.segment.name,e]));
  report.registry={workers:registry.workers,fusions:registry.fusions,rankCounts:{}};
  for(const e of frozen)report.registry.rankCounts[e.rank]=(report.registry.rankCounts[e.rank]||0)+1;
  const value=v=>v?.$==='N111Local'?{kind:v.$,name:v.name}:v;
  function summary(s){
    const r={kind:s.$}; for(const k of ['name','symbol','op','offset','bytes','align'])if(s[k]!==undefined)r[k]=s[k];
    if(s.typ)r.type=s.typ.$;
    for(const k of ['value','base','left','right','condition'])if(s[k])r[k]=value(s[k]);
    if(s.args)r.args=unlist(s.args).map(a=>({type:a.typ.$,value:value(a.value)}));
    return r;
  }
  function statements(body,out=[]){for(const s of unlist(body)){out.push(s);if(s.$==='N111If'){statements(s.yes,out);statements(s.no,out);}}return out;}
  function edges(body){const out=[];for(const s of statements(body))if(s.$==='N111Call')for(const a of unlist(s.args))if(a.value?.$==='N111FuncId')out.push({kind:s.symbol,target:a.value.name});return out;}
  function refusals(body,owner,arity,sites,path,out){
    if(out.length>=16)return;
    if(truth(api.p112r_failure(body,registry.symbols,sites)))return;
    let cursor=body,i=0;
    while(cursor.$==='Con'&&out.length<16){
      const buffer=api.p112r_head_buffer(cursor),validBuffer=truth(api.p112r_buffer(buffer,sites));
      if(validBuffer&&truth(api.p112r_tail(cursor,owner,arity,0,buffer)))return;
      if(truth(api.p112r_result(cursor,sites)))return;
      const target=api.p112r_target(cursor,sites),entry=ready.get(target);
      if(entry&&target!==owner&&validBuffer&&truth(api.p112r_tail(cursor,target,entry.segment.arity,0,buffer)))return;
      const stmt=cursor.head,at=path+'/'+i;
      if(stmt.$==='N111If'){
        refusals(stmt.yes,owner,arity,sites,at+'/yes',out);
        refusals(stmt.no,owner,arity,sites,at+'/no',out);
      }else if(!truth(api.p112r_scalar(stmt,registry.symbols,sites))){
        out.push({path:at,reason:'p112r_scalar refused after exact failure/self-tail/result/prior-ready-tail checks',statement:summary(stmt),terminalTarget:target||null,targetReady:!!entry,knownBuffer:validBuffer});return;
      }
      cursor=cursor.tail;i++;
    }
  }
  function frames(body,sites,path,out){
    const nodes=[],cursors=[];let c=body;
    while(c.$==='Con'){nodes.push(c.head);cursors.push(c);c=c.tail;}
    for(let i=0;i<nodes.length;i++){
      const s=nodes[i],at=path+'/'+i;
      if(s.$==='N111If'){frames(s.yes,sites,at+'/yes',out);frames(s.no,sites,at+'/no',out);continue;}
      if(s.$!=='N111Call'||s.symbol!=='p111_rt_frame')continue;
      const args=unlist(s.args),captures=args[3]?.value?.lo,continuation=args[1]?.value?.name;
      const row={path:at,continuation,captures,statement:summary(s)};out.push(row);
      const start=Number.isInteger(captures)?i-captures:-1;
      if(start<0){row.reason='capture prefix shorter than frame count';continue;}
      const suffix=cursors[start],buffer=api.p112r_head_buffer(suffix);
      row.buffer=buffer;row.knownBuffer=truth(api.p112r_buffer(buffer,sites));
      const frame=api.p112c_frame(suffix,0,nil,buffer);
      if(frame.$!=='Some'){row.reason='p112c_frame refused exact capture stores/frame';continue;}
      let tail=frame.value.tail;
      if(typeof api.p112g_split==='function'){
        const split=api.p112g_split(tail,0,nil);
        if(split.$!=='Some'){row.reason='p112g_split refused pure-gap budget';continue;}
        row.gapStatements=unlist(split.value.gap).map(summary);tail=split.value.tail;
      }
      row.firstPostGap=tail.$==='Con'?summary(tail.head):null;
      const target=api.p112r_target(tail,sites),entry=ready.get(target);
      row.target=target||null;row.targetReady=!!entry;row.targetRank=entry?.rank;
      if(!target){row.reason='p112r_target found no exact stores-plus-terminal-jump target after frame/gap';continue;}
      if(!entry){row.reason='target absent from final six-rank private registry';continue;}
      row.tailExact=truth(api.p112r_tail(tail,target,entry.segment.arity,0,buffer));
      if(!row.tailExact){row.reason='p112r_tail refused argument stores/count/buffer/terminal jump';continue;}
      const cont=byName.get(continuation);
      if(!cont){row.reason='original continuation not found';continue;}
      row.continuationMetadata={arity:cont.arity,result:cont.result,incoming:cont.incoming,flags:cont.flags,clean:truth(api.p112f_clean(cont.body))};
      const accepted=api.p112f_cont(cont,captures);
      row.continuationAccepted=accepted.$==='Some';
      if(accepted.$!=='Some'){
        let rest=cont.body;const skip=1+(captures?1:0)+captures+1;
        for(let n=0;n<skip&&rest.$==='Con';n++)rest=rest.tail;
        row.expectedPreludeLength=skip;row.positionalRemainderSize=api.p112f_size(rest);row.positionalRemainderSafe=truth(api.p112f_safe(rest));
        row.reason='p112f_cont refused original continuation metadata/exact prelude/safety/128-statement bound';continue;
      }
      row.remainingBudget=8-sites;
      row.fullAttemptAccepted=api.p112c_try(suffix,originalIndex,registry.ready,sites).$==='Some';
      row.reason=sites>=8?'eight-site budget exhausted':row.fullAttemptAccepted?'eligible in a further final-ready probe; not claimed admitted':'full frame attempt refused despite component facts';
    }
  }
  await stage('read-only-admission-diagnosis',()=>{
    const roots=['$direct.sx','$direct.sy','$direct.sz','$direct.sr','$direct.isect.t','$direct.isect.go2','$direct.isect.go','$direct.isect5','$direct.nearest','$direct.nearest.t'];
    const queue=[...roots],seen=new Set(),rows=[];
    while(queue.length&&rows.length<96){
      const name=queue.shift();if(seen.has(name))continue;seen.add(name);
      const segment=byName.get(name);if(!segment){rows.push({name,missing:true});continue;}
      const entry=ready.get(name),deps=edges(segment.body);
      const row={name,metadata:{arity:segment.arity,result:segment.result,incoming:segment.incoming,flags:segment.flags},candidate:truth(api.p112c_candidate(segment)),admitted:!!entry,firstRank:entry?.rank,frozenSites:entry?.sites,dependencies:deps};
      const fusion=api.p112c_plan_index(segment,originalIndex,registry.ready);
      const transformed={...segment,body:fusion.body};
      const probe=api.p112c_plan(transformed,registry.ready,registry.symbols,fusion.count);
      row.finalReadyProbe={scope:'Hypothetical plan against final ready set, not the first frozen admission plan',sites:fusion.count,next:fusion.next,valid:truth(probe.valid),calls:probe.calls,refusals:[],remainingFrames:[]};
      const prelude=api.p112t_prelude(fusion.body,segment.arity);
      row.finalReadyProbe.preludeValid=truth(prelude.valid);
      row.candidateRefusals=[];
      if(segment.incoming!==0)row.candidateRefusals.push('incoming must equal0');
      if(segment.flags!==0)row.candidateRefusals.push('flags must equal0');
      if(segment.result!==1)row.candidateRefusals.push('result must equal1');
      if(segment.arity>32)row.candidateRefusals.push('worker arity exceeds32');
      if(!truth(api.p112f_clean(segment.body)))row.candidateRefusals.push('original p112f_clean hygiene refused');
      if(row.candidate&&!truth(prelude.valid))row.finalReadyProbe.refusals.push({reason:'p112t_prelude refused exact scratch allocation/register-parameter prelude'});
      if(truth(prelude.valid)&&!truth(probe.valid))refusals(prelude.body,name,segment.arity,fusion.count,'body',row.finalReadyProbe.refusals);
      frames(fusion.body,fusion.count,'body',row.finalReadyProbe.remainingFrames);
      if(!entry&&row.candidate&&truth(probe.valid))row.rankLimitSignal='Would admit using final ready set; another rank may be necessary, not automatically authorized';
      rows.push(row);
      if(!entry)for(const d of deps)if(!seen.has(d.target)&&!ready.has(d.target))queue.push(d.target);
    }
    report.diagnosis={roots,rows,truncatedQueue:[...new Set(queue)],nodeLimit:96,method:'Host walks only; all eligibility, fusion, private plan and refusal predicate answers come from the authenticated Bend API.'};
  });
  await stage('output-authentication',()=>{for(const row of inputs)verify(row);});
  program=null;
  report.complete = true;
} catch (error) {
  report.failedStage = activeStage;
  report.error = String(error);
  process.exitCode = 1;
} finally {
  report.compilerSeconds = report.stages.filter(row => row.compiler).reduce((sum, row) => sum + row.seconds, 0);
  report.writeSeconds = report.stages.find(row => row.name === 'write')?.seconds ?? 0;
  report.totalSeconds = (performance.now() - totalStart) / 1000;
  report.finishedUtc = new Date().toISOString();
  report.memory = memory();
  save();
  console.log(JSON.stringify({complete: report.complete, failedStage: report.failedStage,
    compilerSeconds: report.compilerSeconds, writeSeconds: report.writeSeconds,
    totalSeconds: report.totalSeconds, counts: report.counts, registry: report.registry, diagnosed: report.diagnosis?.rows?.length}));
}
