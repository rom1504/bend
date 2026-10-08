// Packing-only successor of the maintained raw native controls.
// Root runs this under the existing bounded guard; no benchmark timings.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const [recipeArg,baselineArg,candidateArg,outArg]=process.argv.slice(2);
const recipe=JSON.parse(fs.readFileSync(recipeArg,'utf8')),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const pin=p=>({file:path.resolve(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const root=path.resolve(import.meta.dirname,'../../../../../..');
const runtimePath=path.join(root,'selfhost/src/runtime/native/runtime.c'),runtime=fs.readFileSync(runtimePath,'utf8');
const inputs=[pin(recipeArg),pin(baselineArg),pin(candidateArg),pin(runtimePath),pin(import.meta.filename)];
const report={kind:'phase68-packing-raw-controls-v2',complete:false,pass:false,inputs,rows:[],scope:'Exact product10/checked packing candidate raw-core API controls; four native programs and one explicit readback-layout diagnostic at threads1/4, plus compile-only permission probes. No timing, frontend, foreign ABI or GPU universality claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
// These builders and parent declarations follow src/back/native/tests.mjs and
// the reviewed Phase68 raw-v5 controller. NWord deliberately exercises the
// native raw boundary with exact decimal word strings, without JS truncation.
const list=a=>a.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
const t=(tag,name='',kids=[],id=0,quant=1)=>({$: 'KTerm',tag,name,kids:list(kids),id,quant,removed:list([])});
const vr=i=>t('Var','',[],i),ctr=(k,...a)=>t('Ctr',k,a),ref=k=>t('Ref',k),app=(f,x)=>t('App','',[f,x]);
const lam=(id,b)=>t('Lam','',[b],id),all=(id,a,b)=>t('All','',[a,b],id);
const nty=t('ADT','Nat'),word=n=>t('NWord',String(n));
const def=(name,value,typ=nty)=>({$: 'KDef',name,kind:'Def',arity:0,templates:0,typ,value,ctors:list([]),native:value.tag==='Absent',unsafe:true});
const bind=(id,value,body)=>t('Let','',[t('Bind','',[value],id),body]);
const add=(a,b)=>app(app(ref('Nat.add'),a),b);
const baseCtor=(name,arity,typ)=>({...def(name,t('Absent'),typ),kind:'Ctr',arity});
const baseADT=(name,ctors)=>({...def(name,t('Absent'),t('Typ')),kind:'ADT',ctors:list(ctors),native:true});
const lty=t('ADT','List',[t('ADT','U32')]),aty=t('ADT','Array',[nty]);
const parents=[baseADT('List',[baseCtor('Nil',0,lty),baseCtor('Con',2,all(78,t('ADT','U32'),all(79,lty,lty)))]),baseADT('Nat',[baseCtor('Zero',0,nty),baseCtor('Succ',1,all(80,nty,nty))]),baseADT('Array',[baseCtor('ALeaf',1,all(81,nty,aty)),baseCtor('ANode',2,all(82,aty,all(83,aty,aty)))])];
const ty=name=>t('ADT',name);
const adt=(name,fields)=>{
  const signature=fields.reduceRight((body,field,i)=>all(300+i,field,body),ty(name));
  return {...baseADT(name,[{...baseCtor(name,fields.length,signature),native:false}]),native:false};
};
const box=adt('PackingBox68',[nty]),outer=adt('PackingOuter68',[ty('PackingBox68')]);
const boundary=adt('PackingBoundary68',Array(4).fill(ty('PackingBox68')));
const arrayBox=adt('PackingArray68',[aty]);
const bx=n=>ctr('PackingBox68',word(n));
const unbox=def('packing_unbox68',lam(10,app(t('Mat','PackingBox68',[lam(11,vr(11)),t('Efq')]),vr(10))),all(10,ty('PackingBox68'),nty));
const unouter=def('packing_unouter68',lam(20,app(t('Mat','PackingOuter68',[lam(21,app(ref('packing_unbox68'),vr(21))),t('Efq')]),vr(20))),all(20,ty('PackingOuter68'),nty));
const prim=def('Nat.add',t('Absent'));
const books=[
  ['readback-boundaries',[def('main',ctr('PackingBoundary68',bx('0'),bx('1099511627775'),bx('1099511627776'),bx('281474976710655')),ty('PackingBoundary68')),box,boundary],
   'PackingBoundary68{PackingBox68{0n}, PackingBox68{1099511627775n}, PackingBox68{1099511627776n}, PackingBox68{281474976710655n}}'],
  ['packed-share-drop',[def('main',bind(51,bx('9'),bind(50,bx('7'),add(app(ref('packing_unbox68'),vr(50)),app(ref('packing_unbox68'),vr(50)))))),unbox,prim,box],'14n'],
  ['pointer-share-drop',[def('main',bind(51,ctr('PackingOuter68',bx('7')),bind(50,ctr('PackingOuter68',bx('1099511627776')),add(app(ref('packing_unouter68'),vr(50)),app(ref('packing_unouter68'),vr(50)))))),unouter,unbox,prim,box,outer],'2199023255552n'],
  ['array-pointer-readback',[def('main',ctr('PackingArray68',ctr('ANode',ctr('ALeaf',word('7')),ctr('ALeaf',word('9')))),ty('PackingArray68')),arrayBox],'PackingArray68{[7n, 9n]}'],
];
const foreign={...def('packing_unused_foreign68',t('Foreign','packing_unused_foreign68')),native:false};
const absent={...def('packing_unused_law68',t('Absent')),native:false};
const nested=d=>({...def('packing_index68',t('Absent')),kind:'KIndexNode',native:false,ctors:list([d])});
const policies=[
  ['ordinary-adt-metadata',[],1],
  ['user-foreign',[foreign],0],
  ['user-absent-def',[absent],0],
  ['annotated-foreign',[{...foreign,value:t('Ann','',[foreign.value,nty])}],0],
  ['foreign-unusual-kind',[{...foreign,kind:'PolicyProbe'}],0],
  ['nested-foreign',[nested(foreign)],0],
  ['nested-absent-def',[nested(absent)],0],
  ['base-foreign-provenance',[{...foreign,native:true}],1],
];
try {
  const apis={baseline:(await import(pathToFileURL(baselineArg))).default,candidate:(await import(pathToFileURL(candidateArg))).default};
  for(const [name,extra,expected] of policies) {
    const row={name,kind:'permission-source',candidatePermission:expected,results:{}};report.rows.push(row);
    for(const [role,api] of Object.entries(apis)) {
      const got=api.nc_compile(list([def('main',bx('7'),ty('PackingBox68')),box,...extra,...parents]),runtime,'');
      assert.equal(got.error,'',name+' '+role);
      const file=path.join(out,name+'-'+role+'.c');fs.writeFileSync(file,got.source,{flag:'wx'});
      const found=[...got.source.matchAll(/^#define NATIVE_PACK_CTORS ([01])$/gm)].map(m=>Number(m[1]));
      assert.deepEqual(found,role==='candidate'?[expected]:[],name+' '+role);
      row.results[role]={source:pin(file),permission:found};
    }
    row.pass=true;save();
  }
  for(const [name,book,expected] of books)for(const [role,api] of Object.entries(apis)) {
    const got=api.nc_compile(list([...book,...parents]),runtime,'');assert.equal(got.error,'',name+' '+role);
    if(role==='candidate')assert.match(got.source,/^#define NATIVE_PACK_CTORS 1$/m);
    const stem=path.join(out,name+'-'+role);fs.writeFileSync(stem+'.c',got.source,{flag:'wx'});
    const row={name,role,kind:'native-execution',expected,source:pin(stem+'.c'),runs:[]};report.rows.push(row);save();
    const cc=spawnSync(recipe.clang,[...recipe.clangArgs.filter(x=>x!=='-O3'),'-O1',stem+'.c',...recipe.linkArgs,'-o',stem],{encoding:'utf8',timeout:45000,maxBuffer:2**20});
    row.compile={status:cc.status,stderr:cc.stderr,error:cc.error?.message};save();assert.equal(cc.status,0,cc.stderr||cc.error?.message);
    row.executable=pin(stem);
    for(const threads of [1,4]) {
      const run=spawnSync(stem,['--threads',String(threads),'--gpu','off'],{encoding:'utf8',timeout:10000,maxBuffer:2**20});
      row.runs.push({threads,status:run.status,stdout:run.stdout,stderr:run.stderr,pass:run.status===0&&run.stdout.trimEnd()===expected&&run.stderr===''});
    }
    row.pass=row.runs.every(x=>x.pass);save();assert(row.pass,JSON.stringify(row));
    if(name==='readback-boundaries'&&role==='candidate') {
      // Explicit diagnostic derivative: observe the representation at readback.
      // This checks both successful packing and preservation of wider payloads.
      const cid='CID__CTOR_'+[...'PackingBox68'].map(c=>c.codePointAt(0)).join('_')+'_';
      assert(got.source.includes('#define '+cid+' '));
      const anchor='      Term t   = w[0];';assert.equal(got.source.split(anchor).length,2);
      const witness=`\n      if (term_aux(t) == ${cid}) {\n        Term payload = term_tag(t) == TAG_PAK ? term_loc(t) : e.mem[term_peek(e, t)];\n        bool packed = term_tag(t) == TAG_PAK;\n        if (packed != ((payload & ~LOC_MASK) == 0)) err_fail("packing layout witness failed");\n        fprintf(stderr, "P68_%s:%llu\\n", packed ? "PACKED" : "BOXED", (unsigned long long)payload);\n      }`;
      const derivative=got.source.replace(anchor,anchor+witness);
      const dc=stem+'-layout.c',binary=stem+'-layout';fs.writeFileSync(dc,derivative,{flag:'wx'});
      const observed='P68_PACKED:0\nP68_PACKED:1099511627775\nP68_BOXED:1099511627776\nP68_BOXED:281474976710655\n';
      const check={name:'packing-layout-witness',role,kind:'emitted-C-readback-layout-diagnostic',parent:pin(stem+'.c'),source:pin(dc),edits:[{before:anchor,after:anchor+witness,count:1}],expected,expectedStderr:observed,runs:[]};report.rows.push(check);save();
      const cc=spawnSync(recipe.clang,[...recipe.clangArgs.filter(x=>x!=='-O3'),'-O1',dc,...recipe.linkArgs,'-o',binary],{encoding:'utf8',timeout:45000,maxBuffer:2**20});
      check.compile={status:cc.status,stderr:cc.stderr,error:cc.error?.message};save();assert.equal(cc.status,0,cc.stderr||cc.error?.message);check.executable=pin(binary);
      for(const threads of [1,4]) {
        const run=spawnSync(binary,['--threads',String(threads),'--gpu','off'],{encoding:'utf8',timeout:10000,maxBuffer:2**20});
        check.runs.push({threads,status:run.status,stdout:run.stdout,stderr:run.stderr,pass:run.status===0&&run.stdout.trimEnd()===expected&&run.stderr===observed});
      }
      check.pass=check.runs.every(x=>x.pass);save();assert(check.pass,JSON.stringify(check));
    }
  }
  inputs.forEach(x=>assert.deepEqual(pin(x.file),x));
  for(const row of report.rows) {
    if(row.results)for(const result of Object.values(row.results))assert.deepEqual(pin(result.source.file),result.source);
    if(row.source)assert.deepEqual(pin(row.source.file),row.source);
    if(row.executable)assert.deepEqual(pin(row.executable.file),row.executable);
  }
  report.complete=report.rows.length===17;
  report.pass=report.complete&&report.rows.every(x=>x.pass);
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,rows:report.rows.length,error:report.error}));
