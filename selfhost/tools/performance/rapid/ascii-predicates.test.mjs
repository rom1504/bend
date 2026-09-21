// Exhaustively validate the unsigned ASCII formulas used by the Bend lexer
// prototype. This is a mathematical predicate check, not a throughput benchmark.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const baseline=await import(new URL('../../../dist/phase1/selfhost-api.mjs',import.meta.url));
const alpha=n=>(((n|32)-97)>>>0)<=25;
const digit=n=>((n-48)>>>0)<=9;
const space=n=>n===32||((n-9)>>>0)<=4;
const ident=n=>alpha(n)||digit(n)||n===95||n===46;
const alphaReference=n=>(n>=65&&n<=90)||(n>=97&&n<=122);
const digitReference=n=>n>=48&&n<=57;
const spaceReference=n=>n===32||(n>=9&&n<=13);
const identReference=n=>alphaReference(n)||digitReference(n)||n===95||n===46;
for(let n=0;n<=0x10ffff;n++){
 if(alpha(n)!==alphaReference(n)||digit(n)!==digitReference(n)||space(n)!==spaceReference(n)||ident(n)!==identReference(n))throw Error('ASCII predicate mismatch at '+n);
}
let compared=0;
const samples=new Set([...Array(256).keys(),0x7ff,0x800,0xd7ff,0xd800,0xdbff,0xdc00,0xdfff,0xe000,0xffff,0x10000,0x10ffff]);
let random=0x502ac17;for(let i=0;i<500;i++){random=(Math.imul(random,1664525)+1013904223)>>>0;samples.add(random%0x110000);}
for(const n of samples){
 assert.equal(ident(n),baseline.default.f_ident(n),'f_ident '+n);
 assert.equal(alpha(n),baseline.default['Char.is_alpha'](n),'Char.is_alpha '+n);
 assert.equal(digit(n),baseline.default['Char.is_digit'](n),'Char.is_digit '+n);
 assert.equal(space(n),baseline.default['Char.is_space'](n),'Char.is_space '+n);
 compared+=4;
}
// Optionally check the actual Bend-emitted capsule helpers over every codepoint.
// Caller controls scheduling because these generic-runtime calls take longer.
let bendComparisons=0;
if(process.env.BEND_ASCII_CAPSULE){
 const api=await import(pathToFileURL(path.resolve(process.env.BEND_ASCII_CAPSULE)));
 const checks=[['f_ascii_alpha',alphaReference],['f_ascii_digit',digitReference],['f_ascii_space',spaceReference],['f_ident',identReference]];
 for(let n=0;n<=0x10ffff;n++)for(const [name,reference] of checks){
  if(api.call(api.G[name],[n])!==reference(n))throw Error('Bend '+name+' mismatch at '+n);
  bendComparisons++;
 }
 for(const a of [0,9,46,48,65,95,97,127,0xd800,0x10000,0x10ffff])for(const b of [0,9,46,48,65,95,97,127,0xd800,0x10000,0x10ffff]){
  assert.equal(api.call(api.G.f_ascii_char_eq,[a,b]),baseline.default['Char.is_eq'](a,b));bendComparisons++;
 }
}
const report={kind:'compiler-local-ascii-predicate-equivalence',codepoints:0x110000,formulaComparisons:0x110000*4,includesSurrogateCodepoints:true,baselineBendComparisons:compared,compiledBendComparisons:bendComparisons,scope:'Source character codepoints; no change to Base Char APIs. Does not claim equivalence for invalid host Char values such as NaN or Infinity.'};
if(process.env.BEND_ASCII_REPORT)fs.writeFileSync(process.env.BEND_ASCII_REPORT,JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));
