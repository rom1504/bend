import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import test from 'node:test';
import {captureBootstrapProvenance,verifyBootstrapProvenance} from '../../tools/typed-driver.mjs';

function fixture(){
  const root=fs.mkdtempSync(path.join(os.tmpdir(),'bend-bootstrap-provenance-')),file=name=>path.join(root,name);
  fs.mkdirSync(file('bend2'));for(const name of ['bend.ts','comp.ts','base.bend'])fs.writeFileSync(file('bend2/'+name),name+'\n');
  fs.writeFileSync(file('builder.mjs'),'// test builder\n');
  const git=args=>{const result=spawnSync('git',['-C',root,...args],{encoding:'utf8'});assert.equal(result.status,0,result.stderr);return result.stdout.trim();};
  git(['init','-q']);git(['add','.']);git(['-c','user.name=Test','-c','user.email=test@example.invalid','commit','-qm','fixture']);
  const options={expectedRevision:git(['rev-parse','HEAD']),tools:[file('builder.mjs')]};
  return {root,file,options,close:()=>fs.rmSync(root,{recursive:true,force:true})};
}
test('bootstrap captures actual upstream/compiler/build tools with clean pinned identity',()=>{
  const f=fixture();try{
    const provenance=captureBootstrapProvenance(f.root,f.options);assert.equal(provenance.inputs.length,4);assert.equal(provenance.upstream.trackedSourcesClean,true);
    assert.equal(provenance.verifiedAfterBuild,false);assert.ok(provenance.inputs.every(input=>input.canonicalPath===fs.realpathSync(input.file)&&input.sha256.length===64));
    assert.equal(verifyBootstrapProvenance(provenance),true);
    assert.throws(()=>captureBootstrapProvenance(f.root,{...f.options,expectedRevision:'wrong'}),/requires upstream wrong/);
    fs.appendFileSync(f.file('bend2/bend.ts'),'changed');assert.throws(()=>captureBootstrapProvenance(f.root,f.options),/tracked sources differ/);assert.throws(()=>verifyBootstrapProvenance(provenance),/tracked sources differ/);
  }finally{f.close();}
});
test('bootstrap rejects build-tool drift before publishing a checked artifact',()=>{
  const f=fixture();try{
    const provenance=captureBootstrapProvenance(f.root,f.options);fs.appendFileSync(f.file('builder.mjs'),'changed');
    assert.throws(()=>verifyBootstrapProvenance(provenance),/Bootstrap input changed/);
  }finally{f.close();}
});
test('bootstrap rejects same-byte tool symlink retargets',()=>{
  const f=fixture();try{
    const first=f.file('first.mjs'),second=f.file('second.mjs'),alias=f.file('alias.mjs');
    fs.writeFileSync(first,'same');fs.writeFileSync(second,'same');fs.symlinkSync(first,alias);
    const provenance=captureBootstrapProvenance(f.root,{...f.options,tools:[alias]});fs.unlinkSync(alias);fs.symlinkSync(second,alias);
    assert.throws(()=>verifyBootstrapProvenance(provenance),/Bootstrap input changed/);
  }finally{f.close();}
});
