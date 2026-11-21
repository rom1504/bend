import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import zlib from 'node:zlib';
const out=path.resolve(process.argv[process.argv.indexOf('--out')+1]);
fs.mkdirSync(out);
const read=p=>JSON.parse(fs.readFileSync(p));
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
function auth(row){const b=fs.readFileSync(row.file);if(b.length!==row.bytes||hash(b)!==row.sha256)throw Error('pin '+row.file);return b;}
const receipt=read('selfhost/build/phase199/baseline-api01/report.json');
const binding=read('selfhost/build/phase197/shared-emission-plan01.json').producer.bindingValue;
const old=auth(receipt.api).toString();
if(!old.includes('function $nc_definition_plain('))throw Error('erasure export unavailable');
const wrapper='\nexport const erase205=(book,d)=>run_loop($nc_definition_plain(book,d,0));\n';
const m=await import('data:text/javascript;base64,'+Buffer.from(old+wrapper).toString('base64'));
const a=m.default,prep=a.p88_cache_prepare(binding.base.file,auth(binding.base).toString(),auth(binding.carrier).toString(),binding.stamp);
if(prep.$!=='P86PreparationReady')throw Error('base');
function list(x){const a=[];for(;x.$==='Con';x=x.tail)a.push(x.head);if(x.$!=='Nil')throw Error('list');return a;}
function term(t){
 if(t.$==='KLiteral')return {t:'Lit',n:t.kind,i:t.number,s:t.text,k:[]};
 if(t.$!=='KLambda'&&t.$!=='KTerm')throw Error(t.$);
 const tag=t.$==='KLambda'?'Lam':t.tag;
 return {t:tag,n:t.name,i:t.id,q:t.quant,k:tag==='Var'?[]:list(t.kids).map(term)};
}
const dir='selfhost/tools/bench/catalogs/native45/fixtures/';
const inputs={bst:dir+'coverage-bst-64.bend',text:dir+'coverage-unicode-text-64.bend',lexer:dir+'lexer.bend',compact:'selfhost/build/phase200/tree-source01/compact.bend'};
for(const [role,p] of Object.entries(inputs)){
 const src=fs.readFileSync(p).toString();
 const plan=a.p86_plan(prep.seed,path.resolve(p),src);if(plan.$!=='P86PlanReady')throw Error(role+' '+plan.error);
 const book=plan.request.book;
 const selected=new Set([...src.matchAll(/^(?:def|type) ([\w.]+)/gm)].map(m=>m[1]));
 for(const s of ['String.take','String.drop','String.find','String.append','List','Bool','String','Tuple','U32.is_lt'])selected.add(s);
 const defs=[];
 for(const d of list(book)){
  if(d.$!=='KDef'||!selected.has(d.name))continue;
  const r={name:d.name,kind:d.kind,arity:d.arity,typ:term(d.typ??d.type),checked:term(d.value)};
  if(d.kind==='Def')r.erased=term(m.erase205(book,d));
  defs.push(r);
 }
 if(defs.length<3)throw Error(role+' missing checked definitions');
 const dest=path.join(out,role+'.json.gz');fs.writeFileSync(dest,zlib.gzipSync(JSON.stringify({source:p,sourceHash:hash(src),api:receipt.api,defs})));
 console.log(role,defs.length,dest);
}
