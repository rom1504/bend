// Untimed operation attribution for frozen, checked upstream-emitted Bend APIs.
// The wrappers intentionally perturb execution; their elapsed time is not evidence.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [apiFile,outputDirectory]=process.argv.slice(2);
if(!apiFile||!outputDirectory)throw Error('Usage: analysis-probe.mjs BASELINE_B1.mjs NEW_OUTPUT_DIRECTORY');
const sourceFile=fs.realpathSync(apiFile),out=path.resolve(outputDirectory);fs.mkdirSync(out,{recursive:false});
const sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const source=fs.readFileSync(sourceFile,'utf8'),names=['annotate','ka_node','ka_type','ka_type_node','core_beta','wnf','subst','subst_terms','lookup','signature_mode','nc_tele_fill','nc_live_count','nc_erase_args','nc_context_defs','nc_ctor_owned'];
const rawNames=['nc_tele_fill','nc_live_count','nc_erase_args','signature_mode'];
for(const name of names)assert(source.includes(`function $${name}$(`),'Missing frozen worker '+name);
const counterCode=`\nconst __counts=Object.create(null);\n`+names.map(name=>{
 const key='$'+name+'$';const extra=name==='lookup'?`if(args[0]?.$==='Con')__counts[args[0].head.kind==='BookCache'?'lookupCached':'lookupRawStep']=(__counts[args[0].head.kind==='BookCache'?'lookupCached':'lookupRawStep']||0)+1;`:'';
 return `{const original=${key};${key}=function(...args){__counts[${JSON.stringify(name)}]=(__counts[${JSON.stringify(name)}]||0)+1;${extra}return original.apply(this,args);};}`;
}).join('\n')+`\nexport const counterProbe={reset(){for(const k of Object.keys(__counts))delete __counts[k]},read(){return {...__counts}}};\n`;
const rawCode=`\nexport const rawProbe={${rawNames.map(name=>`${name}:(...args)=>run_loop($${name}$(...args))`).join(',')}};\n`;
const instrumented=path.join(out,'counted.mjs'),plain=path.join(out,'plain.mjs');fs.writeFileSync(instrumented,source+counterCode+rawCode);fs.writeFileSync(plain,source+rawCode);
const {default:K,counterProbe:C,rawProbe:R}=await import(pathToFileURL(instrumented));const {default:B,rawProbe:P}=await import(pathToFileURL(plain));
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
const t=(tag,name='',id=0,quant=0,kids=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:nil});
const typ=q=>t('Typ','',0,0,[t('Qua','',0,q)]),all=(id,a,b)=>t('All','x'+id,id,1,[a,b]),lam=(id,b)=>t('Lam','x'+id,id,1,[b]);
const adt=t('ADT','Bool'),truth=t('Ctr','True');
const d=(name,type,value=t('Absent'),arity=0,kind='Def',ctors=[])=>({$:'KDef',name,kind,arity,templates:0,typ:type,value,ctors:list(ctors),native:false,unsafe:false});
const bool=d('Bool',typ(2),t('Absent'),0,'ADT',[d('True',adt,t('Absent'),0,'Ctr'),d('False',adt,t('Absent'),0,'Ctr')]);
const checked=book=>assert.equal(B.check_book(book),'','Synthetic source must pass the unchanged checker');
const rows=[];
function record(kind,size,operation,reference){C.reset();const actual=operation();const counts=C.read();assert.deepEqual(actual,reference());rows.push({kind,size,counts,resultSha256:sha(JSON.stringify(actual))});}
for(const n of [4,8,16,32,64]){
 let type=adt,body=truth,call=t('Ref','f');for(let i=n-1;i>=0;i--){type=all(100+i,adt,type);body=lam(100+i,body);}for(let i=0;i<n;i++)call=t('App','',0,0,[call,truth]);
 const book=list([bool,d('f',type,body,n),d('main',adt,call)]);checked(book);
 record('annotation-application-spine',n,()=>K.annotate_selected(book,list([d('main',adt,call)]),nil),()=>B.annotate_selected(book,list([d('main',adt,call)]),nil));
}
for(const n of [8,16,32,64,128]){
 const laws=Array.from({length:n},(_,i)=>d('claim'+i,adt));const fills=laws.map(x=>({...x,value:truth}));const book=list([bool,...laws,...fills]);checked(book);
 record('checker-law-suffix',n,()=>K.check_book(book),()=>B.check_book(book));
}
for(const n of [4,8,16,32]){
 let tel=adt;for(let i=n-1;i>=0;i--)tel=all(500+i,adt,tel);const book=list([bool]),args=list(Array.from({length:n},()=>truth));
 record('native-telescope-fill',n,()=>R.nc_tele_fill(book,tel,args),()=>P.nc_tele_fill(book,tel,args));
 record('native-live-count',n,()=>R.nc_live_count(book,tel,n),()=>P.nc_live_count(book,tel,n));
 record('native-erase-arguments',n,()=>R.nc_erase_args(book,tel,args),()=>P.nc_erase_args(book,tel,args));
}
for(const n of [32,64,128,256]){
 const defs=Array.from({length:n},(_,i)=>d('value'+i,adt,truth)),book=list([bool,...defs]);checked(book);const annotations=list(defs.filter((_,i)=>i%4===0).map(x=>({...x,value:t('Ann','',0,0,[truth,adt])})));
 record('native-annotated-context',n,()=>K.nc_annotated_context(book,annotations),()=>B.nc_annotated_context(book,annotations));
}
const report={kind:'phase3-analysis-operation-counts',api:{file:sourceFile,sha256:sha(source)},instrumented:{file:instrumented,sha256:sha(fs.readFileSync(instrumented))},probe:{file:fs.realpathSync(process.argv[1]),sha256:sha(fs.readFileSync(process.argv[1]))},node:process.version,rows,unchanged:sha(fs.readFileSync(sourceFile))===sha(source),allExact:true,note:'Operation counts from a perturbed disposable API, not timing measurements. Synthetic books are checked by the unchanged compiler and all counted results are deeply equal to the unchanged API.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report,null,2));
