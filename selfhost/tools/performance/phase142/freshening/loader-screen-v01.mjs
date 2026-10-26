// Differential test of the actual completed loader. Never parse/freshen in host code.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import assert from 'node:assert/strict';import{pathToFileURL}from'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..'),[apiArg,outArg,guardArg]=process.argv.slice(2);
assert(apiArg&&outArg);const started=performance.now(),out=path.resolve(outArg),budgetSeconds=30;
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase142/'));
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=f=>JSON.parse(fs.readFileSync(f)),verify=p=>assert.deepEqual(pin(p.file),p),elapsed=()=>(performance.now()-started)/1000;
const rec=read(apiArg),selectionPath=ROOT+'/implementation/phase137/candidate.json',selection=read(selectionPath),carrier=read(selection.preferredCarrierReceipt.file);
assert(rec.complete&&rec.checked);rec.inputs.forEach(verify);verify(rec.api);
const required=['p88_cache_prepare','f_source_end','p142fl_load','p140pl_load'];for(const key of required)assert(rec.exports.includes(key),'Missing checked export: '+key);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);verify(base);verify(selection.preferredCarrier);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase142-freshening-loader-differential-v1',complete:false,budgetSeconds,inputs:[pin(import.meta.filename),pin(process.execPath),pin(apiArg),rec.api,...rec.inputs,pin(selectionPath),pin(selection.preferredCarrierReceipt.file),base,selection.preferredCarrier],rows:[],
 guard:{receiptFile:guardArg?path.resolve(guardArg):null,validatedHere:false},scope:'Checked original p140pl_load versus checked p142fl_load on actual sources. Entire P140PLoadResult graphs, including completed/freshened books, errors, spans, IDs, parser cache and hit flag, compared. Graph-pair memoization prevents shared-graph explosion. This checks loader behavior, not compiler code generation or a formal theorem; session rollback is checked separately.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x};
