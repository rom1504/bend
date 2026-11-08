// Exact pinned effect transport. The manifest binds a Base and each vendored
// file; constructor/definition names remain the compiler emitter's concern.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
const hash=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');

export function pinnedJsEffects({base,effects,manifestPath=path.join(effects,'manifest.json')}) {
  const manifest=JSON.parse(fs.readFileSync(manifestPath,'utf8'));
  const legacy=manifest.kind==='phase52-pinned-upstream-js-effects';
  if((!legacy&&manifest.kind!=='bend-pinned-upstream-js-effects')||manifest.version!==1||
    !/^[0-9a-f]{64}$/.test(manifest.base?.sha256??'')||!Array.isArray(manifest.files))
    throw Error('Invalid pinned JS effect manifest');
  const entries=new Map(manifest.files.map(item=>[item.path,item]));
  if(entries.size!==manifest.files.length||entries.size<1||entries.size>256||
    (legacy&&entries.size!==35)||[...entries].some(([name,item])=>
      !/^[a-z0-9_]+\.js$/.test(name)||!Number.isSafeInteger(item.bytes)||item.bytes<0||
      !/^[0-9a-f]{64}$/.test(item.sha256??'')))throw Error('Invalid pinned JS effect inventory');
  const canonicalBase=fs.realpathSync(base),pinned=hash(fs.readFileSync(canonicalBase))===manifest.base.sha256;
  return {inputs:[manifestPath],resolve:file=>{
    const resolved=path.resolve(file),name=path.basename(resolved);
    if(!pinned||path.dirname(resolved)!==path.join(path.dirname(canonicalBase),'effs')||!entries.has(name))return resolved;
    const target=path.join(effects,name),bytes=fs.readFileSync(target),expected=entries.get(name);
    if(bytes.length!==expected.bytes||hash(bytes)!==expected.sha256)throw Error('Pinned JS effect bytes differ: '+name);
    return target;
  }};
}
