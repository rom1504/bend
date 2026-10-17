// Run with pinned Bun under the external resource guard. Six matched sources;
// compare complete C and compiler verdicts, not timing envelopes or exit alone.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'../../../..');
const [buildArg,outArg]=process.argv.slice(2),build=path.resolve(buildArg),out=path.resolve(outArg);
assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const pin=p=>{p=fs.realpathSync(p);const b=fs.readFileSync(p);return {file:p,bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};};
const verify=p=>assert.deepEqual(pin(p.file),p);
const selected=read(root+'/selfhost/tools/native/selection.json');verify(selected.admission);
const baseline=read(selected.admission.file),a=baseline.assets,native=read(build+'/native.json');
assert(baseline.qualified&&native.complete);verify(native.binary);verify(baseline.stages.b2.binary);
for(const p of [a.base,...a.parts,...a.effects,a.cache.carrier])verify(p);
const sources=[
  'selfhost/tools/performance/phase77/fixtures/small.bend',
  'selfhost/tools/performance/phase77/fixtures/functions65.bend',
  'selfhost/tools/performance/programs/fixtures/local-fold.bend',
  'selfhost/tools/performance/programs/fixtures/lexer.bend',
  'selfhost/tools/performance/phase99/scalar-controls/fixtures01/io-char-array.bend',
  'selfhost/.bootstrap/upstream-phase66/tests/io/file_roundtrip.bend',
].map(p=>pin(root+'/'+p));
const report={kind:'phase103-native-cli-equivalence',version:1,complete:false,passed:false,
  method:pin(import.meta.filename),candidate:{binary:native.binary,source:native.source},
  baseline:{admission:selected.admission,binary:baseline.stages.b2.binary},rows:[],
  scope:'One matched invocation per source. Complete emitted-C and verdict equality; process times are not a balanced performance benchmark.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
function run(label,args){
  const started=performance.now(),r=spawnSync(args[0],args.slice(1),{cwd:root,timeout:30000,maxBuffer:4*1024**2});
  const row={command:args,status:r.status,signal:r.signal,error:r.error?.message??null,wallSeconds:(performance.now()-started)/1000};
  for(const key of ['stdout','stderr']){const file=out+'/'+label+'.'+key;fs.writeFileSync(file,r[key]??Buffer.alloc(0));row[key]=pin(file);}
  assert(!r.error&&!r.signal&&r.status===0,JSON.stringify(row));return row;
}
try{
  for(let i=0;i<sources.length;i++){
    const source=sources[i],prefix=out+'/reference-'+i,dest=out+'/candidate-'+i+'.c';
    const oldArgs=[baseline.stages.b2.binary.file,'--threads','1','--gpu','off','--',a.argvSentinel,source.file,a.base.file,a.runtime.file,a.effectsDir,prefix,'1',a.cache.carrier.file,a.cache.stamp];
    const oldProcess=run('reference-'+i,oldArgs),newProcess=run('candidate-'+i,[native.binary.file,source.file,'-o',dest]);
    const reference=pin(prefix+'.1.c'),candidate=pin(dest);
    const oldVerdict=fs.readFileSync(oldProcess.stderr.file,'utf8').split('\n').filter(l=>!(/^(base_prepare_ms|runtime_prepare_ms)=/.test(l)||/^request=1 request_ms=\d+ consumed_chars=\d+$/.test(l))).join('\n');
    const newVerdict=fs.readFileSync(newProcess.stderr.file,'utf8');
    const row={source,reference,candidate,cEqual:reference.sha256===candidate.sha256&&reference.bytes===candidate.bytes,
      diagnosticsEqual:oldVerdict===newVerdict,oldProcess,newProcess};
    report.rows.push(row);save();assert(row.cEqual&&row.diagnosticsEqual,source.file);
    verify(source);
  }
  verify(native.binary);verify(baseline.stages.b2.binary);
  report.complete=true;report.passed=true;
}catch(e){report.error=e.stack??String(e);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,cases:report.rows.length,report:out+'/report.json'}));
