// Files/identity transport only. Both complete backend decisions remain Bend.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {pin, verify, items, root} from '../../phase147/tools/support.mjs';
import {encodeGraph, writeGraph} from '../../phase154/tools/graph.mjs';

const [planFile, directory] = process.argv.slice(2);
assert(planFile && directory && process.argv.length === 4);
const plan = JSON.parse(fs.readFileSync(planFile));
assert(plan.complete && plan.kind === 'phase165-backend-replay');
const out = path.resolve(directory);
assert(out.startsWith(root + '/selfhost/build/phase165/') && !fs.existsSync(out));
fs.mkdirSync(out, {recursive: false});
const report = {kind:'phase165-complete-backend-replay', complete:false, inputs:[pin(planFile), ...plan.inputs],
  name:plan.name, source:plan.source, expectedStdout:plan.expectedStdout, products:{},
  acquisitionSeconds:0, executionArgs:plan.executionArgs, expectedFile:plan.expectedFile,
  scope:'One actual checked NR_Request, passed unchanged to both complete maintained backends. Hosted diagnostic clocks include rendering and file writes, exclude machine construction and process teardown. No native speed or generated-execution claim.'};
const save = () => fs.writeFileSync(path.join(out,'report.json'), JSON.stringify(report,null,2)+'\n');
const elapsed = start => (performance.now()-start)/1000;
save();
try {
  report.inputs.forEach(verify);
  assert.equal(pin(process.execPath).sha256, plan.providers.bun.sha256, 'Pinned engine required');
  const receipt = JSON.parse(fs.readFileSync(plan.apiReceipt.file));
  assert(receipt.complete && receipt.checked);
  assert.equal(receipt.api.sha256, plan.api.sha256);
  for (const name of plan.requiredExports) assert(receipt.exports.includes(name), name);
  const api = (await import(pathToFileURL(plan.api.file))).default;
  const base = fs.realpathSync(plan.providers.base.file);
  let start = performance.now();
  const prepared = api.p86_prepare(base, fs.readFileSync(base,'utf8'));
  assert.equal(prepared.$, 'P86PreparationReady', prepared.error);
  report.baseSeconds = elapsed(start);
  start = performance.now();
  const checked = api.p86_plan(prepared.seed, plan.source.file, fs.readFileSync(plan.source.file,'utf8'));
  assert.equal(checked.$, 'P86PlanReady', checked.error);
  report.frontendSeconds = elapsed(start);
  assert.equal(checked.request.$, 'NR_Request');
  report.verdict = checked.verdict;
  // Generic graph transport preserves all six request fields and sharing.
  // Capture is outside backend clocks; neither compiler consumes a projection.
  const graphFile = path.join(out,'request.graph.json');
  writeGraph(graphFile, encodeGraph(checked.request), plan.bounds.graphBytes);
  report.request = pin(graphFile); save();

  // This host mapping matches typed-driver native mode's audited Base handlers.
  // Semantic foreign parsing/scoping runs in Bend, using ORIGINAL source/scope.
  const safe = {'args.c':plan.providers['c-effect-args'], 'print.c':plan.providers['c-effect-print'],
                'now.c':plan.providers['c-effect-now']};
  const audited = {'args.c':'7209a5fa11396fa8b0667a6738c913c40f554797e442c847a25e13a5f69676e0',
    'print.c':'709500d2ace6e2eaeec0f5f1e4373d4ec5e402b3c1e289bd70dfef7e2a635b26',
    'now.c':'da5fde65701c4fadc7560625c9615b4d60b2eefbd7b6bbe1aedda61887b825b9'};
  assert.equal(plan.providers.base.sha256,'99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf');
  const effects = [...new Set(items(checked.request.paths))].map(file => {
    assert.equal(path.dirname(path.resolve(file)),path.join(path.dirname(base),'effs'), 'Non-Base foreign refused');
    const name = path.basename(file), provider = safe[name];
    assert(provider && provider.sha256 === audited[name], 'Unaudited effect ' + file);
    verify(provider);
    return {file, source:fs.readFileSync(provider.file,'utf8')};
  });
  const runtimeText = fs.readFileSync(plan.providers['c-runtime'].file,'utf8');
  const writeProduct = (role, body) => {
    const file=path.join(out,role === 'c' ? 'program.c' : 'program.ssa');
    const fd=fs.openSync(file,'wx'); let bytes=0, pieces=0;
    const write=text => {
      assert.equal(typeof text,'string'); bytes+=Buffer.byteLength(text); pieces++;
      assert(bytes<=plan.bounds.productBytes && pieces<=plan.bounds.pieces, 'Output bound exceeded');
      fs.writeSync(fd,text);
    };
    const begin=performance.now();
    try { body(write); } finally { fs.closeSync(fd); }
    const seconds=elapsed(begin);
    assert(bytes>0,'Empty complete product');
    report.products[role]={file:pin(file),seconds,bytes,pieces}; save();
  };
  writeProduct('qbe', write => {
    const emission=api.p134e_plan(checked);
    if(emission.$==='P111Emission') {
      assert.equal(emission.error,''); for(const text of items(emission.chunks)){write(text);write('\n');}
    } else {
      assert.equal(emission.$,'P134Planned');
      let cursor=api.p134e_begin(emission.plan);
      for(;;) {
        const step=api.p134e_next(cursor);
        if(step.$==='P134Done') break;
        assert.equal(step.$,'P134Piece'); write(step.text); if(step.legacy_end)write('\n'); cursor=step.next;
      }
    }
  });
  if(plan.qbeOracle) {
    verify(plan.qbeOracle);
    report.qbeOracleExact=fs.readFileSync(report.products.qbe.file.file).equals(fs.readFileSync(plan.qbeOracle.file));
    save(); assert(report.qbeOracleExact, 'Complete QBE differs from independently retained native oracle');
  }
  writeProduct('c', write => {
    const requests=effects.map(({file,source}) => {
      const parsed=api.kf_source(checked.request.source,checked.request.scope,file,source);
      assert.equal(parsed.error,'');
      return api.nc_foreign_source(checked.request.source,checked.request.scope,file,source,parsed);
    }).join('\n');
    const result=api.nr_compile_prepared(checked.request,api.ne_runtime_prepare(runtimeText),requests,true);
    assert.equal(result.$,'NC_Result'); assert.equal(result.error,''); write(result.source);
  });
  report.inputs.forEach(verify);
  report.complete=true;
} catch(error) {
  report.error=String(error.stack??error); process.exitCode=1;
} finally {
  save(); console.log(JSON.stringify({complete:report.complete, products:report.products, error:report.error}));
}
