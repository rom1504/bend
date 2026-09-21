// Reject malformed internal transport through the actual native decoder.
import fs from 'node:fs';import os from 'node:os';import path from 'node:path';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';
const [binaryFile,runtimeFile]=process.argv.slice(2);if(!binaryFile||!runtimeFile)throw Error('usage: native-graph-wire-native.test.mjs BINARY RUNTIME');
const binary=fs.realpathSync(binaryFile),runtime=fs.realpathSync(runtimeFile),directory=fs.mkdtempSync(path.join(os.tmpdir(),'bend-graph-wire-'));
const frame=fields=>fields.join('\0')+'\0';
const cases=['',frame(['BEND_GRAPH_2','/main','E']),frame(['BEND_GRAPH_1','relative','E']),frame(['BEND_GRAPH_1','/main','X']),frame(['BEND_GRAPH_1','/main','E','extra']),frame(['BEND_GRAPH_1','/main','S','name','/physical','/snapshot','E']),frame(['BEND_GRAPH_1','/main','A','/asset','relative','E']),frame(['BEND_GRAPH_1','/main','E']).slice(0,-1),frame(['BEND_GRAPH_1','/'+ 'x'.repeat(8193),'E'])];
try{
  for(let i=0;i<cases.length;i++){
    const wire=path.join(directory,i+'.wire'),output=path.join(directory,i+'.mjs');fs.writeFileSync(wire,cases[i]);fs.writeFileSync(output,'previous');
    const result=spawnSync(binary,['--threads','1','--gpu','off','--','--graph',wire,runtime,output,'program'],{encoding:'utf8',timeout:5000,maxBuffer:65536});
    assert.equal(result.error,undefined);assert.equal(result.status,1);assert.match(result.stderr,/phase=load checked=False:/);assert.equal(fs.readFileSync(output,'utf8'),'previous');
  }
  console.log(JSON.stringify({passed:true,checks:cases.length}));
}finally{fs.rmSync(directory,{recursive:true,force:true});}
