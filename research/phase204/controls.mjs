import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import assert from 'node:assert/strict';
const root=process.argv[2];
const load=async role=>(await import(pathToFileURL(path.join(root,role,'api.mjs')))).default;
const old=await load('old'), fresh=await load('new');
const node=($,fields={})=>({$,...fields});
const xs=a=>a.reduceRight((tail,head)=>node('Con',{head,tail}),node('Nil'));
const nil=xs([]),word=node('N111U64'),narrow=node('N111U32');
const names=['a','b','c','d','e','λ','f','z'];
const local=name=>node('N111Local',{name});
const constant=i=>node('N111Const',{lo:i,hi:0});
const set=(name,value,typ=word)=>node('N111Set',{name,value,typ});
const scalar=stmt=>node('P113DScalar',{stmt});
const exit=(tag,values)=>node(tag,{values:xs(values)});
const branch=(yes,no)=>node('P113DIf',{condition:local('b'),yes:xs(yes),no:xs(no)});
function random(seed){
 let state=seed>>>0;return n=>{state=(Math.imul(state,1664525)+1013904223)>>>0;return (state>>>8)%n;};
}
let reads=0,graphs=0,nonzero=0,backedges=0;
for(let seed=0;seed<128;seed++){
 const rnd=random(seed+229), n=1+rnd(8), map=names.slice(0,n);
 let ids=old.missing(), writes=old.missing(),newWrites=fresh.missing();
 for(let i=0;i<n;i++)ids=old.p111v_put(ids,map[i],'X190LBit',(seed%8===0&&i===n-1)?0x80000000:2**i,0);
 for(let i=0;i<18;i++){
   const name=names[rnd(8)];writes=old.x185_copy_write(name,writes);newWrites=fresh.x185_copy_write(name,newWrites);
   assert.equal(old.x190_l_bit(name,ids),fresh.x190_l_bit(name,ids));reads++;
 }
 assert.deepEqual(writes,newWrites);
 const pick=()=>names[rnd(8)], value=()=>rnd(4)===0?constant(rnd(9)):local(pick());
 function body(depth){
   return Array.from({length:rnd(depth===2?9:5)},()=>{
     switch(rnd(depth?9:6)){
       case 0:return scalar(set(pick(),value(),narrow));
       case 1:return exit('P113DResult',[value(),value()]);
       case 2:return exit('P113DAgain',[value(),value()]);
       case 3:return node('P113DCall',{destinations:xs([pick()]),target:'callee',args:xs([value(),value()])});
       case 4:return scalar(node('N111Set',{name:pick(),typ:word,value:value()}));
       case 5:return scalar(node('N111If',{condition:value(),yes:xs([set(pick(),value())]),no:xs([set(pick(),value(),narrow)])}));
       default:return branch(body(depth-1),body(depth-1));
     }
   });
 }
 const setup=xs(body(1)),code=xs(body(2)),params=xs(map.slice(0,2));
 assert.deepEqual(old.x185_copy_function(params,setup,code),fresh.x185_copy_function(params,setup,code));
 const baselineReads=old.x191_joint_reads(setup,code,params), trialReads=fresh.x191_joint_reads(setup,code,params);
 assert.deepEqual(baselineReads.reversedNames,trialReads.reversedNames);
 for(const k of names)assert.deepEqual(old.p111v_get(baselineReads.counts,k),fresh.p111v_get(trialReads.counts,k));
 const parameters=(rnd(512) | (seed%3===0?0x80000000:0))>>>0;
 const expected=old.x190_l_fixed(code,ids,parameters,0,33), selected=fresh.x204_for_collection(setup,code,ids,parameters);
 assert.equal(expected.ready,true);assert.equal(selected.ready,true);
 const has=fresh.x190_register_loop(setup)||fresh.x190_register_loop(code);
 if(has){assert.equal(selected.header,expected.header);backedges++;}
 const measure=(api,header)=>{
   const env=node('X190LEnv',{ids,parameters,header,collect:true});
   const start=node('X190LFlow',{live:0,graph:xs(Array(32).fill(0))});
   return api.x190_l_body(setup,api.x190_l_body(code,start,env),env);
 };
 assert.deepEqual(measure(old,expected.header),measure(fresh,selected.header));graphs++;
 if(expected.header!==0)nonzero++;
}
fs.writeFileSync(path.join(root,'checks.json'),JSON.stringify({graphs,nonzero,backedges,reads,copyBodies:graphs,method:'deterministic structural comparisons of both checked implementations'},null,2)+'\n');
