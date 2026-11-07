// Diagnose frozen fixture phase boundaries using a checked, unmodified oracle.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';
const [receiptFile,bindingFile,out]=process.argv.slice(2);
need(receiptFile&&bindingFile&&out&&!fs.existsSync(out),'receipt binding fresh-out required');
const receipt=JSON.parse(fs.readFileSync(receiptFile)),binding=JSON.parse(fs.readFileSync(bindingFile));
need(receipt.complete&&receipt.checked,'checked API required');
const manifestFile=path.join(workspace,'experiments/phase175/parser-publication-cases.json');
const inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath),pin(receiptFile),pin(bindingFile),pin(manifestFile),receipt.api,...receipt.inputs,binding.base,binding.carrier];
inputs.forEach(verify);fs.mkdirSync(out,{recursive:true});
const api=(await import(pathToFileURL(receipt.api.file))).default;
const prep=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
need(prep.$==='P86PreparationReady','Base refused');const rows=[];
for(const fixture of JSON.parse(fs.readFileSync(manifestFile)).rows){
  const file=path.join(workspace,fixture.file),identity={...pin(file)};need(identity.sha256===fixture.sha256&&identity.bytes===fixture.bytes,'fixture differs');inputs.push(identity);
  const text=fs.readFileSync(file,'utf8'),admission=api.p175pa_plan('parse',prep.seed,file,text),checked=api.p175fp_plan('check',prep.seed,file,text);
  rows.push({name:fixture.name,admission,result:checked.$,error:checked.error??null});
}
inputs.forEach(verify);fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({kind:'phase175-publication-fixture-probe',complete:true,inputs,rows},null,2)+'\n');
console.log(JSON.stringify(rows));
