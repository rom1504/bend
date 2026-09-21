// Resource probe for a self-hosted compiler, using the ordinary host ABI.
// Run with the documented self-host configuration:
// BEND_SELFHOST_API=/absolute/stage2.mjs node --stack-size=4096 tests/selfhost-stack.mjs
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
const apiPath=path.resolve(process.env.BEND_SELFHOST_API||path.join(import.meta.dirname,'../dist/selfhost/release/stage2.mjs'));
process.env.BEND_TYPED_API=apiPath;
const {loadApi}=await import('../tools/typed-driver.mjs');
const api=await loadApi();
const nil={$:'Nil'},cons=(head,tail)=>({$:'Con',head,tail});
const term=tag=>({$:'KTerm',tag,name:'',id:0,quant:0,kids:nil,removed:nil});
const def=(name,kind='Def',ctors=nil)=>({$:'KDef',name,kind,arity:0,templates:0,typ:term('Typ'),value:term('Absent'),ctors,native:false,unsafe:false});
const results=[];
for(const count of [1859,3000,5000]){
 let book=nil;for(let i=0;i<count;i++)book=cons(def('d'+i),book);
 let mixed=nil;for(let i=0;i<count;i++)mixed=cons({...def('m'+i),native:i%3===0,value:term(i%3===2?'Typ':'Absent')},mixed);
 let tail=cons(def('Family','ADT',cons(def('Target','Ctr'),nil)),nil);
 for(let i=1;i<count;i++)tail=cons(def('d'+i),tail);
 for(const [name,args,expected] of [
  ['count_open',[book],count],
  ['count_open mixed native/filled/open',[mixed],Math.floor((count+1)/3)],
  ['constructor_exists absent',[book,'Missing'],false],
  ['constructor_exists at end',[tail,'Target'],true],
  ['driver_owned_name absent',[book,'Clo.apply'],false],
 ]){
  const start=performance.now();try{
   const result=api[name.split(' ')[0]](...args);assert.equal(result,expected);
   results.push({count,name,pass:true,result,milliseconds:performance.now()-start});
  }catch(error){results.push({count,name,pass:false,error:String(error),milliseconds:performance.now()-start});}
 }
}
const report={node:process.version,execArgv:process.execArgv,api:apiPath,apiSha256:crypto.createHash('sha256').update(fs.readFileSync(apiPath)).digest('hex'),pass:results.every(r=>r.pass),results};
console.log(JSON.stringify(report,null,2));
if(!report.pass)process.exitCode=1;
