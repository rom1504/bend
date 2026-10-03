// Root may reproduce this bounded sanity check under pinned Node.
import assert from 'node:assert/strict';import path from 'node:path';import {pathToFileURL} from 'node:url';
const dir=process.argv[2];assert(dir,'usage: tiny-controls.mjs DERIVED');
const mods=await Promise.all(['original','live','recursive-ceiling'].map(x=>import(pathToFileURL(path.resolve(dir,x+'.mjs')))));
for(let d=0;d<=5;d++)for(const seed of[0,17,123]){const values=mods.map(m=>m.default.bench(d,seed));assert.equal(values[1],values[0]);assert.equal(values[2],values[0]);}
for(const m of mods){assert.deepEqual(m.p41Fresh(),[true,true]);assert.deepEqual(m.p41ZeroAliases(),[true,true,true]);assert.equal(m.p41ProofActive(),false);}
console.log(JSON.stringify({complete:true,benchPairs:18,roles:3,aliasControls:6}));
