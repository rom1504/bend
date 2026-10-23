// Data-only exact lookup controls. The three implementations are checked Bend:
// selected Phase130 lookup through the prior fixture API, renamed original
// lookup in this API, and the single-loop candidate. No semantic host lowering.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const argv=process.argv.slice(2);
const option=n=>{const i=argv.indexOf(n);assert(i>=0&&argv[i+1],n);return path.resolve(argv[i+1]);};
const out=option('--out');assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return {file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const report={complete:false,targetsRun:true,inputs:[pin(import.meta.filename)],cases:[],
  scope:'Exact checked-API KDef result comparisons on canonical, legacy and deliberately malformed finite trees. No native program execution or performance claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
function receipt(file){const r=JSON.parse(fs.readFileSync(file));assert(r.complete&&r.checked&&r.status===0);
  for(const p of [pin(file),r.api,...r.inputs]){assert.deepEqual(pin(p.file),p);report.inputs.push(p);}return r;}
function list(v){const a=[];while(v?.$==='Con'){assert(a.length<1024);a.push(v.head);v=v.tail;}assert.equal(v?.$,'Nil');return a;}
function linked(a){return a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});}
function hash(key,mode){
  if(mode===0){let h=2166136261;for(const c of 'identity.'+key)h=Math.imul(h^c.codePointAt(0),16777619)>>>0;return h;}
  if(mode===1)return 0;if(mode===2)return 4294967295;
  if(mode===3)return Math.imul(key,2147483648)>>>0;
  if(mode===4)return Math.imul(key,65536)>>>0;
  if(mode===5)return key>>>0;
  return (Math.imul(key,2654435761)+2246822519)>>>0;
}
try{
  const current=receipt(option('--api-report')),fixture=receipt(option('--fixture-api-report'));
  assert(current.exports.includes('p131ir_probe'));
  const api=(await import(pathToFileURL(current.api.file))).default;
  const fixtures=(await import(pathToFileURL(fixture.api.file))).default;
  for(const legacy of [false,true])for(const seed of [0,1,17,4294967295])
  for(const count of [0,1,2,17,64,257])for(let mode=0;mode<7;mode++){
    const tree=(legacy?fixtures.p131ic_legacy_case:fixtures.p131ic_case)(seed,count,mode,true);
    const expected=list(fixtures.p131ic_queries(tree,0,33,mode));
    for(let key=0;key<33;key++){
      const name='identity.'+key,h=hash(key,mode);
      const old=api.p131ir_probe(tree,name,h,32,true),next=api.p131ir_probe(tree,name,h,32,false);
      assert.deepEqual(old,expected[key]);assert.deepEqual(next,expected[key]);
    }
    report.cases.push({legacy,seed,count,mode,queries:33,selectedOriginalAndCloneAndCandidateEqual:true});
  }
  const singleton=fixtures.p131ic_case(1,1,0,true);
  const record=list(fixtures.p131ic_queries(singleton,1,1,0))[0];
  const absent=list(fixtures.p131ic_queries(singleton,32,1,0))[0];
  const leaf=(h,b)=>({$:'KIndexLeaf',hash:h,bucket:linked(b)});
  const node=(h,m,a,b)=>({$:'KIndexNode',hash:h,mask:m,left:a,right:b});
  const legacy=(kind,h,m,children)=>({...absent,kind,arity:h,templates:m,ctors:linked(children)});
  const h=hash(1,0),l=leaf(h,[record]);
  const shapes=[absent,l,leaf(h,[record,{...record,arity:91}]),
    node(h,0,record,absent),node(h,3,l,absent),node((h^17)>>>0,2147483648,absent,l),
    node(0,1,node(0,1,l,absent),l),leaf(0,[leaf(7,[]),record]),
    legacy('IndexLeaf',h,0,[record]),legacy('IndexNode',h,3,[l]),
    legacy('IndexNode',h,1,[]),legacy('Absent',h,1,[l,l]),
    legacy('other',h,0,[record]),legacy('IndexNode',h,1,[l,l,record])];
  report.malformed=[];
  for(let shape=0;shape<shapes.length;shape++)for(const name of ['identity.1','','absent'])
  for(const value of [0,1,h,2147483648,4294967295])for(const bits of [0,1,32,4294967295]){
    const old=api.p131ir_probe(shapes[shape],name,value,bits,true);
    const next=api.p131ir_probe(shapes[shape],name,value,bits,false);
    assert.deepEqual(next,old);
    report.malformed.push({shape,name,hash:value,bits,equal:true});
  }
  for(const p of report.inputs)assert.deepEqual(pin(p.file),p);
  report.complete=true;report.treeCases=report.cases.length;
  report.queries=report.treeCases*33;report.malformedQueries=report.malformed.length;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,trees:report.treeCases,queries:report.queries,malformedQueries:report.malformedQueries,error:report.error}));}
