// Root-run correctness diagnostic: expose existing pure functions from a checked
// equality-only JS derivative. No IO main, native layout, or semantic rewrite.
// BUILD_REPORT JS_DERIVATION_JSON CARRIER_RECEIPT NEW_OUTPUT_DIRECTORY
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import Module from 'node:module';
import {createHash} from 'node:crypto';
import {decodeBaseArena,encodeBaseArena} from '../../../base-cache-graph.mjs';
const [buildFile,derivationFile,receiptFile,outArg]=process.argv.slice(2);
assert(outArg,'BUILD_REPORT JS_DERIVATION_JSON CARRIER_RECEIPT NEW_OUT');
const out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const sha=b=>createHash('sha256').update(b).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,sha256:sha(b),bytes:b.length};};
const verify=p=>{const got=pin(p.file);assert.equal(got.sha256,p.sha256,p.file);if(p.bytes!==undefined)assert.equal(got.bytes,p.bytes,p.file);return got;};
const build=JSON.parse(fs.readFileSync(buildFile)),derivation=JSON.parse(fs.readFileSync(derivationFile)),receipt=JSON.parse(fs.readFileSync(receiptFile));
const report={kind:'phase88-cache-full-products',complete:false,inputs:[buildFile,derivationFile,receiptFile,import.meta.filename].map(pin),comparisons:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
function exact(a,b){
  const todo=[[a,b,'root']],seen=new WeakMap();let objectPairs=0,scalarChecks=0;
  while(todo.length){
    const [x,y,at]=todo.pop();
    if(x===null||typeof x!=='object'||y===null||typeof y!=='object'){
      assert(Object.is(x,y),`${at}: scalar mismatch`);scalarChecks++;continue;
    }
    assert.equal(Array.isArray(x),Array.isArray(y),at);
    let ys=seen.get(x);if(ys?.has(y))continue;
    if(!ys){ys=new WeakSet();seen.set(x,ys);}ys.add(y);objectPairs++;
    const kx=Object.keys(x).sort(),ky=Object.keys(y).sort();assert.deepEqual(kx,ky,at);
    for(const k of kx)todo.push([x[k],y[k],at+'.'+k]);
  }
  return {objectPairs,scalarChecks};
}
try{
  assert(build.complete&&build.upstream==='059266225b77c8ca256ac6b25ee5c21449bab151');
  assert.equal(derivation.kind,'phase86-io-program-equality-only');
  assert.equal(derivation.parent.sha256,build.js.sha256);
  assert.equal(derivation.parentBuildSha256,pin(buildFile).sha256);
  assert(receipt.complete&&receipt.kind==='phase88-private-base-carrier');
  for(const p of Object.values(receipt.inputPins))report.inputs.push(verify(p));
  report.inputs.push(verify(build.js),verify(derivation.output),verify(receipt.carrier));
  const source=fs.readFileSync(derivation.output.file,'utf8');
  const raw=fs.readFileSync(build.js.file,'utf8');
  assert.equal(raw.split(derivation.old).length,2);
  assert.equal(source,raw.replace(derivation.old,derivation.old.replace('\n','\n'+derivation.guard)));
  const footer='cli(process.argv.slice(1));\nio_exit($main$, null);';
  assert(source.endsWith(footer)||source.endsWith(footer+'\n'));
  assert.equal(source.split(footer).length,2);
  for(const name of ['p86_prepare','p88_decode_admitted','p88_cache_prepare'])assert(source.includes('function $'+name+'$('),name);
  const expose='\nmodule.exports = { prepare:(p,t)=>run_loop($p86_prepare$(p,t)), decode:(t,s,b,e)=>run_loop($p88_decode_admitted$(t,s,b,e)), cached:(p,t,c,s)=>run_loop($p88_cache_prepare$(p,t,c,s)) };\n';
  const derivative=source.slice(0,source.lastIndexOf(footer))+expose;
  const file=path.join(out,'pure-products.cjs');fs.writeFileSync(file,derivative,{flag:'wx'});
  report.derivative={...pin(file),parent:verify(derivation.output),method:'Replace exact IO footer with wrappers forcing existing pure functions through run_loop.'};save();
  const mod=new Module(file);mod.filename=file;mod.paths=Module._nodeModulePaths(path.dirname(file));mod._compile(derivative,file);
  const cache=fs.readFileSync(receipt.inputPins.cache.file),cut=cache.indexOf(10),h=JSON.parse(cache.subarray(0,cut));
  const [nb,np]=h.segments;assert.equal(cut+1+nb+np,cache.length);
  assert.equal(h.format,'bend-base-cache-frame-4');
  const opts={range:{begin:h.sourceBegin,end:h.sourceEnd},termAbi:h.termAbi};
  const first=decodeBaseArena(cache.subarray(cut+1,cut+1+nb),{...opts,rootKinds:['defs']});
  const all=decodeBaseArena(cache.subarray(cut+1+nb),{...opts,base:first,rootKinds:['checked','fresh','world','frontend']});
  const expected={$:'P88Products',book:first.roots[0],fresh:all.roots[1],ready:all.roots[3],world:all.roots[2]};
  const text=fs.readFileSync(receipt.inputPins.base.file,'utf8'),carrier=fs.readFileSync(receipt.carrier.file,'utf8');
  const at=performance.now();
  const decoded=mod.exports.decode(carrier,receipt.stamp,h.sourceBegin,h.sourceEnd);
  assert.equal(decoded.$,'P88DecodeReady',decoded.error??'unexpected decoded product');
  report.comparisons.push({name:'decoded-versus-source-cache',...exact(decoded.products,expected),exact:true,diagnosticWallMs:performance.now()-at});save();
  const before=performance.now();
  const fresh=mod.exports.prepare(h.sourcePath,text);assert.equal(fresh.$,'P86PreparationReady',fresh.error??'unexpected fresh product');
  const freshProducts={$:'P88Products',book:fresh.seed.book,fresh:fresh.seed.fresh,ready:fresh.seed.ready,world:fresh.seed.world};
  report.comparisons.push({name:'fresh-versus-source-cache',...exact(freshProducts,expected),exact:true,diagnosticWallMs:performance.now()-before});save();
  const cached=mod.exports.cached(h.sourcePath,text,carrier,receipt.stamp);assert.equal(cached.$,'P86PreparationReady',cached.error??'unexpected cached product');
  report.comparisons.push({name:'complete-cached-versus-live-seed',...exact(cached,fresh),exact:true});
  assert.equal(cached.seed.world.prefix,cached.seed.book,'world prefix lost book alias');
  for(const [name,c,s] of [['wrong-stamp',carrier,receipt.stamp+'!'],['truncated',carrier.slice(0,-3),receipt.stamp],['trailing',carrier+'x',receipt.stamp]]){
    const refused=mod.exports.cached(h.sourcePath,text,c,s);assert.equal(refused.$,'P86PreparationError',name);assert(refused.error.startsWith('base_cache: '));
    report.comparisons.push({name,result:refused.$,error:refused.error,expectedRefusal:true});
  }
  report.canonicalProductsSha256=sha(encodeBaseArena([decoded.products.book,decoded.products.fresh,decoded.products.world,decoded.products.ready]).bytes);
  for(const p of report.inputs)verify(p);
  report.complete=true;
  report.limitation='Full Data equivalence on checked JS derivative; not native speed or public cache admission. Diagnostic wall times include comparison and are not benchmark claims.';
}catch(e){report.error=e.stack??String(e);process.exitCode=1;}
report.maxRssKiB=process.resourceUsage().maxRSS;save();console.log(JSON.stringify({complete:report.complete,report:path.join(out,'report.json'),comparisons:report.comparisons,error:report.error}));
