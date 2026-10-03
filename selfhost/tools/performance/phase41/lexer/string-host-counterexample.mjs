// Cheapest falsifier for adding native String to scalar purity unchanged.
// This deliberately DOES NOT implement or claim a lexer optimization.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [inputArg,outArg]=process.argv.slice(2);
assert(inputArg&&outArg,'usage: node string-host-counterexample.mjs emitted-lexer.mjs fresh-output-dir');
const input=fs.realpathSync(inputArg),out=path.resolve(outArg);
assert(out.startsWith(path.resolve('selfhost/build/phase41')+path.sep));
assert(path.basename(out).startsWith('lexer-'));
assert(!fs.existsSync(out));
const source=fs.readFileSync(input,'utf8');
const hash=x=>createHash('sha256').update(x).digest('hex');
assert(source.includes('function regionHostGuard()'));
assert(source.includes('function scalarGuard(names)'));
assert(source.includes('function fields(k,x)'));
const addon=`
export function phase41StringGuardCounterexample(){
 const observations=[];
 const before=regionHostGuard()&&scalarGuard([]);
 const cp=Object.getOwnPropertyDescriptor(String.prototype,'codePointAt');
 const fc=Object.getOwnPropertyDescriptor(String,'fromCodePoint');
 let calls=0;
 try{
  Object.defineProperty(String.prototype,'codePointAt',{...cp,value:function(...a){++calls;return cp.value.apply(this,a);}});
  const guard=regionHostGuard()&&scalarGuard([]);
  const full=fields('SCon','\\u{1f600}z');
  observations.push({hook:'String.prototype.codePointAt',before,guard,calls,completeHead:full[0],completeTail:full[1]});
 }finally{Object.defineProperty(String.prototype,'codePointAt',cp);}
 calls=0;
 try{
  Object.defineProperty(String,'fromCodePoint',{...fc,value:function(...a){++calls;return fc.value.apply(this,a);}});
  const guard=regionHostGuard()&&scalarGuard([]);
  const full=ctor('SCon',[128512,'z']);
  observations.push({hook:'String.fromCodePoint',before,guard,calls,completeString:full});
 }finally{Object.defineProperty(String,'fromCodePoint',fc);}
 return observations;
}
`;
fs.mkdirSync(out,{recursive:false});
const emitted=path.join(out,'instrumented.mjs');
fs.writeFileSync(emitted,source+addon,{flag:'wx'});
const mod=await import(pathToFileURL(emitted));
const observations=mod.phase41StringGuardCounterexample();
assert(observations.every(x=>x.before&&x.guard&&x.calls>0));
assert.equal(observations[0].completeHead,128512);
assert.equal(observations[0].completeTail,'z');
assert.equal(observations[1].completeString,'😀z');
const report={kind:'phase41-static-proposal-falsifier',complete:true,
 claim:'Existing numeric/scalar guard does not establish callback-free native String graph',
 optimized:false,compilerAdmission:false,input:{path:input,sha256:hash(source)},
 tool:{path:import.meta.filename,sha256:hash(fs.readFileSync(import.meta.filename))},
 instrumented:{path:emitted,sha256:hash(source+addon)},observations};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify(report));
