// Diagnostic-only observation of an existing checked API's machine-selection input.
// The copied host API gains one read-only callback; emitted assembly must remain exact.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const out=path.resolve(process.argv[process.argv.indexOf('--out')+1]);
fs.mkdirSync(out,{recursive:true});
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const pin=p=>({file:path.resolve(p),bytes:fs.statSync(p).size,sha256:crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const check=p=>{if(pin(p.file).sha256!==p.sha256)throw Error('pin '+p.file);};
const authorityPath='selfhost/build/phase197/baseline-api01/report.json',authority=read(authorityPath);
if(!authority.complete||!authority.checked)throw Error('unchecked parent');check(authority.api);check(authority.source);
const bindingPath='selfhost/build/phase197/baseline-api-source01/base-binding.json',binding=read(bindingPath);
check(binding.base);check(binding.carrier);check(binding.engine);
const source='selfhost/tools/bench/catalogs/native45/fixtures/mandelbrot.bend';
const original=fs.readFileSync(authority.api.file,'utf8');
const needle='function $x185_function_copied(_symbol_0, _params_0, _setup_0, _body_0, _ids_0) {';
if(original.split(needle).length!==2)throw Error('unique callback point');
const copy=out+'/instrumented-api.mjs';fs.writeFileSync(copy,original.replace(needle,needle+'\n  globalThis.__numericObserve(_symbol_0,_params_0,_setup_0,_body_0);'));
let captured=0;const names=[];
globalThis.__numericObserve=(symbol,params,setup,body)=>{
 names.push(symbol);
 if(symbol.includes('109_105_116_')||symbol.endsWith('.mit')){captured++;fs.writeFileSync(out+'/mit-ir.json',JSON.stringify({symbol,params,setup,body},null,2)+'\n');}
};
const api=(await import(pathToFileURL(copy))).default;
const base=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
if(base.$!=='P86PreparationReady')throw Error(base.error);
const plan=api.p86_plan(base.seed,path.resolve(source),fs.readFileSync(source,'utf8'));
if(plan.$!=='P86PlanReady')throw Error(plan.error);
const prepared=api.p169np_plan(plan);if(prepared.error)throw Error(prepared.error);
const selected=api.x181_prepared(prepared);if(selected.error)throw Error(selected.error);
const assembly=api.x188_render(api.x188_many(selected.chunks));
const expected='selfhost/build/phase197/shared-emission01/combined/mandelbrot/program.s';
if(assembly!==fs.readFileSync(expected,'utf8'))throw Error('assembly changed');
fs.writeFileSync(out+'/symbols.json',JSON.stringify(names,null,2)+'\n');
if(captured!==1)throw Error('mit captures '+captured);
fs.writeFileSync(out+'/capture.json',JSON.stringify({complete:true,diagnosticOnly:true,compilerAlgorithmChanged:false,readOnlyCallback:true,assemblyExact:true,parent:pin(authorityPath),api:pin(authority.api.file),instrumented:pin(copy),source:pin(source),binding:pin(bindingPath),expected:pin(expected),capture:pin(out+'/mit-ir.json'),method:pin('research/phase198/numeric/capture.mjs')},null,2)+'\n');
console.log('captured exact mit IR; whole assembly unchanged');
