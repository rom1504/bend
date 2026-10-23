// Offline transport recoding only: no compiler import, checking, AST or heap terms.
// Usage: node carrier.mjs ORIGINAL_P88_RECEIPT FRESH_OUTPUT_DIRECTORY
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';

const [receiptFile,outArg]=process.argv.slice(2), out=path.resolve(outArg);
assert(!fs.existsSync(out));
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const verify=row=>assert.deepEqual(pin(row.file),row);
const original=JSON.parse(fs.readFileSync(receiptFile));
assert(original.complete&&original.kind==='phase88-private-base-carrier');
for(const p of [...Object.values(original.inputPins),original.carrier])verify(p);
assert(original.carrier.bytes<=16*1024*1024);
const input=fs.readFileSync(original.carrier.file,'utf8'),chars=[...input];
assert(chars.every(c=>{const n=c.codePointAt(0);return n<0xd800||n>0xdfff;}));
let at=0,numberCount=0;
const parts=[],inverse=[];
const word=n=>{
  assert(Number.isInteger(n)&&n>=0&&n<=0xffffffff);
  const s=String.fromCodePoint(65536+(n%65536),65536+Math.floor(n/65536));
  const p=[...s].map(c=>c.codePointAt(0)-65536);
  assert.equal(p[0]+p[1]*65536,n);
  return s;
};
const decimal=()=>{
  let text='';while(at<chars.length&&chars[at]!=='\n')text+=chars[at++];
  assert.equal(chars[at++],'\n');assert(/^(0|[1-9][0-9]{0,9})$/.test(text));
  const n=Number(text);assert(n<=0xffffffff);return n;
};
const number=n=>{parts.push(word(n));inverse.push(String(n)+'\n');numberCount++;};
const string=()=>{
  const n=decimal();assert(n<=1048576&&at+n<chars.length);
  const text=chars.slice(at,at+n).join('');at+=n;assert.equal(chars[at++],'\n');return text;
};
const stamp=string();assert.equal(stamp,original.stamp);
const newStamp='p130-word-pair-v1:'+stamp;assert([...newStamp].length<=1048576);
parts.push(word([...newStamp].length),newStamp,'\n');
inverse.push(String([...stamp].length)+'\n',stamp,'\n');numberCount++;
const nodes=decimal(),strings=decimal();
assert.equal(nodes,original.nodeCount);assert.equal(strings,original.stringCount);
assert(nodes>=1&&nodes<=65536&&strings<=4096);number(nodes);number(strings);
for(let i=0;i<strings;i++){
  const text=string();number([...text].length);parts.push(text,'\n');inverse.push(text,'\n');
}
while(at<chars.length)number(decimal());
assert.equal(inverse.join(''),input,'Canonical inverse must recover every old carrier byte');
const data=Buffer.from(parts.join(''));assert(data.length<=16*1024*1024);
for(const p of [...Object.values(original.inputPins),original.carrier])verify(p);
fs.mkdirSync(out);fs.writeFileSync(path.join(out,'base.p130'),data,{flag:'wx'});
const report={kind:'phase130-private-word-pair-carrier',complete:true,targetsRun:false,
  inputs:[pin(import.meta.filename),pin(receiptFile),original.carrier,...Object.values(original.inputPins)],
  parentReceipt:pin(receiptFile),parentCarrier:original.carrier,carrier:pin(path.join(out,'base.p130')),
  format:'p130-word-pair-v1',stamp:newStamp,originalStamp:stamp,
  sourceIdentity:original.stampBinding,sourceBegin:original.cacheHeader.sourceBegin,sourceEnd:original.cacheHeader.sourceEnd,
  numericTokens:numberCount,unicodeScalars:{before:chars.length,after:[...parts.join('')].length},
  inverseByteIdentity:true,decoder:'Isolated checked decoder replacing only p88_u32 with p130b_u32. All original reconstruction gates required.',
  nativeAdmission:false,scope:'Pure authenticated transport recoding. No producer/Base checking, native term injection, compiler execution, semantic admission or promotion. Full product and alias comparison and independent request output gates remain required.'};
fs.writeFileSync(path.join(out,'receipt.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({carrier:report.carrier,numberCount,unicodeScalars:report.unicodeScalars,stamp:newStamp}));
