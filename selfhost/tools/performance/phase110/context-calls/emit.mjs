// Checked-source transport and explicit malformed-certificate probes only.
// All admission, closure, context-call transformation and emission run in Bend.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
const script=fileURLToPath(import.meta.url),root=path.resolve(path.dirname(script),'../../../../..');
const [apiArg,captureArg,outArg]=process.argv.slice(2);
if(!outArg)throw Error('usage: emit.mjs CONTEXT_API BASE_STRING_CAPTURE FRESH_OUT');
const apiFile=path.resolve(apiArg),capture=path.resolve(captureArg),out=path.resolve(outArg);
if(!out.startsWith(path.join(root,'selfhost/build/phase110')+path.sep)||fs.existsSync(out))throw Error('fresh Phase110 output required');
const pin=file=>{const data=fs.readFileSync(file);return{file:path.resolve(file),bytes:data.length,sha256:crypto.createHash('sha256').update(data).digest('hex')};};
const verify=row=>{const actual=pin(path.resolve(root,row.file));if(actual.bytes!==row.bytes||actual.sha256!==row.sha256)throw Error('changed '+row.file);return actual;};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const list=items=>items.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=value=>{const items=[];while(value?.$==='Con'){items.push(value.head);value=value.tail;}if(value?.$!=='Nil')throw Error('invalid Bend list');return items;};
const clone=value=>JSON.parse(JSON.stringify(value));
const find=(value,predicate)=>{if(value&&typeof value==='object'){if(predicate(value))return value;for(const item of Object.values(value)){const found=find(item,predicate);if(found)return found;}}return null;};
const apiReportFile=path.join(path.dirname(apiFile),'report.json'),apiReport=read(apiReportFile);
if(!apiReport.complete||apiReport.api?.sha256!==pin(apiFile).sha256)throw Error('complete source-bound API report required');
verify(apiReport.source);verify(apiReport.api);
const api=(await import(pathToFileURL(apiFile))).default;
for(const name of ['nxe_lower_runtime_library','nx110rt_verify','nx110rt_qbe','nx110rt_c','nx110ctx_prepare','nx110ctx_verify','nx110ctx_qbe','nx110ctx_c','nx110ctx_control_report'])if(typeof api[name]!=='function')throw Error('missing API '+name);
const captureFile=path.join(capture,'report.json'),captured=read(captureFile),typedFile=path.join(capture,'checked-graph.json'),erasedFile=path.join(capture,'native-facts.json');
if(captured.kind!=='phase109-checked-native-facts'||!captured.complete||captured.result?.checked!==true||captured.result?.typeAccepted!==true||captured.result?.exitCode!==0)throw Error('actual checked capture required');
const controlFile=path.join(root,'selfhost/tools/performance/phase110/controls/admission/string-append/manifest.json'),control=read(controlFile);
if(!captured.sourceFiles.some(row=>row.sha256===control.source.sha256&&row.bytes===control.source.bytes))throw Error('capture does not bind frozen actual Base wrapper');
for(const file of [typedFile,erasedFile])if(!captured.products.some(row=>path.resolve(row.file)===file))throw Error('capture does not bind fact product');
const fixedFile=path.join(root,'selfhost/build/phase110/native-fixed-qualify01/report.json'),fixed=read(fixedFile),stringFile=path.join(root,'selfhost/build/phase110/native-string-append01/report.json'),string=read(stringFile);
if(!fixed.complete||!string.complete)throw Error('native baselines must already be qualified');
const inputs=[pin(script),pin(apiFile),pin(apiReportFile),apiReport.source,pin(captureFile),pin(controlFile),...captured.inputs,...captured.products,...captured.sourceFiles,...control.inputs,pin(fixedFile),...fixed.inputs,pin(stringFile),...string.inputs];
const cases=[];
const expected=(contract,format)=>fixed.rows.find(row=>row.contract===contract&&row.format===format).output;
for(const [name,folder,contract] of [['reverse','general-build01','reverse'],['nt_append','general-append02','append']]){
 const dir=path.join(root,'selfhost/build/phase110',folder,'emit-runtime-ir-single'),receiptFile=path.join(dir,'report.json'),receipt=read(receiptFile),libraryFile=path.join(dir,'library.json');
 if(!receipt.complete||receipt.policy!=='runtime-ir-single'||receipt.variant!==contract)throw Error('qualified original library required');
 const libraryPin=receipt.outputs.find(row=>path.resolve(row.file)===libraryFile);if(!libraryPin)throw Error('library not pinned by prior emission');
 inputs.push(pin(receiptFile),...receipt.inputs,libraryPin,expected(contract,'qbe'),expected(contract,'c'));
 cases.push({name,sourceKind:'unchanged captured ownership certificate',library:read(libraryFile),expectedQbe:expected(contract,'qbe'),expectedC:expected(contract,'c')});
}
const stringQbe=string.rows.find(row=>row.backend==='qbe').nativeProduct,stringC=string.rows.find(row=>row.backend==='clang').nativeProduct;inputs.push(stringQbe,stringC);
for(const row of inputs)verify(row);
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase110-context-call-emission',complete:false,inputs,controls:null,rows:[],mutations:[],scope:'Actual canonical Base String.append plus unchanged qualified reverse/nt_append ownership libraries. Original QBE/C must equal native image products; context variants are a separate diagnostic, not a new native selection.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 const lowered=api.nxe_lower_runtime_library(read(typedFile),read(erasedFile),list([{$:'NxeRoot',source:'String.append',symbol:'entry'}]),'single');
 if(lowered.error)throw Error(lowered.error);
 cases.unshift({name:'string_append',sourceKind:'actual typed and erased checked source; canonical closed admission in Bend',library:lowered.library,expectedQbe:stringQbe,expectedC:stringC});
 report.controls=api.nx110ctx_control_report();if(!report.controls.passed||report.controls.cases!==25)throw Error('context Bend controls failed');save();
 for(const test of cases){
  const library=test.library;if(!api.nx110rt_verify(library))throw Error('original library refused '+test.name);
  const baselineQbe=api.nx110rt_qbe(library),baselineC=api.nx110rt_c(library);
  if(baselineQbe+'\n'!==fs.readFileSync(test.expectedQbe.file,'utf8')||baselineC+'\n'!==fs.readFileSync(test.expectedC.file,'utf8'))throw Error('original differs from exact native qualified products '+test.name);
  for(const mode of ['baseline','threaded','context']){
   const facade=mode==='baseline'?library:api.nx110ctx_prepare(library,mode);
   if(mode!=='baseline'&&!api.nx110ctx_verify(facade))throw Error('context facade refused '+test.name+' '+mode);
   const dir=path.join(out,test.name,mode);fs.mkdirSync(dir,{recursive:true});
   fs.writeFileSync(path.join(dir,'library.json'),JSON.stringify(facade,null,2)+'\n');fs.writeFileSync(path.join(dir,'program.ssa'),mode==='baseline'?baselineQbe:api.nx110ctx_qbe(facade));fs.writeFileSync(path.join(dir,'program.c'),mode==='baseline'?baselineC:api.nx110ctx_c(facade));
   report.rows.push({name:test.name,mode,sourceKind:test.sourceKind,baselineExactNativeProduct:true,library:pin(path.join(dir,'library.json')),qbe:pin(path.join(dir,'program.ssa')),c:pin(path.join(dir,'program.c'))});save();
   if(mode==='baseline')continue;
   const mutations=[
    ['unknown-mode',bad=>{bad.mode='unknown';}],
    ['private-export',bad=>{bad.machine.exports=list([array(bad.machine.functions)[0].name]);}],
    ['missing-private-function',bad=>{bad.machine.functions=bad.machine.functions.tail;}],
    ['wrong-wrapper-getter',bad=>{const f=array(bad.machine.functions).find(fn=>!fn.name.startsWith('ctx110_'));const s=find(f,node=>node.$==='NxSet'&&node.name==='ir_heap');if(!s)throw Error('no wrapper getter');s.value={$:'NxVar',name:'ctx'};}],
    ['wrong-private-target',bad=>{const c=find(bad.machine,node=>node.$==='NxCall'&&node.name.startsWith('ctx110_'));if(!c)throw Error('no private call');c.name='rt_ir_heap';}],
    ['missing-private-argument',bad=>{const c=find(bad.machine,node=>node.$==='NxCall'&&node.name.startsWith('ctx110_'));const args=array(c.args);args.pop();c.args=list(args);}],
    ['pointer-slot',bad=>{if(mode==='threaded'){const c=find(bad.machine,node=>node.$==='NxCall'&&node.name.startsWith('ctx110_'));const args=array(c.args);[args[1],args[2]]=[args[2],args[1]];c.args=list(args);}else{const load=find(bad.machine,node=>node.$==='NxLoad'&&node.typ?.$==='NxPtr');if(!load)throw Error('no private pointer load');load.offset=load.offset===0?8:0;}}],
    ['wrong-private-name',bad=>{array(bad.machine.functions)[0].name='bad_context_private';}],
    ['corrupt-source-credit',bad=>{array(bad.source.workers)[0].ownership=list([{$:'NxoReturn',word:'v999999'}]);}]
   ];
   for(const [name,mutate] of mutations){const bad=clone(facade);mutate(bad);const accepted=api.nx110ctx_verify(bad);if(accepted)throw Error('malformed certificate accepted '+test.name+' '+mode+' '+name);report.mutations.push({source:test.name,mode,name,accepted:false,scope:'explicit data-only certificate mutation'});save();}
  }
 }
 for(const row of inputs)verify(row);report.complete=true;save();console.log(JSON.stringify({complete:true,libraries:report.rows.length,mutations:report.mutations.length,bendControls:report.controls.cases}));
}catch(error){report.error=String(error);save();throw error;}
