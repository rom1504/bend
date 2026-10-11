// BASELINE_ATTEMPT CANDIDATE_ATTEMPT FRESH_OUT; private exports of actual helpers.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [oldArg,newArg,outArg]=process.argv.slice(2),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const pins=[],pin=p=>{const e=typeof p==='string'?null:p,file=fs.realpathSync(e?.file??p),b=fs.readFileSync(file),r={file,sha256:createHash('sha256').update(b).digest('hex')};if(e)assert.equal(r.sha256,e.sha256);pins.push(r);return r;};
const report={complete:false,method:pin(import.meta.filename),rows:[]};
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=l=>{const a=[];while(l.$==='Con'){a.push(l.head);l=l.tail;}assert.equal(l.$,'Nil');return a;};
const t=(tag,name='',id=0,kids=[])=>({$:'KTerm',tag,name,id,quant:1,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
const v=i=>t('Var','',i),ann=(i,ty)=>t('Ann','',0,[v(i),ty]);
const d=(name,kind='Def',value=t('Absent'),native=false)=>({$:'KDef',name,kind,value,typ:t('Typ'),arity:0,templates:0,ctors:list([]),native,unsafe:true});
const scalar=t('ADT','U32'),arr=t('ADT','Array',0,[scalar]),book=list([d('U32','ADT',t('Absent'),true),d('Array','ADT',t('Absent'),true)]);
try {
 const apis=[];
 for(const [i,arg] of [oldArg,newArg].entries()){
  const a=JSON.parse(fs.readFileSync(pin(arg).file));assert(a.checked&&a.config.strictExact);const s=fs.readFileSync(pin(a.api).file,'utf8');
  const derived=path.join(out,'api-'+i+'.mjs');
  fs.writeFileSync(derived,s+'\nexport const uses=(a,b,c)=>run_loop($ns_unshared_terms$(a,b,c));\nexport const foreignParts=(a,b)=>run_loop($nc_foreign_parts$(a,b));\n');pin(derived);
  apis.push(await import(pathToFileURL(derived)));
 }
 const duplicate=t('Ctr','Tuple',0,[v(7),v(7)]),branch=t('Mat','Choice',1,[v(7),v(7)]);
 for(const [name,body,terms,expected] of [
  ['one-array-use',v(7),[ann(7,arr)],true],['duplicate-array',duplicate,[ann(7,arr)],false],
  ['branch-maximum',branch,[ann(7,arr)],true],['duplicate-scalar',duplicate,[ann(7,scalar)],true],
  ['unknown-type',duplicate,[ann(7,t('Ref','Missing'))],false],['bare-duplicate',duplicate,[v(7)],false],
  ['nonvar-with-duplicate-zero',t('Ctr','Tuple',0,[v(0),v(0)]),[t('Ctr','Unit')],true],
  ['nested-duplicate',duplicate,[t('Ctr','Tuple',0,[v(7)])],false],
  ['dead-bare',v(8),[v(7)],true],['fail-then-safe',duplicate,[ann(7,arr),ann(7,scalar)],false]
 ]){
  const values=apis.map(a=>a.uses(book,body,list(terms)));assert.deepEqual(values,[expected,expected],name);report.rows.push({name,values,pass:true});
 }
 const defs=list([d('foo'),d('mod/foo')]),scope=list([d('mod/importer','Def',t('Foreign','importer',0,[t('Path','helper.c')]))]);
 const cases=[['global','FID(foo)',list([]),'foo'],['namespaced','FID(foo)',scope,'mod/foo'],['exit','FID(EXIT)',list([]),'EXIT'],['enter','FID(ENTER)',list([]),'ENTER']];
 for(const [name,source,sc,want] of cases){
  const values=apis.map(a=>a.default.kf_source(defs,sc,'helper.c',source));assert.deepEqual(values[0],values[1]);assert.equal(values[1].error,'');assert(array(values[1].parts).some(p=>p.tag==='FID'&&p.name===want));report.rows.push({name,pass:true});
 }
 for(const source of ['FID(no_such_def)','CID(Clo~apply)']){
  const values=apis.map(a=>a.default.kf_source(defs,list([]),'helper.c',source));assert.deepEqual(values[0],values[1]);assert(values[1].error.includes('names no constructor or def'));report.rows.push({name:source,pass:true});
 }
 for(const source of ['"FID(no_such_def)"',"'FID(no_such_def)'",'`FID(no_such_def)`','// FID(no_such_def)\n','/* FID(no_such_def) */','xFID(no_such_def)']){
  const values=apis.map(a=>a.default.kf_source(defs,list([]),'helper.c',source));assert.deepEqual(values[0],values[1]);assert.equal(values[1].error,'');assert(array(values[1].parts).every(p=>p.tag==='Text'));report.rows.push({name:source,pass:true});
 }
 const values=apis.map(a=>a.default.kf_source(defs,list([]),'helper.c','FID(Clo~apply)'));
 assert(values[0].error.includes('names no constructor or def'));assert.equal(values[1].error,'');
 assert.equal(apis[1].foreignParts(defs,values[1].parts),'BEND_CLO_APPLY');report.rows.push({name:'runtime-closure-id',before:values[0].error,after:'BEND_CLO_APPLY',pass:true});
 for(const r of [...pins])pin(r);report.complete=true;report.pass=true;
} catch(error){report.error=error.stack;process.exitCode=1;}
report.inputs=pins;fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
