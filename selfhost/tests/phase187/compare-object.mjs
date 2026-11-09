// Cross-host artifact comparison only; the checked Bend export emits all bytes.
import fs from 'node:fs';
import {pathToFileURL,fileURLToPath} from 'node:url';
import path from 'node:path';
import {pin,verify,requireThat as need} from '../../tools/build/hosted.mjs';
const [receiptFile,assemblyFile,objectFile,reportFile]=process.argv.slice(2);
need(reportFile&&!fs.existsSync(reportFile),'Fresh report required');
const receipt=JSON.parse(fs.readFileSync(receiptFile,'utf8'));
need(receipt.kind==='bend-checked-hosted-api'&&receipt.complete&&receipt.checked&&receipt.exports.includes('x187_assemble'),'Checked Bend export required');
const inputs=[pin(fileURLToPath(import.meta.url)),pin(receiptFile),pin(assemblyFile),pin(objectFile),receipt.api,receipt.source,...receipt.inputs];
inputs.forEach(verify);
const api=(await import(pathToFileURL(receipt.api.file))).default;
const start=performance.now(),result=api.x187_assemble(fs.readFileSync(assemblyFile,'utf8'));
need(result.$==='X187ObjectResult'&&result.error==='','Object emission failed: '+result.error);
const expected=fs.readFileSync(objectFile);let xs=result.bytes,i=0;
while(xs.$==='Con'){need(i<expected.length&&xs.head===expected[i++],'Object byte mismatch');xs=xs.tail;}
need(xs.$==='Nil'&&i===expected.length,'Object length mismatch');inputs.forEach(verify);
fs.mkdirSync(path.dirname(reportFile),{recursive:true});
fs.writeFileSync(reportFile,JSON.stringify({kind:'phase187-cross-host-object-identity',complete:true,inputs,bytes:i,seconds:(performance.now()-start)/1000,scope:'Checked upstream-JS execution of Bend encoder versus self-hosted native output; complete object byte identity on this input, not a full bootstrap fixed point.'},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,bytes:i}));
