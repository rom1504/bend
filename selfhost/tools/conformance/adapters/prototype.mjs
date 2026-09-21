import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';

export const name='unchecked-prototype';
export const capabilities={parse:true,check:false,interpreter:false,js:true,native:false,metal:false,cuda:false,
  modules:false,foreign:false,dependentTypes:false,affine:false,termination:false,proofs:false};

export async function probe({test,lane,project,workdir,timeoutMs}) {
  if(!capabilities[lane]) return {status:'unsupported',reason:`Prototype does not implement ${lane}.`};
  process.env.BEND_LIBRARY_MODE='1';
  const {G,call,list}=await import(pathToFileURL(process.env.BEND_CONFORMANCE_COMPILER||path.join(project,'dist/bend2c.mjs')));
  const source=fs.readFileSync(test.file,'utf8');
  let ast;
  try {
    ast=call(G.top,[call(G.lex,[source,1,0,0,list([])]),list([])]).a[0];
    const diagnostic=call(G.first_error,[ast]);
    if(diagnostic) return {status:'error',phase:'parse',diagnostic,exitCode:1,checked:false};
  } catch(e) { return {status:'error',phase:'parse',diagnostic:String(e),exitCode:1,checked:false}; }
  if(lane==='parse') return {status:'ok',phase:'parse',exitCode:0,checked:false};
  try {
    const runtime=fs.readFileSync(process.env.BEND_CONFORMANCE_RUNTIME||path.join(project,'src/runtime.mjs'),'utf8');
    const file=path.join(workdir,'program.mjs');
    fs.writeFileSync(file,runtime+'\n'+call(G.emit_top,[ast.a[2]])+'\nawait runmain();\n');
    const child=spawnSync(process.execPath,[file],{cwd:workdir,encoding:'utf8',timeout:Math.max(100,timeoutMs-250),maxBuffer:2**20});
    if(child.error?.code==='ETIMEDOUT') return {status:'timeout',phase:'runtime',reason:'Runtime exceeded timeout.'};
    return {status:child.status===0?'ok':'error',phase:'runtime',stdout:child.stdout||'',stderr:child.stderr||'',exitCode:child.status??1,checked:false};
  } catch(e) {return {status:'error',phase:'compile',diagnostic:String(e),exitCode:1,checked:false};}
}
