import test from 'node:test';import assert from 'node:assert/strict';
import {semanticRow,compareHostRows} from './base-memo-frontend.mjs';
const oldHost={driverSha256:'old-driver',adapterSha256:'old-adapter'},newHost={driverSha256:'new-driver',adapterSha256:'new-adapter'};
const row=host=>({id:'negative',lane:'check',negative:true,status:'fail',reason:'Exact diagnostic mismatch',result:{status:'error',phase:'parse',checked:false,diagnostic:'the exact original error',hostProvenance:host}});
test('only explicitly verified host provenance may differ',()=>{
 assert.deepEqual(compareHostRows([row(oldHost)],[row(newHost)],oldHost,newHost),[]);
 assert.throws(()=>semanticRow(row({...newHost,extra:'unreviewed'}),newHost));
 assert.throws(()=>semanticRow({...row(newHost),result:{...row(newHost).result,hostProvenance:undefined}},newHost));
 assert.throws(()=>compareHostRows([row(oldHost)],[row(oldHost)],oldHost,newHost));
 assert.throws(()=>semanticRow(row({...newHost,extra:1}),{...newHost,extra:1}));
});
test('diagnostic, phase, checked status, oracle, added field and inventory drift stay failures',()=>{
 for(const change of [{diagnostic:'different reason'},{phase:'check'},{checked:true},{output:'new output'},{extra:'not provenance'}]){
  const changed=row(newHost);Object.assign(changed.result,change);assert.equal(compareHostRows([row(oldHost)],[changed],oldHost,newHost).length,1);
 }
 for(const field of ['status','reason','evidence','negative','namespace']){const changed=row(newHost);changed[field]='changed';assert.equal(compareHostRows([row(oldHost)],[changed],oldHost,newHost).length,1);}
 assert.throws(()=>compareHostRows([row(oldHost)],[],oldHost,newHost));
 assert.throws(()=>compareHostRows([row(oldHost),row(oldHost)],[row(newHost),row(newHost)],oldHost,newHost));
});
