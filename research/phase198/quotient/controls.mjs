// Independent exact integer oracle for the actual checked Bend plan.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';
const arg=Object.fromEntries(Array.from({length:(process.argv.length-2)/2},(_,i)=>process.argv.slice(2+2*i,4+2*i)));
const out=path.resolve(arg['--out']);fs.mkdirSync(out);
const auth=JSON.parse(fs.readFileSync(arg['--api']));
if(!auth.complete||!auth.checked)throw Error('unchecked');
verify(auth.source);verify(auth.api);
const api=(await import(pathToFileURL(auth.api.file))).default;
let admitted=0,refused=0,shift=0,values=0;
const sample={};
let seed=124151398;
const random=()=> (seed=(Math.imul(1664525,seed)+1013904223)>>>0);
const divisors=[...Array(65536).keys(),65536,65537,16777216,2147483648,2147483649,4294967295];
for(const d of divisors){
  const r=api.p198q_plan(d);
  if(d<32 || d>65535)sample[d]=r;
  if(r.$==='P198NoQuot'){refused++;continue;}
  admitted++;let m,s;
  if(r.$==='P198Shift'){
    s=BigInt(r.shift);if(1n<<s!==BigInt(d))throw Error('shift');shift++;
  }else if(r.$==='P198Magic'){
    m=BigInt(r.multiplier);s=BigInt(r.shift);
    const error=m*BigInt(d)-(1n<<s);
    if(m<=0n||m>0xffffffffn||s<32n||s>=64n||error<0n||error>1n<<(s-32n))throw Error('bad proof '+d);
  }else throw Error(r.$);
  for(const word of [0,1,d-1,d,d+1,4294967295,4294967296,4294967297,random(),2**40+random()]){
    const x=BigInt(word>>>0),q=m===undefined?x>>s:x*m>>s,rem=x-q*BigInt(d);
    if(q!==x/BigInt(d)||rem!==x%BigInt(d))throw Error('quotient '+d+','+word);
    values++;
  }
}
const report={complete:true,source:auth.source,api:auth.api,method:pin(fileURLToPath(import.meta.url)),
  divisors:divisors.length,admitted,refused,shifts:shift,wordChecks:values,sample,
  scope:'Every admitted magic plan satisfies the sufficient integer inequality for all possible U32 words. The finite values also exercise high raw input bits. Full compiled products and complete machine backend require independent gates.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log({admitted,refused,shift,values});
