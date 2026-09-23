// Host toolchain orchestration. Bend code has already emitted the complete
// program; this module only selects a compiler, links libraries and runs it.
// Build protocol follows pinned upstream bend2/main.ts (see NOTICE).
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';

function listDirectory(directory) {
  try { return fs.readdirSync(directory); } catch { return []; }
}

export function findClang({gpu=false,env=process.env}={}) {
  const numbered=[...new Set((env.PATH||'').split(path.delimiter)
    .flatMap(listDirectory).filter(name=>/^clang-\d+$/.test(name)))]
    .sort((a,b)=>Number(b.slice(6))-Number(a.slice(6)));
  const candidates=[...new Set([...(env.CC?[env.CC]:[]),'clang',...numbered])];
  const found=[];
  for(const command of candidates) {
    const probe=spawnSync(command,['--version'],{env,encoding:'utf8',timeout:3000});
    const match=/^(Apple )?(?:\w+ )?clang version (\d+)/m.exec(probe.stdout||'');
    const required=gpu?(match?.[1]?17:19):14;
    if(match&&Number(match[2])>=required) return {command,version:Number(match[2]),apple:!!match[1]};
    found.push(match?`${command} version ${match[2]}`:command);
  }
  throw Error(`Native ${gpu?'GPU':'CPU'} builds require Clang ${gpu?'19 (Apple Clang 17)':'14'} or newer; searched ${found.join(', ')}.`);
}

export function nativeBuildPlan({source,file,binary,target='auto',platform=process.platform,env=process.env,exists=fs.existsSync}) {
  if(!['auto','cpu','metal','cuda'].includes(target)) throw Error('Unknown native target: '+target);
  const bangs=Number(/^#define BANGS\s+(\d+)\s*$/m.exec(source)?.[1]||0);
  const mac=platform==='darwin';
  const cuda=env.CUDA_HOME||'/usr/local/cuda';
  const cudaAvailable=exists(path.join(cuda,'include/nvrtc.h'));
  const selected=target==='auto'?(bangs&&(mac||cudaAvailable)?(mac?'metal':'cuda'):'cpu'):target;
  if(selected==='metal'&&!mac) throw Error('Metal builds require an Apple host.');
  if(selected==='cuda'&&!cudaAvailable) throw Error('CUDA builds require nvrtc.h under CUDA_HOME/include (default /usr/local/cuda).');
  const gpu=selected!=='cpu';
  const objc=mac&&(gpu||/^#import /m.test(source))?['-x','objective-c','-fobjc-arc','-fmodules']:[];
  const libraries=[['X11','X11'],['alsa','asound']].flatMap(([header,library])=>
    !mac&&source.includes('#include <'+header+'/')?['-l'+library]:[]);
  const common=[...objc,'-std=c11','-O3',path.resolve(file),'-lpthread','-lm',...libraries,'-o',path.resolve(binary)];
  const args=selected==='metal'?['-DBEND_METAL=1',...common]:selected==='cuda'?
    ['-DBEND_CUDA=1','-I'+path.join(cuda,'include'),'-L'+path.join(cuda,'lib64'),'-L'+path.join(cuda,'lib'),...common,'-lcuda','-lnvrtc']:common;
  return {target:selected,gpu,bangs,args,deviceArgs:gpu?['--gpu-build']:null};
}

export function buildNative({source,file,binary,target='auto',cwd,timeoutMs=120000,env=process.env}) {
  let plan,compiler;
  try {
    plan=nativeBuildPlan({source,file,binary,target,env});
    compiler=findClang({gpu:plan.gpu,env});
  } catch(error) {
    return {status:'unsupported',phase:'compile',reason:error.message,checked:true};
  }
  const started=performance.now();
  for(const [command,args,phase] of [[compiler.command,plan.args,'compile'],
    ...(plan.deviceArgs?[[path.resolve(binary),plan.deviceArgs,'device-compile']]:[])]) {
    const remaining=Math.max(1,timeoutMs-(performance.now()-started));
    const result=spawnSync(command,args,{cwd,env,encoding:'utf8',timeout:Math.ceil(remaining),maxBuffer:2**20});
    if(result.error?.code==='ETIMEDOUT') return {status:'timeout',phase:'compile',reason:`Native ${phase} exceeded timeout.`,checked:true};
    if(result.error||result.status!==0) return {status:'error',phase:'compile',diagnostic:result.error?.message||result.stderr||result.stdout||`${command} failed`,exitCode:result.status||1,checked:true};
  }
  return {status:'ok',phase:'compile',binary:path.resolve(binary),target:plan.target,bangs:plan.bangs,compiler,checked:true};
}
