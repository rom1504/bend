// Independent generated-tree comparison of compiled Bend summary and old query.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [attemptFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const hash=b=>createHash('sha256').update(b).digest('hex');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,sha256:hash(b),bytes:b.length}};
const attempt=JSON.parse(fs.readFileSync(attemptFile,'utf8'));assert(attempt.checked);const before=pin(attempt.api.file);assert.equal(before.sha256,attempt.api.sha256);
let source=fs.readFileSync(attempt.api.file,'utf8');for(const n of ['nq_counts','nq_uses','nq_count_get'])assert.equal(source.split('function $'+n+'$(').length,2);
source+='\nexport const phase80Occurrence={counts:t=>run_loop($nq_counts$(t)),old:(t,i)=>run_loop($nq_uses$(t,i)),get:(m,i)=>run_loop($nq_count_get$(m,i))};\n';
const file=path.join(out,'controls.mjs');fs.writeFileSync(file,source,{flag:'wx'});
const {phase80Occurrence:F}=await import(pathToFileURL(file));
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
const node=(tag,id=0,kids=[])=>({$:'KTerm',tag,name:'',id,quant:0,kids:list(kids),removed:nil,originBegin:0,originEnd:0});
let seed=0x80c011a;const random=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
const ids=[0,1,2,3,4,5,6,7,8,9,10,11,4294967295];
function tree(depth){if(depth===0||random(4)===0)return random(3)?node('Var',ids[random(ids.length)]):node('NWord');const tags=['App','Ctr','Lam','Mat','NSeqLet','NWPattern','Var'];const tag=tags[random(tags.length)],arity=random(4),kids=Array.from({length:arity},()=>tree(depth-1));return node(tag,ids[random(ids.length)],tag==='NWPattern'?kids.map(k=>node('NWRow',0,[k,node('Var',11)])):kids);}
const cases=[node('Var',1,[node('Var',2)]),node('Mat',0,[node('Var',1),node('Var',1)]),node('App',0,[node('Var',1),node('Var',1),node('Var',1)]),node('Mat',0,[node('Var',1),node('Var',1),node('Var',1)]),node('NWPattern',0,[node('NWRow',0,[node('Var',1),node('Var',2)]),node('NWRow',0,[node('Var',1)])]),node('NWPattern',0,[node('NWRow')])];
for(let i=0;i<1200;i++)cases.push(tree(6));
let observations=0;for(let n=0;n<cases.length;n++){const t=cases[n],counts=F.counts(t);for(const id of ids){assert.equal(F.get(counts,id),F.old(t,id),`case ${n}, binder ${id}`);observations++;}}
assert.deepEqual(pin(attempt.api.file),before);
const report={complete:true,pass:true,scope:'Generated finite raw-term trees, comparing two compiled Bend implementations. Not a proof or clean timing. Deterministic seed 0x80c011a; branches, saturated sums, NWPattern row bodies, malformed Vars/Mat arities and U32 boundary IDs.',attempt:pin(attemptFile),sourceApi:before,derivative:pin(file),method:pin(import.meta.filename),cases:cases.length,observations};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:true,pass:true,cases:cases.length,observations}));
