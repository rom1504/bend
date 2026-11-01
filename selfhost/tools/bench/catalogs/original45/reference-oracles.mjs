// Root runs this bounded worker only on checked pinned TypeScript preparation.
// Its values are differential oracles, never labeled independent correctness.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [manifestArg, catalogArg, outputArg] = process.argv.slice(2);
assert(manifestArg && catalogArg && outputArg,
  'usage: reference-oracles.mjs TS_MANIFEST DRAFT_CATALOG NEW_REPORT');
const identity = file => ({path:fs.realpathSync(file),
  sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex'),
  bytes:fs.statSync(file).size});
const verify = (file, item) => {
  const got = identity(file);
  assert.equal(got.sha256,item.sha256); assert.equal(got.bytes,item.bytes);
  return got;
};
const manifestFile=path.resolve(manifestArg),catalogFile=path.resolve(catalogArg),output=path.resolve(outputArg);
assert(!fs.existsSync(output));
const manifest=JSON.parse(fs.readFileSync(manifestFile)),catalog=JSON.parse(fs.readFileSync(catalogFile));
const report={kind:'phase37-pinned-reference-oracles',complete:false,
  scope:'Checked pinned TypeScript scalar results; differential oracle only, not independent semantic proof.',
  producer:identity(import.meta.filename),manifest:identity(manifestFile),catalog:identity(catalogFile),
  upstreamCommit:catalog.upstreamCommit,observations:[],inputs:[]};
try {
  assert.equal(manifest.complete,true); assert.deepEqual(Object.keys(manifest.roles),['typescript']);
  assert.equal(manifest.catalogSha256,report.catalog.sha256);
  assert.equal(manifest.upstreamCommit,catalog.upstreamCommit);
  const compiler=manifest.roles.typescript.compiler;
  assert.equal(compiler.kind,'checked-pinned-typescript');
  assert.equal(compiler.upstreamCommit,catalog.upstreamCommit);
  report.compiler=compiler;
  const root=path.dirname(manifestFile),preparationFile=path.resolve(root,manifest.preparation.path);
  report.inputs.push(verify(preparationFile,manifest.preparation));
  const preparation=JSON.parse(fs.readFileSync(preparationFile)); assert.equal(preparation.complete,true);
  const loaded=new Map();
  for(const selected of catalog.cases.filter(c=>c.oracleStatus==='pending-pinned-reference')) {
    const row=manifest.cases.find(c=>c.id===selected.id); assert(row);
    assert.equal(row.sourceSha256,selected.source.sha256); assert.deepEqual(row.point,selected.point);
    const moduleEntry=row.modules.typescript,moduleFile=path.resolve(root,moduleEntry.path);
    assert(moduleFile.startsWith(root+path.sep));
    report.inputs.push(verify(moduleFile,moduleEntry));
    const receiptFile=moduleFile+'.json',receipt=JSON.parse(fs.readFileSync(receiptFile));
    assert.equal(receipt.complete,true); assert.equal(receipt.observation.checked,true);
    assert.equal(receipt.output.sha256,moduleEntry.sha256); assert.deepEqual(receipt.compiler,compiler);
    assert.equal(receipt.input.sha256,selected.source.sha256);
    report.inputs.push(identity(receiptFile));
    if(!loaded.has(moduleFile)) loaded.set(moduleFile,(await import(pathToFileURL(moduleFile))).default);
    const value=loaded.get(moduleFile)[selected.point.exportName](...selected.point.args);
    assert((typeof value==='number'&&Number.isInteger(value)&&value>=0&&value<=4294967295)
      ||typeof value==='string');
    report.observations.push({id:selected.id,sourceSha256:selected.source.sha256,
      exportName:selected.point.exportName,args:selected.point.args,expected:value,module:identity(moduleFile)});
  }
  assert(report.observations.length>0);
  for(const item of [report.manifest,report.catalog,...report.inputs]) verify(item.path,item);
  report.complete=true;
} catch(error) {report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,observations:report.observations.length,error:report.error}));
