// Bounded runtime diagnostic. Source-first semantics, not a TS golden waiver.
import fs from 'node:fs';
import assert from 'node:assert/strict';
const [out]=process.argv.slice(2);
const bits=x=>{const f=new Float32Array(1);f[0]=x;return new Uint32Array(f.buffer)[0];};
const fromBits=u=>new Float32Array(new Uint32Array([u]).buffer)[0];
const payloads=[0x7f800001,0x7f800002,0x7f800003,0x7fbfffff,0x7fc00000,0x7fc00001,0x7fffffff,0xff800001,0xffbfffff,0xffc00000,0xffffffff];
const rows=[];
for(let turn=0;turn<4;turn++)for(const u of payloads){const a=bits(fromBits(u)),b=bits(fromBits(u));assert.equal(a,b);assert.equal(a,(u|0x00400000)>>>0);rows.push({turn,input:u,bits:a});}
const finite=[0,0x80000000,0x00000001,0x007fffff,0x00800000,0x3f800000,0x7f7fffff,0xff7fffff,0x7f800000,0xff800000].map(u=>{const actual=bits(fromBits(u));assert.equal(actual,u);return {input:u,bits:actual};});
const events=[];
const nested={valueOf(){events.push('nested');return fromBits(0x7f800002);}};
const outer={valueOf(){events.push('outer');const n=bits(nested);assert.equal(n,0x7fc00002);return fromBits(0x7f800003);}};
assert.equal(bits(outer),0x7fc00003);assert.deepEqual(events,['outer','nested']);
const boom={valueOf(){events.push('throw');throw 'probe';}};
assert.throws(()=>bits(boom),e=>e==='probe');assert.equal(events.filter(x=>x==='throw').length,1);
fs.writeFileSync(out,JSON.stringify({kind:'phase53-nan-store-runtime-controls',complete:true,pass:true,node:process.version,rows,finite,events,scope:'Fresh native typed arrays; preserves quieted NaN payloads, finite bits and once-only coercion/reentry. Does not assert custom-constructor equivalence or full emitted qualification.'},null,2)+'\n',{flag:'wx'});
