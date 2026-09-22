// Compact evidence archive; generated C/binaries remain reproducible from source.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import zlib from 'node:zlib';
import assert from 'node:assert/strict';
const [configFile,outArg]=process.argv.slice(2);
if(!outArg)throw Error('Usage: native-annotation-archive.mjs CONFIG NEW_DIRECTORY');
const cfg=JSON.parse(fs.readFileSync(configFile)),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const hash=b=>crypto.createHash('sha256').update(b).digest('hex'),rows=[],labels=new Set();
for(const item of cfg.files){
 assert.ok(typeof item.label==='string'&&!path.isAbsolute(item.label)&&!item.label.split('/').includes('..'));assert.ok(!labels.has(item.label));labels.add(item.label);
 const source=fs.readFileSync(item.file),sha256=hash(source);if(item.sha256)assert.equal(sha256,item.sha256,'Source archive identity mismatch: '+item.file);
 const compressed=source.length>8192,relative=item.label+(compressed?'.gz':''),target=path.join(out,relative),bytes=compressed?zlib.gzipSync(source,{level:6}):source;
 fs.mkdirSync(path.dirname(target),{recursive:true});fs.writeFileSync(target,bytes);const restored=compressed?zlib.gunzipSync(fs.readFileSync(target)):fs.readFileSync(target);assert.equal(hash(restored),sha256);
 rows.push({source:item.file,file:relative,sha256,bytes:source.length,packedSha256:hash(bytes),packedBytes:bytes.length,compression:compressed?'gzip':'none',scope:item.scope??null});
}
const manifest={kind:'phase4-native-annotation-evidence',complete:true,at:new Date().toISOString(),producer:{file:import.meta.filename,sha256:hash(fs.readFileSync(import.meta.filename))},configSha256:hash(fs.readFileSync(configFile)),rows,omissions:cfg.omissions??[]};
fs.writeFileSync(path.join(out,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');console.log(JSON.stringify({complete:true,files:rows.length,packedBytes:rows.reduce((n,r)=>n+r.packedBytes,0)}));
