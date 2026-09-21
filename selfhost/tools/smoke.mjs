#!/usr/bin/env node
// End-to-end checks through the distributed Bend compiler API, no upstream.
import assert from 'node:assert/strict';
import path from 'node:path';
import {inspect,execute,project} from './typed-driver.mjs';
const source=n=>path.join(project,'tests/conformance/typed-smoke',n+'.bend');
const counts=[];
const checked=await inspect(source('base-u32'),{mode:'check'});
assert.equal(checked.status,'ok',JSON.stringify(checked));
assert.equal(checked.checked,true);counts.push('Base program checked');
const interpreted=await inspect(source('base-u32'),{mode:'interpreter'});
assert.equal(interpreted.status,'ok',JSON.stringify(interpreted));
assert.equal(interpreted.stdout.trim(),'42');counts.push('Bend normalizer returns 42');
const executed=await execute(source('base-u32'),{timeoutMs:30000});
assert.equal(executed.status,'ok',JSON.stringify(executed));
assert.equal(executed.stdout.trim(),'42');counts.push('Bend-generated JavaScript returns 42');
const rejected=await inspect(source('bad-type'),{mode:'check'});
assert.equal(rejected.status,'error',JSON.stringify(rejected));
assert.equal(rejected.phase,'check');counts.push('invalid type rejected by checker');
if(process.argv.includes('--native')){
 const native=await execute(source('base-u32'),{backend:'native',timeoutMs:30000});
 assert.equal(native.status,'ok',JSON.stringify(native));
 assert.equal(native.stdout.trim(),'42');counts.push('Bend-generated native C returns 42');
}
for(const result of counts)console.log('PASS '+result);
