// Execute the selected production Bend graph algorithm, checked by pinned TS.
// The oracle uses independent DFS sets, not the production bitset/Warshall code.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
import {assemble} from '../../assemble.mjs';

const [sourceRootArg,upstreamArg,outArg]=process.argv.slice(2);
assert(sourceRootArg&&upstreamArg&&outArg,
  'worker-graph-controls-v1.mjs SOURCE_ROOT UPSTREAM NEW_OUT');
const sourceRoot=path.resolve(sourceRootArg),upstream=path.resolve(upstreamArg),out=path.resolve(outArg);
fs.mkdirSync(out);
const report={kind:'phase45-worker-graph-controls',complete:false,pass:false,
  scope:'Production Bend graph algorithm checked/executed through pinned TypeScript; not execution of the self-hosted compiler API.',
  inputs:[],cases:[],auxiliary:[]};
const identity=file=>{const bytes=fs.readFileSync(file);return {file:fs.realpathSync(file),
  sha256:createHash('sha256').update(bytes).digest('hex'),bytes:bytes.length};};
const pin=file=>{const row=identity(file);report.inputs.push(row);return row;};
const write=(name,text)=>{const file=path.join(out,name);fs.writeFileSync(file,text,{flag:'wx'});return file;};
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const literal={$:'JWLiteral',code:'0'},done={$:'JWReturn',value:literal};
const call=target=>({$:'JWDirectCall',slot:0,target,args:list([])});
const branch=(yes,no)=>({$:'JWCase',layout:'tagged',name:'Witness',input:literal,yes:list(yes),no:list(no)});
function declarations(text,names){
  const starts=[...text.matchAll(/^(?:@unsafe\n)?(?:type|law|def)\s+([^\s(<:]+)/gm)];
  return names.map(name=>{const index=starts.findIndex(m=>m[1]===name);assert(index>=0,'Missing production declaration '+name);
    return text.slice(starts[index].index,starts[index+1]?.index??text.length).trimEnd()+'\n';}).join('\n');
}
function array(xs){const out=[];while(xs?.$==='Con'){assert(out.length<100);out.push(xs.head);xs=xs.tail;}
  assert.equal(xs?.$,'Nil');return out;}
function observed(value){if(value?.$==='None')return null;assert.equal(value?.$,'Some');return array(value.value);}
function oracle(n,edges,invalid=false){
  if(n===0||n>96||invalid||edges.some(([from,to])=>from>=n||to>=n))return null;
  const adjacent=Array.from({length:n},()=>[]);for(const [from,to]of edges)adjacent[from].push(to);
  const reach=adjacent.map((_,start)=>{const seen=new Set(),pending=[start];while(pending.length){const node=pending.pop();
    if(seen.has(node))continue;seen.add(node);pending.push(...adjacent[node]);}return seen;});
  return reach.map((row,node)=>{for(let at=0;at<n;at++)if(row.has(at)&&reach[at].has(node))return at;
    throw Error('Oracle lost reflexivity');});
}
function functions(n,edges,invalid=false,overrides={}){
  return Array.from({length:n},(_,at)=>({$:'JWFunction',name:'function'+at,arity:0,
    code:list(overrides[at]??[...edges.filter(([from])=>from===at).map(([,to])=>call(to)),done]),
    valid:!(invalid&&at===n-1)}));
}
try{
  pin(import.meta.filename);pin(process.execPath);pin(new URL('../../assemble.mjs',import.meta.url));
  const configFile=path.join(sourceRoot,'src/compiler.json');pin(configFile);
  const config=JSON.parse(fs.readFileSync(configFile,'utf8'));
  const rev=spawnSync('git',['-C',upstream,'rev-parse','HEAD'],{encoding:'utf8',timeout:10000});
  assert.equal(rev.status,0,rev.stderr);assert.equal(rev.stdout.trim(),config.upstream);
  for(const file of ['bend2/bend.ts','bend2/comp.ts','bend2/base.bend'])pin(path.join(upstream,file));
  const modelFile=path.join(sourceRoot,'src/back/js/ir/worker-model.bend'),graphFile=path.join(sourceRoot,'src/back/js/ir/worker-graph.bend');
  const coreFile=path.join(sourceRoot,'src/core/term.bend');for(const file of [modelFile,graphFile,coreFile])pin(file);
  const support=write('support.bend','import Base\n\n'+declarations(fs.readFileSync(coreFile,'utf8'),['kc']));
  const model=write('worker-model-subset.bend',declarations(fs.readFileSync(modelFile,'utf8'),['JWValue','JWInstruction','JWFunction']));
  const graph=write('worker-graph.bend',fs.readFileSync(graphFile,'utf8'));
  const assembled=path.join(out,'controls.bend');assemble([support,model,graph],assembled);
  const stage0=path.resolve(import.meta.dirname,'../../stage0-library.mjs');pin(stage0);
  const output=path.join(out,'controls.mjs');
  const command=[process.execPath,'--stack-size=4096','--max-old-space-size=1024',stage0,assembled,output,
    'jw_components','jw_components_rows','jw_same_component'];
  const compiled=spawnSync(command[0],command.slice(1),{encoding:'utf8',timeout:120000,maxBuffer:4*1024*1024,
    env:{...process.env,BEND_UPSTREAM:upstream}});
  write('compile.stdout',compiled.stdout??'');write('compile.stderr',compiled.stderr??'');
  report.compilation={command,status:compiled.status,signal:compiled.signal,error:compiled.error?.message,
    source:identity(assembled)};
  assert.equal(compiled.status,0,(compiled.stderr??'')+'\n'+(compiled.error?.message??''));
  report.compilation.output=identity(output);
  const api=(await import(pathToFileURL(output))).default;
  const test=(id,n,edges,invalid=false,overrides={})=>{
    const expected=oracle(n,edges,invalid),value=observed(api.jw_components(list(functions(n,edges,invalid,overrides))));
    if(id==='mutual-components')assert.deepEqual(expected,[0,1,0,1,0,5]);
    if(id==='nested-case-edges')assert.deepEqual(expected,[0,0,2,0,4,2]);
    if(id==='word-boundaries-31-63-95')assert.deepEqual(expected,
      Array.from({length:96},(_,i)=>[31,63,95].includes(i)?31:i));
    assert.deepEqual(value,expected,id);report.cases.push({id,n,edges,invalid,expected,value});};
  test('empty-refused',0,[]);test('singleton',1,[]);test('disconnected',5,[]);
  test('acyclic-chain',6,[[0,1],[1,2],[2,3],[3,4],[4,5]]);
  test('self-cycles',4,[[0,0],[2,2]]);
  test('mutual-components',6,[[0,2],[2,4],[4,0],[1,3],[3,1],[4,5]]);
  const nestedEdges=[[0,1],[0,2],[0,3],[0,4],[1,0],[3,0],[2,5],[5,2]];
  test('nested-case-edges',6,nestedEdges,false,{0:[branch([call(1),done],[call(2),branch([call(3),done],[call(4),done])])]});
  test('word-boundaries-31-63-95',96,[[0,95],[31,63],[63,95],[95,31]]);
  test('boundary-chain-distinct',96,[[0,31],[31,32],[32,63],[63,64],[64,95]]);
  test('maximum-96',96,[]);test('oversized-97-refused',97,[]);
  test('target-at-limit-refused',2,[[0,2]]);test('target-u32-max-refused',2,[[1,4294967295]]);
  test('nested-invalid-target-refused',2,[[0,2]],false,{0:[branch([done],[branch([call(2),done],[done])])]});
  test('invalid-function-refused',3,[],true);
  const missing=observed(api.jw_components_rows({$:'Some',value:list([{$:'JWReach',lo:1,mid:0,hi:0}])},2));
  assert.equal(missing,null);report.auxiliary.push({id:'missing-reachability-row-refused',value:missing});
  const labels=list([0,1,0]);for(const [a,b,want]of [[0,2,true],[0,1,false],[0,3,false],[4294967295,0,false]]){
    const value=api.jw_same_component(labels,a,b);assert.equal(value,want);
    report.auxiliary.push({id:'same-component-bounds',a,b,value,want});}
  for(const input of report.inputs)assert.deepEqual(identity(input.file),input,'Changed input');
  report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
write('report.json',JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,
  auxiliary:report.auxiliary.length,error:report.error}));
