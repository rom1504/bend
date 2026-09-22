import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {nodeResourceArgs} from '../tools/node-resource-args.mjs';

assert.deepEqual(nodeResourceArgs([]),[]);
assert.deepEqual(nodeResourceArgs(['--eval','throw Error("must not forward")','--inspect',
  '--stack_size','4096','--max-old-space-size=2048','--stack-size=1024']),
  ['--stack-size=1024','--max-old-space-size=2048']);
for(const args of [['--stack-size'],['--stack-size=0'],['--stack-size=1.5'],
  ['--max-old-space-size=NaN'],['--stack-size=9007199254740992']])
  assert.throws(()=>nodeResourceArgs(args),/Invalid Node resource limit/);

// Observe the actual child arguments, including when parent flags use V8's
// underscore spelling, without inheriting the parent's --input-type or -e.
const code=`import {nodeResourceArgs} from ${JSON.stringify(new URL('../tools/node-resource-args.mjs',import.meta.url).href)};
import {spawnSync} from 'node:child_process';
const r=spawnSync(process.execPath,[...nodeResourceArgs(),'-p','JSON.stringify(process.execArgv.slice(0,2))'],{encoding:'utf8'});
if(r.status!==0)throw Error(r.stderr);process.stdout.write(r.stdout);`;
const child=spawnSync(process.execPath,['--stack_size=2048','--max_old_space_size=512','--input-type=module','-e',code],{encoding:'utf8',timeout:10000});
assert.equal(child.status,0,child.stderr);
assert.deepEqual(JSON.parse(child.stdout),['--stack-size=2048','--max-old-space-size=512']);
console.log('Node resource limits propagate without execution options.');
