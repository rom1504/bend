// Exhaustive current catalog + adverse unknown names on actual checked B1 APIs.
// Root executes under its existing CPU3 resource guard. No timings are a benchmark.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
const [proposalArg,baselineAttemptArg,candidateAttemptArg,outArg]=process.argv.slice(2);
const out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const inputs=new Map();
const pin=x=>{const expected=typeof x==='string'?null:x,file=fs.realpathSync(expected?.file??x),b=fs.readFileSync(file),p={file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};if(expected){assert.equal(p.sha256,expected.sha256);if(expected.bytes!==undefined)assert.equal(p.bytes,expected.bytes);}inputs.set(file,p);return p;};
const read=x=>JSON.parse(fs.readFileSync(pin(x).file,'utf8'));
const report={kind:'phase68-demand-template-controls',complete:false,pass:false,rows:[],derivatives:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
try{
  report.method=pin(import.meta.filename);report.proposal=pin(proposalArg);
  const proposal=read(proposalArg),catalog=read(proposal.catalog),entries=catalog.entries;
  assert.equal(entries.length,69);assert.equal(new Set(entries.map(x=>x.name)).size,69);
  pin(proposal.producer);pin(proposal.patch);pin(catalog.source);
  const originals={};
  for(const [role,file] of [['baseline',baselineAttemptArg],['candidate',candidateAttemptArg]]){
    const attemptPin=pin(file),attempt=read(file);
    assert(attempt.checked&&attempt.config.strictExact&&attempt.artifactKind==='derived-b1');
    const apiPin=pin(attempt.api),source=attempt.snapshot.sources.find(p=>p.frozen.file.endsWith('/src/back/native/intrinsic.bend'));
    assert(source);pin(source.frozen);pin(attempt.derivationReport);pin(attempt.bootstrapReport);pin(attempt.checkedApi);
    const expected=proposal.files.find(p=>p.path.endsWith('/intrinsic.bend'))[role==='baseline'?'before':'after'];
    assert.equal(source.frozen.sha256,pin(expected).sha256);
    const src=fs.readFileSync(apiPin.file,'utf8');
    for(const name of ['ni_emit','nd_scalar_known',role==='baseline'?'ni_find':'ni_template'])assert(src.includes('function $'+name+'$('));
    const expression=role==='baseline'?'$ni_find$(k, $ni_templates$())':'$ni_template$(k)';
    const append='\n// P68-006 diagnostic exports only; original module bytes remain the exact prefix.\n'+
      'export const p68 = {\n'+
      '  template: run_lib(k => run_loop('+expression+'), 1),\n'+
      '  emit: run_lib((k, xs) => run_loop($ni_emit$(k, xs)), 2),\n'+
      '  scalarKnown: run_lib(k => run_loop($nd_scalar_known$(k)), 1)\n};\n';
    const derivative=path.join(out,role+'-observed.mjs');fs.writeFileSync(derivative,src+append,{flag:'wx'});
    assert.equal(fs.readFileSync(derivative,'utf8').slice(0,src.length),src);
    const module=await import(pathToFileURL(derivative));assert.equal(module.G,undefined);
    originals[role]=module.p68;
    report.derivatives.push({role,attempt:attemptPin,original:apiPin,source:pin(source.frozen),
      derived:pin(derivative),append,scope:'Append-only wrappers expose existing compiled functions; no compiler algorithm is changed and no Base cache is read or written.'});
  }
  const expected=new Map(entries.map(x=>[x.name,x.template]));
  const names=[...expected.keys(),'',...entries.flatMap(x=>[x.name+'!', '!'+x.name, x.name.toUpperCase()]),
    'u32','f32_','nat_add\0','u32_add\n','\0','λ','😀','x'.repeat(1024)];
  const unique=[...new Set(names)];
  const vectors=[[],['left'],['left','right'],['($1)','$0'],['$0','$1','$2'],['"\\\n','λ😀','third'],['','$1suffix','$2']];
  const fill=(template,words)=>words.reduce((s,w,i)=>s.split('$'+i).join(w),template);
  for(const name of unique){
    const template=expected.get(name)??'',known=template!==''&&!['f32_show','f32_read'].includes(name);
    for(const api of Object.values(originals)){assert.equal(api.template(name),template,name);assert.equal(api.scalarKnown(name),known,name);}
    for(const words of vectors){
      const want=fill(template,words);
      for(const api of Object.values(originals))assert.equal(api.emit(name,list(words)),want,JSON.stringify({name,words}));
    }
    report.rows.push({name,templateBytes:Buffer.byteLength(template),known,emissionVectors:vectors.length,pass:true});
  }
  for(const p of [...inputs.values()])pin(p);
  report.summary={catalog:69,names:unique.length,unknownNames:unique.length-69,emissionVectors:vectors.length,
    scalarMembershipChecks:unique.length*2,completeTemplateChecks:unique.length*2,completeEmissionChecks:unique.length*vectors.length*2};
  report.inputs=[...inputs.values()];report.inputsUnchanged=true;report.complete=true;report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;report.inputs=[...inputs.values()];}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,summary:report.summary,error:report.error}));
