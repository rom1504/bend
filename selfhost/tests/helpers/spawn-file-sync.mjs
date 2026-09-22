import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';

// Test subprocess capture must not depend on pipe delivery by the supervisor.
// Preserve ordinary nonzero exits for each test's own oracle; spawning failures
// and signals are infrastructure failures, even if a status was also supplied.
export function spawnFileSync(command,args,options={}) {
  const directory=fs.mkdtempSync(path.join(os.tmpdir(),'bend-test-capture-'));
  const stdout=path.join(directory,'stdout'),stderr=path.join(directory,'stderr');
  const a=fs.openSync(stdout,'wx'),b=fs.openSync(stderr,'wx');
  try {
    const result=spawnSync(command,args,{...options,stdio:['ignore',a,b]});
    const encoding=options.encoding??null;
    const captured={...result,stdout:fs.readFileSync(stdout,encoding),stderr:fs.readFileSync(stderr,encoding)};
    if(result.error)throw result.error;
    if(result.signal)throw Error('Test subprocess ended with '+result.signal+': '+captured.stderr);
    return captured;
  } finally {
    fs.closeSync(a);fs.closeSync(b);fs.rmSync(directory,{recursive:true,force:true});
  }
}
