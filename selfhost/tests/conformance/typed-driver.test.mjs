import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import test from 'node:test';
import {inspect,execute,apiPath} from '../../tools/typed-driver.mjs';
const fixture=name=>path.join(import.meta.dirname,'typed-smoke',name+'.bend');
const available=fs.existsSync(apiPath);
test('actual source is parsed, checked, normalized, emitted and executed by typed Bend API',{skip:!available},async()=>{
  const checked=await inspect(fixture('bool'));
  assert.equal(checked.status,'ok',checked.diagnostic);
  assert.equal(checked.checked,true);
  const interpreted=await inspect(fixture('bool'),{mode:'interpreter'});
  assert.equal(interpreted.stdout,'On{}\n',interpreted.diagnostic);
  const ran=await execute(fixture('base-u32'));
  assert.equal(ran.status,'ok',ran.diagnostic||ran.stderr);
  assert.equal(ran.stdout,'42\n');
});
test('well-formed source with a false result type reaches and fails the checker',{skip:!available},async()=>{
  const result=await inspect(fixture('bad-type'));
  assert.equal(result.status,'error');
  assert.equal(result.phase,'check');
  assert.equal(result.checked,true);
});
test('type-valued main is interpreted by the core normalizer',{skip:!available},async()=>{
  const result=await inspect(fixture('type-value'),{mode:'interpreter'});
  assert.equal(result.status,'ok',result.diagnostic);
  assert.equal(result.stdout,'Type\n');
});
