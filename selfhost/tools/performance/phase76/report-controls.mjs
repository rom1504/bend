// Finite semantic controls for the new private report against both old queries.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
const [apiFile,out]=process.argv.slice(2),api=(await import(pathToFileURL(apiFile))).default;
const list=a=>a.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
const term=(tag,name='',kids=[])=>({$:'KTerm',tag,name,kids:list(kids),id:0,quant:1,removed:list([]),originBegin:0,originEnd:0});
const def=(name,refs=[],unsafe=false,native=false)=>({$:'KDef',name,kind:'Def',arity:0,templates:0,typ:term('Typ'),value:term('Ctr','Tuple',refs.map(n=>term('Ref',n))),ctors:list([]),unsafe,native});
let count=0;const checks=[];
function check(label,defs){const book=list(defs),actual=api.driver_report_data(book);assert.equal(actual.verdict,api.driver_report(book,list([])),label);assert.deepEqual(actual.names,api.driver_bad_names(book),label);count++;checks.push(label);}
check('safe cycle',[def('a',['b']),def('b',['a'])]);
check('cycle reaches unsafe',[def('a',['b']),def('b',['a','u']),def('u',[],true)]);
check('safe branch before unsafe',[def('a',['safe','u']),def('later',['safe']),def('safe'),def('u',[],true)]);
check('unresolved and duplicate',[def('a',['absent']),def('b',['a']),def('a',[],true)]);
check('foreign and native foreign',[{...def('x'),value:term('Foreign')},{...def('base',[],false,true),value:term('Foreign')},def('y',['base']),def('z',['x'])]);
check('constructor field dependency',[{...def('D'),kind:'ADT',ctors:list([{...def('C'),kind:'Ctr',typ:term('Ref','u')}])},def('user',['D']),def('u',[],true)]);
let seed=75005;const rnd=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed;};
for(let k=0;k<160;k++){let ds=[];for(let i=0;i<8;i++)ds.push(def('n'+i,Array.from({length:rnd()%4},()=> 'n'+(rnd()%10)),rnd()%7===0,rnd()%4===0));check('graph-'+k,ds);}
const pin=p=>({file:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
fs.writeFileSync(out,JSON.stringify({complete:true,pass:true,count,checks,inputs:[pin(apiFile),pin(import.meta.filename)],scope:'Exact verdict and ordered unsafe names against the unchanged public algorithms. Deterministic cyclic, foreign, missing and duplicate dependency graphs; no timing claim.'},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({pass:true,count}));
