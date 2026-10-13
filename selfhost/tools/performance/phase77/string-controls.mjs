import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';import {createHash} from 'node:crypto';
const [original,candidate,out]=process.argv.slice(2);fs.mkdirSync(out);
const names=['String_46_starts_95_with','String_46_contains','String_46_reverse','String_46_is_95_empty'];
async function expose(file,label){const text=fs.readFileSync(file,'utf8');const p=path.join(out,label+'.mjs');fs.writeFileSync(p,text+'\nexport const controls={'+names.map(n=>n+':$jd$'+n).join(',')+'};\n');return (await import(pathToFileURL(path.resolve(p)))).controls;}
const A=await expose(original,'original'),B=await expose(candidate,'candidate');
let strings=[''];const alphabet=['a','b','\ud800','\udc00','🙂','\0'];
for(let len=1;len<=3;len++){const prev=strings.filter(x=>[...x].length===len-1);for(const x of prev)for(const y of alphabet)strings.push(x+y);}
strings=[...new Set(strings)];let count=0;
const prefix=(s,p)=>{s=[...s];p=[...p];return p.length<=s.length&&p.every((x,i)=>x===s[i]);};
const contains=(s,p)=>{const a=[...s];for(let i=0;i<=a.length;i++)if(prefix(a.slice(i).join(''),p))return true;return false;};
for(const s of strings){for(const p of strings){for(const [name,oracle] of [['String_46_starts_95_with',prefix],['String_46_contains',contains]]){const expected=oracle(s,p);assert.equal(A[name](s,p),expected);assert.equal(B[name](s,p),expected);count++;}}
for(const [name,expected] of [['String_46_reverse',[...s].reverse().join('')],['String_46_is_95_empty',s==='']]){assert.equal(A[name](s),expected);assert.equal(B[name](s),expected);count++;}}
const pin=f=>({file:path.resolve(f),sha256:createHash('sha256').update(fs.readFileSync(f)).digest('hex')});
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:true,pass:true,cases:count,strings:strings.length,inputs:[original,candidate,import.meta.filename].map(pin),scope:'Original compiled Base and derived kernels agree with independent code-point oracle, including malformed surrogate boundaries.'},null,2)+'\n');console.log(JSON.stringify({pass:true,cases:count}));
