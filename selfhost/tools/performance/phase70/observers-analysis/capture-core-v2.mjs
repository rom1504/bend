// Root-only bounded source query. No C emission or native execution.
// Usage: node capture-core.mjs CHECKED_API INPUT_BEND FRESH_PHASE70_OUT [DEF ...]
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
const [apiArg,inputArg,outArg,...requested]=process.argv.slice(2);
assert(apiArg&&inputArg&&outArg,'CHECKED_API INPUT_BEND FRESH_PHASE70_OUT [DEF ...]');
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../../../../..');
const api=fs.realpathSync(apiArg),input=fs.realpathSync(inputArg),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase70')+path.sep)&&!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});
const pin=file=>{const b=fs.readFileSync(file);return{file:fs.realpathSync(file),sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
const driver=path.join(root,'selfhost/tools/typed-driver.mjs');
const wanted=requested.length?requested:['Map.bit.go','Map.bit.go.chr','Map.bit.go.rec','Map.bit.chr','Map.bit.u','String.cmp','String.cmp.fin','String.cmp.rec','Char.cmp'];
const source=fs.readFileSync(api,'utf8');
for(const n of ['nc_definition','nc_compact','lookup','nc_live_names','nq_layout_type'])assert(source.includes('function $'+n+'$('),n);
const suffix=String.raw`
export function phase70ObserverCore(book,names) {
  const c=(f,...a)=>run_loop(f(...a));
  const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
  const array=x=>{const a=[];while(x?.$==='Con'){a.push(x.head);x=x.tail;if(a.length>20000)throw Error('list budget');}assertDiagnostic(x?.$==='Nil','malformed list');return a;};
  function assertDiagnostic(ok,msg){if(!ok)throw Error(msg);}
  let remaining=150000;
  function term(t){if(--remaining<0)throw Error('term budget');return {tag:c($tg$,t),name:c($nm$,t),id:c($ix$,t),quant:c($qt$,t),kids:array(c($ks$,t)).map(term),removed:array(c($rm$,t))};}
  function definition(d){return{name:c($dn$,d),kind:c($dk$,d),arity:c($da$,d),templates:c($dx$,d),native:c($db$,d),unsafe:c($du$,d),type:term(c($dt$,d)),value:term(c($dv$,d)),ctors:array(c($dc$,d)).map(definition)};}
  const live=array(c($nc_live_names$,book,list(names),nil));
  const records=[];
  for(const name of names){const d=c($lookup$,book,name);assertDiagnostic(c($dk$,d)==='Def','missing requested definition '+name);records.push({name,definition:definition(d),arity:c($nd_arity$,book,name),erased:term(c($nc_erase$,book,c($dv$,d))),nativeBody:term(c($nc_compact$,c($nc_definition$,book,d,0)))});}
  function telescope(ty){const parameters=[];for(let i=0;i<32;i++){const h=c($nq_layout_type$,book,ty);if(c($tg$,h)!=='All')return{parameters,result:term(h)};if(c($qt$,h)!==0)parameters.push(term(c($nq_layout_type$,book,c($kid$,h,0))));ty=c($kid$,h,1);}throw Error('telescope budget');}
  const dependencies=live.map(name=>{const d=c($lookup$,book,name),p=c($nc_primitive_name$,name),isNative=c($nc_native_def$,d);return{...definition(d),telescope:telescope(c($dt$,d)),nativePrimitive:isNative===true||isNative?.$==='True'?p:null,scalarPrimitive:c($nd_scalar_known$,p),nativeBody:term(c($nc_compact$,c($nc_definition$,book,d,0)))};});
  const adts=array(book).filter(d=>c($dk$,d)==='ADT').map(d=>({...definition(d),constructorIdentities:array(c($dc$,d)).map(k=>({name:c($dn$,k),identity:c($nc_ctor_identity$,book,c($dn$,k))}))}));
  return {records,dependencies,adts,visitedNodes:150000-remaining};
}
`;
const derived=path.join(out,'query-api.mjs');
fs.writeFileSync(derived,source+suffix,{flag:'wx'});
const inputs=[pin(api),pin(input),pin(driver),pin(fileURLToPath(import.meta.url)),pin(path.join(root,'selfhost/dist/base.bend')),pin(path.join(root,'selfhost/src/runtime.mjs'))];
const report={kind:'phase70-observer-core-capture-v2',complete:false,names:wanted,inputs,derivation:{original:inputs[0],output:pin(derived),append:suffix,originalPrefixByteIdentical:fs.readFileSync(derived,'utf8').slice(0,source.length)===source}};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try {
  process.env.BEND_TYPED_API=api;process.env.BEND_BASE=path.join(root,'selfhost/dist/base.bend');process.env.BEND_TYPED_RUNTIME=path.join(root,'selfhost/src/runtime.mjs');
  const A=await import(pathToFileURL(derived));
  const capture=book=>{report.core=A.phase70ObserverCore(book,wanted);throw Error('PHASE70_OBSERVER_CORE_CAPTURE_COMPLETE');};
  const wrapped={...A.default,nc_compile:capture,nc_compile_checked:capture};
  const D=await import(pathToFileURL(driver));
  const graph=D.discoverSources(wrapped,input);for(const file of graph.files)inputs.push(pin(file));
  report.observation=await D.inspect(input,{mode:'native',api:wrapped,withReport:true});
  assert(report.core,'checked book not captured');
  assert(String(report.observation.diagnostic??report.observation.reason??'').includes('PHASE70_OBSERVER_CORE_CAPTURE_COMPLETE'),JSON.stringify(report.observation));
  for(const old of inputs)assert.deepEqual(pin(old.file),old);
  assert.equal(fs.readFileSync(derived,'utf8'),source+suffix);
  report.complete=true;report.inputsUnchanged=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,definitions:report.core?.records.length,nodes:report.core?.visitedNodes,error:report.error}));
