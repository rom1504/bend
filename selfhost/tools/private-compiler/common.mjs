import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';
export const digest=value=>createHash('sha256').update(value).digest('hex');
export const identity=value=>{const file=value instanceof URL?fileURLToPath(value):value;return {file:path.resolve(file),canonicalPath:fs.realpathSync(file),sha256:digest(fs.readFileSync(file))};};
export function verifyIdentity(expected) {
  if(!expected||typeof expected.file!=='string'||typeof expected.canonicalPath!=='string'||!/^[a-f0-9]{64}$/.test(expected.sha256??''))throw Error('Missing artifact identity');
  const actual=identity(expected.file);
  if(actual.canonicalPath!==expected.canonicalPath||actual.sha256!==expected.sha256)throw Error('Artifact changed: '+expected.file);
  return actual;
}
export function writeJson(file,value){fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n',{flag:'wx'});}
export function readJson(file,max=16*1024*1024) {
  if(fs.statSync(file).size>max)throw Error('JSON file exceeds size limit: '+file);
  return JSON.parse(fs.readFileSync(file,'utf8'));
}
export function verifyImage(directory) {
  const root=fs.realpathSync(directory),manifestFile=path.join(root,'manifest.json'),manifestIdentity=identity(manifestFile),manifest=readJson(manifestFile);
  if(manifest.kind!=='bend-private-compiler-image'||manifest.version!==1||manifest.complete!==true)throw Error('Incomplete private compiler image');
  if(!['fixedpoint','checked-stage-proof-pending'].includes(manifest.proofStatus))throw Error('Unknown image proof status');
  if(!Array.isArray(manifest.artifacts)||!manifest.artifacts.length)throw Error('Image has no artifact identities');
  const required=['image.mjs','runtime.mjs',...['typed-driver','compiler-abi','node-resource-args','assemble','native-build'].map(n=>'host/tools/'+n+'.mjs'),...['worker','common','transport','input-audit'].map(n=>'runner/'+n+'.mjs')];
  if(new Set(manifest.artifacts.map(a=>a.relative)).size!==manifest.artifacts.length||required.some(name=>!manifest.artifacts.some(a=>a.relative===name)))throw Error('Image manifest lacks required artifacts');
  for(const artifact of manifest.artifacts){
    if(typeof artifact.relative!=='string'||path.isAbsolute(artifact.relative)||artifact.relative.split(path.sep).includes('..'))throw Error('Invalid image artifact path');
    const file=path.join(root,artifact.relative),actual=identity(file);
    if(!actual.canonicalPath.startsWith(root+path.sep)||actual.sha256!==artifact.sha256)throw Error('Image artifact changed: '+file);
  }
  verifyIdentity(manifest.base);
  return {root,manifest,manifestIdentity};
}
