// Root-run finite value checks; not a public-host equivalence qualification.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [manifestFile,output]=process.argv.slice(2);assert(manifestFile&&output);
const hash=p=>createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const manifest=JSON.parse(fs.readFileSync(manifestFile)),manifestSha=hash(manifestFile);
const report={kind:'phase48-numeric-finite-controls',complete:false,pass:false,manifestSha256:manifestSha,observations:[],
  scope:'35 independent finite recurrence values per derivative; no retained-view/host-boundary equivalence or timing claim.'};
assert.equal(manifest.kind,'phase48-saved-numeric-constants-ablation');assert.equal(manifest.controls.length,35);
assert(!fs.existsSync(output));fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');
try{
  for(const [role,item]of Object.entries(manifest.modules)){
    assert.equal(hash(item.path),item.sha256);const m=await import(pathToFileURL(item.path));
    for(const c of manifest.controls){const value=m.default.bench(...c.args);assert.equal(value,c.expected);report.observations.push({role,args:c.args,value});}
    assert.equal(hash(item.path),item.sha256);
  }
  assert.equal(hash(manifestFile),manifestSha);assert.equal(report.observations.length,105);report.complete=report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
finally{fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');}
