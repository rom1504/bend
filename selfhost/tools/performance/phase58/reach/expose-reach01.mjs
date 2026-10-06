// Private diagnostic derivative only. No cap changes or checked derivative claim.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {identity,verify,hash} from '../../../performance/phase54/bootstrap/adapter.mjs';
const CORE_SHA='85381e3c1418f575b818197ed66b5a590a4923bc91c7a366a36ad3260e521351';
export function exposeReach(api,core,out){
 verify(api);verify(core);assert.equal(core.sha256,CORE_SHA);
 const bytes=fs.readFileSync(api.file),source=bytes.toString('utf8');assert.equal(Buffer.from(source).compare(bytes),0);
 assert(!source.includes('$phase58Reach'));
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],M={exports:{}};
 new Function('module','exports',parserSource)(M,M.exports);
 const parse=s=>M.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(source);
 const edits=[];
 for(const [name,params,text] of [
 ['jd_reach_definition',['_book_0','_names_0','_defs_0','_rest_0','_seen_0','_left_0','_fuel_0','_d_0'],
  '$phase58Reach.current=_d_0.name;$phase58Reach.definitionEntries++;'],
 ['jd_reach_follow',['_book_0','_names_0','_defs_0','_rest_0','_seen_0','_left_0','_fuel_0','_refs_0'],
  `if(_refs_0.$==='Some'){const counts=new Map();let xs=_refs_0.value,n=0;while(xs.$==='Con'){assertReach(++n<=10000000);counts.set(xs.head,(counts.get(xs.head)||0)+1);xs=xs.tail;}assertReach(xs.$==='Nil');$phase58Reach.rows.push({name:$phase58Reach.current,occurrences:n,unique:counts.size,duplicates:n-counts.size,targets:[...counts].filter(x=>x[1]>1).sort((a,b)=>b[1]-a[1])});$phase58Reach.seen.add($phase58Reach.current);}else{$phase58Reach.metadataRefusals++;}`],
 ['jd_reach_visit',['_book_0','_names_0','_defs_0','_todo_0','_seen_0','_left_0','_fuel_0'],
  `if(_todo_0.$==='Con'){$phase58Reach.pops++;if(_fuel_0===0)$phase58Reach.fuelZero++;else if($phase58Reach.seen.has(_todo_0.head))$phase58Reach.seenPops++;else $phase58Reach.newPops++;}`]
 ]){const hits=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name==='$'+name+'$');assert.equal(hits.length,1,name);const d=hits[0];assert.deepEqual(d.params.map(p=>p.name),params);edits.push({at:d.body.start+1,text:'\n'+text+'\n'});}
 const suffix=`\nconst $phase58Reach={current:null,definitionEntries:0,pops:0,seenPops:0,newPops:0,fuelZero:0,metadataRefusals:0,seen:new Set(),rows:[]};
function assertReach(x){if(!x)throw Error('Phase58 diagnostic list malformed/budget');}
export function $phase58ReachSnapshot(){const {seen,...rest}=$phase58Reach;return {...rest,seenDefinitions:seen.size,totals:$phase58Reach.rows.reduce((a,r)=>({occurrences:a.occurrences+r.occurrences,unique:a.unique+r.unique,duplicates:a.duplicates+r.duplicates}),{occurrences:0,unique:0,duplicates:0})};}\n`;
 let text=source;for(const e of edits.sort((a,b)=>b.at-a.at))text=text.slice(0,e.at)+e.text+text.slice(e.at);text+=suffix;parse(text);
 const target=path.join(out,'api-reach-diagnostic.mjs');fs.writeFileSync(target,text,{flag:'wx'});verify(api);verify(core);
 const receipt={kind:'phase58-private-reach-counters',checked:false,source:api,core,output:identity(target),producer:identity(import.meta.filename),edits,suffixSha256:hash(Buffer.from(suffix)),parser:{version:M.exports.version,sha256:hash(Buffer.from(parserSource))},scope:'Entry counters only; current definition persists across the sequential compiler trampoline until its follow call. JS seen mirrors only completed Some follows, matching compiler seen insertion on successful definitions. No forcing or compiler query is added. Timing/allocations are diagnostic.'};
 const f=path.join(out,'derivation.json');fs.writeFileSync(f,JSON.stringify(receipt,null,2)+'\n',{flag:'wx'});return{api:receipt.output,receipt:identity(f)};
}
