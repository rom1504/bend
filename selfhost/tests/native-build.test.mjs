import assert from 'node:assert/strict';
import test from 'node:test';
import {nativeBuildPlan} from '../tools/native-build.mjs';

const input={file:'/tmp/program.c',binary:'/tmp/program',env:{},exists:()=>false};
test('CPU fallback links the foreign libraries that the emitted source uses',()=>{
  const plan=nativeBuildPlan({...input,platform:'linux',source:'#define BANGS 1\n#include <X11/Xlib.h>\n#include <alsa/asoundlib.h>\n'});
  assert.equal(plan.target,'cpu');
  assert.equal(plan.deviceArgs,null);
  assert(plan.args.includes('-lX11')&&plan.args.includes('-lasound'));
});
test('CUDA host build embeds a separately compiled device program',()=>{
  const plan=nativeBuildPlan({...input,platform:'linux',source:'#define BANGS 2\n',env:{CUDA_HOME:'/opt/cuda'},exists:p=>p==='/opt/cuda/include/nvrtc.h'});
  assert.equal(plan.target,'cuda');
  for(const option of ['-DBEND_CUDA=1','-I/opt/cuda/include','-L/opt/cuda/lib64','-L/opt/cuda/lib','-lcuda','-lnvrtc']) assert(plan.args.includes(option),option);
  assert.deepEqual(plan.deviceArgs,['--gpu-build']);
});
test('Metal uses Objective-C ARC while explicit CPU can avoid GPU build',()=>{
  const metal=nativeBuildPlan({...input,platform:'darwin',source:'#define BANGS 1\n'});
  assert.equal(metal.target,'metal');
  for(const option of ['-DBEND_METAL=1','objective-c','-fobjc-arc','-fmodules']) assert(metal.args.includes(option));
  const cpu=nativeBuildPlan({...input,platform:'darwin',source:'#define BANGS 1\n',target:'cpu'});
  assert.equal(cpu.target,'cpu');assert.equal(cpu.gpu,false);
  const audio=nativeBuildPlan({...input,platform:'darwin',source:'#define BANGS 0\n#import <Foundation/Foundation.h>\n'});
  assert(audio.args.includes('objective-c'));
});
test('an explicit unavailable GPU target cannot silently fall back to CPU',()=>{
  assert.throws(()=>nativeBuildPlan({...input,platform:'linux',source:'',target:'metal'}),/Apple host/);
  assert.throws(()=>nativeBuildPlan({...input,platform:'linux',source:'',target:'cuda'}),/nvrtc.h/);
});
