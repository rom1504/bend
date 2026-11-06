// Observation adapter only. All template decisions and QBE emission run in the
// authenticated, source-checked Bend API. This script neither lowers nor runs
// generated programs and never rewrites emitted QBE.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,workspace} from '../../tools/build/hosted.mjs';

const args={};
for(let i=2;i<process.argv.length;i+=2){
  assert(process.argv[i]?.startsWith('--')&&process.argv[i+1],'Expected --key value');
  const key=process.argv[i].slice(2);assert(!Object.hasOwn(args,key),'Duplicate option');
  args[key]=process.argv[i+1];
}
assert.deepEqual(Object.keys(args).sort(),['out','receipt']);
const own=fileURLToPath(import.meta.url);
const receiptPin=pin(args.receipt),receipt=JSON.parse(fs.readFileSync(receiptPin.file,'utf8'));
assert.equal(receipt.kind,'bend-checked-hosted-api');
assert(receipt.complete&&receipt.checked&&!receipt.error,'Checked complete API required');
const exports=['p172is_controls','p172is_guard_observation','p172is_fast_observation','p172ir_oracle_module'];
for(const name of exports)assert(receipt.exports.includes(name),'Missing checked export '+name);
const inputs=[pin(own),pin(process.execPath),pin(path.join(workspace,'selfhost/tools/build/hosted.mjs')),
  receiptPin,receipt.source,receipt.api,...receipt.inputs];
inputs.forEach(verify);
const out=path.resolve(args.out);
assert(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh guarded build directory required');
fs.mkdirSync(out,{recursive:true});
const report={kind:'phase172-inline-runtime-controls',version:1,complete:false,passed:false,
  inputs,authority:{receipt:receiptPin,source:receipt.source,image:receipt.api},
  rows:[],graphs:[],artifacts:[],scope:'Finite checked Bend controls, exact full instruction-graph comparison, and unchanged Bend-emitted oracle QBE. No generated program execution, runtime qualification, or performance claim.'};

// Count every occurrence, including shared subgraphs. The depth/node bounds
// reject cycles without relying on a recursive JavaScript walk.
function inspectGraph(root){
  const pending=[[root,0]];let nodes=0,stringBytes=0;
  while(pending.length){
    const [value,depth]=pending.pop();assert(++nodes<=100000&&depth<=512,'Graph bound exceeded');
    if(value===null)continue;
    switch(typeof value){
      case 'boolean':break;
      case 'number':assert(Number.isFinite(value),'Non-finite observation');break;
      case 'string':stringBytes+=Buffer.byteLength(value);assert(stringBytes<=2*1024**2,'Text bound exceeded');break;
      case 'object':{
        const proto=Object.getPrototypeOf(value);assert(proto===Object.prototype||proto===null,'Plain observation object required');
        const keys=Object.keys(value);assert(keys.length<=32,'Record width bound exceeded');
        for(const key of keys){assert(typeof value[key]!=='undefined','Undefined observation');pending.push([value[key],depth+1]);}
        break;
      }
      default:throw Error('Non-data observation: '+typeof value);
    }
  }
  return {nodes,stringBytes};
}

function graphEqual(a,b){
  const pending=[[a,b]];let nodes=0;
  while(pending.length){
    assert(++nodes<=100000,'Comparator bound exceeded');
    const [left,right]=pending.pop();
    if(left===null||right===null){if(left!==right)return false;continue;}
    if(typeof left!==typeof right)return false;
    if(typeof left!=='object'){if(!Object.is(left,right))return false;continue;}
    const lk=Object.keys(left).sort(),rk=Object.keys(right).sort();
    if(lk.length!==rk.length||lk.some((key,i)=>key!==rk[i]))return false;
    for(const key of lk)pending.push([left[key],right[key]]);
  }
  return true;
}

function save(name,text){
  assert(Buffer.byteLength(text)<=16*1024**2,'Artifact bound exceeded');
  const file=path.join(out,name);fs.writeFileSync(file,text,{flag:'wx'});
  const artifact=pin(file);report.artifacts.push(artifact);return artifact;
}

try{
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  for(const name of exports)assert.equal(typeof api[name],'function');
  let rows=api.p172is_controls();inspectGraph(rows);
  while(rows?.$==='Con'){
    assert(report.rows.length<27,'Too many finite controls');
    assert.equal(typeof rows.head,'string');report.rows.push(rows.head);rows=rows.tail;
  }
  assert.equal(rows?.$,'Nil');assert.equal(report.rows.length,27);
  for(const row of report.rows)assert(row.startsWith('PASS '),'Failed Bend control: '+row);
  assert.equal(new Set(report.rows).size,27,'Repeated control label');
  for(const name of ['p172is_guard_observation','p172is_fast_observation']){
    const pair=api[name]();assert.equal(pair?.$,'Tuple');
    assert.deepEqual(Object.keys(pair).sort(),['$','fst','snd']);
    const actual=inspectGraph(pair.fst),expected=inspectGraph(pair.snd);
    assert.equal(pair.fst?.$,'Con','Nonempty actual instruction graph required');
    assert.equal(pair.snd?.$,'Con','Nonempty independent expected graph required');
    assert(graphEqual(pair.fst,pair.snd),'Complete instruction graph differs: '+name);
    const mutation=structuredClone(pair.snd);
    assert.equal(typeof mutation.head.name,'string');mutation.head.name+='__mutation';
    inspectGraph(mutation);assert(!graphEqual(pair.fst,mutation),'Comparator ignored mutated instruction field');
    const missing=structuredClone(pair.snd);delete missing.head.name;
    inspectGraph(missing);assert(!graphEqual(pair.fst,missing),'Comparator ignored missing instruction field');
    const artifact=save(name+'.json',JSON.stringify(pair,null,2)+'\n');
    report.graphs.push({export:name,exact:true,actual,expected,mutationRejected:true,missingFieldRejected:true,artifact});
  }
  const qbe=api.p172ir_oracle_module();assert.equal(typeof qbe,'string');
  assert(Buffer.byteLength(qbe)>0&&Buffer.byteLength(qbe)<256*1024,'Oracle QBE bound');
  assert.equal((qbe.match(/^export function l /gm)||[]).length,8,'Expected four candidate/reference pairs');
  for(let width=1;width<=4;width++)for(const role of ['fast','base'])
    assert(qbe.includes('export function l $p172ir_'+role+'_'+width+'('),'Missing oracle function');
  report.oracle=save('oracle.ssa',qbe);
  inputs.forEach(verify);report.complete=true;report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,passed:report.passed,controls:report.rows.length,
  graphs:report.graphs.length,oracle:report.oracle,error:report.error}));
