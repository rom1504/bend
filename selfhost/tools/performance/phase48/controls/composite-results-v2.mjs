// Root-only untimed checked-emission comparison. No source rewriting.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,destination]=process.argv.slice(2);
assert(destination,'composite-results-v2.mjs BASELINE CANDIDATE NEW_OUT');
const out=path.resolve(destination);fs.mkdirSync(out);
const sha=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const report={complete:false,passed:false,kind:'phase48-composite-result-controls',inputs:[],oracles:[],boundaries:[],activation:[]};
const pins=new Map(),define=Object.defineProperty,desc=Object.getOwnPropertyDescriptor,apply=Reflect.apply;
function pin(file,want){file=fs.realpathSync(file);const id={path:file,sha256:sha(file)};
  if(want)assert.equal(id.sha256,want);pins.set(file,id.sha256);report.inputs.push(id);return id;}
function audit(v){if(!v||typeof v!=='object')return;
  const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v.sha256);
  for(const x of Object.values(v))audit(x);}
function fixtureOracle(n,seed){const left=Array(4).fill(BigInt(seed)),right=Array(4).fill(BigInt((seed+1)>>>0));let score=0n;
  for(let i=0;i<n;i++){const j=i%4;score=(score+left[j]+1n)&0xffffffffn;left[j]=(score^BigInt(i))&0xffffffffn;right[(i+1)%4]=(score+3n)&0xffffffffn;}
  return {left:left.map(Number),right:right.map(Number),score:Number(score)};}
function observe(v){assert.equal(v.$,'Parcel');assert.equal(Object.getPrototypeOf(v),Object.prototype);
  assert.deepEqual(Object.keys(v),['$','a']);assert.equal(Object.getPrototypeOf(v.a),Array.prototype);
  assert.equal(v.a.length,3);for(const h of v.a.slice(0,2)){assert.equal(Object.getPrototypeOf(h),Object.prototype);assert.deepEqual(Object.keys(h),['array']);assert.equal(Object.getPrototypeOf(h.array),Array.prototype);}
  return {left:[...v.a[0].array],right:[...v.a[1].array],score:v.a[2],sameHandle:v.a[0]===v.a[1],sameBacking:v.a[0].array===v.a[1].array};}
