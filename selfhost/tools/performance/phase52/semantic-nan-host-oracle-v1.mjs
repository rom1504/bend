// Diagnostic only: JS Number/Float32Array payload behavior is host-specific.
// Does not replace the maintained Bend/C golden40 or waive TS differential errors.
import fs from 'node:fs';
import assert from 'node:assert/strict';
const [out]=process.argv.slice(2);assert(out&&!fs.existsSync(out));
const bits=x=>new Uint32Array(new Float32Array([x]).buffer)[0];
const fromBits=u=>new Float32Array(new Uint32Array([u]).buffer)[0];
const literalTable=[NaN,NaN,NaN];
const payloads=[2139095041,2139095042,2139095043];
const rows=payloads.map((payload,index)=>({index,payload,literalBits:bits(literalTable[index]),convertedBits:bits(fromBits(payload))}));
let hostTableOracle=0;
for(let index=0;index<40;index++){const row=Math.min(index,2);hostTableOracle+=bits(literalTable[row])===bits(fromBits(payloads[row]))?1:0;}
fs.writeFileSync(out,JSON.stringify({kind:'phase52-nan-payload-host-diagnostic',complete:true,passGate:false,sourceGolden:40,hostTableOracle,node:process.version,rows,scope:'Independent host operations mirror upstream JS literal NaN table lowering. NaN payload representation is implementation-dependent; this diagnostic never changes or satisfies the source golden or differential gate.'},null,2)+'\n',{flag:'wx'});
