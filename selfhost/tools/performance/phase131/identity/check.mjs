// Data-only differential harness: execute checked Bend exports, compare all
// fields, and independently check queried replacement payloads. No lowering.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL, fileURLToPath} from 'node:url';

const args=process.argv.slice(2);
const option=name=>{const i=args.indexOf(name);assert(i>=0&&i+1<args.length,name);return args[i+1];};
const receiptFile=path.resolve(option('--api-report'));
const out=path.resolve(option('--out'));
assert(!fs.existsSync(out),'Fresh output directory required');
fs.mkdirSync(out,{recursive:true});
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const digest=value=>crypto.createHash('sha256').update(JSON.stringify(value)).digest('hex');
const report={complete:false,targetsRun:true,kind:'phase131-patricia-differential',inputs:[pin(fileURLToPath(import.meta.url)),pin(receiptFile)],cases:[],scope:'Checked Bend API execution. Whole-tree equality to retained original algorithm plus independent latest-payload oracle. No native benchmark or compiler qualification.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const next=s=>(Math.imul(s,1664525)+1013904223)>>>0;
function expected(seed,count,map=new Map()) {for(let left=count;left>0;left--){map.set(seed%31,left);seed=next(seed);}return map;}
function list(v){const xs=[];while(v?.$==='Con'){assert(xs.length<1024);xs.push(v.head);v=v.tail;}assert.equal(v?.$,'Nil');return xs;}
function oracle(tree,values,map){
  assert.equal(values.length,33);
  for(let key=0;key<33;key++){
    const d=values[key];
    if(!map.has(key)){assert.equal(d.$,'KDef');assert.equal(d.kind,'Absent');continue;}
    const version=map.get(key);
    assert.equal(d.$,'KDef');assert.equal(d.name,'identity.'+key);
    assert.equal(d.kind,'P131Identity');assert.equal(d.arity,key);assert.equal(d.templates,version);
    assert.equal(d.typ.tag,'ProbeType');assert.equal(d.typ.id,key);assert.equal(d.typ.quant,version);
    assert.equal(d.value.tag,'ProbeValue');assert.equal(d.value.id,version);assert.equal(d.value.quant,key);
    assert.equal(d.native,version%2===0);assert.equal(d.unsafe,version%3===0);
    const children=list(d.ctors);assert.equal(children.length,1);
    assert.equal(children[0].name,'payload');assert.equal(children[0].arity,version);assert.equal(children[0].templates,key);
  }
}
try{
  const receipt=JSON.parse(fs.readFileSync(receiptFile));
  assert(receipt.complete&&receipt.checked&&receipt.status===0);
  for(const p of [...receipt.inputs,receipt.api]){assert.deepEqual(pin(p.file),p);report.inputs.push(p);}
  for(const n of ['p131ic_case','p131ic_legacy_case','p131ic_queries'])assert(receipt.exports.includes(n));
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  for(const legacy of [false,true])for(const seed of [0,1,17,4294967295])
  for(const count of [0,1,2,17,64,257])for(let mode=0;mode<7;mode++){
    const f=legacy?api.p131ic_legacy_case:api.p131ic_case;
    const old=f(seed,count,mode,true),candidate=f(seed,count,mode,false);
    try{assert.deepEqual(candidate,old);}catch(e){
      fs.writeFileSync(path.join(out,'mismatch-original.json'),JSON.stringify(old,null,2));
      fs.writeFileSync(path.join(out,'mismatch-candidate.json'),JSON.stringify(candidate,null,2));throw e;
    }
    const oldQueries=list(api.p131ic_queries(old,0,33,mode));
    const queries=list(api.p131ic_queries(candidate,0,33,mode));
    assert.deepEqual(queries,oldQueries);
    const model=legacy?expected((seed+91)>>>0,count,expected(seed,17)):expected(seed,count);
    oracle(candidate,queries,model);
    report.cases.push({legacy,seed,count,mode,wholeTreeEqual:true,lookupEqual:true,independentPayloadOracle:true,treeSha256:digest(candidate),querySha256:digest(queries)});
  }
  report.complete=true;report.caseCount=report.cases.length;
  report.queryCount=report.caseCount*33;
  save();process.stdout.write(JSON.stringify({complete:true,cases:report.caseCount,queries:report.queryCount})+'\n');
}catch(e){report.error=String(e.stack||e);save();throw e;}
