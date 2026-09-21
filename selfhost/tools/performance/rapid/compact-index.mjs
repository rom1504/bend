import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

// Diagnostic ablation, not a compiler implementation. The cache's private tree
// representation changes; public definition results and declaration order do not.
// Append after generated definitions so this composes with source-to-source call
// experiments. Do not use it to generate or promote release artifacts.
export function transformCompactIndex(source) {
  if (source.includes('const rapidIndexMaps=')) throw Error('compact index already installed');
  for (const name of ['index_build', 'index_lookup', 'index_set', 'index_find']) {
    if (!source.includes(`G["${name}"]=`)) throw Error(`missing generated ${name}`);
  }
  const transformed = source + `
// EXPERIMENT: immutable JS Map ablation of the Bend exact-name index.
const rapidIndexMaps=new WeakMap();
const rapidIndexAbsent=call(get(G,"atom"),["Absent"]);
const rapidIndexHash=name=>{let h=2166136261;for(const c of name)h=Math.imul(h^c.codePointAt(0),16777619)>>>0;return h};
const rapidIndexFields=d=>project("KDef",d);
const rapidIndexMissing=()=>get(G,"missing");
function rapidIndexTree(map){
  const tree=ctor("KDef",["","RapidIndexMap",0,0,rapidIndexAbsent,rapidIndexAbsent,list([...map.values()].map(item=>item.value)),true,false]);
  rapidIndexMaps.set(tree,map);return tree;
}
function rapidIndexMap(tree){
  const map=rapidIndexMaps.get(tree);if(map)return map;
  if(rapidIndexFields(tree)[1]==="Absent")return new Map();
  if(rapidIndexFields(tree)[1]==="RapidIndexMap"){
    const rebuilt=new Map();
    for(const d of unlist(rapidIndexFields(tree)[6])){
      const name=rapidIndexFields(d)[0];rebuilt.set(name,{hash:rapidIndexHash(name),value:d});
    }
    rapidIndexMaps.set(tree,rebuilt);return rebuilt;
  }
  throw Error("rapid index: foreign tree representation");
}
function rapidIndexRequireWhole(bits){if(bits!==32)throw Error("rapid index: experiment supports whole 32-bit roots only")}
G["index_build"]=fn(1,([book])=>{
  const map=new Map();
  for(const d of unlist(book)){
    const name=rapidIndexFields(d)[0];
    if(map.has(name))stringEq(name,name);
    if(!map.has(name))map.set(name,{hash:rapidIndexHash(name),value:d});
  }
  return map.size?rapidIndexTree(map):rapidIndexMissing();
});
G["index_set"]=fn(4,([tree,d,hash,bits])=>{
  rapidIndexRequireWhole(bits);
  const map=new Map(rapidIndexMap(tree));const name=rapidIndexFields(d)[0];
  // A supplied hash is part of this lower-level ABI. Multiple hashes for one
  // name cannot occur at compiler call sites; reject that unsupported case.
  if(rapidIndexHash(name)!==(hash>>>0))throw Error("rapid index: inconsistent name hash");
  if(map.has(name))stringEq(name,name);
  map.set(name,{hash:hash>>>0,value:d});return rapidIndexTree(map);
});
G["index_find"]=fn(4,([tree,name,hash,bits])=>{
  rapidIndexRequireWhole(bits);const item=rapidIndexMap(tree).get(name);
  return item&&item.hash===(hash>>>0)&&stringEq(rapidIndexFields(item.value)[0],name)?item.value:rapidIndexMissing();
});
G["index_lookup"]=fn(2,([cache,name])=>{
  const children=rapidIndexFields(cache)[6];
  const tree=children?.$==="Con"?children.a[0]:rapidIndexMissing();
  const item=rapidIndexMap(tree).get(name);
  return item&&item.hash===rapidIndexHash(name)&&stringEq(rapidIndexFields(item.value)[0],name)?item.value:rapidIndexMissing();
});
`;
  return {source: transformed, stats: {kind: 'diagnostic-js-map',
    replacedGlobals: ['index_build', 'index_set', 'index_find', 'index_lookup'],
    persistentUpdates: 'clone-map', serializedRepresentation: 'KDef definition list',
    supportedIndexBits: 32, requiresConsistentHash: true}};
}

export default transformCompactIndex;

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  const [input, output] = process.argv.slice(2);
  if (!input || !output) throw Error('usage: node compact-index.mjs INPUT.mjs OUTPUT.mjs');
  fs.mkdirSync(path.dirname(output), {recursive: true});
  const result = transformCompactIndex(fs.readFileSync(input, 'utf8'));
  fs.writeFileSync(output, result.source);
  console.log(JSON.stringify(result.stats));
}
