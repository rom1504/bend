// Checked-image helper exposure; no algorithm changes. Compare coverage rows to
// a separate interpreter of the expanded matcher on native word constructors.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';import {createHash} from 'node:crypto';
const [apiFile,bodyFile,out]=process.argv.slice(2);fs.mkdirSync(out);
const text=fs.readFileSync(apiFile,'utf8'),names=['nw_walk','nw_same'];
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
const pin=p=>({file:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const report={complete:true,pass:true,comparisons:checks.length+3,rows:rows.map(r=>({bits:r.id,value:r.name,fields:r.quant})),inputs:[apiFile,bodyFile,import.meta.filename,exposed].map(pin),scope:'One captured expanded scalar matcher against an independent constructor interpreter, 32 bit-flip boundaries and deterministic random words; finite prototype gate, not full pattern coverage.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({...report,inputs:undefined}));
