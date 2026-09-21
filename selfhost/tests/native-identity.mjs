// Constructor identity is a compiler namespace, separate from display names.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const {default:N}=await import(process.env.BEND_NATIVE_IDENTITY_API||'../build/native-identity.mjs');
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
const term=(tag,name='')=>({$:'KTerm',tag,name,id:0,quant:0,kids:nil,removed:nil});
const def=(name,kind,native=false,ctors=[])=>({$:'KDef',name,kind,arity:0,templates:0,typ:term('Typ'),value:term('Absent'),ctors:list(ctors),native,unsafe:false});
const family=(name,native,constructors,ctorNative=!native)=>def(name,'ADT',native,constructors.map(n=>def(n,'Ctr',ctorNative)));
const macro=n=>'CID_'+n.replace(/[^A-Za-z0-9_]/g,'_').toUpperCase();
const reserved=['Zero','Succ','True','False','U32','F32','Chr','ALeaf','ANode','Emit','Halt','Tuple','SNil','SCon','WNil','WCon','Done','Fail','Some','None','Unit','LT','EQ','GT','ARITY_T','HOT_T'];
const spellings=[...new Set([...reserved,...reserved.map(n=>n.toLowerCase()),...reserved.map(n=>n[0]+n.slice(1).toLowerCase()),'A.B','A_B','a.b','_ctor_65_','λ','😀','Ord.Lt','Ord.LT'])];
const custom=list([family('Custom',false,spellings,true)]);
const native=list([family('FromBase',true,reserved,false)]);
const ids=spellings.map(n=>N.nc_ctor_identity(custom,n));
assert.equal(new Set(ids.map(macro)).size,spellings.length,'case and punctuation remain injective in emitted C identifiers');
for(let i=0;i<spellings.length;i++){
 const name=spellings[i],id=ids[i];
 assert.equal(id,N.nc_ctor_encode(name));assert.equal(N.nc_ctor_display(id),name,'display '+name);
 assert.equal(N.nc_ctor_owned(custom,name),false,'constructor flag is not ownership');
 assert.ok(!reserved.map(macro).includes(macro(id)),'no runtime table/constructor macro collision');
}
for(const name of reserved){assert.equal(N.nc_ctor_identity(native,name),name);assert.equal(N.nc_ctor_owned(native,name),true,'parent provenance grants ABI, ctor flag irrelevant');}
assert.equal(N.nc_ctor_owned(list([def('Pretend','Def',true,[def('True','Ctr',true)])]),'True'),false,'only ADT parent can grant provenance');
assert.equal(N.nc_ctor_identity(nil,'True'),N.nc_ctor_encode('True'),'missing parent fails closed');
assert.equal(N.nc_ctor_identity(N.book_cached(custom,0),'LT'),N.nc_ctor_encode('LT'),'indexed book handles cache without trusting it as provenance');
assert.equal(N.nc_ctor_identity(N.book_cached(native,0),'LT'),'LT');
for(const invalid of ['$ctor.65','$ctor.065_','$ctor.1114112_','$ctor.55296_','$ctor.4294967296_','$ctor._','$ctor.a_','$ctor.65__','Ord.Lt','LT'])assert.equal(N.nc_ctor_display(invalid),invalid,'malformed or ordinary name remains unchanged');
console.log(`PASS ${spellings.length} distinct constructor identities, ${reserved.length} reserved aliases, parent provenance, indexed books, Unicode and malformed encodings`);
// The oracle must accept ordinary constructors bearing primitive names and
// fields. No Base import is present and no primitive layout is inferred.
if(process.env.BEND_UPSTREAM){
 const U=await import(pathToFileURL(path.join(process.env.BEND_UPSTREAM,'bend2/bend.ts')));
 const dir=fs.mkdtempSync(path.join(os.tmpdir(),'bend-ctor-identity-'));
 try{
  for(const [names,value] of [[['Zero','Succ','True','False','U32','F32','Chr','ALeaf','ANode','Emit','Halt'],'Zero'],[['LT','Lt','lt','EQ','Eq','GT','Gt'],'Lt']]){
   const source='type Leaf is Data:\n  Leaf{}\ntype Custom is Data:\n'+names.map(n=>'  '+n+'{x: Leaf}\n').join('')+'\ndef main() -> Custom:\n  '+value+'{Leaf{}}\n';
   const file=path.join(dir,'case.bend');fs.writeFileSync(file,source);
   const book=U.book_nil();await U.book_load(book,file,'',new Map());U.book_valid(book);
   assert.equal(Boolean(book.tlds.Custom.b),false);assert.equal(book.tlds.Custom.$,'ADT');
  }
  console.log('PASS pinned upstream accepts primitive-spelling and case-colliding custom constructors with fields, without Base');
 }finally{fs.rmSync(dir,{recursive:true,force:true});}
}
