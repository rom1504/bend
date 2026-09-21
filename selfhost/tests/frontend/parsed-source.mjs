// Raw and invocation-local parsed sources must produce identical full graphs.
import assert from 'node:assert/strict';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const {default:api}=await import(pathToFileURL(path.resolve(process.env.BEND_FRONT_API||'dist/typed-api.mjs')));
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const source=(name,text)=>({$:'FSource',name,path:name,text});
const main='/test/main.bend';
const cases=[
 ['simple',[source(main,'type Bit is Data:\n  On{}\ndef main() -> Bit:\n  On{}\n')]],
 ['aliases',[source(main,'import ./child.bend as C\ndef main() -> C.Bit:\n  C.On{}\n'),source('/test/child.bend','type Bit is Data:\n  On{}\n')]],
 ['parse error',[source(main,'def main(\n')]],
 ['cycle',[source(main,'import ./child.bend as C\n'),source('/test/child.bend','import ./main.bend as M\n')]],
 ['missing source',[source(main,'import ./missing.bend as M\n')]],
 ['repeated import',[source(main,'import ./child.bend as C\nimport ./child.bend as C\n'),source('/test/child.bend','type Bit is Data:\n  On{}\n')]],
 ['parallel bindings',[source(main,'type Bit is Data:\n  On{}\ndef main() -> Bit:\n  a b = On{} On{}\n  a\n')]],
];
for(const [name,sources] of cases){
 const parsed=sources.map(s=>api.f_source_parsed(s.name,s.path,s.text,api.f_parse(s.text)));
 const plain=api.f_load_graph(main,list(sources)),cached=api.f_load_graph(main,list(parsed));
 assert.deepEqual(cached,plain,name);
 if(!plain.error)assert.deepEqual(api.f_main_names(main,list(parsed)),api.f_main_names(main,list(sources)),name+' names');
 // A mismatched seed must take the ordinary path, also for parsed records.
 assert.deepEqual(api.f_load_graph_seed(main,list(parsed),'/wrong','wrong',list([])),plain,name+' seed fallback');
 console.log('PASS parsed source '+name);
}
