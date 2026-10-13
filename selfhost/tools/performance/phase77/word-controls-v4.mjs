// Checked-image helper exposure; no algorithm changes. Compare coverage rows to
// a separate interpreter of the expanded matcher on native word constructors.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';import {createHash} from 'node:crypto';
const [apiFile,bodyFile,out]=process.argv.slice(2);fs.mkdirSync(out);
const text=fs.readFileSync(apiFile,'utf8'),names=['nw_walk','nw_same','nw_prepare','ns_static_term','nq_uses','nq_min_uses','nw_prefix','nw_restore'];
for(const h of names)assert(text.includes('function $'+h+'$('));
const exposed=path.join(out,'api.mjs');fs.writeFileSync(exposed,text+'\n'+names.map(h=>'export const '+h+'=(...a)=>run_loop($'+h+'$(...a));').join('\n'));
const A=await import(pathToFileURL(path.resolve(exposed)));
const nil={$:'Nil'},list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),nil),array=x=>{const a=[];while(x.$==='Con'){a.push(x.head);x=x.tail;}return a;};
const term=(tag,name='',id=0,kids=[],quant=0)=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:nil,originBegin:0,originEnd:0});
const kids=t=>array(t.kids??nil),tag=t=>t.$==='KLambda'?'Lam':t.tag;
const body=JSON.parse(fs.readFileSync(bodyFile));const word=k=>{let w={$:'WNil'};for(let i=31;i>=0;i--)w={$:'WCon',fields:[{$:(k>>>i)&1?'True':'False'},w]};return w;};
function val(t,e=new Map()){const ts=kids(t),k=tag(t);if(k==='Lam')return x=>val(ts[0],new Map([...e,[t.id,x]]));if(k==='Var'){assert(e.has(t.id),'unbound '+t.id);return e.get(t.id);}if(k==='Mat')return x=>x.$===t.name?x.fields?.reduce((f,a)=>f(a),val(ts[0],e))??val(ts[0],e):val(ts[1],e)(x);if(k==='NWord')return {$:t.name==='0'?'False':'True'};if(k==='Ctr')return {$:t.name,fields:ts.map(x=>val(x,e))};if(k==='Ref')return t.name==='Nat.read.trim'?x=>({recursive:x}):(()=>{throw Error(t.name)})();if(k==='App')return val(ts[0],e)(val(ts[1],e));throw Error('interpreter '+k);}
const u32=kids(kids(body)[0])[0],tree=kids(u32)[0];assert.equal(u32.name,'U32');
const result=A.nw_walk(tree,0,0,{$:'NW_None'});assert(result.valid);const rows=array(result.rows);assert.equal(rows.length,2,'One literal and one inherited default');
const tail={$:'TailInput'},render=x=>JSON.stringify(x);
const checks=[0,1,47,48,49,255,256,0x7fffffff,0x80000000,0xffffffff];for(let i=0;i<32;i++)checks.push((48^(2**i))>>>0);
let seed=7611;for(let i=0;i<1000;i++){seed=(Math.imul(seed,1664525)+1013904223)>>>0;checks.push(seed);}
for(const x of checks){const r=rows.find(r=>r.id===32?x===Number(r.name):((x&(2**r.id-1))>>>0)===Number(r.name));assert(r);let out=val(kids(r)[0]);let w=word(x);for(let i=0;i<r.id;i++)w=w.fields[1];if(r.quant===1)out=out(w);if(r.quant===2)out=out(w.fields[0])(w.fields[1]);out=out(tail);assert.equal(render(out),render(val(tree)(word(x))(tail)));}
// Alpha-equivalence must distinguish free values and changed result structure.
const v=i=>term('Var','',i),lam=(i,t)=>term('Lam','',i,[t],1);
assert(A.nw_same(lam(1,v(1)),lam(2,v(2)),nil));assert(!A.nw_same(lam(1,v(1)),lam(2,v(3)),nil));assert(!A.nw_same(lam(1,term('Ctr','A',0,[v(1)])),lam(2,term('Ctr','B',0,[v(2)])),nil));
assert(!A.nw_same(lam(1,v(2)),lam(2,v(2)),nil),'Free variable must not equal bound variable');
assert(!A.nw_same(lam(1,lam(2,v(1))),lam(3,lam(4,v(4))),nil),'Nested binders must retain identity');
// Independently generated prefix matchers, including retained word tails and
// reconstructed inherited defaults. Cover every depth, not only one library AST.
let generated=0;
const wcon=(h,t)=>term('Ctr','WCon',0,[h,t],1), bit=b=>term('NWord',String(b));
const mat=(name,id,hit,miss=term('Efq'))=>term('Mat',name,id,[hit,miss]);
function prefixTree(depth,wanted,distinct=false){
 function build(at,low){
  if(at===depth)return at===32?mat('WNil',1,term('Ctr','Hit')):lam(700+at,term('Ctr','Hit',0,[v(700+at)]));
  const h=800+at*2,t=h+1;let rebuilt=wcon(v(h),v(t));
  for(let i=at-1;i>=0;i--)rebuilt=wcon(bit((low>>>i)&1),rebuilt);
  const fallback=lam(h,lam(t,term('Ctr',distinct?'Default'+at:'Default',0,[rebuilt])));
  const b=(wanted>>>at)&1;
  return mat('WCon',3,mat(b?'True':'False',1,build(at+1,(low|(b*2**at))>>>0),fallback));
 }
 return build(0,0);
}
const words=checks.slice(0,74).concat(checks.slice(-60),[0x96c3a57e],Array.from({length:32},(_,i)=>(0x96c3a57e^(2**i))>>>0));
for(let depth=0;depth<=32;depth++)for(const distinct of [false,true]){
 const tree=prefixTree(depth,0x96c3a57e,distinct),r=A.nw_walk(tree,0,0,{$:'NW_None'});assert(r.valid);
 const rs=array(r.rows),prepared=A.nw_prepare(mat('U32',2,tree));assert.equal(tag(prepared),'NWPattern');assert.deepEqual(array(prepared.kids),rs);
 for(const x of words){const row=rs.find(r=>r.id===32?x===Number(r.name):((x&(2**r.id-1))>>>0)===Number(r.name));assert(row);
  let out=val(kids(row)[0]),w=word(x);for(let i=0;i<row.id;i++)w=w.fields[1];
  if(row.quant===1)out=out(w);if(row.quant===2)out=out(w.fields[0])(w.fields[1]);
  assert.equal(render(out),render(val(tree)(word(x))),`depth ${depth}, distinct ${distinct}, word ${x}`);generated++;
 }
}
const forged=term('NWPattern','U32',2,[term('NWRow','0',0,[v(99)],1)]);
assert.equal(tag(A.ns_static_term(term('Absent'),forged,{$:'NS_Image',size:0,words:nil,index:{$:'KDef'}}).term),'NativeStaticInput');
const malformed=mat('U32',2,term('Ctr','Wrong'));assert.deepEqual(A.nw_prepare(malformed),malformed);
const alternatives=term('NWPattern','U32',2,[term('NWRow','0',1,[v(99)],0),term('NWRow','1',1,[v(99)],0)]);
assert.equal(A.nq_uses(alternatives,99),1);assert.equal(A.nq_min_uses(alternatives,99),0);
// Reconstruction folding is valid only under the row's bit constraints.
let restoredChecks=0;
function nativeValue(x){
 if(x?.$==='U32'||x?.$==='F32'){let n=0,i=0,w=x.fields[0];while(w.$==='WCon'){if(w.fields[0].$==='True')n=(n+2**i)>>>0;i++;w=w.fields[1];}assert.equal(i,32);return n;}
 if(x?.fields)return {...x,fields:x.fields.map(nativeValue)};
 return x;
}
for(let depth=0;depth<32;depth++)for(const fields of [1,2]){
 const value=(0x96c3a57e&(2**depth-1))>>>0;
 const h=91001,t=91002,subject=91003;
 const remaining=fields===1?v(t):wcon(v(h),v(t));
 const expected=A.nw_prefix(depth,value,remaining);
 for(const wrapper of ['U32','F32']){
  const scalar=term('Ctr',wrapper,0,[expected]);const folded=A.nw_restore(scalar,expected,subject);assert.equal(tag(folded),'Var');assert.equal(folded.id,subject);
  const preserve=term('Ctr','$ctor.U32',0,[expected]);assert.deepEqual(A.nw_restore(preserve,expected,subject),preserve);
  const escaped=term('Ctr','Result',0,[scalar,v(t)]),rewritten=A.nw_restore(escaped,expected,subject);
  for(const sample of words.slice(-33)){
   const mask=2**depth-1,x=((sample&~mask)|value)>>>0;let tail=word(x);for(let i=0;i<depth;i++)tail=tail.fields[1];
   const e=new Map([[t,fields===1?tail:tail.fields[1]],[h,tail.fields[0]],[subject,{$:'U32',fields:[word(x)]}]]);
   assert.deepEqual(nativeValue(val(scalar,e)),nativeValue(val(folded,e)));
   assert.deepEqual(nativeValue(val(escaped,e)),nativeValue(val(rewritten,e)));restoredChecks+=2;
  }
 }
}
const pin=p=>({file:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const report={complete:true,pass:true,comparisons:checks.length+5+generated+4+restoredChecks,restoredChecks,generatedPrefixComparisons:generated,rows:rows.map(r=>({bits:r.id,value:r.name,fields:r.quant})),inputs:[apiFile,bodyFile,import.meta.filename,exposed].map(pin),scope:'All scalar prefix depths with common/distinct captured defaults, private-input refusal and branch uses; one captured expanded scalar matcher against an independent constructor interpreter, 32 bit-flip boundaries and deterministic random words; finite prototype gate, not full pattern coverage.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({...report,inputs:undefined}));
