// Root-owned diagnostic: expose pure preparation from two checked JS siblings.
// No IO main is run; no source/compiler algorithm is changed by this harness.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import Module from 'node:module';
import {createHash} from 'node:crypto';
const [beforeArg,afterArg,baseArg,outArg]=process.argv.slice(2);
assert(beforeArg&&afterArg&&baseArg&&outArg,'BEFORE_JS AFTER_JS BASE FRESH_OUT');
const before=path.resolve(beforeArg),after=path.resolve(afterArg),base=path.resolve(baseArg),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const sha=b=>createHash('sha256').update(b).digest('hex');
const pin=p=>({path:p,sha256:sha(fs.readFileSync(p))});
function image(file) {
  const source=fs.readFileSync(file,'utf8');
  const footer='cli(process.argv.slice(1));\nio_exit($main$, null);';
  assert(source.endsWith(footer)||source.endsWith(footer+'\n'),'unexpected IO footer');
  assert.equal(source.split(footer).length,2);
  assert(source.includes('function $p86_prepare$('),'missing checked entry');
  const derivative=source.slice(0,source.lastIndexOf(footer))+'\nmodule.exports = { prepare: (path, text) => run_loop($p86_prepare$(path, text)) };\n';
  const module=new Module(file);
  module.filename=file;module.paths=Module._nodeModulePaths(path.dirname(file));
  module._compile(derivative,file);
  return {api:module.exports,sourceSha256:sha(source),derivativeSha256:sha(derivative),method:'Remove exact IO CLI footer; export only existing pure p86_prepare'};
}
// Compare complete Data products including all constructor fields and origins.
// Memoized pairs preserve linear work over shared DAGs, not expanded JSON trees.
function exact(a,b) {
  const todo=[[a,b,'root']],seen=new WeakMap();let pairs=0,scalars=0;
  while(todo.length) {
    const [x,y,at]=todo.pop();
    if(x===null||typeof x!=='object'||y===null||typeof y!=='object') {
      assert(Object.is(x,y),`${at}: scalar mismatch`);scalars++;continue;
    }
    assert.equal(Array.isArray(x),Array.isArray(y),at);
    let ys=seen.get(x);if(ys?.has(y))continue;
    if(!ys){ys=new WeakSet();seen.set(x,ys);}ys.add(y);pairs++;
    const kx=Object.keys(x).sort(),ky=Object.keys(y).sort();assert.deepEqual(kx,ky,at);
    for(const k of kx)todo.push([x[k],y[k],at+'.'+k]);
  }
  return {objectPairs:pairs,scalarChecks:scalars};
}
const baselineText=fs.readFileSync(base,'utf8');
assert.equal(sha(baselineText),'99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf','pinned Base changed');
const report={schema:'phase88-base-products-v1',complete:false,inputs:[pin(before),pin(after),pin(base),pin(import.meta.filename)],records:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try {
  const old=image(before),next=image(after);report.images={before:{...old,api:undefined},after:{...next,api:undefined}};save();
  const cases=[
    {name:'pinned-base',text:baselineText,expected:'ready'},
    {name:'empty-prefix',text:'',expected:'same'},
    {name:'closed-polymorphic-prefix',text:'def p88_identity(-A: Type, x: A) -> A:\n  x\n',expected:'same'},
    {name:'parse-error',text:'def p88_broken(\n',expected:'base_parse: '},
    {name:'checking-error',text:'def p88_unbound() -> Type:\n  missing_name\n',expected:'base_check: '},
    {name:'open-declaration',text:'law p88_open:\n  Type\n',expected:'ready'},
    {name:'erased-open-declaration',text:'law p88_open:\n  Type\n\ndef p88_use() -> Type:\n  p88_open\n',expected:'ready'},
    // Base is loaded in the trusted Base context. Retain its old disposition;
    // the failed generic-module refusal oracle is kept in earlier run reports.
    {name:'open-declaration-in-base-context',text:'type P88T is Type:\n  P88Ctor{}\n\nlaw p88_open:\n  P88T\n\ndef p88_use() -> P88T:\n  p88_open\n',expected:'same'},
  ];
  for(const c of cases) {
    const start=performance.now();const a=old.api.prepare(base,c.text),b=next.api.prepare(base,c.text);
    const checked=exact(a,b);
    if(c.expected==='ready')assert.equal(b.$,'P86PreparationReady');
    else if(c.expected!=='same'){assert.equal(b.$,'P86PreparationError');assert(b.error.startsWith(c.expected),b.error);}
    if(b.$==='P86PreparationReady') {
      assert.equal(b.seed.world.prefix,b.seed.book,'candidate prepared prefix lost book alias');
      assert.equal(a.seed.world.prefix,a.seed.book,'baseline prepared prefix lost book alias');
    }
    report.records.push({name:c.name,textSha256:sha(c.text),result:b.$,error:b.error??null,...checked,diagnosticWallMs:performance.now()-start,exact:true});save();
    console.log(JSON.stringify(report.records.at(-1)));
  }
  report.complete=true;
} catch(error) {report.error=error.stack??String(error);save();throw error;}
finally {save();}
