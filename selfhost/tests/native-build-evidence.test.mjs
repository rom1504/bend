import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {verifyNativeBuildEvidence,nativeBuildTiming} from '../tools/performance/rapid/native-build-evidence.mjs';

const sha=value=>createHash('sha256').update(value).digest('hex');
function fixture(t,{cacheHit=false,legacy=false}={}) {
  const dir=fs.mkdtempSync(path.join(os.tmpdir(),'bend-native-evidence-'));
  t.after(()=>fs.rmSync(dir,{recursive:true,force:true}));
  const write=(name,bytes)=>{const file=path.join(dir,name);fs.writeFileSync(file,bytes);return {file,sha256:sha(bytes)};};
  const source=write('compiler.bend','def answer(): 42\n'),javascript=write('program.cjs','module.exports=42;\n'),c=write('program.c','int main(){return 0;}\n'),binary=write('program','fixture executable bytes');
  const checked={complete:true,source:source.file,sourceSha256:source.sha256,javascript,c,phases:[{milliseconds:5},{milliseconds:7}]};
  const exposure={sourceSha256:source.sha256,checkedProgramSha256:javascript.sha256};
  const identity={version:2,sourceSha256:c.sha256,preprocessedSha256:sha('preprocessed'),optimization:'O1',plan:{args:['-O1',c.file,'-o','$OUTPUT']},compiler:{command:'/fixture/clang',version:'clang version 16',executableSha256:sha('clang')},toolSha256:sha('native-build'),cacheToolSha256:sha('cache-tool'),environment:{CPATH:null},platform:process.platform,arch:process.arch};
  const key=sha(JSON.stringify(identity));
  const cBuild=legacy
    ?{kind:'native-c-only-build',complete:true,exitCode:0,sourceSha256:c.sha256,binarySha256:binary.sha256,milliseconds:20,optimization:'O1'}
    :{kind:'native-content-addressed-build',version:2,complete:true,cacheHit,inputSha256:c.sha256,binarySha256:binary.sha256,key,record:{key,identity,binarySha256:binary.sha256},preprocessedSha256:identity.preprocessedSha256,optimization:identity.optimization,cachePlan:identity.plan,compiler:identity.compiler,toolSha256:identity.toolSha256,cacheToolSha256:identity.cacheToolSha256,environment:identity.environment,preprocessMs:3,...(cacheHit?{}:{compileMs:20})};
  return {checked,cBuild,exposure,binary:binary.file};
}

for(const [name,options] of [['legacy',{legacy:true}],['cache miss',{}],['cache hit',{cacheHit:true}]]) {
  test('accepts matched complete '+name+' evidence',t=>{
    const sample=fixture(t,options);
    assert.equal(verifyNativeBuildEvidence(sample).binarySha256,sample.cBuild.binarySha256);
  });
}

for(const [name,change] of [
  ['changed actual C',s=>fs.appendFileSync(s.checked.c.file,'changed')],
  ['wrong C report',s=>{s.cBuild.inputSha256=sha('wrong C');}],
  ['changed binary',s=>fs.appendFileSync(s.binary,'changed')],
  ['wrong cache binary digest',s=>{s.cBuild.record.binarySha256=sha('wrong binary');}],
  ['incomplete C build',s=>{s.cBuild.complete=false;}],
  ['incomplete checked build',s=>{s.checked.complete=false;}],
  ['corrupt cache key',s=>{s.cBuild.key=sha('corrupt');}],
  ['corrupt record key',s=>{s.cBuild.record.key=sha('corrupt');}],
  ['changed identity under retained key',s=>{s.cBuild.record.identity.sourceSha256=sha('wrong C');}],
  ['valid key for unrelated C',s=>{s.cBuild.record.identity.sourceSha256=sha('wrong C');s.cBuild.record.key=s.cBuild.key=sha(JSON.stringify(s.cBuild.record.identity));}],
  ['inconsistent optimization claim',s=>{s.cBuild.optimization='O3';}],
  ['inconsistent compiler claim',s=>{s.cBuild.compiler={...s.cBuild.compiler,version:'another compiler'};}],
  ['unsupported cache schema',s=>{s.cBuild.version=3;}],
  ['wrong exposed JS digest',s=>{s.exposure.checkedProgramSha256=sha('wrong JS');}],
  ['changed checked source',s=>fs.appendFileSync(s.checked.source,'changed')],
  ['changed checked JS',s=>fs.appendFileSync(s.checked.javascript.file,'changed')]
]) {
  test('rejects '+name,t=>assert.throws(()=>{const sample=fixture(t);change(sample);verifyNativeBuildEvidence(sample);}));
}

test('legacy rejection still requires successful exit and matching C',t=>{
  const sample=fixture(t,{legacy:true});
  sample.cBuild.exitCode=1;assert.throws(()=>verifyNativeBuildEvidence(sample));
  sample.cBuild.exitCode=0;sample.cBuild.sourceSha256=sha('wrong C');assert.throws(()=>verifyNativeBuildEvidence(sample));
});

test('cache timing distinguishes observed preprocessing from unknown original compilation',t=>{
  const hit=fixture(t,{cacheHit:true}),miss=fixture(t),legacy=fixture(t,{legacy:true});
  assert.deepEqual(Object.fromEntries(Object.entries(nativeBuildTiming(hit.checked,hit.cBuild)).filter(([key])=>key!=='note')),
    {optimization:'O1',cacheHit:true,checkedEmissionPhaseMs:12,cCompileMs:null,cPreprocessMs:3,phaseWorkMs:null});
  assert.equal(nativeBuildTiming(miss.checked,miss.cBuild).phaseWorkMs,35);
  assert.equal(nativeBuildTiming(legacy.checked,legacy.cBuild).phaseWorkMs,32);
  miss.cBuild.compileMs=undefined;assert.equal(nativeBuildTiming(miss.checked,miss.cBuild).phaseWorkMs,null);
});
