import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import {spawnSync} from 'node:child_process';

const runner=path.join(import.meta.dirname,'phase2-rules.mjs');
const pin='6018e28ecc67cf1fffc0c20c64b11023474c2df8';
for(const [mode,expected] of [
  ['wrong-pin',/Unexpected upstream revision wrong/],
  ['nonzero',/Upstream Git verification failed: status 9/],
  ['signal',/Upstream Git verification failed: SIGTERM/],
  ['dirty',/Upstream tracked checkout differs from pinned HEAD/],
  ['missing',/Upstream Git verification failed: spawnSync git ENOENT/],
]) test('frontend gate rejects '+mode+' upstream verification',()=>{
  const directory=fs.mkdtempSync(path.join(os.tmpdir(),'bend-frontend-git-test-'));
  const bin=path.join(directory,'bin');fs.mkdirSync(bin);
  if(mode!=='missing') {
    const script=`#!/bin/sh\nif [ "$3" = rev-parse ]; then\n  if [ "$TEST_GIT_MODE" = wrong-pin ]; then printf 'wrong\\n'; else printf '${pin}\\n'; fi\n  if [ "$TEST_GIT_MODE" = nonzero ]; then exit 9; fi\n  if [ "$TEST_GIT_MODE" = signal ]; then kill -TERM $$; fi\nelse\n  if [ "$TEST_GIT_MODE" = dirty ]; then printf ' M bend2/bend.ts\\n'; fi\nfi\n`;
    fs.writeFileSync(path.join(bin,'git'),script,{mode:0o755});
  }
  const stdout=path.join(directory,'stdout'),stderr=path.join(directory,'stderr');
  const a=fs.openSync(stdout,'wx'),b=fs.openSync(stderr,'wx');
  try {
    const result=spawnSync(process.execPath,[runner,path.join(directory,'report.json')],{
      timeout:10000,env:{...process.env,PATH:bin,TEST_GIT_MODE:mode,BEND_TYPED_API:path.join(directory,'unused-api.mjs'),BEND_UPSTREAM:directory},stdio:['ignore',a,b]});
    assert.equal(result.error,undefined);assert.equal(result.signal,null);assert.equal(result.status,1);
    assert.match(fs.readFileSync(stderr,'utf8'),expected);
    assert.equal(fs.existsSync(path.join(directory,'report.json')),false,'must stop before compiler/test execution');
  } finally {fs.closeSync(a);fs.closeSync(b);fs.rmSync(directory,{recursive:true,force:true});}
});