const error=e=>({name:e?.name,message:e?.message??String(e)});
function scenario(m,label){let result,thrown;const events=[],restore=[];
  const patch=(obj,key,value)=>{const old=desc(obj,key);restore.push(()=>define(obj,key,old));define(obj,key,{...old,value});};
  try{
    if(label==='same-handle'||label==='same-backing'){
      const backing=[5,5,5,5],shared={array:backing};
      patch(m.G['Array.new'],'code',function(){events.push('new');return label==='same-handle'?shared:{array:backing};});
      const v=m.default.make(3,2);result=observe(v);
      assert.equal(result.sameHandle,label==='same-handle');assert.equal(result.sameBacking,true);
      m.default.touch(v.a[0],0,991);assert.equal(v.a[1].array[0],991);
    }else if(label.startsWith('fill-')){
      const fill=Array.prototype.fill;let busy=false;
      patch(Array.prototype,'fill',function(...args){events.push(['fill',args[0]]);
        if(label==='fill-throw')throw Error('composite fill sentinel');
        if(label==='fill-reentry'&&!busy){busy=true;events.push(['reentry',observe(m.default.make(0,9))]);busy=false;}
        return apply(fill,this,args);});result=observe(m.default.make(3,2));
    }else if(label==='native-getter'){
      const original=desc(m.G['Array.new'],'code');restore.push(()=>define(m.G['Array.new'],'code',original));
      define(m.G['Array.new'],'code',{configurable:true,get(){events.push('new-code');return original.value;}});
      result=observe(m.default.make(3,2));
    }else if(label==='failing')result=observe(m.default.failing(0,2));
    else throw Error(label);
  }catch(e){thrown=error(e);}finally{for(const undo of restore.reverse())undo();}
  assert(events.length||label==='failing');return {result,error:thrown,events};
}
try{
  pin(import.meta.filename);
  const modules=[];
  for(const [role,file]of [['baseline',baseline],['candidate',candidate]]){
    pin(file);pin(file+'.json');const receipt=JSON.parse(fs.readFileSync(file+'.json','utf8'));
    assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');audit(receipt);
    const m=await import(pathToFileURL(fs.realpathSync(file)).href);modules.push(m);
    if(role==='candidate'){
      const text=fs.readFileSync(file,'utf8'),line=name=>text.split('\n').find(x=>x.startsWith(`G[${JSON.stringify(name)}]=`))??'';
      assert(line('make').includes('/* private composite array result */'),'make must activate');
      assert(!line('external').includes('/* private composite array result */'),'public record input must refuse');
      assert(!line('nested').includes('/* private composite array result */'),'nested result must refuse');
      report.activation.push({role,make:true,external:false,nested:false});
    }
    for(const n of [0,1,3,9,65])for(const seed of [0,2,0xffffffff]){
      const a=m.default.make(n,seed),b=m.default.make(n,seed),got=observe(a),want=fixtureOracle(n,seed);
      assert.deepEqual(got,{...want,sameHandle:false,sameBacking:false});assert.notEqual(a,b);assert.notEqual(a.a[0],b.a[0]);assert.notEqual(a.a[0].array,b.a[0].array);
      a.a[0].array[0]=731;const touched=m.default.touch(a.a[0],1,947);assert.equal(touched,a.a[0]);assert.equal(a.a[0].array[0],731);assert.equal(a.a[0].array[1],947);
      report.oracles.push({role,n,seed,got});
    }
  }
  for(const label of ['same-handle','same-backing','fill-throw','fill-reentry','native-getter','failing']){
    const b=scenario(modules[0],label),c=scenario(modules[1],label);assert.deepEqual(c,b,label);report.boundaries.push({label,baseline:b,candidate:c});
  }
  // Separate altered module supplies executed entry witnesses only; exact modules
  // above continue to supply all semantic comparisons. Never time this derivative.
  const counters={fast:0,fallback:0,external:0,nested:0};
  const marker='/* private composite array result */';
  let lines=fs.readFileSync(candidate,'utf8').split('\n');
  for(const name of ['make','external','nested']){
    const i=lines.findIndex(x=>x.startsWith(`G[${JSON.stringify(name)}]=`));assert(i>=0);
    if(name==='make'){
      assert.equal(lines[i].split(marker).length,2);
      lines[i]=lines[i].replace(marker,marker+'++$p48CompositeWitness.fast;');
      const end=lines[i].indexOf(',$arrayResult);}',lines[i].indexOf(marker)) + ',$arrayResult);}'.length;
      assert(end>0);lines[i]=lines[i].slice(0,end)+'++$p48CompositeWitness.fallback;'+lines[i].slice(end);
    }else{
      assert(!lines[i].includes(marker));assert(lines[i].includes('fn(2,function(a){'));
      lines[i]=lines[i].replace('fn(2,function(a){',`fn(2,function(a){++$p48CompositeWitness.${name};`);
    }
  }
  const derivative='let $p48CompositeWitness='+JSON.stringify(counters)+';\n'+lines.join('\n')+
    '\nexport const phase48Witness=()=>({...$p48CompositeWitness});\n';
  const derivedFile=path.join(out,'activation-only.mjs');fs.writeFileSync(derivedFile,derivative,{flag:'wx'});pin(derivedFile);
  const dm=await import(pathToFileURL(derivedFile).href);
  assert.deepEqual(dm.phase48Witness(),counters);
  const admitted=dm.default.make(3,2);assert.deepEqual(observe(admitted),{...fixtureOracle(3,2),sameHandle:false,sameBacking:false});
  assert.deepEqual(dm.phase48Witness(),{fast:1,fallback:0,external:0,nested:0});
  dm.default.external(0,admitted);assert.deepEqual(dm.phase48Witness(),{fast:1,fallback:0,external:1,nested:0});
  const wrapped=dm.default.nested(0,2);assert.equal(wrapped.$,'Nest');
  assert.deepEqual(dm.phase48Witness(),{fast:2,fallback:0,external:1,nested:1});
  const refused=scenario(dm,'same-handle');assert.equal(refused.result.sameHandle,true);
  assert.deepEqual(dm.phase48Witness(),{fast:2,fallback:1,external:1,nested:1});
  report.executedEntryWitness={counters:dm.phase48Witness(),timingEligible:false,diagnosticOnly:true,
    scope:'Admitted make executes fast; mutated dependency executes fallback; external/nested execute original public bodies.'};
  for(const [file,hash]of pins)assert.equal(sha(file),hash,'consumed input changed');
  report.complete=true;report.passed=true;
}finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});}
console.log(JSON.stringify({complete:report.complete,passed:report.passed,oracles:report.oracles.length,boundaries:report.boundaries.length}));
