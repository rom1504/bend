// Root-supervised target job: transport falsifiers, not a fixed-point claim.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {identity,verify,list,array,loadDirectCompiler} from './adapter.mjs';

const [configFile,outArg]=process.argv.slice(2);
assert.ok(configFile&&outArg,'probe-image.mjs EMISSION/probe.json NEW_DIRECTORY');
const config=JSON.parse(fs.readFileSync(configFile,'utf8')),out=path.resolve(outArg);
assert.ok(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const report={kind:'phase54-direct-compiler-transport',pass:false,complete:false,
  config:identity(configFile),producer:identity(import.meta.filename),helper:identity(new URL('./adapter.mjs',import.meta.url)),observations:[]};
const started=performance.now();
function freezeGraph(root) {
  const todo=[root],seen=new Set();
  while(todo.length) {const x=todo.pop();if(!x||typeof x!=='object'||seen.has(x))continue;
    seen.add(x);for(const v of Object.values(x))todo.push(v);Object.freeze(x);}
}
function observe(name,fn) {const value=fn();report.observations.push({name,pass:true,value});}
try {
  verify(config.emission);
  const emission=JSON.parse(fs.readFileSync(config.emission.file,'utf8'));
  assert.equal(emission.pass,true);assert.equal(emission.complete,true);
  assert.equal(emission.module.file,config.image.file);assert.equal(emission.module.sha256,config.image.sha256);
  assert.deepEqual(emission.roots,config.required);
  const {api,module}=await loadDirectCompiler(config.image,config.required);
  report.image=config.image;report.emission=config.emission;
  report.rawExports=Object.keys(module.default).sort();report.selectedExports=Object.keys(api).sort();
  assert.deepEqual(report.selectedExports,[...config.required].sort());
  for(const name of config.required)assert.equal(api[name],module.default[name],'Method wrapper introduced');
  observe('version-probes',()=>Object.fromEntries(['compiler_term_abi','compiler_span_abi','compiler_load_abi','compiler_check_result_abi']
    .filter(k=>api[k]).map(k=>[k,api[k]()])));
  if(api.f_path_join&&api.f_path_dir)observe('path-strings',()=>{
    assert.equal(api.f_path_join('/alpha/','beta.bend'),'/alpha/beta.bend');
    assert.equal(api.f_path_join('/alpha/','/beta.bend'),'/beta.bend');
    assert.equal(api.f_path_dir('/alpha/beta.bend'),'/alpha/');return 3;
  });
  if(api.kt&&api.tg&&api.kid) {
    const nil=Object.freeze({$:'Nil'});
    const leaf=Object.freeze({$:'KLiteral',kind:'U32',number:19,text:'',originBegin:0,originEnd:0});
    const kids=list([leaf,leaf]);freezeGraph(kids);
    observe('named-fields-and-diamond',()=>{
      const t=api.kt('Probe','name',7,2,kids);
      assert.deepEqual(Object.keys(t).sort(),['$','tag','name','id','quant','kids','removed','originBegin','originEnd'].sort());
      assert.equal(t.$,'KTerm');assert.equal(t.kids,kids);assert.equal(t.id,7);
      assert.equal(api.tg(t),'Probe');assert.equal(api.kid(t,0),leaf);assert.equal(api.kid(t,1),leaf);
      assert.equal(t.removed.$,'Nil');assert.equal(t.originBegin,0);assert.equal(t.originEnd,0);
      t.tag='Changed';assert.equal(api.tg(t),'Changed');return {shared:true,freshResultMutable:true};
    });
    observe('long-frozen-list-spine',()=>{
      const count=20000,deep=list(Array(count).fill(leaf));freezeGraph(deep);
      const t=api.kt('Deep','',0,0,deep);assert.equal(t.kids,deep);
      assert.equal(api.kid(t,count-1),leaf);assert.equal(api.kid(t,count).tag,'Absent');return count;
    });
    if(api.book_cached&&api.lookup)observe('phase-handoff-with-shared-term',()=>{
      const term=api.kt('Pair','',0,0,kids);
      const def={$:'KDef',name:'shared',kind:'Def',arity:0,templates:0,typ:term,value:term,ctors:nil,native:false,unsafe:true};
      const book=list([def]);freezeGraph(book);
      const cached=api.book_cached(book,0);assert.equal(cached.tail,book);
      const found=api.lookup(cached,'shared');assert.equal(found,def);assert.equal(found.typ,found.value);
      assert.equal(api.kid(found.value,0),leaf);return {originalDefinition:true,sharedTerm:true};
    });
  }
  if(api.f_source_header)observe('real-loader-header',()=>{
    const source={$:'FSource',name:'probe',path:'/probe.bend',text:'def answer() -> U32: 42\n'};freezeGraph(source);
    const h=api.f_source_header(source);assert.equal(h.$,'FHeader');assert.equal(h.error,'');
    assert.deepEqual(array(h.imports),[]);assert.equal(h.body,source.text);return {line:h.line,offset:h.offset};
  });
  verify(config.image);verify(config.emission);verify(report.config);verify(report.producer);verify(report.helper);
  report.pass=true;report.complete=true;
} catch(error) {report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
finally {
  report.seconds=(performance.now()-started)/1000;
  fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
  console.log(JSON.stringify({pass:report.pass,observations:report.observations.length,seconds:report.seconds,error:report.error?.message}));
}
