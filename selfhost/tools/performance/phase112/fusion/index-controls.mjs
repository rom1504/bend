// Coordinator-only finite controls for the actual typed Bend index.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('API FRESH_OUTPUT');
const api=(await import(pathToFileURL(path.resolve(apiFile)).href)).default;
fs.mkdirSync(outDir);
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const segment=(name,arity)=>({$:'N111Segment',name,arity,result:1,incoming:1,flags:0,body:{$:'Nil'}});
const names=['','state','$p111.k.0','$p111.k.1','α','😀','α😀',
  ...Array.from({length:64},(_,i)=>'$p111.k.'+(i*65537+17))];
const originals=names.map((name,i)=>segment(name,i));
const orders=[originals,[...originals].reverse(),[...originals.filter((_,i)=>i%2),...originals.filter((_,i)=>!(i%2))]];
const rows=[];
for(const [order,segments] of orders.entries()){
  const tree=api.p112f_index(list(segments));
  for(const name of [...names,'not present','$p111.k.2','α😁']){
    const expected=segments.find(x=>x.name===name);
    assert.deepEqual(api.p112f_index_get(tree,name),expected?{$:'Some',value:expected}:{$:'None'},'complete segment lookup');
    rows.push({order,name,present:!!expected});
  }
}
// Preserve the former linear lookup's first-definition selection even though
// duplicate program symbols are separately refused by the original verifier.
const first=segment('duplicate',3),later=segment('duplicate',99);
const duplicate=api.p112f_index(list([first,...originals,later]));
assert.deepEqual(api.p112f_index_get(duplicate,'duplicate'),{$:'Some',value:first});
// Force equal hash words through the internal typed insertion interface. This
// isolates exact-name collision behavior without pretending names were hashed.
const a=segment('collision-a',4),b=segment('collision-b',8);
let collision={$:'P112FusionEmpty'};
for(const value of [a,b,{...a,arity:99}])collision=api.p112f_index_insert(collision,value,17,0);
assert.deepEqual(api.p112f_index_find(collision,'collision-a',17),{$:'Some',value:a});
assert.deepEqual(api.p112f_index_find(collision,'collision-b',17),{$:'Some',value:b});
assert.deepEqual(api.p112f_index_find(collision,'collision-c',17),{$:'None'});
assert.deepEqual(api.p112f_index_find(collision,'collision-a',18),{$:'None'});
assert.deepEqual(api.p112f_index_get({$:'P112FusionEmpty'},'missing'),{$:'None'});
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-fusion-typed-index-controls',complete:true,
  lookups:rows,duplicateFirst:true,forcedHashCollision:true,hashMismatch:true,emptyMiss:true,
  targetsExecuted:false,scope:'Finite helper checks; forged-hash cases test exact-name buckets, not the hash function.'},null,2)+'\n');
console.log(JSON.stringify({complete:true,lookups:rows.length,additional:6}));
