import fs from'node:fs';import path from'node:path';import assert from'node:assert/strict';import crypto from'node:crypto';import{pathToFileURL}from'node:url';
const[apiFile,outArg]=process.argv.slice(2),out=path.resolve(outArg),rec=JSON.parse(fs.readFileSync(apiFile));const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};const verify=p=>assert.deepEqual(pin(p.file),p);assert(rec.complete&&rec.checked);rec.inputs.forEach(verify);verify(rec.api);assert(!fs.existsSync(out));fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');const api=(await import(pathToFileURL(rec.api.file))).default;
const old='def first() -> U32:\n  1\n\ndef main() -> U32:\n  first()\n',prefix='def first() -> U32:\n  1\n\n',scope=api.f_parse_scope_empty(),seed=api.p140p_seed(old,api.p140pt_header(old,1),scope,1,15);assert.equal(seed.cache.$,'Some');
const rows=[];for(const tail of['+ 2\n','- 2\n','| U32\n','& U32\n','-> U32\n','def main() -> U32:\n  first()\n','define = 3\n','type Other is Data:\n  O{}\n','@unsafe\ndef main() -> U32:\n  first()\n']){const text=prefix+tail,fresh=api.p140pt_fresh(text,scope,1),warm=api.p140p_resume(text,api.p140pt_header(text,1),scope,1,seed.cache);rows.push({tail,hit:warm.hit,equal:api.p140pt_same(fresh,warm.result),freshError:fresh.error,warmError:warm.result.error});}
assert(rows.every(r=>r.equal),'every changed boundary must equal fresh parsing');
for(const r of rows)assert.equal(r.hit,r.tail.startsWith('def main'),'changed first token must miss');
const lexical=[];
for(const[name,head]of[
 ['unsafe','@unsafe\ndef first(x: U32) -> U32:\n  x\n\n@unsafe\n'],
 ['comment','def first(x: U32) -> U32:\n  x\n# between definitions 😀\n\n'],
 ['nested-newline','def first(x: U32) -> U32:\n  U32.add(x,\n    1)\n\n'],
 ['quoted-newline','def first() -> String:\n  "hello\nworld"\n\n']
]){
 const suffix='def main() -> U32:\n  1\n',a=head+suffix,b=head+suffix.replace('  1','  2');
 const seed=api.p140p_seed(a,api.p140pt_header(a,1),scope,1,head.length+1);
 assert.equal(seed.result.error,'',name);assert.equal(seed.cache.$,'Some',name);
 const warm=api.p140p_resume(b,api.p140pt_header(b,1),scope,1,seed.cache),fresh=api.p140pt_fresh(b,scope,1);
 const row={name,hit:warm.hit,equal:api.p140pt_same(fresh,warm.result),savedToken:seed.cache.value.token,savedPrevious:seed.cache.value.previous};
 assert(row.hit&&row.equal,name);lexical.push(row);
}
fs.writeFileSync(out+'/report.json',JSON.stringify({complete:true,kind:'phase140-parser-boundary-adversarial',inputs:[pin(import.meta.filename),pin(apiFile),rec.api,...rec.inputs],rows,lexical},null,2)+'\n');console.log(JSON.stringify(rows));
