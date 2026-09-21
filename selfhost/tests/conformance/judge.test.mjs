import assert from 'node:assert/strict';
import test from 'node:test';
import {judge,rendered} from '../../tools/conformance/judge.mjs';
const negative={negative:true,main:true,expected:'Error: expected Nat, observed U32\nexit 1'};
test('unsupported parser rejection cannot pass a checker negative',()=>{
  assert.equal(judge(negative,'check',{status:'error',phase:'parse',diagnostic:'Error: unsupported law',exitCode:1},{check:true}).status,'fail');
});
test('unchecked adapter never receives checker credit',()=>{
  assert.equal(judge(negative,'check',{status:'error',phase:'check',checked:true,diagnostic:negative.expected,exitCode:1},{check:false}).status,'unsupported');
});
test('a matching diagnostic still requires actual checker completion',()=>{
  assert.equal(judge(negative,'check',{status:'error',phase:'runtime',checked:false,diagnostic:negative.expected,exitCode:1},{check:true}).status,'fail');
});
test('runtime expected errors get no type/proof checker rejection credit',()=>{
  assert.equal(judge(negative,'check',{status:'error',phase:'runtime',checked:true,diagnostic:negative.expected,exitCode:1},{check:true}).evidence,'runtime-rejection');
});
test('proper checker rejection gets separate evidence',()=>{
  assert.equal(judge(negative,'check',{status:'error',phase:'check',checked:true,diagnostic:negative.expected,exitCode:1},{check:true}).evidence,'checker-rejection');
});
test('matching frontend rejection is never a checker rejection',()=>{
  assert.equal(judge(negative,'check',{status:'error',phase:'parse',diagnostic:negative.expected,exitCode:1},{check:true}).evidence,'frontend-rejection');
});
test('timeouts and crashes never count as successful rejection',()=>{
  for(const status of ['timeout','crash']) assert.equal(judge(negative,'check',{status},{check:true}).status,status);
});
test('runtime exit failure cannot pass by matching stdout alone',()=>{
  assert.equal(judge({negative:false,expected:'42'},'js',{status:'error',phase:'runtime',stdout:'42',exitCode:1},{js:true}).status,'fail');
  assert.equal(rendered({stdout:'42\n',exitCode:1}),'42\nexit 1');
});
test('CPU fallback is not GPU conformance',()=>{
  assert.equal(judge({expected:'42'},'cuda',{status:'ok',phase:'runtime',stdout:'42',exitCode:0},{cuda:true}).status,'fail');
});
test('ordered combined runtime output preserves stderr and nonzero exit evidence',()=>{
  const result={status:'error',phase:'runtime',output:'to-stderr\nto-stdout\nNo such file or directory\n',stdout:'',stderr:'',exitCode:2,checked:true};
  assert.equal(judge({negative:false,expected:'to-stderr\nto-stdout\nNo such file or directory\nexit 2'},'js',result,{js:true}).status,'pass');
});
test('upstream printability refusal with its exact explanatory suffix is exempt',()=>{
  const result={status:'error',phase:'compile',checked:true,diagnostic:"Error: main's type Type cannot be printed (a function, a Type, an erased or dependent field)",exitCode:1};
  assert.equal(judge({negative:false},'js',result,{js:true}).status,'not-applicable');
  assert.equal(judge({negative:false},'js',{...result,diagnostic:'Error: unsupported Type'}, {js:true}).status,'fail');
});
