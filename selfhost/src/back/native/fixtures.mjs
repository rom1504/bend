// Checked source-to-native conformance against representative pinned upstream
// programs. Run after tools/typed-driver.mjs --bootstrap and --prepare-base.
import fs from 'node:fs';
import crypto from 'node:crypto';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {loadApi,inspect} from '../../../tools/typed-driver.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../../..');
const upstream=process.env.BEND_UPSTREAM||path.resolve(root,'../upstream-bend');
const output=path.join(root,'build/native-fixtures');fs.mkdirSync(output,{recursive:true});
const fixtures=process.argv.slice(2);
const baselineFixes=[
 'base/list_sort','base/show_read','base/text_ops','base/u32_divmod',
 'compile/fork_width','compile/u32_table_popcount','flatten/literal_rows_cubic',
 'io/request_out_of_band','io/stack_fault_trap','io/tcp_send_slow_peer',
 'proof/fold_assoc','reg/arity_wall','reg/nat_chain','run/bit_walking',
 'run/computed_match','run/evening_program','run/map_set_ops','run/nat_native',
 'run/word_arithmetic','run/word_wrap_chains'];
const ioFixes=['io/stack_fault_trap','io/tcp_send_slow_peer','io/sleep_order',
 'io/spawn_sleep','io/spawn_outlives_main','io/channel_fork_join','io/chan_close_send'];
if(fixtures.includes('--baseline-fixes'))fixtures.splice(fixtures.indexOf('--baseline-fixes'),1,...baselineFixes);
if(fixtures.includes('--io-fixes'))fixtures.splice(fixtures.indexOf('--io-fixes'),1,...ioFixes);
const digest=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const sourceFiles=JSON.parse(fs.readFileSync(path.join(root,'src/compiler.json'),'utf8')).modules;
const identity={
 api:process.env.BEND_TYPED_API?{file:process.env.BEND_TYPED_API,sha256:digest(process.env.BEND_TYPED_API)}:{file:'default',sha256:null},
 runtime:{file:'src/runtime/native/runtime.c',sha256:digest(path.join(root,'src/runtime/native/runtime.c'))},
 sources:sourceFiles.map(file=>({file,sha256:digest(path.join(root,file))})),
 driver:{file:'tools/typed-driver.mjs',sha256:digest(path.join(root,'tools/typed-driver.mjs'))}
};
if(!fixtures.length)fixtures.push(
 'base/list_sort','compile/fork_width','compile/u32_table_popcount',
 'show/nullary_adt','show/string_unicode',
 'compile/closure_partial_app','compile/boxed_ctor_reuse','compile/closure_slab_drop',
 'compile/bang_intrinsic_closure','compile/array_dynamic_closure','compile/array_swap_header',
 'compile/float_compare','compile/float_builtin_agreement',
 'run/array_boxed_get','run/fork_shared_flat','run/array_split_join',
 'reg/array_clone_boxed','reg/array_nested','reg/array_keep_cow',
 'io/marshal_imported_nullary','io/intrinsic_user_name','local/override_add',
 'io/stack_fault_trap','io/tcp_send_slow_peer','io/sleep_order','io/spawn_sleep',
 'io/spawn_outlives_main','io/channel_fork_join','io/chan_close_send');
const api=await loadApi(),results=[];
for(const name of fixtures){
 const input=name.startsWith('local/')?path.join(root,'src/back/native/fixtures',name.slice(6)+'.bend'):path.join(upstream,'tests',name+'.bend');
 const expected=fs.readFileSync(input,'utf8').split('\n').filter(l=>l.startsWith('#|')).map(l=>l.slice(2)).join('\n');
 const expectedExit=Number(expected.match(/(?:^|\n)exit (\d+)$/)?.[1]||0);
 const expectedOutput=expected.replace(/(?:^|\n)exit \d+$/,'');
 const started=Date.now();
 const compiled=await inspect(input,{mode:'native',api});
 const record={fixture:name,status:compiled.status,phase:compiled.phase,expected,diagnostic:compiled.diagnostic||compiled.reason||''};
 if(compiled.status==='ok'){
  const stem=path.join(output,name.replaceAll('/','_')),source=stem+'.c';
  fs.writeFileSync(source,compiled.code);
  const cc=spawnSync(process.env.CC||'clang-19',['-std=c11','-O1','-pthread',source,'-lm','-o',stem],{encoding:'utf8',timeout:120000,maxBuffer:2**20});
  if(cc.status!==0){record.status='error';record.phase='c-compile';record.diagnostic=cc.error?.message||cc.stderr;}
  else{
   record.runs=[];
   for(const threads of [1,4]){
    const run=spawnSync(stem,['--threads',String(threads)],{encoding:'utf8',timeout:30000,maxBuffer:2**20});
    const stdout=run.stdout?.trimEnd()||'';
    const pass=run.status===expectedExit&&(run.stdout+run.stderr).trimEnd()===expectedOutput;
    record.runs.push({threads,pass,exitCode:run.status,stdout,stderr:run.stderr||'',signal:run.signal,error:run.error?.message||''});
    if(!pass){record.status='error';record.phase='runtime';}
   }
  }
 }
 record.milliseconds=Date.now()-started;results.push(record);
 fs.writeFileSync(path.join(output,'report.json'),JSON.stringify({api:process.env.BEND_TYPED_API||'default',identity,results},null,2)+'\n');
 console.log(`${record.status==='ok'?'PASS':'FAIL'} ${name} (${record.milliseconds}ms)${record.status==='ok'?'':' '+record.phase+': '+record.diagnostic.slice(0,240)}`);
}
const passed=results.filter(r=>r.status==='ok').length;
console.log(`${passed}/${results.length} native source fixtures passed; ${path.join(output,'report.json')}`);
if(passed!==results.length)process.exitCode=1;
