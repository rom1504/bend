#!/usr/bin/env bun
// Source preparation only. This does not execute a compiler or proof checker.
import {readFileSync, writeFileSync, mkdirSync, existsSync} from 'node:fs';
import {resolve, dirname, relative, sep} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';

const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, '../../../../..');
const args = process.argv.slice(2);
if (args.length !== 2 || args[0] !== '--out') throw Error('usage: prepare.mjs --out NEW_REPO_DIRECTORY');
const out = resolve(root, args[1]);
if (!out.startsWith(root + sep) || existsSync(out)) throw Error('output must be a fresh repository directory');
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
const pin = path => {const bytes=readFileSync(path); return {file:relative(root,path), bytes:bytes.length, sha256:hash(bytes)};};
const modelPath = resolve(here, '../ir/model.bend');
const optimizePath = resolve(here, '../ir/optimize.bend');
const model = readFileSync(modelPath, 'utf8');
const optimize = readFileSync(optimizePath, 'utf8');
const boundary = optimize.indexOf('\n@unsafe\n');
if (boundary < 0 || /@unsafe|^law /m.test(model)) throw Error('review changed model/extraction boundary');
const helper = optimize.slice(0,boundary) + '\n';
if (/@unsafe|^law /m.test(helper) || !helper.includes('def nx_fold_bin(')) throw Error('expected safe fold helper');
const connection = 'case NxBin{op, left, right}: nx_fold_bin(op, nx_simplify(left), nx_simplify(right))';
if (optimize.split(connection).length !== 2) throw Error('actual recursive-pass connection changed');
const candidate = 'import Base\n\n' + model + '\n' + helper;
const reference = readFileSync(resolve(here,'reference.bend'),'utf8');
const laws = readFileSync(resolve(here,'laws.bend'),'utf8');
const bridge = readFileSync(resolve(here,'bridge.bend'),'utf8');
const observations = JSON.parse(readFileSync(resolve(here,'cases.json'),'utf8')).cases;
const bridgeInputs = [...bridge.matchAll(/NxLawCase\{"([a-z]+)", ([0-9]+), ([0-9]+)\}/g)]
  .map(m=>({op:m[1],a:Number(m[2]),b:Number(m[3])}));
if (JSON.stringify(bridgeInputs)!==JSON.stringify(observations.map(({op,a,b})=>({op,a,b}))))
  throw Error('Bend bridge case order differs from frozen JSON');
const math = {add:(a,b)=>a+b,sub:(a,b)=>a-b,mul:(a,b)=>a*b,and:(a,b)=>a&b,
  or:(a,b)=>a|b,xor:(a,b)=>a^b,eq:(a,b)=>a===b?1n:0n,ult:(a,b)=>a<b?1n:0n};
for (const row of observations) {
  for (const value of [row.a,row.b,row.expected])
    if (!Number.isInteger(value) || value<0 || value>4294967295) throw Error('invalid U32 observation');
  if (!math[row.op] || Number(BigInt.asUintN(32,math[row.op](BigInt(row.a),BigInt(row.b))))!==row.expected)
    throw Error('frozen arithmetic expectation mismatch');
}
const cases = [
  {id:'add-as-sub',before:'U32.add(a, b)',after:'U32.sub(a, b)',law:'fold_add_exact',witness:{op:'add',a:1,b:2,expected:3,mutant:4294967295}},
  {id:'reverse-sub',before:'U32.sub(a, b)',after:'U32.sub(b, a)',law:'fold_sub_exact',witness:{op:'sub',a:0,b:1,expected:4294967295,mutant:1}},
  {id:'less-as-equal',before:'U32.is_lt(a, b)',after:'U32.is_eq(a, b)',law:'fold_ult_exact',witness:{op:'ult',a:0,b:1,expected:1,mutant:0}},
  {id:'erase-literal-types',before:'case NxConst{NxU32{}, a} NxConst{NxU32{}, b}:',after:'case NxConst{left_type, a} NxConst{right_type, b}:',law:'fold_u64_preserves',witness:{op:'add',types:['u64','u64'],a:1,b:2,expected:'unchanged NxBin with U64 operands',mutant:'NxConst U32 3'}},
];
for (const item of cases) if (candidate.split(item.before).length !== 2) throw Error('mutation boundary changed: '+item.id);
mkdirSync(out, {recursive:true});
const files=[];
function write(path,text) {writeFileSync(path,text);files.push(pin(path));}
function packageAt(name,text) {
  const folder=resolve(out,name);mkdirSync(folder);
  write(resolve(folder,'candidate.bend'),text);
  write(resolve(folder,'reference.bend'),reference);
  write(resolve(folder,'laws.bend'),laws);
  return relative(root,folder);
}
const baseline=packageAt('baseline',candidate);
for (const item of cases) item.folder=packageAt(item.id,candidate.replace(item.before,item.after));
const manifest={
  schema:'phase106-source-connected-fold-laws-v1',targetsRun:false,
  source:[pin(modelPath),pin(optimizePath)],method:pin(fileURLToPath(import.meta.url)),
  frozenReference:pin(resolve(here,'reference.bend')),frozenLaws:pin(resolve(here,'laws.bend')),
  finiteBridge:{source:pin(resolve(here,'bridge.bend')),cases:pin(resolve(here,'cases.json')),
    caseCount:observations.length,orderedInputMatch:true,independentBigIntExpectationCheck:true,
    compilerExecuted:false},
  baseline,cases,files,
  extraction:{model:'complete verbatim file',optimizer:'exact prefix before first @unsafe declaration',prefix:'import Base',unsafeRemoved:false},
  connection:{text:connection,meaning:'source inspection only; recursive traversal is not proved'},
  lawCount:[...laws.matchAll(/^law /gm)].length,
  publicLawCount:12,supportLawCount:1,
  scope:'Safe literal-fold helper result; no recursive pass, emitter, ownership, machine-code or whole-compiler proof.',
  negativeProtocol:'First admit candidate.bend alone. Only then count unchanged-law expected/observed rejection as a semantic mutation detection. Syntax/resource failures do not count. Negative source-check rejection is not independent kernel rejection.',
  checker:'selfhost/tools/laws/phase98/check.py',
  outputRestriction:'Existing checker requires fresh output under selfhost/build/phase98/.',
};
writeFileSync(resolve(out,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');
console.log(JSON.stringify({out:relative(root,out),lawCount:manifest.lawCount,mutations:cases.length,targetsRun:false}));
