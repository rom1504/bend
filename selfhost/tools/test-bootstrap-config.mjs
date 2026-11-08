// Host transport fixtures only; no Bend load, checking, emission or target run.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';
import {readBootstrapConfig} from './bootstrap-config.mjs';
import {pinnedJsEffects} from './js-effect-provider.mjs';
import {runtimeArgumentConvention,runtimeArguments,runtimeTemplateConvention} from './runtime-arguments.mjs';

const temp=fs.mkdtempSync(path.join(os.tmpdir(),'bend-bootstrap-config-'));
const sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
try {
  assert.deepEqual(runtimeArguments({}, {application:true}),['--threads','1','--gpu','off','--']);
  const rts={runtimeArgumentConvention:'bend-rts-v1'};
  assert.deepEqual(runtimeArguments(rts,{application:true}),['+RTS','--threads','1','--gpu','off','-RTS','--RTS']);
  assert.deepEqual(runtimeArguments(rts,{application:true,options:[]}),['+RTS','-RTS','--RTS']);
  assert.equal(runtimeTemplateConvention({version:1,runtimeSha256:'a'.repeat(64),...rts},'a'.repeat(64)),'bend-rts-v1');
  assert.throws(()=>runtimeTemplateConvention({version:1,runtimeSha256:'a'.repeat(64),...rts},'b'.repeat(64)),/does not bind/);
  assert.throws(()=>runtimeArgumentConvention({runtimeArgumentConvention:null}),/Unknown/);
  assert.throws(()=>runtimeArgumentConvention({runtimeArgumentConvention:'future'}),/Unknown/);
  const project=path.join(temp,'selfhost'),manifest=path.join(project,'src/compiler.json');
  fs.mkdirSync(path.dirname(manifest),{recursive:true});
  const save=value=>fs.writeFileSync(manifest,JSON.stringify(value));
  save({upstream:'a'.repeat(40),upstreamPath:'.bootstrap/upstream-phase182'});
  let selected=readBootstrapConfig({manifest,environment:{}});
  assert.equal(selected.upstream,path.join(project,'.bootstrap/upstream-phase182'));
  assert.equal(selected.revision,'a'.repeat(40));
  assert.equal(readBootstrapConfig({environment:{BEND_BOOTSTRAP_MANIFEST:manifest}}).manifest,manifest);
  assert.equal(readBootstrapConfig({manifest,environment:{BEND_UPSTREAM:temp}}).upstream,temp);
  assert.equal(readBootstrapConfig({manifest,upstream:project,environment:{BEND_UPSTREAM:temp}}).upstream,project);
  save({upstream:'b'.repeat(40)});
  selected=readBootstrapConfig({manifest,environment:{}});
  assert.equal(selected.upstream,path.join(project,'.bootstrap/upstream-phase66'));
  assert.equal(selected.revision,'b'.repeat(40),'historical manifest retains its own revision');
  save({upstream:'b'.repeat(40),upstreamPath:null});
  assert.throws(()=>readBootstrapConfig({manifest,environment:{}}),/upstreamPath/);
  save({upstream:'not-a-pin'});
  assert.throws(()=>readBootstrapConfig({manifest,environment:{}}),/revision/);

  const base=path.join(temp,'base.bend'),effects=path.join(temp,'vendored');
  fs.writeFileSync(base,'base fixture');fs.mkdirSync(effects);
  const text='exact effect fixture\n',effect=path.join(effects,'now.js');
  fs.writeFileSync(effect,text);
  const effectManifest=path.join(effects,'manifest.json');
  const binding={kind:'bend-pinned-upstream-js-effects',version:1,
    base:{sha256:sha(fs.readFileSync(base))},files:[{path:'now.js',bytes:Buffer.byteLength(text),sha256:sha(text)}]};
  const saveEffects=()=>fs.writeFileSync(effectManifest,JSON.stringify(binding));
  saveEffects();
  const original=path.join(temp,'effs/now.js'),resolver=pinnedJsEffects({base,effects});
  assert.equal(resolver.resolve(original),effect);
  assert.equal(resolver.resolve(path.join(temp,'custom/now.js')),path.join(temp,'custom/now.js'));
  assert.equal(resolver.resolve(path.join(temp,'effs/other.js')),path.join(temp,'effs/other.js'));
  fs.writeFileSync(effect,'changed');
  assert.throws(()=>resolver.resolve(original),/bytes differ/);
  fs.writeFileSync(base,'custom Base');
  assert.equal(pinnedJsEffects({base,effects}).resolve(original),original,'different Base retains its own provider');
  binding.files.push(binding.files[0]);saveEffects();
  assert.throws(()=>pinnedJsEffects({base,effects}),/inventory/);
  binding.files.pop();binding.kind='phase52-pinned-upstream-js-effects';saveEffects();
  assert.throws(()=>pinnedJsEffects({base,effects}),/inventory/,'old manifest keeps exact 35-file requirement');
  console.log('PASS bootstrap selection, pinned effect transport and runtime argv conventions');
} finally {
  fs.rmSync(temp,{recursive:true,force:true});
}
