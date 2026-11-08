// Active bootstrap selection is manifest data. Explicit historical manifests
// retain their own revision/path; no checkout or asset is acquired here.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

export const bootstrapConfigPath=fileURLToPath(import.meta.url);
export const defaultCompilerManifest=fileURLToPath(new URL('../src/compiler.json',import.meta.url));

export function readBootstrapConfig({manifest,upstream,environment=process.env}={}) {
  manifest=path.resolve(manifest??environment.BEND_BOOTSTRAP_MANIFEST??defaultCompilerManifest);
  const config=JSON.parse(fs.readFileSync(manifest,'utf8'));
  if(typeof config.upstream!=='string'||!/^[0-9a-f]{40}$/.test(config.upstream))
    throw Error('Invalid bootstrap upstream revision');
  const relative=Object.hasOwn(config,'upstreamPath')?config.upstreamPath:'.bootstrap/upstream-phase66';
  if(typeof relative!=='string'||!relative||relative.includes('\0'))
    throw Error('Invalid bootstrap upstreamPath');
  const selected=upstream??environment.BEND_UPSTREAM;
  if(selected!==undefined&&(typeof selected!=='string'||!selected||selected.includes('\0')))
    throw Error('Invalid explicit bootstrap upstream path');
  return {manifest,config,revision:config.upstream,
    upstream:selected===undefined?path.resolve(path.dirname(manifest),'..',relative):path.resolve(selected)};
}
