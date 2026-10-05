// Actual maintained RLE source: count executed tuple/list construction syntax.
// Diagnostic only: counters may prevent V8 scalar replacement; never time them.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [baseline,candidate,output]=process.argv.slice(2);assert(output,'aggregate-rle-counters-v1.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase48-maintained-rle-aggregate-witness',complete:false,pass:false,inputs:[],modules:[],observations:[],
  scope:'Exact maintained RLE small source, checksum11, executed ArrayExpression and private tagged-constructor counts; not physical V8 heap allocation or timing.'};
const pinned=new Map(),hash=b=>createHash('sha256').update(b).digest('hex');
function identity(file){file=fs.realpathSync(file);const b=fs.readFileSync(file);return{path:file,sha256:hash(b),bytes:b.length};}
function pin(file,want){const row=identity(file);if(want){assert.equal(row.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(row.bytes,want.bytes);}if(pinned.has(row.path))assert.deepEqual(row,pinned.get(row.path));else{pinned.set(row.path,row);report.inputs.push(row);}return row;}
function audit(x){if(Array.isArray(x))x.forEach(audit);else if(x&&typeof x==='object'){const file=x.file??x.path??x.canonicalPath;if(typeof file==='string'&&x.sha256)pin(file,x);Object.values(x).forEach(audit);}}
function nodes(root){const all=[];function go(x){if(!x||typeof x!=='object')return;if(typeof x.type==='string')all.push(x);for(const y of Object.values(x))if(Array.isArray(y))y.forEach(go);else if(y&&typeof y==='object')go(y);}go(root);return all;}
try{
  pin(import.meta.filename);pin(process.execPath);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  const source=pin(path.resolve(import.meta.dirname,'../../phase37/fixtures-historical/test-rle-roundtrip.bend'));
  assert.equal(source.sha256,'ce4083dab9a8022b2c8867a30802113735917229341cecb8ce18ff9ac2e33989');
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
  new Function('module','exports',parserSource)(parser,parser.exports);
  const parse=text=>parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  report.parser={version:parser.exports.version,sha256:hash(parserSource)};
  for(const [role,file]of [baseline,candidate].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(r.kind,'bend-program-checked-emission');assert(r.complete&&r.observation.checked&&r.observation.status==='ok');
    assert.equal(r.input.sha256,source.sha256);assert.equal(r.output.sha256,module.sha256);assert.equal(r.compiler.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');audit(r);
    const original=await import(pathToFileURL(module.path));assert.equal(original.default['main.out'](),11);
    const text=fs.readFileSync(module.path,'utf8'),roots=nodes(parse(text)).filter(n=>n.type==='AssignmentExpression'&&n.operator==='='&&n.left.type==='MemberExpression'&&n.left.computed&&n.left.object.name==='G'&&n.left.property.value==='main.out');
    assert.equal(roots.length,1);const rhs=roots[0].right,part=text.slice(rhs.start,rhs.end),marker='/* private contextual instances */';assert.equal(part.split(marker).length-1,1);
    if(role)assert(part.includes('/* private scalar tuple transport */'),'maintained RLE transport must activate');
    const edits=[[rhs.start+part.indexOf(marker)+marker.length,'$p48Entries++;']];let arrays=0,objects=0;
    for(const n of nodes(rhs)){
      if(n.type==='ArrayExpression'){arrays++;edits.push([n.start,'($p48Arrays++,'],[n.end,')']);}
      if(n.type==='ObjectExpression'){
        const tag=n.properties.find(p=>p.type==='Property'&&!p.computed&&(p.key.name??p.key.value)==='$');
        if(tag?.value?.type==='Literal'&&typeof tag.value.value==='string'){
          assert(['Con','Nil'].includes(tag.value.value),'unexpected persistent constructor');objects++;edits.push([n.start,'($p48Tagged.'+tag.value.value+'++,'],[n.end,')']);
        }
      }
    }
    let instrumented=text;for(const [at,put]of edits.sort((a,b)=>b[0]-a[0]))instrumented=instrumented.slice(0,at)+put+instrumented.slice(at);
    instrumented='let $p48Arrays=0,$p48Entries=0;const $p48Tagged={Con:0,Nil:0};\n'+instrumented+'\nexport function p48Reset(){$p48Arrays=0;$p48Entries=0;$p48Tagged.Con=0;$p48Tagged.Nil=0;}export const p48Counters=()=>({arrays:$p48Arrays,entries:$p48Entries,tagged:{...$p48Tagged}});\n';parse(instrumented);
    const diagnostic=path.join(out,(role?'candidate':'baseline')+'-diagnostic.mjs');fs.writeFileSync(diagnostic,instrumented,{flag:'wx'});
    const m=await import(pathToFileURL(diagnostic));m.p48Reset();const value=m.default['main.out'](),counts=m.p48Counters();assert.equal(value,11);assert.equal(counts.entries,1);
    report.modules.push({role:role?'candidate':'baseline',module,receipt,diagnostic:identity(diagnostic),staticSites:{arrays,objects}});report.observations.push({value,...counts});
  }
  assert.equal(report.observations[0].arrays-report.observations[1].arrays,12,'five steps plus initial state must lose two tuple shells each');
  assert.deepEqual(report.observations[1].tagged,report.observations[0].tagged,'Persistent list construction must remain');
  assert.equal(report.observations[1].arrays,3,'Three persistent encoded-run pairs must remain');
  for(const row of pinned.values())assert.deepEqual(identity(row.path),row);for(const row of report.modules)assert.deepEqual(identity(row.diagnostic.path),row.diagnostic);
  report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,observations:report.observations,error:report.error}));
