// Run with EQUALITY_TEST_API pointing at a genuine checked B1 API.
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {transformEquality,deriveEquality,verifyEqualityDerivation} from './equality.mjs';

const input=process.env.EQUALITY_TEST_API;
assert.ok(input,'Set EQUALITY_TEST_API to a genuine checked B1 API');
const source=fs.readFileSync(input,'utf8'),temp=fs.mkdtempSync(path.join(os.tmpdir(),'bend-equality-tests-'));
const candidate=transformEquality(source);
const expose='\nexport const equality=(a,b)=>run_loop($String$eq$(a,b));\nexport const staged=run_lib($String$eq$,2);\n';
const modules=[];
for(const [name,body]of [['original',source],['derived',candidate.source]]) {
  const file=path.join(temp,name+'.mjs');fs.writeFileSync(file,body+expose);modules.push(await import(pathToFileURL(file)));
}
const observe=(module,a,b)=>{try{return {ok:true,value:module.equality(a,b)}}catch(e){return {ok:false,error:typeof e==='string'?e:{name:e.name,message:e.message}}}};

test('reviewed body guards and exact single insertion',()=>{
  assert.equal(candidate.stats.replacements,1);assert.equal(Object.keys(candidate.stats.bodyHashes).length,11);
  assert.ok(candidate.source.length>source.length);assert.equal(candidate.stats.exports.length,new Set(candidate.stats.exports).size);
  assert.throws(()=>transformEquality(candidate.source),/Unsupported equality dependency/);
});
test('reject changed equality dependency and runtime',()=>{
  assert.throws(()=>transformEquality(source.replace('function $Char$cmp$(a_0, b_0) {','function $Char$cmp$(a_0, b_0) {\n  void 0;')),/Unsupported equality dependency/);
  assert.throws(()=>transformEquality(source.replace('function char_new(code) {','function char_new(code) {\n void 0;')),/Unsupported generated runtime/);
});
test('reject duplicate, nested and rebound protected function bindings',()=>{
  const body=source.match(/function \$String\$eq\$\(a_0, b_0\) \{\n[^\n]*\n\}/)[0];
  assert.throws(()=>transformEquality(source.replace('export default {',body+'\nexport default {')),/duplicate/);
  assert.throws(()=>transformEquality(source.replace('export default {','function $probe$() {\n'+body+'\n}\nexport default {')),/Nested equality binding/);
  assert.throws(()=>transformEquality(source.replace('export default {','function $probe$() {\n $String$eq$ = null;\n}\nexport default {')),/Rebound/);
  assert.throws(()=>transformEquality(source+'\n$String$eq$ = null;'),/Unexpected top-level/);
});
test('quoted declaration text cannot masquerade as a binding',()=>{
  const text='function $String$eq$(a_0, b_0) {\n return false;\n}';
  const decoy=source.replace('export default {','function $probe$() {\n return '+JSON.stringify(text)+';\n}\nexport default {');
  assert.equal(transformEquality(decoy).stats.replacements,1);
  assert.throws(()=>transformEquality(source.replace('function $String$eq$(', 'function $notEquality$(')),/Unsupported equality dependency/);
});
test('reject protected function and arrow parameter bindings, including destructuring',()=>{
  for(const body of [
    'function $probe$($String$eq$) { return 1; }',
    'function $probe$() { return function($String$cmp$) { return 1; }; }',
    'function $probe$() { return ($String$eq$) => 1; }',
    'function $probe$() { return ({x: $String$eq$}) => 1; }',
    'function $probe$() { return $String$eq$ => 1; }'
  ])assert.throws(()=>transformEquality(source.replace('export default {',body+'\nexport default {')),/Shadowed equality parameter/);
});
test('Unicode, malformed UTF-16 and non-string values preserve exact observations',()=>{
  const values=['','a','b','abc','abd','a\0b','\0','é','e\u0301','λ','中','🙂','𝄞','\ud800','\udc00','a\ud800','b\ud800','\ud800a','\udc00a','\ud800\ud800','\udc00\ud800','🙂\ud800',null,undefined,0,1,true,false,{},new String('abc')];
  for(let i=0;i<values.length;i++)for(let j=0;j<values.length;j++)assert.deepEqual(observe(modules[1],values[i],values[j]),observe(modules[0],values[i],values[j]),`${i},${j}`);
  for(const n of [128,512,2048])for(const tail of ['','x','🙂'])assert.deepEqual(observe(modules[1],'ab'.repeat(n),'ab'.repeat(n)+tail),observe(modules[0],'ab'.repeat(n),'ab'.repeat(n)+tail));
});
test('malformed suffixes retain early mismatch/exhaustion and demanded-error order',()=>{
  for(const [a,b,expected]of [['x\ud800','y\ud800',false],['','\ud800',false],['\ud800','',false],['x\ud800','x\ud800','bend: 55296 is not a Unicode scalar value'],['\ud800','\udc00','bend: 55296 is not a Unicode scalar value']]) {
    for(const module of modules){const result=observe(module,a,b);assert.equal(typeof expected==='boolean'?result.value:result.error,expected);}
  }
});
test('fallback objects and staged arguments preserve observed demand',()=>{
  function run(module) {
    const events=[];
    const a={codePointAt(i){events.push('left codepoint');throw Error('left error');}},b={codePointAt(i){events.push('right codepoint');throw Error('right error');}};
    return {result:observe(module,a,b),events};
  }
  assert.deepEqual(run(modules[1]),run(modules[0]));assert.deepEqual(run(modules[1]).events,['left codepoint']);
  for(const module of modules) {
    const events=[],arg=(name,value)=>(events.push(name),value);
    const partial=module.staged(arg('left','abc'));assert.deepEqual(events,['left']);
    assert.equal(partial(arg('right','abc')),true);assert.deepEqual(events,['left','right']);
    assert.equal(module.staged('a','a','ignored'),true);
  }
});
test('fresh derivation has distinct honest lineage, replays and rejects drift',async()=>{
  const report=process.env.EQUALITY_TEST_BOOTSTRAP;
  assert.ok(report,'Set EQUALITY_TEST_BOOTSTRAP to the matching normal bootstrap report');
  const output=path.join(temp,'successful'),result=await deriveEquality({api:input,bootstrapReport:report,outputDirectory:output});
  assert.equal(result.metadata.newBootstrap,false);assert.equal(result.metadata.complete,true);
  assert.equal(fs.existsSync(result.api+'.bootstrap.json'),false);assert.equal(verifyEqualityDerivation(result.report).api,result.api);
  await assert.rejects(()=>deriveEquality({api:input,bootstrapReport:report,outputDirectory:output}),/EEXIST/);
  fs.appendFileSync(result.api,'\n');assert.throws(()=>verifyEqualityDerivation(result.report),/Changed input/);
});
test('incomplete/bootstrap identity mismatch retains explicit refusal report',async()=>{
  const report=JSON.parse(fs.readFileSync(process.env.EQUALITY_TEST_BOOTSTRAP,'utf8'));
  for(const [name,mutate]of [['incomplete',r=>r.provenance.verifiedAfterBuild=false],['wrong-api',r=>r.apiSha256='0'.repeat(64)],['wrong-stage',r=>r.stage='selfhost']]) {
    const changed=structuredClone(report);mutate(changed);const file=path.join(temp,name+'.json');fs.writeFileSync(file,JSON.stringify(changed));const output=path.join(temp,name);
    await assert.rejects(()=>deriveEquality({api:input,bootstrapReport:file,outputDirectory:output}));
    const failure=JSON.parse(fs.readFileSync(path.join(output,'api.mjs.derivation.json'),'utf8'));assert.equal(failure.complete,false);assert.equal(typeof failure.error,'string');
    assert.equal(fs.existsSync(path.join(output,'api.mjs')),false);
  }
});

test.after(()=>{fs.rmSync(temp,{recursive:true,force:true});});
