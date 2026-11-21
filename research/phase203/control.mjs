import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {verify} from '../../selfhost/tools/build/hosted.mjs';
const [dir,out] = process.argv.slice(2);
const receipt=JSON.parse(fs.readFileSync(path.join(dir,'report.json')));
assert(receipt.complete && receipt.checked);
verify(receipt.api); verify(receipt.source);
const api=(await import(pathToFileURL(receipt.api.file))).default;
const list = xs => xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function items(node) {
  const result=[];
  while(node.$==='Con'){result.push(node.head);node=node.tail;}
  assert.equal(node.$,'Nil');return result;
}
let checks=0,selected=0;
for(const n of [0,1,4,31,32,33,64,128]){
  for(const style of ['tie','ascending','descending','mixed','none']){
    let counts=api.missing(), slots=api.missing();
    const rows=Array.from({length:n},(_,i)=>{
      const score=style==='tie'?1:style==='ascending'?i:style==='descending'?n-i:style==='none'?0:i%13===0?0xffffffff:(7*i)%17;
      const name=i%7===0?'λ'+i:'v_'+i;
      const available=style!=='mixed'||i%5>1;
      counts=api.p111v_put(counts,name,'X181Reads',score,0);
      if(available||i%5===1) slots=api.p111v_put(slots,name,available?'X181Stack':'X181Register',0,0);
      return {name,score,i,available};
    });
    const names=list(rows.map(row=>row.name));
    const expected=rows.filter(row=>row.available&&row.score>0).sort((a,b)=>b.score-a.score||a.i-b.i).slice(0,32).map(row=>row.name);
    const old=api.x190_l_candidates(names,counts,slots,1,32,api.missing(),list([]));
    const candidate=api.x203_candidates(names,counts,slots);
    assert.deepStrictEqual(items(candidate.names),expected);
    assert.deepStrictEqual(old,candidate);
    for(let i=0;i<expected.length;i++)assert.equal(api.da(api.p111v_get(candidate.ids,expected[i]))>>>0,2**i);
    checks++;selected+=expected.length;
  }
}
fs.writeFileSync(out,JSON.stringify({complete:true,checks,selected,expected:'stable descending score, eligible stack slots, maximum 32',source:receipt.source,api:receipt.api},null,2)+'\n');
