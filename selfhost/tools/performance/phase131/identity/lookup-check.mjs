// Catalogue dispatch controls. Source algorithms execute in checked Bend;
// host logic constructs finite data and independently specifies first-hit and
// authoritative-cache expectations. No compiler lowering is implemented here.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const argv=process.argv.slice(2);
const opt=n=>{const i=argv.indexOf(n);assert(i>=0&&argv[i+1],n);return path.resolve(argv[i+1]);};
const out=opt('--out');assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return {file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const report={complete:false,targetsRun:true,inputs:[pin(import.meta.filename)],cases:[],
  scope:'Checked original/candidate exact whole-payload catalogue results, with independent explicit cache-sentinel and first-match expectations. No native timings.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
function receipt(file){const r=JSON.parse(fs.readFileSync(file));assert(r.complete&&r.checked&&r.status===0);
  for(const p of [pin(file),r.api,...r.inputs]){assert.deepEqual(pin(p.file),p);report.inputs.push(p);}return r;}
function list(v){const out=[];while(v?.$==='Con'){assert(out.length<1024);out.push(v.head);v=v.tail;}assert.equal(v?.$,'Nil');return out;}
const linked=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function fnv(name){let h=2166136261;for(const c of name)h=Math.imul(h^c.codePointAt(0),16777619)>>>0;return h;}
try{
  const r=receipt(opt('--api-report')),f=receipt(opt('--fixture-api-report'));
  assert(r.exports.includes('p131il_probe'));
  const api=(await import(pathToFileURL(r.api.file))).default,fixtures=(await import(pathToFileURL(f.api.file))).default;
  const one=fixtures.p131ic_case(1,1,0,true);
  const sample=list(fixtures.p131ic_queries(one,1,1,0))[0];
  const absent=list(fixtures.p131ic_queries(one,32,1,0))[0];
  const record=(name,version,kind='Def')=>({...sample,name,kind,arity:version,templates:version+7});
  const cache=tree=>({...record('$kernel.cache',77,'BookCache'),ctors:linked([tree,record('payload-preserved',33)])});
  const leaf=(h,b)=>({$:'KIndexLeaf',hash:h,bucket:linked(b)});
  function check(label,book,name,expected){
    const input=linked(book),old=api.p131il_probe(input,name,true),next=api.p131il_probe(input,name,false);
    assert.deepEqual(next,old,label+' differs from frozen dispatch');
    assert.deepEqual(next,expected,label+' differs from independent expectation');
    report.cases.push({label,name,exactOriginal:true,independentExpected:true});
  }
  for(const seed of [0,1,17,4294967295])for(const count of [0,1,17,257]){
    const tree=fixtures.p131ic_case(seed,count,0,true),answers=list(fixtures.p131ic_queries(tree,0,33,0));
    for(let prefixSize=0;prefixSize<5;prefixSize++){
      const prefix=Array.from({length:prefixSize},(_,i)=>record('identity.'+(i%3),100+i));
      for(let key=0;key<33;key++){
        const name='identity.'+key,first=prefix.find(d=>d.name===name);
        check(`cache:${seed}:${count}:${prefixSize}:${key}`,[...prefix,cache(tree),record(name,999)],name,first??answers[key]);
      }
    }
  }
  const a=record('alpha',1),a2=record('alpha',2),empty=record('',3),unicode=record('λ.树',4);
  const ca=record('costarring',5),cb=record('liquid',6);assert.equal(fnv(ca.name),fnv(cb.name));
  const collide=cache(leaf(fnv(ca.name),[ca,cb]));
  const internal=leaf(0,[]), malformedCache={...cache(absent),ctors:linked([])};
  const pairs=[
    ['empty',[],'alpha',absent],['first-duplicate',[a,a2],'alpha',a],
    ['reverse-duplicate',[a2,a],'alpha',a2],['plain-empty-name',[a,empty],'',empty],
    ['internal-empty-name',[internal,empty],'',internal],['unicode',[a,unicode],'λ.树',unicode],
    ['exact-case',[a],'Alpha',absent],['authoritative-miss',[cache(absent),a],'alpha',absent],
    ['malformed-cache-empty-children',[malformedCache,a],'alpha',absent],
    ['cache-name-not-entry',[cache(absent)],'$kernel.cache',absent],
    ['prefix-before-cache',[a,cache(absent),a2],'alpha',a],
    ['collision-first',[collide,a],ca.name,ca],['collision-second',[collide,a],cb.name,cb],
    ['absent-kind-matching-payload',[record('alpha',44,'Absent')],'alpha',record('alpha',44,'Absent')],
    ['book-cache-case-sensitive',[record('alpha',45,'bookcache')],'alpha',record('alpha',45,'bookcache')],
    ['cache-zero-mask-bucket',[cache({$:'KIndexNode',hash:fnv('alpha'),mask:0,left:a,right:a2})],'alpha',a]
  ];
  for(const p of pairs)check(...p);
  for(const p of report.inputs)assert.deepEqual(pin(p.file),p);
  report.complete=true;report.caseCount=report.cases.length;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,cases:report.caseCount,error:report.error}));}
