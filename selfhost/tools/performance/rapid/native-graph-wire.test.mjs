import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import path from 'node:path';
const api=(await import(pathToFileURL(path.resolve(process.argv[2])))).default;
const wire=fields=>fields.join('\0')+'\0';
let checks=0;
const valid=['BEND_GRAPH_1','/tmp/猫 main.bend','S','/tmp/猫 main.bend','/real/猫 main.bend','/snapshot/0','S','Base','/base.bend','/snapshot/1','A','/tmp/./foreign.js','/real/foreign.js','E'];
const parsed=api.rapid_graph_parse(wire(valid));assert.equal(parsed.error,'');assert.equal(parsed.main,'/tmp/猫 main.bend');assert.equal(parsed.assets.head.id,0);checks++;
for(const fields of [[],['BEND_GRAPH_2','/main','E'],['BEND_GRAPH_1','relative','E'],['BEND_GRAPH_1','/main'],['BEND_GRAPH_1','/main','X'],['BEND_GRAPH_1','/main','E','extra'],['BEND_GRAPH_1','/main','S','/name','/real','E'],['BEND_GRAPH_1','/main','A','relative','/real','E'],['BEND_GRAPH_1','/main','S','/name','relative','/snap','E']]){assert.notEqual(api.rapid_graph_parse(wire(fields)).error,'');checks++;}
assert.notEqual(api.rapid_graph_parse(wire(valid).slice(0,-1)).error,'');checks++;
assert.notEqual(api.rapid_graph_parse(wire(['BEND_GRAPH_1','/'+ 'x'.repeat(8193),'E'])).error,'');checks++;
const many=['BEND_GRAPH_1','/main'];for(let i=0;i<4097;i++)many.push('A','/asset'+i,'/physical');many.push('E');assert.notEqual(api.rapid_graph_parse(wire(many)).error,'');checks++;
const maximum=['BEND_GRAPH_1','/main'];for(let i=0;i<4096;i++)maximum.push('S','/module'+i,'/physical'+i,'/snapshot'+i);maximum.push('E');assert.equal(api.rapid_graph_parse(wire(maximum)).error,'');checks++;
const escaped=['BEND_GRAPH_1','/tmp/"\\\n猫.bend','S','/tmp/"\\\n猫.bend','/tmp/"\\\n猫.bend','/snapshot/0','E'];assert.equal(api.rapid_graph_parse(wire(escaped)).error,'');checks++;
const nil={$:'Nil'},list=items=>items.reduceRight((tail,head)=>({$:'Con',head,tail}),nil),term=(tag,name,id,kids=[])=>({$:'KTerm',tag,name,id,quant:0,kids:list(kids),removed:nil});
const assets=list([term('Asset','/A',0,[term('Ref','/B',0)]),term('Asset','/B',1,[term('Ref','/C',0)])]);
assert.equal(api.rapid_graph_find_asset('/B',assets).id,1);checks++;
assert.equal(api.rapid_graph_find_asset('/C',assets).id,1);checks++;
console.log(JSON.stringify({passed:true,checks}));
