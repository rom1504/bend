import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {decode,pin,verify} from './baseline.mjs';

test('request clock extraction preserves the complete diagnostic',()=>{
  const diagnostic='ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n\n';
  assert.deepEqual(decode('base_prepare_ms=12\nruntime_prepare_ms=2\nrequest=1 request_ms=47 consumed_chars=99\n'+diagnostic),
    {requestMs:47,diagnostic});
  for(const invalid of [diagnostic,'request=1 request_ms=no consumed_chars=99\n',
    'request=2 request_ms=1 consumed_chars=2\n',
    'request=1 request_ms=1 consumed_chars=2\nrequest=2 request_ms=1 consumed_chars=2\n'])
    assert.throws(()=>decode(invalid));
});

test('artifact verification refuses changed bytes, size, missing files',()=>{
  const directory=fs.mkdtempSync(path.join(os.tmpdir(),'bend-phase104-controls-'));
  const file=path.join(directory,'artifact');
  try {
    fs.writeFileSync(file,'abc');const identity=pin(file);verify(identity);
    fs.writeFileSync(file,'abd');assert.throws(()=>verify(identity));
    fs.writeFileSync(file,'abcd');assert.throws(()=>verify(identity));
    fs.unlinkSync(file);assert.throws(()=>verify(identity));
  } finally {fs.rmSync(directory,{recursive:true,force:true});}
});
