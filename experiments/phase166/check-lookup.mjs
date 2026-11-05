// Data transport and independent oracle comparison; compiler work stays in Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const root=path.resolve(import.meta.dirname,'../..');
const [receiptFile,outArg]=process.argv.slice(2);
assert(receiptFile&&outArg,'Usage: bun check-lookup.mjs CHECKED_API_REPORT FRESH_OUTPUT');
const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return {file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};};
const verify=p=>{const got=pin(p.file);assert.equal(got.bytes,p.bytes);assert.equal(got.sha256,p.sha256);return got;};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const receipt=read(receiptFile),out=path.resolve(outArg);
assert(receipt.kind==='bend-checked-hosted-api'&&receipt.complete&&receipt.checked);
assert(receipt.exports.includes('p166l_values')&&receipt.exports.includes('p166l_run'));
assert(out.startsWith(path.join(root,'selfhost/build/phase166/'))&&!fs.existsSync(out));
const expectedFile=path.join(root,'experiments/phase166/lookup-expected-values.json');
const specFile=path.join(root,'experiments/phase166/lookup-spec.json');
const expected=read(expectedFile),spec=read(specFile);
assert.equal(expected.kind,'phase166-literal-complete-lookup-oracle');
const oracle=verify({...expected.method,file:path.join(root,expected.method.file)});
for(const p of spec.inputs)verify({...p,file:path.join(root,p.file)});
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase166-complete-lookup-controls',complete:false,inputs:[pin(import.meta.filename),pin(receiptFile),verify(receipt.api),verify(receipt.source),pin(expectedFile),pin(specFile),oracle],values:[],digests:[],scope:'Complete raw values must pass the independent literal oracle before any digest call. Hosted finite controls only; no native speed or proof claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
try{
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  for(const row of expected.cases){
    const actual=api.p166l_values(row.i);
    const file=path.join(out,`values-${row.i}.json`);
    fs.writeFileSync(file,JSON.stringify(actual)+'\n',{flag:'wx'});
    const result={i:row.i,count:row.count,actual:pin(file),complete:false};report.values.push(result);save();
    assert.deepEqual(actual,row.value,`Complete KDef output differs at i=${row.i}`);
    result.complete=true;save();
  }
  report.rawValuesComplete=true;save();
  for(const n of [0,1,2,7]){
    const actual=api.p166l_run(n),want=Number(spec.expectedStdout[String(n)].trim());
    report.digests.push({n,actual,expected:want,complete:actual===want});save();
    assert.equal(actual,want,`Independent digest differs at n=${n}`);
  }
  for(const p of report.inputs)verify(p);
  report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,rawValuesComplete:report.rawValuesComplete??false,valueCases:report.values.length,digestCases:report.digests.length,error:report.error}));}
