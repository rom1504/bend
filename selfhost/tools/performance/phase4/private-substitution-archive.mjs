// Content-addressed P4-025 evidence. Historical consumed test versions stay exact.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import zlib from 'node:zlib';import assert from 'node:assert/strict';
const [rootArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('Usage: private-substitution-archive.mjs PHASE4_BUILD NEW_DIRECTORY');
const root=path.resolve(rootArg),out=path.resolve(outArg),start=performance.now(),hash=b=>crypto.createHash('sha256').update(b).digest('hex');fs.mkdirSync(out);fs.mkdirSync(path.join(out,'objects'));
const files=[],objects=new Map(),seen=new Set();
function add(file,label,expected=null,originalPath=null){if(seen.has(label))return;seen.add(label);const source=fs.readFileSync(file),sha256=hash(source);if(expected)assert.equal(sha256,expected,'Archive identity mismatch: '+file);if(!objects.has(sha256)){const packed=zlib.gzipSync(source,{level:6}),object='objects/'+sha256+'.gz';fs.writeFileSync(path.join(out,object),packed,{flag:'wx'});assert.equal(hash(zlib.gunzipSync(fs.readFileSync(path.join(out,object)))),sha256);objects.set(sha256,{file:object,sha256,bytes:source.length,packedBytes:packed.length,packedSha256:hash(packed)});}files.push({label,source:path.resolve(file),...(originalPath?{consumedOriginalPath:originalPath}:{}),sha256,object:objects.get(sha256).file});}
const omissions=[];
for(const [directory,label]of [['substitution-workers-controls','controls1'],['substitution-workers-controls2','controls2'],['substitution-workers-controls3','controls3'],['substitution-workers-compare','comparison']]){
 const dir=path.join(root,directory),report=JSON.parse(fs.readFileSync(path.join(dir,'report.json')));assert.equal(report.complete,true);
 for(const file of fs.readdirSync(dir)){const target=path.join(dir,file);if(fs.statSync(target).isFile())add(target,label+'/'+file);}
 for(const suffix of ['.stdout','.stderr']){const file=path.join(root,directory+suffix);if(fs.existsSync(file))add(file,label+'/supervisor'+suffix);}
 for(const [i,item]of report.inputs.entries()){
  if(item.file===process.execPath){omissions.push({scope:label,file:item.file,sha256:item.sha256,reason:'External Node executable, preserved by exact hash/version rather than duplicate executable bytes.'});continue;}
  let consumed=item.file;
  if(hash(fs.readFileSync(consumed))!==item.sha256){const old=path.join(dir,'private-substitution-test-consumed.mjs');assert.ok(fs.existsSync(old),'No retained consumed source for '+consumed);assert.equal(hash(fs.readFileSync(old)),item.sha256);consumed=old;}
  add(consumed,label+'/input-'+i+'-'+path.basename(item.file),item.sha256,consumed===item.file?null:item.file);
 }
 for(const row of [...(report.prime??[]),...(report.rows??[])])for(const id of [row.configuration,row.request])if(id)add(id.file,label+'/'+row.label+'/'+path.basename(id.file),id.sha256);
}
for(const name of ['private-substitution-workers.mjs','private-substitution-test.mjs','private-substitution-compare.mjs','private-substitution-archive.mjs'])add(path.join(import.meta.dirname,name),'current-tools/'+name);
const manifest={kind:'phase4-private-substitution-evidence',complete:true,at:new Date().toISOString(),files,objects:[...objects.values()],omissions,scope:'All three completed semantic reports and four-row comparison, original/candidate generated images, exact outputs, validated caches and consumed tools/inputs. Historical test-source revisions resolve to hash-matching retained copies; no overwritten report is relabeled.',archiveWallMs:performance.now()-start,affinity:fs.readFileSync('/proc/self/status','utf8').split('\n').find(x=>x.startsWith('Cpus_allowed_list:'))};
fs.writeFileSync(path.join(out,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');console.log(JSON.stringify({complete:true,references:files.length,objects:objects.size,packedBytes:[...objects.values()].reduce((n,r)=>n+r.packedBytes,0),archiveWallMs:manifest.archiveWallMs}));
