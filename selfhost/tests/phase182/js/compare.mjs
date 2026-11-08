// Compile library.bend independently with each compiler before invoking this.
import assert from 'node:assert/strict';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
if(process.argv.length!==4)throw Error('usage: node compare.mjs UPSTREAM.mjs SELFHOST.mjs');
const [upstream,selfhost]=await Promise.all(process.argv.slice(2).map(async p=>(await import(pathToFileURL(path.resolve(p)))).default));
for(const lib of [upstream,selfhost]) {
  for(const n of [0,-0,1,2**48-1,2**53])assert.equal(lib.nat_id(n),n);
  for(const n of [-1,1.5,NaN,Infinity,2**53+2,0n,'1'])assert.throws(()=>lib.nat_id(n),/expected a Nat host number/);
  assert.equal(lib.nat_add(2)(3),5);
  assert.throws(()=>lib.nat_add(2**48-1)(1),/largest immediate/);
  assert.equal(lib.float_id(1.00000008),Math.fround(1.00000008));
  assert.equal(Object.is(lib.float_id(-0),-0),true);
  assert.equal(lib.float_from_nat(4294967297),Math.fround(4294967297));
  assert.equal(lib.float_pow(1)(NaN),1);
  assert.equal(lib.float_pow(-1)(Infinity),1);
  for(const s of ['1 ','\u00a01'])assert.equal(lib.float_read(s).$,'None');
  assert.equal(lib.float_read('1.').value,1);
  assert.equal(lib.float_read('1.e2').value,100);
  assert.equal(lib.text_id('\ud800😀\udfff'),'\ufffd😀\ufffd');
  assert.equal(lib.text_literal(),'a\ufffd\ufffd\ufffd');
  assert.equal(lib.char_literal(),0xffffffff);
  assert.equal(lib.char_id('\ud800'),'\ufffd');
  for(const n of [0,65,0xd800,0xdc00,0x10ffff,0x110000,0xffffffff]) {
    assert.equal(lib.char_round(n),n);
    const c=n>0x10ffff||n>=0xd800&&n<=0xdfff?'\ufffd':String.fromCodePoint(n);
    assert.equal(lib.char_out(n),c);
    assert.equal(lib.text_out(n),c+'x');
    assert.equal(lib.text_size(n),2);
    assert.equal(lib.text_tail(n),'x');
  }
  const box={$:'NatBox',value:7,opaque:{kept:true}};
  assert.equal(lib.box_id(box),box);
  assert.deepEqual(lib.box_make(9),{$:'NatBox',value:9});
  assert.deepEqual(lib.imported_make(11),{$:'Box',value:11});
  assert.equal(lib.imported_take({$:'Box',value:13}),13);
  assert.deepEqual(lib.dotted_make(11),{$:'namespace.Box',value:11});
  assert.equal(lib.dotted_take({$:'namespace.Box',value:13}),13);
  assert.deepEqual(lib.imported_left(7),{$:'Local.Left',value:7});
  assert.deepEqual(lib.imported_right(8),{$:'Local.Right',value:8});
  assert.equal(lib.imported_score({$:'Local.Left',value:7}),7);
  assert.equal(lib.imported_score({$:'Local.Right',value:8}),9);
  assert.deepEqual(lib.pair_array(),Array.from({length:4},()=>({$:'PairData',left:3,right:5})));
  assert.equal(lib['namespace.make'](17),17);
  assert.equal(Object.hasOwn(lib,'__proto__'),true);
  assert.equal(lib.__proto__(19),19);
  const qualified=Object.keys(lib).filter(k=>k.endsWith(':make'));
  assert.equal(qualified.length,1);
  assert.deepEqual(lib[qualified[0]](23),{$:'Box',value:23});
}
assert.deepEqual(Object.keys(selfhost).sort(),Object.keys(upstream).sort());
console.log('phase182 independently compiled JS host ABI controls passed');
