// Tiny read-only host experiment: no compiler or benchmark invocation.
import fs from 'node:fs';
const [mode,out]=process.argv.slice(2);
const bits= mode==='old' ? x=>new Uint32Array(new Float32Array([x]).buffer)[0]
  : mode==='store' ? x=>{const f=new Float32Array(1);f[0]=x;return new Uint32Array(f.buffer)[0];}
  : x=>{const d=new DataView(new ArrayBuffer(4));d.setFloat32(0,x,true);return d.getUint32(0,true);};
const fromBits=u=>new Float32Array(new Uint32Array([u]).buffer)[0];
function as(u){return fromBits(u);}
function table(n){return as(n===0?2139095041:n===1?2139095042:2139095043);}
function expected(n){return n===0?2139095041:n===1?2139095042:2139095043;}
const rows=[];
for(let turn=0;turn<3;turn++)for(let n=39;n>=0;n--){
 const a=bits(table(n));const b=bits(as(expected(n)));
 rows.push({turn,n,a,b,equal:a===b});
}
const finite=[0,-0,1,-1,Infinity,-Infinity,Math.PI].map(x=>({input:Object.is(x,-0)?'-0':String(x),bits:bits(x)}));
fs.writeFileSync(out,JSON.stringify({mode,node:process.version,counts:[0,1,2].map(t=>rows.filter(r=>r.turn===t&&r.equal).length),mismatches:rows.filter(r=>!r.equal),sample:rows.slice(0,3),finite},null,2)+'\n',{flag:'wx'});
