// Reuse the Phase41 independent owner; preserve its source hash in the receipt.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
const[dir]=process.argv.slice(2);assert(dir);const sha=x=>createHash('sha256').update(x).digest('hex');
const old='selfhost/tools/performance/phase41/tree/actual-derive-v2.mjs',owner='selfhost/tools/performance/phase41/tree/actual-controls.mjs';
const deriveSource=fs.readFileSync(old,'utf8');let adapters=deriveSource.slice(deriveSource.indexOf('function adapters('),deriveSource.indexOf('\nfs.mkdirSync(out'));
const getAdapters=new Function(deriveSource.slice(deriveSource.indexOf('const all='),deriveSource.indexOf('const names='))+adapters+';return adapters');adapters=getAdapters()('wrapper');
const receipt=JSON.parse(fs.readFileSync(path.join(dir,'derive.json')));
for(const role of['original','live','recursive-ceiling']){let s=fs.readFileSync(path.join(dir,role+'.clean.mjs'),'utf8');const marker='function $R_119_97_114_112_95_110_111_100_101$tree($p0,$p1){';assert(s.includes(marker));s=s.replace(marker,marker+'++$p41Entries;')+'\nlet $p41Entries=0;\n'+adapters;fs.writeFileSync(path.join(dir,role+'.mjs'),s,{flag:'wx'});receipt.modules.push({role,diagnostic:true,path:path.resolve(dir,role+'.mjs'),sha256:sha(s)});}
receipt.controlOwners=[old,owner].map(p=>({path:p,sha256:sha(fs.readFileSync(p))}));receipt.dependencies=['warp_leaf.go','Bool.xor','warp_leaf','warp_zip','warp','warp_node'];
fs.writeFileSync(path.join(dir,'controls-derive.json'),JSON.stringify(receipt,null,2)+'\n',{flag:'wx'});
let controls=fs.readFileSync(owner,'utf8').replaceAll('derive.json','controls-derive.json').replaceAll("'phase41-tree-actual-wrapper'","'phase42-frame-live-continuations'").replace("const roles=['original','wrapper']","const roles=['original','live']").replaceAll('mods.wrapper','mods.live').replaceAll("role==='wrapper'","role==='live'").replaceAll("checked:true","checked:false");
fs.writeFileSync(path.join(dir,'controls.mjs'),controls,{flag:'wx'});console.log(JSON.stringify({dir,ready:true}));
