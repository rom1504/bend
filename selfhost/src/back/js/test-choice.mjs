// Differential semantics and evaluation order for structurally proven choices.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
import {inspect,project} from '../../../tools/typed-driver.mjs';
const directory=path.join(project,'build/choice-tests');fs.mkdirSync(directory,{recursive:true});
const source=path.join(project,'tests/fixtures/choice.bend');
const names=['picked','partial','loop','dynamic','reversed','ordered'];
const oracleFile=path.join(directory,'oracle.mjs'),candidateFile=path.join(directory,'candidate.mjs');
const built=spawnSync(process.execPath,[path.join(project,'tools/stage0-library.mjs'),source,oracleFile,...names],{encoding:'utf8',timeout:120000});
assert.equal(built.status,0,built.error?.message||built.stderr);
const result=await inspect(source,{mode:'library'});assert.equal(result.status,'ok',JSON.stringify(result));
assert.match(result.code,/\/\* choice \*\//,'eligible literal thunks must use the optimized path');
fs.writeFileSync(candidateFile,result.code);
const {default:actual,G}=await import(pathToFileURL(candidateFile));
const {default:oracle}=await import(pathToFileURL(oracleFile));
for(const name of names.filter(n=>n!=='loop'))for(const b of [true,false])assert.deepEqual(actual[name](b),oracle[name](b),name+' '+b);
assert.equal(actual.loop(50000),17,'tail recursion must remain trampolined');
const events=[];
G.condition={arity:1,code:args=>{events.push('condition');return args[0]},env:null,bound:[]};
G.selected={arity:1,code:args=>{events.push(String(args[0]));return args[0]},env:null,bound:[]};
assert.equal(actual.ordered(true),41n);assert.deepEqual(events,['condition','41']);
events.length=0;assert.equal(actual.ordered(false),43n);assert.deepEqual(events,['condition','43']);
const original=G.thunk;
G.thunk={arity:0,code:(...args)=>{events.push('construct');return original.code(...args)},env:original.env,bound:[]};
events.length=0;assert.equal(actual.dynamic(false),29n);assert.deepEqual(events,['construct'],'computed unselected thunk must still be evaluated');
console.log('choice oracle, partial/dynamic fallback, altered body, branch order, and 50000 tail calls passed');

// Inlining must preserve the pre-existing closure-factory depth boundary.
const deepSource=path.join(directory,'deep.bend'),deepOutput=path.join(directory,'deep.mjs');
let body='n';for(let i=0;i<70;i++)body=`kc(Nat, b, u => ${body}, u => 0n)`;
fs.writeFileSync(deepSource,fs.readFileSync(source,'utf8')+'\n@unsafe\ndef deep(+b: Bool, +n: Nat) -> Nat:\n  '+body+'\n');
const deep=await inspect(deepSource,{mode:'library'});assert.equal(deep.status,'ok',JSON.stringify(deep));
assert.match(deep.code,/F\["\$js\./,'deep choices retain flat factories');fs.writeFileSync(deepOutput,deep.code);
const {default:d}=await import(pathToFileURL(deepOutput));assert.equal(d.deep(true,47n),47n);assert.equal(d.deep(false,47n),0n);
console.log('70 nested choices preserve flat closure factories and captured values');
// Boolean-shaped user datatypes must keep constructor matching, not JS truthiness.
const localSource=path.join(directory,'local.bend'),localOutput=path.join(directory,'local.mjs');
const header=fs.readFileSync(source,'utf8').split('@unsafe\ndef picked')[0].replace('for +b: Bool','for +b: LocalBool').replace('for yes: Unit','for yes: LocalUnit').replace('for no: Unit','for no: LocalUnit').replace('import Base','type LocalBool is Data:\n  True{}\n  False{}\ntype LocalUnit is Data:\n  Unit{}\ntype Answer is Data:\n  Yes{}\n  No{}');
fs.writeFileSync(localSource,header+'\n@unsafe\ndef answer() -> Answer:\n  kc(Answer, False{}, u => Yes{}, u => No{})\n');
const local=await inspect(localSource,{mode:'library'});assert.equal(local.status,'ok',JSON.stringify(local));
assert.doesNotMatch(local.code,/\/\* choice \*\//);fs.writeFileSync(localOutput,local.code);
assert.deepEqual((await import(pathToFileURL(localOutput))).default.answer(),{$:'No',a:[]});
console.log('user Bool/Unit definitions retain constructor semantics');