const time=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
const arr=l=>{const xs=[];while(l.$==='Con'){assert(xs.length<100000);xs.push(l.head);l=l.tail;}tag(l,'Nil');return xs};
function exact(a,b){const todo=[[a,b]],seen=new WeakMap();let objects=0,scalars=0;while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y)){scalars++;continue;}if(!x||!y||typeof x!=='object'||typeof y!=='object'){assert.deepEqual(x,y);scalars++;continue;}let set=seen.get(x);if(set?.has(y))continue;if(!set){set=new WeakSet();seen.set(x,set);}set.add(y);objects++;const keys=Object.keys(x).sort();assert.deepEqual(keys,Object.keys(y).sort());for(const k of keys)todo.push([x[k],y[k]]);}return{objects,scalars};}
const errorOf=result=>result.$==='P140PLoadError'?result.error:tag(result,'P140PLoadReady').load.trace.result.error;
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 const seedTime=time(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selection.preferredCarrier.file,'utf8'),selection.preferredStamp),'P86PreparationReady').seed),seed=seedTime.value,origin=api.f_source_end(seed.source);report.baseSeedSeconds=seedTime.seconds;
 const empty=()=>({oldParser:{$:'None'},parser:{$:'None'},fresh:{$:'P142FFEmpty'}});
 const pair=(label,file,text,prior,{error=false,parserHit,freshHit}={})=>{
  assert(elapsed()<budgetSeconds,'Loader process budget');assert(text.includes('def work'));
  const hint=origin+text.indexOf('def work')+5,sourceFile=out+'/'+label+'.bend';fs.writeFileSync(sourceFile,text);report.inputs.push(pin(sourceFile));
  const old=time(()=>api.p140pl_load(seed,file,text,prior.oldParser,hint)),next=time(()=>tag(api.p142fl_load(seed,file,text,prior.parser,hint,prior.fresh),'P142FLResult'));
  const equality=time(()=>exact(old.value,next.value.loaded)),actualError=errorOf(old.value),stats=arr(next.value.stats);
  assert.equal(Boolean(actualError),error,label+': expected error state');
  if(parserHit!==undefined)assert.equal(next.value.loaded.hit,parserHit,label+': parser hit');
  if(freshHit!==undefined)assert.equal(stats[0]??0,Number(freshHit),label+': freshening hit');
  const state={oldParser:old.value.cache,parser:next.value.loaded.cache,fresh:next.value.cache};
  report.rows.push({label,logicalPath:file,source:pin(sourceFile),hint,utf16Units:text.length,utf8Bytes:Buffer.byteLength(text),originalSeconds:old.seconds,retainedSeconds:next.seconds,equalitySeconds:equality.seconds,completeProductExact:true,equality:equality.value,error:actualError,parserHit:next.value.loaded.hit??null,freshStats:stats,returnedFreshKind:next.value.cache.$});save();return{state,success:!actualError};
 };
 const pathA='/phase142/freshening/a/main.bend',pathB='/phase142/freshening/b/main.bend';
 const plain='import Base\ndef before(x: U32) -> U32:\n  x\ndef work(x: U32) -> U32:\n  U32.add(x, 1)\ndef main() -> U32:\n  work(2)\n';
 const initial=pair('plain-cold',pathA,plain,empty(),{freshHit:false}).state;
 pair('plain-same-path',pathA,plain,initial,{parserHit:true,freshHit:true});
 const late=plain.replace('U32.add(x, 1)','U32.add(x, 3)');
 pair('late-body-edit',pathA,late,initial,{parserHit:true,freshHit:true});
 const binders=plain.replace('def work(x: U32)','def work(x: U32, y: U32)').replace('U32.add(x, 1)','U32.add(x, y)').replace('work(2)','work(2, 4)');
 const bound=pair('suffix-binder-count-edit',pathA,binders,initial,{parserHit:true,freshHit:true}).state;
 pair('suffix-binder-count-revert',pathA,plain,bound,{parserHit:true,freshHit:true});
 const prefix=plain.replace('  x\ndef work','  U32.add(x, 0)\ndef work');
 pair('completed-prefix-edit',pathA,prefix,initial,{parserHit:false,freshHit:false});
 const invalid=plain.replace('U32.add(x, 1)','U32.add(x, 1');
 const failed=pair('invalid-suffix',pathA,invalid,initial,{error:true});
 pair('recovery-retained-success',pathA,late,initial,{parserHit:true,freshHit:true});
 // A caller that discards the invalid completion's cache still behaves safely;
 // the production session instead keeps its last successful whole capsule.
 pair('recovery-returned-failure-state',pathA,late,failed.state);
 const unicode=plain.replace('def before','def label() -> String:\n  "😀𝄞"\ndef before');
 const unicodeSeed=pair('nonbmp-cold',pathA,unicode,empty(),{freshHit:false}).state;
 pair('nonbmp-late-edit',pathA,unicode.replace('U32.add(x, 1)','U32.add(x, 6)'),unicodeSeed,{parserHit:true,freshHit:true});
 const foreign=plain.replace('def before','def foreign_step() -> IO(U32):\n  import "./foreign.js"\n  import "./foreign.c"\ndef before');
 const foreignSeed=pair('foreign-relative-cold',pathA,foreign,empty(),{freshHit:false}).state;
 pair('foreign-relative-same-path',pathA,foreign,foreignSeed,{parserHit:true,freshHit:true});
 pair('foreign-relative-directory-edit',pathB,foreign,foreignSeed,{freshHit:false});
 const absolute=foreign.replaceAll('./foreign.','/shared/foreign.');
 const absoluteSeed=pair('foreign-absolute-cold',pathA,absolute,empty(),{freshHit:false}).state;
 pair('foreign-absolute-directory-edit',pathB,absolute,absoluteSeed,{freshHit:true});
 pair('nonbase-import-refusal',pathA,plain.replace('import Base','import Base\nimport ./other.bend as Other'),initial,{error:true,freshHit:false});
 pair('nonbase-import-recovery',pathA,late,initial,{parserHit:true,freshHit:true});
 report.inputs.forEach(verify);assert(elapsed()<budgetSeconds,'Loader process budget exceeded');report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.processSeconds=elapsed();report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,processSeconds:report.processSeconds,error:report.error}));}
