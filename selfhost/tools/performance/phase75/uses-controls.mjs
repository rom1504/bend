// Finite full-width/persistent set and raw-term occurrence differential controls.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';import {createHash} from 'node:crypto';
const [apiFile,out]=process.argv.slice(2);fs.mkdirSync(out);
const text=fs.readFileSync(apiFile,'utf8'),helpers=['nu_add','nu_has','nc_uses','nc_uses_has','nc_occurs'];
for(const h of helpers)assert(text.includes('function $'+h+'$('));
const file=path.join(out,'probe.mjs');fs.writeFileSync(file,text+'\n'+helpers.map(h=>'export const '+h+'=(...args)=>run_loop($'+h+'$(...args));').join('\n'));
const A=await import(pathToFileURL(path.resolve(file)));let seed=7514,count=0;const rnd=()=>seed=(Math.imul(seed,1664525)+1013904223)>>>0;
const edge=[0,1,2,0x7fffffff,0x80000000,0xfffffffe,0xffffffff,4000000000];
for(let g=0;g<100;g++){let s={$:'NU_Empty'},keys=new Set();for(let i=0;i<64;i++){let k=i<edge.length?edge[i]:rnd();const old=s;s=A.nu_add(s,k);keys.add(k);assert.strictEqual(A.nu_add(s,k),s);assert.equal(A.nu_has(s,k),true);if(i===0)assert.equal(A.nu_has(old,k),false);for(const q of [...edge,rnd(),rnd()]){assert.equal(A.nu_has(s,q),keys.has(q));count++;}}}
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const term=(tag,id,kids=[])=>({$:'KTerm',tag,name:'',id,quant:0,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
function tree(n){if(!n)return term('Var',edge[rnd()%edge.length]);return term(rnd()%4===0?'Var':'App',rnd(),[tree(n-1),tree(n-1)]);}
for(let i=0;i<100;i++){const t=tree(4),s=A.nc_uses(t);for(const id of [...edge,t.id,rnd()]){assert.equal(A.nc_uses_has(s,id),A.nc_occurs(t,id));count++;}}
const pin=p=>({file:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:true,pass:true,count,inputs:[pin(apiFile),pin(import.meta.filename),pin(file)],scope:'U32 edge/random keys against JS Set, duplicate insert identity, prior empty-set persistence, and100 raw term graphs against retained nc_occurs including malformed Var children.'},null,2)+'\n');console.log(JSON.stringify({pass:true,count}));
